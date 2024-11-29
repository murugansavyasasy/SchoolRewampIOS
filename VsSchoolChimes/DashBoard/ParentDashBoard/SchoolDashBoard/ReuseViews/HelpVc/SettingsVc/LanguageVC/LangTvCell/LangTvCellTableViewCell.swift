//
//  LangTvCellTableViewCell.swift
//  VsSchoolChimes
//
//  Created by admin on 08/11/24.
//

import UIKit

class LangTvCellTableViewCell: UITableViewCell {

    @IBOutlet weak var LangIconImg: UIImageView!
    @IBOutlet weak var RadioImage: UIImageView!
    @IBOutlet weak var OriginalLangLbl: UILabel!
    @IBOutlet weak var LangLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        OriginalLangLbl.setFont(style: .title, size: FontSize.TitleSize)
        LangLbl.setFont(style: .body, size: FontSize.BodySize)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
