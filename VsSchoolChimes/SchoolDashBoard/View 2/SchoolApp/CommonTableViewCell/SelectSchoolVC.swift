//
//  SelectSchoolVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 18/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class SelectSchoolVC: UIViewController,UITableViewDelegate,UITableViewDataSource,Apidelegate{
    
    @IBOutlet weak var SelectSchoolTableView: UITableView!
    var schoolNameArray:Array = [String]()
    var StandardCodeArray : NSArray = [Any]() as NSArray
    var SchoolDetailArray : NSArray = [Any]() as NSArray
    var SelectedSchoolDetailArray : NSMutableArray = []
    var GroupCodeArray:Array = [String]()
    var dicStandardCodeArray:NSDictionary = [String : Any]() as NSDictionary
    var selectedSchoolArray:Array = [String]()
    var didselectedSchoolArray:Array = [String]()
    var SegueSelectedDataArray:Array = [Any]()
    var SegueSelectedSchoolDetailArray : NSMutableArray = []
    var strCountryCode = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var strApiFrom = NSString()
    var CallerTyepString = String()
    var loginusername = String()
    var loginAsName = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        callSelectedLanguage()
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        loginusername = UserDefaults.standard.object(forKey:USERNAME) as! String
        
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        
        if(loginAsName == "Principal"){
            CallerTyepString = "M"
        }else{
            CallerTyepString = "A"
        }
        self.SelectSchoolapi()
        
    }
    
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return SchoolDetailArray.count
    }
    
    //MARK: TABLEVIEW
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSchoolTVC", for: indexPath) as! SelectSchoolTVC
        let dic = SchoolDetailArray[indexPath.row] as! NSDictionary
        
        cell.SchoolNameLabel.text = dic["SchoolName"] as? String
        
        if(SegueSelectedSchoolDetailArray.count > 0)
        {
            let compareData = SchoolDetailArray[indexPath.row] as! NSDictionary
            if(SegueSelectedSchoolDetailArray.contains(compareData))
            {
                let data :NSMutableArray = []
                for i in 0..<SegueSelectedSchoolDetailArray.count
                {
                    let dic = SegueSelectedSchoolDetailArray[i]
                    data.add(dic)
                }
                SelectedSchoolDetailArray = data
                
                
                tableView.selectRow(at: indexPath, animated: false, scrollPosition:UITableView.ScrollPosition.none)
            }
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SelectedSchoolDetailArray.add(SchoolDetailArray[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        let deselecteddata = SchoolDetailArray[indexPath.row]
        
        if(SelectedSchoolDetailArray.contains(deselecteddata)){
            SelectedSchoolDetailArray.remove(deselecteddata)
        }
    }
    
    //MARK: BUTTON ACTION
    
    @IBAction func Okaction(_ sender: Any){
        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:"comeBack"),
                object: nil,userInfo: ["SchoolDetail":SelectedSchoolDetailArray,"actionkey":"ok"])
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @IBAction func Cancelaction(_ sender: Any) {
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBack"), object: nil,userInfo: ["SchoolDetail":SegueSelectedSchoolDetailArray,"actionkey":"cancel"])
        self.dismiss(animated: false, completion: nil)
        
    }
    
    //MARK: API CALLING
    func SelectSchoolapi(){
        showLoading()
        strApiFrom = "SelectSchoolapi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SELECTSCHOOL
        
        let arrUserData : NSMutableArray = []
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["MobileNumber" : loginusername,"CallerType" : CallerTyepString, COUNTRY_CODE: strCountryCode]
        arrUserData.add(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SelectSchoolapi")
    }
    
    // MARK: API RESPONSE
    
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom.isEqual(to: "SelectSchoolapi"))
            {
                if((csData?.count)! > 0)
                {
                    SchoolDetailArray = csData!
                    for i in 0..<(csData?.count)!
                    {
                        let dicUser : NSDictionary = csData!.object(at: i) as! NSDictionary
                        
                        
                        let schoolNameString = dicUser["SchoolName"] as! String
                        if(!schoolNameString.isEmpty){
                            self.SelectSchoolTableView.reloadData()
                        }else{
                            let AlertString = dicUser["SchoolID"] as! String
                            Util.showAlert("", msg: AlertString)
                            dismiss(animated: false, completion: nil)
                        }
                        self.SelectSchoolTableView.reloadData()
                    }
                }
            }
        }else{
            Util.showAlert("", msg: strSomething)
        }
        
    }
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        // print("Error")
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
        
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
    }
    
    
}
