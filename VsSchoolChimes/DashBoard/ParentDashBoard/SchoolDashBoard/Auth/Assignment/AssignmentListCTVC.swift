//
//  AssignmentListCTVC.swift
//  VsSchoolChimes
//
//  Created by admin on 21/11/24.
//

import UIKit

class AssignmentListCTVC: UITableViewCell {
    
    @IBOutlet weak var imgHeght: NSLayoutConstraint!
    @IBOutlet weak var spirelview: UIView!
    @IBOutlet weak var outImg: UIImageView!
    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var sendByLbl: UILabel!
    @IBOutlet weak var sumissionLbl: UILabel!
    @IBOutlet weak var dueDateLbl: UILabel!
    var stackView: UIStackView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var viewBtn: UIButton!
    @IBOutlet weak var CreaterdDate: UILabel!
    @IBOutlet weak var CreatedTime: UILabel!
    
    var didSelectDelegate : DidSelectDelegate?
    
       override func awakeFromNib() {
           super.awakeFromNib()
           
           spirelview.layer.cornerRadius = 10
           spirelview.layer.shadowColor = UIColor.black.cgColor
           spirelview.layer.shadowOffset = CGSize(width: 0, height: 2)
           spirelview.layer.shadowRadius = 10
           spirelview.layer.shadowOpacity = 0.3
           outImg.translatesAutoresizingMaskIntoConstraints = false
       }

       override func layoutSubviews() {
           super.layoutSubviews()
           let contentViewHeight = contentView.frame.height - 30
           imgHeght.constant = contentViewHeight
       }
    
    @IBAction func viewAssignment(_ sender: UIButton) {
        didSelectDelegate?.select(index: 1, value:"\(sender.tag)",Img:[""],Pdf:"https://icseindia.org/document/sample.pdf",text:"sjedgwvfefjd xuvu dvs dhv sshgdvsg",type:"")
    }
    @IBAction func submitBtn(_ sender: UIButton) {
    }
    
}
