import Foundation
import UIKit
import MobileCoreServices
import KingfisherWebP
import Kingfisher
import ATGMediaBrowser

open class ImagesViewController: UIViewController {
    
    
    open lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: GridFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.description())
        return collectionView
    }()
    
    public var urlString: String = ""
    public var folderName: String = "" {
        didSet {
            title = folderName
        }
    }


    private var imageURLs: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    open func configImageURLs(_ urls: [String]) {
        let urls  = urls
            .map { $0.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\'", with: "") }
            .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).count > 5 }
            .filter { !$0.hasSuffix(".svg") && !$0.hasPrefix("data:image/svg+xml;")}
        let set = Set<String>(urls)
        imageURLs = Array(set)
    }
    
    private let modifier = AnyModifier { request in
        var r = request
        r.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 11_4 like Mac OS X) AppleWebKit/602.4.6 (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/602.1", forHTTPHeaderField: "User-Agent")
        return r
    }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.pin(to: view)
        
        view.backgroundColor = #colorLiteral(red: 0.1607843137, green: 0.168627451, blue: 0.2117647059, alpha: 1)
        collectionView.backgroundColor = view.backgroundColor
    }
}

extension ImagesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.description(), for: indexPath) as! ImageCell
        let urlString = imageURLs[indexPath.item]

        cell.imageView.kf.setImage(with: URL(string: urlString),
                                   placeholder: #imageLiteral(resourceName: "placeholder.png"), options: [
                                    .processor(WebPProcessor.default),
                                    .cacheSerializer(WebPSerializer.default),
                                    .requestModifier(modifier),
                                    .backgroundDecode,
                                    .targetCache(ImageCache(name: folderName, path: self.urlString, diskCachePathClosure: { [unowned self] path, cacheName -> String in
                                        let fullFolderName = folderName + Constants.Config.token + self.urlString
                                        let finalName = Base64FS.encodeString(str: fullFolderName)
                                        return Constants.Config.rootDir.appendingPathComponent(finalName).relativePath
                                    })),
                                    .transition(.fade(1))]){ (image, error, _, url) in
                                        if let err = error {
                                            print(err, url)
                                            cell.imageView.image = #imageLiteral(resourceName: "placeholder_error.png")
                                        }
        }
        cell.imageView.kf.indicatorType = .activity
        //            cell.imageView.kf.indicator = IndicatorView
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let mediaBrowser = MediaBrowserViewController(index: indexPath.item, dataSource: self, delegate: self)
        //        mediaBrowser.autoHideControls = false
        mediaBrowser.hideControls = imageURLs.count > 10
        present(mediaBrowser, animated: true, completion: nil)
        let urlString = imageURLs[indexPath.item]
        print(urlString)
    }
}

extension ImagesViewController: MediaBrowserViewControllerDataSource {
    public func numberOfItems(in mediaBrowser: MediaBrowserViewController) -> Int {
        return imageURLs.count
    }
    
    public func mediaBrowser(_ mediaBrowser: MediaBrowserViewController, imageAt index: Int, completion: @escaping MediaBrowserViewControllerDataSource.CompletionBlock) {
        let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ImageCell
        let image = cell?.imageView.image ?? #imageLiteral(resourceName: "placeholder.png")
        completion(index, image, ZoomScale.default, nil)
    }
}

extension ImagesViewController: MediaBrowserViewControllerDelegate {
    public func mediaBrowser(_ mediaBrowser: MediaBrowserViewController, didChangeFocusTo index: Int) {
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredVertically, animated: false)
    }
}
