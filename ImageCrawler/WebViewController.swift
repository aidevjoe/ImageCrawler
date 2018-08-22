import UIKit
import WebKit

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        view.addSubview(webView)
        webView.pin(to: view)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.navigationDelegate = nil
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
        guard var urlString = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        if !urlString.hasPrefix("https://") && !urlString.hasPrefix("http://") {
            urlString = "http://" + urlString
        }
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        self.webView.load(request)
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
        
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
