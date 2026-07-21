//
//  QuizSubmisionTvCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 13/09/25.
//

import UIKit
protocol call: AnyObject{
    func callMobileNumber(indexPath:Int)
}
class QuizSubmisionTvCell: UITableViewCell {

    @IBOutlet weak var imageViewWith: NSLayoutConstraint!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var addmissionLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var classLbl: UILabel!
    @IBOutlet weak var SubmittedOnBtn: UIButton!
    @IBOutlet weak var StatusBtn: UIButton!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var FNStack: UIStackView!
    @IBOutlet weak var ANStack: UIStackView!
    @IBOutlet weak var FNBtn: UIButton!
    @IBOutlet weak var ANBtn: UIButton!
    weak var delegate:call?
    override func awakeFromNib() {
        super.awakeFromNib()
       
        cellView.layer.cornerRadius = 10
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        StatusBtn.layer.cornerRadius = 15
        nameLbl.setFont(style: .title, size: FontSize.TitleSize)
        classLbl.setFont(style: .body, size: FontSize.BodySize)
        SubmittedOnBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        StatusBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        SubmittedOnBtn.titleLabel?.numberOfLines = 0
        SubmittedOnBtn.titleLabel?.lineBreakMode = .byWordWrapping
        separatorView.isHidden = true
        FNStack.isHidden = true
        ANStack.isHidden = true
        FNBtn.layer.cornerRadius = 10
        ANBtn.layer.cornerRadius = 10
    }

    @IBAction func stausBtnAct(_ sender: UIButton) {
        delegate?.callMobileNumber(indexPath: sender.tag)
    }
}
