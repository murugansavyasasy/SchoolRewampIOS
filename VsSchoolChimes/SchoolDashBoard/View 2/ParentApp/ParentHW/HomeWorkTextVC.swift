//
//  HomeWorkTextVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 05/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
//import 
class HomeWorkTextVC: UIViewController ,UITableViewDataSource,UITableViewDelegate,Apidelegate {
    
    
    var selectedDictionary = [String: Any]() as NSDictionary
    var SelectedTextDict = [String: Any]() as NSDictionary
    
    var DetailTextArray = NSMutableArray()
    
    
    var strApiFrom = NSString()
    var ChildId = String()
    var SchoolId = String()
    
    @IBOutlet weak var TextDateLabel: UILabel!
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var HomeworkDetailTableview: UITableView!
    
    var hud : MBProgressHUD = MBProgressHUD()
    var Screenheight = CFloat()
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var strCountryCode = String()
    var bIsArchive = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HiddenLabel.isHidden = true
        ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        TextDateLabel.text = String(describing: selectedDictionary["HomeworkDate"]!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        Screenheight = CFloat(self.view.frame.size.height)
        if(Util .isNetworkConnected())
        {
            bIsArchive = selectedDictionary["is_Archive"] as? Bool ?? false
            self.CallDetailHomeworkMessageApi()
            
        }
        else
        {
            DetailTextArray = Childrens.getHomeWorkTextDetail(fromDB: ChildId, getDateId: TextDateLabel.text!)
            if(DetailTextArray.count > 0)
            {
                HomeworkDetailTableview.reloadData()
            }else{
                Util .showAlert("", msg: NETWORK_ERROR)
            }
            
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    // MARK: - Navigation
    
    // MARK: - Button Action
    @IBAction func actionBack(_ sender: UIButton)
    {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK:- TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return DetailTextArray.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dict = DetailTextArray[indexPath.row] as! NSDictionary
        
        let DescriptionText:String = String(describing: dict["HomeworkTitle"]!)
        let CheckNilText : String = Util .checkNil(DescriptionText)
        if(CheckNilText != "")        {
            
            let Stringlength : Int = CheckNilText.count
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                let MuValue : Int = Stringlength/61
                return (165 + ( 22 * CGFloat(MuValue)))
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
        cell1.NewLbl.isHidden = true
        let dict = DetailTextArray[indexPath.row] as! NSDictionary
        
        cell1.SubjectLbl.text = String(describing: dict["HomeworkSubject"]!)
        cell1.TextDetailTextView.text = String(describing: dict["HomeworkContent"]!)
        
        let DescriptionText:String = String(describing: dict["HomeworkTitle"]!)
        let CheckNilText : String = Util .checkNil(DescriptionText)
        if(CheckNilText != "")
        {
            cell1.TextTitleTextView.text = CheckNilText
            
        }
        else{
            cell1.TextTitleTextView.text = ""
            
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
        
        
        
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "HomeWorkTextDetailSegue", sender: self)
        }
        
        
        
    }
    
    // MARK: - Api Calling
    func CallDetailHomeworkMessageApi() {
        print("123456")
        showLoading()
        strApiFrom = "CallDetailHomeworkMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_HOMEWORK_FILES
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        if(appDelegate.isPasswordBind == "1" ){
            requestStringer = baseReportUrlString! + GET_HOMEWORK_FILES
        }
        if(bIsArchive){
            requestStringer = baseReportUrlString! + GET_HOMEWORK_FILES_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"Date" : TextDateLabel.text!,"Type" : "TEXT", COUNTRY_CODE: strCountryCode ,MOBILE_NUMBER : appDelegate.strMobileNumber , SCHOOLIID : SchoolId]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailHomeworkMessage")
    }
    
    func CallReadStatusUpdateApi(_ circularDate : String,_ ID : String, _ type : String) {
        showLoading()
        strApiFrom = "detailssss"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + READ_STATUS_UPDATE
        
        let arrUserData : NSMutableArray = []
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["fn" : "ReadStatusUpdate","ChildID": selectedDictionary.object(forKey: "ChildID") as Any,"SchoolID" : selectedDictionary.object(forKey: "SchoolID") as Any,"Date" : circularDate,"Type" : type,"ID" : ID, COUNTRY_CODE: strCountryCode]
        
        arrUserData.add(myDict)
        
        let myString = Util.convertNSMutableArray(toString: arrUserData)
        
        apiCall.nsurlConnectionFunction(requestString, myString, type)
    }
    // MARK: - Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        
        if(csData != nil)
        {
            utilObj.printLogKey(printKey: "Cs data", printingValue: csData!)
            if(strApiFrom == "CallDetailHomeworkMessage")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    if(arrayData.count > 0)
                    {
                        for i in 0..<arrayData.count
                        {
                            if let dict = CheckedArray[i] as? NSDictionary{
                                
                                if(  dict["HomeworkSubject"] != nil){
                                    var MutalDict : NSMutableDictionary = dict.mutableCopy() as! NSMutableDictionary
                                    
                                    MutalDict["ID"] = String(describing: i)
                                    DetailTextArray.add(MutalDict)
                                    Childrens.saveHomeWorkTextDetail(DetailTextArray as! [Any], ChildId, getDateId: TextDateLabel.text!)
                                }
                            }
                            
                            
                            
                        }
                    }
                    else{
                        AlertMessage()
                        
                    }
                    
                    
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    
                    HomeworkDetailTableview.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
                }
            }
        }
        else
        {
            Util.showAlert("", msg: SERVER_ERROR)
        }
        
        
        
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
        
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
        print(SelectedTextDict)
        
        if (segue.identifier == "HomeWorkTextDetailSegue")
        {
            let segueid = segue.destination as! HomeWorkTextDetailVC
            
            segueid.selectedDictionary = SelectedTextDict
            
        }
    }
    func AlertMessage()
    {
        
        let alertController = UIAlertController(title: "Alert", message: NO_RECORD_MESSAGE, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
}
