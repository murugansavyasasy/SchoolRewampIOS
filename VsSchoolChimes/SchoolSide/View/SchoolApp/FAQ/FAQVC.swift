//
//  FAQVC.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 15/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class FAQVC: UIViewController,Apidelegate,UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    var AlertString = String()
    var ChildIDString = String()
    var SchoolIDString = String()
    var fromVC = String()
    var webURl = String()
    var userType =  String()
    var Dict : NSDictionary = NSDictionary()
    
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var languageDictionary = NSDictionary()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        self.title = "FAQ"
        self.callSelectedLanguage()
        if(fromVC == "Parent"){
            if(appDelegate.SchoolDetailDictionary["ChildID"] != nil){
                ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
                SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
            }else{
                ChildIDString = String(describing: Dict["ChildID"]!)
                SchoolIDString = String(describing: Dict["SchoolID"]!)
            }
            userType = "3"
        }else{
            if(appDelegate.LoginSchoolDetailArray.count > 0)
            {
                let dict:NSDictionary = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
                ChildIDString = String(describing: dict["StaffID"]!)
                SchoolIDString = String(describing: dict["SchoolID"]!)
            }
            userType = "2"
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if(Util .isNetworkConnected())
        {
            self.GetFAQDetailApiCalling()
        }
        else
        {
            Util .showAlert("", msg: strNoInternet)
        }
    }
    
    func loadWebURl(){
        showLoading()
        let url = URL(string: webURl)
        webView.loadRequest(URLRequest(url: url!))
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hideLoading()
    }
    //MARK: API CALLING
    
    func GetFAQDetailApiCalling()
    {
        showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_FAQ + ChildIDString + GET_USERTYPE + userType
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_FAQ + ChildIDString + GET_USERTYPE + userType
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        print(requestStringer)
        
        apiCall.getFunction(requestStringer, "GetFAQApi")
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            UtilObj.printLogKey(printKey: "CSData", printingValue: csData!)
            if let CheckedArray = csData as? NSArray
            {
                if(CheckedArray.count > 0)
                {
                    let dict : NSDictionary = CheckedArray.mutableCopy() as! NSDictionary
                    if let val =  dict["Status"] {
                        let strVal:String = String(describing: val)
                        AlertString  = String(describing: dict["Message"]!)
                        
                        if(strVal == "1")
                        {
                            webURl = AlertString
                            loadWebURl()
                        }else{
                            self.AlerMessage()
                        }
                        
                    }else
                    {
                        self.AlerMessage()
                    }
                    
                }else
                {
                    self.AlerMessage()
                }
            }else{
                Util.showAlert("", msg: strSomething)
            }
        }else{
            Util.showAlert("", msg: strSomething)
        }
        hideLoading()
        
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
    
    func AlerMessage()
    {
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: AlertString, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
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
        languageDictionary = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
    }
}
