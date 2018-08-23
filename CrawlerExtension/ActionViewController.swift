import UIKit
import MobileCoreServices

class ActionViewController: ImagesViewController {
    
    private var isImpactOccurred: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                        self.configImageURLs(imageURLs)
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
