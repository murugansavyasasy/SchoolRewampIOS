//
//  PrincipalNewStandardGroupVC1.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 05/07/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class PrincipalNewStandardGroupVC1: UIViewController,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,Apidelegate {
    
    
    @IBOutlet weak var groupCollectionView: UICollectionView!
    @IBOutlet weak var selectEntireSchoolButton: UIButton!
    @IBOutlet weak var SendButton: UIButton!
    //SendButton
    @IBOutlet weak var standardCollectionView: UICollectionView!
    
    
    
    var SelectedGroups = NSMutableArray()
    var SelectedStandards = NSMutableArray()
    var enable = Bool()
    var disableView = UIView()
    var disableView1 = UIView()
    var fromViewController = NSString()
    var isEntireSchool = NSString()
    var apiCallFrom = NSString()
    var SchoolID = NSString()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var groupsArray = NSArray()
    var standardsArray = NSArray()
    var standardCodeArray = NSMutableArray()
    var groupCodeArray = NSMutableArray()
    var selectedStandardCodeArray = NSMutableArray()
    var selectedGroupCodeArray = NSMutableArray()
    var selectedSchoolDictionary = NSMutableDictionary()
    var strCountryCode = String()
    var VoiceData : NSData? = nil
    var urlData: URL?
    var imageToSend = UIImage()
    var imageData : NSData? = nil
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SendButton.layer.cornerRadius = 5
        SendButton.layer.masksToBounds = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.callSelectedLanguage()
        self.config()
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        if(self.fromViewController .isEqual(to: "VoiceToParents"))
        {
            self.GetSchoolStrengthBySchoolID(schoolID: self.SchoolID)
        }
        else if(self.fromViewController .isEqual(to: "TextToParents"))
        {
            self.GetSchoolStrengthBySchoolID(schoolID: self.SchoolID)
        }
        else if(self.fromViewController .isEqual(to: "SchoolEvents"))
        {
            self.GetSchoolStrengthBySchoolID(schoolID: self.SchoolID)
        }
        else if(self.fromViewController .isEqual(to: "SendImage"))
        {
            self.GetSchoolStrengthBySchoolID(schoolID: self.SchoolID)
        }
        
    }
    
    @IBAction func actionBackButton (_ sender:UIButton){
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionSendButton(_ sender: UIButton)
    {
        if(self.fromViewController .isEqual(to: "VoiceToParents"))
        {
            self.callSendVoiceToGroupsAndStandards()
        }
        else if(self.fromViewController .isEqual(to: "TextToParents"))
        {
            self.callSendSMSToGroupsAndStandards()
        }
        else if(self.fromViewController .isEqual(to: "SchoolEvents"))
        {
            self.callSchoolEvents()
        }
        else if(self.fromViewController .isEqual(to: "SendImage"))
        {
            self.callSendImageToGroupsAndStandards()
        }
    }
    
    func config()
    {
        
        disableView.backgroundColor = UIColor.darkGray
        disableView.alpha = 0.80
        disableView1.backgroundColor = UIColor.darkGray
        disableView1.alpha = 0.80
        groupCollectionView.delegate = self;
        groupCollectionView.dataSource = self;
        standardCollectionView.delegate = self;
        standardCollectionView.dataSource = self;
        enable = true
        isEntireSchool = "T"
        selectEntireSchoolButton.isSelected = true
        standardCollectionView.reloadData()
        groupCollectionView.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if(enable == true)
        {
            standardCollectionView.addSubview(disableView)
            groupCollectionView.addSubview(disableView1)
        }
        else{
            disableView.removeFromSuperview()
            disableView1.removeFromSuperview()
        }
        if(collectionView == standardCollectionView)
        {
            return 1
        }
        else
        {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == standardCollectionView)
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return CGSize(width: (standardCollectionView.frame.size.width)-20, height: 50)
            }else{
                return CGSize(width: (standardCollectionView.frame.size.width)-20, height: 30)
            }
        }
        else
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return CGSize(width: (groupCollectionView.frame.size.width)-20, height: 50)
            }else{
                
                return CGSize(width: (groupCollectionView.frame.size.width)-20, height: 30)
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(collectionView == standardCollectionView)
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                disableView.frame = CGRect(x: 0 , y:0, width:standardCollectionView.frame.size.width, height : standardCollectionView.frame.size.height * 50)
            }else
            {
                disableView.frame = CGRect(x: 0 , y:0, width:standardCollectionView.frame.size.width, height : standardCollectionView.frame.size.height * 30)
            }
            
            
            
            return standardsArray.count
        }else{
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                disableView1.frame = CGRect(x: 0 , y:0, width:groupCollectionView.frame.size.width, height : groupCollectionView.frame.size.height * 50)
            }else
            {
                disableView1.frame = CGRect(x: 0 , y:0, width:groupCollectionView.frame.size.width, height : groupCollectionView.frame.size.height * 30)
            }
            return groupsArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if(collectionView == standardCollectionView)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellStandards", for: indexPath) as! StandardGroupCVCell
            var i = Int()
            let standardDict = standardsArray.object(at: indexPath.row) as? NSDictionary
            
            i = indexPath.row+1
            cell.Checkbox.tag = (i)*(-1)
            cell.NumberLabel.text = standardDict?.object(forKey: "StdName") as? String
            cell.Checkbox.addTarget(self, action: #selector(actionCheckBoxButton(sender:)), for: .touchUpInside)
            
            let targetDictionary = NSMutableDictionary()
            targetDictionary["TargetCode"] = standardDict?.object(forKey: "StdCode")
            if(selectedStandardCodeArray .contains(targetDictionary))
            {
                cell.Checkbox.isSelected = true
            }
            else{
                cell.Checkbox.isSelected = false
            }
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellGroups", for: indexPath) as! StandardGroupCVCell
            let groupDict = groupsArray.object(at: indexPath.row) as? NSDictionary
            cell.Checkbox1.tag = (indexPath.row+1)*(1)
            cell.Checkbox1.addTarget(self, action: #selector(actionCheckBoxButton(sender:)), for: .touchUpInside)
            cell.NumberLabel.text = groupDict?.object(forKey: "GroupName") as? String
            let targetDictionary = NSMutableDictionary()
            targetDictionary["TargetCode"] = groupDict?.object(forKey: "GroupId")
            if(selectedGroupCodeArray .contains(targetDictionary))
            {
                cell.Checkbox1.isSelected = true
            }
            else{
                cell.Checkbox1.isSelected = false
            }
            
            return cell
        }
    }
    
    @IBAction func actionSelectEntireSchoolButton(sender: UIButton) {
        if(enable == true)
        {
            enable = false
            selectEntireSchoolButton.isSelected = false
            isEntireSchool = "F"
            standardCollectionView.reloadData()
            groupCollectionView.reloadData()
        }
        else{
            enable = true
            selectEntireSchoolButton.isSelected = true
            isEntireSchool = "T"
            standardCollectionView.reloadData()
            groupCollectionView.reloadData()
        }
    }
    
    @IBAction func actionCheckBoxButton (sender: UIButton)
    {
        if(sender.tag > 0)
        {
            var i = Int()
            i =  (sender.tag) * (1)
            i = i - 1
            
            let groupDict = groupsArray.object(at: i) as? NSDictionary
            
            let targetDictionary = NSMutableDictionary()
            targetDictionary["TargetCode"] = groupDict?.object(forKey: "GroupId")
            
            if(sender .isSelected == false)
            {
                selectedGroupCodeArray.add(targetDictionary)
            }else{
                selectedGroupCodeArray.remove(targetDictionary)
            }
            groupCollectionView.reloadData()
            
        }else{
            var i = Int()
            i =  (sender.tag) * (-1)
            i = i - 1
            
            let standardDict = standardsArray.object(at: i) as? NSDictionary
            
            let targetDictionary = NSMutableDictionary()
            targetDictionary["TargetCode"] = standardDict?.object(forKey: "StdCode")
            
            if(sender .isSelected == false)
            {
                selectedStandardCodeArray.add(targetDictionary)
            }else{
                selectedStandardCodeArray.remove(targetDictionary)
            }
            standardCollectionView.reloadData()
        }
    }
    
    //MARK: Api Calling
    
    func GetSchoolStrengthBySchoolID(schoolID : NSString)
    {
        apiCallFrom = "GetSchoolStrengthBySchoolID"
        self.showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_SCHOOL_STRENGTH_DETAIL
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_SCHOOL_STRENGTH_DETAIL
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolId" : schoolID, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetSchoolStreng")
    }
    
    func callSendVoiceToGroupsAndStandards()
    {
        apiCallFrom = "SendVoiceToGroupsAndStandards"
        self.showLoading()
        VoiceData = NSData(contentsOf: self.urlData!)
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        print("DefaultsKeys.SelectInstantSchedule",DefaultsKeys.SelectInstantSchedule)
        let defaults = UserDefaults.standard
        var initialTime = DefaultsKeys.initialDisplayDate
        var doNotDial =  DefaultsKeys.doNotDialDisplayDate
        print("initialTime",initialTime)
        print("doNotDial",doNotDial)
        print("doNotDialDateArr",DefaultsKeys.dateArr)
        
        if DefaultsKeys.SelectInstantSchedule == 0 {
            let requestStringer = baseUrlString! + SendVoiceToGroupsAndStandards
            print("requestStringerOL56tcervgerhvy",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            self.selectedSchoolDictionary["isEntireSchool"] = isEntireSchool
            self.selectedSchoolDictionary["StdCode"] = selectedStandardCodeArray
            self.selectedSchoolDictionary["GrpCode"] = selectedGroupCodeArray
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.callPassVoiceParms(requestString, myString, "VoiceToParents", VoiceData as Data?)
            
            
            
            
            
        }else {
            
            let requestStringer = baseUrlString! + ScheduleSendVoiceToGroupsAndStandards
            print("requestStringercerrevOL56ty",requestStringer)
            
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            self.selectedSchoolDictionary["isEntireSchool"] = isEntireSchool
            self.selectedSchoolDictionary["StdCode"] = selectedStandardCodeArray
            self.selectedSchoolDictionary["GrpCode"] = selectedGroupCodeArray
            self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
            self.selectedSchoolDictionary["StartTime"] = initialTime
            self.selectedSchoolDictionary["EndTime"] = doNotDial
            self.selectedSchoolDictionary["Dates"] = DefaultsKeys.dateArr
            
            
            
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
            apiCall.callPassVoiceParms(requestString, myString, "VoiceToParents", VoiceData as Data?)
            
            
            
        }
        
    }
    
    func callSendImageToGroupsAndStandards()
    
    {
        apiCallFrom = "SendImageToGroupsAndStandards"
        imageData = (imageToSend.pngData() as NSData?)!
        self.showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SendImageToGroupsAndStandards
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        self.selectedSchoolDictionary["isEntireSchool"] = isEntireSchool
        self.selectedSchoolDictionary["StdCode"] = selectedStandardCodeArray
        self.selectedSchoolDictionary["GrpCode"] = selectedGroupCodeArray
        self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
        apiCall.callPassImageParms(requestString, myString, "SendImageAsPrincipalToSelectedClass", imageData as Data?)
    }
    
    func callSendSMSToGroupsAndStandards()
    {
        apiCallFrom = "SendSMSToGroupsAndStandards"
        self.showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SendSMSToGroupsAndStandards
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        self.selectedSchoolDictionary["isEntireSchool"] = isEntireSchool
        self.selectedSchoolDictionary["StdCode"] = selectedStandardCodeArray
        self.selectedSchoolDictionary["GrpCode"] = selectedGroupCodeArray
        self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
        apiCall.nsurlConnectionFunction(requestString, myString, "TextToParents")
    }
    
    func callSchoolEvents()
    {
        apiCallFrom = "SchoolEvents"
        self.showLoading()
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + ManageSchoolEvents
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        self.selectedSchoolDictionary["isEntireSchool"] = isEntireSchool
        self.selectedSchoolDictionary["StdCode"] = selectedStandardCodeArray
        self.selectedSchoolDictionary["GrpCode"] = selectedGroupCodeArray
        self.selectedSchoolDictionary[COUNTRY_CODE] = strCountryCode
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: self.selectedSchoolDictionary)
        apiCall.nsurlConnectionFunction(requestString, myString, "SchoolEvents")
    }
    
    //MARK: Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if((csData?.count)! > 0){
                let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                
                if(apiCallFrom .isEqual(to: "GetSchoolStrengthBySchoolID"))
                {
                    if let CheckStandardArray = dicUser.object(forKey: "Standards") as? NSArray
                    {
                        standardsArray = CheckStandardArray
                        
                    }
                    if let CheckGroupArray = dicUser.object(forKey: "Groups") as? NSArray
                    {
                        groupsArray = CheckGroupArray
                    }
                    groupCollectionView.reloadData()
                    standardCollectionView.reloadData()
                    
                    
                }else{
                    if let status = dicUser["Status"] as? NSString
                    {
                        let Status = status
                        let Message = dicUser["Message"] as! NSString
                        
                        if(Status .isEqual(to: "1")){
                            Util.showAlert("", msg: Message as String?)
                            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        }else{
                            Util.showAlert("", msg: Message as String?)
                        }
                    }
                }
            }
        }else{
            Util.showAlert("", msg: strSomething)
        }
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util .showAlert("", msg: strSomething);
    }
    
    //MARK: Loading Indicator
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        
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
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
    
}
