//
//  TextVC.swift
//  VoicesnapParentApp
//
//  Created by PREMKUMAR on 16/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit


class TextVC: UIViewController,UITableViewDataSource,UITableViewDelegate,Apidelegate {
    
    
    var selectedDictionary = NSDictionary()
    var SelectedTextDict = NSDictionary()
    
    var DetailTextArray = NSMutableArray()
    var strCountryCode = String()
    var strScreenFrom = String()
    var strLanguage = String()
    var strApiFrom = NSString()
    var ChildId = String()
    var SchoolId = String()
    var SenderType = String()
    var Screenheight = CFloat()
    var bIsArchive = Bool()
    var getArchive : String!
    @IBOutlet weak var TextDateLabel: UILabel!
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var TextDetailstableview: UITableView!
    
    var hud : MBProgressHUD = MBProgressHUD()
    
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    
    var getMsgFromMgnt : Int! = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HiddenLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Screenheight = CFloat(self.view.frame.size.height)
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        
        bIsArchive = selectedDictionary["is_Archive"] as? Bool ?? false
        
        if(strScreenFrom == "FromStaff")
        {
            
            if(appDelegate.LoginSchoolDetailArray.count > 0)
            {
                let dict:NSDictionary = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
                if getMsgFromMgnt == 1 {
                    let defaults = UserDefaults.standard
                    print("SchoolId",SchoolId)
                }else{
                    ChildId = String(describing: dict["StaffID"]!)
                    SchoolId = String(describing: dict["SchoolID"]!)
                }
                TextDateLabel.text = String(describing: selectedDictionary["Date"]!)
                if(Util .isNetworkConnected())
                {
                    if(bIsArchive){
                        CallSeeMoreStaffTextMessageApi()
                    }else{
                        CallStaffTextMessageApi()
                        
                    }
                    
                }
                else
                {
                    Util .showAlert("", msg: NETWORK_ERROR)
                }
                
            }else
            {
                Util.showAlert("", msg: NO_RECORD_MESSAGE)
            }
            
        }else
        {
            ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
            SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
            TextDateLabel.text = String(describing: selectedDictionary["Date"]!)
            if(Util .isNetworkConnected())
            {
                self.CallDetailTextMessageApi()
                
            }
            else
            {
                DetailTextArray =  Childrens.getDateWiseText(fromDB: ChildId,getDateId:TextDateLabel.text!)
                if(DetailTextArray.count > 0)
                {
                    TextDetailstableview.reloadData()
                }else{
                    Util .showAlert("", msg: NETWORK_ERROR)
                }
                
                
            }
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    // MARK:- Button Action
    @IBAction func actionBack(_ sender: Any)
    {
        
        
        if(strScreenFrom == "FromStaff")
        {
            print("COMFromStaff")
            let nc = NotificationCenter.default
           

            nc.post(name: NSNotification.Name(rawValue: "comeBackStaff"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }else
        {
            print("COMFText")

            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: "comeBackText"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    // MARK:- TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return DetailTextArray.count
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dict = DetailTextArray[indexPath.row] as! NSDictionary
        var DescriptionText = String()
        var CheckNilText = String()
        if(strScreenFrom == "FromStaff")
        {
            DescriptionText = String(describing: dict["Description"]!)
            CheckNilText  = Util .checkNil(DescriptionText)
        }else
        {
            DescriptionText = String(describing: dict["Description"]!)
            CheckNilText  = Util .checkNil(DescriptionText)
        }
        if(CheckNilText != "")        {
            
            let Stringlength : Int = CheckNilText.count
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                let MuValue : Int = Stringlength/61
                return (165 + ( 22 * CGFloat(MuValue)))
                //return (165 * CGFloat(MuValue))
            }else{
                if(Screenheight > 580)
                {
                    let MuValue : Int = Stringlength/50
                    return (118 + ( 18 * CGFloat(MuValue)))
                    
                }else{
                    let MuValue : Int = Stringlength/44
                    return (118 + ( 18 * CGFloat(MuValue)))
                }
            }
        }
        else{
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return 120
            }else{
                return 88
            }
            
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "TextFileTableViewCell", for: indexPath) as! TextFileTableViewCell
        cell1.backgroundColor = UIColor.clear
        let dict = DetailTextArray[indexPath.row] as! NSDictionary
        
        cell1.TimeLbl.text = String(describing: dict["Time"]!)
        cell1.DateLbl.text = String(describing: dict["Date"]!)
        cell1.SubjectLbl.text = String(describing: dict["Subject"]!)

        
        let iReadVoice : Int? = Int((dict["AppReadStatus"] as? String)!)
        
        var DescriptionText = String()
        var CheckNilText = String()
        if(strScreenFrom == "FromStaff"){

            var desc  = String(describing: dict["Description"]!)

                   if desc != "" && desc != nil {

                       DescriptionText = desc
                       CheckNilText  = Util .checkNil(DescriptionText)
                       cell1.TextTitleTextView.text = desc
                       cell1.TextTitleTextView.isHidden = false


                   }else{
                       cell1.TextTitleTextView.isHidden = true
                       print("desEmptyc",desc)


                   }
        }else{
            cell1.TextTitleTextView.isHidden = false
            cell1.TextDetailTextView.text = String(describing: dict["URL"]!)
            DescriptionText = String(describing: dict["Description"]!)
            CheckNilText  = Util .checkNil(DescriptionText)
        }
        if(CheckNilText != ""){
            cell1.TextTitleTextView.text = CheckNilText
        }
        else{
            cell1.TextTitleTextView.text = ""
        }
        
        if(iReadVoice == 0){
            cell1.NewLbl.isHidden = false
        }
        else{
            cell1.NewLbl.isHidden = true
        }
        
        if(strLanguage == "ar"){
            cell1.TextTitleTextView.textAlignment = .right
            
        }else{
            cell1.TextTitleTextView.textAlignment = .left
            
        }
        
        cell1.TextTitleTextView.tintColor = .systemGreen
        cell1.TextTitleTextView.isEditable = false
        cell1.TextTitleTextView.dataDetectorTypes = .all
        
        cell1.TextDetailTextView.tintColor = .systemGreen
        cell1.TextDetailTextView.isEditable = false
        cell1.TextDetailTextView.dataDetectorTypes = .all
        return cell1
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SelectedTextDict = DetailTextArray[indexPath.row] as! NSDictionary
        let dict = NSMutableDictionary(dictionary: SelectedTextDict)
        let iReadVoice : Int? = Int((SelectedTextDict["AppReadStatus"] as? String)!)
        
        if(iReadVoice == 0){
            
            dict["AppReadStatus"] = "1"
            
            DetailTextArray[indexPath.row] = dict
            
            if(Util .isNetworkConnected())
            {
                if(strScreenFrom == "FromStaff")
                {
                    CallStaffReadStatusUpdateApi(String(describing: SelectedTextDict["ID"]!) , "SMS")
                }else
                {
                    CallReadStatusUpdateApi(String(describing: SelectedTextDict["ID"]!) , "SMS")
                }
            }
            else
            {
                Util .showAlert("", msg: NETWORK_ERROR)
            }
            
        }
        TextDetailstableview.reloadData()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "TextDetailsSeg", sender: self)
        }
        
        
        
    }
    
