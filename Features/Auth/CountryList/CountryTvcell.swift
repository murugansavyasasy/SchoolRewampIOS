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
        cellView.layer.cornerRadius = 25
        cellView.layer.borderWidth = 1
        FlagImage.layer.cornerRadius = FlagImage.frame.width / 2
        nameLbl.setFont(style: .body, size: FontSize.TitleSize)
    }

}
