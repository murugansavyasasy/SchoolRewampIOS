//
//  ClaimCouponVc.swift
//  VoicesnapSchoolApp
//
//  Created by Lakshmanan on 04/04/25.
//  Copyright © 2025 SchoolChimes. All rights reserved.
//

import UIKit
import SDWebImage

class ClaimCouponVc: UIViewController {
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var OverallStack: UIStackView!
    @IBOutlet weak var TicketView: CustomTicketView!
    @IBOutlet weak var BrandLogo: UIImageView!
    @IBOutlet weak var BrandName: UILabel!
    @IBOutlet weak var offerLbl: UILabel!
    @IBOutlet weak var InstructionLbl: UILabel!
    @IBOutlet weak var QRImgview: UIImageView!
    @IBOutlet weak var CouponCodeFld: UITextField!
    @IBOutlet weak var CopyBtn: UIButton!
    @IBOutlet weak var ShareBtn: UIButton!
    @IBOutlet weak var BookingDetailsDefLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var VenueLbl: UILabel!
    @IBOutlet weak var DetailBrandname: UILabel!
    @IBOutlet weak var ValidUntilLbl: UILabel!
    @IBOutlet weak var CityLbl: UILabel!
    @IBOutlet weak var AppoinmentDetailsView: UIView!
    @IBOutlet weak var TremsAndCondView: UIView!
    @IBOutlet weak var TermsStack: UIStackView!
    @IBOutlet weak var TermsAndCondDefLbl: UILabel!
    @IBOutlet weak var DateDefLbl: UILabel!
    @IBOutlet weak var TimeDefLbl: UILabel!
    @IBOutlet weak var VenueDefLbl: UILabel!
    @IBOutlet weak var Qrheight: NSLayoutConstraint!
    var couponDetails : Coupon?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.layer.cornerRadius = BackBtn.frame.width/2
        TicketView.layer.cornerRadius = 20
        AppoinmentDetailsView.layer.cornerRadius = 15
        
        Qrheight.constant = 0
        
        BrandName.setFont(style: .title, size: 20)
        offerLbl.setFont(style: .header, size: 25)
        InstructionLbl.setFont(style: .body, size: 14)
        BookingDetailsDefLbl.setFont(style: .title, size: 18)
        DateDefLbl.setFont(style: .title, size: 15)
        TimeDefLbl.setFont(style: .title, size: 15)
        VenueDefLbl.setFont(style: .title, size: 15)
        DateLbl.setFont(style: .body, size: 14)
        TimeLbl.setFont(style: .body, size: 14)
        VenueLbl.setFont(style: .body, size: 14)
        
        DetailBrandname.setFont(style: .title, size: 17)
        ValidUntilLbl.setFont(style: .body, size: 14)
        CityLbl.setFont(style: .body, size: 14)
        
        TermsAndCondDefLbl.setFont(style: .title, size: 17)
        
        CouponCodeFld.font = UIFont(name: "Gilroy-Regular", size: 15)
        
        AppoinmentDetailsView.layer.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.3).cgColor
        
        
        BrandLogo.sd_setImage(with: URL(string: couponDetails?.merchantLogo ?? ""), placeholderImage: UIImage(named: "placeHolder.png"), options:SDWebImageOptions.refreshCached )
        BrandName.text = couponDetails?.merchantName
        offerLbl.text = couponDetails?.offerToShow
        InstructionLbl.text = convertHTMLToText(htmlString: couponDetails?.howToUse ?? "")
        QRImgview.sd_setImage(with: URL(string: couponDetails?.qrCode ?? ""), placeholderImage: UIImage(named: "placeHolder.png"), options:SDWebImageOptions.refreshCached )
        
        CouponCodeFld.text = couponDetails?.couponCode
        addDashedBorder(to: CouponCodeFld)
        CouponCodeFld.isEnabled = false
        

        let inputDateString = couponDetails?.expiryDate ?? ""
        // Create a date formatter to parse the input date string
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-MM-dd"

        // Convert the string to a Date object
        if let date = inputDateFormatter.date(from: inputDateString) {
         
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "dd MMMM yyyy" // "date month year" format
            
            let outputDateString = outputDateFormatter.string(from: date)
            ValidUntilLbl.text = "Valid Until " + outputDateString
        }

        DetailBrandname.text = couponDetails?.merchantName
        CityLbl.text = couponDetails?.locationList?.first?.locationName
        
        let TermsList = couponDetails?.termsAndConditions ?? ""
        let terms = extractListItems(from: TermsList)
        
        addDynamicLabels(from: couponDetails?.termsAndConditions ?? "")

    }

    func addDashedBorder(to textField: UITextField) {
        let border = CAShapeLayer()
        border.strokeColor = UIColor.gray.cgColor
        border.lineDashPattern = [4, 4] // 4 points dashed, 4 points space
        border.frame = textField.bounds
        border.fillColor = nil
        border.path = UIBezierPath(roundedRect: textField.bounds, cornerRadius: textField.layer.cornerRadius).cgPath
        textField.layer.addSublayer(border)
    }
    
    @IBAction func CopyAct(_ sender: Any) {
        
        guard let text = CouponCodeFld.text, !text.isEmpty else {
                    print("Text field is empty")
                    return
                }

                // Copy the text to the clipboard
                UIPasteboard.general.string = text
                print("Text copied to clipboard: \(text)")
    }
    
    @IBAction func ShareAct(_ sender: Any) {
    }
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    func htmlToAttributedString(_ htmlString: String) -> NSAttributedString? {
        guard let data = htmlString.data(using: .utf8) else { return nil }

        do {
            return try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
        } catch {
            print("Failed to convert HTML: \(error)")
            return nil
        }
    }
    
    func convertHTMLToText(htmlString: String) -> String {
        guard let data = htmlString.data(using: .utf8) else { return "" }

        if let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html,
                      .characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil) {
            return attributedString.string
        }
        return ""
    }
    
    func extractListItems(from html: String) -> [String] {
        var results: [String] = []

        let pattern = "<li>(.*?)</li>"

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let nsString = html as NSString
            let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))

            for match in matches {
                if match.numberOfRanges > 1 {
                    let item = nsString.substring(with: match.range(at: 1))
                    results.append(item.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        } catch {
            print("Regex error: \(error)")
        }

        return results
    }

    func addDynamicLabels(from html: String) {
        let terms = extractListItems(from: html)

        // Clear all except the default label
        for view in TermsStack.arrangedSubviews {
            if view != TermsAndCondDefLbl {
                TermsStack.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }

        // Add each term as a label
        for term in terms {
            let label = UILabel()
            label.text = "• \(term)"
            label.numberOfLines = 0
            label.textAlignment = .left
            label.setFont(style: .body, size: 14)
            label.textColor = .darkGray
            TermsStack.addArrangedSubview(label)
        }
    }

}
