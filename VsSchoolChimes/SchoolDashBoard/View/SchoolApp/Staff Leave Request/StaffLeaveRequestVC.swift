//
//  StaffLeaveRequestVC.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 16/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffLeaveRequestVC: UIViewController ,UITableViewDelegate,UITableViewDataSource,Apidelegate {
    
    @IBOutlet weak var LeaveHistoryTableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var WaitingLabel: UILabel!
    @IBOutlet weak var DeclineLabel: UILabel!
    @IBOutlet weak var ApproveLabel: UILabel!
    var AlertString = String()
    var ChildIDString = String()
    var SchoolIDString = String()
    var strLanguage = String()
    var LeaveHistoryArray : NSArray = NSArray()
    var selectedDict : NSDictionary = NSDictionary()
    var languageDictionary = NSDictionary()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(StaffLeaveRequestVC.callNotification), name: NSNotification.Name(rawValue: "comeBackFromPopup"), object:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("didappear")
    }
    
    // MARK: DATAVIEW DELEAGATE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LeaveHistoryArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 310
        }else{
            return 230
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaveHistoryTVCell", for: indexPath) as! LeaveHistoryTVCell
        cell.backgroundColor = UIColor.clear
        let Dict = LeaveHistoryArray[indexPath.row] as! NSDictionary
        if(strLanguage == "ar"){
            cell.cellView.semanticContentAttribute = .forceRightToLeft
            cell.NameLabel.textAlignment = .right
            cell.ClassLabel.textAlignment = .right
            cell.LeaveAppiledOnLabel.textAlignment = .right
            cell.LeaveFromLabel.textAlignment = .right
            cell.LeaveToLabel.textAlignment = .right
            cell.reasonLabel.textAlignment = .right
            cell.FloatreasonLabel.textAlignment = .right
            cell.FloatNameLabel.textAlignment = .right
            cell.FloatClassLabel.textAlignment = .right
            cell.FloatLeaveToLabel.textAlignment = .right
            cell.FloatreasonLabel.textAlignment = .right
            cell.FloatLeaveFromLabel.textAlignment = .right
            cell.FloatLeaveAppiledOnLabel.textAlignment = .right
            cell.NameLabel.text = String(describing: Dict["StudentName"]!) + " : "
            cell.ClassLabel.text = String(describing: Dict["Class"]!) + " - " + String(describing: Dict["Section"]!)  + " : "
            cell.LeaveAppiledOnLabel.text =  String(describing: Dict["LeaveAppliedOn"]!)  + " : "
            cell.LeaveFromLabel.text =  String(describing: Dict["LeaveFromDate"]!)  + " : "
            cell.LeaveToLabel.text = String(describing: Dict["LeaveTODate"]!) + " : "
            cell.reasonLabel.text =  String(describing: Dict["Reason"]!)
        }else{
            cell.NameLabel.textAlignment = .left
            cell.ClassLabel.textAlignment = .left
            cell.LeaveAppiledOnLabel.textAlignment = .left
            cell.LeaveFromLabel.textAlignment = .left
            cell.LeaveToLabel.textAlignment = .left
            cell.reasonLabel.textAlignment = .left
            cell.FloatreasonLabel.textAlignment = .left
            cell.FloatNameLabel.textAlignment = .left
            cell.FloatClassLabel.textAlignment = .left
            cell.FloatLeaveToLabel.textAlignment = .left
            cell.FloatreasonLabel.textAlignment = .left
            cell.FloatLeaveFromLabel.textAlignment = .left
            cell.FloatLeaveAppiledOnLabel.textAlignment = .left
            cell.cellView.semanticContentAttribute = .forceLeftToRight
            cell.NameLabel.text = " : " + String(describing: Dict["StudentName"]!)
            cell.ClassLabel.text = " : " + String(describing: Dict["Class"]!) + " - " + String(describing: Dict["Section"]!)
            cell.LeaveAppiledOnLabel.text = " : " + String(describing: Dict["LeaveAppliedOn"]!)
            cell.LeaveFromLabel.text = " : " + String(describing: Dict["LeaveFromDate"]!)
            cell.LeaveToLabel.text = " : " + String(describing: Dict["LeaveTODate"]!)
            cell.reasonLabel.text =  String(describing: Dict["Reason"]!)
        }
        
        
        cell.FloatNameLabel.text = languageDictionary["name"] as? String
        cell.FloatClassLabel.text = languageDictionary["class"] as? String
        cell.FloatLeaveToLabel.text = languageDictionary["leave_to_date"] as? String
        cell.FloatreasonLabel.text = languageDictionary["leave_reason"] as? String
        cell.FloatLeaveFromLabel.text = languageDictionary["leave_from_date"] as? String
        cell.FloatLeaveAppiledOnLabel.text = languageDictionary["appliedon"] as? String
        
        let strStatus : String = String(describing: Dict["Status"]!)
        if(strStatus == "2"){
            cell.statusImageView.image = UIImage(named: "close")
        }else if(strStatus == "1"){
            cell.statusImageView.image = UIImage(named: "tick")
        }else{
            cell.statusImageView.image = UIImage(named: "info")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDict = LeaveHistoryArray[indexPath.row] as! NSDictionary
        self.performSegue(withIdentifier: "StaffLeaveRequestPopupSegue", sender: self)
    }
    
    //MARK: API CALLING
    
    func GetLeaveHistoryApiCalling(){
        showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_LEAVE_REQUEST
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_LEAVE_REQUEST
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ReqId" : ChildIDString,"type" : "staff", COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        print("LEAVEREQUESTmyString",myString)
        print("LEAVEREQUESTmyDict",myDict)
        print("requestStringer",requestStringer)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetLeaveRequestApi")
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if let CheckedArray = csData as? NSArray
            {
                if(CheckedArray.count > 0)
                {
                    let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                    if let val =  dict["LeaveId"] {
                        let strVal:String = String(describing: val)
                        AlertString  = String(describing: dict["Reason"]!)
                        print(strVal)
                        if(strVal == "0")
                        {
                            self.AlerMessage(alrtStr: AlertString)
                        }
                        
                        else
                        {
                            LeaveHistoryArray = CheckedArray
                            
                            LeaveHistoryTableView.reloadData()
                        }
                        
                    }else
                    {
                        self.AlerMessage(alrtStr: strNoRecordAlert)
                    }
                    
                }else
                {
                    self.AlerMessage(alrtStr: strNoRecordAlert)
                }
                
            }else
            {
                self.AlerMessage(alrtStr: strNoRecordAlert)
            }
            
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
        hideLoading()
        
    }
    
    func AlerMessage(alrtStr : String)
    {
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: alrtStr, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
    }
    
    func navTitle()
    {
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        titleLabel.textColor = UIColor (red:0.0/255.0, green:183.0/255.0, blue: 190.0/255.0, alpha: 1)
        let secondWord =  languageDictionary["leave"] as? String
        let thirdWord   = languageDictionary["requesttttt"] as? String
        let comboWord = (secondWord ?? "Leave" ) + " " + (thirdWord ?? "Request")
        let attributedText = NSMutableAttributedString(string:comboWord)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.white]
        let range = NSString(string: comboWord).range(of: secondWord ?? "Leave")
        attributedText.addAttributes(attrs, range: range)
        titleLabel.attributedText = attributedText
        self.navigationItem.titleView = titleLabel
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "StaffLeaveRequestPopupSegue"){
            let segueid = segue.destination as! StaffLeaveRequestPopupVC
            segueid.selectedHistoryDict = selectedDict
        }
    }
    
    @objc func callNotification(notification:Notification) -> Void {
        print("Notification Comnebback")
        if(Util .isNetworkConnected()){
            self.GetLeaveHistoryApiCalling()
        }
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
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        
        ApproveLabel.text = LangDict["approved"] as? String
        DeclineLabel.text = LangDict["declined"] as? String
        WaitingLabel.text = LangDict["waiting_for_approval"] as? String
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
        self.loadViewData()
        
    }
    
    func loadViewData(){
        self.title = languageDictionary["leave_request"] as? String
        if(appDelegate.LoginSchoolDetailArray.count > 0)
        {
            let dict:NSDictionary = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            ChildIDString = String(describing: dict["StaffID"]!)
            SchoolIDString = String(describing: dict["SchoolID"]!)
            if(Util .isNetworkConnected())
            {
                self.GetLeaveHistoryApiCalling()
            }
            else
            {
                Util.showAlert("", msg: strNoInternet)
            }
        }
    }
    
    
}
