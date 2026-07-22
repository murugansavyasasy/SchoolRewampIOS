import UIKit

public enum SchedulingType {
    case date(String)
    case time(String)
    case session(String)
    case venue(String)
    case syllabus(String)
    
    var title: String {
        switch self {
        case .date: return "DATE"
        case .time: return "TIME"
        case .session: return "SESSION"
        case .venue: return "VENUE"
        case .syllabus: return "SYLLABUS"
        }
    }
    
    var value: String {
        switch self {
        case .date(let val): return val
        case .time(let val): return val
        case .session(let val): return val
        case .venue(let val): return val
        case .syllabus(let val): return val
        }
    }
    
    var iconName: String {
        switch self {
        case .date: return "calendar"
        case .time: return "clock"
        case .session: return "sun.max"
        case .venue: return "mappin.and.ellipse"
        case .syllabus: return "book"
        }
    }
    
    var iconTintColor: UIColor {
        switch self {
        case .date: return UIColor(red: 25/255, green: 118/255, blue: 210/255, alpha: 1.0)
        case .time: return UIColor(red: 142/255, green: 36/255, blue: 170/255, alpha: 1.0)
        case .session: return UIColor(red: 67/255, green: 160/255, blue: 71/255, alpha: 1.0)
        case .venue: return UIColor(red: 251/255, green: 140/255, blue: 0/255, alpha: 1.0)
        case .syllabus: return UIColor(red: 0/255, green: 137/255, blue: 123/255, alpha: 1.0)
        }
    }
    
    var iconBackgroundColor: UIColor {
        switch self {
        case .date: return UIColor(red: 227/255, green: 242/255, blue: 253/255, alpha: 1.0)
        case .time: return UIColor(red: 243/255, green: 229/255, blue: 245/255, alpha: 1.0)
        case .session: return UIColor(red: 232/255, green: 245/255, blue: 233/255, alpha: 1.0)
        case .venue: return UIColor(red: 255/255, green: 243/255, blue: 224/255, alpha: 1.0)
        case .syllabus: return UIColor(red: 224/255, green: 242/255, blue: 241/255, alpha: 1.0)
        }
    }
}

@IBDesignable
public class SchedulingRowView: UIView {
    
    @IBOutlet public weak var iconContainerView: UIView!
    @IBOutlet public weak var iconImageView: UIImageView!
    @IBOutlet public weak var lblCategoryTitle: UILabel!
    @IBOutlet public weak var lblDetailValue: UILabel!
    @IBOutlet public weak var separatorView: UIView!
    
    private var contentView: UIView?
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 60)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        contentView = view
        iconContainerView?.layer.cornerRadius = 10
        iconContainerView?.clipsToBounds = true
    }
    
    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "SchedulingRowView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    public func configure(type: SchedulingType, showSeparator: Bool = true) {
        lblCategoryTitle.text = type.title
        lblDetailValue.text = type.value
        
        iconContainerView.backgroundColor = type.iconBackgroundColor
        iconImageView.tintColor = type.iconTintColor
        
        if #available(iOS 13.0, *) {
            iconImageView.image = UIImage(systemName: type.iconName)
        } else {
            iconImageView.image = UIImage(named: type.iconName)
        }
        
        separatorView.isHidden = !showSeparator
        invalidateIntrinsicContentSize()
    }
}
