import UIKit
import MobileCoreServices
import KingfisherWebP
import Kingfisher
import ATGMediaBrowser

class ActionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var imageURLs: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private let modifier = AnyModifier { request in
        var r = request
        r.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 10_2_1 like Mac OS X) AppleWebKit/602.4.6 (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/602.1", forHTTPHeaderField: "User-Agent")
        return r
    }
    
    private var isImpactOccurred: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.alwaysBounceVertical = true
        view.backgroundColor = #colorLiteral(red: 0.1607843137, green: 0.168627451, blue: 0.2117647059, alpha: 1)
        collectionView.backgroundColor = view.backgroundColor
        
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        //        navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.shadowImage = UIImage()
        //        navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        navigationController?.navigationBar.backgroundColor = view.backgroundColor
        
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                
                provider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [unowned self] (dict, error) in
                    
                    guard
                        let itemDictionary = dict as? [String: Any],
                        let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? [String: Any]
                        else { return }
                    let pageTitle = javaScriptValues["title"] as? String
//                    let url = javaScriptValues["URL"] as? String
                    guard let imageURLs = javaScriptValues["imageURLs"] as? [String] else { return }
                    
                    print(imageURLs, imageURLs.count)
                    
                    DispatchQueue.main.async {
                        self.title = pageTitle
                        let urls  = imageURLs
                            .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).count > 10 }
                            .filter { !$0.hasSuffix(".svg")}
                            .map { $0.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\'", with: "") }
                        let set = Set<String>(urls)
                        self.imageURLs = Array(set)
                    }
                }
            }
        }
    }
    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
}

extension ActionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let urlString = imageURLs[indexPath.item]
        
        cell.imageView.kf.setImage(with: URL(string: urlString),
                                   placeholder: #imageLiteral(resourceName: "placeholder.png"), options: [
                                    .processor(WebPProcessor.default),
                                    .cacheSerializer(WebPSerializer.default),
                                    .requestModifier(modifier),
                                    .backgroundDecode,
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let mediaBrowser = MediaBrowserViewController(index: indexPath.item, dataSource: self, delegate: self)//MediaBrowserViewController(dataSource: self)
        //        mediaBrowser.autoHideControls = false
        mediaBrowser.hideControls = imageURLs.count > 10
        present(mediaBrowser, animated: true, completion: nil)
        let urlString = imageURLs[indexPath.item]
        print(urlString)
    }
}

extension ActionViewController: MediaBrowserViewControllerDataSource {
    func numberOfItems(in mediaBrowser: MediaBrowserViewController) -> Int {
        return imageURLs.count
    }
    
    func mediaBrowser(_ mediaBrowser: MediaBrowserViewController, imageAt index: Int, completion: @escaping MediaBrowserViewControllerDataSource.CompletionBlock) {
        let cell = collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ImageCell
        let image = cell?.imageView.image ?? #imageLiteral(resourceName: "placeholder.png")
        completion(index, image, ZoomScale.default, nil)
    }
}

extension ActionViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        headerLabel.text = scrollView.contentOffset.y <= -(scrollView.contentInset.top + 100) ? "松开关闭查看" : "下拉关闭查看"
        
        if scrollView.contentOffset.y <= -(scrollView.contentInset.top + 100) {
            if isImpactOccurred { return }
            isImpactOccurred = true
            if #available(iOS 10.0, *) {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.prepare()
                generator.impactOccurred()
            }
        } else {
            isImpactOccurred = false
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 下拉关闭
        if scrollView.contentOffset.y <= -(scrollView.contentInset.top + 100) {
            // 让scrollView 不弹跳回来
            scrollView.contentInset = UIEdgeInsetsMake(-1 * scrollView.contentOffset.y, 0, 0, 0)
            scrollView.isScrollEnabled = false
            done()
        }
    }
}

extension ActionViewController: MediaBrowserViewControllerDelegate {
    func mediaBrowser(_ mediaBrowser: MediaBrowserViewController, didChangeFocusTo index: Int) {
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredVertically, animated: false)
    }
}
