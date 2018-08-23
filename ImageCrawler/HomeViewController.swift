import UIKit

class HomeViewController: BaseFileViewController {
    
    private lazy var textFiled: UITextField = {
        let view = UITextField()
        view.frame = CGRect(x: 0, y: 0, width: 300, height: 35)
        view.placeholder = "Website url or search"
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
        view.delegate = self
        return view
    }()
    
    init() {
        super.init(initialPath: Constants.Config.rootDir, title: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var items: [FileItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        definesPresentationContext = true
        
        
        navigationItem.titleView = textFiled
        textFiled.text = "https://unsplash.com/"
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textFiled.resignFirstResponder()
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        guard let urlString = textField.text else { return true }
        
        let webVC = WebViewController(urlString: urlString)
        navigationController?.pushViewController(webVC, animated: true)
        return true
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
