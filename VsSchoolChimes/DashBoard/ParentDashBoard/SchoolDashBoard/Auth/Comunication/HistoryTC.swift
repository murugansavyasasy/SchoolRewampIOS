//
//  HistoryTC.swift
//  
//
//  Created by admin on 13/11/24.
//

import UIKit

class HistoryTC: UITableViewCell {

    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var contentlbl: UILabel!
    @IBOutlet weak var sendedtime: UILabel!
    @IBOutlet weak var totaltime: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var outerview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        outerview.layer.shadowColor = UIColor.black.cgColor
        outerview.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerview.layer.shadowRadius = 5
        outerview.layer.shadowOpacity = 0.3
        outerview.layer.cornerRadius = 20
        sendbtn.layer.cornerRadius = 4
        let thumbImage = UIImage(named: "yourThumbImage")!
            
            // Resize the thumb image to make it smaller
            let resizedThumbImage = resizeImage(image: thumbImage, targetSize: CGSize(width: 20, height: 20))
            
            // Set the resized thumb image for the slider
        slider.setThumbImage(resizedThumbImage, for: .normal)
        slider.setThumbImage(resizedThumbImage, for: .highlighted)
        // Initialization code
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resizedImage
    }
    @IBAction func play(_ sender: UIButton) {
      
    }
    
}
