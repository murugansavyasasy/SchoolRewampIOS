//
//  MsgFromMgmtTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 12/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class MsgFromMgmtTVCell: UITableViewCell {

    @IBOutlet weak var UnreadTextCountLabel: UILabel!
     @IBOutlet weak var UnreadPdfCountLabel: UILabel!
     @IBOutlet weak var UnreadImageCountLabel: UILabel!
     @IBOutlet weak var UnreadVoiceCountLabel: UILabel!
    
    @IBOutlet weak var UnreadVideoCountLabel: UILabel!
    @IBOutlet weak var VoiceView: UIView!
    @IBOutlet weak var PdfView: UIView!
    @IBOutlet weak var ImageView: UIView!
    @IBOutlet weak var TextView: UIView!
    
    @IBOutlet weak var VideoView: UIView!
    @IBOutlet weak var VoiceButton: UIButton!
    @IBOutlet weak var TextButton: UIButton!
    @IBOutlet weak var ImageButton: UIButton!
    @IBOutlet weak var PdfButton: UIButton!
    
    @IBOutlet weak var VideoButton: UIButton!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var DayLbl: UILabel!
    
    @IBOutlet weak var VoiceCountLbl: UILabel!
    @IBOutlet weak var TextCountLbl: UILabel!
    @IBOutlet weak var ImageCountLbl: UILabel!
    @IBOutlet weak var PdfCountLbl: UILabel!
    
    @IBOutlet weak var VideoCountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UnreadTextCountLabel.layer.cornerRadius = 0.5 * UnreadTextCountLabel.bounds.size.width
        UnreadTextCountLabel.clipsToBounds = true
        
        UnreadVideoCountLabel.layer.cornerRadius = 0.5 * UnreadVideoCountLabel.bounds.size.width
        UnreadVideoCountLabel.clipsToBounds = true
        
        UnreadPdfCountLabel.layer.cornerRadius = 0.5 * UnreadPdfCountLabel.bounds.size.width
        UnreadPdfCountLabel.clipsToBounds = true
        
        UnreadImageCountLabel.layer.cornerRadius = 0.5 * UnreadImageCountLabel.bounds.size.width
        UnreadImageCountLabel.clipsToBounds = true
        
        UnreadVoiceCountLabel.layer.cornerRadius = 0.5 * UnreadVoiceCountLabel.bounds.size.width
        UnreadVoiceCountLabel.clipsToBounds = true
        
        
        
        VoiceView.layer.cornerRadius = 5
        VoiceView.clipsToBounds = true
        VoiceView.layer.borderWidth = 1
        VoiceView.layer.borderColor = UIColor.black.cgColor
        
        TextView.layer.cornerRadius = 5
        TextView.clipsToBounds = true
        TextView.layer.borderWidth = 1
        TextView.layer.borderColor = UIColor.black.cgColor
        
        PdfView.layer.cornerRadius = 5
        PdfView.clipsToBounds = true
        PdfView.layer.borderWidth = 1
        PdfView.layer.borderColor = UIColor.black.cgColor
        
        ImageView.layer.cornerRadius = 5
        ImageView.clipsToBounds = true
        ImageView.layer.borderWidth = 1
        ImageView.layer.borderColor = UIColor.black.cgColor
        
        
        VideoView.layer.cornerRadius = 5
        VideoView.clipsToBounds = true
        VideoView.layer.borderWidth = 1
        VideoView.layer.borderColor = UIColor.black.cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