    // }
    // MARK:- Api Calling
    func CallStaffTextMessageApi() {
        showLoading()
        strApiFrom = "CallStaffTextMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_FILES_STAFF
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_FILES_STAFF
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)

        let myDict:NSMutableDictionary = ["SchoolId": SchoolId,"MemberId" : ChildId,"CircularDate" : TextDateLabel.text!,"Type" : "SMS", COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        print("myDictmyDict",myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        print("myStringmyString",myString)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallStaffTextMessage")
    }
    func CallSeeMoreStaffTextMessageApi() {
        showLoading()
        strApiFrom = "CallSeeMoreStaffTextMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_FILES_STAFF_ARCHIVE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_FILES_STAFF_ARCHIVE
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
      print("requestStringrequestString",requestString)
        let myDict:NSMutableDictionary = ["SchoolId": SchoolId,"MemberId" : ChildId,"CircularDate" : TextDateLabel.text!,"Type" : "SMS", COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallSeeMoreStaffTextMessage")
    }
    func CallDetailTextMessageApi() {
        showLoading()
        strApiFrom = "CallDetailTextMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_FILES
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_FILES
        }
        if(bIsArchive){
            requestStringer = baseReportUrlString! + GET_FILES_SEEMORE
        }
        utilObj.printLogKey(printKey: "appDelegate.isPasswordBind", printingValue: appDelegate.isPasswordBind)
        utilObj.printLogKey(printKey: "bIsArchive", printingValue: bIsArchive)
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId,"CircularDate" : TextDateLabel.text!,"Type" : "SMS", COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        utilObj.printLogKey(printKey: "CallDetailTextMessage", printingValue: requestStringer)
        
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailTextMessage")
    }
    
    func CallStaffReadStatusUpdateApi(_ ID : String, _ type : String) {
        //showLoading()
        
        strApiFrom = "UpdateReadStatus"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        var requestStringer = baseUrlString! + READ_STATUS_UPDATE
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ID" : ID,"Type" : type, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertNSDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "UpdateReadStatus")
    }
    
    
    
    func CallReadStatusUpdateApi(_ ID : String, _ type : String) {
        //showLoading()
        
        strApiFrom = "UpdateReadStatus"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        
        var requestStringer = baseUrlString! + READ_STATUS_UPDATE
        
        if(bIsArchive){
            requestStringer = baseUrlString! + READ_STATUS_UPDATE_SEEMORE
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        print("CallReadStatusUpdateApirequestString",requestString)
        let myDict:NSMutableDictionary = ["ID" : ID,"Type" : type, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertNSDictionary(toString: myDict)
        print(myDict)
        print(requestStringer)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "UpdateReadStatus")
    }
    
    // MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        
        if(csData != nil)
        {
            if(strApiFrom == "CallDetailTextMessage")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData : NSArray = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = arrayData[i] as! NSDictionary
                        print(dict)
                        
                        let Status = String(describing: dict["Status"]!)
                        let Message = String(describing: dict["Message"]!)
                        if(Status == "1")
                        {
                            DetailTextArray.add(dict)
                        }else{
                            AlertMessage(strAlert: Message)
                            
                            
                        }
                    }
                    
                    Childrens.saveDateWiseTextDetail(DetailTextArray as! [Any] , ChildId)
                    
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    TextDetailstableview.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
                }
            }
            if(strApiFrom == "CallStaffTextMessage")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData : NSArray = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = arrayData[i] as! NSDictionary
                        let Status = String(describing: dict["ID"]!)
                        
