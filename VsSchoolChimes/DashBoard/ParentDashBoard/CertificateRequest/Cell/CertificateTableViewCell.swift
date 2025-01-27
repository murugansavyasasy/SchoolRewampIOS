//
//  CertificateTableViewCell.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/20/24.
//

import UIKit

class CertificateTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusImgview: UIImageView!
    @IBOutlet weak var StatusLbl: UILabel!
    
    @IBOutlet weak var CertifiacteTypeDefLbl: UILabel!
    @IBOutlet weak var certificateNameLbl: UILabel!
    
    @IBOutlet weak var ReasonDefLbl: UILabel!
    
    @IBOutlet weak var createdonDefLbl: UILabel!
    @IBOutlet weak var linkUrlLbl: UILabel!
    @IBOutlet weak var reasonLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var DownloadBtn: UIButton!
    
    @IBOutlet weak var DownloadBtnHeight: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.cornerRadius = 10
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cellView.layer.shadowRadius = 5
        cellView.layer.shadowOpacity = 0.3
        DownloadBtnHeight.constant = 0
        DownloadBtn.isHidden = true
        StatusLbl.setFont(style: .body, size: FontSize.BodySize)
        CertifiacteTypeDefLbl.setFont(style: .body, size: FontSize.BodySize)
        certificateNameLbl.setFont(style: .body, size: FontSize.BodySize)
        reasonLbl.setFont(style: .body, size: FontSize.BodySize)
        ReasonDefLbl.setFont(style: .body, size: FontSize.BodySize)
        createdonDefLbl.setFont(style: .body, size: FontSize.BodySize)
        dateLbl.setFont(style: .body, size: FontSize.BodySize)
        DownloadBtn.layer.cornerRadius = 10
        DownloadBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        statusView.layer.cornerRadius = 8
        statusView.layer.shadowColor = UIColor.black.cgColor
        statusView.layer.shadowOffset = CGSize(width: 0, height: 2)
        statusView.layer.shadowRadius = 5
        statusView.layer.shadowOpacity = 0.3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
