//
//  SubmitRatingViewController.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 06/11/24.
//

import UIKit
import ImageIO
class SubmitRatingViewController: UIViewController {
    @IBOutlet weak var AppreciateLbl: UILabel!
    
    @IBOutlet weak var GobackBtn: UIButton!
    @IBOutlet weak var ThankyouLbl: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let gifImage = UIImage.gifImageWithName("Thumbs Up")
                //
        imgView.image = gifImage
        
        AppreciateLbl.setFont(style: .body, size: FontSize.BodySize)
        ThankyouLbl.setFont(style: .header, size: FontSize.TitleSize)
        GobackBtn.setTitleFont(style: .body, size: FontSize.BodySize)
    }

    @IBAction func BacktoHome(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
