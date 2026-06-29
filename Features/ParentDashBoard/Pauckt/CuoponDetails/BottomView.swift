
//  BottomView.swift
//  rewardDesign
//
//  Created by admin on 18/02/25.
//

import UIKit
import SDWebImage
protocol AddCoupen{
    func addpucket()
}
class BottomView: UIViewController, AddCoupen{
    func addpucket() {
        coupenAdded = true
       // tv.reloadData()
    }
    private var confettiLayer: CAEmitterLayer?
    private var isAnimating = true
    private let confetti1: ConfettiView = .top

    @IBOutlet weak var ActiveBrrandLogoImg: UIImageView!
    @IBOutlet weak var ActiveBrandName: UILabel!
    @IBOutlet weak var ActiveCategoryLbl: UILabel!
    @IBOutlet weak var ActiveOfferDetailsLbl: UILabel!
    @IBOutlet weak var QrcodeImage: UIImageView!
    @IBOutlet weak var ActiveEpiryDateLbl: UILabel!
    @IBOutlet weak var ActivatedUsageDetails: UILabel!
    @IBOutlet weak var CouponCopyBtn: UIButton!
    @IBOutlet weak var CouponCodeFld: UITextField!
    @IBOutlet weak var CategoryLbl: UILabel!
    @IBOutlet weak var temsAndCondtionImage: UIImageView!
    @IBOutlet weak var howtoUseDropImage: UIImageView!
    @IBOutlet weak var GoToMyPauket: UIButton!
    @IBOutlet weak var branchYoucanClaimLbl: UILabel!
    @IBOutlet weak var activateImageView: UIImageView!
    @IBOutlet weak var activateValidateLbl: UILabel!
    @IBOutlet weak var howTouseLbl: UILabel!
    @IBOutlet weak var temsAndCondionsLbl: UILabel!
    @IBOutlet weak var activateCouponLocationLbl: UILabel!
    @IBOutlet weak var activateCuponTitleLbl: UILabel!
    @IBOutlet weak var activateDiscound: UILabel!
    @IBOutlet weak var temsAndCondionStack: UIStackView!
    @IBOutlet weak var howTouseStack: UIStackView!
    @IBOutlet weak var youCanClaimStack: UIStackView!
    @IBOutlet weak var reedimFullView: UIView!
    @IBOutlet weak var qrCodeView: UIView!
    @IBOutlet weak var activatePageView: UIView!
    @IBOutlet weak var BranchesClaimHorizontal: UIStackView!
    @IBOutlet weak var BranchesDropdownImg: UIImageView!
    @IBOutlet weak var BranchesYouCanClaimDefLbl: UILabel!
    @IBOutlet weak var HowtoUseHorizontal: UIStackView!
    @IBOutlet weak var TermsAndCondHorizontal: UIStackView!
    @IBOutlet weak var OrdernowBtn: UIButton!
    @IBOutlet weak var ActivateBtn: UIButton!
    @IBOutlet weak var HowtouseDefLbl: UILabel!
    @IBOutlet weak var TermsAndCondDefLbl: UILabel!
    @IBOutlet weak var QrcodeHeight: NSLayoutConstraint!
    
    var coupenAdded = false
    var campian : CampaignDetails?
    var source_link : String?
    var DataArray : [String] = []
    var category : String?
    var Coupon : [CouponDetails] = []
    var sourceLink : String?
    var CouponStatus : String?
    var RedirectURL : String?
    var childId : String?
    var totalPoints : String?
    var campaignData: CampaignDetails?
    var ActivatedCoupon: CouponDetails?

