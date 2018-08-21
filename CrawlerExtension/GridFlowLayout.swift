import UIKit

class GridFlowLayout: UICollectionViewFlowLayout {
    private let margin: CGFloat = 10
    private let itemHeight: CGFloat = 130
    var row: Int {
        return UIDevice.current.isLandscape ? (UIDevice.current.isPad ? 7 : 5) : UIDevice.current.isPad ? 6 : 3
    }
    
    override init() {
        super.init()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    /**
     Sets up the layout for the collectionView. 1pt distance between each cell and 1pt distance between each row plus use a vertical layout
     */
    func setupLayout() {
        minimumInteritemSpacing = margin
        //        minimumLineSpacing = 15
        scrollDirection = .vertical
        sectionInset = UIEdgeInsets(top: 20, left: margin, bottom: margin, right: margin)
    }
    
    /// here we define the width of each cell, creating a 2 column layout. In case you would create 3 columns, change the number 2 to 3
    func itemWidth() -> CGFloat {
        return (collectionView!.frame.width - (CGFloat( row + 1) * margin)) / CGFloat(row)
    }
    
    override var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width: itemWidth(), height: itemHeight)
        }
        get {
            return CGSize(width: itemWidth(), height:itemHeight)
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return collectionView?.contentOffset ?? .zero
    }
}

extension UIDevice {
    public var isLandscape: Bool {
        return [UIDeviceOrientation.landscapeLeft, UIDeviceOrientation.landscapeRight].contains(UIDevice.current.orientation)
    }
    
    public var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
