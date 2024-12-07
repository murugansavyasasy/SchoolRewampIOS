//
//  StaffViewAssignmentVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 04/05/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class StaffViewAssignmentVC: UIViewController ,UITableViewDataSource,UITableViewDelegate,Apidelegate {
    
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
    var strAssignmentID = String()
    var strNoInternet = String()
    var strSomething = String()
    var assignmentDetailID = String()
    var fileType = String()
    var viewFrom = String()
    let todayDate = Calendar.current.startOfDay(for: Date())
    var totalFrom = String()
    
    var strLanguage  = String()
    
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var assignmentTableview: UITableView!
    @IBOutlet var PopupChooseImagePDFView: UIView!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet weak var closeButtonHeight: NSLayoutConstraint!
    
    var hud : MBProgressHUD = MBProgressHUD()
    var SelectedIndex = IndexPath()
    var popupChoosenBtn : KLCPopup  = KLCPopup()
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var languageDictionary = NSDictionary()
    
    
    var strSegmentForm = String()
    var selecSchoolDict = NSDictionary()
    var altSting = String()
    var bIsSeeMore = Bool()
    var bIsArchive = Bool()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HiddenLabel.isHidden = true
        print("Assignment345")
        let isPrincipal = appDelegate.isPrincipal as NSString
        bIsSeeMore = false
        if(appDelegate.isPasswordBind == "0"){
            bIsSeeMore = true
        }
        
        print("isPrincipalS",isPrincipal)
        print("isPrincipalisEqualS",isPrincipal .isEqual(to: "true"))
        if(isPrincipal .isEqual(to: "true")){
            SchoolId = String(describing: selectedSchoolDictionary["SchoolID"]!)
            StaffId = String(describing: selectedSchoolDictionary["StaffID"]!)
            closeButton.isHidden = false
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                closeButtonHeight.constant = 50
            }else{
                closeButtonHeight.constant = 30
            }
        }else{
            selectedSchoolDictionary  = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
            closeButton.isHidden = true
            closeButtonHeight.constant = 0
            
        }
        strSegmentForm = "school"
        
        
        assignmentTableview.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        if(appDelegate.LoginSchoolDetailArray.count == 1){
            strSegmentForm = "view"
            self.CallAssignmentMessageApi()
        }else{
            strSegmentForm = "school"
            assignmentTableview.reloadData()
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
        performSegue(withIdentifier: "ViewAsssignmentSegue", sender: self)
    }
    
    @IBAction func actionPDFButton(_ sender: Any){
        fileType = "PDF"
        viewFrom = "Submission"
        popupChoosenBtn.dismiss(true)
        performSegue(withIdentifier: "ViewAsssignmentSegue", sender: self)
    }
    
    @IBAction func actionClosePopUpButton(_ sender: Any) {
        popupChoosenBtn.dismiss(true)
    }
    
    // MARK:- TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        
        if(strSegmentForm == "school"){
            return appDelegate.LoginSchoolDetailArray.count
        }else{
            var iCount : Int? = 0
            iCount = DetailTextArray.count
            if(iCount == 0){
                if(appDelegate.isPasswordBind != "0"){
                    emptyView()
                }
                iCount = 0
            }else{
                restoreView()
                if(!bIsSeeMore){
                    iCount = iCount! + 1
                    
                }
            }
            return iCount!
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(strSegmentForm == "school"){
            return 50
        }else{
            if(indexPath.row <= (DetailTextArray.count - 1)){
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    return 410
                }else{
                    return 350
                }
            }else{
                return 40
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(strSegmentForm == "school"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageTVCell", for: indexPath) as! TextMessageTVCell
            let schoolDict = appDelegate.LoginSchoolDetailArray .object(at: indexPath.row) as? NSDictionary
            cell.SchoolNameLbl.text = schoolDict?["SchoolName"] as? String
            var schoolNameReg  =  schoolDict?["SchoolNameRegional"] as? String

                    if schoolNameReg != "" && schoolNameReg != nil {

                        cell.SchoolNameRegionalLbl.text = schoolNameReg
                        cell.SchoolNameRegionalLbl.isHidden = false

    //                        cell.locationTop.constant = 4
                    }else{
                        cell.SchoolNameRegionalLbl.isHidden = true
            //            cell.SchoolNameRegional.backgroundColor = .red
                        cell.schoolNameTop.constant = 20

                    }
            return cell
        }
        else{
            if(indexPath.row <= (DetailTextArray.count - 1)){
                let cell = tableView.dequeueReusableCell(withIdentifier: "StaffViewAssignmentTVCell", for: indexPath) as! StaffViewAssignmentTVCell
                cell.backgroundColor = UIColor.clear
                
                let dict:NSDictionary = DetailTextArray[indexPath.row] as! NSDictionary
                
                cell.dateLabel.text = dict["Date"] as? String
                cell.timeLabel.text =  dict["Time"] as? String
                cell.titleLabel.text = dict["Title"] as? String
                cell.typeLabel.text =  dict["Type"] as? String
                cell.subjectLabel.text = ": " +  String(describing: dict["Subject"]!)
                cell.countLabel.text = ": " + String(describing: dict["submittedCount"]!)
                cell.totalLabel.text = ": " + String(describing: dict["TotalCount"]!)
                cell.categorylabel.text = ": " + String(describing: dict["category"]!)
                let dueDate = utilObj.convertStringIntoDate1(strDate: String(describing: dict["EndDate"]!))
                cell.dueLabel.text = ": " + String(describing: dict["EndDate"]!)
                if( dueDate >= todayDate as Date ){
                    cell.dueLabel.textColor = UIColor.black
                }else{
                    cell.dueLabel.textColor = UIColor.red
                }
                cell.viewButton.addTarget(self, action: #selector(actionViewButton(sender:)), for: .touchUpInside)
                cell.viewButton.tag = indexPath.row
                
                
                cell.submissionButton.addTarget(self, action: #selector(actionSubmissionButton(sender:)), for: .touchUpInside)
                cell.submissionButton.tag = indexPath.row
                
                cell.deleteButton.addTarget(self, action: #selector(actionDeleteButton(sender:)), for: .touchUpInside)
                cell.deleteButton.tag = indexPath.row
                
                cell.totalButton.addTarget(self, action: #selector(actionTotalButton(sender:)), for: .touchUpInside)
                cell.totalButton.tag = indexPath.row
                
                cell.forwardButton.addTarget(self, action: #selector(actionForwardButton(sender:)), for: .touchUpInside)
                cell.forwardButton.tag = indexPath.row
                
                cell.layoutIfNeeded()
                if(strLanguage == "ar"){
                    cell.mainView.semanticContentAttribute = .forceRightToLeft
                    cell.subjectLabel.textAlignment = .right
                    cell.dueLabel.textAlignment = .right
                    cell.countLabel.textAlignment = .right
                    cell.totalLabel.textAlignment = .right
                    
                }else{
                    cell.subjectLabel.textAlignment = .left
                    cell.dueLabel.textAlignment = .left
                    cell.countLabel.textAlignment = .left
                    cell.totalLabel.textAlignment = .left
                    
                    
                }
                cell.subjectLabelLang.text = languageDictionary["teacher_atten_subject"] as? String
                cell.dueLabelLang.text = languageDictionary["subission_due"] as? String
                cell.countLabelLang.text = languageDictionary["subission_count"] as? String
                cell.totalLabelLang.text = languageDictionary["total_count"] as? String
                cell.categoryLabelLang.text = languageDictionary["category"] as? String
                cell.viewButton.setTitle(languageDictionary["view"] as? String, for: .normal)
                cell.totalButton.setTitle(languageDictionary["total"] as? String, for: .normal)
                cell.submissionButton.setTitle(languageDictionary["submissions"] as? String, for: .normal)
                cell.deleteButton.setTitle(languageDictionary["delete"] as? String, for: .normal)
                cell.forwardButton.setTitle(languageDictionary["forward"] as? String, for: .normal)
                return cell
            }
            
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreTVCell", for: indexPath) as! SeeMoreTVCell
                cell.SeeMoreBtn.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
                cell.backgroundColor = .clear
                return cell
                
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(strSegmentForm == "school"){
            selecSchoolDict = appDelegate.LoginSchoolDetailArray[indexPath.row] as! NSDictionary
            print("selectedSchoolDict \(selecSchoolDict)")
            strSegmentForm = "view"
            DetailTextArray = []
            SchoolId = String(describing: selecSchoolDict["SchoolID"]!)
            StaffId = String(describing: selecSchoolDict["StaffID"]!)
            
            CallAssignmentMessageApi()
        }
    }
    @objc func actionViewButton(sender: UIButton){
        selectedDictionary = DetailTextArray[sender.tag] as! NSDictionary
        viewFrom = "View"
        fileType = ""
        if(String(describing: selectedDictionary["Type"]!) == "VOICE"){
            performSegue(withIdentifier: "VedioAssignmentDetailSegue", sender: self)
        }else{
            performSegue(withIdentifier: "ViewStaffAsssignmentSegue", sender: self)
        }
    }
    
    @objc func actionSubmitButton(sender: UIButton){
        selectedDictionary = DetailTextArray[sender.tag] as! NSDictionary
        performSegue(withIdentifier: "SubmitAssignmentSegue", sender: self)
    }
    
    @objc func actionTotalButton(sender: UIButton){
        totalFrom = "TOTAL"
        selectedDictionary = DetailTextArray[sender.tag] as! NSDictionary
        performSegue(withIdentifier: "TotalAssignmentSegue", sender: self)
    }
    
    @objc func actionForwardButton(sender: UIButton){
        selectedDictionary = DetailTextArray[sender.tag] as! NSDictionary
        let isPrincipal = appDelegate.isPrincipal as NSString
        print("isPrincipalF",isPrincipal)
        print("isPrincipalisEqualF",isPrincipal .isEqual(to: "true"))
        if(isPrincipal .isEqual(to: "true")){
            let StaffVC = self.storyboard?.instantiateViewController(withIdentifier: "PrincipleStandardSectionVC") as! PrincipleStandardSectionVC
            StaffVC.SchoolDetailDict = selectedSchoolDictionary
            StaffVC.SchoolId = self.SchoolId
            StaffVC.StaffId = self.StaffId
            StaffVC.strAssigmentFrom = "principal"
            StaffVC.strAssignmentID = String(describing: selectedDictionary["AssignmentId"]!)
            self.present(StaffVC, animated: false, completion: nil)
            
        }else{
            let StaffStudent = self.storyboard?.instantiateViewController(withIdentifier: "PrincipleStandardSectionVC") as! PrincipleStandardSectionVC
            StaffStudent.SchoolDetailDict = selectedSchoolDictionary
            StaffStudent.SchoolId = self.SchoolId
            StaffStudent.StaffId = self.StaffId
            StaffStudent.strAssigmentFrom = "staff"
            StaffStudent.strAssignmentID = String(describing: selectedDictionary["AssignmentId"]!)
            self.present(StaffStudent, animated: false, completion: nil)
        }
    }
    
    @objc func actionDeleteButton(sender: UIButton){
        selectedDictionary = DetailTextArray[sender.tag] as! NSDictionary
        bIsArchive = selectedDictionary["is_Archive"] as? Bool ?? false
        
        showDeleteAlert()
        
    }
    
    @objc func actionSubmissionButton(sender: UIButton){
        totalFrom = "SUBMITTED"
        selectedDictionary = DetailTextArray[sender.tag] as! NSDictionary
        performSegue(withIdentifier: "TotalAssignmentSegue", sender: self)
    }
    
    
    // MARK:- Api Calling
    func CallAssignmentMessageApi() {
        showLoading()
        strApiFrom = "CallAssignmentMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_STAFF_ASSIGNMENT_LIST
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + POST_STAFF_ASSIGNMENT_LIST
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ProcessBy": StaffId, COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber , SCHOOLIID : SchoolId]
        
        
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailAssignmentMessage")
    }
    
    func CallSeeMoreAssignmentMessageApi() {
        showLoading()
        strApiFrom = "CallSeeMoreAssignmentMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_STAFF_ASSIGNMENT_LIST_SEEMORE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + POST_STAFF_ASSIGNMENT_LIST_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ProcessBy": StaffId, COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber , SCHOOLIID : SchoolId]
        
        
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallSeeMoreAssignmentMessage")
    }
    
    func CallDeleteAssignmentApi() {
        showLoading()
        strApiFrom = "DeleteAssignment"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_DELETE_ASSIGNMENT
        // if(appDelegate.isPasswordBind == "1" && bIsArchive){
        if(bIsArchive){
            requestStringer = baseUrlString! + POST_DELETE_ASSIGNMENT_SEEMORE
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ProcessBy": StaffId,"AssignmentId" :String(describing: selectedDictionary["AssignmentId"]!), COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber , SCHOOLIID : SchoolId]
        
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
                    print(CheckedArray)
                    if(CheckedArray.count > 0){
                        let Dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        strNoRecordAlert = Dict["Message"] as? String ?? strNoRecordAlert
                        if(String(describing: Dict["AssignmentId"]!) == "<null>" || String(describing: Dict["AssignmentId"]!) == ""){
                            
                            altSting = strNoRecordAlert
                            
                        }else{
                            DetailTextArray = NSMutableArray(array: CheckedArray)
                            assignmentTableview.reloadData()
                        }
                        
                    }else{
                        DetailTextArray = []
                        altSting = strNoRecordAlert
                        
                    }
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    assignmentTableview.reloadData()
                    
                    
                }
                else{
                    self.showAlert(alert: "", message: strNoRecordAlert)
                }
            }
            if(strApiFrom == "CallSeeMoreAssignmentMessage")
            {
                if let CheckedArray = csData as? NSArray{
                    
                    if(CheckedArray.count > 0){
                        let Dict : NSDictionary = CheckedArray[0] as! NSDictionary
                        strNoRecordAlert = Dict["Message"] as? String ?? strNoRecordAlert
                        
                        if(String(describing: Dict["AssignmentId"]!) == "<null>" || String(describing: Dict["AssignmentId"]!) == ""){
                            self.showAlert(alert: "", message: strNoRecordAlert)
                        }else{
                            for i in 0..<CheckedArray.count
                            {
                                let dict = CheckedArray[i] as! NSDictionary
                                DetailTextArray.add(dict)
                                
                                
                            }
                            assignmentTableview.reloadData()
                        }
                        
                    }else{
                        DetailTextArray = []
                        self.showAlert(alert: "", message: strNoRecordAlert)
                    }
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    assignmentTableview.reloadData()
                    
                    
                }
                else{
                    self.showAlert(alert: "", message: strNoRecordAlert)
                }
            }
            else if(strApiFrom == "DeleteAssignment"){
                print(csData)
                Util.showAlert("", msg: "Deleted Successfully!")
                self.CallAssignmentMessageApi()
            }
        }
        else{
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
    
    func showDeleteAlert(){
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: languageDictionary["delete_assignment_alert"] as? String, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: languageDictionary["rb_yes"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.CallDeleteAssignmentApi()
        }
        let cancelAction = UIAlertAction(title: languageDictionary["rb_no"] as? String, style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
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
            segueid.ChildId = self.StaffId
        }
        
        if (segue.identifier == "TotalAssignmentSegue"){
            let segueid = segue.destination as! TotalAssignmentVC
            segueid.selectedDictionary = selectedDictionary
            segueid.totalType = self.totalFrom
            segueid.StaffId = self.StaffId
            segueid.SchoolId = self.SchoolId
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
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
    @objc func reloadApiData(notification:Notification) -> Void {
        self.CallAssignmentMessageApi()
    }
    //Mark:- SeeMore Feature
    func emptyView(){
        let noview : UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.assignmentTableview.bounds.size.width, height: self.assignmentTableview.bounds.size.height))
        
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y:  8, width: self.assignmentTableview.bounds.size.width, height: 150))
        noDataLabel.text = altSting
        noDataLabel.textColor = .white
        
        noDataLabel.numberOfLines = 0
        
        noDataLabel.textAlignment = NSTextAlignment.center
        noview.addSubview(noDataLabel)
        
        let button = UIButton(frame: CGRect(x: self.assignmentTableview.bounds.size.width - 108, y: noDataLabel.frame.height + 10, width: 100, height: 32))
        button.setTitle(SEE_MORE_TITLE, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        
        button.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        noview.addSubview(button)
        
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 3
        button.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        
        self.assignmentTableview.backgroundView = noview
    }
    func restoreView(){
        self.assignmentTableview.backgroundView = nil
    }
    
    @objc func seeMoreButtonTapped(sender : UIButton) {
        self.bIsSeeMore = true
        self.assignmentTableview.reloadData()
        CallSeeMoreAssignmentMessageApi()
    }
}
