//
//  StaffLeaveRequestPopupVC.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 16/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffLeaveRequestPopupVC: UIViewController,Apidelegate,UITextViewDelegate {
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var ClassLabel: UILabel!
    @IBOutlet weak var LeaveAppiledOnLabel: UILabel!
    @IBOutlet weak var LeaveFromLabel: UILabel!
    @IBOutlet weak var LeaveToLabel: UILabel!
    @IBOutlet weak var reasonTextView: UITextView!
    //@IBOutlet weak var responseTextView: UITextView!
    @IBOutlet weak var DeclineButton: UIButton!
    @IBOutlet weak var ApproveButton: UIButton!
  //  @IBOutlet weak var responseView: UIView!
   // @IBOutlet weak var reasonHeight: NSLayoutConstraint!
    @IBOutlet weak var FloatNameLabel: UILabel!
    @IBOutlet weak var FloatClassLabel: UILabel!
    @IBOutlet weak var FlaotLeaveAppiledOnLabel: UILabel!
    @IBOutlet weak var FloatLeaveFromLabel: UILabel!
    @IBOutlet weak var FloatLeaveToLabel: UILabel!
    @IBOutlet weak var FlaotReason: UILabel!
    @IBOutlet weak var TitlLable: UILabel!
    var strCountryCode = String()

    var selectedHistoryDict : NSDictionary = NSDictionary()
    var languageDictionary = NSDictionary()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var AlertString : String = String()
    var strLeaveID : String = String()
    var strStatus : String = String()
    var strStaffID : String = String()
    var strLanguage = String()
    let UtilObj = UtilClass()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
          strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
       
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
  
    func cornerDesign(){
        ApproveButton.layer.cornerRadius = 5
        ApproveButton.layer.masksToBounds = true
        DeclineButton.layer.cornerRadius = 5
        DeclineButton.layer.masksToBounds = true
    }
    
    //MARK: Button Action
    
    @IBAction func actionOkButton(_ sender: UIButton) {
       close()
    }
    
    func close(){
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBackFromPopup"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionApproveButton(_ sender: UIButton) {
        strStatus = "1"
        updateStatus()
    }
    
    @IBAction func actionDeclineButton(_ sender: UIButton) {
        strStatus = "2"
        updateStatus()
    }
    
    func updateStatus(){
        if(Util .isNetworkConnected()){
            self.UpateLeaveStatusCalling()
        }else
        {
            Util.showAlert("", msg: strNoInternet)
        }
    }
    //MARK: API CALLING
    
    func UpateLeaveStatusCalling(){
        showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + UPDATE_LEAVE_REQUEST
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["leaveid" : strLeaveID ,"status" : strStatus,"updatedby" : strStaffID, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetLeaveRequestApi")
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!){
        hideLoading()
        if(csData != nil){
            UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if let CheckedArray = csData as? NSArray{
                if(CheckedArray.count > 0){
                    let dict : NSDictionary = CheckedArray.mutableCopy() as! NSDictionary
                    if let val =  dict["status"] {
                        AlertString  = String(describing: dict["message"]!)
                        Util .showAlert("", msg: AlertString);
                        self.close()
                        
                    }else
                    {
                        Util .showAlert("", msg: strSomething);
                    }
                }else
                {
                    Util .showAlert("", msg: strSomething);
                }
            }else
            {
                Util .showAlert("", msg: strSomething);
            }
        }else
        {
            Util.showAlert("", msg: strSomething)
        }
        hideLoading()
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util .showAlert("", msg: strSomething);
    }
    
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        // popupLoading.dismiss(true)
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }else{
                    self.loadViewData()
                }
            } catch {
                self.loadViewData()
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDictionary = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.TitlLable.text = languageDictionary["leave_history"] as? String
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.TitlLable.text = languageDictionary["leave_history"] as? String
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
        
    }
    
    func loadViewData(){
        if(appDelegate.LoginSchoolDetailArray.count > 0){
            let dict:NSDictionary = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            strStaffID = String(describing: dict["StaffID"]!)
        }
      
        cornerDesign()
        strStatus = "0"
        if(String(describing: selectedHistoryDict["Status"]!) == "0"){
            ApproveButton.isHidden = false
            DeclineButton.isHidden = false
        }else{
            ApproveButton.isHidden = true
            DeclineButton.isHidden = true
        }
        
        strLeaveID = String(describing: selectedHistoryDict["LeaveId"]!)
       
        if(strLanguage == "ar"){
            
            self.NameLabel.textAlignment = .right
            self.ClassLabel.textAlignment = .right
            self.LeaveAppiledOnLabel.textAlignment = .right
            self.LeaveFromLabel.textAlignment = .right
            self.LeaveToLabel.textAlignment = .right
            self.reasonTextView.textAlignment = .right
            self.FlaotReason.textAlignment = .right
            self.FloatNameLabel.textAlignment = .right
            self.FloatClassLabel.textAlignment = .right
            self.FloatLeaveToLabel.textAlignment = .right
            self.FlaotReason.textAlignment = .right
            self.FloatLeaveFromLabel.textAlignment = .right
            self.FlaotLeaveAppiledOnLabel.textAlignment = .right
            
            NameLabel.text =  String(describing: selectedHistoryDict["StudentName"]!) + " : "
            ClassLabel.text =  String(describing: selectedHistoryDict["Class"]!) + " - " + String(describing: selectedHistoryDict["Section"]!) + " : "
            LeaveAppiledOnLabel.text =  String(describing: selectedHistoryDict["LeaveAppliedOn"]!) + " : "
            LeaveFromLabel.text =   String(describing: selectedHistoryDict["LeaveFromDate"]!) + " : "
            LeaveToLabel.text = String(describing: selectedHistoryDict["LeaveTODate"]!) + " : "
            reasonTextView.text =  String(describing: selectedHistoryDict["Reason"]!)
        }else{
            self.NameLabel.textAlignment = .left
            self.ClassLabel.textAlignment = .left
            self.LeaveAppiledOnLabel.textAlignment = .left
            self.LeaveFromLabel.textAlignment = .left
            self.LeaveToLabel.textAlignment = .left
            self.reasonTextView.textAlignment = .left
            self.FlaotReason.textAlignment = .left
            self.FloatNameLabel.textAlignment = .left
            self.FloatClassLabel.textAlignment = .left
            self.FloatLeaveToLabel.textAlignment = .left
            self.FlaotReason.textAlignment = .left
            self.FloatLeaveFromLabel.textAlignment = .left
            self.FlaotLeaveAppiledOnLabel.textAlignment = .left
            
            NameLabel.text = " : " + String(describing: selectedHistoryDict["StudentName"]!)
            ClassLabel.text = " : " + String(describing: selectedHistoryDict["Class"]!) + " - " + String(describing: selectedHistoryDict["Section"]!)
            LeaveAppiledOnLabel.text = " : " + String(describing: selectedHistoryDict["LeaveAppliedOn"]!)
            LeaveFromLabel.text = " : " + String(describing: selectedHistoryDict["LeaveFromDate"]!)
            LeaveToLabel.text = " : " + String(describing: selectedHistoryDict["LeaveTODate"]!)
            reasonTextView.text =  String(describing: selectedHistoryDict["Reason"]!)
        }
        self.FloatNameLabel.text = languageDictionary["name"] as? String
        self.FloatClassLabel.text = languageDictionary["class"] as? String
        self.FloatLeaveToLabel.text = languageDictionary["leave_to_date"] as? String
        self.FlaotReason.text = languageDictionary["leave_reason"] as? String
        self.FloatLeaveFromLabel.text = languageDictionary["leave_from_date"] as? String
        self.FlaotLeaveAppiledOnLabel.text = languageDictionary["appliedon"] as? String

        self.ApproveButton.setTitle(languageDictionary["approve"] as? String, for: .normal)
        self.DeclineButton.setTitle(languageDictionary["decline"] as? String, for: .normal)
     
    }
    
    
}
