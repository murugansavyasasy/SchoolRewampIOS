//
//  CompletedTVcell.swift
//  VsSchoolChimes
//
//  Created by Admin on 20/01/25.
//

import UIKit

class CompletedTVcell: UITableViewCell {

    @IBOutlet weak var Button4: UIButton!
    @IBOutlet weak var Button3: UIButton!
    @IBOutlet weak var Button2: UIButton!
    @IBOutlet weak var Button1: UIButton!
    @IBOutlet weak var ButtonStackView: UIStackView!
    @IBOutlet weak var QuestionLbl: UILabel!
    @IBOutlet weak var QuestionView: UIView!
    @IBOutlet weak var cellView: UIView!
    
    var buttons : [UIButton] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        buttons = [Button1,Button2,Button3,Button4]
        cellView.layer.cornerRadius = 10
        cellView.layer.borderWidth = 0.5
        cellView.layer.borderColor = UIColor.lightGray.cgColor
        QuestionView.layer.cornerRadius = 10
        Button1.layer.cornerRadius = 15
        Button2.layer.cornerRadius = 15
        Button3.layer.cornerRadius = 15
        Button4.layer.cornerRadius = 15
        
        QuestionLbl.setFont(style: .title, size: FontSize.TitleSize)
        for button in buttons{
            button.setTitleFont(style: .body, size: FontSize.BodySize)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
