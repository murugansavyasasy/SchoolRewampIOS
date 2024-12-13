//
//  PlayYouTubeVideoVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MacMini2 on 27/06/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class PlayYouTubeVideoVC: UIViewController , UITableViewDelegate, UITableViewDataSource,Apidelegate {
    @IBOutlet weak var YoutubeVideoTableView: UITableView!
    var arrVideoData: NSArray = []
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var languageDictionary = NSDictionary()
    let UtilObj = UtilClass()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var strApiFrom = String()
    var ChildIDString = String()
    var strCountryCode = String()
    var strLanguage = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.callSelectedLanguage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.loadViewData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return arrVideoData.count
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat = 0
        if(UIDevice.current.userInterfaceIdiom == .pad){
            height =  470
        }else{
            height =  280
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayYouTubeVideoTVCell", for: indexPath) as! PlayYouTubeVideoTVCell
        cell.backgroundColor = UIColor.clear
        return cell
        
    }
    
    //MARK: Button Action
    @IBAction func actionBack(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: API CALLING
    func GetStudentYoutubeVideoApiCall()
    {
        showLoading()
        strApiFrom = "GetYouTubeVideoApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + PARENT_LIBRARY_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["StudentID" : ChildIDString,"Option" : OPTION_LIBRARY_METHOD, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetYouTubeVideoApi")
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom.isEqual("GetYouTubeVideoApi"))
                
            {
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                if let CheckedArray = csData as? NSArray
                {
                    if(CheckedArray.count > 0)
                    {
                        let dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        if let val =  dict["RefBookID"] {
                            let strVal:String = String(describing: val)
                            
                            if(strVal == "-2")
                            {
                                if let alrtValue =  dict["BookName"] {
                                    self.AlerMessage(alrtMessage: alrtValue as? String ?? strNoRecordAlert)
                                }else{
                                    self.AlerMessage(alrtMessage: strNoRecordAlert)
                                }
                                
                            }else{
                                self.AlerMessage(alrtMessage: strNoRecordAlert)
                            }
                            
                        }else
                        {
                            arrVideoData = CheckedArray
                            YoutubeVideoTableView.reloadData()
                        }
                        
                    }else
                    {
                        self.AlerMessage(alrtMessage: strNoRecordAlert)
                    }
                    
                }else
                {
                    self.AlerMessage(alrtMessage: strNoRecordAlert)
                }
            }
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
    }
    
    func AlerMessage(alrtMessage : String)
    {
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: alrtMessage, preferredStyle: .alert)
        
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
        self.navigationController?.navigationBar.barTintColor = UtilObj.SCHOOL_NAV_BAR_COLOR
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
            self.YoutubeVideoTableView.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.YoutubeVideoTableView.semanticContentAttribute = .forceLeftToRight
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
        
    }
    
    func loadViewData(){
        
        ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        if(Util .isNetworkConnected())
        {
        }
        else
        {
            Util.showAlert("", msg: NO_INTERNET)
        }
        YoutubeVideoTableView.reloadData()
    }
    
}
