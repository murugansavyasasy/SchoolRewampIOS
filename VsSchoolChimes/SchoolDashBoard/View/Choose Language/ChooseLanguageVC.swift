//
//  ChooseLanguageVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MacMini2 on 04/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class ChooseLanguageVC: UIViewController ,UITableViewDelegate,UITableViewDataSource,Apidelegate {
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var chooseLanguageLabel: UILabel!
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var ChooseLanguageTableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var selectedDict : NSDictionary = NSDictionary()
    var strLanguage = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    var strCountryCode = String()
    var  strAlertString = String()
    var memeberArrayString = String()
    var arrMembersData = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.memberArray()
        if(UserDefaults.standard.object(forKey: COUNTRY_ID) != nil){
            strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_ID) as! String
        }
        self.callSelectedLanguage()
        self.mainView.layer.cornerRadius = 10
        self.mainView.layer.masksToBounds = true
        let viewHeight = self.view.frame.height
        let cellHeight = (appDelegate.LanguageArray.count * 45) + 200
        if(Int(viewHeight) >= cellHeight ){
            mainViewHeight.constant = CGFloat(cellHeight)
        }else{
            mainViewHeight.constant = viewHeight - 100
        }
        if(appDelegate.LanguageArray.count > 0){
            selectedDict = appDelegate.LanguageArray[0] as! NSDictionary
            okButton.isHidden = false
        }else{
            okButton.isHidden = true
        }
        
    }
    
    // MARK: DATAVIEW DELEAGATE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.LanguageArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseLanguageTVCell", for: indexPath) as! ChooseLanguageTVCell
        let Dict = appDelegate.LanguageArray[indexPath.row] as! NSDictionary
        cell.LanguageNameLabel.text = String(describing: Dict["Language"]!)
        if(selectedDict.isEqual(Dict))
        {
            let image = UIImage(named: "RadioSelect")! as UIImage
            cell.RadioButton.setImage(image, for: UIControl.State.normal)
        }else
        {
            let image = UIImage(named: "RadioNormal")! as UIImage
            cell.RadioButton.setImage(image, for: UIControl.State.normal)
            
        }
        if(strLanguage == "ar"){
            cell.LanguageNameLabel.textAlignment = .right
        }else{
            cell.LanguageNameLabel.textAlignment = .left
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        selectedDict = appDelegate.LanguageArray[indexPath.row] as! NSDictionary
        ChooseLanguageTableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let currentCell = tableView.cellForRow(at: indexPath) as! ChooseCountryTVCell
        let image = UIImage(named: "RadioNormal")! as UIImage
        currentCell.RadioButton.setImage(image, for: UIControl.State.normal)
    }
    
    // MARK: Button Action
    
    @IBAction func actionCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionOKButton(_ sender: Any) {
        if(Util .isNetworkConnected()){
            self.CallLanguageChangeApi()
        }else{
            Util .showAlert("", msg: strNoInternet)
        }
    }
    
    func successFlow(){
        let strLanguageCode = String(describing: selectedDict[SCRIPTCODE]!)
        UserDefaults.standard.set(strLanguageCode, forKey: SELECTED_LANGUAGE)
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name(rawValue:LANGUAGE_NOTIFICATION), object: nil)
        self.dismiss(animated: true, completion: nil)
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
                }
            } catch {
                print(error)
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.mainView.semanticContentAttribute = .forceRightToLeft
            self.ChooseLanguageTableView.semanticContentAttribute = .forceRightToLeft
            chooseLanguageLabel.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.mainView.semanticContentAttribute = .forceLeftToRight
            self.ChooseLanguageTableView.semanticContentAttribute = .forceLeftToRight
            chooseLanguageLabel.textAlignment = .left
        }
        chooseLanguageLabel.text = LangDict["choose_language"] as? String
        cancelButton.setTitle(LangDict["teacher_cancel"] as? String, for: .normal)
        okButton.setTitle(LangDict["teacher_btn_ok"] as? String, for: .normal)
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
    //MARK: API  DELEGATE
    
    func CallLanguageChangeApi()
    {
        showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self
        let baseUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_LANGUAGE_CHANGE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String

          if(appDelegate.isPasswordBind == "1"){
           }

        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
      
        let myDict:NSMutableDictionary = ["MemberData" : arrMembersData,"LanguageId": "1",COUNTRY_ID : strCountryCode]

        
        let myString = Util.convertNSDictionary(toString: myDict)
        
        Constants.printLogKey("myDict", printValue: myDict)
        Constants.printLogKey("requestStringer", printValue: requestStringer)
        apiCall.nsurlConnectionFunction(requestString, myString, "deviceToken")
    }
    
    
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!){
        hideLoading()
        
        Constants.printLogKey("csData", printValue: csData)
        if(csData != nil){
            var Message = String()
            var Status = String()
            
            if((csData?.count)! > 0){
                let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                Status = String(describing: dicUser["Status"]!)
                Message = String(describing: dicUser["Message"]!)
                strAlertString = Message
                if(Status == "1"){
                    assignParentStaffIDS(selectedDict: dicUser)
                  
                    appDelegate.MenuNmaes =  String(describing: dicUser["menu_name"]!)
                    
                    self.successFlow()
                }else{
                    Util .showAlert("", msg: Message)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }else{
            Util .showAlert("", msg: strSomething);
        }
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
    
    func assignParentStaffIDS(selectedDict : NSDictionary){
        
        let strParentID  : String = String(describing: selectedDict[IS_PARENT_ID]!)
        let parentIDArray = strParentID.components(separatedBy: ",") as NSArray
        Constants.printLogKey("parentIDArray", printValue: parentIDArray)
        
        let strStaffID  : String = String(describing: selectedDict[IS_STAFF_ID]!)
        let staffIDArray = strStaffID.components(separatedBy: ",") as NSArray
        Constants.printLogKey("staffIDArray", printValue: staffIDArray)
        
        let strAdminID  : String = String(describing: selectedDict[IS_ADMIN_ID]!)
        let adminIDArray = strAdminID.components(separatedBy: ",") as NSArray
        Constants.printLogKey("adminIDArray", printValue: adminIDArray)
        
        let strGroupHeadID  : String = String(describing: selectedDict[IS_GROUPHEAD_ID]!)
        let groupHeadIDArray = strGroupHeadID.components(separatedBy: ",") as NSArray
        Constants.printLogKey("groupHeadIDArray", printValue: groupHeadIDArray)
        
        let strPrincipalID  : String = String(describing: selectedDict[IS_PRINCIPLE_ID]!)
        let  principleIDArray = strPrincipalID.components(separatedBy: ",") as NSArray
        Constants.printLogKey("principleIDArray", printValue: principleIDArray)
        
        UserDefaults.standard.set(parentIDArray, forKey: PARENT_ARRAY_INDEX)
        UserDefaults.standard.set(staffIDArray, forKey: STAFF_ARRAY_INDEX)
        UserDefaults.standard.set(principleIDArray, forKey: PRINCIPLE_ARRAY_INDEX)
        UserDefaults.standard.set(adminIDArray, forKey: ADMIN_ARRAY_INDEX)
        UserDefaults.standard.set(groupHeadIDArray, forKey: GROUPHEAD_ARRAY_INDEX)
        
        //
    }
    //    appDelegate.LoginParentDetailArray = ChildDetailsArray
    func memberArray(){
        var idArray : NSMutableArray = NSMutableArray()
//
        
        for i in 0..<appDelegate.LoginParentDetailArray.count{
            let Dict : NSDictionary =  appDelegate.LoginParentDetailArray[i] as! NSDictionary
            idArray.add(String(describing: Dict["ChildID"]!))
             //   {"MemberData":[{"type":"parent","id":"5191710","schoolid":"5512"}],"LanguageId":"1","CountryID":"1"}
            let dicMembers = ["type" : "parent",
                              "id" : String(describing: Dict["ChildID"]!),
                            "schoolid" : String(describing: Dict["SchoolID"]!)
                            ]
            
            arrMembersData.add(dicMembers)
                              
            
        }
        for i in 0..<appDelegate.LoginSchoolDetailArray.count{
            let Dict : NSDictionary =  appDelegate.LoginSchoolDetailArray[i] as! NSDictionary
            idArray.add(String(describing: Dict["StaffID"]!))
            let dicMembers = ["type" : "staff",
                              "id" : String(describing: Dict["StaffID"]!),
                            "schoolid" : String(describing: Dict["SchoolID"]!)
                            ]
            
            arrMembersData.add(dicMembers)
        }
        
        memeberArrayString = idArray.componentsJoined(by: "~")
        print(memeberArrayString)
        
    }
    
}
