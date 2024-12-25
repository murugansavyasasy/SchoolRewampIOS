//
//  ExamMarkTV.swift
//  VsSchoolChimes
//
//  Created by Admin on 24/12/24.
//

import UIKit

class ExamMarkTV: UITableViewCell {

    @IBOutlet weak var progessBar: UIProgressView!
    @IBOutlet weak var MarkLbl: UILabel!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        MarkLbl.setFont(style: .title, size: FontSize.TitleSize)
        SubjectLbl.setFont(style: .title, size: FontSize.TitleSize)
        //MarkLbl.setFont(style: .title, size: FontSize.TitleSize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
