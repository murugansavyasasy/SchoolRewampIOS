//
//  TotalAssignmentVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 05/05/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class TotalAssignmentVC: UIViewController,UITableViewDataSource,UITableViewDelegate,Apidelegate {
    
    var selectedDictionary = [String: Any]() as NSDictionary
    var selectedSchoolDictionary = [String: Any]() as NSDictionary
    var SelectedTextDict = [String: Any]() as NSDictionary
    var SchoolDetailDict = [String: Any]() as NSDictionary
    var DetailTextArray = NSMutableArray()
    var strApiFrom = NSString()
    var SelectedStr = String()
    var StaffId = String()
    var SchoolId = String()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var assignmentDetailID = String()
    var fileType = String()
    var viewFrom = String()
    var totalType = String()
    let todayDate = Calendar.current.startOfDay(for: Date())
    var studentID = String()
    
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var assignmentTableview: UITableView!
    @IBOutlet var PopupChooseImagePDFView: UIView!
    @IBOutlet weak var chooseLabel: UILabel!
    @IBOutlet weak var popupImageButton: UIButton!
    @IBOutlet weak var popupPdfButton: UIButton!
    
    var hud : MBProgressHUD = MBProgressHUD()
    var SelectedIndex = IndexPath()
    var popupChoosenBtn : KLCPopup  = KLCPopup()
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var languageDictionary = NSDictionary()
    var bIsArchive = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Assignment123")
        self.HiddenLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        bIsArchive = selectedDictionary["is_Archive"] as? Bool ?? false
        
        self.callSelectedLanguage()
        if(Util .isNetworkConnected()){
            self.CallTotalAssignmentMessageApi()
        }else{
            Util .showAlert("", msg: strNoInternet)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    
    // MARK:- Button Action
    @IBAction func actionBack(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionImageSelectionButton(_ sender: Any){
        fileType = "IMAGE"
        viewFrom = "Submission"
        popupChoosenBtn.dismiss(true)
        performSegue(withIdentifier: "ViewStaffAsssignmentSegue", sender: self)
        
    }
    
    
    @IBAction func actionPDFButton(_ sender: Any){
        fileType = "PDF"
        viewFrom = "Submission"
        popupChoosenBtn.dismiss(true)
        performSegue(withIdentifier: "ViewStaffAsssignmentSegue", sender: self)
    }
    
    @IBAction func actionClosePopUpButton(_ sender: Any) {
        PopupChooseImagePDFView.alpha = 0
        popupChoosenBtn.dismiss(true)
    }
    
    // MARK:- TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return DetailTextArray.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(totalType == "TOTAL"){
            let dict:NSDictionary = DetailTextArray[indexPath.row] as! NSDictionary
            let strMessage = String(describing: dict["Message"]!)
            if(strMessage.lowercased() == "non submitted"){
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    return 90
                }else{
                    return 60
                }
            }else{
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    return 130
                }else{
                    return 110
                }
            }
            
        }else{
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return 130
            }else{
                return 110
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TotalAssignmentTVCell", for: indexPath) as! TotalAssignmentTVCell
        cell.backgroundColor = UIColor.white
        
        let dict:NSDictionary = DetailTextArray[indexPath.row] as! NSDictionary
        
        cell.NameLabel.textColor = utilObj.GREEN_COLOR
        cell.NameLabel.text = String(describing: dict["Studentname"]!)
        cell.SectionLabel.text = String(describing: dict["Standard"]!) + " " + String(describing: dict["Section"]!)
        cell.TypeLabel.text = String(describing: dict["Message"]!)
        if(cell.TypeLabel.text?.lowercased() == "non submitted"){
            cell.TypeLabel.textColor = UIColor.red
            cell.viewButton.isHidden = true
        }else{
            cell.TypeLabel.textColor = UIColor.green
            cell.viewButton.isHidden = false
        }
        cell.viewButton.addTarget(self, action: #selector(actionViewButton(sender:)), for: .touchUpInside)
        cell.viewButton.tag = indexPath.row
        cell.layoutIfNeeded()
        return cell
    }
    
    @objc func actionViewButton(sender: UIButton){
        print("TotlaView")
        let  Dict = DetailTextArray[sender.tag] as! NSDictionary
        studentID =  String(describing: Dict["StudentId"]!)
        if(UIDevice.current.userInterfaceIdiom == .pad){
            PopupChooseImagePDFView.frame.size.height = 250
            PopupChooseImagePDFView.frame.size.width = 400
        }
        
        //        G3
        
        PopupChooseImagePDFView.center = view.center
        PopupChooseImagePDFView.alpha = 1
        PopupChooseImagePDFView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(PopupChooseImagePDFView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.PopupChooseImagePDFView.transform = .identity
        })
        
        print("TotlaView")
        
    }
    
    
    // MARK:- Api Calling
    func CallTotalAssignmentMessageApi() {
        showLoading()
        strApiFrom = "CallAssignmentMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_TOTAL_ASSIGNMENT
        
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + POST_TOTAL_ASSIGNMENT
        }
        
        // if(appDelegate.isPasswordBind == "1" && bIsArchive){
        if(bIsArchive){
            requestStringer = baseReportUrlString! + POST_TOTAL_ASSIGNMENT_SEEMORE
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ProcessBy": StaffId,"Type" :totalType, "AssignmentId" :   String(describing: selectedDictionary["AssignmentId"]!),COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber , SCHOOLIID : SchoolId]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailAssignmentMessage")
    }
    
    
    
    // MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        
        if(csData != nil)
        {
            utilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if(strApiFrom == "CallAssignmentMessage")
            {
                if let CheckedArray = csData as? NSArray{
                    
                    if(CheckedArray.count > 0){
                        let Dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        if let ss = Dict["StudentId"] as? NSNumber{
                            let sid = String(describing: Dict["StudentId"])
                            
                            if(sid == "<null>" && sid == "nil" && sid == "" && sid == nil){
                                DetailTextArray = []
                                AlertMessage(strAlert: strNoRecordAlert)
                            }else{
                                DetailTextArray = NSMutableArray(array: CheckedArray)
                                assignmentTableview.reloadData()
                            }
                            
                        }else{
                            DetailTextArray = []
                            AlertMessage(strAlert: strNoRecordAlert)
                        }
                        
                        
                    }else{
                        DetailTextArray = []
                        AlertMessage(strAlert: strNoRecordAlert)
                    }
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    assignmentTableview.reloadData()
                    
                    
                }
                else{
                    AlertMessage(strAlert: strSomething)
                }
            }
            else if(strApiFrom == "DeleteAssignment"){
                if let CheckedDict = csData as? NSDictionary{
                    let alertMessage = CheckedDict["Message"] as! String
                    if(String(describing: CheckedDict["result"]!) == "1"){
                        Util.showAlert("", msg: alertMessage)
                    }else{
                        Util.showAlert("", msg: alertMessage)
                    }
                }else{
                    Util.showAlert("", msg: strSomething)
                }
            }
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
        
        hideLoading()
        
    }
    
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util.showAlert("", msg: strSomething)
        
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
    
    
    
    
    func AlertMessage(strAlert : String){
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: strAlert, preferredStyle: .alert)
        
        
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ViewStaffAsssignmentSegue"){
            let segueid = segue.destination as! ViewAssignmentVC
            segueid.selectedDictionary = selectedDictionary
            segueid.viewFrom = self.viewFrom
            segueid.fileType = self.fileType
            segueid.isStaff = "true"
            segueid.ChildId = self.studentID
        }
        
        if (segue.identifier == "VedioAssignmentDetailSegue"){
            let segueid = segue.destination as! AssignmentVideoDetailVC
            segueid.selectedDictionary = selectedDictionary
            segueid.isStaff = "true"
            segueid.ChildId = self.StaffId
        }
        if (segue.identifier == "SubmitAssignmentSegue"){
            let segueid = segue.destination as! StudentSubmitAssignmentVC
            segueid.selectedDictionary = selectedDictionary
        }
        //Submission
        
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
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        chooseLabel.text = LangDict["choose"] as? String ?? "Choose"
        popupPdfButton.setTitle(LangDict["choose_pdf"] as? String ?? "Choose Pdf", for: .normal)
        popupImageButton.setTitle(LangDict["choose_image"] as? String ?? "Choose Image", for: .normal)
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
}
