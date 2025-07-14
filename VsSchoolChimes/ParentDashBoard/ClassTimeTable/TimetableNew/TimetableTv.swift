//
//  TimetableTv.swift
//  TimetableDesignPractice
//
//  Created by Admin on 10/01/25.
//

import UIKit

class TimetableTv: UITableViewCell {

    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var DetailsView: UIView!
    @IBOutlet weak var CheckImgview: UIImageView!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var StaffNameLbl: UILabel!
    @IBOutlet weak var DurationLbl: UILabel!
    @IBOutlet weak var hrsType: UILabel!
    var animated = false
    @IBOutlet weak var progressBar: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()

        progressBar.progressTintColor = .systemGreen
        progressBar.trackTintColor = .lightGray

        progressBar.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        progressBar.layer.cornerRadius = 2
        progressBar.clipsToBounds = true
        progressBar.subviews.forEach { $0.layer.cornerRadius = 2 }

        DetailsView.layer.cornerRadius = 10
        hrsType.layer.cornerRadius = 8
        hrsType.clipsToBounds = true
        DetailsView.layer.borderWidth = 0.5
        DetailsView.layer.borderColor = UIColor.gray.cgColor
        progressBar.setProgress(0.0, animated: false)
        TimeLbl.setFont(style: .title, size: FontSize.TitleSize)
        SubjectLbl.setFont(style: .title, size: FontSize.TitleSize)
        StaffNameLbl.setFont(style: .body, size: FontSize.BodySize)
        DurationLbl.setFont(style: .body, size: FontSize.BodySize)
    }
}
