//
//  StaffAddNewClassVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 09/08/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit
import Alamofire
import KRProgressHUD
import ObjectMapper

class StaffAddNewClassVC: UIViewController,Apidelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITableViewDataSource,UITableViewDelegate {
    
    
    
    @IBOutlet var PopupChoosePickerView: UIView!
    @IBOutlet var SendAssigmentView: UIView!
    @IBOutlet weak var MyPickerView: UIPickerView!
    @IBOutlet weak var PickerTitleLabel: UILabel!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var pickerCancelButton: UIButton!
    @IBOutlet weak var pickerOkButton: UIButton!
    @IBOutlet weak var assigmentSendButton: UIButton!
    @IBOutlet weak var assigmentStudentButton: UIButton!
    @IBOutlet var MyTableView: UITableView!
    var strApiFrom = NSString()
    var assignmentType = NSString()
    var StaffId = String()
    var SchoolId = String()
    var TableString = String()
    var pickerStandardArray = [String]()
    var pickerSubjectArray = [String]()
    var pickerSectionArray = [String]()
    var pickerCategoryArray = [String]()
    var selectedStandardRow = 0;
    var selectedSubjectRow = 0;
    var selectedSectionRow = 0;
    var selectedCategoryRow = 0;
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var StandarCodeArray:Array = [String]()
    var StandardNameArray:Array = [String]()
    var SubjectNameArray:Array = [String]()
    var DetailofSectionArray:Array = [Any]()
    var DetailofSubjectArray:Array = [Any]()
    var popupChooseStandard : KLCPopup  = KLCPopup()
    var DetailedSubjectArray:Array = [Any]()
    var SelectedSectionDetail:NSDictionary = [String:Any]() as NSDictionary
    var SelectedSubjectDetail:NSDictionary = [String:Any]() as NSDictionary
    //  var SectionTitleArray = ["Standard","Section(s)","Subject"]
    var SectionTitleArray = NSMutableArray()
    var SelectedStandardString = String()
    var SelectedSubjectString = String()
    var SelectedCategoryString = String()
    var SelectedSectionName = String()
    var SendedScreenNameStr = String()
    var apicalled = String()
    var HomeTitleText = String()
    var HomeTextViewText = String()
    var SchoolDetailDict:NSDictionary = [String:Any]() as NSDictionary
    var StandardSectionSubjectArray = NSArray()
    var SectionCodeArray:Array = [String]()
    var SubjectCodeArray:Array = [String]()
    var SelectedSectionCodeArray = NSMutableArray()
    var ChoosenSectionIDArray : Array = [Any]()
    var durationString = String()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var sectionIDNode = ""
    var LanguageDict = NSDictionary()
    var VoiceurlData: URL?
    let UtilObj = UtilClass()
    var pdfData : NSData? = nil
    var sendAssignmentDict = NSMutableDictionary()
    var SectionArray = NSMutableArray()
    var imagesArray = NSMutableArray()
    var mainSubjectArray = NSArray()
    var convertedImagesUrlArray = NSMutableArray()
    var currentImageCount = 0
    var totalImageCount = 0
    var imageUrlArray = NSMutableArray()
    var originalImagesArray = [UIImage]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var checkSchoolID : String!
    var bisSubject = Bool()
    
    var filepathArray = NSMutableArray()
    var SectionIdArr = NSMutableArray()
    var selectfilepathArray : Array = [Any]()
    var filepath : String!
    var fileType :String!
    var insertHomeWorkSeccodeArr : [String] = []
    
    var voiceURl : URL!
    
    var SectionIds : String!
    var FilePathArrayPath : String!
    var FilePathArrayType : String!
    
    var HomeWorkPdf : String!
    var HomeWorkType : String!
    var yourArray = [String]()
    var yourArray1 = [String: String]()
    
    
    var voicePathUrl : String!
    var voiceType : String!
    
