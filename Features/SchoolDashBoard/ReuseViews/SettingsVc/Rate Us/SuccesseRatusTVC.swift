//
//  SuccesseRatusTVC.swift
//  School Chimes
//
//  Created by Chandhru on 10/11/25.
//

import UIKit
import Lottie

class SuccesseRatusTVC: UITableViewCell {
    @IBOutlet weak var ThankyouLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var AppreciateLbl: UILabel!
    var animationView: LottieAnimationView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        let gifImage = UIImage.gifImageWithName("Thumbs Up")
//        imgView.image = gifImage
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
//            self.imgView.image = nil
//        }
        
        ThankyouLbl.text = "Thank You".translated()
        AppreciateLbl.text = "We appreciate your feedback! Your rating helps us improve.".translated()
        
        DispatchQueue.main.async { [self] in
            animationView = LottieAnimationView(name: "done") // json name
            animationView.frame = imgView.bounds
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.animationSpeed = 1.0
            
            imgView.addSubview(animationView)
            animationView.play()
        }
    }

}
