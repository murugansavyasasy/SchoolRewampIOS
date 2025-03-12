//
//  AttendanceMessageVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 18/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//  //

import UIKit
import DropDown
import FSCalendar
import ObjectMapper
class AttendanceMessageVC: UIViewController,Apidelegate,UIPickerViewDelegate ,UIPickerViewDataSource,FSCalendarDelegate, FSCalendarDataSource,UITableViewDelegate,UITableViewDataSource{

    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var attendanceRportHoleView: UIView!
    @IBOutlet weak var attendReportLbl: UILabel!
    @IBOutlet weak var attendMarkDefltLbl: UILabel!
    @IBOutlet weak var reportAttendanceView: UIViewX!
    @IBOutlet weak var attendanceMArkingView: UIViewX!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var calanderHoleView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
   
    @IBOutlet weak var DatePickers: FSCalendar!
    
    @IBOutlet weak var calanderView: UIViewX!
    @IBOutlet weak var markAllView1: UIView!
    
    
    @IBOutlet weak var attendanceLbl2: UILabel!
    
    @IBOutlet weak var sessionTypeHdngLbl: UILabel!
    
    @IBOutlet weak var attendanceTypeHdngLbl: UILabel!
    
    @IBOutlet weak var attendanceTypeView: UIView!
    
    @IBOutlet weak var sessionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sessionTypeLbl: UILabel!
    @IBOutlet weak var attendanceTypeLbl: UILabel!
    @IBOutlet weak var sessionTypeView: UIView!
    
    @IBOutlet weak var PickerTitleLabel: UILabel!
    @IBOutlet weak var SectionView: UIView!
    @IBOutlet weak var StandardView: UIView!
    @IBOutlet weak var MyPickerView: UIPickerView!
    @IBOutlet weak var MarkAllasPresentButton: UIButton!
    @IBOutlet weak var AlertOkLabel: UIButton!
    @IBOutlet weak var AlertCancelLabel: UIButton!
    @IBOutlet weak var AlertMessageLabel: UILabel!
    @IBOutlet weak var AlertConfirmLabel: UILabel!
    @IBOutlet weak var PickerOkButton: UIButton!
    @IBOutlet weak var PickerCancelButton: UIButton!
    @IBOutlet weak var OrLabel: UILabel!
    @IBOutlet weak var SectionLabel: UILabel!
    @IBOutlet weak var StandardLabel: UILabel!
    @IBOutlet weak var AttendanceTitle: UILabel!
    @IBOutlet weak var PopupChooseStandardPickerView: UIView!
    @IBOutlet weak var SectionNameTextField: UITextField!
    @IBOutlet weak var StandardNameTextField: UITextField!
    @IBOutlet weak var OtherViewHeight: NSLayoutConstraint!
    @IBOutlet weak var OtherView: UIView!
    @IBOutlet var AttendanceConfirmPopupView: UIView!
    @IBOutlet weak var SelectStudentButton: UIButton!
    
    var strApiFrom = NSString()
    var StaffId = String()
    var SchoolId = String()
    var loginAsName = String()
    var TableString = String()
    var pickerStandardArray = [String]()
    var pickerSectionArray = [String]()
    var selectedStandardRow = 0;
    var selectedSectionRow = 0;
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var StandarCodeArray:Array = [String]()
    var SectionCodeArray:Array = [String]()
    var StandardNameArray:Array = [String]()
    var DetailofSectionArray:Array = [Any]()
    var popupChooseStandard : KLCPopup  = KLCPopup()
    var popupAttendance : KLCPopup  = KLCPopup()
    var SelectedStandardName = String()
    var SelectedSectionDeatil:NSDictionary = [String:Any]() as NSDictionary
    var SchoolDeatilDict:NSDictionary = [String:Any]() as NSDictionary
    let UtilObj = UtilClass()
    var StandardSectionArray = NSArray()
    var SelectedClassIDString = String()
    var SelectedSectionIDString = String()
    var SelectedDictforApi = [String:Any]() as NSDictionary
    var languageDict = NSDictionary()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var checkSchoolId : String!
    
    var drop_down = DropDown()
    