    override func viewDidLoad() {
        super.viewDidLoad()
         
        QrcodeHeight.constant = 0
        reedimFullView.isHidden = true
        qrCodeView.isHidden = true
        GoToMyPauket.isHidden = true
        youCanClaimStack.isHidden = true
        temsAndCondionsLbl.isHidden = true
        howTouseLbl.isHidden = true
        branchYoucanClaimLbl.isHidden = true
        OrdernowBtn.isHidden = true
        activatePageView.layer.cornerRadius = 20
        
       
        
        if CouponStatus == "activated" {
            
            ActivateBtn.isHidden = true
        }
        
        OrdernowBtn.layer.cornerRadius = 20
        GoToMyPauket.layer.cornerRadius = 20
        GoToMyPauket.layer.borderWidth = 1
        GoToMyPauket.layer.borderColor = UIColor.black.cgColor
        
        ActiveBrandName.setFont(style: .body, size: 15)
        ActiveCategoryLbl.setFont(style: .body, size: 13)
        ActiveOfferDetailsLbl.setFont(style: .title, size: 17)
        ActiveEpiryDateLbl.setFont(style: .body, size: 13)
        CategoryLbl.setFont(style: .body, size: 15)
        activateDiscound.setFont(style: .title, size: 15)
        activateCuponTitleLbl.setFont(style: .body, size: 14)
        activateCouponLocationLbl.setFont(style: .body, size: 13)
        activateValidateLbl.setFont(style: .body, size: 13)
        
        ActivatedUsageDetails.setFont(style: .body, size: 14)
        BranchesYouCanClaimDefLbl.setFont(style: .title, size: 15)
        branchYoucanClaimLbl.setFont(style: .body, size: 15)
        howTouseLbl.setFont(style: .body, size: 15)
        branchYoucanClaimLbl.setFont(style: .body, size: 15)
        HowtouseDefLbl.setFont(style: .title, size: 15)
        TermsAndCondDefLbl.setFont(style: .title, size: 15)
        temsAndCondionsLbl.setFont(style: .body, size: 15)
        
        OrdernowBtn.setTitleFont(style: .secondary, size: 14)
        GoToMyPauket.setTitleFont(style: .secondary, size: 14)
        ActivateBtn.setTitleFont(style: .secondary, size: 14)
        
        CouponCodeFld.isEnabled = false
        
//        GetcampaigsDetails()
        
        get_campaign_details()
        
        CategoryLbl.text = category
        
        let temsAndCondionTapGesture = UITapGestureRecognizer(target: self, action: #selector(dropClick))
        temsAndCondionStack.addGestureRecognizer(temsAndCondionTapGesture)
        
        let howtoUSe = UITapGestureRecognizer(target: self, action: #selector(HowTouse))
        howTouseStack.addGestureRecognizer(howtoUSe)
        
        let BranchesCanTap = UITapGestureRecognizer(target: self, action: #selector(BranchesClaim))
        youCanClaimStack.addGestureRecognizer(BranchesCanTap)
        
        addDashedBorder(to: CouponCodeFld)
    }
    
    func addDashedBorder(to textField: UITextField) {
        let border = CAShapeLayer()
        border.strokeColor = UIColor.systemGreen.cgColor
        border.lineDashPattern = [4, 4] // 4 points dashed, 4 points space
        border.frame = textField.bounds
        border.fillColor = nil
        border.path = UIBezierPath(roundedRect: textField.bounds, cornerRadius: textField.layer.cornerRadius).cgPath
        textField.layer.addSublayer(border)
    }

    
    @IBAction func CopyBtnAct(_ sender: Any) {
        
        guard let text = CouponCodeFld.text, !text.isEmpty else {
                    print("Text field is empty")
                    return
                }

                // Copy the text to the clipboard
                UIPasteboard.general.string = text
                print("Text copied to clipboard: \(text)")
    }
    
    @IBAction func dropClick() {
        
        temsAndCondionsLbl.isHidden.toggle()
    }
    
    @IBAction func HowTouse() {
        
        howTouseLbl.isHidden.toggle()
    }
    
    @IBAction func BranchesClaim() {
        
        branchYoucanClaimLbl.isHidden.toggle()
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
    
    func convertHTMLToTextWithBullets(htmlString: String) -> String {
        guard let data = htmlString.data(using: .utf8) else { return "" }

        if let attributedString = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil) {
            
            let rawString = attributedString.string
            
            // Optional: Add bullet points to lines that likely represent list items
            let lines = rawString.components(separatedBy: .newlines)
            let bulletFormatted = lines.map { line -> String in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("•") || trimmed.hasPrefix("-") {
                    return "• \(trimmed.dropFirst())"
                } else if trimmed != "" {
                    return "• \(trimmed)"
                } else {
                    return ""
                }
            }
            
            return bulletFormatted.joined(separator: "\n")
        }

        return ""
    }

    
    @IBAction func OrdernowBtnAct(_ sender: Any) {
        
        if let url = URL(string: RedirectURL ?? "") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func MypaucketBtnAct(_ sender: Any) {
        
        //dismiss(animated: true)
        
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

    }
    @IBAction func Add(_ sender: UIButton) {
        coupenAdded = true
        activate_coupon{ success in
            if success {
//                self.spend_coin()
            }
        }
    
        reedimFullView.isHidden = false
        qrCodeView.isHidden = false
        QrcodeImage.isHidden = true
        GoToMyPauket.isHidden = false
        youCanClaimStack.isHidden = true
        OrdernowBtn.isHidden = true
        ActivateBtn.isHidden = true
        activatePageView.isHidden = true
        confeeti()
         }
    func confeeti(){
        if isAnimating {
            self.isAnimating = false
            if let window = UIApplication.shared.windows.first {
                confetti1.translatesAutoresizingMaskIntoConstraints = false
                window.addSubview(confetti1)
                
                NSLayoutConstraint.activate([
                    confetti1.topAnchor.constraint(equalTo: window.topAnchor),
                    confetti1.rightAnchor.constraint(equalTo: window.rightAnchor),
                    confetti1.leftAnchor.constraint(equalTo: window.leftAnchor),
                    confetti1.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                ])
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
                    let impactEngine = UIImpactFeedbackGenerator(style: .heavy)
                    impactEngine.impactOccurred()
                    //                confetti.emit()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                        let impactEngine = UIImpactFeedbackGenerator(style: .heavy)
                        impactEngine.impactOccurred()
                        self.confetti1.emit()
                    }
                }
            }
        }
    }
    
    func get_campaign_details(){
        
        let params: [String: Any] = [PaucketHeader.source_link:sourceLink ?? "", PaucketHeader.mobile_no: "91" + (UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? "")]
        APIService.shared
            .makeApi(url: ServiceUrl.get_campaign_details, parameters: params, type: ApitTypeSringFile.POST, token: PaucketHeader.Paucket, isBaseUrl: false) {[self] (
                result: Result<CampaignResponse,
                Error>
            ) in
            
            switch result{
                
            case .success(let success):
                DispatchQueue.main.async { [self] in
                        
                 
                    campian = success.data?.campaign_details
                    
//                    campaignData.append((getattendace.data?.campaign_details)!)

                    
                    let htmlString = campian?.terms_and_conditions
                    let plainText = convertHTMLToTextWithBullets(htmlString: htmlString ?? "")
                    print(plainText)
                    temsAndCondionsLbl.text = plainText
                    
                    let htmlString1 = campian?.how_to_use
                    let plainText1 = convertHTMLToTextWithBullets(htmlString: htmlString1 ?? "")
                    howTouseLbl.text = plainText1

                    activateDiscound.text = campian?.offer_to_show
                    
                    if campian?.expiry_type == "valid_for" {
                        activateValidateLbl.text = "Valid for " + String(campian?.coupon_valid_for ?? "") + "days"
                    }else{
                        activateValidateLbl.text = "Valid Until " + (
                            campian?.expiry_date ?? ""
                        )
                    }
                   
                    activateImageView.layer.cornerRadius = 5
                    activateCuponTitleLbl.text = campian?.merchant_name
                    
                    activateImageView.sd_setImage(with: URL(string: campian?.merchant_logo ?? ""), placeholderImage: UIImage(named: "placeHolder.png"), options: SDWebImageOptions.refreshCached)
                    
                }
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print("Error:",error.localizedDescription)
                    if let error = error as? DecodingError {
                        switch error {
                        case .typeMismatch(let type, let context):
                            print("Type mismatch:", type, context)
                        case .valueNotFound(let type, let context):
                            print("Value not found:", type, context)
                        case .keyNotFound(let key, let context):
                            print("Key '\(key)' not found:", context)
                        case .dataCorrupted(let context):
                            print("Data corrupted:", context)
                        default:
                            print("Other decoding error:", error)
                        }
                    }
                }
            }
        }
    }
    
   
        
    func activate_coupon(onComplete: @escaping (Bool) -> Void) {
        
        let param: [String: Any] = [
            PaucketHeader.source_link: sourceLink ?? "",
            PaucketHeader.mobile_no: UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? ""
        ]
        
        APIService.shared.makeApi(
            url: ServiceUrl.activate_coupon,
            parameters: param,
            type: ApitTypeSringFile.POST,
            token: PaucketHeader.Paucket, isBaseUrl: false
        ) { [weak self] (result: Result<ActivateCouponResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                DispatchQueue.main.async {
                    self.ActivatedCoupon = success.data
                    guard let couponDetails = self.ActivatedCoupon,
                          let coupons = couponDetails.coupons,
                          let firstCoupon = coupons.first else {
                        onComplete(false)
                        return
                    }
                    self.ActiveBrandName.text = self.campian?.merchant_name
                    self.ActiveCategoryLbl.text = self.category
                    // Format expiry date
                    if let dateString = firstCoupon.expiry_date {
                        let inputFormatter = DateFormatter()
                        inputFormatter.dateFormat = "yyyy-MM-dd"
                        inputFormatter.locale = LocaleManager.shared.apiLocale
                        
                        if let date = inputFormatter.date(from: dateString) {
                            let day = Calendar.current.component(.day, from: date)
                            let daySuffix: String
                            switch day {
                            case 1, 21, 31: daySuffix = "st"
                            case 2, 22: daySuffix = "nd"
                            case 3, 23: daySuffix = "rd"
                            default: daySuffix = "th"
                            }
                            
                            let monthFormatter = DateFormatter()
                            monthFormatter.dateFormat = "MMMM"
                            monthFormatter.locale = LocaleManager.shared.apiLocale
                            let month = monthFormatter.string(from: date)
                            
                            self.ActiveEpiryDateLbl.text = "Expires on \(day)\(daySuffix) \(month)"
                        }
                    }
                    if let offerText = couponDetails.offer {
                        self.ActiveOfferDetailsLbl.text = "Get \(offerText) Off"
                    }
                    if let logoURL = self.campian?.merchant_logo {
                        self.ActiveBrrandLogoImg.sd_setImage(
                            with: URL(string: logoURL),
                            placeholderImage: UIImage(named: "placeHolder.png"),
                            options: .refreshCached
                        )
                    }
                    self.CouponCodeFld.text = firstCoupon.coupon_code
                    
                    let howToUseHTML = self.campian?.how_to_use ?? ""
                    self.ActivatedUsageDetails.text = self.convertHTMLToTextWithBullets(htmlString: howToUseHTML)
                    
                    self.RedirectURL = couponDetails.CTAredirect
                    
                    onComplete(true)
                }
                
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Error:", error.localizedDescription)
                    //                    onComplete(false)
                }
            }
        }
    }
    
    
    

//    func spend_coin(){
//        
//        let param : [String : Any] =
//        [
//            "user_type": 1,
//            "mobile_number": mobileNumber ?? "",
//            "coupon_link" : sourceLink ?? "",
//            "coupon_id" : 0
//        ]
//        print("paramparamm,nc",param)
//        
//        let headers: [String: Any] = [ :
//        ]
//        
//        spend_point.call_request(param: param,headers: headers ){ [self]
//            (res) in
//            
//            print("resres",res)
//            let getattendace : CampaignResponse = Mapper<CampaignResponse>().map(JSONString: res)!
//            
//        }
//        
//    }
    
    
}
struct CoupenDetail{
    let name:String
    let contentDetail:String
    var isSelected:Bool
}
