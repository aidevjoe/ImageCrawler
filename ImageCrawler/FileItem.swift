import UIKit

public struct FileItem {
    
    public var name: String
    public var path: String
    
    public let creationDate: Date
    public let size: UInt
    public var childFileCount: Int
    
    public var isDir: Bool
    public var image: UIImage
    
    public var fileURL: URL {
        return URL(fileURLWithPath: path)
    }
}

