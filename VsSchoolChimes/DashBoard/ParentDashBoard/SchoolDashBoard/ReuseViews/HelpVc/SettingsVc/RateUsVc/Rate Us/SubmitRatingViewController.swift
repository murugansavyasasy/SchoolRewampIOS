//
//  SubmitRatingViewController.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 06/11/24.
//

import UIKit
import ImageIO
class SubmitRatingViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let gifImage = UIImage.gifImageWithName("Thumbs Up")
                //
        imgView.image = gifImage
    }

    @IBAction func BacktoHome(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
