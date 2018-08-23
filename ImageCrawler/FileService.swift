import Foundation
import UIKit

protocol FileService {
    func toModel(for paths: [String], rootPath: String) -> [FileItem]
}

extension FileService {
    
    func convertModel(path: String, rootPath: String = "") -> FileItem {
        var isDir: ObjCBool = ObjCBool(false)
        
        let fullpath = (rootPath as NSString).appendingPathComponent(path)
        FileManager.default.fileExists(atPath: fullpath, isDirectory: &isDir)

        var childCount = 0
        if isDir.boolValue {
            childCount = (try? FileManager.default.contentsOfDirectory(atPath: fullpath).count) ?? 0
        }
        
        let attr = try? FileManager.default.attributesOfItem(atPath: fullpath)
//        let modificationDate = attr?[FileAttributeKey.modificationDate] as? Date ?? Date()
        let creationDate = attr?[FileAttributeKey.creationDate] as? Date ?? Date()
        let fileSize = attr?[FileAttributeKey.size] as? UInt ?? 0
        let image: UIImage = isDir.boolValue ? #imageLiteral(resourceName: "folder") : UIImage(contentsOfFile: fullpath)!
        var fileName = (path as NSString).lastPathComponent
        
        if isDir.boolValue{
            
            fileName = Base64FS.decodeString(str: fileName)
        }
        
        return FileItem(name: fileName,
                      path: fullpath,
                      creationDate: creationDate,
                      size: fileSize,
                      childFileCount: childCount,
                      isDir: isDir.boolValue,
                      image: image)
    }
    
    func toModel(for paths: [String], rootPath: String = "") -> [FileItem] {
        return paths
            .filter { !ignoreFiles().contains($0.lowercased()) }
            .map { convertModel(path: $0, rootPath: rootPath) }
            .sorted { $0.creationDate > $1.creationDate }
    }
    
    private func ignoreFiles() -> [String] {
        return [".DS_Store"].map { $0.lowercased() }
    }
}

extension UInt {
    var fileSize: String {
        var conversion = Float(self)
        var units = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        var unitCount = 0
        
        while conversion > 1024 {
            conversion /= 1024
            unitCount += 1
        }
        
        let isConversionInt = conversion.truncatingRemainder(dividingBy: 1) == 0
        let rounded = isConversionInt ? String(format: "%.0f", conversion) : String(format: "%.2f", conversion)
        
        return "\(rounded) \(units[unitCount])"
    }

}
