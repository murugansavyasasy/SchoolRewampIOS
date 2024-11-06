//
//  DemoTVCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 30/10/24.
//

import UIKit

class DemoTVCell: UITableViewCell {
    @IBOutlet weak var namelabel: UILabel!
    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var cellview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellview.layer.cornerRadius = 10
        //cellview.layer.masksToBounds = true
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 3
        cellview.layer.masksToBounds = false
        
        imgview.contentMode = .scaleAspectFill
        imgview.layer.cornerRadius =  imgview.frame.width/2
        imgview.layer.masksToBounds = true
        
        //namelabel.text?.append("Saranraj Shanmugammmmmmmmmm")

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
