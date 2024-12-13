//
//  CreateAssignmentVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 04/05/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class CreateAssignmentVC: UIViewController {
    
    
    @IBOutlet weak var TextButton: UIButton!
    @IBOutlet weak var VoiceButton: UIButton!
    @IBOutlet weak var ImageButton: UIButton!
    @IBOutlet weak var PdfButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    
    var SchoolID = NSString()
    var StaffID = NSString()
    var loginAsName = String()
    var sendAssignmentType = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var fromViewController = NSString()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.callSelectedLanguage()
        TextButton.layer.cornerRadius = 5
        TextButton.layer.masksToBounds = true
        
        VoiceButton.layer.cornerRadius = 5
        VoiceButton.layer.masksToBounds = true
        
        ImageButton.layer.cornerRadius = 5
        ImageButton.layer.masksToBounds = true
        
        PdfButton.layer.cornerRadius = 5
        PdfButton.layer.masksToBounds = true
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    @IBAction func actionTextButton(_ sender: UIButton){
        sendAssignmentType = "text"
        if(loginAsName == "Principal"){
            
            if(self.appDelegate.LoginSchoolDetailArray.count == 1){
                handleDidSelect()
            }
            else{
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "SelectSchoolSegue", sender: self)
                }
            }
        }else{
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "TextHomeWorkVC") as! TextHomeWorkVC
            AddCV.SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            AddCV.strFrom = "Assignment"
            self.present(AddCV, animated: false, completion: nil)
        }
        
        
    }
    
    @IBAction func actionVoiceButton(_ sender: UIButton){
        
        sendAssignmentType = "voice"
        if(loginAsName == "Principal"){
            
            
            
            if(self.appDelegate.LoginSchoolDetailArray.count == 1){
                handleDidSelect()
            }
            else{
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "SelectSchoolSegue", sender: self)
                }
            }
        }else{
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "VoiceHomeWorkVC") as! VoiceHomeWorkVC
            AddCV.SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            AddCV.strFrom = "Assignment"
            self.present(AddCV, animated: false, completion: nil)
        }
    }
    
    @IBAction func actionImageButton(_ sender: UIButton){
        
        sendAssignmentType = "image"
        if(loginAsName == "Principal"){
            
            
            if(self.appDelegate.LoginSchoolDetailArray.count == 1){
                handleDidSelect()
            }
            else{
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "SelectSchoolSegue", sender: self)
                }
            }
        }else{
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "SendImagePDFAssignmentVC") as! SendImagePDFAssignmentVC
            AddCV.SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            AddCV.strFrom = "Assignment"
            AddCV.assignmentType = "image"
            self.present(AddCV, animated: false, completion: nil)
        }
    }
    
    @IBAction func actionPdfButton(_ sender: UIButton){
        
        sendAssignmentType = "pdf"
        if(loginAsName == "Principal"){
            
            if(self.appDelegate.LoginSchoolDetailArray.count == 1){
                handleDidSelect()
            }
            else{
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "SelectSchoolSegue", sender: self)
                }
            }
            
        }else{
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "SendImagePDFAssignmentVC") as! SendImagePDFAssignmentVC
            AddCV.SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            AddCV.strFrom = "Assignment"
            AddCV.assignmentType = "pdf"
            self.present(AddCV, animated: false, completion: nil)
        }
    }
    
    
    
    func handleDidSelect(){
        if(sendAssignmentType == "text"){
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "TextHomeWorkVC") as! TextHomeWorkVC
            AddCV.SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            AddCV.strFrom = "Assignment"
            self.present(AddCV, animated: false, completion: nil)
            
        }else  if(sendAssignmentType == "voice"){
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "VoiceHomeWorkVC") as! VoiceHomeWorkVC
            AddCV.SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            AddCV.strFrom = "Assignment"
            self.present(AddCV, animated: false, completion: nil)
        }else  if(sendAssignmentType == "image"){
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "SendImagePDFAssignmentVC") as! SendImagePDFAssignmentVC
            AddCV.SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            AddCV.strFrom = "Assignment"
            AddCV.assignmentType = "image"
            self.present(AddCV, animated: false, completion: nil)
            
        }else  if(sendAssignmentType == "pdf"){
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "SendImagePDFAssignmentVC") as! SendImagePDFAssignmentVC
            AddCV.SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            AddCV.strFrom = "Assignment"
            AddCV.assignmentType = "pdf"
            self.present(AddCV, animated: false, completion: nil)
            
        }
        
    }
    
    
    
    
    //MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "SelectSchoolSegue"){
            let segueid = segue.destination as! AssignmentSchoolSelectionVC
            segueid.ViewFrom = "create"
            segueid.sendAssignmentType = sendAssignmentType
        }
    }
    
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        let strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }
            } catch {
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        textLabel.text = LangDict["send_assignment_title"] as? String
        TextButton.setTitle(LangDict["teacher_txt_text"] as? String, for: .normal)
        ImageButton.setTitle(LangDict["teacher_txt_Image"] as? String, for: .normal)
        VoiceButton.setTitle(LangDict["teacher_txt_voice"] as? String, for: .normal)
        PdfButton.setTitle(LangDict["pdf_1"] as? String, for: .normal)
    }
    
}