    var selectedSchoolDictionaryVoice = NSMutableDictionary()
    var countryCoded : String!
    override func viewDidLoad()
    {
        
        print("HomeWorkImage :",HomeWorkPdf)
        super.viewDidLoad()
        view.isOpaque = false
        SendButton.layer.cornerRadius = 5
        SendButton.layer.masksToBounds = true
        assigmentSendButton.layer.cornerRadius = 5
        assigmentSendButton.layer.masksToBounds = true
        assigmentStudentButton.layer.cornerRadius = 5
        assigmentStudentButton.layer.masksToBounds = true
        self.SendAssigmentView.isHidden = true
        if(assignmentType == "StaffAssignment"){
        }
        
        
        PopupChoosePickerView.isHidden = true
        print("SchoolDetailDict\(SchoolDetailDict)")
        if checkSchoolID == "1" {
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            print("SchoolId\(SchoolId)")
            print("StaffId\(StaffId)")
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
            
        }else{
            
            
            
            let userDefaults = UserDefaults.standard
            
            SchoolId = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
            StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)!
            
        }
        countryCoded =  UserDefaults.standard.object(forKey: COUNTRY_ID) as! String
        print("URLDATA:",voiceURl)
        
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(StaffAddNewClassVC.notificationReloadData), name: NSNotification.Name(rawValue: "reloadTable"), object:nil)
        
        pickerCategoryArray = ["GENERAL","CLASS WORK","PROJECT","RESEARCH PAPER"]
        print(pickerCategoryArray)
        bisSubject = false
        
        

    }
    
    @objc func notificationReloadData(notification:Notification) -> Void{
        print(SelectedSectionCodeArray)
        MyTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        if(StandardSectionSubjectArray.count == 0)
        {
            if(UtilObj.IsNetworkConnected()){
                self.GetAllStandardSectionSubjectDetailApi()
            }else{
                Util.showAlert("", msg:strNoInternet )
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK:PICKER VIEW
    public func numberOfComponents(in pickerView:  UIPickerView) -> Int
    {
        return 1
        
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(TableString == "Standard")
        {
            return pickerStandardArray.count
            
        }
        else if(TableString == "Subject")
        {
            return pickerSubjectArray.count
            
        }
        else if (TableString == "Category"){
            
            return pickerCategoryArray.count
        }
        
        else
        {
            return pickerSectionArray.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(TableString == "Standard")
        {
            return pickerStandardArray[row]
            
        }
        else if(TableString == "Subject")
        {
            
            return pickerSubjectArray[row]
            
        }
        else if(TableString == "Category"){
            return pickerCategoryArray[row]
        }
        else
        {
            return pickerSectionArray[row]
            
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(TableString == "Standard")
        {
            selectedStandardRow = row;
            
        }
        else if(TableString == "Section")
        {
            selectedSectionRow = row
        }
        else if(TableString == "Subject")
        {
            selectedSubjectRow = row
        }
        else if (TableString == "Category"){
            selectedCategoryRow = row
        }
        
    }
    //MARK: TABLEVIEW  DELEGATE
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(bisSubject){
            return SectionTitleArray.count
        }else{
            return SectionTitleArray.count - 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 1)
        {
            return pickerSectionArray.count
        }
        else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 55
        }else{
            return 40
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StaffAddNewClassTVCell", for: indexPath) as! StaffAddNewClassTVCell
        cell.SubjectView.backgroundColor = UIColor.white
        if(indexPath.section == 1)
        {
            cell.getSubjectButton.isHidden = true
            let sectionCode = SectionCodeArray[indexPath.row]
            if(SelectedSectionCodeArray.contains(sectionCode)){
                cell.SelectionImage.image = UIImage(named: "CheckBoximage")
            }else{
                cell.SelectionImage.image = UIImage(named: "UnChechBoxImage")
            }
            cell.BorderImage.isHidden = true
            
            cell.SubjectView.layer.cornerRadius = 0
            cell.SubjectView.layer.masksToBounds = true
            cell.SubjectView.layer.shadowOpacity = 0.7
            cell.SubjectView.layer.shadowOffset = CGSize.zero
            cell.SubjectView.layer.shadowRadius = 4
            cell.SubjectView.layer.shadowColor = UIColor.black.cgColor
            cell.SchoolNameLbl.isHidden = false
            cell.SubjectView.isHidden = false
            cell.SchoolNameLbl.text = pickerSectionArray[indexPath.row]
            
        }else if(indexPath.section == 2)
        {
            if(indexPath.row == 0){
                cell.getSubjectButton.isHidden = false
                cell.getSubjectButton.layer.cornerRadius = 3
                cell.getSubjectButton.layer.masksToBounds = true
                cell.SubjectView.backgroundColor = UIColor.clear
                cell.contentView.bringSubviewToFront(cell.SelectionImage)
                cell.BorderImage.isHidden = true
                if(cell.getSubjectButton.isHidden){
                    
                }
                cell.SchoolNameLbl.isHidden = true
            }
            
            
        }
        else{
            cell.SchoolNameLbl.isHidden = false
            cell.SubjectView.isHidden = false
            cell.getSubjectButton.isHidden = true
            
            if(indexPath.section == 0)
            {
                cell.SchoolNameLbl.text = SelectedStandardString
            }else if(indexPath.section == 3){
                cell.SchoolNameLbl.text = SelectedSubjectString
            }
            
            cell.BorderImage.isHidden = false
            cell.SubjectView.layer.cornerRadius = 3
            cell.SubjectView.layer.masksToBounds = true
            cell.SubjectView.layer.shadowOpacity = 0.7
            cell.SubjectView.layer.shadowOffset = CGSize.zero
            cell.SubjectView.layer.shadowRadius = 4
            cell.SubjectView.layer.shadowColor = UIColor.black.cgColor
            cell.SelectionImage.image = UIImage(named: "Downarrow")
        }
        
        cell.getSubjectButton.tag = indexPath.row
        UtilObj.printLogKey(printKey: "SelectedSectionCodeArray", printingValue: SelectedSectionCodeArray)
        cell.getSubjectButton.addTarget(self, action: #selector(buttonSelected), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        let headerLabel = UILabel()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            headerView.frame = CGRect(x: 0, y: 0, width:
                                        tableView.bounds.size.width, height: 30)
            headerLabel.frame = CGRect(x: 0, y: 10, width:
                                        tableView.bounds.size.width, height: 35)
            headerLabel.font = UIFont(name: "Verdana", size: 20)
        }
        else
        {
            
            headerView.frame = CGRect(x: 0, y: 0, width:
                                        tableView.bounds.size.width, height: 20)
            headerLabel.frame = CGRect(x: 0, y: 10, width:
                                        tableView.bounds.size.width, height: 25)
            headerLabel.font = UIFont(name: "Verdana", size: 15)
            
            
        }
        headerLabel.textColor = UIColor.white
        headerLabel.text = SectionTitleArray[section] as! String
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 40
        }else{
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.MyTableView.cellForRow(at: indexPath) as! StaffAddNewClassTVCell
        if(indexPath.section == 0){
            MyPickerView.selectRow(selectedStandardRow, inComponent: 0, animated: true)
            self.actionSelectStandard()
        }else if(indexPath.section == 1){
            let sectionCode = SectionCodeArray[indexPath.row]
            if(SelectedSectionCodeArray.contains(sectionCode)){
                SelectedSectionCodeArray.remove(sectionCode)
                cell.SelectionImage.image = UIImage(named: "UnChechBoxImage")
            }else{
                SelectedSectionCodeArray.add(sectionCode)
                cell.SelectionImage.image = UIImage(named: "CheckBoximage")
            }
            if(assignmentType == "StaffAssignment" ){
                if(SelectedSectionCodeArray.count  == 1){
                    self.SendAssigmentView.isHidden = false
                }else{
                    self.SendAssigmentView.isHidden = true
                }
            }
            
        }else if(indexPath.section == 2){
            
        }
        else if(indexPath.section == 3){
            MyPickerView.selectRow(selectedSubjectRow, inComponent: 0, animated: true)
            self.actionSelectSubject()
            
        }
        
        UtilObj.printLogKey(printKey: "SelectedSectionCodeArray", printingValue: SelectedSectionCodeArray)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = self.MyTableView.cellForRow(at: indexPath) as! StaffAddNewClassTVCell
        if(indexPath.section == 1)
        {
            
            let sectionCode = SectionCodeArray[indexPath.row]
            if(SelectedSectionCodeArray.contains(sectionCode)){
                SelectedSectionCodeArray.remove(sectionCode)
                cell.SelectionImage.image = UIImage(named: "UnChechBoxImage")
            }else{
                SelectedSectionCodeArray.add(sectionCode)
                cell.SelectionImage.image = UIImage(named: "CheckBoximage")
            }
            
            if(assignmentType == "StaffAssignment" ){
                if(SelectedSectionCodeArray.count == 1){
                    self.SendAssigmentView.isHidden = false
                }else{
                    self.SendAssigmentView.isHidden = true
                }
                
            }
            
        }
        UtilObj.printLogKey(printKey: "DESelectedSectionCodeArray", printingValue: SelectedSectionCodeArray)
    }
    
    @objc func buttonSelected(sender: UIButton){
        print(sender.tag)
        
        if(SelectedSectionCodeArray.count > 0)
        {
            bisSubject = true
            MyTableView.reloadData()
            if(UtilObj.IsNetworkConnected())
            {
                GetCommonSubjectForSections()
                
            }
            else
            {
                Util.showAlert("", msg:strNoInternet )
            }
        }else{
            Util.showAlert("", msg: LanguageDict["alert_section"] as? String)
        }
        
    }
    
    //MARK: BUTTON ACTION
    
    func actionSelectCategory(){
        TableString = "Category"
        PickerTitleLabel.text = LanguageDict["select_category"] as? String
        self.MyPickerView.reloadAllComponents()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PopupChoosePickerView.frame.size.height = 300
            PopupChoosePickerView.frame.size.width = 350
            
        }
        
        //        G3
        
        
        
        PopupChoosePickerView.center = view.center
        PopupChoosePickerView.alpha = 1
        PopupChoosePickerView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(PopupChoosePickerView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.PopupChoosePickerView.transform = .identity
        })
        
        
        print("StaffAddNEwClassVcccfcf111")
        
        
    }
    
    func actionSelectSection()
    {
        TableString = "Section"
        PickerTitleLabel.text = LanguageDict["select_section"] as? String
        self.MyPickerView.reloadAllComponents()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PopupChoosePickerView.frame.size.height = 300
            PopupChoosePickerView.frame.size.width = 350
            
        }
        popupChooseStandard = KLCPopup(contentView: PopupChoosePickerView, showType: KLCPopupShowType.none , dismissType:KLCPopupDismissType.none,maskType: KLCPopupMaskType.dimmed , dismissOnBackgroundTouch:  false , dismissOnContentTouch: false )
        popupChooseStandard.show()
        
    }
    func actionSelectStandard()
    {
        TableString = "Standard"
        PickerTitleLabel.text = LanguageDict["select_standard"] as? String
        
        self.MyPickerView.reloadAllComponents()
        
        if(pickerStandardArray.count > 0)
        {
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                PopupChoosePickerView.frame.size.height = 300
                PopupChoosePickerView.frame.size.width = 350
            }
            PopupChoosePickerView.isHidden = false
            //
            popupChooseStandard.show()
        }
        else
        {
            Util.showAlert(LanguageDict["alert"] as? String, msg: LanguageDict["no_students"] as? String)
        }
        
    }
    
    func actionSelectSubject() {
        TableString = "Subject"
        PickerTitleLabel.text = LanguageDict["select_subject"] as? String
        self.ChooseSubject()
    }
    func UpdateStandardValue(StandardName : String)
    {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = self.MyTableView.cellForRow(at: indexPath) as! StaffAddNewClassTVCell
        cell.SchoolNameLbl.text = StandardName
        SelectedSubjectDetail = [String:Any]() as NSDictionary
        pickerSubjectArray = []
        bisSubject = false
        MyTableView.reloadData()
        
    }
    
    func UpdateSubjectValue(SubjectName : String)
    {
        let indexPath = IndexPath(row: 0, section: 3)
        let cell = self.MyTableView.cellForRow(at: indexPath) as! StaffAddNewClassTVCell
        cell.SchoolNameLbl.text = SubjectName
        
    }
    func UpdateCategoryValue(CategoryName : String){
        let indexPath = IndexPath(row: 0, section: 1)
        let cell = self.MyTableView.cellForRow(at: indexPath) as! StaffAddNewClassTVCell
        cell.SchoolNameLbl.text = CategoryName
    }
    
    
    func ChooseSubject()
    {
        PopupChoosePickerView.isHidden = false
        if(pickerStandardArray.count > 0)
        {
            if(pickerSubjectArray.count > 0)
            {
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    PopupChoosePickerView.frame.size.height = 300
                    
                    PopupChoosePickerView.frame.size.width = 350
                    
                    
                }
                self.MyPickerView.reloadAllComponents()
                PopupChoosePickerView.isHidden = false
                //
                
                popupChooseStandard.show()
            }
            else
            {
                Util.showAlert("", msg: LanguageDict["no_subject"] as? String)
            }
            
        }else
        {
            Util.showAlert("", msg: LanguageDict["alert_subject"] as? String)
        }
        
        
    }
    
    //MARK: BUTTON ACTIONS
    
    
    
    //assignmentType
    @IBAction func actionStudentButton(_ sender: UIButton){
        if(SelectedSectionCodeArray.count > 0  ){
            if(SelectedSubjectDetail.count > 0){
                print(SelectedSubjectDetail)
                sendAssignmentDict["isentireSection"] = "0"
                if(SelectedSubjectDetail["SubjectID"] != nil) {
                    sendAssignmentDict["SubCode"] = String(describing: SelectedSubjectDetail["SubjectID"]!)
                    sectionIDNode = "SubjectID"
                }
                
                if (SelectedSubjectDetail["SubjectId"] != nil){
                    sendAssignmentDict["SubCode"] = String(describing: SelectedSubjectDetail["SubjectId"]!)
                    sectionIDNode = "SubjectId"
                }
                if(sendAssignmentDict["SubCode"]  as! String != "0"){
                    sendAssignmentDict[COUNTRY_CODE] = strCountryCode
                    self.getSelectedSectionName(sectionCode: SelectedSectionCodeArray[0] as! String)
                    
                    let studentVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectstudentVC") as! SelectstudentVC
                    studentVC.SenderNameString = "SendAssignment"
                    studentVC.SchoolId = SchoolId
                    studentVC.StaffId = StaffId
                    studentVC.urlData = VoiceurlData
                    studentVC.pdfData = self.pdfData
                    studentVC.imagesArray = self.imagesArray
                    studentVC.SectionStandardName = SelectedStandardString + " - " +  SelectedSectionName
                    studentVC.sendAssignmentDict = self.sendAssignmentDict
                    studentVC.SelectedSectionCode = SelectedSectionCodeArray[0] as! String
                    
                    self.present(studentVC, animated: false, completion: nil)
                    
                }else{
                    self.showAlert(alert: "", message: "No Subjects Found!")
                }
            }else{
                ChooseSubject()
            }
            
        }
        else{
            Util.showAlert("", msg: LanguageDict["alert_section"] as? String)
        }
        
    }
    @IBAction func actionSendButton(_ sender: UIButton){
        if(SelectedSectionCodeArray.count > 0)
        {
            if(assignmentType == "StaffAssignment")
            {
                if(SelectedSubjectDetail.count > 0){
                    let sectionCodeArrayString  =  SelectedSectionCodeArray.componentsJoined(by: "~")
                    sendAssignmentDict["receiverId"] = sectionCodeArrayString
                    sendAssignmentDict[COUNTRY_CODE] = strCountryCode
                    sendAssignmentDict["isentireSection"] = "1"
                    if (SelectedSubjectDetail["SubjectID"] != nil){
                        sendAssignmentDict["SubCode"] = String(describing: SelectedSubjectDetail["SubjectID"]!)
                    }
                    
                    if (SelectedSubjectDetail["SubjectId"] != nil){
                        sendAssignmentDict["SubCode"] = String(describing: SelectedSubjectDetail["SubjectId"]!)
                    }
                    
                    if(sendAssignmentDict["SubCode"]  as! String != "0"){
                        
                        if(String(describing: sendAssignmentDict["AssignmentType"]!) == "SMS"){
                            SendTextAssignmentApi()
                        }else  if(String(describing: sendAssignmentDict["AssignmentType"]!) == "VOICE"){
                            SendVoiceAssignmentApi()
                            
                        }else  if(String(describing: sendAssignmentDict["AssignmentType"]!) == "Image"){
                            
                            
                            self.getImageURL(images: self.imagesArray as! [UIImage])
                            
                        }else  if(String(describing: sendAssignmentDict["AssignmentType"]!) == "PDF"){
                            
                            self.uploadPDFFileToAWS(pdfData: pdfData!)
                        }
                    }else{
                        self.showAlert(alert: "", message: "No Subjects Found!")
                    }
                }else{
                    ChooseSubject()
                }
            }
            else{ for i in 0..<SelectedSectionCodeArray.count
                {
                let mystring = SelectedSectionCodeArray[i] as? String
                let StudentDic:NSDictionary = ["ID" : mystring!]
                SectionIds = mystring
                SectionIdArr.add(StudentDic)
                ChoosenSectionIDArray.append(StudentDic)
                print(ChoosenSectionIDArray)
                
            }
                if(UtilObj.IsNetworkConnected())
                {
                    if(SendedScreenNameStr == "TextHomeWork")
                    {
                        if(SelectedSubjectDetail.count > 0){
                            if(HomeWorkPdf == "Image"){
                                
                                
                                
                                print("HomeWorkImage == Image")
                                self.getImageURL(images: self.imagesArray as! [UIImage])
                            }else if(HomeWorkPdf == "Pdf"){
                                print("HomeWorkPdf == Pdf")
                                print("pdfDataty",pdfData)
                                self.uploadPDFFileToAWS(pdfData: pdfData!)
                            }
                            else if(HomeWorkPdf == "Voice"){
                                print("HomeWorkPdf == Voice")
                                
                                print("SelectedSectionCodeArray12rr4567imageUrlArray : ",imageUrlArray)
                                
                                
                                Awws3Voice(URLPath: voiceURl)
                                
                            } else if(HomeWorkPdf == "Text"){
                                self.SendTextHomeWorkApi()
                            }
                            else{
                                self.SendTextHomeWorkApi()
                            }
                            
                        }else{
                            
                            
                            ChooseSubject()
                        }
                    }
                    else if(SendedScreenNameStr == "VoiceHomeWork")
                    {
                        if(SelectedSubjectDetail.count > 0){
                            self.SendVoiceHomeWorkApi()
                        }else{
                            ChooseSubject()
                        }
                        
                    }
                    else if(SendedScreenNameStr == "ExamTestHomeWork")
                    {
                        self.SendExamTestHomeWorkApi()
                    }
                    else if(SendedScreenNameStr == "OnlineMeetingVC")
                    {
                        self.SendOnlineMeetingApi()
                    }
                    
                }
                else
                {
                    Util.showAlert("", msg:strNoInternet )
                }
            }
        }else{
            Util.showAlert("", msg: LanguageDict["alert_section"] as? String)
        }
        
    }
    
    @IBAction func actionOk(_ sender: UIButton) {
        
        if(TableString == "Standard")
        {
            
            SectionCodeArray.removeAll()
            SelectedSectionCodeArray.removeAllObjects()
            SelectedStandardString = pickerStandardArray[selectedStandardRow]
            UpdateStandardValue(StandardName: SelectedStandardString)
            
            let sectionarray:Array = DetailofSectionArray[selectedStandardRow] as! [Any]
            let SubjectArray:Array = DetailedSubjectArray[selectedStandardRow] as! [Any]
            UtilObj.printLogKey(printKey: "sectionarray", printingValue: sectionarray)
            UtilObj.printLogKey(printKey: "SubjectArray", printingValue: SubjectArray)
            var sectionNameArray :Array = [String]()
            var SubjectNameArray :Array = [String]()
            SectionArray = NSMutableArray(array: sectionarray);
            PopupChoosePickerView.isHidden = true
            if(sectionarray.count > 0)
            {
                for var i in 0..<sectionarray.count
                {
                    let dicResponse :NSDictionary = sectionarray[i] as! NSDictionary
                    sectionNameArray.append(dicResponse["SectionName"] as! String)
                    SectionCodeArray.append(String(describing: dicResponse["SectionId"]!))
                }
                pickerSectionArray = sectionNameArray
                
            }else{
                pickerSectionArray = []
            }
            MyTableView.reloadData()
            
            
        }
        
        else if(TableString == "Section")
        {
            
        }
        else if(TableString == "Subject")
        {
            UtilObj.printLogKey(printKey: "mainSubjectArray", printingValue: mainSubjectArray)
            UtilObj.printLogKey(printKey: "DetailedSubjectArray", printingValue: DetailedSubjectArray)
            
            if(mainSubjectArray.count > 0)
            {
                SelectedSubjectDetail = mainSubjectArray[selectedSubjectRow]  as! NSDictionary
                UtilObj.printLogKey(printKey: "SelectedSubjectDetail", printingValue: SelectedSubjectDetail)
                SelectedSubjectString = pickerSubjectArray[selectedSubjectRow]
                UpdateSubjectValue(SubjectName: SelectedSubjectString)
                PopupChoosePickerView.isHidden = true
            }else{
                Util.showAlert("", msg: LanguageDict["no_subject"] as? String)
            }
            
        }
        popupChooseStandard.dismiss(true)
        
    }
    @IBAction func actionCancel(_ sender: UIButton) {
        popupChooseStandard.dismiss(true)
        PopupChoosePickerView.isHidden = true
    }
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    //MARK: API CALLING
    func GetAllStandardSectionSubjectDetailApi()
    {
        showLoading()
        strApiFrom = "GetAllStandardSectionSubjectDetailApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
        print(requestStringer)
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolId" : SchoolId,"StaffID" : StaffId, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        print(myString)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetAllStandardSectionSubjectDetailApi")
    }
    
    
    
    func SendTextHomeWorkApi()
    {
        print("HomeWorkPdf:",HomeWorkPdf)
        DispatchQueue.main.async { [self] in
            strApiFrom = "SendTextHomeWorkApi"
            print("strApiFrom11",strApiFrom)
            
            showLoading()
            
            
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + SEND_TEXT_HOMEWORK
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            var SubjectId =  ""
            if (SelectedSubjectDetail["SubjectID"] != nil){
                SubjectId = String(describing: SelectedSubjectDetail["SubjectID"]!)
            }
            
            if (SelectedSubjectDetail["SubjectId"] != nil) {
                SubjectId = String(describing: SelectedSubjectDetail["SubjectId"]!)
            }
            print("SendHomeWorkPdf",HomeWorkPdf)
            if(HomeWorkPdf == "Text"){
                
                
                var str : [String] = []
                let StudentDic:NSDictionary = [:]
                filepathArray.add(StudentDic)
                selectfilepathArray.append(filepathArray)
                
                
                
                let myDict:NSMutableDictionary = ["CountryID" :strCountryCode,"SchoolID" : SchoolId,"StaffID" : StaffId,"SubCode": SubjectId,"HomeworkTopic": HomeTitleText,"HomeworkText": HomeTextViewText,"Seccode" : ChoosenSectionIDArray, COUNTRY_CODE: strCountryCode ,"FilePath" : str]
                
                let myString = Util.convertDictionary(toString: myDict)
                print("TEXTHOMEWORK1234",myDict)
                //showLoading()
                UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
                apiCall.nsurlConnectionFunction(requestString, myString, "SendTextHomeWorkApi")
                
                
                print("TEXTHOMEW",myDict)
            }else if HomeWorkPdf == "Voice" {
                print("VOICECONDITION")
                print("filepathArray",filepathArray)
                print("ChoosenSectionIDArray",ChoosenSectionIDArray)
                print("insertHomeWorkSeccodeArr",insertHomeWorkSeccodeArr)
                
                
                var HomeWorkSeccodeModal : [InsertHomeWorkSeccode] = []
                
                var  insertHomeWorkSeccodeModal = InsertHomeWorkSeccode()
                
                
                
                insertHomeWorkSeccodeModal.ID = SectionIds
                print("SectionIds",SectionIds)
                HomeWorkSeccodeModal.append(insertHomeWorkSeccodeModal)
                
                
                
                var HomeWorkFilePath : [InsertHomeWorkFilePath] = []
                
                var  InsertHomeWorkFilePath = InsertHomeWorkFilePath()
                
                
                
                InsertHomeWorkFilePath.path = voicePathUrl
                
                
                InsertHomeWorkFilePath.type = "VOICE"
                HomeWorkFilePath.append(InsertHomeWorkFilePath)
                
                
                
                
                
                let modal = InsertHomeWorkModal()
                
                
                
                modal.CountryID = strCountryCode
                modal.StaffID = StaffId
                modal.SchoolID = SchoolId
                modal.SubCode = SubjectId
                modal.HomeworkText = HomeTextViewText
                modal.HomeworkTopic = HomeTitleText
                
                modal.Seccode = HomeWorkSeccodeModal
                modal.FilePath = HomeWorkFilePath
                
                let modal_str = modal.toJSONString()
                print("modal_str123",modal_str)
                hideLoading()
                InsertHomeWorkRequest.call_request(param: modal_str!) {
                    [self]
                    (res) in
                    
                    let modal_response : [InsertHomeWorkResponse] = Mapper<InsertHomeWorkResponse>().mapArray(JSONString: res)!
                    
                    for i in modal_response {
                        if i.Status == 1 {
                            hideLoading()
                            Util.showAlert("", msg: i.Message)
                            self.presentingViewController!.presentingViewController!.presentingViewController?.dismiss(animated: false, completion: {})
                            print("Error3")
                            
                        }else{
                            Util.showAlert("", msg: i.Message)
                        }
                    }
                    
                    
                }
                
                
            }else{
                let myDict:NSMutableDictionary = ["CountryID" :strCountryCode,"SchoolID" : SchoolId,"StaffID" : StaffId,"SubCode": SubjectId,"HomeworkTopic": HomeTitleText,"HomeworkText": HomeTextViewText,"Seccode" : ChoosenSectionIDArray, COUNTRY_CODE: strCountryCode ,"FilePath" : imageUrlArray]
                
                
                let myString = Util.convertDictionary(toString: myDict)
                print("TEXTHOMEWORK1234",myDict)
                
                UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
                apiCall.nsurlConnectionFunction(requestString, myString, "SendTextHomeWorkApi")
                
                
                print("TEXTHOMEW",myDict)
            }
            
            
            
        }
    }
    
    func SendTextAssignmentApi()
    {
        showLoading()
        strApiFrom = "SendAssignmentApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SEND_ASSIGNMENT
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myString = Util.convertDictionary(toString: sendAssignmentDict)
        UtilObj.printLogKey(printKey: "myDict", printingValue: sendAssignmentDict)
        apiCall.callSendTextParms(requestString, myString, "SendTextAssignmentApi")
    }
    
    
    func SendPdfAssignmentApi(){
        DispatchQueue.main.async {
            self.strApiFrom = "SendAssignmentApi"
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + SEND_ASSIGNMENT_NEW
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            self.sendAssignmentDict["FileNameArray"] = self.convertedImagesUrlArray
            let myString = Util.convertDictionary(toString: self.sendAssignmentDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "VoiceToParents")
        }
        
    }
    
    func SendImageAssignmentApi(){
        DispatchQueue.main.async {
            self.strApiFrom = "SendAssignmentApi"
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
            let requestStringer = baseUrlString! + SEND_ASSIGNMENT_NEW
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            self.sendAssignmentDict["FileNameArray"] = self.convertedImagesUrlArray
            let myString = Util.convertDictionary(toString: self.sendAssignmentDict)
            apiCall.nsurlConnectionFunction(requestString, myString, "SendAssignmentApi")
        }
        
    }
    
    func SendVoiceAssignmentApi()
    {
        showLoading()
        let VoiceData = NSData(contentsOf: self.VoiceurlData!)
        strApiFrom = "SendAssignmentApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SEND_ASSIGNMENT
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myString = Util.convertDictionary(toString: sendAssignmentDict)
        apiCall.callPassAssignmentParms(requestString, myString, "VoiceToParents",  VoiceData as Data?, "file.mp4")
    }
    
    func SendOnlineMeetingApi()
    {
        showLoading()
        strApiFrom = "SendOnlineMeetingApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + POST_MEETING_STAFF
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //TargetCode
        ChoosenSectionIDArray.removeAll()
        for i in 0..<SelectedSectionCodeArray.count
        {
            let mystring = SelectedSectionCodeArray[i] as? String
            let StudentDic:NSDictionary = ["TargetCode" : mystring!]
            ChoosenSectionIDArray.append(StudentDic)
            print(ChoosenSectionIDArray)
            
        }
        var SubjectId =  ""
        if (SelectedSubjectDetail["SubjectID"]  != nil){
            SubjectId = String(describing: SelectedSubjectDetail["SubjectID"]!)
        }
        
        if (SelectedSubjectDetail["SubjectId"] != nil){
            SubjectId = String(describing: SelectedSubjectDetail["SubjectId"]!)
        }
        
        sendAssignmentDict["subject_id"] = SubjectId
        sendAssignmentDict["Seccode"] = ChoosenSectionIDArray
        let myDict:NSMutableDictionary = sendAssignmentDict
        let myString = Util.convertDictionary(toString: myDict)
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendOnlineMeetingApi")
    }
    func SendExamTestHomeWorkApi()
    {
        showLoading()
        strApiFrom = "SendExamTestHomeWorkApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SEND_EXAM_HOMEWORK
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //TargetCode
        ChoosenSectionIDArray.removeAll()
        for i in 0..<SelectedSectionCodeArray.count
        {
            let mystring = SelectedSectionCodeArray[i] as? String
            let StudentDic:NSDictionary = ["TargetCode" : mystring!]
            ChoosenSectionIDArray.append(StudentDic)
            print(ChoosenSectionIDArray)
            
        }
        var SubjectId =  ""
        if (SelectedSubjectDetail["SubjectID"]  != nil){
            SubjectId = String(describing: SelectedSubjectDetail["SubjectID"]!)
        }
        
        if (SelectedSubjectDetail["SubjectId"] != nil){
            SubjectId = String(describing: SelectedSubjectDetail["SubjectId"]!)
        }
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"SubCode": SubjectId,"ExamName": HomeTitleText,"ExamSyllabus": HomeTextViewText,"Seccode" : ChoosenSectionIDArray, COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendExamTestHomeWorkApi")
    }
    
    func SendVoiceHomeWorkApi()
    {
        showLoading()
        strApiFrom = "SendVoiceHomeWorkApi"
        let VoiceData = NSData(contentsOf: self.VoiceurlData!)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SEND_VOICE_HOMEWORK
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        print("voicehomework\(requestString)")
        var SubjectId =  ""
        if (SelectedSubjectDetail["SubjectID"]  != nil){
            SubjectId = String(describing: SelectedSubjectDetail["SubjectID"]!)
        }
        
        if (SelectedSubjectDetail["SubjectId"] != nil) {
            SubjectId = String(describing: SelectedSubjectDetail["SubjectId"]!)
        }
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Description" : HomeTitleText,"SubCode" : SubjectId,"Duration": durationString ,"Seccode" : ChoosenSectionIDArray, COUNTRY_CODE: strCountryCode]
        
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertDictionary(toString: myDict)
        print("voicehomework\(myString)")
        apiCall.callPassVoiceParms(requestString, myString, "VoiceToParents", VoiceData as Data?)
    }
    
    
    func GetCommonSubjectForSections()
    {
        showLoading()
        strApiFrom = "GetCommonSubjectForSectionsAPI"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_COMMON_SUBJECT_FOR_SECTIONS
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_COMMON_SUBJECT_FOR_SECTIONS
        }
        var targetCodeString = ""
        for i in 0..<SelectedSectionCodeArray.count
        {
            let mystring = SelectedSectionCodeArray[i] as? String
            
            if(targetCodeString.count > 0){
                targetCodeString = targetCodeString + "~" + mystring!
            }else{
                targetCodeString = targetCodeString + mystring!
                
            }
            print(targetCodeString)
            
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffId" : StaffId, "TargetCode": targetCodeString]
        let myString = Util.convertDictionary(toString: myDict)
        UtilObj.printLogKey(printKey: "GetCommonSubjectForSectionsAPI", printingValue: myString!)
        UtilObj.printLogKey(printKey: "GetCommonSubjectForSectionsAPI", printingValue: requestStringer)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "GetCommonSubjectForSectionsAPI")
    }
    
    
    //MARK: API RESPONSE DELEGATE
    @objc func responestring(_ csData: NSMutableArray!, _ pagename: String!)
    {
        print("responestringresponestring")
        hideLoading()
        
        print("strApiFrom",strApiFrom)
        if(csData != nil)
        {
            UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if(strApiFrom.isEqual(to:"GetAllStandardSectionSubjectDetailApi"))
            {
                var dicResponse: NSDictionary = [:]
                var AlertString = String()
                if((csData?.count)! > 0)
                {
                    if let ResponseArray = csData as? NSArray
                    {
                        print(ResponseArray)
                        StandardSectionSubjectArray = ResponseArray
                        DetailedSubjectArray = []
                        DetailofSectionArray = []
                        StandardNameArray = []
                        StandarCodeArray = []
                        SectionCodeArray = []
                        
                        if(StandardSectionSubjectArray.count > 0)
                        {
                            for  i in 0..<StandardSectionSubjectArray.count
                            {
                                
                                dicResponse = StandardSectionSubjectArray[i] as! NSDictionary
                                let CheckstdName = String(describing: dicResponse["Standard"]!)
                                let stdName = Util.checkNil(CheckstdName)
                                let stdcode = String(describing: dicResponse["StandardId"]!)
                                StandarCodeArray.append(stdcode)
                                AlertString = stdcode
                                if(stdName != "" && stdName != "0")
                                {
                                    StandardNameArray.append(stdName!)
                                    DetailofSectionArray.append(dicResponse["Sections"] as! [Any])
                                    DetailedSubjectArray.append(dicResponse["Subjects"] as! [Any])
                                    UtilObj.printLogKey(printKey: "DetailofSectionArray", printingValue: DetailofSectionArray)
                                    UtilObj.printLogKey(printKey: "DetailedSubjectArray", printingValue: DetailedSubjectArray)
                                    pickerStandardArray = StandardNameArray
                                    
                                    
                                    if let sectionarray = DetailofSectionArray[0] as? NSArray
                                    {
                                        SectionArray = NSMutableArray(array: sectionarray)
                                        
                                        var sectionNameArray :Array = [String]()
                                        if(sectionarray.count > 0)
                                        {
                                            for  i in 0..<sectionarray.count
                                            {
                                                let dicResponse : NSDictionary = sectionarray[i] as! NSDictionary
                                                sectionNameArray.append(String(describing: dicResponse["SectionName"]!))
                                                
                                                SectionCodeArray.append(String(describing: dicResponse["SectionId"]!))
                                            }
                                            pickerSectionArray = sectionNameArray
                                        }
                                        MyTableView.reloadData()
                                        
                                    }
                                    
                                    if(pickerStandardArray.count > 0) {
                                        SelectedStandardString = pickerStandardArray[0]
                                        
                                        UpdateStandardValue(StandardName: String(pickerStandardArray[0]))
                                        
                                    }
                                    
                                }else
                                {
                                    Util.showAlert("", msg: AlertString)
                                    dismiss(animated: false, completion: nil)
                                }
                            }
                        }
                        else
                        {
                            Util.showAlert("", msg: strNoRecordAlert)
                            dismiss(animated: false, completion: nil)
                        }
                    }
                    
                }
                else
                {   Util.showAlert("", msg: strNoRecordAlert)
                    dismiss(animated: false, completion: nil)
                    
                }
                
            } else if(strApiFrom.isEqual(to:"SendImageAssignment"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1"){
                        if(apicalled == "1"){
                            apicalled = "0"
                            Util.showAlert("", msg: myalertstring)
                            let loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
                            if(loginAsName == "Principal"){
                                
                                if(appDelegate.LoginSchoolDetailArray.count > 1){
                                    self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                }else{
                                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                }
                            }else{
                                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                            }
                        }
                        
                    }else{
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                }else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else if(strApiFrom.isEqual(to:"GetCommonSubjectForSectionsAPI"))
            {
                
                if((csData?.count)! > 0)
                {
                    if let SubjectArray = csData as? NSArray
                    {
                        var SubjectNameArray :Array = [String]()
                        mainSubjectArray = []
                        selectedSubjectRow = 0
                        if(SubjectArray.count > 0)
                        {
                            pickerSubjectArray = []
                            SubjectCodeArray = []
                            mainSubjectArray = SubjectArray
                            for  i in 0..<SubjectArray.count
                            {
                                let dicResponse : NSDictionary = SubjectArray[i] as! NSDictionary
                                SubjectNameArray.append(String(describing: dicResponse["SubjectName"]!))
                                
                                if (dicResponse["SubjectID"] != nil) {
                                    SubjectCodeArray.append(String(describing: dicResponse["SubjectID"]!))
                                }
                                
                                if (dicResponse["SubjectId"] != nil){
                                    SubjectCodeArray.append(String(describing: dicResponse["SubjectId"]!))
                                }
                                
                            }
                            pickerSubjectArray = SubjectNameArray
                            let dicResponse :NSDictionary = SubjectArray[0] as! NSDictionary
                            SelectedSubjectDetail = dicResponse
                            
                            let SubjectName = String (describing: dicResponse["SubjectName"]!)
                            // UpdateStandardValue(StandardName: String(pickerStandardArray[0]))
                            UpdateSubjectValue(SubjectName: SubjectName)
                            SelectedSubjectString = SubjectName
                            
                            
                        }
                        
                        
                    }
                    
                    
                }
            }
            else if(strApiFrom.isEqual(to:"SendTextHomeWorkApi"))
            {
                print("API SUCCESS")
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    print(arrayDatas)
                    dicResponse = arrayDatas[0] as! NSDictionary
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1")
                    {
                        print("Error4")
                        Util.showAlert("", msg: myalertstring)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        let nc = NotificationCenter.default
                        nc.post(name: NSNotification.Name(rawValue: "comeBackMenu"), object: nil)
                        print("Error3")
                    }
                    else
                    {
                        print("Error2")
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                else{
                    print("Error1")
                    Util.showAlert("", msg: strSomething)
                }
                
                
            }
            else if(strApiFrom.isEqual(to:"SendAssignmentApi"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    if(arrayDatas.count > 0){
                        
                        if  let dicRes = arrayDatas[0] as? NSDictionary {
                            dicResponse = dicRes
                            
                            
                            dicResponse = arrayDatas[0] as! NSDictionary
                            let myalertstring = String(describing: dicResponse["Message"]!)
                            let mystatus = String(describing: dicResponse["Status"]!)
                            
                            if(mystatus == "1")
                            {
                                Util.showAlert("", msg: myalertstring)
                                let loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
                                if(loginAsName == "Principal"){
                                    //  self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                                    if(appDelegate.LoginSchoolDetailArray.count > 1){
                                        self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                    }else{
                                        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                                    }
                                }else{
                                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                                }
                                
                                let nc = NotificationCenter.default
                                nc.post(name: NSNotification.Name(rawValue: "comeBackMenu"), object: nil)
                                
                            }
                            else
                            {
                                Util.showAlert("", msg: myalertstring)
                                dismiss(animated: false, completion: nil)
                                
                            }
                            
                        }
                        else{
                            Util.showAlert("", msg: strSomething)
                        }
                    }
                    else{
                        Util.showAlert("", msg: strSomething)
                    }
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
                
            }
            else if(strApiFrom.isEqual(to:"SendOnlineMeetingApi"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1")
                    {
                        Util.showAlert("", msg: myalertstring)
                        let loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
                        if(loginAsName == "Principal"){
                            self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        }else{
                            self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        }
                        
                        let nc = NotificationCenter.default
                        nc.post(name: NSNotification.Name(rawValue: "comeBackMenu"), object: nil)
                        
                    }
                    else
                    {
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
                
                
            }
            else if(strApiFrom.isEqual(to:"SendVoiceHomeWorkApi"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1")
                    {
                        Util.showAlert("", msg: myalertstring)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        let nc = NotificationCenter.default
                        nc.post(name: NSNotification.Name(rawValue: "comeBackMenu"), object: nil)
                        
                    }
                    else
                    {
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
                
                
            }
            else if(strApiFrom.isEqual(to:"SendExamTestHomeWorkApi"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["Status"]!)
                    
                    if(mystatus == "1")
                    {
                        Util.showAlert("", msg: myalertstring)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                        let nc = NotificationCenter.default
                        nc.post(name: NSNotification.Name(rawValue: "comeBackMenu"), object: nil)
                        
                    }
                    else
                    {
                        Util.showAlert("", msg: myalertstring)
                        dismiss(animated: false, completion: nil)
                        
                    }
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
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
        Util .showAlert("", msg: strSomething)
        
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
        LanguageDict = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        
        let strStandard : String = LangDict["teacher_atten_standard"] as? String ?? "Standard"
        let strSection : String = LangDict["teacher_atten_sections"] as? String ?? "Section(s)"
        let strSubject : String = LangDict["teacher_atten_subject"] as? String ?? "Subject"
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        SendButton.setTitle(LangDict["teacher_txt_send"] as? String, for: .normal)
        pickerCancelButton.setTitle(LangDict["teacher_cancel"] as? String, for: .normal)
        pickerOkButton.setTitle(LangDict["teacher_btn_ok"] as? String, for: .normal)
        SectionTitleArray = [strStandard,strSection,"",strSubject]
        MyTableView.reloadData()
    }
    
    func getSelectedSectionName(sectionCode : String){
        print(pickerSectionArray)
        
        
        let resultPredicate = NSPredicate(format: "%K CONTAINS[c] %@",sectionIDNode ,sectionCode)
        let arrSearchResults = SectionArray.filter { resultPredicate.evaluate(with: $0) } as NSArray
        
        let sectionArray = NSMutableArray(array: arrSearchResults)
        if(sectionArray.count > 0){
            let Dict : NSDictionary = sectionArray[0] as! NSDictionary
            SelectedSectionName = String(describing: Dict["SectionName"]!)
        }else{
            SelectedSectionName = ""
        }
    }
    
    
    
    //MARK: AWS Upload
    
    func getImageURL(images : [UIImage]){
        showLoading()
        self.originalImagesArray = images
        self.totalImageCount = images.count
        if currentImageCount < images.count{
            self.uploadAWS(image: images[currentImageCount])
        }
    }
    
    func uploadAWS(image : UIImage){
        
        self.showLoading()
        
        var bucketName = ""
        print("countryCoded",countryCoded)
        if countryCoded == "1" {
           
            bucketName = DefaultsKeys.bucketNameIndia
        }else  {
            bucketName = DefaultsKeys.bucketNameBangkok
        }
//        let S3BucketName = "schoolchimes-india"
        let CognitoPoolID = DefaultsKeys.CognitoPoolID
        let Region = AWSRegionType.APSouth1
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:Region,identityPoolId:CognitoPoolID)
        let configuration = AWSServiceConfiguration(region:Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        
        
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".png")
        
        let ext = imageName as String
        
        let fileName = imageNameWithoutExtension
        let fileType = ".png"
        
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
        
        let data = image.jpegData(compressionQuality: 0.9)
        do {
            try data?.write(to: imageURL)
        }
        catch {}
        
        print("awsimageURL",imageURL)
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let  currentDate =   dateFormatter.string(from: Date())
        
        print("currentDate",currentDate)
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = imageURL
        uploadRequest?.key = "communication" + "/" + currentDate +  "/" + ext
        uploadRequest?.bucket = bucketName
        uploadRequest?.contentType = "image/" + ext
        uploadRequest?.acl = .publicRead
        
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { [self] (task) -> AnyObject? in
            
            if let error = task.error {
                self.hideLoading()
                print("Upload failed : (\(error))")
            }
            var imageFilePath = NSMutableArray()
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                    let imageDicthome = NSMutableDictionary()
                    imageDicthome["path"] = absoluteString
                    imageDicthome["type"] = "PDF"
                    let imageDict = NSMutableDictionary()
                    var emptyDictionary = [String: String]()
                    if HomeWorkPdf == "Image" {
                        imageDict["path"] = absoluteString
                        imageDict["type"] = "IMAGE"
                        
                        yourArray1["path"] = absoluteString
                        yourArray1["type"] = "IMAGE"
                        FilePathArrayPath = absoluteString
                        FilePathArrayType = "IMAGE"
                    }else{
                        
                        imageDict["FileName"] = absoluteString
                    }
                    imageFilePath.add(imageDicthome)
                    
                    
                    
                    self.imageUrlArray.add(imageDict)
                    
                    
                    self.currentImageCount = self.currentImageCount + 1
                    if self.currentImageCount < self.totalImageCount{
                        DispatchQueue.main.async {
                            self.getImageURL(images: self.originalImagesArray)
                        }
                    }else{
                        self.convertedImagesUrlArray = self.imageUrlArray
                        
                        filepathArray.removeAllObjects()
                        if HomeWorkType == "1" {
                            
                            
                            filepathArray.add(imageUrlArray)
                            print("SelectedSectionCodeArray12rr : ",imageUrlArray)
                            print("yourArray1 : ",yourArray1)
                            
                            SendTextHomeWorkApi()
                            print("convertedImagesUrlArray",convertedImagesUrlArray)
                            print("HomeWorkPdfType",HomeWorkPdf)
                        }else{
                            
                            self.SendImageAssignmentApi()
                        }
                    }
                }
            }
            
            return nil
        }
    }
    
    
    func uploadPDFFileToAWS(pdfData : NSData){
        self.showLoading()
        var bucketName = ""
        if countryCoded == "1" {
               
                bucketName = DefaultsKeys.bucketNameIndia
            }else  {
                 bucketName = DefaultsKeys.bucketNameBangkok
            }
        
        let S3BucketName = bucketName
                   
        let CognitoPoolID = DefaultsKeys.CognitoPoolID
        let Region = AWSRegionType.APSouth1
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:Region,identityPoolId:CognitoPoolID)
        let configuration = AWSServiceConfiguration(region:Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let currentTimeStamp = Date().currentTimeMillis()
        let imageNameWithoutExtension = "VC-\(currentTimeStamp)"
        let imageName = "\(imageNameWithoutExtension).pdf"
        
        let ext = imageName as String
        
        let fileName = imageNameWithoutExtension
        var fileTypeAws = ".pdf"
        
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
        
        do {
            try pdfData.write(to: imageURL)
        }
        catch {}
        
        print(imageURL)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let  currentDate =   dateFormatter.string(from: Date())
        
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = imageURL
        uploadRequest?.key = "communication" + "/" + currentDate +  "/" + ext
        uploadRequest?.bucket = bucketName
        uploadRequest?.contentType = "application/pdf"
       uploadRequest?.acl = .publicRead
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task, progress) in
            DispatchQueue.main.async(execute: {
            })
        }
        
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                
            })
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadData(pdfData as Data,
                                   bucket: S3BucketName,
                                   key: ext,
                                   contentType: "application/pdf" ,
                                   expression: expression, completionHandler: completionHandler).continueWith { [self] (task) -> Any? in
            if let error = task.error {
                print("Error : \(error.localizedDescription)")
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                print("task URL : ",url)
                
                let publicURL = url?.appendingPathComponent(S3BucketName).appendingPathComponent(ext)
                if let absoluteString = publicURL?.absoluteString {
                    
                    print("Image URL : ",absoluteString)
                    
                    print("HomeWorkType",HomeWorkType)
                    if HomeWorkType == "1" {
                        filepathArray.removeAllObjects()
                        var pdftype : String!
                        pdftype = "PDF"
                        let StudentDic:NSDictionary = ["path" : absoluteString,"type" : pdftype ]
                        filepathArray.add(StudentDic)
                        FilePathArrayPath = absoluteString
                        FilePathArrayType = pdftype
                        
                        self.imageUrlArray.add(StudentDic)
                        selectfilepathArray.append(filepathArray)
                        
                        print("SelectedSectionCodeArray12rr : ",StudentDic)
                        
                        SendTextHomeWorkApi()
                    }else{
                        
                        
                        
                        
                        let imageDict = NSMutableDictionary()
                        imageDict["FileName"] = absoluteString
                        self.imageUrlArray.add(imageDict)
                        self.convertedImagesUrlArray = self.imageUrlArray
                        self.SendPdfAssignmentApi()
                    }
                }
            }else {
                self.hideLoading()
                print("Unexpected empty result.")
            }
            
            return nil
        }
    }
    
    
    func multipartAudio() {
        
        
        
        
        var urlString : String!
        urlString  = voiceURl.absoluteString
        print("urlStringurlString",urlString!)
        
        
        let audioUrl = URL(fileURLWithPath: urlString)
        AWSS3Manager.shared.uploadAudio(audioUrl: audioUrl, progress: { [weak self] (progress) in
            
            guard let strongSelf = self else { return }
            
        }) { [weak self] (uploadedFileUrl, error) in
            
            guard let strongSelf = self else { return }
            if let finalPath = uploadedFileUrl as? String {
                print("finalPath",finalPath)
            } else {
                print("\(String(describing: error?.localizedDescription))")
            }
        }
        
        
        
        
    }
    
    func Awws3Voice(URLPath : URL) {
        
        
        
        let audioUrl = URL(fileURLWithPath: URLPath.path)
        
        AWSS3Manager.shared.uploadAudio(audioUrl: audioUrl, progress: { [weak self] (progress) in
            
            
            
            print("audioUrl!",audioUrl)
            
            guard let strongSelf = self else { return }
            
            
            
        }) { [weak self] (uploadedFileUrl, error) in
            
            
            
            guard let strongSelf = self else { return }
            
            if let finalPath = uploadedFileUrl as? String {
                
                self!.voiceURl = URL(string: finalPath)
                print("finalPath123!",finalPath)
                var pdftype : String!
                pdftype = "VOICE"
                
                self!.filepathArray.removeAllObjects()
                let imageDict = NSMutableDictionary()
                
                imageDict["path"] = self!.voiceURl
                
                
                
                imageDict["type"] = "VOICE"
                
                
                self!.voicePathUrl = self!.voiceURl.absoluteString
                self!.voiceType = "VOICE"
                
                print("voiceURl.path",self!.voiceURl.absoluteString)
                
                
                
                self!.filepathArray.add(imageDict)
                self!.imageUrlArray.add(imageDict)
                self!.SendTextHomeWorkApi()
                
                
            } else {
                
                print("\(String(describing: error?.localizedDescription))")
                
            }
            
        }
        
        
    }
    
    
}


extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
class AWSService {
    var preSignedURLString : String = ""
    
    func getPreSignedURL( S3DownloadKeyName: String)->String{
        let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPreSignedURLRequest.httpMethod = AWSHTTPMethod.GET
        getPreSignedURLRequest.key = S3DownloadKeyName
        getPreSignedURLRequest.bucket = "schoolchimes-india"
        getPreSignedURLRequest.expires = Date(timeIntervalSinceNow: 3600)
        
        
        AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPreSignedURLRequest).continueWith { (task:AWSTask<NSURL>) -> Any? in
            if let error = task.error as NSError? {
                print("Error: \(error)")
                return nil
            }
            self.preSignedURLString = (task.result?.absoluteString)!
            return nil
        }
        return self.preSignedURLString
    }
    
    
    
    
    
    
}





