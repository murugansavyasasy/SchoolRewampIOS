//
//  PirorityTableViewCell.swift
//  SchoolChimesVS
//
//  Created by admin on 13/06/24.
//

import UIKit
//import Lottie

class PirorityTableViewCell: UITableViewCell {

    
    
    
    @IBOutlet weak var rollNumberLbl: UILabel!
    @IBOutlet weak var priorityImgView: UIImageView!
    
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    
    @IBOutlet weak var schoolNameLbl: UILabel!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        
//        arrowview = .init(name: "right-arrow")
//     
////        arrowview!.frame = View.bounds
//     
//     // 3. Set animation content mode
//     
//        arrowview.contentMode = .scaleAspectFit
//     
//     // 4. Set animation loop mode
//     
//        arrowview.loopMode = .loop
//     
//     // 5. Adjust animation speed
//     
//        arrowview.animationSpeed = 0.9
//     
//// addSubview(arrowview!)
//     
//     // 6. Play animation
//     
//        arrowview.play()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
//        priorityImgView.contentMode = .scaleAspectFill
//        priorityImgView.clipsToBounds = true
        // Configure the view for the selected state
    }
    
}
