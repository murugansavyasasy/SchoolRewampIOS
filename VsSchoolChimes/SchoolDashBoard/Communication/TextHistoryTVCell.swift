//
//  TextHistoryTVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 16/11/24.
//

import UIKit
protocol SelectedTextDelegate{
    func select(Tittle:String,descriptContent:String)
}

protocol TextExpandCellDelegate: AnyObject {
    func didTapExpand(in cell: TextHistoryTVCell)
}

class TextHistoryTVCell: UITableViewCell {
    
    @IBOutlet weak var sendBtnheight: NSLayoutConstraint!
    @IBOutlet weak var NewImageView: UIImageView!
    @IBOutlet weak var newImageOuterView: UIView!
    @IBOutlet weak var sendBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var DateLabel: ShimmerLabel!
    @IBOutlet weak var MessageTitle: ShimmerLabel!
    
    @IBOutlet weak var descriptContent: ShimmerLabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var outerview: ShimmerView2!
    var delegate : SelectedTextDelegate?
    var ExpandDelegate: TextExpandCellDelegate?
    private var isExpanded = false
    private var fullText: String = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        outerview.layer.shadowColor = UIColor.black.cgColor
        outerview.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerview.layer.shadowRadius = 5
        outerview.layer.shadowOpacity = 0.3
        outerview.layer.cornerRadius = 20
        sendBtn.layer.cornerRadius = 4
        MessageTitle.removeShimmer()
        DateLabel.removeShimmer()
        DateLabel.setFont(style: .body, size: FontSize.BodySize)
        MessageTitle.setFont(style: .title, size: FontSize.TitleSize)
        descriptContent.setFont(style: .body, size: FontSize.BodySize)
        sendBtn.isHidden = true
        setupTapGesture()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Assuming 'myLabel' is your UILabel
        descriptContent.preferredMaxLayoutWidth = descriptContent.frame.width
        
        configureShimmer()
    }
    
    @IBAction func Select(_ sender: UIButton) {
        delegate?.select(Tittle: MessageTitle.text ?? "selectedText", descriptContent: descriptContent.text ?? "hgdsxgvbdusf")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureShimmer() {
        MessageTitle.removeShimmer()
        DateLabel.removeShimmer()
        descriptContent.removeShimmer()
        outerview.removeShimmer()
        sendBtn.isHidden = false
    }
    
    func configure(with text: String, expanded: Bool, isUnread: Bool) {
            self.fullText = text
            self.isExpanded = expanded
            self.descriptContent.attributedText = getAttributedText(for: text, expanded: expanded)
            self.descriptContent.numberOfLines = expanded ? 0 : (text.count > 120 ? 3 : 0)
            self.NewImageView.isHidden = !isUnread
        self.newImageOuterView.isHidden = !isUnread
        }

        private func setupTapGesture() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap(_:)))
            descriptContent.isUserInteractionEnabled = true
            descriptContent.addGestureRecognizer(tap)
        }

    @objc private func handleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let text = descriptContent.attributedText?.string else { return }

        // Check which keyword to respond to
        let keyword = isExpanded
            ? (text.count > 120 ? "Hide" : nil)  // Only react to "Hide" for long text
            : "View"

        guard let target = keyword else { return }

        let tapRange = (text as NSString).range(of: target)
        if gesture.didTapAttributedTextInLabel(label: descriptContent, inRange: tapRange) {
            ExpandDelegate?.didTapExpand(in: self)
        }
    }


    private func getAttributedText(for text: String, expanded: Bool) -> NSAttributedString {
        let threshold = 120
        let attributed = NSMutableAttributedString()

        if text.count > threshold {
            if expanded {
                let full = text + " Hide"
                attributed.append(NSAttributedString(string: full))
                let range = (full as NSString).range(of: "Hide")
                attributed.addAttribute(.foregroundColor, value: UIColor.link, range: range)
            } else {
                let truncated = String(text.prefix(100)) + "... View"
                attributed.append(NSAttributedString(string: truncated))
                let range = (truncated as NSString).range(of: "View")
                attributed.addAttribute(.foregroundColor, value: UIColor.link, range: range)
            }
        } else {
            if expanded {
                // Just show full text, no "Hide"
                attributed.append(NSAttributedString(string: text))
            } else {
                let collapsed = text + " View"
                attributed.append(NSAttributedString(string: collapsed))
                let range = (collapsed as NSString).range(of: "View")
                attributed.addAttribute(.foregroundColor, value: UIColor.link, range: range)
            }
        }

        return attributed
    }

}
