import UIKit

class DynamicHeightTableView: UITableView {
    
    var onContentSizeChange: (() -> Void)?
    
    override var contentSize: CGSize {
        didSet {
            if oldValue != contentSize {
                invalidateIntrinsicContentSize()
                onContentSizeChange?()
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

