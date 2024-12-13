//
//  SchoolEventVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 12/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit


class SchoolEventVC: UIViewController,UITextViewDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource{
    
    
    @IBOutlet var HeaderView: UIView!
    @IBOutlet var MyTableView: UITableView!
    @IBOutlet weak var TextMessageView: UITextView!
    @IBOutlet weak var remainingCharactersLabel: UILabel!
    @IBOutlet weak var topicTextField: UITextField!
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var SendTextMessageLabel: UILabel!
    @IBOutlet weak var DateTimeLabel: UILabel!
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var ScreenWidth = CGFloat()
    var SchoolNameArray = ["VoicesnapSchool Adyar","VoicesnapSchool Chennai","VoicesnapSchool Avadi","VoicesnapSchool KKNagar","VoicesnapSchool Ashok Pillar","VoicesnapSchool Gunidy","VoicesnapSchool Anna salai ","VoicesnapSchool Vellore","VoicesnapSchool"]
    var datePickerMode = NSString()
    var dateString = NSString()
    var timeString = NSString()
    var strApiFrom = NSString()
    let dateView = UIView()
    var selectedSchoolDictionary = NSMutableDictionary()
    var selectedSchoolID = NSString()
    var strTextViewPlaceholder = String()
    var strDateTime = String()
    var MaxTextCount = Int()
    let UtilObj = UtilClass()
    let DateFormatter2 : DateFormatter = DateFormatter()
    var strLanguage = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var LanguageDict = NSDictionary()
    
    var strSeleDate = String()
    //MARK: ViewController Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.callSelectedLanguage()
        var currentDate: NSDate = NSDate()
        let dateFormatter: DateFormatter = DateFormatter()
        let dateFormatter1: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        var selectedDate: String = dateFormatter.string(from: currentDate as Date)
        dateString = selectedDate as NSString
        print(selectedDate)
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateButton.setTitle(dateFormatter.string(from: currentDate as Date), for: .normal)
        
        strSeleDate = dateButton.titleLabel?.text ?? ""
        currentDate = currentDate.addingTimeInterval(600)
        dateFormatter1.dateFormat = "hh:mm a"
        dateFormatter1.locale = Locale(identifier: "en_US_POSIX")
        selectedDate = dateFormatter1.string(from: currentDate as Date)
        