    var sessionType = "FH"
    var AttendanceType : String!
    var dates = ""
    var data : [reasondetails] = []
    var identifier = "ReportTVCell"
    var Clickid = 1
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        PopupChooseStandardPickerView.isHidden = true
        calanderHoleView.isHidden = true
        attendanceRportHoleView.isHidden  = true
        
         let rowNib = UINib(nibName: identifier, bundle: nil)
        tv.register(rowNib, forCellReuseIdentifier: identifier)
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMM,yyy" // You can customize this format
        let formattedDate = dateFormatter.string(from: currentDate)
        dateLbl.text = formattedDate
        
        
    
      
        
        
        let currentDate1 = Date()
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "dd/MM/yyyy" // You can customize this format
        let formattedDate1 = dateFormatter1.string(from: currentDate1)
        
        DefaultsKeys.SelectedDAte = formattedDate1
        
      
        
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(AttendanceMessageVC.catchNotification), name: NSNotification.Name(rawValue: "comeBack1"), object:nil)
        
        nc.addObserver(self,selector: #selector(AttendanceMessageVC.catchNotification1), name: NSNotification.Name(rawValue: "comeBackMenu"), object:nil)
        
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        if(loginAsName == "Principal")
        {
            
            print("bigIfFF",loginAsName)
            if checkSchoolId == "1" {
                SchoolId =   String(describing: SchoolDeatilDict["SchoolID"]!)
                StaffId = String(describing: SchoolDeatilDict["StaffID"]!)
                
                print("checkSchoolIdifif",checkSchoolId)
            }else{
                
                let userDefaults = UserDefaults.standard
                
                SchoolId = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
                StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)!
                print("checkSchoolIdelse",checkSchoolId)
            }
        }else{
            print("checkSchoolIdELSEE",loginAsName)
            print("SchoolDeatilDict",SchoolDeatilDict)
            if checkSchoolId == "1" {
                SchoolId =   String(describing: SchoolDeatilDict["SchoolID"]!)
                StaffId = String(describing: SchoolDeatilDict["StaffID"]!)
                
                print("checkSchoolIdifif",checkSchoolId)
            }else{
                
                let userDefaults = UserDefaults.standard
                
                SchoolId = userDefaults.string(forKey: DefaultsKeys.SchoolD)!
                StaffId = userDefaults.string(forKey: DefaultsKeys.StaffID)!
                print("checkSchoolIdelse",checkSchoolId)
            }
            
        }
        
        markAllView1.isHidden = true
        sessionHeight.constant = 0
        sessionTypeView.isHidden = true
        sessionTypeHdngLbl.isHidden = true
        attendanceTypeLbl.text = "Full Day"
        
        AttendanceType = "F"
        
        if attendanceTypeLbl.text == "Full Day" {
            sessionType = ""
            sessionHeight.constant = 0
            sessionTypeView.isHidden = true
            sessionTypeHdngLbl.isHidden = true
        }else{
            sessionType = "FH"
            sessionHeight.constant = 40
            sessionTypeView.isHidden = false
            sessionTypeHdngLbl.isHidden = false
        }
        
        let attendanceTypeGes = UITapGestureRecognizer(target: self, action: #selector(attendanceTypeList))
        attendanceTypeView.addGestureRecognizer(attendanceTypeGes)
        
        let attendanceReport = UITapGestureRecognizer(target: self, action: #selector(AttendanceReport))
        reportAttendanceView.addGestureRecognizer(attendanceReport)
        
        let attendanceMarking = UITapGestureRecognizer(target: self, action: #selector(attendanceMArking))
        attendanceMArkingView.addGestureRecognizer(attendanceMarking)
        
       
      
        let dateClick = UITapGestureRecognizer(target: self, action: #selector(calanderClikcVC))
        calanderView.addGestureRecognizer(dateClick)
        
        
        let sessionTypeGes = UITapGestureRecognizer(target: self, action: #selector(sessionTypeList))
        sessionTypeView.addGestureRecognizer(sessionTypeGes)
        
        sessionTypeLbl.text = "First Half"
        attendanceTypeLbl.text = "Select attendance type"
        
    
      
        DatePickers.delegate = self
        DatePickers.dataSource = self
             
             // Optionally, customize the calendar appearance
        DatePickers.appearance.todayColor = .blue
        DatePickers.appearance.selectionColor = .systemBlue
        
     
        
        
    }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
            return data.count
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ReportTVCell
//            
//            cell.fullview.layer.cornerRadius = 20
//         
//            cell.fullview.layer.masksToBounds = true
//            cell.fullview.layer.shadowColor = UIColor.black.cgColor
//            cell.fullview.layer.shadowOpacity = 0.5
//            cell.fullview.layer.shadowOffset = CGSize(width: 4, height: 4)
//            cell.fullview.layer.shadowRadius = 5
//            cell.fullview.layer.masksToBounds = false
            let datadetails : reasondetails = data[indexPath.row]
            
            cell.nameLbl.text =  datadetails.student_name
//            cell.dateLbl.text = datadetails.absent_on
            cell.admisionLbl.text = "Admision No : " + datadetails.admission_no
            
            if datadetails.att_status == "P"{
                
              
                cell.presentImageView.isHidden = false
                cell.presentImageView.image = UIImage(named: "PresentImage")
                cell.presentImageView.tintColor = .green
                cell.notTakeLbl.isHidden = true
                
            }else if datadetails.att_status == "A"{
                
                cell.presentImageView.image = UIImage(named: "AbsentImage")
                cell.presentImageView.tintColor = .red
                cell.notTakeLbl.isHidden = true
                cell.presentImageView.isHidden = false
            }else if datadetails.att_status == "Not taken"{
                
                
                cell.notTakeLbl.isHidden = false
                cell.presentImageView.isHidden = true
                
                cell.notTakeLbl.text = datadetails.att_status
                
            }else{
                
                
                cell.notTakeLbl.isHidden = true
                cell.presentImageView.isHidden = true
                
            }
//            else if datadetails.
            return cell
            
        }
        
      
    @IBAction func AttendanceReport(){
        
        Clickid = 2
        reportAttendanceView.backgroundColor = .systemOrange
        attendReportLbl.textColor = .white
        attendanceMArkingView.backgroundColor = .white
        attendMarkDefltLbl.textColor = .black
        attendanceRportHoleView.isHidden = false
        getAttendenceReport()
    }
    @IBAction func attendanceMArking(){
        Clickid = 1
        attendanceMArkingView.backgroundColor = .systemOrange
        attendMarkDefltLbl.textColor = .white
        reportAttendanceView.backgroundColor =  .white
        attendReportLbl.textColor = .black
        attendanceRportHoleView.isHidden = true
        
        
        
    }
    
    
    func minimumDate(for calendar: FSCalendar) -> Date {
            // Set minimum date to 30 days ago
            let currentDate = Date()
            return Calendar.current.date(byAdding: .day, value: -30, to: currentDate) ?? currentDate
        }

        func maximumDate(for calendar: FSCalendar) -> Date {
            // Set maximum date to today
            return Date()
        }

        // MARK: - FSCalendarDelegate

        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            // Allow selection only if the date is within the last 30 days
            let currentDate = Date()
            let minDate = Calendar.current.date(byAdding: .day, value: -30, to: currentDate)!
            return date >= minDate && date <= currentDate
        }
   
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let result = formatter.string(from: date)
       
        DefaultsKeys.SelectedDAte = result
        
        dates = result
       
        
    }
    
    @IBAction func backbtn(_ sender: Any) {
        
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"

        // Convert the input string to a Date object
        if let date = inputFormatter.date(from: dates) {
            // Create a DateFormatter for the desired output format
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "ddMMM,yyy" // Desired format: 10Sep,204
            
            // Convert the Date object to the desired string format
            let formattedDate = outputFormatter.string(from: date)
            
            print("Formatted Date: \(formattedDate)")
            
            dateLbl.text = formattedDate
        } else {
            print("Invalid date format")
        }
        
        
        calanderHoleView.isHidden = true
        
        if Clickid == 2{
            
            getAttendenceReport()
        }else{
            
            
            
        }
      
        
        
    }
    @IBAction func calanderClikcVC(){
        
        calanderHoleView.isHidden = false
    }
    @objc func datePicked(_ sender: UIDatePicker) {
           let selectedDate = sender.date
//           print("Selected Date: \(selectedDate)")
         
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy" // Set the desired date format

            // Format the selected date
            let formattedDate = dateFormatter.string(from: selectedDate)
            
            // Print or use the formatted date
            print("Selected Date: \(formattedDate)")
        DefaultsKeys.SelectedDAte = formattedDate
        
           self.dismiss(animated: true, completion: nil)
       }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        self.ButtonCornerDesign()
        
        if(StandardSectionArray.count == 0)
        {
            if(UtilObj.IsNetworkConnected())
            {
                self.GetAllSectionCodeapi()
                
            }
            else
            {
                Util.showAlert("", msg:strNoInternet )
            }
        }
    }
    
    func ButtonCornerDesign()
    {
        PopupChooseStandardPickerView.layer.cornerRadius = 8
        PopupChooseStandardPickerView.layer.masksToBounds = true
        StandardView.layer.cornerRadius = 5
        StandardView.layer.masksToBounds = true
        SectionView.layer.cornerRadius = 5
        SectionView.layer.masksToBounds = true
        MarkAllasPresentButton.layer.cornerRadius = 5
        MarkAllasPresentButton.layer.masksToBounds = true
        SelectStudentButton.layer.cornerRadius = 5
        SelectStudentButton.layer.masksToBounds = true
        
    }
    
    
    @objc func catchNotification(notification:Notification) -> Void {
        print("catch notification in text message")
        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBackMenu"), object: nil)
        
    }
    
    
    
    //MARK: PickerView
    
    public func numberOfComponents(in pickerView:  UIPickerView) -> Int  {
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(TableString == "Standard")
        {
            return pickerStandardArray.count
            
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
        else
        {
            
            return pickerSectionArray[row]
            
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if(TableString == "Standard")
        {
            selectedStandardRow = row;
            
            
        }
        else
        {
            selectedSectionRow = row
        }
        
    }
    
    
    
    // MARK: DONE PICKER ACTION
    @IBAction func actionDonePickerView(_ sender: Any)
    {
        if(TableString == "Standard")
        {
            
            print("bigIF")
            StandardNameTextField.text = pickerStandardArray[selectedStandardRow]
            SelectedStandardName = pickerStandardArray[selectedStandardRow]
            
            UtilObj.printLogKey(printKey: "SelectedStandardName", printingValue: SelectedStandardName)
            let sectionarray:Array = DetailofSectionArray[selectedStandardRow] as! [Any]
            var sectionNameArray :Array = [String]()
            if(sectionarray.count > 0)
            {
               
                for i in 0..<sectionarray.count
                {
                    let dicResponse :NSDictionary = sectionarray[i] as! NSDictionary
                    sectionNameArray.append(String(describing: dicResponse["SectionName"]!))
                    SectionCodeArray.append(String(describing: dicResponse["SectionId"]!))
                }
                SectionNameTextField.text = String(sectionNameArray[0])
                
                PopupChooseStandardPickerView.isHidden = true
                pickerSectionArray = sectionNameArray
                
                SelectedSectionDeatil = sectionarray[0] as! NSDictionary
                SelectedSectionIDString = String(describing: SelectedSectionDeatil["SectionId"]!)
                UtilObj.printLogKey(printKey: "SelectedSectionDeatil", printingValue: SelectedSectionDeatil)
                
               
                
            }else{
                
                print("else")
                pickerSectionArray = []
                SectionNameTextField.text = ""
                SelectedSectionIDString = ""
                
            }
            SelectedClassIDString = String(StandarCodeArray[selectedStandardRow])
            
            
            if Clickid == 2{
                
                getAttendenceReport()
                
            }else{
                
                
            }
            
        }else{
            
            print("sections")
            let sectionarray:Array = DetailofSectionArray[selectedStandardRow] as! [Any]
            SelectedSectionDeatil = sectionarray[selectedSectionRow] as! NSDictionary
            UtilObj.printLogKey(printKey: "SelectedSectionDeatil", printingValue: SelectedSectionDeatil)
            SelectedSectionIDString = String(describing: SelectedSectionDeatil["SectionId"]!)
            UtilObj.printLogKey(printKey: "SelectedSectionDeatil", printingValue: SelectedSectionDeatil)
            SectionNameTextField.text = pickerSectionArray[selectedSectionRow]
            PopupChooseStandardPickerView.isHidden = true
            
            
            if Clickid == 2{
                
                getAttendenceReport()
                
            }else{
                
                
            }
        }
        popupChooseStandard.dismiss(true)
        
    }
    
    @IBAction func actionCancelPickerView(_ sender: Any) {
        popupChooseStandard.dismiss(true)
        PopupChooseStandardPickerView.isHidden = true
        
    }
    
    // MARK: CHOOSE STANDARD BUTTON ACTION
    
    @IBAction func actionChooseStandardButton(_ sender: Any) {
        print("actionChooseStandardButton")
        
        TableString = "Standard"
        PickerTitleLabel.text =  languageDict["select_standard"] as? String //"Select Standard"
        PickerTitleLabel.textAlignment = .center
        self.MyPickerView.reloadAllComponents()
        if(pickerStandardArray.count > 0){
            print("pickerStandardArray")
            if(UIDevice.current.userInterfaceIdiom == .pad){
                PopupChooseStandardPickerView.frame.size.height = 300
                PopupChooseStandardPickerView.frame.size.width = 350
            }
            PopupChooseStandardPickerView.isHidden = false
            
            popupChooseStandard.show()
            
            
        }else{
            
            print("pickerStandardArrayELSE")
            Util.showAlert(languageDict["alert"] as? String, msg: languageDict["no_students"] as? String)
        }
    }
    
    // MARK: CHOOSE SECTION BUTTON ACTION
    @IBAction func actionChooseSectionButton(_ sender: Any) {
        print("actionChooseSectionButton")
        
        TableString = "Section"
        PickerTitleLabel.text =  languageDict["select_section"] as? String //"Select Section"
        PickerTitleLabel.textAlignment = .center
        self.MyPickerView.reloadAllComponents()
        if((StandardNameTextField.text?.count)! > 0 && pickerSectionArray.count > 0){
            if(UIDevice.current.userInterfaceIdiom == .pad){
                PopupChooseStandardPickerView.frame.size.height = 300
                PopupChooseStandardPickerView.frame.size.width = 350
            }
            //           
            
            PopupChooseStandardPickerView.isHidden = false
            popupChooseStandard.show()
        }else{
            if(pickerSectionArray.count == 0){
                Util.showAlert(languageDict["alert"] as? String, msg: languageDict["no_section"] as? String)
            }else{
                Util.showAlert(languageDict["alert"] as? String, msg: languageDict["standard_first"] as? String)
            }
            
        }
    }
    
    @IBAction func actionCloseView(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionCancelAttendanceView(_ sender: Any) {
        markAllView1.isHidden = true
        popupAttendance.dismiss(true)
    }
    
    @IBAction func actionOkAttendanceView(_ sender: Any) {
        print("okWorking")
        PopupChooseStandardPickerView.isHidden = true
        if((StandardNameTextField.text?.count)! > 0 && (SectionNameTextField.text?.count)! > 0){
            if(UtilObj.IsNetworkConnected()){
                if attendanceTypeLbl.text == "Half Day" {
                    //
                    if sessionTypeLbl.text == "" {
                        view.makeToast("Please Select Session")
                    }else{
                        self.MarkAllAsPresentAttendanceapi()
                    }
                }else{
                    self.MarkAllAsPresentAttendanceapi()
                }
            }else{
                Util.showAlert("", msg:strNoInternet )
            }
        }else{
            Util.showAlert(languageDict["alert"] as? String, msg: languageDict["select_standard_section_alert"] as? String)
        }
        
        
    }
    
    // MARK: MARK ALL PRESENT BUTTON ACTION
    @IBAction func actionMarkAllAsPresent(_ sender: Any){
        if(UIDevice.current.userInterfaceIdiom == .pad){
            AttendanceConfirmPopupView.frame.size.height = 220
            AttendanceConfirmPopupView.frame.size.width = 350
        }
        markAllView1.isHidden = false
        
        print("actionMarkAllAsPresent")
        //        
        
    }
    
    // MARK: SELECT STUDENT BUTTON ACTION
    @IBAction func actionSelectStudent(_ sender: Any) {
        if attendanceTypeLbl.text == "Half Day" {
            if sessionTypeLbl.text == "" {
                view.makeToast("Please Select Session")
            }else{
                
                
                if((StandardNameTextField.text?.count)! > 0 && (SectionNameTextField.text?.count)! > 0){
                    SelectedDictforApi = ["SchoolID":SchoolId,"StaffID": StaffId,"ClassID": SelectedClassIDString,"SectionID":SelectedSectionIDString]
                    let studentVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectstudentVC") as! SelectstudentVC
                    
                    studentVC.attendacePassType = 1
                    studentVC.SectionStandardName = StandardNameTextField.text! + " - " + SectionNameTextField.text!
                    studentVC.SectionDetailDictionary = SelectedSectionDeatil
                    studentVC.SchoolId = SchoolId
                    studentVC.StaffId = StaffId
                    studentVC.SelectedDictforApi = SelectedDictforApi
                    studentVC.SenderNameString = "AttendanceVC"
                    
                    studentVC.sessionType = sessionType
                    studentVC.attendanceType = AttendanceType
                    
                    
                    self.present(studentVC, animated: false, completion: nil)
                    
                }else{
                    Util.showAlert(languageDict["alert"] as? String, msg: languageDict["select_standard_section_alert"] as? String)
                }
            }
        }
        
        else if attendanceTypeLbl.text == "Select attendance type"{
            
            
            Util.showAlert("Kindly select the attendance type" as? String ,msg:languageDict["select_attendance_type"] as? String)
         
            
            
        }
        
        else{
            if((StandardNameTextField.text?.count)! > 0 && (SectionNameTextField.text?.count)! > 0){
                SelectedDictforApi = ["SchoolID":SchoolId,"StaffID": StaffId,"ClassID": SelectedClassIDString,"SectionID":SelectedSectionIDString]
                let studentVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectstudentVC") as! SelectstudentVC
                
                studentVC.attendacePassType = 1
                studentVC.SectionStandardName = StandardNameTextField.text! + " - " + SectionNameTextField.text!
                studentVC.SectionDetailDictionary = SelectedSectionDeatil
                studentVC.SchoolId = SchoolId
                studentVC.StaffId = StaffId
                studentVC.SelectedDictforApi = SelectedDictforApi
                studentVC.SenderNameString = "AttendanceVC"
                
                studentVC.sessionType = sessionType
                studentVC.attendanceType = AttendanceType
                
                
                self.present(studentVC, animated: false, completion: nil)
                
            }else{
                Util.showAlert(languageDict["alert"] as? String, msg: languageDict["select_standard_section_alert"] as? String)
                
            }
        }
    }
    
    //MARK:API CALLING
    
    func GetAllSectionCodeapi(){
        showLoading()
        strApiFrom = "GetSectionCodeAttendance"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
        print("requestStringer",requestStringer)
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_STANDARD_SECTION_SUBJECT_NEWOLD
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolId" : SchoolId,"StaffID" : StaffId,"isAttendance" : "1"
                                          , COUNTRY_CODE: strCountryCode]
        
        print("AttmyDict",myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetSectionCodeAttendance")
    }
    
    func MarkAllAsPresentAttendanceapi(){
        showLoading()
        strApiFrom = "MarkAllAsPresentAttendance"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + MARK_ATTENDANCE
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        print("MarkAllAttendance",requestString)
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId ,"ClassId":SelectedClassIDString ,"SectionID": SelectedSectionIDString,"AllPresent" : "T","StudentID": [], COUNTRY_CODE: strCountryCode, "AttendanceType" : AttendanceType, "SessionType": sessionType,"AttendanceDate" : DefaultsKeys.SelectedDAte]
        print("MarkAllAttendanceDict",myDict)
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        //        
        
        
        print("MArkAttenDict",myDict)
        
        
        
        
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "MarkAllAsPresentAttendance")
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!){
        
        hideLoading()
        if(csData != nil)  {
            UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if(strApiFrom.isEqual(to:"GetSectionCodeAttendance")){
                
                var dicResponse: NSDictionary = [:]
                var AlertString = String()
                if((csData?.count)! > 0){
                    let ResponseArray = NSArray(array: csData!)
                    let Dict = ResponseArray[0] as! NSDictionary
                    if(Dict != nil){
                        if let CheckedArray = ResponseArray as? NSArray{
                            StandardSectionArray = CheckedArray
                            if(StandardSectionArray.count > 0){
                                for  i in 0..<StandardSectionArray.count{
                                    dicResponse = StandardSectionArray[i] as! NSDictionary
                                    
                                    let stdcode = String(describing: dicResponse["StandardId"]!)
                                    StandarCodeArray.append(stdcode)
                                    
                                    let CheckstdName = String(describing: dicResponse["Standard"]!)
                                    AlertString = stdcode
                                    let stdName = Util.checkNil(CheckstdName)
                                    
                                    if(stdName != "" && stdName != "0"){
                                        StandardNameArray.append(stdName!)
                                        DetailofSectionArray.append(dicResponse["Sections"] as! [Any])
                                        pickerStandardArray = StandardNameArray
                                        StandardNameTextField.text = pickerStandardArray[0]
                                        SelectedClassIDString = String(StandarCodeArray[0])
                                        let sectionarray:Array = DetailofSectionArray[0] as! [Any]
                                        var sectionNameArray :Array = [String]()
                                        for  i in 0..<sectionarray.count{
                                            let dicResponse : NSDictionary = sectionarray[i] as! NSDictionary
                                            sectionNameArray.append(String(describing: dicResponse["SectionName"]!))
                                            SectionCodeArray.append(String(describing: dicResponse["SectionId"]!))
                                        }
                                        SelectedSectionIDString = String(SectionCodeArray[0])
                                        pickerSectionArray = sectionNameArray
                                        let dicResponse :NSDictionary = sectionarray[0] as! NSDictionary
                                        SelectedSectionDeatil = dicResponse
                                        let SectionString = dicResponse["SectionName"] as! String
                                        SectionNameTextField.text = SectionString
                                    }else{
                                        Util.showAlert("", msg: AlertString)
                                        dismiss(animated: false, completion: nil)
                                    }
                                }
                            }
                        }else{
                            Util.showAlert("", msg: strNoRecordAlert)
                        }                    }
                    
                }else{   Util.showAlert("", msg: strNoRecordAlert)
                    dismiss(animated: false, completion: nil)
                    
                }
            }else if(strApiFrom.isEqual(to: "MarkAllAsPresentAttendance")){
                
                var  arrayDatas: NSArray = []
                var dicResponse: NSDictionary = [:]
                arrayDatas = csData!
                for var i in 0..<arrayDatas.count
                {
                    dicResponse = arrayDatas[i] as! NSDictionary
                }
                let myalertstring = String(describing: dicResponse["Message"]!)
                let mystatus = String(describing: dicResponse["Status"]!)
                
                if(mystatus == "1"){
                    Util.showAlert("", msg: myalertstring)
                    dismiss(animated: false, completion: nil)
                    let nc = NotificationCenter.default
                    nc.post(name: NSNotification.Name(rawValue: "comeBackMenu"), object: nil)
                    
                }else{
                    Util.showAlert("", msg: myalertstring)
                    dismiss(animated: true, completion: nil)
                    
                }
            }
        }else{
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
    
    @objc func catchNotification1(notification:Notification) -> Void{
        dismiss(animated: false, completion: nil)
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
        languageDict = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            AttendanceTitle.textAlignment = .right
            StandardLabel.textAlignment = .right
            SectionLabel.textAlignment = .right
            OrLabel.textAlignment = .right
            AlertConfirmLabel.textAlignment = .right
            AlertMessageLabel.textAlignment = .right
            StandardNameTextField.textAlignment = .right
            SectionNameTextField.textAlignment = .right
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            AttendanceTitle.textAlignment = .left
            StandardLabel.textAlignment = .left
            SectionLabel.textAlignment = .left
            OrLabel.textAlignment = .left
            AlertConfirmLabel.textAlignment = .left
            AlertMessageLabel.textAlignment = .left
            StandardNameTextField.textAlignment = .left
            SectionNameTextField.textAlignment = .left
        }
        AttendanceTitle.text = LangDict["attedance"] as? String
        StandardLabel.text = LangDict["teacher_atten_standard"] as? String
        SectionLabel.text = LangDict["teacher_atten_section"] as? String
        OrLabel.text = LangDict["teacher_or"] as? String
        AlertConfirmLabel.text = LangDict["confirmation"] as? String
        AlertMessageLabel.text = LangDict["mark_all_present"] as? String
        
        MarkAllasPresentButton.setTitle(LangDict["teacher_btn_mark_all_present"] as? String, for: .normal)
        SelectStudentButton.setTitle(LangDict["select_student_attedance"] as? String, for: .normal)
        AlertOkLabel.setTitle(LangDict["teacher_btn_ok"] as? String, for: .normal)
        AlertCancelLabel.setTitle(LangDict["teacher_cancel"] as? String, for: .normal)
        PickerOkButton.setTitle(LangDict["teacher_btn_ok"] as? String, for: .normal)
        PickerCancelButton.setTitle(LangDict["teacher_cancel"] as? String, for: .normal)
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
    
    
    
    @IBAction func attendanceTypeList() {
        
        
        
        var fiel_names : [String] = []
        
        
        var fieldData = ["Full Day","Half Day"]
        
        
        fieldData.forEach { (field) in
            fiel_names.append(field)
        }
        
        drop_down.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            attendanceTypeLbl.text = item
            
            
            
            
            if attendanceTypeLbl.text == "Full Day" {
                AttendanceType = "F"
                sessionType = ""
                sessionHeight.constant = 0
                sessionTypeView.isHidden = true
            }else{
                AttendanceType = "H"
                sessionType = "FH"
                sessionHeight.constant = 40
                sessionTypeView.isHidden = false
            }
            
            
            
            
        }
        
        drop_down.dataSource = fiel_names
        drop_down.anchorView = attendanceTypeView
        drop_down.bottomOffset = CGPoint(x: 0, y:(drop_down.anchorView?.plainView.bounds.height)!)
        drop_down.show()
        
        
        
        
        
    }
    
    
    @IBAction func sessionTypeList() {
        
        
        
        var fiel_names : [String] = []
        
        
        var fieldData = [ "First Half","Second Half"]
        
        
        fieldData.forEach { (field) in
            fiel_names.append(field)
        }
        drop_down.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            sessionType = ""
            sessionTypeLbl.text = item
            if sessionTypeLbl.text == "First Half" {
                sessionType = "FH"
                
            }else  if sessionTypeLbl.text == "Second Half"  {
                sessionType = "SH"
                
            }
            
        }
        
        drop_down.dataSource = fiel_names
        drop_down.anchorView = sessionTypeView
        drop_down.bottomOffset = CGPoint(x: 0, y:(drop_down.anchorView?.plainView.bounds.height)!)
        drop_down.show()
        
    }
    
    
    func getAttendenceReport(){
            
        print("SelectedClassIDStringSelectedClassIDString",SelectedClassIDString)
            let param : [String : Any] =
            [
                
                "instituteId": SchoolId,
                "sectionId" : SelectedSectionIDString,
                "from_date" :  DefaultsKeys.SelectedDAte,
                "to_date" :  DefaultsKeys.SelectedDAte,
                "standardId"    : SelectedClassIDString
              
                
            ]
            
            print("paramparam",param)
            
            StudentAttendenceReportRequest.call_request(param: param){ [self]
                (res) in
                
                print("resres",res)
                
                let getattendaceReport : StudentAttendenceReportResponse = Mapper<StudentAttendenceReportResponse>().map(JSONString: res)!
                
                if getattendaceReport.status == 1{
                    
                    data = getattendaceReport.data
                    
                    tv.dataSource = self
                    tv.delegate = self
                    tv.reloadData()
                    
                    
                }else{
                    
                    
            }
                
                
            }
        }
}
