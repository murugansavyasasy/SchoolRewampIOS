//
//  QuizListTvCell.swift
//  VsSchoolChimes
//
//  Created by Admin on 07/02/25.
//

import UIKit
protocol addQuestionAndSubmitedListDelegate {
    
    func addQuestionAndSubmitedList(index : Int)
    func submitedList(index : Int)
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
    @IBOutlet weak var LevelView: UIView!
    @IBOutlet weak var levelLbl: UILabel!
    
    
    
    var delegate : addQuestionAndSubmitedListDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        CellView.layer.cornerRadius = 10
        DeafultimageView.layer.cornerRadius = 10
        addQuestionBtnName.layer.cornerRadius = 10
        submittedListBtnName.layer.cornerRadius = 10
        LevelView.layer.cornerRadius = 15
        LevelView.layer.maskedCorners = [.layerMinXMaxYCorner]
        LevelView.clipsToBounds = true
        LevelView.layer.masksToBounds = true
        CellView.clipsToBounds = true
        
    }

    @IBAction func addQestBtn(_ sender: UIButton) {
        
        delegate?.addQuestionAndSubmitedList(index: sender.tag)
    }
    
    @IBAction func submitedList(_ sender: UIButton) {
        
        delegate?.submitedList(index: sender.tag)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
