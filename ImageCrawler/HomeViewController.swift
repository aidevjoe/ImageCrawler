import UIKit

class HomeViewController: UIViewController {
    
    private lazy var textFiled: UITextField = {
        let view = UITextField()
        view.frame = CGRect(x: 0, y: 0, width: 300, height: 35)
        view.placeholder = "Website url or search"
        
        //        searchController.searchBar.barTintColor = UIColor.white
        view.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.9098039216, blue: 0.9137254902, alpha: 1)
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.white.cgColor
        view.keyboardType = .asciiCapable
        view.addLeftTextPadding(10)
        view.layer.cornerRadius = 9
        view.layer.masksToBounds = true
        view.clearButtonMode = .always
        view.keyboardType = .webSearch
        view.returnKeyType = .go
        view.autocapitalizationType = .none
        view.autocorrectionType = .no
        return view
    }()
    
//    private lazy var webViewController: WebViewController = {
//        let view = WebViewController()
//        return view
//    }() 
//
//    private lazy var searchController: UISearchController = {
//        let searchController = UISearchController(searchResultsController: webViewController)
////        searchController.searchResultsUpdater = webViewController
//        searchController.searchBar.delegate = webViewController
//        searchController.searchBar.barTintColor = .white
//        searchController.searchBar.textField?.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.9098039216, blue: 0.9137254902, alpha: 1)
//        searchController.searchBar.textField?.leftViewMode = .never
////        searchController.searchBar.tintColor = Constants.Colors.globalTintColor
//        searchController.searchBar.layer.borderWidth = 0.5
//        searchController.searchBar.layer.borderColor = UIColor.white.cgColor
//        searchController.searchBar.keyboardType = .webSearch
//        searchController.searchBar.returnKeyType = .go
//        searchController.searchBar.showsCancelButton = false
//        searchController.searchBar.autocapitalizationType = .none
//        searchController.hidesNavigationBarDuringPresentation = false
//        searchController.searchBar.searchBarStyle = .prominent
//        return searchController
//    }()
    
    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        let textField = (view.value(forKey: "searchField") as? UITextField)
        textField?.leftViewMode = .never
        view.placeholder = "Search or enter a link"
        textField?.backgroundColor = #colorLiteral(red: 0.9058823529, green: 0.9098039216, blue: 0.9137254902, alpha: 1)
        view.sizeToFit()
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        definesPresentationContext = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(action))
        
        navigationItem.titleView = searchBar//textFiled//searchController.searchBar//textFiled
        
    }
    
    @objc private func action() {
//        searchController.view.isHidden = !searchController.view.isHidden
    }
    
}

extension HomeViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        guard let urlString = searchBar.text else { return }
        
        let webVC = WebViewController()
        webVC.load(for: urlString)
        navigationController?.pushViewController(webVC, animated: true)
    }
}

extension UITextField {
    
    /// Add left padding to the text in textfield
    public func addLeftTextPadding(_ blankSize: CGFloat) {
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: blankSize, height: frame.height)
        self.leftView = leftView
        self.leftViewMode = UITextFieldViewMode.always
    }
    
    /// Add a image icon on the left side of the textfield
    public func addLeftIcon(_ image: UIImage?, frame: CGRect, imageSize: CGSize) {
        let leftView = UIView()
        leftView.frame = frame
        let imgView = UIImageView()
        imgView.frame = CGRect(x: frame.width - 8 - imageSize.width, y: (frame.height - imageSize.height) / 2, width: imageSize.width, height: imageSize.height)
        imgView.image = image
        leftView.addSubview(imgView)
        self.leftView = leftView
        self.leftViewMode = UITextFieldViewMode.always
    }
}

extension UISearchBar {
    var textField: UITextField? {
        let subViews = subviews.flatMap { $0.subviews }
        guard let textField = (subViews.filter { $0 is UITextField}).first as? UITextField else { return nil }
        return textField
    }
    var cancelButton: UIButton? {
        let subViews = subviews.flatMap { $0.subviews }
        guard let button = (subViews.filter { $0 is UIButton}).first as? UIButton else { return nil }
        return button
    }
}
