//
//  CertificateCv.swift
//  School Chimes
//
//  Created by Lakshmanan on 29/07/25.
//

import UIKit

class CertificateCv: UICollectionViewCell {

    @IBOutlet weak var CertificateView: UIView!
    @IBOutlet weak var Folderview: FolderView!
    
    @IBOutlet weak var CertificateName: UILabel!
    @IBOutlet weak var reasonLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        CertificateView.layer.cornerRadius = 5
        CertificateView.layer.borderWidth = 5
        CertificateView.layer.borderColor = UIColor.systemGray4.cgColor
        
        CertificateName.setFont(style: .title, size: 10)
        reasonLbl.setFont(style: .body, size: 10)
        DateLbl.setFont(style: .body, size: 10)
    }
}
