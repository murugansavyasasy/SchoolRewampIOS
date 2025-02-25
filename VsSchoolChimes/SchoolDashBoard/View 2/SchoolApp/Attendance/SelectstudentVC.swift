//
//  SelectstudentVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 07/08/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

import Alamofire
class SelectstudentVC: UIViewController,Apidelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var normlImageView: UIImageView!
    @IBOutlet weak var sortBigViewHeight: NSLayoutConstraint!
    @IBOutlet weak var sortBigView: UIView!
    @IBOutlet weak var searchHeight: NSLayoutConstraint!
    @IBOutlet weak var setTitleLbl: UILabel!
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var SetTitleBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var sortBtnName: UIButton!
    @IBOutlet weak var sortBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var desendingImgView: UIImageView!
    @IBOutlet weak var assendingImgView: UIImageView!
    @IBOutlet weak var ZtoAImgView: UIImageView!
    @IBOutlet weak var AtoZImgView: UIImageView!
    @IBOutlet weak var DesendingView: UIView!
    @IBOutlet weak var ascendingView: UIView!
    @IBOutlet weak var ZtoAView: UIView!
    @IBOutlet weak var AtoZView: UIView!
    @IBOutlet weak var sortByFullView: UIView!
    @IBOutlet weak var OkButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var SectionLabel: UILabel!
    @IBOutlet weak var SelectStudentLabel: UILabel!
    @IBOutlet weak var TotalNumberOfStudentsLabel: UILabel!
    @IBOutlet weak var SelectAllLabel: UILabel!
    @IBOutlet weak var MyTableView: UITableView!
    @IBOutlet weak var SelectImage: UIImageView!
    @IBOutlet weak var SectionNameLabel: UILabel!
    
  
    var sessionType : String!
    var attendanceType : String!
    
    var SectionDetailDictionary:NSDictionary = [String:Any]() as NSDictionary
    var StandardName = String()
    var SelectedSectionCode = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var strApiFrom = NSString()
    var StaffId = String()
    var SchoolId = String()
    var StudentDetailDictionary:NSDictionary = [String:Any]() as NSDictionary
    var StudentNameArray : Array = [String]()
    var SearchStudentNameArray : Array = [String]()
    var SelectedStudentIDArray : Array = [String]()
    var filteredStudentIDArray : Array = [String]()
    var ChoosenStudentIDArray : Array = [Any]()
    var SelectedStudentNameArray : Array = [String]()
    var StudentIDArray : Array = [String]()
    var StudentCount = Int()
    var SenderNameString = String()
    var StudentAdmissionNoArray : Array = [String]()
    var StudentRollNumberNoArray : Array = [String]()
    var SelectedStudentAdmissionNoArray : Array = [String]()
    var SectionStandardName = String()
    var SelectedDictforApi = [String:Any]() as NSDictionary
    var SelectedSubjectDict = [String:Any]() as NSDictionary
    var LanguageDict : NSDictionary = NSDictionary()
    let UtilObj = UtilClass()
    var HomeTitleText = String()
    var HomeTextViewText = String()
    var durationString = String()
    var assignmentID = String()
    var urlData: URL?
    var uploadImageData : NSData? = nil
    var  SubjectCodeStr = String()
    var ExamTestApiDict : NSMutableDictionary = NSMutableDictionary()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    //Histoty
    var fromView = String()
    var strLanguage = String()
    var voiceHistoryArray = NSMutableArray()
    var imagesArray = NSMutableArray()
    var pdfData : NSData? = nil
    var strFrom = String()
    var sendAssignmentDict = NSMutableDictionary()
    var vimeoVideoDict = NSMutableDictionary()
    var VideoData : NSData? = nil
    var convertedImagesUrlArray = NSMutableArray()
    var currentImageCount = 0
    var totalImageCount = 0
    var imageUrlArray = NSMutableArray()
    var originalImagesArray = [UIImage]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var vimeoVideoURL : URL!
    
    var attendacePassType : Int!
    var  FilterarrayDatas: NSArray = []
    
    @IBOutlet weak var SelectAllButton: UIButton!
    
    @IBOutlet weak var TotalPresentedStudentLabel: UILabel!
    
    var clkickId : Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        sortByFullView.isHidden = true
        searchView.delegate = self
        sortBtnHeight.constant = 0
        searchHeight.constant = 0
       
        sortBigViewHeight.constant = 0
        sortBtnName.isHidden = true
        setTitleLbl.isHidden = true
        sortBigView.isHidden = true
        SetTitleBtnHeight.constant = 0
        normlImageView.isHidden = true
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(AttendanceMessageVC.catchNotification), name: NSNotification.Name(rawValue: "comeBackStud"), object:nil)
        OkButton.isUserInteractionEnabled = false
        SelectAllButton.isSelected = true
        TotalPresentedStudentLabel.text = "0"
        SectionNameLabel.text = SectionStandardName
        //
        if(SenderNameString == "StudentExamTextVC"){
            
            print("StudentExamTextVC",SenderNameString)
            SelectedSectionCode = String(describing: ExamTestApiDict["SectionCode"]!)
            print(SelectedSectionCode)
        }else if(SenderNameString == "ExamTextVC"){
            print("ExamTextVC",SenderNameString)
            
            SelectedSectionCode = String(describing: SectionDetailDictionary["SectionId"]!)
            SubjectCodeStr = String(describing: SelectedSubjectDict["SubjectId"]!)
        } else if(SenderNameString == "StaffAssignment" || SenderNameString == "SendAssignment"){
            
            print("SendAssignment",SenderNameString)
            
        }
        else if (SenderNameString == "AttendanceVC"){
            
         
            MyTableView.separatorStyle = .singleLine
            sortBtnHeight.constant = 35
            searchHeight.constant = 55
            SetTitleBtnHeight.constant = 35
            sortBtnName.isHidden = false
            setTitleLbl.isHidden = false
            normlImageView.isHidden = false
            let nib = UINib(nibName: "AttendTvCell", bundle: nil)
            MyTableView.register(nib, forCellReuseIdentifier: "AttendTvCell")
            
            MyTableView.rowHeight = UITableView.automaticDimension
            MyTableView.estimatedRowHeight = 44.0
            print("AttendaceVcccc",SenderNameString)
            
            SelectedSectionCode = String(describing: SectionDetailDictionary["SectionId"]!)
        }
        else{
            
           
            
           
            print("AttendaceVcccc",SenderNameString)
            
            SelectedSectionCode = String(describing: SectionDetailDictionary["SectionId"]!)
        }
        
        if(StudentNameArray.count == 0){
            if(UtilObj.IsNetworkConnected()){
                self.GetAllStudendOfSectionAPICalling()
            }else{
                Util.showAlert("", msg:strNoInternet )
            }
        }
        
        let Atoz = UITapGestureRecognizer(target: self, action: #selector(AtoZClick))
        AtoZView.addGestureRecognizer(Atoz)
        let ZtoA = UITapGestureRecognizer(target: self, action: #selector(ZtoAClick))
        ZtoAView.addGestureRecognizer(ZtoA)
        let Assendings = UITapGestureRecognizer(target: self, action: #selector(AsendingClick))
        ascendingView.addGestureRecognizer(Assendings)
        let desendings = UITapGestureRecognizer(target: self, action: #selector(DesendingClick))
        DesendingView.addGestureRecognizer(desendings)
        
        sortByFullView.layer.cornerRadius = 10
        sortByFullView.clipsToBounds = true
        
//        let defaults = UserDefaults.standard
//        print(" defaults.string(forKey:DefaultsKeys.sortName)", defaults.string(forKey:DefaultsKeys.sortName))
      
//            userDefault.set(name, forKey: DefaultsKeys.sortName)
       
    }
    
    
    
    
    

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Reset both arrays when the search is empty
            StudentNameArray = SearchStudentNameArray
            StudentIDArray = filteredStudentIDArray
        } else {
            // Filter both the name and ID arrays based on the search text
            StudentNameArray = []
            StudentIDArray = []
            
            for (index, name) in SearchStudentNameArray.enumerated() {
                if name.lowercased().contains(searchText.lowercased()) {
                    StudentNameArray.append(name)
                    StudentIDArray.append(filteredStudentIDArray[index])
                }
            }
        }
        // Reload the table view with filtered data
        MyTableView.reloadData()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        print("scrollViewWillBeginDragging")
        searchView.endEditing(true)
        
    }



    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("searchBarSearchButtonClicked")
        searchView.resignFirstResponder()
        
    }





    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        
       
            
            
            searchBar.resignFirstResponder()
            
            
            
            MyTableView.alpha = 1
            
           
            
            self.MyTableView.reloadData()
       
        
        
        
    }

    
    @IBAction func cancelFilterBtn(_ sender: Any) {
        sortBtnName.isHidden = false
        sortByFullView.isHidden = true
        sortBtnName.isHidden = false
                setTitleLbl.isHidden = false
        searchView.isHidden = false
        sortBigView.isHidden = true
        SetTitleBtnHeight.constant = 0
        normlImageView.isHidden = false
       
    }
    
   
    @IBAction func doneFiltrBtn(_ sender: Any) {
        
        sortBtnName.isHidden = false
                setTitleLbl.isHidden = false
        searchView.isHidden = false
        sortBigView.isHidden = true
        SetTitleBtnHeight.constant = 35
        normlImageView.isHidden = false
       
      
        if clkickId == 1{
            
            sortByFullView.isHidden = true
            
          
          
            
          
            let atozSortedArray = sortFilterArrayByName(ascending: true)
            print("A-to-Z Order:")
            atozSortedArray.forEach { item in
                if let dict = item as? [String: Any],
                  
                   let rollNo = dict["RollNO"] as? String,
                   let studentName = dict["StudentName"] as? String,
                   let studentId = dict["StudentID"]as? String,
                   let admissionNo = dict["StudentAdmissionNo"] as? String {
                    print("RollNO:vgbhjnkm.n,m \(rollNo), Student Name: \(studentName), Admission No: \(admissionNo)")
                    StudentNameArray.append(studentName)
                    StudentAdmissionNoArray.append(admissionNo)
                    StudentRollNumberNoArray.append(rollNo)
                    StudentIDArray.append(studentId)
                    MyTableView.reloadData()
                }
            }
        }else if clkickId == 2{
            sortByFullView.isHidden = true
            
           
           
            let ztoaSortedArray = sortFilterArrayByName(ascending: false)
            print("Z-to-A Order:")
            ztoaSortedArray.forEach { item in
                if let dict = item as? [String: Any],
                   let rollNo = dict["RollNO"] as? String,
                   let studentName = dict["StudentName"] as? String,
                   let studentId = dict["StudentID"]as? String,
                   let admissionNo = dict["StudentAdmissionNo"] as? String {
                    print("RollNO: \(rollNo), Student Name: \(studentName), Admission No: \(admissionNo)")
                    StudentNameArray.append(studentName)
                    StudentAdmissionNoArray.append(admissionNo)
                    StudentRollNumberNoArray.append(rollNo)
                    StudentIDArray.append(studentId)
                  
                    MyTableView.reloadData()
                }
            }
            
            
        }else if clkickId == 3{
            
            sortByFullView.isHidden = true
            
           
            
            let ascendingSortedArray = sortFilterArrayByRollNO(ascending: true)
            print("Ascending Order:")
            ascendingSortedArray.forEach { item in
                if let dict = item as? [String: Any],
                   let rollNo = dict["RollNO"] as? String,
                   let studentName = dict["StudentName"] as? String,
                   let studentId = dict["StudentID"]as? String,
                   let admissionNo = dict["StudentAdmissionNo"] as? String {
                    print("RollNO: \(rollNo), Student Name: \(studentName), Admission No: \(admissionNo)","Student Id: \(studentId)")
                    
                    StudentNameArray.append(studentName)
                    StudentAdmissionNoArray.append(admissionNo)
                    StudentRollNumberNoArray.append(rollNo)
                    StudentIDArray.append(studentId)
                   
                    MyTableView.reloadData()
                    
                }
            }
            
            
        }else if clkickId == 4{
            
            sortByFullView.isHidden = true
            
           
            

            let descendingSortedArray = sortFilterArrayByRollNO(ascending: false)
            print("\nDescending Order:")
            descendingSortedArray.forEach { item in
                if let dict = item as? [String: Any],
                   let rollNo = dict["RollNO"] as? String,
                   let studentName = dict["StudentName"] as? String,
                   let studentId = dict["StudentID"] as? String,
                   let admissionNo = dict["StudentAdmissionNo"] as? String {
                    print("RollNO: \(rollNo), Student Name: \(studentName), Admission No: \(admissionNo)")
                    
                    StudentNameArray.append(studentName)
                    StudentAdmissionNoArray.append(admissionNo)
                    StudentRollNumberNoArray.append(rollNo)
                    StudentIDArray.append(studentId)
                    MyTableView.reloadData()
                }
            }
            
        }
        
    }
    
    
    @IBAction func AtoZClick(){
        
        clkickId = 1
        
     
            
        setTitleLbl.text = "Sort Alphabetically (A → Z)"
      
        var name : String = "Sort Alphabetically (A → Z)"
        
        let userDefault = UserDefaults.standard
        userDefault.set(name, forKey: DefaultsKeys.sortName)
        
        StudentNameArray.removeAll()
        StudentAdmissionNoArray.removeAll()
        StudentRollNumberNoArray.removeAll()
        StudentIDArray.removeAll()
        
        AtoZImgView.image = UIImage(named: "CheckBoximage")
        ZtoAImgView.image = UIImage(named: "UnCheckBoxIcon")
        assendingImgView.image = UIImage(named: "UnCheckBoxIcon")
        desendingImgView.image = UIImage(named: "UnCheckBoxIcon")
        
        
    }
    @IBAction func ZtoAClick(){
        clkickId = 2
        
//
                setTitleLbl.text = "Sort Alphabetically (Z → A)"
       
        
        var name : String = setTitleLbl.text!
        
        let userDefault = UserDefaults.standard
        userDefault.set(name, forKey: DefaultsKeys.sortName)
        StudentNameArray.removeAll()
        StudentAdmissionNoArray.removeAll()
        StudentRollNumberNoArray.removeAll()
        StudentIDArray.removeAll()
        
        AtoZImgView.image = UIImage(named: "UnCheckBoxIcon")
        ZtoAImgView.image = UIImage(named: "CheckBoximage")
        assendingImgView.image = UIImage(named: "UnCheckBoxIcon")
        desendingImgView.image = UIImage(named: "UnCheckBoxIcon")
        
        
    }
    @IBAction func AsendingClick(){
        
        clkickId = 3
       
        
               
        setTitleLbl.text = "Sort by Roll Number (Low → High)"
      
        var name : String = setTitleLbl.text!
        
        let userDefault = UserDefaults.standard
        userDefault.set(name, forKey: DefaultsKeys.sortName)
        StudentNameArray.removeAll()
        StudentAdmissionNoArray.removeAll()
        StudentRollNumberNoArray.removeAll()
        StudentIDArray.removeAll()
        
        AtoZImgView.image = UIImage(named: "UnCheckBoxIcon")
        ZtoAImgView.image = UIImage(named: "UnCheckBoxIcon")
        assendingImgView.image = UIImage(named: "CheckBoximage")
        desendingImgView.image = UIImage(named: "UnCheckBoxIcon")
    
        
        
    }
    @IBAction func DesendingClick(){
       
        clkickId = 4
       

        setTitleLbl.text = "Sort by Roll Number (High → Low)"
        var name : String = setTitleLbl.text!
        
        let userDefault = UserDefaults.standard
        userDefault.set(name, forKey: DefaultsKeys.sortName)
        StudentNameArray.removeAll()
        StudentAdmissionNoArray.removeAll()
        StudentRollNumberNoArray.removeAll()
        StudentIDArray.removeAll()
        
        AtoZImgView.image = UIImage(named: "UnCheckBoxIcon")
        ZtoAImgView.image = UIImage(named: "UnCheckBoxIcon")
        assendingImgView.image = UIImage(named: "UnCheckBoxIcon")
        desendingImgView.image = UIImage(named: "CheckBoximage")
        
        
        
        
        
    }
    @IBAction func filterBtn(_ sender: Any) {
        
        sortByFullView.isHidden = false
        sortBtnName.isHidden = true
        sortBtnName.isHidden = true
                setTitleLbl.isHidden = true
        searchView.isHidden = true
        sortBigView.isHidden = false
        SetTitleBtnHeight.constant = 759
        normlImageView.isHidden = true
        
        
        
    }
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.dismiss(animated: true, completion: nil)
//    }
    func sortFilterArrayByName(ascending: Bool) -> NSArray {
        let sortedArray = FilterarrayDatas.sorted { (obj1, obj2) -> Bool in
            guard
                let dict1 = obj1 as? [String: Any],
                let dict2 = obj2 as? [String: Any],
                let name1 = dict1["StudentName"] as? String,
                let name2 = dict2["StudentName"] as? String
            else {
                return false
            }
            
            return ascending ? (name1 < name2) : (name1 > name2)
        }
        return sortedArray as NSArray
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //MARK: TABLE VIEW
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if SenderNameString == "AttendanceVC"{
            
            return StudentNameArray.count
        }else{
            
            return StudentNameArray.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if SenderNameString == "AttendanceVC"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttendTvCell", for: indexPath) as! AttendTvCell
            
            //        AttendTvCell
            cell.attendendanceType = attendacePassType
            
            cell.StudentNameLabel.text = StudentNameArray[indexPath.row]
            
            if StudentRollNumberNoArray[indexPath.row] == ""{
                
                cell.RollNumLbl.isHidden = true
                cell.defaultRollLbl.isHidden = true
                cell.DefaultrollColun.isHidden = true
            }else{
                
                cell.RollNumLbl.isHidden = false
                cell.defaultRollLbl.isHidden = false
                cell.DefaultrollColun.isHidden = false
                cell.RollNumLbl.text = StudentRollNumberNoArray[indexPath.row]
                
            }
            
            cell.StudentIdLabel.text =  StudentAdmissionNoArray[indexPath.row]
          
            
            
            if(SelectedStudentIDArray.count > 0){
                if(SelectedStudentIDArray.contains(StudentIDArray[indexPath.row])){
                    self.MyTableView.selectRow(at: indexPath, animated: false, scrollPosition:UITableView.ScrollPosition.none)
                }else{
                    self.MyTableView.deselectRow(at: indexPath, animated: false)
                }
            }
            
            
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectStudentTVC", for: indexPath) as! SelectStudentTVC
            
            //        AttendTvCell
            cell.attendendanceType = attendacePassType
            
            cell.StudentNameLabel.text = StudentNameArray[indexPath.row]
            
            cell.StudentIdLabel.text = StudentAdmissionNoArray[indexPath.row]
            
            if(SelectedStudentIDArray.count > 0){
                if(SelectedStudentIDArray.contains(StudentIDArray[indexPath.row])){
                    self.MyTableView.selectRow(at: indexPath, animated: false, scrollPosition:UITableView.ScrollPosition.none)
                }else{
                    self.MyTableView.deselectRow(at: indexPath, animated: false)
                }
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            OkButton.isUserInteractionEnabled = true
            SelectedStudentIDArray.append(StudentIDArray[indexPath.row])
            
            print("SelectedStudentIDArray",SelectedStudentIDArray)
            SelectedStudentNameArray.append(StudentNameArray[indexPath.row])
            StudentCount = SelectedStudentIDArray.count
            TotalPresentedStudentLabel.text = String(StudentCount)
            
            if(StudentCount == 0){
                SelectImage.image = UIImage(named: "UnChechBoxImage")
                SelectAllButton.isSelected = true
            }

    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselecteddata = StudentIDArray[indexPath.row]
        if(SelectedStudentIDArray.contains(deselecteddata))
        {
            if let index = SelectedStudentIDArray.index(of: deselecteddata) {
                SelectedStudentNameArray.remove(at: index)
                SelectedStudentIDArray.remove(at: index)
                
                StudentCount = SelectedStudentIDArray.count
                TotalPresentedStudentLabel.text = String(StudentCount)
                
            }
            
        }
        if(StudentCount == 0){
            OkButton.isUserInteractionEnabled = false
            
            SelectImage.image = UIImage(named: "UnChechBoxImage")
            SelectAllButton.isSelected = true
        }
        
    }
    
    
    //MARK: BUTTON ACTIONS
    func showOkAlert(){
        
        
        let alertController = UIAlertController(title: LanguageDict["alert"] as? String, message:  LanguageDict["submission_alert"] as? String, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: LanguageDict["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            if(self.SenderNameString == "SendAssignment"){
                let mutableArray = NSMutableArray(array: self.SelectedStudentIDArray)
                let studentArrayString  =  mutableArray.componentsJoined(by: "~")
                self.sendAssignmentDict["receiverId"] = studentArrayString
                if(String(describing: self.sendAssignmentDict["AssignmentType"]!) == "SMS"){
                    self.SendTextAssignmentApi()
                }else  if(String(describing: self.sendAssignmentDict["AssignmentType"]!) == "VOICE"){
                    self.SendVoiceAssignmentApi()
                    
                }else  if(String(describing: self.sendAssignmentDict["AssignmentType"]!) == "Image"){
                    self.getImageURL(images: self.imagesArray as! [UIImage])
                    
                }else  if(String(describing: self.sendAssignmentDict["AssignmentType"]!) == "PDF"){
                    self.uploadPDFFileToAWS(pdfData: self.pdfData!)
                }
            }else{
                self.CallForwardAssignmentApi()
            }
            
            
        }
        let cancelAction = UIAlertAction(title: LanguageDict["teacher_cancel"] as? String, style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: BUTTON ACTIONS
    func showSendVimeoAlert(){
        
        
        let alertController = UIAlertController(title: LanguageDict["alert"] as? String, message:  "Are you sure you want to send the Video?", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: LanguageDict["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.vimeoVideoDict["IDS"] = self.ChoosenStudentIDArray
            self.CallUploadVideoToVimeoServer()
            
        }
        let cancelAction = UIAlertAction(title: LanguageDict["teacher_cancel"] as? String, style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func actionOk(_ sender: Any){
        ChoosenStudentIDArray.removeAll()
        if(SenderNameString == "StaffAssignment" || SenderNameString == "SendAssignment" ){
            self.showOkAlert()
            
        }else if(SenderNameString == "VimeoVideoToParents" ){
            for i in 0..<SelectedStudentIDArray.count
            {
                let mystring = SelectedStudentIDArray[i]
                let StudentDic:NSDictionary = ["ID" : mystring]
                ChoosenStudentIDArray.append(StudentDic)
                
            }
            self.showSendVimeoAlert()
            
        }else{
            let confirmVC = self.storyboard?.instantiateViewController(withIdentifier: "SendAttendanceConfirmationVC") as! SendAttendanceConfirmationVC
            confirmVC.StudentNameArray = SelectedStudentNameArray
            confirmVC.AdmissionNoArray = SelectedStudentAdmissionNoArray
            confirmVC.SenderNameStr = SenderNameString
            for i in 0..<SelectedStudentIDArray.count
            {
                let mystring = SelectedStudentIDArray[i]
                let StudentDic:NSDictionary = ["ID" : mystring]
                ChoosenStudentIDArray.append(StudentDic)
                
                
            }
            
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolId, "StaffID" : StaffId,"SubCode" : SubjectCodeStr,"SectionCode": SelectedSectionCode,"ExamName": HomeTitleText,"ExamSyllabus": HomeTextViewText,"IDS": ChoosenStudentIDArray]
            
            ExamTestApiDict["IDS"] = ChoosenStudentIDArray
            
            confirmVC.ExamTestDictforApi = myDict
            confirmVC.ExamTestApiDict = ExamTestApiDict
            confirmVC.CheckAttendanceVCStr = SenderNameString
            confirmVC.StudentIDArray = ChoosenStudentIDArray
            confirmVC.SelectedDictforApi = SelectedDictforApi
            confirmVC.DescriptionString = HomeTitleText
            confirmVC.MessageString = HomeTextViewText
            confirmVC.urlData = urlData
            confirmVC.durationString = durationString
            confirmVC.uploadImageData = uploadImageData
            confirmVC.SelectedSectiondict = SectionDetailDictionary
            
            confirmVC.fromView = self.fromView
            confirmVC.voiceHistoryArray = self.voiceHistoryArray
            confirmVC.strFrom = self.strFrom
            confirmVC.imagesArray = self.imagesArray
            confirmVC.pdfData = self.pdfData
            
            confirmVC.sessionTypeList = sessionType
            confirmVC.attendanceTypeList = attendanceType
            
            
            
            self.present(confirmVC, animated: false, completion: nil)
        }
    }
    
    
    @IBAction func actionCancel(_ sender: Any){
        
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name(rawValue:"reloadTable"), object: nil)
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: ACTION SELECT ALL STUDENT
    func CallUploadVideoToVimeoServer() {
        self.showLoading()
        strApiFrom = "VimeoVidoUpload"
        
        
        let vimeoAccessToken =  appDelegate.VimeoToken
        
        createVimeoUploadURL(authToken: vimeoAccessToken, videoFilePath: vimeoVideoURL) { [self] result in
            switch result {
            case .success(let uploadLink):
                uploadVideoToVimeo(uploadLink: uploadLink, videoFilePath: vimeoVideoURL, authToken: vimeoAccessToken) { [self] result in
                    switch result {
                    case .success:
                        print("Video uploaded successfully!")
                        
                        
                    case .failure(let error):
                        print("Failed to upload video: \(error)")
                        
                        let refreshAlert = UIAlertController(title: "", message: "Failed to upload video", preferredStyle: UIAlertController.Style.alert)
                        
                        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                            
                            
                        }))
                        
                        
                        present(refreshAlert, animated: true, completion: nil)
                        
                        
                    }
                }
            case .failure(let error):
                print("Failed to create upload URL: \(error)")
                
                let refreshAlert = UIAlertController(title: "", message: "Failed to upload video", preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                }))
                
                
                present(refreshAlert, animated: true, completion: nil)
                
                
            }
        }
        
        
    }
    
    
    
    enum UploadResult {
        case success(String)
        case failure(Error)
    }
    
    func getFileSize(at url: URL) -> UInt64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                return fileSize
            }
        } catch {
            print("Error: \(error)")
        }
        return nil
    }
    
    func createVimeoUploadURL(authToken: String, videoFilePath: URL, completion: @escaping (UploadResult) -> Void) {
        
        
        guard let fileSize = getFileSize(at: videoFilePath) else {
            completion(.failure(NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get file size"])))
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(authToken)",
            "Content-Type": "application/json",
            "Accept": "application/vnd.vimeo.*+json;version=3.4"
        ]
        
        var TitleGet =  vimeoVideoDict["Title"] as! String
        var TitleDescriotion = vimeoVideoDict["Description"] as! String
        if TitleGet != "" && TitleGet != nil {
            TitleGet =  vimeoVideoDict["Title"] as! String
        }else{
            TitleGet =  "Test Name"
        }
        if TitleDescriotion != "" &&  TitleDescriotion != nil {
            TitleDescriotion = vimeoVideoDict["Description"] as! String
            
        }else{
            TitleDescriotion =  "Test Description"
        }
        let userDefaults = UserDefaults.standard
        let getDownload = UserDefaults.standard.value(forKey: DefaultsKeys.allowVideoDownload) as? Bool ?? false
        let parameters: [String: Any] = [
            "upload": [
                "approach": "tus",
                "size": "\(fileSize)"
            ],
            "privacy":[
                "view":"unlisted",
                "download": true
            ],
            "embed":[
                "buttons":[
                    "share":"false"
                ]
            ],
            "name": TitleGet,
            "description": TitleDescriotion
        ]
        
        AF.request("https://api.vimeo.com/me/videos", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { [self] response in
                switch response.result {
                case .success(let value):
                    print("Vimeo API Response: \(value)") // Print the full JSON
                    if let json = value as? [String: Any],
                       let upload = json["upload"] as? [String: Any],
                       let uploadLink = upload["upload_link"] as? String {
                        let LinkGet  = json["link"] as! String
                        let embedUrl = json["player_embed_url"] as! String
                        let IFrameLink : String!
                        let embed = json["embed"]! as AnyObject
                        IFrameLink = embed["html"]! as! String
                        
                        
                        
                        
                        vimeoVideoDict["URL"] = LinkGet
                        vimeoVideoDict["Iframe"] = embed["html"]!
                        vimeoVideoDict["videoFileSize"] = DefaultsKeys.videoFilesize
                        
                        print(vimeoVideoDict)
                        self.SendVimeoVideoApi()
                        
                        print("videe=embedUrl",IFrameLink)
                        completion(.success(uploadLink))
                    } else {
                        completion(.failure(NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Upload link not found"])))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func uploadVideoToVimeo(uploadLink: String, videoFilePath: URL, authToken: String, chunkSize: Int = 5 * 1024 * 1024, completion: @escaping (UploadResult) -> Void) {
        guard let fileHandle = try? FileHandle(forReadingFrom: videoFilePath) else {
            completion(.failure(NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to read video file"])))
            return
        }
        print("fileHandleBefore",fileHandle)
        var offset: Int = 0
        let fileSize = fileHandle.seekToEndOfFile()
        fileHandle.seek(toFileOffset: 0)
        
        print("fileHandleBefore",fileHandle)
        func uploadNextChunk() {
            let chunkData = fileHandle.readData(ofLength: chunkSize)
            
            if chunkData.isEmpty {
                fileHandle.closeFile()
                completion(.success(("")))
                return
            }
            
            var request = URLRequest(url: URL(string: uploadLink)!)
            request.httpMethod = "PATCH"
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/offset+octet-stream", forHTTPHeaderField: "Content-Type")
            request.setValue("\(offset)", forHTTPHeaderField: "Upload-Offset")
            request.setValue("1.0.0", forHTTPHeaderField: "Tus-Resumable")
            request.httpBody = chunkData
            
            let uploadTask = URLSession.shared.uploadTask(with: request, from: chunkData) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 204 {
                        offset += chunkSize
                        uploadNextChunk()
                    } else if httpResponse.statusCode == 412 {
                        if let rangeHeader = httpResponse.value(forHTTPHeaderField: "Upload-Offset"), let serverOffset = Int(rangeHeader) {
                            offset = serverOffset
                            uploadNextChunk()
                        } else {
                            let error = NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload chunk: Precondition Failed"])
                            completion(.failure(error))
                        }
                    } else {
                        let error = NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload chunk, status code: \(httpResponse.statusCode)"])
                        completion(.failure(error))
                    }
                }
            }
            
            uploadTask.resume()
        }
        
        uploadNextChunk()
    }
    
    @IBAction func actionSelectedAllStudent(_ sender: Any) {
        
        if(SelectAllButton.isSelected == true){
            StudentCount = StudentNameArray.count
            TotalPresentedStudentLabel.text = String(StudentCount)
            SelectImage.image = UIImage(named: "CheckBoximage")
            SelectAllButton.isSelected = false
            SelectedStudentNameArray = StudentNameArray
            SelectedStudentIDArray = StudentIDArray
            SelectedStudentAdmissionNoArray = StudentIDArray
            OkButton.isUserInteractionEnabled = true
            self.MyTableView.reloadData()
        }else{
            TotalPresentedStudentLabel.text = "0"
            SelectedStudentNameArray.removeAll()
            SelectedStudentIDArray.removeAll()
            SelectImage.image = UIImage(named: "UnChechBoxImage")
            SelectAllButton.isSelected = true
            OkButton.isUserInteractionEnabled = false
            self.MyTableView.reloadData()
        }
    }
    
    func SendPdfAssignmentApi()
    {
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
    
    func SendImageAssignmentApi()
    {
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
    
    func SendVoiceAssignmentApi()
    {
        showLoading()
        let VoiceData = NSData(contentsOf: self.urlData!)
        strApiFrom = "SendAssignmentApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SEND_ASSIGNMENT
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myString = Util.convertDictionary(toString: sendAssignmentDict)
        apiCall.callPassAssignmentParms(requestString, myString, "VoiceToParents",  VoiceData as Data?, "file.mp4")
    }
    
    func GetAllStudendOfSectionAPICalling()
    {
        showLoading()
        strApiFrom = "GetStudentDetail"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + STUDENT_DETAIL
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + STUDENT_DETAIL
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolId" : SchoolId, "TargetCode" : SelectedSectionCode, "StaffID": StaffId]
        UtilObj.printLogKey(printKey: "requestString", printingValue: requestString)
        
        
        
        
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        
        print("myDictmyDictmyDictmyDict",myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetStudentDetail")
    }
    
    func SendVimeoVideoApi()
    {
        showLoading()
        
        strApiFrom = "sendVimeoVideo"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SEND_VIMEO_VIDEO_STUDENT
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myString = Util.convertDictionary(toString: vimeoVideoDict)
        UtilObj.printLogKey(printKey: "myDict", printingValue: vimeoVideoDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "sendVimeoVideo")
        
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
        print("REQ \(requestString) \(myString)")
        apiCall.callSendTextParms(requestString, myString, "SendTextAssignmentApi")
    }
    
    func CallForwardAssignmentApi(){
        showLoading()
        strApiFrom = "forwardAssignmentApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let mutableArr : NSMutableArray = NSMutableArray(array: SelectedStudentIDArray)
        let  sectionArrayString = mutableArr.componentsJoined(by: "~")
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + FORWARD_ASSIGNMENT
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId, "FromAssignmentId":assignmentID,"receiverId" : sectionArrayString, "isentireSection":"0","ProcessBy":StaffId,COUNTRY_CODE: strCountryCode]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SendForwardAssignment")
    }
    
    // MARK: API RESPONSE
    
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        print("RES : \(csData) \(pagename)")
        
        if(csData != nil) {
            //        
            if(strApiFrom.isEqual(to:"sendVimeoVideo"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                var dicResponse: NSDictionary = [:]
                if let arrayDatas = csData as? NSArray
                {
                    dicResponse = arrayDatas[0] as! NSDictionary
                    let myalertstring = String(describing: dicResponse["Message"]!)
                    let mystatus = String(describing: dicResponse["result"]!)
                    
                    if(mystatus == "1")
                    {
                        Util.showAlert("", msg: myalertstring)
                        self.presentingViewController!.presentingViewController!.presentingViewController?.dismiss(animated: false, completion: {})
                        
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
            else if(strApiFrom.isEqual(to: "GetStudentDetail"))
            {
                UtilObj.printLogKey(printKey: "csdata", printingValue: csData!)
                
                var  arrayDatas: NSArray = []
                var dicResponse: NSDictionary = [:]
                arrayDatas = csData!
                var AlertString = String()
                
                StudentIDArray.removeAll()
                StudentNameArray.removeAll()
                StudentAdmissionNoArray.removeAll()
                if let CheckedArray = arrayDatas as? NSArray{
                    
                    FilterarrayDatas = arrayDatas
                    
                    
                    print("FilterarrayDatas",FilterarrayDatas)
                    
                    
                    
                    for var i in 0..<arrayDatas.count
                    {
                        
                    
                        dicResponse = arrayDatas[i] as! NSDictionary
                        if(dicResponse != nil){
                            if(dicResponse["StudentID"] != nil){
                                
                                let studentId : String = Util.checkNil(String( describing: dicResponse["StudentID"]!))
                                
                                AlertString = String( describing: dicResponse["StudentName"]!)
                                
                                if(!studentId.isEmpty && studentId != "0" )
                                {
                                    StudentIDArray.append(String(describing: dicResponse["StudentID"]!))
                                    filteredStudentIDArray.append(String(describing: dicResponse["StudentID"]!))
                                    
                                    
                                    StudentNameArray.append(String(describing: dicResponse["StudentName"]!))
                                    StudentAdmissionNoArray.append(String(describing: dicResponse["StudentAdmissionNo"]!))
                                    StudentRollNumberNoArray.append(String(describing: dicResponse["RollNO"]!))
                                    SearchStudentNameArray.append(String(describing: dicResponse["StudentName"]!))
                                    MyTableView.reloadData()
                                    
                                    let defaults = UserDefaults.standard
                                    
                                  
                                    
                                    if defaults.string(forKey:DefaultsKeys.sortName) == "Sort Alphabetically (A → Z)" {
                                        
                                        clkickId = 1
                                        AtoZClick()
                                        
                                        doneFiltrBtn(self)
                                        
                                    }else if  defaults.string(forKey:DefaultsKeys.sortName) == "Sort Alphabetically (Z → A)"{
                                        
                                        clkickId = 2
                                        ZtoAClick()
                                        doneFiltrBtn(self)
                                    }else if  defaults.string(forKey:DefaultsKeys.sortName) == "Sort by Roll Number (Low → High)"{
                                      
                                        clkickId = 3
                                        AsendingClick()
                                        doneFiltrBtn(self)
                                    }else if  defaults.string(forKey:DefaultsKeys.sortName) == "Sort by Roll Number (High → Low)"{
                                        clkickId = 4
                                        DesendingClick()
                                        doneFiltrBtn(self)
                                    }
                                    
                                }
                                else
                                {
                                    Util.showAlert("", msg: AlertString)
                                    dismiss(animated: false, completion: nil)
                                    
                                }
                            } else
                            {
                                Util.showAlert("", msg: AlertString)
                                dismiss(animated: false, completion: nil)
                                
                            }
                        }else{
                            Util.showAlert("", msg: strSomething)
                        }
                        
                    }
                    let TotalStudent = String(StudentIDArray.count)
                    if(strLanguage == "ar"){
                        TotalNumberOfStudentsLabel.text = TotalStudent  + "/"
                    }else{
                        TotalNumberOfStudentsLabel.text = "/" + TotalStudent
                    }
                }else{
                    Util.showAlert("", msg: strSomething)
                }
                
                
            }
            else if(strApiFrom == "forwardAssignmentApi"){
                if let CheckedDict = csData![0] as? NSDictionary{
                    let alertMessage = CheckedDict["Message"] as! String
                    if(String(describing: CheckedDict["Status"]!) == "1"){
                        Util.showAlert("", msg: alertMessage)
                        self.presentingViewController!.presentingViewController!.presentingViewController?.dismiss(animated: false, completion: {})
                    }else{
                        Util.showAlert("", msg: alertMessage)
                    }
                }else{
                    Util.showAlert("", msg: strSomething)
                }
                
                
            }
            else if(strApiFrom == "SendAssignmentApi"){
                if let CheckedDict = csData![0] as? NSDictionary{
                    let alertMessage = CheckedDict["Message"] as! String
                    if(String(describing: CheckedDict["Status"]!) == "1"){
                        Util.showAlert("", msg: alertMessage)
                        let loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
                        if(loginAsName == "Principal"){
                            self.presentingViewController!.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {})
                        }else{
                            self.presentingViewController!.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {})
                        }
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
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
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
    
    
    
//    func extractNumericRollNO(_ rollNO: String) -> Int {
//        let digits = rollNO.compactMap { $0.isNumber ? Int(String($0)) : nil }
//        return digits.isEmpty ? Int.max : Int(digits.reduce(0, { $0 * 10 + $1 }))
//    }

    
    func extractNumericRollNO(_ rollNO: String) -> Int {
        // Extract digits from the string
        let digits = rollNO.compactMap { $0.isNumber ? Int(String($0)) : nil }
        // Combine the digits into a single number
        return digits.isEmpty ? Int.max : digits.reduce(0) { $0 * 10 + $1 }
    }
    // Sorting function
//    func sortFilterArrayByRollNO(ascending: Bool) -> NSArray {
//        let sortedArray = FilterarrayDatas.sorted { (obj1, obj2) -> Bool in
//            guard
//                let dict1 = obj1 as? [String: Any],
//                let dict2 = obj2 as? [String: Any],
//                let rollNo1 = dict1["RollNO"] as? String,
//                let rollNo2 = dict2["RollNO"] as? String
//            else {
//                return false
//            }
//            
//            let rollNo1Value = rollNo1.isEmpty ? Int.max : extractNumericRollNO(rollNo1)
//            let rollNo2Value = rollNo2.isEmpty ? Int.max : extractNumericRollNO(rollNo2)
//            
//            return ascending ? (rollNo1Value < rollNo2Value) : (rollNo1Value > rollNo2Value)
//        }
//        return sortedArray as NSArray
//    }
//    
//
//    \
    
    
    
    func sortFilterArrayByRollNO(ascending: Bool) -> NSArray {
        let sortedArray = FilterarrayDatas.sorted { (obj1, obj2) -> Bool in
            guard
                let dict1 = obj1 as? [String: Any],
                let dict2 = obj2 as? [String: Any]
            else {
                return false
            }
            
            let rollNo1 = dict1["RollNO"] as? String ?? ""
            let rollNo2 = dict2["RollNO"] as? String ?? ""

            // Handle empty RollNO by assigning a very high or low value
            if rollNo1.isEmpty && rollNo2.isEmpty {
                return false // Keep original order if both are empty
            } else if rollNo1.isEmpty {
                return false // Push empty to the bottom
            } else if rollNo2.isEmpty {
                return true // Push empty to the bottom
            }

            // Extract numeric value from RollNO
            let rollNo1Value = extractNumericRollNO(rollNo1)
            let rollNo2Value = extractNumericRollNO(rollNo2)

            // Sort numerically, ascending or descending
            return ascending ? (rollNo1Value < rollNo2Value) : (rollNo1Value > rollNo2Value)
        }
        return sortedArray as NSArray
    }

   

//    func sortFilterArrayByRollNO(ascending: Bool) -> NSArray {
//        let sortedArray = FilterarrayDatas.sorted { (obj1, obj2) -> Bool in
//            guard
//                let dict1 = obj1 as? [String: Any],
//                let dict2 = obj2 as? [String: Any]
//            else {
//                return false
//            }
//            
//            let rollNo1 = dict1["RollNO"] as? String ?? ""
//            let rollNo2 = dict2["RollNO"] as? String ?? ""
//
//            // Assign a high value for empty RollNO to push it to the bottom
//            let rollNo1Value = rollNo1.isEmpty ? Int.max : extractNumericRollNO(rollNo1)
//            let rollNo2Value = rollNo2.isEmpty ? Int.max : extractNumericRollNO(rollNo2)
//            
//            // Sort based on ascending or descending
//            return ascending ? (rollNo1Value < rollNo2Value) : (rollNo1Value > rollNo2Value)
//        }
//        return sortedArray as NSArray
//    }
//
//    
    
    
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
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
            SelectAllLabel.textAlignment = .left
            SelectStudentLabel.textAlignment = .right
            SectionLabel.textAlignment = .right
            TotalPresentedStudentLabel.textAlignment = .left
            TotalNumberOfStudentsLabel.textAlignment = .right
            SectionNameLabel.textAlignment = .right
            
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            SelectAllLabel.textAlignment = .right
            SelectStudentLabel.textAlignment = .left
            SectionLabel.textAlignment = .left
            TotalPresentedStudentLabel.textAlignment = .right
            TotalNumberOfStudentsLabel.textAlignment = .left
            SectionNameLabel.textAlignment = .left
        }
        SelectAllLabel.text = LangDict["teacher_txt_select"] as? String
        SelectStudentLabel.text = LangDict["teacher_txt_selectStudents"] as? String
        SectionLabel.text = LangDict["teacher_txt_section"] as? String
        
        OkButton.setTitle(LangDict["teacher_btn_ok"] as? String, for: .normal)
        CancelButton.setTitle(LangDict["teacher_cancel"] as? String, for: .normal)
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
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
        
        
        var bucketName = ""
               print("countryCoded",strCountryCode)
               if strCountryCode == "1" {
                  
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
        
        print(imageURL)
        
        let dateFormatter = DateFormatter()
              
              dateFormatter.dateFormat = "yyyy-MM-dd"
              
              let  currentDate =   dateFormatter.string(from: Date())
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = imageURL
        uploadRequest?.key =   "communication" + "/" + currentDate +  "/" + ext
        uploadRequest?.bucket = S3BucketName
        uploadRequest?.contentType = "image/" + ext
        uploadRequest?.acl = .publicRead
        
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { (task) -> AnyObject? in
            
            if let error = task.error {
                self.hideLoading()
                print("Upload failed : (\(error))")
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                    let imageDict = NSMutableDictionary()
                    imageDict["FileName"] = absoluteString
                    self.imageUrlArray.add(imageDict)
                    self.currentImageCount = self.currentImageCount + 1
                    if self.currentImageCount < self.totalImageCount{
                        DispatchQueue.main.async {
                            self.getImageURL(images: self.originalImagesArray)
                        }
                    }else{
                        self.convertedImagesUrlArray = self.imageUrlArray
                        self.SendImageAssignmentApi()
                        
                    }
                }
            }
            else {
                self.hideLoading()
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
    
    func uploadPDFFileToAWS(pdfData : NSData){
        self.showLoading()
        
        var bucketName = ""
               print("countryCoded",strCountryCode)
               if strCountryCode == "1" {
                  
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
        
        
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".pdf")
        
        
        let ext = imageName as String
        
        let fileName = imageNameWithoutExtension
        let fileType = ".pdf"
        
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
        uploadRequest?.key =   "communication" + "/" + currentDate +  "/" + ext
        uploadRequest?.bucket = S3BucketName
        
        uploadRequest?.contentType = "application/pdf"
        uploadRequest?.acl = .publicRead
        
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { (task) -> AnyObject? in
            
            if let error = task.error {
                print("Upload failed : (\(error))")
                self.hideLoading()
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                    let imageDict = NSMutableDictionary()
                    imageDict["FileName"] = absoluteString
                    self.imageUrlArray.add(imageDict)
                    self.convertedImagesUrlArray = self.imageUrlArray
                    self.SendPdfAssignmentApi()
                    
                }
            }
            else {
                self.hideLoading()
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
    
}

