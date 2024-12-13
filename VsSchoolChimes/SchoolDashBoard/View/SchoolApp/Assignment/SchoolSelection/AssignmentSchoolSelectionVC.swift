//
//  AssignmentSchoolSelectionVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 30/04/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class AssignmentSchoolSelectionVC: UIViewController ,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet var MyTableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var closeButtonHeight: NSLayoutConstraint!
    var SelectedSchoolDeatilDict:NSDictionary = [String:Any]() as NSDictionary
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let UtilObj = UtilClass()
    var ViewFrom = String()
    var VoiceData : NSData? = nil
    var sendAssignmentType = String()
    var vimeoVideoDict =  NSMutableDictionary()
    var vimeoURL : URL!
    override func viewDidLoad() {
        super.viewDidLoad()
        if(ViewFrom == "view"){
            closeButton.isHidden = true
            closeButtonHeight.constant = 0
        }else{
            closeButton.isHidden = false
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                closeButtonHeight.constant = 50
            }else{
                closeButtonHeight.constant = 30
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    //MARK: Button Action
    @IBAction func actionCloseView(_ sender: UIButton) {
        
        dismiss(animated: false, completion: nil)
    }
    
    //MARK: TABLEVIEW DELEGATE
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 65
        }else{
            return 50
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.LoginSchoolDetailArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageTVCell", for: indexPath) as! TextMessageTVCell
        let Dict = appDelegate.LoginSchoolDetailArray[indexPath.row] as! NSDictionary
        cell.SchoolNameLbl.text = Dict["SchoolName"] as? String
        var schoolNameReg  =  Dict["SchoolNameRegional"] as? String

                            if schoolNameReg != "" && schoolNameReg != nil {

                                cell.SchoolNameRegionalLbl.text = schoolNameReg
                                cell.SchoolNameRegionalLbl.isHidden = false

        //                        cell.locationTop.constant = 4
                            }else{
                                cell.SchoolNameRegionalLbl.isHidden = true
                    //            cell.SchoolNameRegional.backgroundColor = .red
                                cell.schoolNameTop.constant = 20

                            }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SelectedSchoolDeatilDict = appDelegate.LoginSchoolDetailArray[indexPath.row] as! NSDictionary
        UtilObj.printLogKey(printKey: "SelectedSchoolDeatilDict", printingValue: SelectedSchoolDeatilDict)
        if(ViewFrom == "view"){
            performSegue(withIdentifier: "StaffViewAssignmentListSegue", sender: self)
        }else  if(ViewFrom == "VimeoVideo"){
            goToSectionSelection()
        }else{
            handleDidSelect()
        }
        
    }
    
    
    func goToSectionSelection(){
        vimeoVideoDict["SchoolId"] =  String(describing: SelectedSchoolDeatilDict["SchoolID"]!) as NSString
        vimeoVideoDict["ProcessBy"] = String(describing: SelectedSchoolDeatilDict["StaffID"]!) as NSString
        print(SelectedSchoolDeatilDict)
        let schoolVC  = self.storyboard?.instantiateViewController(withIdentifier: "PrincipalGroupSelectionVC") as! PrincipalGroupSelectionVC
        schoolVC.fromViewController = "VimeoVideoToParents"
        schoolVC.fromView = "VimeoVideoToParents"
        schoolVC.vimeoVideoDict = self.vimeoVideoDict
        schoolVC.VideoData = self.VoiceData
        schoolVC.vimeoVideoURL =  vimeoURL as! URL
        schoolVC.SchoolID = String(describing: SelectedSchoolDeatilDict["SchoolID"]!) as NSString
        schoolVC.StaffID = String(describing: SelectedSchoolDeatilDict["StaffID"]!) as NSString
        schoolVC.selectedSchoolDictionary = NSMutableDictionary(dictionary: SelectedSchoolDeatilDict)
        schoolVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(schoolVC, animated: true, completion: nil)
    }
    
    func handleDidSelect(){
        if(sendAssignmentType == "text"){
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "TextHomeWorkVC") as! TextHomeWorkVC
            AddCV.SchoolDetailDict = SelectedSchoolDeatilDict
            AddCV.strFrom = "Assignment"
            self.present(AddCV, animated: false, completion: nil)
            
        }else  if(sendAssignmentType == "voice"){
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "VoiceHomeWorkVC") as! VoiceHomeWorkVC
            AddCV.SchoolDetailDict = SelectedSchoolDeatilDict
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "StaffViewAssignmentListSegue"){
            let segueid = segue.destination as! StaffViewAssignmentVC
            segueid.selectedSchoolDictionary = SelectedSchoolDeatilDict
        }
    }
    @objc func catchNotification(notification:Notification) -> Void
    {
        dismiss(animated: false, completion: nil)
    }
    
    
}
