import UIKit
import WebKit
import Kingfisher
import KingfisherWebP

class WebViewController: UIViewController {
    
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        return view
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = .clear
        view.tintColor = #colorLiteral(red: 0.2941176471, green: 0.5450980392, blue: 0.9607843137, alpha: 1)
        if let navigationBar = self.navigationController?.navigationBar {
            self.navigationController?.navigationBar.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate(
                [view.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
                 view.leftAnchor.constraint(equalTo: navigationBar.leftAnchor),
                 view.rightAnchor.constraint(equalTo: navigationBar.rightAnchor),
                 view.heightAnchor.constraint(equalToConstant: 2)]
            )
        }
        return view
    }()
    
    private var imagesViewController: ImagesViewController = ImagesViewController()
    
    private let urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
        
        load(for: urlString)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        view.addSubview(webView)
        webView.pin(to: view)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }
    
    @objc private func refresh() {
        //        webView.reload()
        
        executeScript { [weak self] in
            if let vc = self?.imagesViewController {
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    deinit {
        print(self.classForCoder.description() + "Deinit")
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.navigationDelegate = nil
    }
    
    public func load(for url: String) {
        var urlString = url.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !urlString.hasPrefix("https://") && !urlString.hasPrefix("http://") {
            urlString = "http://" + urlString
        }
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        self.webView.load(request)
    }
}

extension WebViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let `keyPath` = keyPath else { return }
        
        switch keyPath {
        case "estimatedProgress":
            if let newValue = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                progressChanged(newValue)
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func progressChanged(_ newValue: NSNumber) {
        progressView.alpha = 1
        progressView.setProgress(newValue.floatValue, animated: true)
        if webView.estimatedProgress >= 1 {
            UIView.animate(withDuration: 0.3, delay: 0.4, options: .curveEaseOut, animations: {
                self.progressView.alpha = 0
            }, completion: { _ in
                self.progressView.setProgress(0, animated: false)
            })
        }
    }
}

extension WebViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let urlString = searchBar.text else { return }
        load(for: urlString)
        searchBar.showsCancelButton = false
    }
}


extension WebViewController: WKNavigationDelegate {
    
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        executeScript()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        executeScript()
//        decisionHandler(.allow)
//        
//        print("decidePolicyFor navigationAction")
//    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        executeScript()
        print("didCommit")
    }
    
    private func executeScript(_ completed: (() -> Void)? = nil) {
        
        webView.evaluateJavaScript("document.title", completionHandler: { [unowned self] response, error in
            self.title = response as? String
            self.imagesViewController.folderName = self.title ?? self.webView.url?.lastPathComponent ?? (self.urlString as NSString).lastPathComponent
            self.imagesViewController.urlString = self.webView.url?.absoluteString ?? self.urlString
        })
        
        let script = """
            function getImageSrc() {
                var urls = new Array();
                var nodes = document.getElementsByTagName('*');
                var disTag = ['br', 'hr', 'script', 'code', 'del', 'embed', 'frame', 'frameset', 'iframe', 'link', 'style', 'object', 'pre', 'video', 'wbr', 'xmp'];

                for (var i = 0, len = nodes.length; i < len; i++) {
                    var node = nodes[i];
                    if (disTag.indexOf(node.tagName) > -1) {
                        continue;
                    } else if (node.tagName.toLowerCase() == 'input' && (node.type == 'radio' || node.type == 'checkbox')) {
                        continue;
                    }
                    if (node.tagName.toLowerCase() == 'img') {
                        urls.push(node.src);
                    } else {
                        var bgImage;
                        if (document.defaultView && document.defaultView.getComputedStyle) {
                            bgImage = document.defaultView.getComputedStyle(node, null).backgroundImage;
                        } else {
                            bgImage = node.currentStyle.backgroundImage;
                        }
                        if (bgImage == 'none') {
                            continue;
                        }
                        var results = bgImage.match(/\\burl\\([^\\)]+\\)/gi);
                        if (results == null || results.length <= 0) {
                            continue;
                        }
                        var bgSrc = results[0].replace(/\\burl\\(|\\)/g, '').replace(/^\\s+|\\s+$/g, '');
                        urls.push(bgSrc);
                    }
                }
                return urls;
            }
            getImageSrc();
            """
        
        webView.evaluateJavaScript(script, completionHandler: { [weak self] response, error in
            guard let imageURLs = response as? [String] else { return }
            self?.imagesViewController.configImageURLs(imageURLs)
            
            imageURLs.forEach { self?.downloadImage(url: $0)}
            completed?()
        })
    }
    
    
    private func downloadImage(url: String) {
        guard let url = URL(string: url) else { return }
        KingfisherManager.shared.retrieveImage(with: url, options: [
            .processor(WebPProcessor.default),
            .cacheSerializer(WebPSerializer.default),
            .backgroundDecode,
            .targetCache(ImageCache(name: imagesViewController.folderName, path: imagesViewController.urlString, diskCachePathClosure: { [unowned self] path, cacheName -> String in
                let fullFolderName = self.imagesViewController.folderName + Constants.Config.token + imagesViewController.urlString
                let finalName = Base64FS.encodeString(str: fullFolderName)
                return Constants.Config.rootDir.appendingPathComponent(finalName).relativePath
            }))], progressBlock: nil, completionHandler: nil)
    }
}
