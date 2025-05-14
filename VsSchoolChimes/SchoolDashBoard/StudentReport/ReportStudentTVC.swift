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
    
    @IBOutlet weak var shimmerView: AnimatView!
    @IBOutlet weak var genderTitle: UILabel!
    @IBOutlet weak var fatherTitle: UILabel!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var tagView: UIView!
    var smsNumber = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let originalImage = ImageName.idCard {
            // Resize the image to match outerView's size
            let resizedImage = originalImage.resized(to: outerView.bounds.size)
            
            // Create the background UIImageView
            let backgroundImageView = UIImageView(image: resizedImage)
            backgroundImageView.frame = outerView.bounds
            backgroundImageView.contentMode = .scaleAspectFill
            //            backgroundImageView.tintColor = .blue
            backgroundImageView.layer.cornerRadius = 10
            backgroundImageView.clipsToBounds = true
//            backgroundImageView.alpha = 0.6
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
        
        hiddenui(true)
        animationview()

    }
    func hiddenui(_ hide:Bool){
        shimmerView.changeHeightAndAnimate(0,0, 60, 60, top: 5)
        outerView.isHidden = hide
//        playbtl.isHidden = hide
        let color = hide == true ? UIColor.dashBoardClr : UIColor.white
        shimmerView.backgroundColor = color
    }
    func animationview(){
        shimmerView.animateView(enable:true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [self] in
            // Code to execute after delay
            self.shimmerView.animateView(enable:false)
            shimmerView.parentview.isHidden = true
            hiddenui(false)
        }
        
    }
    func confic(student:StudentData){

        //MARK: Label Font
        
        tcherLbl.setFont(style: .body, size: FontSize.BodySize)
        teacherName.setFont(style: .body, size: FontSize.BodySize)
        admissionTitle.setFont(style: .body, size: FontSize.BodySize)
        admissionLbl.setFont(style: .body, size: FontSize.BodySize)
        dobLbl.setFont(style: .body, size: FontSize.BodySize)
        dobTitleLbl.setFont(style: .body, size: FontSize.BodySize)
        nameTitle.setFont(style: .body, size: FontSize.BodySize)
        studentNmae.setFont(style: .body, size: FontSize.BodySize)
        genderLbl.setFont(style: .body, size: FontSize.BodySize)
        fatherName.setFont(style: .body, size: FontSize.BodySize)
        fatherTitle.setFont(style: .body, size: FontSize.BodySize)
        genderTitle.setFont(style: .body, size: FontSize.BodySize)
        emailBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        mobleNo.setTitleFont(style: .body, size: FontSize.BodySize)
        smsBtn.setTitleFont(style: .body, size: FontSize.BodySize)
    }
    @IBAction func callAction(_ sender: UIButton) {
        let phoneNumber = smsNumber // Replace with the phone number you want
        if let phoneURL = URL(string: "tel://\(phoneNumber)"),
           UIApplication.shared.canOpenURL(phoneURL) {
            UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
        } else {
            print("Phone app is not available on this device or invalid phone number.")
        }
    }
    @IBAction func emailAction(_ sender: UIButton) {
        let email = sender.titleLabel?.text // Replace with the recipient's email
        let subject = "Hello" // Replace with your subject
        let body = "This is a sample email body." // Replace with your email body
        
        let emailURL = "mailto:\(email ?? "")?subject=\(subject)&body=\(body)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let url = URL(string: emailURL ?? ""),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            
            print("Mail app is not available or invalid email address.")
        }
    }
    @IBAction func smsAction(_ sender: UIButton) {
        let phoneNumber = smsNumber // Replace with the recipient's phone number
        let message = "Hello, this is a sample message." // Replace with your SMS message
        
        let smsURL = "sms:\(phoneNumber)&body=\(message)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        if let url = URL(string: smsURL ?? ""),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Messages app is not available or invalid phone number.")
        }
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
