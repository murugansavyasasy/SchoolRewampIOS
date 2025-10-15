//
//  GenderDistriTvcel.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 14/10/25.
//

import UIKit

class GenderDistriTvcel: UITableViewCell {

    @IBOutlet weak var boysProgress: UIProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
       
        boysProgress.layer.cornerRadius = 8
        boysProgress.clipsToBounds = true
        
        boysProgress.layer.sublayers?.forEach { layer in
            layer.cornerRadius = 8
            layer.masksToBounds = true
        }
    }
    
    
   


    
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
