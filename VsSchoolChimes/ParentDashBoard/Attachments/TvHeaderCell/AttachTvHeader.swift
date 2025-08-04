//
//  AttachTvHeader.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 31/07/25.
//

import UIKit

class AttachTvHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var fullView: UIView!
    
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var discretpionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    override func awakeFromNib() {
            super.awakeFromNib()
           
        roundView.isHidden = true
        roundView.layer.cornerRadius = roundView.frame.width/2
        }
    
    
    
    func configure(with item: AttachmentHeaderInfo) {
        
//        discretpionLbl.text = item.description
        titleLbl.text =  item.title
        let displayText = formattedDateStatus(from: item.date ?? "")
        dateLbl.text = "🗓️" + displayText

        
       }
}
