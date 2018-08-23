import Foundation
import UIKit

struct Closure {
    typealias Completion = () -> Void
    typealias Failure = (NSError?) -> Void
}

struct Constants {

    struct Config {
        // App
        static var token = "com.aidevjoe.imageCrawler"
        
        static let rootDir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Images")
        
        static var receiverEmail = "aidevjoe@gmail.com"
        
        static let AppID = "1363499992"
        
        
    }

    struct Metric {

        static let screenWidth: CGFloat = UIScreen.main.bounds.width
        static let screenHeight: CGFloat = UIScreen.main.bounds.height
    }
    
    struct Colors {
        static let mainColor = #colorLiteral(red: 0.0862745098, green: 0.5137254902, blue: 0.8666666667, alpha: 1)// #colorLiteral(red: 0.5058823529, green: 0.8117647059, blue: 0.9764705882, alpha: 1)
        static let highlightColor = UIColor(red: 150 / 255, green: 200 / 255, blue: 1, alpha: 1)
    }
}

