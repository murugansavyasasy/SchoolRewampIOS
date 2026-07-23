import UIKit

@IBDesignable
public class RubricItemView: UIView {

    @IBOutlet public weak var cardContainerView: UIView!
    @IBOutlet public weak var iconCheckmark: UIImageView!
    @IBOutlet public weak var lblRubricName: UILabel!
    @IBOutlet public weak var iconChevron: UIImageView!
    
    public var onTap: (() -> Void)?
    private var contentView: UIView?

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 54)
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
        
        cardContainerView.layer.cornerRadius = 12
        cardContainerView.layer.borderWidth = 1
        cardContainerView.layer.borderColor = UIColor(red: 220/255, green: 230/255, blue: 242/255, alpha: 1.0).cgColor
        cardContainerView.backgroundColor = UIColor(red: 248/255, green: 250/255, blue: 255/255, alpha: 1.0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
        cardContainerView.addGestureRecognizer(tap)
        cardContainerView.isUserInteractionEnabled = true
    }
    
    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "RubricItemView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    public func configure(rubricName: String, onTap: (() -> Void)?) {
        lblRubricName.text = rubricName
        self.onTap = onTap
        invalidateIntrinsicContentSize()
    }
    
    @objc private func didTapCard() {
        UIView.animate(withDuration: 0.1, animations: {
            self.cardContainerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.cardContainerView.transform = .identity
            }
            self.onTap?()
        }
    }
}
