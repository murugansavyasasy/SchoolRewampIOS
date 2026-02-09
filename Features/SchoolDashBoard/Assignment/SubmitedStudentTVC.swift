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
    @IBOutlet weak var reasonLbl: UILabel!
    
    var onBlock: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialBtn.setShadow(cornerRadius: initialBtn.frame.width/2)
        reasonLbl.isHidden = true
    }
    
    func setLabelWithIcon(label: UILabel, iconName: String, text: String) {
        let attachment = NSTextAttachment()
        if let iconImage = UIImage(named: iconName) {
            let fontHeight = label.font.lineHeight
            attachment.image = iconImage
            attachment.bounds = CGRect(x: 0,y: (label.font.capHeight - fontHeight) / 2,width: fontHeight,height: fontHeight)
        }

        let attachmentString = NSAttributedString(attachment: attachment)
        let textString = NSAttributedString(string: " \(text)",attributes: [.font: label.font ?? 0])
        let finalString = NSMutableAttributedString()
        finalString.append(attachmentString)
        finalString.append(textString)

        label.attributedText = finalString
    }

    
    @IBAction func BtnAct(_ sender: UIButton) {
        onBlock?()
    }
}
