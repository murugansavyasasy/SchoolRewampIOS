//
//  QuizListTvCell.swift
//  VsSchoolChimes
//
//  Created by Admin on 07/02/25.
//

import UIKit
protocol addQuestionAndSubmitedListDelegate {
    
    func addQuestionAndSubmitedList(index : Int)
}
class QuizListTvCell: UITableViewCell {
    
    @IBOutlet weak var addQuestionBtnName: UIButton!
    @IBOutlet weak var submittedListBtnName: UIButton!
    @IBOutlet weak var postedByLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var discretiponsLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var EndTimeLbl: UILabel!
    @IBOutlet weak var strtTimeLbl: UILabel!
    @IBOutlet weak var exameDateLbl: UILabel!
    @IBOutlet weak var DeafultimageView: UIImageView!
    @IBOutlet weak var CellView: UIView!
    @IBOutlet weak var PlayBtn: UIButton!
    var delegate : addQuestionAndSubmitedListDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        CellView.layer.cornerRadius = 10
        DeafultimageView.layer.cornerRadius = 10
//        CellView.layer.shadowColor = UIColor.black.cgColor
//        CellView.layer.shadowOpacity = 0.5
//        CellView.layer.shadowOffset = CGSize(width: 4, height: 4)
//        CellView.layer.shadowRadius = 3
//        CellView.layer.masksToBounds = false
//        CellView.layer.borderWidth = 1
//        CellView.layer.borderColor = UIColor.gray.cgColor
//        
//        LevelView.layer.cornerRadius = 10
//        LevelView.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner]
//       
//        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
//        DescriptionLbl.setFont(style: .body, size: FontSize.BodySize)
//        SubjectLbl.setFont(style: .body, size: FontSize.BodySize)
//        LevelLbl.setFont(style: .title, size: FontSize.TitleSize)
//        PlayBtn.setTitleFont(style: .body, size: FontSize.TitleSize)
//        PlayBtn.applyRightButton()
    }

    @IBAction func addQestBtn(_ sender: UIButton) {
        
        delegate?.addQuestionAndSubmitedList(index: sender.tag)
    }
    
    @IBAction func submitedList(_ sender: UIButton) {
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