        print(selectedDate)
        timeString = selectedDate as NSString
        print(timeString)
        timeButton.setTitle(timeString as String, for: .normal)
        
        
    }
    
    //MARK: TextField Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(TextMessageView.text == strTextViewPlaceholder){
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        setupTextViewAccessoryView()
        if(TextMessageView.text == strTextViewPlaceholder){
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        textView.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.location == 0 && string == " " {
            return false
        }
        return true
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentCharacterCount = TextMessageView.text?.count ?? 0
        
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        
        let newLength = currentCharacterCount + text.count - range.length
        
        let length : integer_t
        
        length = integer_t(MaxTextCount) - Int32(newLength)
        
        
        remainingCharactersLabel.text = String (length)
        if(length <= 0){
            return false
        }
        else if textView.text?.last == " "  && text == " "
        {
            return false
        }
        else {
            let newString = (textView.text as NSString).replacingCharacters(in: range, with: text) as NSString
            return newString.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines).location != 0
        }
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
            TextMessageView.text = strTextViewPlaceholder
            TextMessageView.textColor = UIColor.lightGray
        }
        
        TextMessageView.resignFirstResponder()
    }
    
    //MARK: Button Actions
    @IBAction func actionCloseView(_ sender: UIButton) {
        
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionNextButton(_ sender: Any) {
        self.dismissKeyboard()
        DispatchQueue.main.async {
        }
    }
    
    @IBAction func actionDateButton(_ sender: UIButton) {
        datePickerMode = "date"
        self.congifureDatePicker()
    }
    @IBAction func actionTimeButton(_ sender: UIButton) {
        datePickerMode = "time"
        self.congifureDatePicker()
    }
    
    
    
    func dismissKeyboard()
    {
        TextMessageView.resignFirstResponder()
    }
    
    //MARK: TABLEVIEW DELEGATE
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 65
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.LoginSchoolDetailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return HeaderView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let schoolDict = appDelegate.LoginSchoolDetailArray .object(at: indexPath.row) as? NSDictionary
        selectedSchoolID = schoolDict?["SchoolID"] as! NSString
        selectedSchoolDictionary["SchoolId"] = schoolDict?["SchoolID"] as! NSString
        selectedSchoolDictionary["StaffId"] = schoolDict?["StaffID"] as! NSString
        UtilObj.printLogKey(printKey: "dateString", printingValue: dateString)
        selectedSchoolDictionary["EventDate"] = dateString
        UtilObj.printLogKey(printKey: "timeString", printingValue: timeString)
        let Timeformat:String = UtilObj.convertTimeFromAM(str_time: timeString as String)
        
        
        selectedSchoolDictionary["EventTime"] = Timeformat
        selectedSchoolDictionary["EventTopic"] = topicTextField.text!
        selectedSchoolDictionary["EventBody"] = TextMessageView.text!
        
        if(TextMessageView.text.count > 0 && (topicTextField.text?.count)! > 0 && TextMessageView.text != strTextViewPlaceholder)
        {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "SchoolEventToPrincipalGroupSegue", sender: self)
            }
        }else{
            Util.showAlert("", msg: LanguageDict["fill_all_alert"] as? String)
        }
        
    }
    
    func validateAllFields()
    {
        
    }
    //MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "SchoolEventToPrincipalGroupSegue")
        {
            let segueid = segue.destination as! GroupStandardSelectionPrincipalVC
            segueid.fromViewController = "SchoolEvents"
            segueid.SchoolID = selectedSchoolID
            segueid.selectedSchoolDictionary = selectedSchoolDictionary
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
        let timeViews = UIView()
        timeViews.frame = CGRect(x: 0, y: dateView.frame.height - 200, width: self.view.frame.width, height: 200)
        timeViews.backgroundColor = UIColor.white
        let currentDate: NSDate = NSDate()
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
        }
        if(datePickerMode .isEqual(to: "date")){
            datePicker.datePickerMode = UIDatePicker.Mode.date
            datePicker.minimumDate = currentDate as Date
            
            let dateFormatter: DateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            dateButton.setTitle(dateFormatter.string(from: currentDate as Date), for: .normal)
            strSeleDate = dateButton.titleLabel?.text ?? ""
        }else{
            datePicker.datePickerMode = UIDatePicker.Mode.time
            datePicker.locale = NSLocale.init(localeIdentifier: "en_US") as Locale
            let CurrentDate = UtilObj.getCurrentDate() as NSString
            if(CurrentDate.isEqual(to: (dateButton.titleLabel?.text!)!) || dateButton.titleLabel?.text == "")
            {
                datePicker.minimumDate = currentDate as Date
            }
            
        }
        
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        
        dateView.addSubview(timeViews)
        dateView.addSubview(doneButton)
        dateView.addSubview(datePicker)
        
        //        G3
        
        
        
        
        dateView.center = view.center
        dateView.alpha = 1
        dateView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(dateView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.dateView.transform = .identity
        })
        
        print("SchooleVntVc")
        
        
        
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        
        let dateFormatter: DateFormatter = DateFormatter()
        
        if(datePickerMode .isEqual(to: "date")){
            dateFormatter.dateFormat = "dd MMM yyyy"
        }else{
            dateFormatter.dateFormat = "hh:mm a"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        }
        
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        if(datePickerMode .isEqual(to: "date")){
            dateFormatter.dateFormat = "dd-MM-yyyy"
            dateString = dateFormatter.string(from: sender.date) as NSString
            dateButton.setTitle(selectedDate, for: .normal)
            strSeleDate = selectedDate
            let CurrentDate = UtilObj.getCurrentDate() as NSString
            if(CurrentDate.isEqual(to: (dateButton.titleLabel?.text!)!) || dateButton.titleLabel?.text == "")
            {
                dateFormatter.dateFormat = "hh:mm a"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                let selectedDate: String = dateFormatter.string(from: sender.date)
                timeButton.setTitle(selectedDate, for: .normal)
                
                
            }
        }else{
            timeString =  selectedDate as NSString
            timeButton.setTitle(timeString as String, for: .normal)
        }
    }
    
    @objc func actionDoneButton(_ sender: UIButton)
    {
        dateButton.setTitle(strSeleDate, for: .normal)
        dateView.alpha = 0
    }
    @objc func actionClosePopup(_ sender: UIButton)
    {
        dateView.alpha = 0
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
        LanguageDict = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            topicTextField.textAlignment = .right
            TextMessageView.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            topicTextField.textAlignment = .left
            TextMessageView.textAlignment = .left
        }
        strTextViewPlaceholder = LangDict["teacher_events_hint_msg"] as? String ?? "Type Event content here"
        topicTextField.placeholder = LangDict["teacher_events_hint_title"] as? String
        DateTimeLabel.text = LangDict["teacher_event_txt_datetime"] as? String
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.Config()
        
    }
    func Config(){
        
        TextMessageView.text = strTextViewPlaceholder
        TextMessageView.textColor = UIColor.lightGray
        if(TextMessageView.text != strTextViewPlaceholder){
            TextMessageView.textColor = UIColor.black
        }
        let SendTextmessageLength = String(appDelegate.MaxGeneralSMSCountString)
        MaxTextCount = Int(SendTextmessageLength)!
        if(strLanguage == "ar"){
            SendTextMessageLabel.text =  SendTextmessageLength  + "/"
        }else{
            SendTextMessageLabel.text = "/" + SendTextmessageLength
        }
    }
}
