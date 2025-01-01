//
//  ProfileViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 30/10/24.
//

import UIKit

class ProfileViewController: UIViewController {

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
    
    @IBOutlet weak var bgView: UIView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        view.backgroundColor = Colornames.topBackgroundCLr
//        fullview.backgroundColor = Colornames.topBackgroundCLr
        
        bottomFullview.backgroundColor = Colornames.bottomClr
        
//        fullview.applyGradient(
//                   colors: [Colornames.gradientBlue, Colornames.gradientgreen],
//                   startPoint: CGPoint(x: 1, y: 0.5),
//                   endPoint: CGPoint(x: 0, y: 0.5)
//               )
               topview.applyGradient(
                   colors: [Colornames.gradientBlue, Colornames.gradientgreen],
                   startPoint: CGPoint(x: 1, y: 0.5),
                   endPoint: CGPoint(x: 0, y: 0.5)
               )
      
        
        SaveBtnHeight.constant = 0
        
        StyleAndTranslater()
      
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

