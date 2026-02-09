//
//  CertificateTableViewCell.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/20/24.
//

import UIKit

class CertificateTableViewCell: UITableViewCell {

    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var issueCertificatStack: UIStackView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var issuedLbl: UILabel!
    @IBOutlet weak var issuedDateLbl: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusImgview: UIImageView!
    @IBOutlet weak var StatusLbl: UILabel!
    @IBOutlet weak var certificateNameLbl: UILabel!
    @IBOutlet weak var createdonDefLbl: UILabel!
    @IBOutlet weak var reasonLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var DownloadBtn: UIButton!
    @IBOutlet weak var DownloadBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var StatusImgHeight: NSLayoutConstraint!
    @IBOutlet weak var StatusImgWidth: NSLayoutConstraint!
    
    @IBOutlet weak var resonOuterView: UIView!
    @IBOutlet weak var resonInnerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        statusImgview.tintColor = .white
        outerView.layer.cornerRadius = 10
        iconBtn.layer.cornerRadius = 8
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        DownloadBtnHeight.constant = 0
        setCornerRadius(for: cellView, radius: 10)
        setCornerRadius(for: resonInnerView, radius: 10)
        setCornerRadius(for: resonOuterView, radius: 10)
        cellView.clipsToBounds = true
        DownloadBtn.isHidden = true
        StatusLbl.setFont(style: .body, size: FontSize.BodySize)
        certificateNameLbl.setFont(style: .title, size: FontSize.TitleSize)
        issuedLbl.setFont(style: .body, size: FontSize.BodySize)
        issuedDateLbl.setFont(style: .body, size: FontSize.BodySize)
        reasonLbl.setFont(style: .body, size: FontSize.BodySize)
        createdonDefLbl.setFont(style: .body, size: FontSize.TitleSize)
        dateLbl.setFont(style: .body, size: FontSize.BodySize)
        DownloadBtn.layer.cornerRadius = 10
        DownloadBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        statusView.layer.cornerRadius = 8
        statusView.layer.shadowColor = UIColor.black.cgColor
        statusView.layer.shadowOffset = CGSize(width: 0, height: 2)
        statusView.layer.shadowRadius = 5
        statusView.layer.shadowOpacity = 0.3
    }
    func confic(secondString:String?){
        let firstString = "Reason: "

        // Create attributes
        let firstAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]

        let secondAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.gray
        ]
        let attributedText = NSMutableAttributedString(string: firstString, attributes: firstAttributes)
        attributedText.append(NSAttributedString(string: secondString ?? "", attributes: secondAttributes))
        reasonLbl.attributedText = attributedText
    }
    func setCornerRadius(for view: UIView, radius: CGFloat) {
        view.layer.cornerRadius = radius
//        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        view.clipsToBounds = true
    }

}
