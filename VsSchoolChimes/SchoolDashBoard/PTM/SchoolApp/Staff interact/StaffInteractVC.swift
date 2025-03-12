//
//  StaffInteractVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 12/06/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffInteractVC: UIViewController ,UITableViewDelegate,UITableViewDataSource,Apidelegate,UISearchBarDelegate{
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var search_bar: UISearchBar!
    
    let UtilObj = UtilClass()
    var strCountryCode = String()
    var SchoolId  = String()
    var StaffId  = String()
    var selectedStaffID  = String()
    var selectedSchoolDictionary = NSDictionary()
    var stdSubjectArray = NSMutableArray()
    var languageDictionary = NSDictionary()
    var SchoolDetailDict = NSDictionary()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var hud : MBProgressHUD = MBProgressHUD()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("STAFFINTREACTViewDidLoad")
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        loadViewData()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Staff Details"
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.title = ""
    }
    func loadViewData(){
        
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        let isPrincipal = appDelegate.isPrincipal as NSString
        
        print("isPrincipal",isPrincipal)
        print("isPrincipalisEqual",isPrincipal .isEqual(to: "true"))
        print("SchoolDetailDict",SchoolDetailDict)
        
        if(appDelegate.LoginSchoolDetailArray.count > 1)
        {
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        }else{
            selectedSchoolDictionary  = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        }
        
        
        callSelectedLanguage()
        
    }
    
    // MARK: - Textfield delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - TableView delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stdSubjectArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return 90
        }else{
            return 60
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageTVCell", for: indexPath) as! TextMessageTVCell
        cell.backgroundColor = UIColor.clear
        let Dict = stdSubjectArray[indexPath.row] as! NSDictionary
        cell.SchoolNameLbl.text = String(describing: Dict["StaffName"]!)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Dict = stdSubjectArray[indexPath.row] as! NSDictionary
        selectedStaffID = String(describing: Dict["StaffId"]!)
        self.performSegue(withIdentifier: "showSubjectDetail", sender: self)
    }
    
    //MARK: API CALLING
    
    func GetAllStaffListAPICalling(){
        showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_ALL_STAFFLIST
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_ALL_STAFFLIST
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["DialerId" : StaffId,"SchoolId" : SchoolId , COUNTRY_CODE: strCountryCode]
        
        let myString = Util.convertNSDictionary(toString: myDict)
        print("requestString",requestString)
        print("myDictmyDict",myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetStaffList")
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        print(csData)
        hideLoading()
        if(csData != nil)
        {
            UtilObj.printLogKey(printKey: "CSData", printingValue: csData!)
            if let arrayDatas = csData as? NSArray
            {
                if(arrayDatas.count > 0){
                    let  dicResponse = arrayDatas[0] as! NSDictionary
                    let alrtMessage = String(describing: dicResponse["StaffName"]!)
                    
                    let staffId = String(describing: dicResponse["StaffId"]!)
                    let StarID = String(describing: dicResponse["StaffType"]!)
                    
                    if(!staffId.isEqual("0")){
                        stdSubjectArray = NSMutableArray(array: arrayDatas)
                        
                    }else{
                        self.AlerMessage(alrtStr: alrtMessage)
                    }
                    myTableView.reloadData()
                }else{
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
    
    func AlerMessage(alrtStr : String){
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: alrtStr, preferredStyle: .alert)
        let okAction = UIAlertAction(title:languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
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
                }else{
                    GetAllStaffListAPICalling()
                }
            } catch {
                GetAllStaffListAPICalling()
            }
        }
    }
    
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDictionary = LangDict
        
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
        GetAllStaffListAPICalling()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("SEGUEStaff",selectedStaffID)
        print("SEGUESChool",SchoolId)
        if (segue.identifier == "showSubjectDetail"){
            let segueid = segue.destination as! StaffChatInteractDetailVC
            segueid.StaffId = self.selectedStaffID
            segueid.SchoolId = self.SchoolId
            
        }
    }
    
    
}
