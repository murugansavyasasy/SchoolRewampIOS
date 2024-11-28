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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colornames.topBackgroundCLr
        fullview.backgroundColor = Colornames.topBackgroundCLr
        
        bottomFullview.backgroundColor = Colornames.bottomClr
        
        EditBtn.layer.cornerRadius = 10
        saveBtn.isHidden = true
        saveBtn.layer.cornerRadius = 10
        
        imgview.layer.cornerRadius = 50//imgview.frame.width/2
        personalview.layer.cornerRadius = 15
        standardView.layer.cornerRadius = 15
        contactDetails.layer.cornerRadius = 15
        AboutstudentView.layer.cornerRadius = 15
        familyDetailsView.layer.cornerRadius = 15
        
        bloodimg.layer.cornerRadius = 10
        locationimg.layer.cornerRadius = 10
        hostelimg.layer.cornerRadius = 10
        
        Profile.text = "Profile".translated()
        aboutstudent.text = "About Student".translated()
        contactdetails.text = "Contact details".translated()
        section.text = "Section".translated() + ": A"
        standard.text = "Standard".translated() + ": XI"
        RegisterNo.text = "Register number".translated() + ": 476543"
        Familydetails.text = "Family Details".translated()
        Fathername.text = "Fathername".translated()
        FatherOccupation.text = "Father occupation".translated()
        Mothername.text = "Mothername".translated()
        Motheroccupation.text = "Mother occupation".translated()
        SeconadaryphoneNo.text = "Secondary Phone no".translated()
        
        SaveBtnHeight.constant = 0
        //ScrollviewBottom.constant = 0
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
            EditBtn.setTitle("Cancel", for: .normal)
            EditBtn.imageView?.isHidden = true
            
        }else {
            SaveBtnHeight.constant = 0
            
            saveBtn.isHidden = true
            EditBtn.setTitle("Edit", for: .normal)
            EditBtn.imageView?.isHidden = false
        }
        
        
       
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
