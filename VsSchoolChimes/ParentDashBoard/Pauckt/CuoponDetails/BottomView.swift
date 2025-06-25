////
////  BottomView.swift
////  rewardDesign
////
////  Created by admin on 18/02/25.
////
//
//import UIKit
//import SDWebImage
//protocol AddCoupen{
//    func addpucket()
//}
//class BottomView: UIViewController, AddCoupen{
//    func addpucket() {
//        coupenAdded = true
//       // tv.reloadData()
//    }
//    private var confettiLayer: CAEmitterLayer?
//    private var isAnimating = true
//    private let confetti1: ConfettiView = .top
//
//    @IBOutlet weak var ActiveBrrandLogoImg: UIImageView!
//    @IBOutlet weak var ActiveBrandName: UILabel!
//    @IBOutlet weak var ActiveCategoryLbl: UILabel!
//    @IBOutlet weak var ActiveOfferDetailsLbl: UILabel!
//    @IBOutlet weak var QrcodeImage: UIImageView!
//    @IBOutlet weak var ActiveEpiryDateLbl: UILabel!
//    @IBOutlet weak var ActivatedUsageDetails: UILabel!
//    @IBOutlet weak var CouponCopyBtn: UIButton!
//    @IBOutlet weak var CouponCodeFld: UITextField!
//    @IBOutlet weak var CategoryLbl: UILabel!
//    @IBOutlet weak var temsAndCondtionImage: UIImageView!
//    @IBOutlet weak var howtoUseDropImage: UIImageView!
//    @IBOutlet weak var GoToMyPauket: UIButton!
//    @IBOutlet weak var branchYoucanClaimLbl: UILabel!
//    @IBOutlet weak var activateImageView: UIImageView!
//    @IBOutlet weak var activateValidateLbl: UILabel!
//    @IBOutlet weak var howTouseLbl: UILabel!
//    @IBOutlet weak var temsAndCondionsLbl: UILabel!
//    @IBOutlet weak var activateCouponLocationLbl: UILabel!
//    @IBOutlet weak var activateCuponTitleLbl: UILabel!
//    @IBOutlet weak var activateDiscound: UILabel!
//    @IBOutlet weak var temsAndCondionStack: UIStackView!
//    @IBOutlet weak var howTouseStack: UIStackView!
//    @IBOutlet weak var youCanClaimStack: UIStackView!
//    @IBOutlet weak var reedimFullView: UIView!
//    @IBOutlet weak var qrCodeView: UIView!
//    @IBOutlet weak var activatePageView: UIView!
//    @IBOutlet weak var BranchesClaimHorizontal: UIStackView!
//    @IBOutlet weak var BranchesDropdownImg: UIImageView!
//    @IBOutlet weak var BranchesYouCanClaimDefLbl: UILabel!
//    @IBOutlet weak var HowtoUseHorizontal: UIStackView!
//    @IBOutlet weak var TermsAndCondHorizontal: UIStackView!
//    @IBOutlet weak var OrdernowBtn: UIButton!
//    @IBOutlet weak var ActivateBtn: UIButton!
//    @IBOutlet weak var HowtouseDefLbl: UILabel!
//    @IBOutlet weak var TermsAndCondDefLbl: UILabel!
//    @IBOutlet weak var QrcodeHeight: NSLayoutConstraint!
//    
//    var coupenAdded = false
//    var campian : [CampaignDetails] = []
//    var source_link : String?
//    var DataArray : [String] = []
//    var category : String?
//    var Coupon : [CouponDetails] = []
//    var sourceLink : String?
//    var CouponStatus : String?
//    var RedirectURL : String?
//    var childId : String?
//    var totalPoints : String?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//         
//        QrcodeHeight.constant = 0
//        reedimFullView.isHidden = true
//        qrCodeView.isHidden = true
//        GoToMyPauket.isHidden = true
//        youCanClaimStack.isHidden = true
//        temsAndCondionsLbl.isHidden = true
//        howTouseLbl.isHidden = true
//        branchYoucanClaimLbl.isHidden = true
//        OrdernowBtn.isHidden = true
//        activatePageView.layer.cornerRadius = 20
//        
//       
//        
//        if CouponStatus == "activated" {
//            
//            ActivateBtn.isHidden = true
//        }
//        
//        OrdernowBtn.layer.cornerRadius = 20
//        GoToMyPauket.layer.cornerRadius = 20
//        GoToMyPauket.layer.borderWidth = 1
//        GoToMyPauket.layer.borderColor = UIColor.black.cgColor
//        
//        ActiveBrandName.setFont(style: .body, size: 15)
//        ActiveCategoryLbl.setFont(style: .body, size: 13)
//        ActiveOfferDetailsLbl.setFont(style: .title, size: 17)
//        ActiveEpiryDateLbl.setFont(style: .body, size: 13)
//        CategoryLbl.setFont(style: .body, size: 15)
//        activateDiscound.setFont(style: .title, size: 15)
//        activateCuponTitleLbl.setFont(style: .body, size: 14)
//        activateCouponLocationLbl.setFont(style: .body, size: 13)
//        activateValidateLbl.setFont(style: .body, size: 13)
//        
//        ActivatedUsageDetails.setFont(style: .body, size: 14)
//        BranchesYouCanClaimDefLbl.setFont(style: .title, size: 15)
//        branchYoucanClaimLbl.setFont(style: .body, size: 15)
//        howTouseLbl.setFont(style: .body, size: 15)
//        branchYoucanClaimLbl.setFont(style: .body, size: 15)
//        HowtouseDefLbl.setFont(style: .title, size: 15)
//        TermsAndCondDefLbl.setFont(style: .title, size: 15)
//        temsAndCondionsLbl.setFont(style: .body, size: 15)
//        
//        OrdernowBtn.setTitleFont(style: .secondary, size: 14)
//        GoToMyPauket.setTitleFont(style: .secondary, size: 14)
//        ActivateBtn.setTitleFont(style: .secondary, size: 14)
//        
//        CouponCodeFld.isEnabled = false
//        
//        GetcampaigsDetails()
//        
//        CategoryLbl.text = category
//        
//        let temsAndCondionTapGesture = UITapGestureRecognizer(target: self, action: #selector(dropClick))
//        temsAndCondionStack.addGestureRecognizer(temsAndCondionTapGesture)
//        
//        let howtoUSe = UITapGestureRecognizer(target: self, action: #selector(HowTouse))
//        howTouseStack.addGestureRecognizer(howtoUSe)
//        
//        let BranchesCanTap = UITapGestureRecognizer(target: self, action: #selector(BranchesClaim))
//        youCanClaimStack.addGestureRecognizer(BranchesCanTap)
//        
//        addDashedBorder(to: CouponCodeFld)
//    }
//    
//    func addDashedBorder(to textField: UITextField) {
//        let border = CAShapeLayer()
//        border.strokeColor = UIColor.systemGreen.cgColor
//        border.lineDashPattern = [4, 4] // 4 points dashed, 4 points space
//        border.frame = textField.bounds
//        border.fillColor = nil
//        border.path = UIBezierPath(roundedRect: textField.bounds, cornerRadius: textField.layer.cornerRadius).cgPath
//        textField.layer.addSublayer(border)
//    }
//
//    
//    @IBAction func CopyBtnAct(_ sender: Any) {
//        
//        guard let text = CouponCodeFld.text, !text.isEmpty else {
//                    print("Text field is empty")
//                    return
//                }
//
//                // Copy the text to the clipboard
//                UIPasteboard.general.string = text
//                print("Text copied to clipboard: \(text)")
//    }
//    
//    @IBAction func dropClick() {
//        
//        temsAndCondionsLbl.isHidden.toggle()
//    }
//    
//    @IBAction func HowTouse() {
//        
//        howTouseLbl.isHidden.toggle()
//    }
//    
//    @IBAction func BranchesClaim() {
//        
//        branchYoucanClaimLbl.isHidden.toggle()
//    }
//    
//    func convertHTMLToText(htmlString: String) -> String {
//        guard let data = htmlString.data(using: .utf8) else { return "" }
//
//        if let attributedString = try? NSAttributedString(
//            data: data,
//            options: [.documentType: NSAttributedString.DocumentType.html,
//                      .characterEncoding: String.Encoding.utf8.rawValue],
//            documentAttributes: nil) {
//            return attributedString.string
//        }
//        return ""
//    }
//    
//    func convertHTMLToTextWithBullets(htmlString: String) -> String {
//        guard let data = htmlString.data(using: .utf8) else { return "" }
//
//        if let attributedString = try? NSAttributedString(
//            data: data,
//            options: [
//                .documentType: NSAttributedString.DocumentType.html,
//                .characterEncoding: String.Encoding.utf8.rawValue
//            ],
//            documentAttributes: nil) {
//            
//            let rawString = attributedString.string
//            
//            // Optional: Add bullet points to lines that likely represent list items
//            let lines = rawString.components(separatedBy: .newlines)
//            let bulletFormatted = lines.map { line -> String in
//                let trimmed = line.trimmingCharacters(in: .whitespaces)
//                if trimmed.hasPrefix("•") || trimmed.hasPrefix("-") {
//                    return "• \(trimmed.dropFirst())"
//                } else if trimmed != "" {
//                    return "• \(trimmed)"
//                } else {
//                    return ""
//                }
//            }
//            
//            return bulletFormatted.joined(separator: "\n")
//        }
//
//        return ""
//    }
//
//    
//    @IBAction func OrdernowBtnAct(_ sender: Any) {
//        
//        if let url = URL(string: RedirectURL ?? "") {
//            UIApplication.shared.open(url)
//        }
//    }
//    
//    @IBAction func MypaucketBtnAct(_ sender: Any) {
//        
//        //dismiss(animated: true)
//        
//        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
//
//    }
//    @IBAction func Add(_ sender: UIButton) {
//        coupenAdded = true
//        ActivateCoupon{ success in
//            if success {
////                self.spend_coin()
//            }
//        }
//        
////        tv.reloadData()
//        reedimFullView.isHidden = false
//        qrCodeView.isHidden = false
//        QrcodeImage.isHidden = true
//        GoToMyPauket.isHidden = false
//        youCanClaimStack.isHidden = true
//        OrdernowBtn.isHidden = true
//        ActivateBtn.isHidden = true
//        activatePageView.isHidden = true
//        confeeti()
//         }
//    func confeeti(){
//        if isAnimating {
//            self.isAnimating = false
//            if let window = UIApplication.shared.windows.first {
//                confetti1.translatesAutoresizingMaskIntoConstraints = false
//                window.addSubview(confetti1)
//                
//                NSLayoutConstraint.activate([
//                    confetti1.topAnchor.constraint(equalTo: window.topAnchor),
//                    confetti1.rightAnchor.constraint(equalTo: window.rightAnchor),
//                    confetti1.leftAnchor.constraint(equalTo: window.leftAnchor),
//                    confetti1.bottomAnchor.constraint(equalTo: window.bottomAnchor),
//                ])
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
//                    let impactEngine = UIImpactFeedbackGenerator(style: .heavy)
//                    impactEngine.impactOccurred()
//                    //                confetti.emit()
//                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
//                        let impactEngine = UIImpactFeedbackGenerator(style: .heavy)
//                        impactEngine.impactOccurred()
//                        self.confetti1.emit()
//                    }
//                }
//            }
//        }
//    }
//    
//    func ActivateCoupon(onComplete : @escaping(Bool) -> Void){
//        let param : [String : Any] =
//        [
//            "source_link": sourceLink ?? "",
//            "mobile_no": "91" + (mobileNumber ?? "")
//        ]
//        
//        print("paramparamm,nc",param)
//        
//        Activate_coupon_Request
//            .call_request(param: param, headers: DefaultsKeys.packut_Headers ){ [self]
//            (res) in
//            
//            let GetActivateCoupon : ActivateCoupenResponse = Mapper<ActivateCoupenResponse>().map(JSONString: res)!
//            
//            if GetActivateCoupon.status == true {
//                
//                if let couponDetails = GetActivateCoupon.data, let coupons = couponDetails.couponData, !coupons.isEmpty {
//                    let firstCoupon = coupons.first
//                    
//                    self.ActiveBrandName.text = self.campian.first?.merchantName
//                    self.ActiveCategoryLbl.text = self.category
//                    
//                    let dateString = firstCoupon?.expiry_date
//                    let inputFormatter = DateFormatter()
//                    inputFormatter.dateFormat = "yyyy-MM-dd"
//                    
//                    if let date = inputFormatter.date(from: dateString ?? "") {
//                        let calendar = Calendar.current
//                        let day = calendar.component(.day, from: date)
//                        let daySuffix: String
//                        switch day {
//                        case 1, 21, 31:
//                            daySuffix = "st"
//                        case 2, 22:
//                            daySuffix = "nd"
//                        case 3, 23:
//                            daySuffix = "rd"
//                        default:
//                            daySuffix = "th"
//                        }
//                        
//                        let monthFormatter = DateFormatter()
//                        monthFormatter.dateFormat = "MMMM" // Get the month name
//                        let month = monthFormatter.string(from: date)
//                        
//                        let formattedDate = "\(day)\(daySuffix) \(month)"
//                        self.ActiveEpiryDateLbl.text = "Expires on " + formattedDate
//                    }
//                    
//                    
//                    self.ActiveOfferDetailsLbl.text = "Get " + couponDetails.offer! + " Off"
//                    
//                    
//                    self.ActiveBrrandLogoImg.sd_setImage(with: URL(string: self.campian.first?.merchant_logo ?? ""), placeholderImage: UIImage(named: "placeHolder.png"), options: SDWebImageOptions.refreshCached)
//                    
////                    QrcodeImage
////                        .sd_setImage(
////                            with: URL(string: firstCoupon?.qr_code ?? ""),
////                            placeholderImage: UIImage(named: "placeHolder.png"),
////                            options: SDWebImageOptions.refreshCached
////                        )
//                    
//                    self.CouponCodeFld.text = firstCoupon?.coupon_code
//                    let plainText = self.convertHTMLToTextWithBullets(htmlString: self.campian.first?.howToUse ?? "")
//                    self.ActivatedUsageDetails.text = plainText
//                    
//                    self.RedirectURL = couponDetails.CTAredirect
//                    
//                    onComplete(true)
//                }
//                
//            } else{
//                print("Coupon activation failed: \(GetActivateCoupon.message ?? "Unknown error")")
//                onComplete(false)
//            }
//        }
//    }
//    
//    
//    func GetcampaigsDetails(){
//        
//        let param : [String : Any] =
//        ["source_link": sourceLink ?? "","mobile_no": "91" + (mobileNumber ?? "")]
//       
//        
//        print("paramparamm,nc",param)
//        Get_Campaign_details_Request.call_request(param: param,headers: DefaultsKeys.packut_Headers ){ [self]
//            (res) in
//            
//            print("resres",res)
//            let getattendace : CampaignResponse = Mapper<CampaignResponse>().map(JSONString: res)!
//            
//            if getattendace.status == true  {
//                
//                
//                campian.append((getattendace.data?.campaignDetails)!)
//
//                
//                let htmlString = campian.first?.termsAndConditions
//                let plainText = convertHTMLToTextWithBullets(htmlString: htmlString ?? "")
//                print(plainText)
//                temsAndCondionsLbl.text = plainText
//                
//                let htmlString1 = campian.first?.howToUse
//                let plainText1 = convertHTMLToTextWithBullets(htmlString: htmlString1 ?? "")
//                howTouseLbl.text = plainText1
//
//                activateDiscound.text = campian.first?.offer_to_show
//                
//                if campian.first?.expiry_type == "valid_for" {
//                    activateValidateLbl.text = "Valid for " + String(campian.first?.coupon_valid_for ?? 0) + "days"
//                }else{
//                    activateValidateLbl.text = "Valid Until " + (campian.first?.expiryDate ?? "")
//                }
//               
//                activateImageView.layer.cornerRadius = 5
//                activateCuponTitleLbl.text = campian.first?.merchantName
//                
//                activateImageView.sd_setImage(with: URL(string: campian.first?.merchant_logo ?? ""), placeholderImage: UIImage(named: "placeHolder.png"), options: SDWebImageOptions.refreshCached)
//            }else{
//                
//            }
//        }
//        
//    }
//    
////    func spend_coin(){
////        
////        let param : [String : Any] =
////        [
////            "user_type": 1,
////            "mobile_number": mobileNumber ?? "",
////            "coupon_link" : sourceLink ?? "",
////            "coupon_id" : 0
////        ]
////        print("paramparamm,nc",param)
////        
////        let headers: [String: Any] = [ :
////        ]
////        
////        spend_point.call_request(param: param,headers: headers ){ [self]
////            (res) in
////            
////            print("resres",res)
////            let getattendace : CampaignResponse = Mapper<CampaignResponse>().map(JSONString: res)!
////            
////        }
////        
////    }
//    
//    
//}
//struct CoupenDetail{
//    let name:String
//    let contentDetail:String
//    var isSelected:Bool
//}
