import UIKit
import ATGMediaBrowser

class BaseFileViewController: UIViewController, FileService {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        view.rowHeight = 70
        view.separatorInset = .zero
        view.register(FileCell.self, forCellReuseIdentifier: FileCell.description())
        view.tableFooterView = UIView()
        view.keyboardDismissMode = .onDrag
        view.cellLayoutMarginsFollowReadableWidth = false
        self.view.addSubview(view)
        return view
    }()
    
    public var initialPath: URL
    
    var files: [FileItem] = []
    
    var isEdit: Bool = false
    
    
    init(initialPath: URL, title: String) {
        self.initialPath = initialPath
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.pin(to: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadPath()
    }
    
    private func loadPath() {
        var paths: [String] = []
        let path = initialPath.relativePath
        do {
            paths = try FileManager.default.contentsOfDirectory(atPath: path)
        } catch {
            print(error.localizedDescription)
        }

        DispatchQueue.global(qos: .background).async {
            let filelist = self.toModel(for: paths, rootPath: path)
            DispatchQueue.main.async {
                self.files = filelist
                self.tableView.reloadData()
            }
        }
    }
}

extension BaseFileViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FileCell.description()) as! FileCell
        cell.config(file: files[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < files.count else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let file = files[indexPath.row]
        
        if file.isDir {
            let fileVC = BaseFileViewController(initialPath: file.fileURL, title: file.name)
            navigationController?.pushViewController(fileVC, animated: true)
        } else {
            let mediaBrowser = MediaBrowserViewController(index: indexPath.row, dataSource: self, delegate: self)
            mediaBrowser.hideControls = files.count > 10
            present(mediaBrowser, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let shareAction = UITableViewRowAction(style: .normal, title: "分享") { [weak self] action, indexPath in
            guard let `self` = self else { return }
            let item = self.files[indexPath.row]
        }
        shareAction.backgroundColor = #colorLiteral(red: 0, green: 0.3517866135, blue: 0.9266097546, alpha: 1)
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "删除") { [weak self] _, indexPath in
            guard let `self` = self else { return }
            let item = self.files[indexPath.row]
            self.files.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            do {
                try FileManager.default.removeItem(at: item.fileURL)
            } catch {
                print(error)
            }
        }
        return [deleteAction, shareAction]
    }
    
}


extension BaseFileViewController: MediaBrowserViewControllerDataSource {
    public func numberOfItems(in mediaBrowser: MediaBrowserViewController) -> Int {
        return files.count
    }
    
    public func mediaBrowser(_ mediaBrowser: MediaBrowserViewController, imageAt index: Int, completion: @escaping MediaBrowserViewControllerDataSource.CompletionBlock) {
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? FileCell
        let image = cell?.imageView?.image ?? #imageLiteral(resourceName: "placeholder.png")
        completion(index, image, .default, nil)
    }
}

extension BaseFileViewController: MediaBrowserViewControllerDelegate {
    public func mediaBrowser(_ mediaBrowser: MediaBrowserViewController, didChangeFocusTo index: Int) {
        tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: false)
    }
}
