//
//  certificateReqTVCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 07/08/25.
//

import UIKit

protocol certificateRequest{
    
    func reqestBtn(type:String,urgencyLevel:String,reason:String)
}
class certificateReqTVCell: UITableViewCell,UITextViewDelegate {

    @IBOutlet weak var ResondefaultLbl: UILabel!
    @IBOutlet weak var ResontextView: UITextView!
    @IBOutlet weak var NotUrgentView: UIView!
    @IBOutlet weak var UrgentView: UIView!
    @IBOutlet weak var NoturgentCheckImg: UIImageView!
    @IBOutlet weak var UrgentCheckImg: UIImageView!
    @IBOutlet weak var DropdownLbl: UILabel!
    @IBOutlet weak var certificsteTypeView: UIViewX!
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var MenuNameLbl: UILabel!
    
    
    var placeholderLabel: UILabel!
    var CertificatTypes : [String]?
    let dropdown = DropDown()
    var textChanged: ((String) -> Void)? // callback to controller
    var delegate : certificateRequest?
    var urgetStatus = "Not Urgent"
    var placeHolderName = "Enter your reason here..."
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        ResondefaultLbl.setRequiredText("Reason", asteriskColor: .red)
        
        certificateTypeApi()
        ResontextView.addDoneButton()
        MenuNameLbl.text = MenuStringFile.selectedMenuName
        requestBtn.layer.cornerRadius = 10
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 5
        fullview.layer.cornerRadius = 10
        fullview.backgroundColor = .white
        ResontextView.delegate = self
           setupPlaceholder()
        let click = UITapGestureRecognizer(target: self, action:#selector(DropDowns))
        certificsteTypeView.addGestureRecognizer(click)
        
        UrgentCheckImg.image = UIImage(named: "CheckCircle")
        NoturgentCheckImg.image = UIImage(named: "RadioCheck")
        
        UrgentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UrgentAct)))
        NotUrgentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(NotUrgentAct)))
        
    }
    func resetFields() {
        ResontextView.text = ""
        placeholderLabel.isHidden = false
        urgetStatus = "Not Urgent"
        NoturgentCheckImg.image = UIImage(named: "RadioCheck")
        UrgentCheckImg.image = UIImage(named: "CheckCircle")
        DropdownLbl.text = CertificatTypes?.first
    }
    
    func setupPlaceholder() {
        ResontextView.text = ""
        placeholderLabel = UILabel()
        placeholderLabel.text = placeHolderName
        placeholderLabel.font = ResontextView.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8) // Adjust padding
        ResontextView.applyRightTxt()
        ResontextView.applyRightTxt(with: placeholderLabel)
        ResontextView.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !ResontextView.text.isEmpty // Hide if text exists
    }

    @IBAction func requestCertificateBtn(_ sender: UIButton) {
        
        delegate?
            .reqestBtn(
                type: DropdownLbl.text ?? "",
                urgencyLevel: urgetStatus,
                reason: ResontextView
                    .text)
        
    }

//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.textColor == UIColor.lightGray {
//            textView.text = nil
//            textView.textColor = UIColor.black
//        }
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = placeHolderName
//            textView.textColor = UIColor.lightGray
//        }
//    }
    func textViewDidChange(_ textView: UITextView) {
            textChanged?(textView.text) // callback to controller
            placeholderLabel.isHidden = !ResontextView.text.isEmpty
        }
    
    @IBAction func UrgentAct() {
        UrgentCheckImg.image = UIImage(named: "RadioCheck")
        NoturgentCheckImg.image = UIImage(named: "CheckCircle")
        urgetStatus = "Urgent"
    }

    @IBAction func NotUrgentAct() {
        NoturgentCheckImg.image = UIImage(named: "RadioCheck")
        UrgentCheckImg.image = UIImage(named: "CheckCircle")
        urgetStatus = "Not Urgent"
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func DropDowns(){
       
        dropdown.anchorView = certificsteTypeView
        dropdown.dataSource = CertificatTypes ?? []
        dropdown.show()
        dropdown.bottomOffset = CGPoint(
            x: 0,
            y: certificsteTypeView.bounds.height
        )
 
        dropdown.selectionAction = { [weak self] (index: Int, item: String) in
            self?.DropdownLbl.text = item
        }
        
    }
    
    func certificateTypeApi() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_certificate_types,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<ResetPasswordSuc, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.CertificatTypes = response.data
                    self?.DropdownLbl.text = self?.CertificatTypes?.first
                case .failure(let error):
                    print("API Error:", error)
                }
            }
        }
    }
}
