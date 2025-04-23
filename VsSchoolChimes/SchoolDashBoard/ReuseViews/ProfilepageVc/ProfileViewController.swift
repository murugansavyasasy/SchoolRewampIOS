//
//  ProfileViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 30/10/24.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var ScrollviewBottom: NSLayoutConstraint!
    @IBOutlet weak var SaveBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var EditBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var bottomFullview: UIView!
    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var contactDetails: UIView!
    @IBOutlet weak var standardView: UIView!
    @IBOutlet weak var personalview: UIView!
    @IBOutlet weak var AboutstudentView: UIView!
    @IBOutlet weak var hostelimg: UIImageView!
    @IBOutlet weak var locationimg: UIImageView!
    @IBOutlet weak var bloodimg: UIImageView!
    @IBOutlet weak var familyDetailsView: UIView!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var Profile: UILabel!
    @IBOutlet weak var RegisterNo: UILabel!
    @IBOutlet weak var aboutstudent: UILabel!
    @IBOutlet weak var contactdetails: UILabel!
    @IBOutlet weak var section: UILabel!
    @IBOutlet weak var standard: UILabel!
    @IBOutlet weak var Familydetails: UILabel!
    @IBOutlet weak var Fathername: UILabel!
    @IBOutlet weak var Mothername: UILabel!
    @IBOutlet weak var FatherOccupation: UILabel!
    @IBOutlet weak var Motheroccupation: UILabel!
    @IBOutlet weak var SeconadaryphoneNo: UILabel!
    @IBOutlet weak var topview: UIView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var schoolNameLbl: UILabel!
    @IBOutlet weak var mobileNoLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var blodLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var LiveinLbl: UILabel!
    @IBOutlet weak var fatherLbl: UILabel!
    @IBOutlet weak var motherLbl: UILabel!
    @IBOutlet weak var fatherOcupationLbl: UILabel!
    @IBOutlet weak var motherOcupationLbl: UILabel!
    @IBOutlet weak var secondryMnoLbl: UILabel!
    
    
    
    
    
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var childDetails = UserDefaultFileManager.get_child_Details()
    var passvalue = 1
    var HideBackButton = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomFullview.backgroundColor = Colornames.bottomClr
       
        SaveBtnHeight.constant = 0
        
        StyleAndTranslater()
        BackBtn.isHidden = HideBackButton
        imgview.layer.cornerRadius = imgview.frame.width/2
        imgview.layer.borderWidth = 1
        imgview.layer.borderColor = UIColor.black.cgColor
        if passvalue == 1{
            familyDetailsView.isHidden = true
            standardView.isHidden = true
            imgview.kf.setImage(with:URL(string: staffDetails?.school_logo ?? ""),placeholder: UIImage(named: "Default_profile"))
            schoolNameLbl.text = childDetails?.school_name
            userNameLbl.text = staffDetails?.staff_name ?? ""
            RegisterNo.text = "Employee ID : \(childDetails?.roll_number ?? "")"
//            mobileNoLbl.text = staffDetails?.
//            emailLbl.text = staffDetails?.e
//            blodLbl.text = childDetails?.blood_group
//            addressLbl.text = childDetails?.student_address
//            LiveinLbl.text = childDetails?.school_city
//            RegisterNo.text = "Employee Id : \(staffDetails.school_naame ?? "")"
//            section.text = "Section : \(childDetails?.section_name ?? "")"
//            standard.text = "Standard : \(childDetails?.standard_name ?? "")"
        }else{
            familyDetailsView.isHidden = false
            imgview.kf.setImage(with:URL(string: childDetails?.school_logo_url ?? ""),placeholder: UIImage(named: "Default_profile"))
            schoolNameLbl.text = childDetails?.school_name
            userNameLbl.text = childDetails?.name
            mobileNoLbl.text = childDetails?.whatsapp_number
            emailLbl.text = childDetails?.email
            blodLbl.text = childDetails?.blood_group
            addressLbl.text = childDetails?.student_address
            LiveinLbl.text = childDetails?.school_city
            fatherLbl.text = ": \(childDetails?.father_name ?? "")"
            motherLbl.text = ": \(childDetails?.mother_name ?? "")"
            fatherOcupationLbl.text = ": \(childDetails?.father_occupation ?? "")"
            motherOcupationLbl.text = ": \(childDetails?.mother_occupation ?? "")"
            secondryMnoLbl.text = ": \(childDetails?.secondary_mobile ?? "")"
            RegisterNo.text = "Register no : \(childDetails?.roll_number ?? "")"
            section.text = "Section : \(childDetails?.section_name ?? "")"
            standard.text = "Standard : \(childDetails?.standard_name ?? "")"
        }
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        if passvalue == 2{
            topview.applyGradient(
                colors: [Colornames.gradientBlue, Colornames.gradientgreen],
                startPoint: CGPoint(x: 1, y: 0.5),
                endPoint: CGPoint(x: 0, y: 0.5)
            )
        }else{
            topview.applyGradient(
                colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
                startPoint: CGPoint(x: 1, y: 0.5),
                endPoint: CGPoint(x: 0, y: 0.5)
            )
        }
    }
    
    
    func StyleAndTranslater(){
        
        
        EditBtn.layer.cornerRadius = Colornames.CORadius10
        saveBtn.isHidden = true
        saveBtn.layer.cornerRadius = Colornames.CORadius10
        imgview.layer.cornerRadius = 50//imgview.frame.width/2
        personalview.layer.cornerRadius = Colornames.CORadius15
        standardView.layer.cornerRadius = Colornames.CORadius15
        contactDetails.layer.cornerRadius = Colornames.CORadius15
        AboutstudentView.layer.cornerRadius = Colornames.CORadius15
        familyDetailsView.layer.cornerRadius = Colornames.CORadius15
        
        bloodimg.layer.cornerRadius = Colornames.CORadius10
        locationimg.layer.cornerRadius = Colornames.CORadius10
        hostelimg.layer.cornerRadius = Colornames.CORadius10
        
        
        //MARK: Tranlater
        Profile.text = CommonStringFile.Profile.translated()
        aboutstudent.text = CommonStringFile.AboutStudent.translated()
        contactdetails.text = CommonStringFile.Contactdetails.translated()
        section.text = CommonStringFile.Section.translated() + ": A"
        standard.text = CommonStringFile.Standard .translated() + ": XI"
        RegisterNo.text = CommonStringFile.Registernumber.translated() + ": 476543"
        Familydetails.text = CommonStringFile.FamilyDetails.translated()
        Fathername.text = CommonStringFile.Fathername.translated()
        FatherOccupation.text = CommonStringFile.Fatheroccupation.translated()
        Mothername.text = CommonStringFile.Mothername.translated()
        Motheroccupation.text = CommonStringFile.Motheroccupation.translated()
        SeconadaryphoneNo.text = CommonStringFile.SecondaryPhoneno.translated()
        
        //MARK: Button Font Stye
        //        EditBtn.setTitleFont(style: .body, size: FontSize.TitleSize)
        saveBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Label Font Stye
        Profile.setFont(style: .header, size: FontSize.HeaderSize)
        aboutstudent.setFont(style: .title, size: FontSize.TitleSize)
        contactdetails.setFont(style: .title, size: FontSize.TitleSize)
        section.setFont(style: .body, size: FontSize.BodySize)
        standard.setFont(style: .body, size: FontSize.BodySize)
        RegisterNo.setFont(style: .body, size: FontSize.BodySize)
        Familydetails.setFont(style: .title, size: FontSize.TitleSize)
        Fathername.setFont(style: .body, size: FontSize.BodySize)
        FatherOccupation.setFont(style: .body, size: FontSize.BodySize)
        Mothername.setFont(style: .body, size: FontSize.BodySize)
        Motheroccupation.setFont(style: .body, size: FontSize.BodySize)
        SeconadaryphoneNo.setFont(style: .body, size: FontSize.BodySize)
        
    }
    
    @IBAction func BackAct(_ sender: Any) {
        print("back Button pressed")
        dismiss(animated: true)
    }
    @IBAction func SaveAct(_ sender: Any) {
        let alert = CustomAlert()
        alert.showAlert(title:"" , message: "Save changes", on: self)
    }
    
    @IBAction func EditBtnAct(_ sender: Any) {
        // ScrollviewBottom.constant = 70
        if EditBtn.titleLabel!.text == "Edit" {
            SaveBtnHeight.constant = 40
            saveBtn.isHidden = false
            EditBtn.setTitle(AlertstringFile.Cancel, for: .normal)
            EditBtn.layoutIfNeeded()
            EditBtn.setImage(nil, for: .normal)
        }else {
            SaveBtnHeight.constant = 0
            saveBtn.isHidden = true
            EditBtn.setTitle("Edit", for: .normal)
            EditBtn.setImage(UIImage(systemName: "pencil"), for: .normal)
        }
        
    }
    
}

