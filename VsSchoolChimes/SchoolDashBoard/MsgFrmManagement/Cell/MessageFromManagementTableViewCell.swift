//
//  MessageFromManagementTableViewCell.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/17/24.
//

import UIKit

class MessageFromManagementTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var voiceLbl: UILabel!
    @IBOutlet weak var textLBl: UILabel!
    @IBOutlet weak var videoLbl: UILabel!
    @IBOutlet weak var imgLbl: UILabel!
    @IBOutlet weak var pdfLbl: UILabel!
    @IBOutlet weak var videoView: UIViewX!
    @IBOutlet weak var imgView: UIViewX!
    @IBOutlet weak var textView: UIViewX!
    @IBOutlet weak var voiceView: UIViewX!    
    @IBOutlet weak var pdfView: UIViewX!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        voiceLbl.text = "Voice".translated()
        textLBl.text = "Text".translated()
        imgLbl.text = "Image".translated()
        pdfLbl.text = "PDF".translated()
        videoLbl.text = "Video".translated()
        
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
