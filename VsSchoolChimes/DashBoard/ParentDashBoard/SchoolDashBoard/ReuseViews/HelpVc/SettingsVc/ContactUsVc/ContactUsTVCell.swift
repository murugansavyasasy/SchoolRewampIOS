//
//  ContactUsTVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class ContactUsTVCell: UITableViewCell {

    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var mailOrPhoneLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var cellview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        cellview.layer.shadowColor = UIColor.white.cgColor
//        cellview.layer.shadowOpacity =  10
//        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
//        cellview.layer.shadowRadius = 3
//        cellview.layer.masksToBounds = true
//        cellview.layer.cornerRadius = 5
        
        cellview.layer.cornerRadius = 10
        //cellview.layer.masksToBounds = true
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 3
        cellview.layer.masksToBounds = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openGmail))
        mailOrPhoneLabel.addGestureRecognizer(tap)
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func openGmail() {
           // Retrieve the email address from the label's text
           if let email = mailOrPhoneLabel.text, !email.isEmpty {
               
               // You can encode the subject and body if needed, to handle special characters or spaces
               let subject = "Subject of the email"
               let body = "Body of the email content."
               
               // Encode the subject and body to ensure special characters don't break the URL
               let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
               let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
               
               // Create the Gmail URL scheme
               if let gmailURL = URL(string: "googlegmail://co?to=\(email)&subject=\(encodedSubject)&body=\(encodedBody)") {
                   if UIApplication.shared.canOpenURL(gmailURL) {
                       // If Gmail app is installed, open it
                       UIApplication.shared.open(gmailURL, options: [:], completionHandler: nil)
                   } else {
                       // If Gmail app is not installed, open Gmail in Safari
                       if let webURL = URL(string: "https://mail.google.com/mail/?view=cm&fs=1&to=\(email)&su=\(encodedSubject)&body=\(encodedBody)") {
                           UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
                       }
                       print("Can't open Gmail app; opening Gmail in Safari instead.")
                   }
               }
           } else {
               print("Email address is empty or invalid.")
           }
       }
    
    @IBAction func ConnectEmail(){
        
        if let email = mailOrPhoneLabel.text, !email.isEmpty {
//            // Check if Gmail app is installed
//            if let gmailURL = URL(string: "googlegmail://co?to=\(email)") {
//                // Encode the email to be URL-safe
//                if let encodedEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//                   let encodedURL = URL(string: "googlegmail://co?to=\(encodedEmail)") {
//                    if UIApplication.shared.canOpenURL(encodedURL) {
//                        UIApplication.shared.open(encodedURL)
//                        return
//                    }
//                }
//            }
            
           
//
//            if let gmailURL = URL(string: "googlegmail://") {
//                        // If the Gmail app is installed, open it
//                        if UIApplication.shared.canOpenURL(gmailURL) {
//                            UIApplication.shared.open(gmailURL)
//                        } else {
//                            // If Gmail app is not installed, open in Safari
//                            if let webURL = URL(string: "https://mail.google.com/") {
//                              UIApplication.shared.open(webURL)
//                            }
//                            print("can't open Gmail")
//                        }
//                    }
            
//            if let email = mailOrPhoneLabel.text, !email.isEmpty {
//                // Create the "mailto" URL to launch the email client
//                if let url = URL(string: "mailto:\(email)") {
//                    // Check if the device can open the email client
//                    if UIApplication.shared.canOpenURL(url) {
//                        UIApplication.shared.open(url)
//                    } else {
//                        // If the email client can't be opened, show an error message
//                        print("Unable to open email client.")
//                    }
//                }
//            }
        }
    }
    
}
