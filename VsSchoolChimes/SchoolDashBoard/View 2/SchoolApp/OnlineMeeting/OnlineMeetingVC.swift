//
//  OnlineMeetingVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 12/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

var menuController: UIMenuController?


class OnlineMeetingVC: UIViewController,UITextViewDelegate,UITextFieldDelegate,
                       UITableViewDelegate,UITableViewDataSource,Apidelegate,
                       UIPopoverPresentationControllerDelegate{
    
    @IBOutlet weak var TextMessageView: UITextView!
    @IBOutlet weak var linkTxtView: UITextView!
    
    @IBOutlet weak var TitleText: UITextField!
    @IBOutlet weak var SendTextMessageLabel: UILabel!
    @IBOutlet weak var remainingCharactersLabel: UILabel!
    @IBOutlet weak var ToStandardSection: UIButton!
    @IBOutlet weak var ToGroupSection: UIButton!
    
    @IBOutlet weak var ComposeTitleLabel: UILabel!
    @IBOutlet weak var SubmissionDateLabel: UILabel!
    @IBOutlet weak var SubmissionView: UIView!
    @IBOutlet weak var submissionViewTopHeight: NSLayoutConstraint!
    @IBOutlet weak var submissionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var submissionDateButton: UIButton!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var tablview: UITableView!
    @IBOutlet weak var meetingView: UIView!
    @IBOutlet weak var meetingTabView: UIView!
    @IBOutlet weak var linkTF: UITextField!
    
    
    @IBOutlet weak var pasteMenuLbl: SelectableLabel!
    
    
    var ChildIDString = String()
    var SchoolIDString = String()
    var datePickerMode = NSString()
    
    var dateString = NSString()
    var timeString = NSString()
    
    @IBOutlet weak var meetingSeg: UISegmentedControl!
    
    var loginAsName = String()
    var strSubmissionDate = String()
    var strFrom = String()
    var SchoolId = String()
    var StaffId = String()
    var MaxTextCount = Int()
    var SchoolDetailDict:NSDictionary = [String:Any]() as NSDictionary
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let UtilObj = UtilClass()
    var textViewPlaceholder = String()
    var strLanguage = String()
    let dateView = UIView()
    let dateViews = UIView()
    let timeView = UIView()
    let timeViews = UIView()
    var assignmentDict = NSMutableDictionary()
    var popupLoading : KLCPopup = KLCPopup()
    var selectedType = NSDictionary()
    
    var hud : MBProgressHUD = MBProgressHUD()
    var strApiFrom = String()
    
    var arrMeetingType = NSMutableArray()
    var arrMeetingList = NSMutableArray()
    
    var meetingDict = NSMutableDictionary()
    var selectMeetDict = NSDictionary()
    
    var strCountryName = String()
    var strSegmentForm = String()
    var selecSchoolDict = NSDictionary()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(OnlineMeetingVC.catchNotification), name: NSNotification.Name(rawValue: "comeBackMenu"), object:nil)
        nc.addObserver(self,selector: #selector(OnlineMeetingVC.UpdatemeetingSelection), name: NSNotification.Name(rawValue: "meetingNotification"), object:nil)
        nc.addObserver(self,selector: #selector(OnlineMeetingVC.PasteLableSelection), name: NSNotification.Name(rawValue: "pasteLabelNotification"), object:nil)
        linkTF.isUserInteractionEnabled = false
        textViewPlaceholder = "Description"
        TextMessageView.text = textViewPlaceholder
        TextMessageView.textColor = .lightGray
        
        linkTF.placeholder = ""
        pasteMenuLbl.text = " Paste link                                "
        pasteMenuLbl.textColor = .lightGray
        
        callGetDetailsApi()
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        print("loginAsName \(loginAsName)")
        if(loginAsName == "Staff"){
            ToGroupSection.isHidden = true
            
        }else{
            ToGroupSection.isHidden = false
            
        }
        ToStandardSection.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        ToStandardSection.isUserInteractionEnabled = true
        
        ToGroupSection.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        ToGroupSection.isUserInteractionEnabled = true
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        meetingTabView.isHidden = true
        strCountryName = UserDefaults.standard.object(forKey: COUNTRY_Name) as? String ?? ""
        print(strCountryName)
        self.callSelectedLanguage()
        
    }
    //MARK: TEXTFIELD DELEGATE
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.location == 0 && string == " " {
            return false
        }
        return true
    }
    
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch meetingSeg.selectedSegmentIndex {
        case 0:
            meetingTabView.isHidden = true
            meetingView.isHidden = false
            //
        case 1:
            meetingTabView.isHidden = false
            meetingView.isHidden = true
            if(appDelegate.LoginSchoolDetailArray.count == 1){
                strSegmentForm = "view"
                selecSchoolDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
                
                callGetMeetingsApi(dict: selecSchoolDict)
            }else{
                strSegmentForm = "school"
                
            }
            
            tablview.reloadData()
            
        default:
            break;
        }
    }
    //MARK: TEXTVIEW DELEGATE
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(TextMessageView.text == textViewPlaceholder)
        {
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        setupTextViewAccessoryView()
        if(TextMessageView.text == textViewPlaceholder)
        {
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
        return true
    }
    
    func textviewEnableorDisable(){
        if(TextMessageView.text.count > 0 && TextMessageView.text != textViewPlaceholder)
        {
            ToStandardSection.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            ToStandardSection.isUserInteractionEnabled = true
        }
        else
        {
            ToStandardSection.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            ToStandardSection.isUserInteractionEnabled = false
        }
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        textView.resignFirstResponder()
        return true
    }
    //
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
        
        
    }
    func setupTextViewAccessoryView() {
        let toolBar: UIToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        let flexsibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(didPressDoneButton))
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        toolBar.items = [flexsibleSpace, doneButton]
        TextMessageView.inputAccessoryView = toolBar
    }
    
    @objc func didPressDoneButton(button: UIButton) {
        if( TextMessageView.text == "" ||  TextMessageView.text!.count == 0 || ( TextMessageView.text!.trimmingCharacters(in: .whitespaces).count) == 0){
            TextMessageView.text = textViewPlaceholder
            TextMessageView.textColor = UIColor.lightGray
        }
        
        TextMessageView.resignFirstResponder()
    }
    
    //MARK:BUTTON ACTION
    @IBAction func actionDateButton(_ sender: UIButton) {
        self.dismissKeyboard()
        datePickerMode = "date"
        let dateFormatter: DateFormatter = DateFormatter()
        
        let date = Date()
        
        dateFormatter.dateFormat = "dd MMM yyyy"
        let dst = dateFormatter.string(from: date)
        dateButton.setTitle(dst, for: .normal)
        dateString = dst as NSString
        
        self.congifureDatePicker()
    }
    @IBAction func actionTimeButton(_ sender: UIButton) {
        datePickerMode = "time"
        let dateFormatter: DateFormatter = DateFormatter()
        
        let date = Date()
        
        
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let tst = dateFormatter.string(from: date)
        timeString = tst as NSString
        
        timeButton.setTitle(tst, for: .normal)
        self.congifureDatePickerTime()
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    @IBAction func actionclearLink(_ sender: UIButton) {
        
        pasteMenuLbl.text = " Paste link                              "
        pasteMenuLbl.textColor = .lightGray
        linkTF.text = ""
        
    }
    @IBAction func actionStandardAndGroups(_ sender: UIButton) {
        if(TitleText.text?.count == 0){
            Util.showAlert("", msg: "Please enter title")
        }
        else if(TextMessageView.text == "" || TextMessageView.text == textViewPlaceholder){
            Util.showAlert("", msg: "Please enter description")
            
        }
        else if(selectedType.count == 0){
            Util.showAlert("", msg: "Please select meeting type ")
        }
        else if(dateString == ""){
            Util.showAlert("", msg: "Please select date")
            
        }else if(timeString == ""){
            Util.showAlert("", msg: "Please select time")
        }else if(linkTF.text == ""){
            Util.showAlert("", msg: "Please paste meeting link")
        }
        else{
            if(appDelegate.LoginSchoolDetailArray.count == 1){
                SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
            }
            SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
            StaffId = String(describing: SchoolDetailDict["StaffID"]!)
            
            
            meetingDict = [
                "school_id" : SchoolId,
                "staff_id" : StaffId,
                "meeting_url" : linkTF.text ?? "",
                "meeting_date" : dateString,
                "meeting_time" : timeString,
                "meeting_topic" : TitleText.text ?? "",
                "meeting_id" : selectedType.object(forKey: "id") as? NSNumber ?? 0,
                "meeting_type" : selectedType.object(forKey: "type") as? String ?? "",
                "meeting_description" : TextMessageView.text ?? ""
                
                
            ]
            
            
            let segueid = self.storyboard?.instantiateViewController(withIdentifier: "GroupStandardSelectionPrincipalVC") as! GroupStandardSelectionPrincipalVC
            segueid.fromViewController = "OnlineMeetingVC"
            segueid.SchoolID = SchoolId as NSString
            segueid.selectedSchoolDictionary = meetingDict
            self.present(segueid, animated: false, completion: nil)
        }
    }
    @IBAction func actionStandardOrSectionSelection(_ sender: UIButton) {
        dismissKeyboard()
        
        if(TitleText.text?.count == 0){
            Util.showAlert("", msg: "Please enter title")
        }
        else if(TextMessageView.text == "" || TextMessageView.text == textViewPlaceholder){
            Util.showAlert("", msg: "Please enter description")
            
        }
        else if(selectedType.count == 0){
            Util.showAlert("", msg: "Please select meeting type ")
        }
        else if(dateString == ""){
            Util.showAlert("", msg: "Please select date")
            
        }else if(timeString == ""){
            Util.showAlert("", msg: "Please select time")
        }else if(linkTF.text == ""){
            Util.showAlert("", msg: "Please paste meeting link")
        }
        else{
            if(strFrom == "Assignment"){
                
                assignmentDict = [
                    "AssignmentId" : "0",
                    "SchoolID" : SchoolId,
                    "AssignmentType": "SMS",
                    "Title": self.TitleText.text! ,
                    "content": self.TextMessageView.text!,
                    
                    "category" : "",
                    "Duration":"0" ,
                    "ProcessBy":StaffId,
                    "isMultiple":"0" ,
                    "processType":"add",
                    "EndDate":strSubmissionDate,
                    
                ]
                
                let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "StaffAddNewClassVC") as! StaffAddNewClassVC
                AddCV.SchoolDetailDict = SchoolDetailDict
                AddCV.sendAssignmentDict = self.assignmentDict
                AddCV.assignmentType = "StaffAssignment"
                self.present(AddCV, animated: false, completion: nil)
            }else{
                if(appDelegate.LoginSchoolDetailArray.count == 1){
                    SchoolDetailDict = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
                }
                SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
                StaffId = String(describing: SchoolDetailDict["StaffID"]!)
                
                
                meetingDict = [
                    "school_id" : SchoolId,
                    "staff_id" : StaffId,
                    "meeting_url" : linkTF.text ?? "",
                    "meeting_date" : dateString,
                    "meeting_time" : timeString,
                    "meeting_topic" : TitleText.text ?? "",
                    "meeting_id" : selectedType.object(forKey: "id") as? NSNumber ?? 0,
                    "meeting_type" : selectedType.object(forKey: "type") as? String ?? "",
                    "meeting_description" : TextMessageView.text ?? ""
                    
                    
                ]
                
                let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "StaffAddNewClassVC") as! StaffAddNewClassVC
                AddCV.SchoolDetailDict = SchoolDetailDict
                AddCV.sendAssignmentDict = meetingDict
                
                AddCV.SendedScreenNameStr = "OnlineMeetingVC"
                
                self.present(AddCV, animated: false, completion: nil)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "SendTextMessageSegue")
        {
            let segueid = segue.destination as! SendTextMessageVC
            segueid.SegueText = TextMessageView.text
            
        }
    }
    func dismissKeyboard()
    {
        TextMessageView.resignFirstResponder()
        TitleText.resignFirstResponder()
        linkTF.resignFirstResponder()
    }
    @objc  func catchNotification(notification:Notification) -> Void
    {
        dismiss(animated: false, completion: nil)
    }
    
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
        
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            TitleText.textAlignment = .right
            TextMessageView.textAlignment = .right
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            TitleText.textAlignment = .left
            TextMessageView.textAlignment = .left
        }
        if(strFrom == "Assignment"){
            ComposeTitleLabel.text  =  LangDict["teacher_txt_composemsg"] as? String
            SubmissionDateLabel.text = LangDict["subission_date"] as? String
            
            TitleText.placeholder  =  LangDict["assignment_title"] as? String
            ToStandardSection.setTitle("Choose Recipients", for: .normal)
            textViewPlaceholder =  LangDict["teacher_txt_typemsg"] as? String ?? "Content?"
            
        }
        else{
            TitleText.placeholder  = LangDict["teacher_txt_only_title"] as? String
            if (strCountryName.uppercased() == SELECT_COUNTRY){
                ToStandardSection.setTitle(LangDict["teacher_staff_to_sections_usa"] as? String, for: .normal)
                print(ToStandardSection)
                ToGroupSection.setTitle(LangDict["send_to_standard_groups_usa"] as? String, for: .normal)
            }
            else{
                ToStandardSection.setTitle(LangDict["teacher_staff_to_sections"] as? String, for: .normal)
                ToGroupSection.setTitle(LangDict["send_to_standard_groups"] as? String, for: .normal)
            }
            
            textViewPlaceholder =  LangDict["teacher_txt_typemsg"] as? String ?? "Content?"
        }
        TextMessageView.text = textViewPlaceholder
        TextMessageView.textColor = UIColor.lightGray
        ToStandardSection.layer.cornerRadius = 5
        ToStandardSection.layer.masksToBounds = true
        
        if(TextMessageView.text != textViewPlaceholder){
            TextMessageView.textColor = UIColor.black
        }
    }
    
    //MARK: DatePicker
    func congifureDatePicker()
    {
        dateView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.actionClosePopup(_:)))
        dateView.addGestureRecognizer(tap)
        
        let doneButton = UIButton()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            doneButton.frame = CGRect(x: 0, y: self.view.frame.height - 250, width: self.dateView.frame.width, height: 50)
        }else
        {
            doneButton.frame = CGRect(x: 0, y: self.view.frame.height - 235, width: self.dateView.frame.width, height: 35)
        }
        doneButton.setTitle("Done", for: .normal)
        doneButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        doneButton.addTarget(self, action: #selector(self.actionDoneButton(_:)), for: .touchUpInside)
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.frame = CGRect(x: 0, y: dateView.frame.height - 200, width: self.view.frame.width, height: 200)
        let currentDate: NSDate = NSDate()
        dateViews.frame = CGRect(x: 0, y: dateView.frame.height - 200, width: self.view.frame.width, height: 200)
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        dateViews.backgroundColor = UIColor.white
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        } else {
        }
        
        
        if(datePickerMode .isEqual(to: "date")){
            datePicker.datePickerMode = UIDatePicker.Mode.date
            datePicker.minimumDate = currentDate as Date
        }else{
            datePicker.datePickerMode = UIDatePicker.Mode.time
            datePicker.locale = NSLocale.init(localeIdentifier: "en_US") as Locale
            let CurrentDate = UtilObj.getCurrentDate() as NSString
            
            
        }
        
        
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        
        
        dateView.addSubview(dateViews)
        
        dateView.addSubview(doneButton)
        dateView.addSubview(datePicker)
        dateView.bringSubviewToFront(datePicker)
        
        //        G3
        
        
        dateView.center = view.center
        dateView.alpha = 1
        dateView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(dateView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.dateView.transform = .identity
        })
        
        
        print("ONline?MEetting")
        
        
        
        
        
        
        popupLoading.dimmedMaskAlpha =  0
        
        
        
        
        
    }
    
    func congifureDatePickerTime()
    {
        timeView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.actionClosePopup(_:)))
        timeView.addGestureRecognizer(tap)
        
        let doneButton = UIButton()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            doneButton.frame = CGRect(x: 0, y: self.view.frame.height - 250, width: self.dateView.frame.width, height: 50)
        }else
        {
            doneButton.frame = CGRect(x: 0, y: self.view.frame.height - 235, width: self.dateView.frame.width, height: 35)
        }
        doneButton.setTitle("Done", for: .normal)
        doneButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
        doneButton.addTarget(self, action: #selector(self.actionDoneButton(_:)), for: .touchUpInside)
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.frame = CGRect(x: 0, y: dateView.frame.height - 200, width: self.view.frame.width, height: 200)
        var currentDate: NSDate = NSDate()
        timeViews.frame = CGRect(x: 0, y: dateView.frame.height - 200, width: self.view.frame.width, height: 200)
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        timeViews.backgroundColor = UIColor.white
        
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        } else {
        }
        
        
        if(datePickerMode .isEqual(to: "date")){
            datePicker.datePickerMode = UIDatePicker.Mode.date
            datePicker.minimumDate = currentDate as Date
        }else{
            datePicker.datePickerMode = UIDatePicker.Mode.time
            datePicker.locale = NSLocale.init(localeIdentifier: "en_US") as Locale
            var CurrentDate = UtilObj.getCurrentDate() as NSString
            currentDate = currentDate.addingTimeInterval(600)
            
            
            if(CurrentDate.isEqual(to: (dateButton.titleLabel?.text!)!) || dateButton.titleLabel?.text == "")
            {
                datePicker.minimumDate = currentDate as Date
            }
            
        }
        
        
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        
        
        timeView.addSubview(timeViews)
        timeView.addSubview(doneButton)
        timeView.addSubview(datePicker)
        timeView.bringSubviewToFront(datePicker)
        
        
        timeView.center = view.center
        timeView.alpha = 1
        timeView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(timeView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.timeView.transform = .identity
        })
        
        
        print("ONline?MEettingtimeView")
        
        
        popupLoading.dimmedMaskAlpha =  0
        
        
    }
    
    func setCurrentDateTime(){
        
        
        
        let dateFormatter: DateFormatter = DateFormatter()
        
        let date = Date()
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dst = dateFormatter.string(from: date)
        dateButton.setTitle(dst, for: .normal)
        dateString = dst as NSString
        
        
        dateFormatter.dateFormat = "hh:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let tst = dateFormatter.string(from: date)
        timeButton.setTitle(tst, for: .normal)
        
        
        
        
        
        
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        
        let dateFormatter: DateFormatter = DateFormatter()
        
        
        if(datePickerMode .isEqual(to: "date")){
            dateFormatter.dateFormat = "dd MMM yyyy"
        }else{
            dateFormatter.dateFormat = "hh:mm a"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        }
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        if(datePickerMode .isEqual(to: "date")){
            dateFormatter.dateFormat = "dd-MM-yyyy"
            dateString = dateFormatter.string(from: sender.date) as NSString
            dateButton.setTitle(selectedDate, for: .normal)
            dateString = selectedDate as NSString
            let CurrentDate = UtilObj.getCurrentDate() as NSString
            
            if(CurrentDate.isEqual(to: (dateButton.titleLabel?.text!)!) || dateButton.titleLabel?.text == "")
            {
                dateFormatter.dateFormat = "hh:mm a"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                let selectedDate: String = dateFormatter.string(from: sender.date)
                timeString =  selectedDate as NSString
                timeButton.setTitle(selectedDate, for: .normal)
                
                
            }
        }else{
            timeString =  selectedDate as NSString
            timeButton.setTitle(timeString as String, for: .normal)
        }
        
    }
    
    @objc func actionDoneButton(_ sender: UIButton)
    {
        dateView.removeFromSuperview()
        timeView.alpha = 0
        popupLoading.dismiss(true)
    }
    @objc func actionClosePopup(_ sender: UIButton)
    {
        popupLoading.dismiss(true)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(strSegmentForm == "school"){
            return appDelegate.LoginSchoolDetailArray.count
            
        }else{
            return arrMeetingList.count
            
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if(strSegmentForm == "school"){
            
            return 0
        }else{
            return 10
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 400
        }else{
            if(strSegmentForm == "school"){
                return 50
                
            }else{
                let dicCountryName = arrMeetingList.object(at: indexPath.section) as! NSDictionary
                let can_cancel = dicCountryName["can_cancel"] as? NSNumber ?? 0
                if(can_cancel == 0){
                    return 300
                }else{
                    return 350
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if(strSegmentForm == "school"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageTVCell", for: indexPath) as! TextMessageTVCell
            let schoolDict = appDelegate.LoginSchoolDetailArray .object(at: indexPath.section) as? NSDictionary
            cell.SchoolNameLbl.text = schoolDict?["SchoolName"] as? String
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingTVCell", for: indexPath) as! MeetingTVCell
            let dicCountryName = arrMeetingList.object(at: indexPath.section) as! NSDictionary
            
            cell.meetingDateLabel.text = "MEETING DATE & TIME : \(dicCountryName["meetingdatetime"] as? String ?? "")"
            cell.typeLabel.text = "MEETING TYPE : \(dicCountryName["meetingtype"] as? String ?? "")"
            cell.subjectLabel.text = "SUBJECT : \(dicCountryName["subject_name"] as? String ?? "")"
            cell.createOnLabel.text = "CREATED ON : \(dicCountryName["created_on"] as? String ?? "")"
            cell.targetTypeLabel.text = "TARGET TYPE : \(dicCountryName["target_type"] as? String ?? "")"
            cell.titleLabel.text = "\(dicCountryName["topic"] as? String ?? "")"
            cell.descLabel.text = "\(dicCountryName["description"] as? String ?? "")"
            let strUrl = "\(dicCountryName["url"] as? String ?? "")"
            
            if(strUrl.contains("http") || strUrl.contains("www")){
                let attributedString = NSMutableAttributedString(string: strUrl, attributes:[NSAttributedString.Key.link: URL(string: strUrl)!])
                cell.linkLabel.attributedText = attributedString
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(OnlineMeetingVC.tapFunction))
            cell.linkLabel.isUserInteractionEnabled = true
            cell.linkLabel.tag = indexPath.section
            
            cell.linkLabel.addGestureRecognizer(tap)
            let can_cancel = dicCountryName["can_cancel"] as? NSNumber ?? 0
            
            if(can_cancel == 0){
                cell.cancelButton.isHidden = true
            }else{
                cell.cancelButton.isHidden = false
            }
            cell.cancelButton.backgroundColor = UIColor(red: 230.0/255.0, green: 126.0/255.0, blue: 34.0/255.0, alpha: 1)
            cell.cancelButton.setTitleColor(.white, for: .normal)
            
            cell.cancelButton.setTitle("Cancel Meeting", for: .normal)
            cell.cancelButton.tag = indexPath.section
            //cell.ViewProgressBtn.addTarget(self, action: Selector(("progressClicked:")), for: UIControl.Event.touchUpInside)
            cell.cancelButton.addTarget(self, action: #selector(progressClicked), for: .touchUpInside)
            
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(strSegmentForm == "school"){
            selecSchoolDict = appDelegate.LoginSchoolDetailArray[indexPath.section] as! NSDictionary
            print("selectedSchoolDict \(selecSchoolDict)")
            strSegmentForm = "view"
            callGetMeetingsApi(dict: selecSchoolDict)
        }
    }
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
        let dicCountryName = arrMeetingList.object(at: buttonRow) as! NSDictionary
        let strUrl = "\(dicCountryName["url"] as? String ?? "")"
        self.openURL(urlSting: strUrl)
        print("tap working")
    }
    func openURL(urlSting : String){
        //
        
        let strUrl = urlSting.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        guard let url = URL(string: strUrl!) else { return }
        UIApplication.shared.openURL(url)
    }
    @objc func progressClicked(sender:UIButton) {
        
        let buttonRow = sender.tag
        selectMeetDict = arrMeetingList[buttonRow] as! NSDictionary
        cancelAlertAction()
    }
    
    func cancelAlertAction(){
        let alertController = UIAlertController(title: "", message: "Are you sure want to cancel meeting?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.callPostCancelMeetingsApi()
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func callGetDetailsApi(){
        if(Util .isNetworkConnected()){
            showLoading()
            strApiFrom = "typedetails"
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
            let requestStringer = baseUrlString! + GET_MEETINGS_TYPES_LIST
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            apiCall.getFunction(requestString, "typedetails")
        }else{
            Util .showAlert("", msg: NETWORK_ERROR)
        }
    }
    
    func callGetMeetingsApi(dict : NSDictionary){
        //   let dict:NSDictionary = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
        let ChildId = String(describing: dict["StaffID"]!)
        SchoolId = String(describing: dict["SchoolID"]!)
        if(Util .isNetworkConnected()){
            showLoading()
            strApiFrom = "meetings"
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
            let requestStringer = baseUrlString! + GET_MEETINGS_STAFF
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["schoolid": SchoolId,"staffid": ChildId]
            let myString = Util.convertDictionary(toString: myDict)
            print("Online \(requestString) \(myString)")
            apiCall.nsurlConnectionFunction(requestString,myString ,"meetings")
        }else{
            Util .showAlert("", msg: NETWORK_ERROR)
        }
    }
    
    func callPostCancelMeetingsApi(){
        let dict:NSDictionary = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
        
        let ChildId = String(describing: dict["StaffID"]!)
        SchoolId = String(describing: dict["SchoolID"]!)
        
        let hid = selectMeetDict.object(forKey: "header_id") as? NSNumber ?? 0
        let shid = selectMeetDict.object(forKey: "subheader_id") as? NSNumber ?? 0
        
        if(Util .isNetworkConnected()){
            showLoading()
            strApiFrom = "cancelmeetings"
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
            let requestStringer = baseUrlString! + POST_CANCEL_MEETING
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["header_id": hid,"subheader_id": shid,"process_by": ChildId]
            let myString = Util.convertDictionary(toString: myDict)
            print("Online \(requestString) \(myString)")
            apiCall.nsurlConnectionFunction(requestString,myString ,"meetings")
        }else{
            Util .showAlert("", msg: NETWORK_ERROR)
        }
    }
    //MARK: API RESPONSE
    
    
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!){
        hideLoading()
        if(csData != nil){
            
            if(strApiFrom.isEqual("typedetails")){
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                if let arrdate = csData as? NSMutableArray{
                    arrMeetingType = arrdate
                }
                else{
                    Util.showAlert("", msg: NO_DATA_FOUND)
                    
                }
            }
            else if(strApiFrom.isEqual("meetings")){
                
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                let emptyDict : NSDictionary = NSDictionary()
                let Dict : NSDictionary = csData?.mutableCopy() as? NSDictionary ?? emptyDict
                
                UtilObj.printLogKey(printKey: "Dict", printingValue: Dict)
                if(Dict.count > 0){
                    
                    let Status = Dict["status"] as? String ?? "0"
                    let Message = Dict["message"] as? String
                    let strAlertString = Message as? String ?? ""
                    if(Status == "1"){
                        
                        let arrD = Dict.object(forKey: "data") as? NSArray ?? []
                        arrMeetingList = NSMutableArray(array: arrD)
                        tablview.reloadData()
                    }else{
                    }
                    
                    
                }else
                {
                    Util.showAlert("", msg: NO_DATA_FOUND)
                }
                
                
            } else if(strApiFrom.isEqual("cancelmeetings")){
                
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                if let arrdate = csData as? NSMutableArray{
                    
                    if(arrdate.count > 0){
                        let dicDate = arrdate[0] as! NSDictionary
                        let Status = dicDate["status"] as? String ?? "0"
                        let Message = dicDate["message"] as? String
                        let strAlertString = Message as? String ?? ""
                        if(Status == "1"){
                            Util.showAlert("", msg: strAlertString)
                            callGetMeetingsApi(dict: selecSchoolDict)
                        }else{
                            Util.showAlert("", msg: strAlertString)
                            
                        }
                    }
                    
                }
                
                else
                {
                    Util.showAlert("", msg: NO_DATA_FOUND)
                }
                
                
            }
            else{
                Util.showAlert("", msg: "strSomething")
            }
        }
    }
    
    
    
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util .showAlert("", msg: SERVER_CONNECTION_FAILED);
    }
    
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
    }
    
    @IBAction func actionType(_ sender: UIButton) {
        self.dismissKeyboard()
        self.showPopover(sender, Titletext: "")
    }
    // MARK: - Popover delegate  & Functions
    func showPopover(_ base: UIView, Titletext: String)
    {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DropDownVC") as? DropDownVC {
            
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .popover
            viewController.fromVC = "meeting"
            viewController.arrCommon = arrMeetingType
            if let pctrl = navController.popoverPresentationController {
                pctrl.delegate = self
                pctrl.permittedArrowDirections = .down
                pctrl.sourceView = base
                pctrl.sourceRect = base.bounds
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc func UpdatemeetingSelection(notification:Notification) -> Void
    {
        print("PLib \(notification.object)")
        
        selectedType = notification.object as! NSDictionary
        SubmissionDateLabel.text = selectedType.object(forKey: "type") as? String ?? ""
        if(SubmissionDateLabel.text?.lowercased() == "others" ){
            linkTF.text = ""
            linkTF.isUserInteractionEnabled = true
            pasteMenuLbl.isHidden = true
            self.view.bringSubviewToFront(linkTF)
        }else{
            pasteMenuLbl.isHidden = false
            linkTF.isUserInteractionEnabled = false
        }
        let arrSteps = selectedType.object(forKey: "steps") as? NSArray ?? []
        if(arrSteps.count > 0){
            actionTabTypes(self)
        }
        
    }
    
    @objc func PasteLableSelection(notification:Notification) -> Void
    {
        print("PasteLableSelection \(notification.object as? String ?? "p")")
        linkTF.text = notification.object as? String ?? ""
        linkTF.isHidden = false
        pasteMenuLbl.text = "                                 "
        //pasteMenuLbl.textColor = .white
        
    }
    
    @IBAction func actionTabTypes(_ sender: Any) {
        self.dismissKeyboard()
        if(selectedType.count == 0){
            Util.showAlert("", msg: "Please paste meeting link")
        }else{
            let arrSteps = selectedType.object(forKey: "steps") as? NSArray ?? []
            if(arrSteps.count > 0){
                let languageVC  = self.storyboard?.instantiateViewController(withIdentifier: "OnlineTypeVC") as! OnlineTypeVC
                languageVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                languageVC.selectedDictionary = selectedType
                self.present(languageVC, animated: true, completion: nil)
            }
            
        }
        
    }
    
    
    
}
