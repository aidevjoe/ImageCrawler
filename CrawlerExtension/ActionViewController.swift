import UIKit
import MobileCoreServices
import KingfisherWebP
import Kingfisher

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                
                provider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [unowned self] (dict, error) in
                    
                    guard
                        let itemDictionary = dict as? [String: Any],
                        let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? [String: Any]
                        else { return }
                    let pageTitle = javaScriptValues["title"] as? String
                    let url = javaScriptValues["URL"] as? String
                    guard let imageURLs = javaScriptValues["imageURLs"] as? [String] else { return }
                    
                    print(imageURLs, imageURLs.count)
                    
                    DispatchQueue.main.async {
                        self.title = pageTitle
                        let urls  = imageURLs
                            .filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).count > 10 }
                            .filter { !$0.hasSuffix(".svg")}
                        let set = Set<String>(urls)
                        self.imageURLs = Array(set)
                        self.imageURLs = urls
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
        if let urlString = imageURLs[indexPath.item].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            cell.imageView.kf.setImage(with: URL(string: urlString), options: [
                .processor(WebPProcessor.default),
                .cacheSerializer(WebPSerializer.default),
                .requestModifier(modifier),
                .backgroundDecode,
                .transition(.fade(1))])
            cell.imageView.kf.indicatorType = .activity
//            cell.imageView.kf.indicator = IndicatorView
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let urlString = imageURLs[indexPath.item]
        print(urlString)
    }
}
