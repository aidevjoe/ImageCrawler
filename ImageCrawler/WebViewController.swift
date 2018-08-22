import UIKit
import WebKit
import CrawlerCore

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
    
    private lazy var imagesViewController = ImagesViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        view.addSubview(webView)
        webView.pin(to: view)
    
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
    }
    
    @objc private func refresh() {
//        webView.reload()
        navigationController?.pushViewController(imagesViewController, animated: true)
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
        if newValue.floatValue < progressView.progress {
            progressView.setProgress(1, animated: true)
            return
        }
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
        
        webView.evaluateJavaScript("document.title", completionHandler: {(response, error) in
            self.title = response as? String
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
            """
        
        webView.evaluateJavaScript(script, completionHandler: { [weak self] response, error in
            print(response, error)
            webView.evaluateJavaScript("getImageSrc()", completionHandler: { [weak self] response, error in
                print(response, error)
                guard let imageURLs = response as? [String] else { return }
                self?.imagesViewController.imageURLs = imageURLs
            })
        })
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(webView.url)
        decisionHandler(.allow)
    }
}
