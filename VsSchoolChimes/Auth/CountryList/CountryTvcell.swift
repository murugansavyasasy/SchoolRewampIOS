//
//  CountryTvcell.swift
//  School Chimes
//
//  Created by Lakshmanan on 06/08/25.
//

import UIKit

class CountryTvcell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var FlagImage: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cellView.layer.cornerRadius = 20
        cellView.layer.borderWidth = 1
        cellView.layer.borderColor = UIColor.clear.cgColor
        
        FlagImage.layer.cornerRadius = FlagImage.frame.width / 2
        
        nameLbl.setFont(style: .body, size: FontSize.TitleSize)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
