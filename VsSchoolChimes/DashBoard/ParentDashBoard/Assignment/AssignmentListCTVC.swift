//
//  AssignmentListCTVC.swift
//  VsSchoolChimes
//
//  Created by admin on 21/11/24.
//

import UIKit

class AssignmentListCTVC: UITableViewCell {
    
    
    @IBOutlet weak var SendBySecLbl: UILabel!
    @IBOutlet weak var SubCountSec: UILabel!
    @IBOutlet weak var DueSecLbl: UILabel!
    @IBOutlet weak var CategorySecLbl: UILabel!
    @IBOutlet weak var subjectSecLbl: UILabel!
    
    @IBOutlet weak var imageLabel: UILabel!
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
           spirelview.layer.shadowOffset = CGSize(width: 4, height: 4)
           spirelview.layer.shadowRadius = 3
           spirelview.layer.shadowOpacity = 0.5
           spirelview.layer.masksToBounds = false
           outImg.translatesAutoresizingMaskIntoConstraints = false
           
           //MARK: Label Font
           SendBySecLbl.setFont(style: .body, size: FontSize.BodySize)
           SubCountSec.setFont(style: .body, size: FontSize.BodySize)
           DueSecLbl.setFont(style: .body, size: FontSize.BodySize)
           CategorySecLbl.setFont(style: .body, size: FontSize.BodySize)
           subjectSecLbl.setFont(style: .body, size: FontSize.BodySize)

           imageLabel.setFont(style: .body, size: FontSize.BodySize)
           tittleLbl.setFont(style: .title, size: FontSize.TitleSize)
           categoryLbl.setFont(style: .body, size: FontSize.BodySize)
           subjectLbl.setFont(style: .body, size: FontSize.BodySize)
           sendByLbl.setFont(style: .body, size: FontSize.BodySize)
           sumissionLbl.setFont(style: .body, size: FontSize.BodySize)
           dueDateLbl.setFont(style: .body, size: FontSize.BodySize)
           CreaterdDate.setFont(style: .body, size: FontSize.BodySize)
           CreatedTime.setFont(style: .body, size: FontSize.BodySize)

           //MARK: Button Font
           submitBtn.setTitleFont(style: .body, size: FontSize.BodySize)
           viewBtn.setTitleFont(style: .body, size: FontSize.BodySize)

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
