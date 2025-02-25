//
//  LessonProgressCell.swift
//  VsSchoolChimes
//
//  Created by MacBook on 19/02/25.
//

import UIKit

class LessonProgressCell: UITableViewCell {

    @IBOutlet weak var CellView: UIView!
    @IBOutlet weak var UnitLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
   // @IBOutlet weak var ProgressHeight: NSLayoutConstraint!
    @IBOutlet weak var checkImageView: UIImageView!
    
    @IBOutlet weak var TopProgressView: UIView!
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var Baseview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        self.clipsToBounds = false
        self.contentView.clipsToBounds = false
        progressView.layer.masksToBounds = false
        contentView.layer.masksToBounds = false
        Baseview.layer.cornerRadius = 10
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        DateLbl.setFont(style: .body, size: FontSize.BodySize)
        UnitLbl.setFont(style: .body, size: FontSize.BodySize)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.progressView.isHidden = false
        self.TopProgressView.isHidden = false
        self.progressView.backgroundColor = .systemGreen
        self.TopProgressView.backgroundColor = .systemGreen
      //  self.ProgressHeight.constant = 85 // Reset to default height
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