                        let Message = String(describing: dict["URL"]!)
                        let CheckNilText : String = Util .checkNil(Status)
                        if(CheckNilText != "")
                        {
                            DetailTextArray.add(dict)
                        }else{
                            AlertMessage(strAlert: Message)
                            
                            
                        }
                    }
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    TextDetailstableview.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
                }
            }
            else  if(strApiFrom == "CallSeeMoreStaffTextMessage")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData : NSArray = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = arrayData[i] as! NSDictionary
                        let Status = String(describing: dict["ID"]!)
                        
                        let Message = String(describing: dict["URL"]!)
                        let CheckNilText : String = Util .checkNil(Status)
                        if(CheckNilText != "")
                        {
                            DetailTextArray.add(dict)
                        }else{
                            AlertMessage(strAlert: Message)
                            
                            
                        }
                    }
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    TextDetailstableview.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
                }
            }
            else if(strApiFrom == "UpdateReadStatus")
            {
                if((csData?.count)! > 0){
                    
                }
            }
            
        }
        else
        {
            Util.showAlert("", msg: SERVER_ERROR)
        }
        
        hideLoading()
        
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util .showAlert("", msg: pagename.localizedDescription);
        
    }
    
    // MARK: - Loading
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //  print(detailsDict)
        
        if (segue.identifier == "TextDetailsSeg"){
            let segueid = segue.destination as! TextDetailVC
            segueid.SenderType = strScreenFrom
            segueid.selectedDictionary = SelectedTextDict
            
        }
    }
    
    func AlertMessage(strAlert : String){
        
        let alertController = UIAlertController(title: "Alert", message: strAlert, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    
}
