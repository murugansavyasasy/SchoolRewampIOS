//
//  ReportStudentTVC.swift
//  VsSchoolChimes
//
//  Created by admin on 09/12/24.
//

import UIKit

class ReportStudentTVC: UITableViewCell {

    @IBOutlet weak var idCardImg: UIImageView!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var smsBtn: UIButton!
    @IBOutlet weak var mobleNo: UIButton!
    @IBOutlet weak var tcherLbl: UILabel!
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var admissionLbl: UILabel!
    @IBOutlet weak var admissionTitle: UILabel!
    @IBOutlet weak var dobLbl: UILabel!
    @IBOutlet weak var dobTitleLbl: UILabel!
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var studentNmae: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var fatherName: UILabel!
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var tagView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()

        if let originalImage = UIImage(named: "idCard") {
                // Resize the image to match outerView's size
                let resizedImage = originalImage.resized(to: outerView.bounds.size)
                
                // Create the background UIImageView
                let backgroundImageView = UIImageView(image: resizedImage)
                backgroundImageView.frame = outerView.bounds
                backgroundImageView.contentMode = .scaleAspectFill
//            backgroundImageView.tintColor = .blue
                backgroundImageView.layer.cornerRadius = 10
                backgroundImageView.clipsToBounds = true

                // Add the background UIImageView to outerView
                outerView.insertSubview(backgroundImageView, at: 0)

                // Ensure resizing adjusts dynamically with outerView
                backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }

            // Style outerView
            outerView.layer.cornerRadius = 10
            outerView.layer.shadowColor = UIColor.black.cgColor
            outerView.layer.shadowOffset = CGSize(width: 4, height: 4)
            outerView.layer.shadowOpacity = 0.5
            outerView.layer.shadowRadius = 4
          tagView.layer.cornerRadius = 10
            // Style imgView
        profileView.layer.cornerRadius = 10
        imgView.layer.cornerRadius = 10
        profileView.layer.shadowColor = UIColor.black.cgColor
        profileView.layer.shadowOffset = CGSize(width: 4, height: 4)
        profileView.layer.shadowOpacity = 0.5
        profileView.layer.shadowRadius = 4
        
    }

}
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
