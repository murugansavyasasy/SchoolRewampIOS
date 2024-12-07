//
//  AbsenteesDeteViceVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 13/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class AbsenteesDeteViceVC: UIViewController,UITableViewDelegate,UITableViewDataSource,Apidelegate {
    @IBOutlet var myTableView: UITableView!
    @IBOutlet var NoRecordFoundLabel: UILabel!
    
    var SchoolIDString = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var strApiFrom = NSString()
    var AbsentenceDateViceArray = NSArray()
    var SelectedAbsentenceDateViceArray = NSArray()
    let UtilObj = UtilClass()
    var strLanguage = String()
    var strCountryCode = String()
    var LanguageDict = NSDictionary()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        NoRecordFoundLabel.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        
        self.callSelectedLanguage()
        
        if(AbsentenceDateViceArray.count == 0)
        {
            if(UtilObj.IsNetworkConnected())
            {
                self.GetDateViceAttendanceApiCalling()
            }
            else
            {
                Util.showAlert("", msg:strNoInternet )
            }
        }
    }
    
    //MARK: TABLEVIEW DELEGATE
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 98
        }else{
            return 78
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return AbsentenceDateViceArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AbsenteesDateViceTVCell", for: indexPath) as! AbsenteesDateViceTVCell
        cell.backgroundColor = UIColor.clear
        let Dict = AbsentenceDateViceArray[indexPath.row] as! NSDictionary
        cell.Datelabel.text = String(describing: Dict["Date"]!)
        cell.DayLabel.text = String(describing: Dict["Day"]!)
        cell.CountLabel.text = String(describing: Dict["TotalAbsentees"]!)
        if(strLanguage == "ar"){
            cell.Datelabel.textAlignment = .right
            cell.DayLabel.textAlignment = .right
        }else{
            cell.Datelabel.textAlignment = .left
            cell.DayLabel.textAlignment = .left
        }
        return cell;
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Dict = AbsentenceDateViceArray[indexPath.row] as! NSDictionary
        SelectedAbsentenceDateViceArray = Dict["ClassWise"] as! NSArray
        performSegue(withIdentifier: "ViewAbsenteesRecordSegue", sender: self)
    }
    
    func TitleForNavigation(){
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        titleLabel.textColor = UIColor (red:166.0/255.0, green: 114.0/255.0, blue: 155.0/255.0, alpha: 1)
        let secondWord : String = LanguageDict["home_absentees"] as? String ?? "Absentees"//"Absentees "
        let thirdWord : String   = LanguageDict["report"] as? String ?? "Report"//"Report"
        let comboWord = secondWord + " " + thirdWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.white]
        let range = NSString(string: comboWord).range(of: secondWord)
        attributedText.addAttributes(attrs, range: range)
        
        titleLabel.attributedText = attributedText
        self.navigationItem.titleView = titleLabel
    }
    //MARK: API CALLING
    func GetDateViceAttendanceApiCalling(){
        showLoading()
        strApiFrom = "GetDateViceAttendanceApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_DATEVICE_ATTENDANCE_DETAIL
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_DATEVICE_ATTENDANCE_DETAIL
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        UtilObj.printLogKey(printKey: "REq", printingValue: requestString!)
        
        let myDict:NSMutableDictionary = ["SchoolId" : SchoolIDString]
        
        let myString = Util.convertDictionary(toString: myDict)
        UtilObj.printLogKey(printKey: "csData", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "GetDateViceAttendanceApi")
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom.isEqual(to: "GetDateViceAttendanceApi"))
            {
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                if let CheckedArray = csData as? NSArray
                {
                    if(CheckedArray.count == 1)
                    {
                        let dict = CheckedArray[0] as! NSDictionary
                        let DayCount = Util.checkNil(String(describing: dict["Day"]!))
                        let Message = String(describing: dict["Date"]!)
                        if(DayCount != "" && DayCount != "0")
                        {
                            NoRecordFoundLabel.isHidden = true
                            AbsentenceDateViceArray = CheckedArray
                            myTableView.reloadData()
                            
                        }
                        else{
                            NoRecordFoundLabel.isHidden = false
                            NoRecordFoundLabel.text = Message
                            
                        }
                    }else{
                        NoRecordFoundLabel.isHidden = true
                        AbsentenceDateViceArray = CheckedArray
                        myTableView.reloadData()
                    }
                }else
                {
                    Util.showAlert("", msg: strNoRecordAlert)
                }
                
            }
            
        }
        else
        {
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "ViewAbsenteesRecordSegue")
        {
            let segueid = segue.destination as! AbsenteesRecordVC
            segueid.DifferString = "DateVice"
            segueid.SchoolStrengthArray = SelectedAbsentenceDateViceArray
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
        LanguageDict = LangDict
        strLanguage = Language
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
        NoRecordFoundLabel.text = strNoRecordAlert
        TitleForNavigation()
    }
    
}
