//
//  SuccesseRatusTVC.swift
//  School Chimes
//
//  Created by Chandhru on 10/11/25.
//

import UIKit

class SuccesseRatusTVC: UITableViewCell {
    @IBOutlet weak var ThankyouLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var AppreciateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let gifImage = UIImage.gifImageWithName("Thumbs Up")
        imgView.image = gifImage
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
            self.imgView.image = nil
        }
    }

}
