import UIKit

class FileCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        imageView?.contentMode = .scaleAspectFit
        textLabel?.font = UIFont.systemFont(ofSize: 15)
        detailTextLabel?.numberOfLines = 2
        detailTextLabel?.textColor = #colorLiteral(red: 0.7764705882, green: 0.7764705882, blue: 0.7764705882, alpha: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    public func config(file: FileItem) {
        imageView?.image = file.image
        let fileSize = file.size.fileSize
        let time = DateFormatter.localizedString(from: file.creationDate,
                                                 dateStyle: .short,
                                                 timeStyle: .short)
        
        let detail = time + " - " + fileSize
        
        let names = file.name.components(separatedBy: Constants.Config.token)
        
        if file.isDir && names.count == 2 {
            textLabel?.text = names.first!
            detailTextLabel?.text = "URL: " + names.last! + "\n" + detail
        } else {
            textLabel?.text = file.name
            detailTextLabel?.text = detail
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var imageFrame = imageView!.frame
        imageFrame.size.width = 45
        imageFrame.size.height = 45
        imageView?.frame = imageFrame
        imageView?.center.y = contentView.center.y
        
        var textLabelFrame = textLabel!.frame
        textLabelFrame.origin.x = imageFrame.maxX + 15
        textLabelFrame.origin.y = textLabelFrame.origin.y - 1
        textLabel?.frame = textLabelFrame
        
        var detailLabelFrame = detailTextLabel!.frame
        detailLabelFrame.origin.x = textLabelFrame.origin.x
        detailLabelFrame.origin.y = detailLabelFrame.origin.y + 1
        detailTextLabel?.frame = detailLabelFrame
    }
}

