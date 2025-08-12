//
//  SubmitedStudentTVC.swift
//  School Chimes
//
//  Created by Chandhru on 18/06/25.
//

import UIKit

class SubmitedStudentTVC: UITableViewCell {
    @IBOutlet weak var initialBtn: UIButton!
    @IBOutlet weak var statusView: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var standerdScection: UILabel!
    @IBOutlet weak var submitDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initialBtn.setShadow(cornerRadius: initialBtn.frame.width/2)
//       x5 applyShadowAndCornerRadius(to: outerView)
    }
    func setLabelWithIcon(label: UILabel, iconName: String, text: String) {
        // Create attachment for the icon
        let attachment = NSTextAttachment()
        if let iconImage = UIImage(named: iconName) {
            let fontHeight = label.font.lineHeight
            attachment.image = iconImage
            
            // Scale icon to match text height
            attachment.bounds = CGRect(
                x: 0,
                y: (label.font.capHeight - fontHeight) / 2, // Vertical alignment
                width: fontHeight,
                height: fontHeight
            )
        }

        // Create attributed string
        let attachmentString = NSAttributedString(attachment: attachment)
        let textString = NSAttributedString(
            string: " \(text)",
            attributes: [.font: label.font]
        )

        // Combine
        let finalString = NSMutableAttributedString()
        finalString.append(attachmentString)
        finalString.append(textString)

        label.attributedText = finalString
    }

}
