//
//  OnlineMeetingVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 12/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper


class OnlineViewMeetingVC: UIViewController,UITextViewDelegate,UITextFieldDelegate,
                           UITableViewDelegate,UITableViewDataSource,Apidelegate,UISearchBarDelegate{
    
    @IBOutlet weak var TextMessageView: UITextView!
    @IBOutlet weak var TitleText: UITextField!
    @IBOutlet weak var SendTextMessageLabel: UILabel!
    @IBOutlet weak var remainingCharactersLabel: UILabel!
    @IBOutlet weak var ToStandardSection: UIButton!
    @IBOutlet weak var ComposeTitleLabel: UILabel!
    @IBOutlet weak var SubmissionDateLabel: UILabel!
    @IBOutlet weak var SubmissionView: UIView!
    @IBOutlet weak var submissionViewTopHeight: NSLayoutConstraint!
    @IBOutlet weak var submissionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var submissionDateButton: UIButton!
    
    @IBOutlet weak var tablview: UITableView!
    @IBOutlet weak var meetingView: UIView!
    @IBOutlet weak var meetingTabView: UIView!
    
    @IBOutlet weak var AdView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var ChildIDString = String()
    var SchoolIDString = String()
    
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var meetingSeg: UISegmentedControl!
    
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
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
    var assignmentDict = NSMutableDictionary()
    var popupLoading : KLCPopup = KLCPopup()
    
    
    var getadID : Int!
    var hud : MBProgressHUD = MBProgressHUD()
    var strApiFrom = String()
    var MainDetailTextArray: NSMutableArray = NSMutableArray()
    var SelectedSectionArray : NSMutableArray = NSMutableArray()
    var arrMeetingType = NSMutableArray()
    var arrMeetingList = NSMutableArray()
    
    var selectedDictionary = NSDictionary()
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    
    var firstImage : Int  = 0
    
    weak var timer: Timer?
    
    var menuId : String!
    
    var strCountryName = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("OnlineMeeting123")
        
        
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        
        
        
        
        view.isOpaque = false
        search_bar.delegate = self
        //        view.backgroundColor = .white
        
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(OnlineMeetingVC.catchNotification), name: NSNotification.Name(rawValue: "comeBackMenu"), object:nil)
        
        //
        async {
            do {
                //
                menuId = AdConstant.getMenuId as String
                print("menu_id:\(AdConstant.getMenuId)")
                
                
                
                let AdModal = AdvertismentModal()
                AdModal.MemberId = ChildIDString
                AdModal.MemberType = "student"
                if AdConstant.mgmtVoiceType == "1" {
                    AdModal.MenuId = "0"
                }
                AdModal.MenuId = menuId
                AdModal.SchoolId = SchoolId
                
                
                let admodalStr = AdModal.toJSONString()
                
                
                print("admodalStr2222",admodalStr)
                AdvertismentRequest.call_request(param: admodalStr!) { [self]
                    
                    (res) in
                    
                    let adModalResponse : [AdvertismentResponse] = Mapper<AdvertismentResponse>().mapArray(JSONString: res)!
                    
                    
                    
                    for i in adModalResponse {
                        if i.Status.elementsEqual("1") {
                            print("AdConstantadDataListtt",AdConstant.adDataList.count)
                            
                            
                            
                            
                            AdConstant.adDataList.removeAll()
                            AdConstant.adDataList = i.data
                            
                            startTimer()
                            
                        }else{
                            
                        }
                        
                    }
                    
                    print("admodalStr_count", AdConstant.adDataList .count)
                    
                    
                    
                    //
                }
                
                
            } catch {
                print("Error fetching data: \(error)")
            }
        }
        
        let imgTap = AdGesture (target: self, action: #selector(viewTapped))
        AdView.addGestureRecognizer(imgTap)
        
        
    }
    
    func startTimer() {
        if AdConstant.adDataList.count > 0 {
            
            
            let url : String =  AdConstant.adDataList[0].contentUrl!
            self.imgaeURl = AdConstant.adDataList[0].redirectUrl!
            self.AdName = AdConstant.adDataList[0].advertisementName!
            self.getadID = AdConstant.adDataList[0].id!
            self.imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
            
            AdView.isHidden = false
            adViewHeight.constant = 80
            
            if(self.firstImage == 0){
                self.imageCount =  1
            }
            else{
                self.imageCount =  0
            }
            
            let minC : Int = UserDefaults.standard.integer(forKey: ADTIMERINTERVAL)
            print("minC",minC)
            var AdSec = String(minC / 1000)
            print("minutesBefore",AdSec)
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(AdSec)!, repeats: true) { [weak self] _ in
                
                
                if(AdConstant.adDataList.count == self!.imageCount){
                    self!.imageCount = 0
                    self!.firstImage = 1
                }
                
                self!.imageCount = self!.imageCount + 1
                
                let url : String =  AdConstant.adDataList[self!.imageCount-1].contentUrl!
                self!.imgaeURl = AdConstant.adDataList[self!.imageCount-1].redirectUrl!
                self!.AdName = AdConstant.adDataList[self!.imageCount-1].advertisementName!
                self!.getadID = AdConstant.adDataList[self!.imageCount-1].id!
                
                self!.imageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
            }
        }else {
            AdView.isHidden = true
            adViewHeight.constant = 0
        }
    }
    
    func stopTimer() {
        print("Stopped timer")
        timer?.invalidate()
    }
    
    @IBAction func viewTapped() {
        
        if imgaeURl.isEmpty != true {
            let vc = AdRedirectViewController(nibName: nil, bundle: nil)
            
            
            vc.advertisement_Name = AdName
            vc.redirect_urls = imgaeURl
            vc.adIdget = getadID
            vc.getMenuID = menuId
            
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
            
            
            
        }else{
            print("isEmpty")
        }
        
        
        
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        stopTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //  meetingTabView.isHidden = true
        ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        //        tablview.backgroundColor = .clear
        callGetMeetingsApi()
        
        strCountryName = UserDefaults.standard.object(forKey: COUNTRY_Name) as? String ?? ""
        print(strCountryName)
        //        self.callSelectedLanguage()
        
        
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
            
        case 1:
            meetingTabView.isHidden = false
            meetingView.isHidden = true
            
            callGetMeetingsApi()
            
            
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
    func textViewDidChange(_ textView: UITextView)
    {
        if(TextMessageView.text.count > 0)
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
            TextMessageView.text = textViewPlaceholder
            TextMessageView.textColor = UIColor.lightGray
        }
        
        TextMessageView.resignFirstResponder()
    }
    
    //MARK:BUTTON ACTION
    @IBAction func actionDateButton(_ sender: UIButton) {
        self.dismissKeyboard()
        self.congifureDatePicker()
    }
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionStandardOrSectionSelection(_ sender: UIButton) {
        dismissKeyboard()
        if(strFrom == "Assignment"){
            
            assignmentDict = [
                "AssignmentId" : "0",
                "SchoolID" : SchoolId,
                "AssignmentType": "SMS",
                "Title": self.TitleText.text! ,
                "content": self.TextMessageView.text!,
                //"receiverId":"31025~31024" ,
                // "isentireSection":"1" ,
                //"SubCode":"25928" ,
                "Duration":"0" ,
                "ProcessBy":StaffId,
                "isMultiple":"0" ,
                "processType":"add", "EndDate":strSubmissionDate,
                
            ]
            
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "StaffAddNewClassVC") as! StaffAddNewClassVC
            AddCV.SchoolDetailDict = SchoolDetailDict
            AddCV.sendAssignmentDict = self.assignmentDict
            AddCV.assignmentType = "StaffAssignment"
            self.present(AddCV, animated: false, completion: nil)
        }else{
            let AddCV = self.storyboard?.instantiateViewController(withIdentifier: "StaffAddNewClassVC") as! StaffAddNewClassVC
            AddCV.SchoolDetailDict = SchoolDetailDict
            AddCV.SendedScreenNameStr = "OnlineMeetingVC"
            AddCV.HomeTitleText = TitleText.text!
            AddCV.HomeTextViewText = TextMessageView.text!
            self.present(AddCV, animated: false, completion: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.identifier == "SendTextMessageSegue")
        {
            let segueid = segue.destination as! SendTextMessageVC
            segueid.SegueText = TextMessageView.text
            
        }
        if (segue.identifier == "OnlineDetailsSegue")
        {
            let segueid = segue.destination as! OnlineDetailVC
            
            segueid.selectedDictionary = selectedDictionary
            
        }
    }
    func dismissKeyboard()
    {
        TextMessageView.resignFirstResponder()
        TitleText.resignFirstResponder()
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
        }else{
            TitleText.placeholder  = LangDict["teacher_txt_only_title"] as? String
            ToStandardSection.setTitle(LangDict["teacher_staff_to_sections"] as? String, for: .normal)
            textViewPlaceholder =  LangDict["teacher_txt_typemsg"] as? String ?? "Content?"
        }
        TextMessageView.text = textViewPlaceholder
        TextMessageView.textColor = UIColor.lightGray
        ToStandardSection.isUserInteractionEnabled = false
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
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.minimumDate = currentDate as Date
        
        
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(_:)), for: .valueChanged)
        
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
        
        print("Online?MeetingPopup")
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strSubmissionDate = dateFormatter.string(from: sender.date) as String
        submissionDateButton.setTitle("   " + selectedDate + "   ", for: .normal)
        
    }
    
    @objc func actionDoneButton(_ sender: UIButton)
    {
        dateView.alpha = 0
    }
    @objc func actionClosePopup(_ sender: UIButton)
    {
        popupLoading.dismiss(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrMeetingList.count
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 10
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 250
        }else{
            return 240
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingTVCell", for: indexPath) as! MeetingTVCell
        let dicCountryName = arrMeetingList.object(at: indexPath.section) as! NSDictionary
        
        cell.meetingDateLabel.text = "DATE & TIME : \(dicCountryName["meetingdatetime"] as? String ?? "")"
        cell.typeLabel.text = "MEETING TYPE : \(dicCountryName["meetingtype"] as? String ?? "")"
        cell.subjectLabel.text = "SUBJECT : \(dicCountryName["subject_name"] as? String ?? "")"
        
        cell.titleLabel.text = "\(dicCountryName["topic"] as? String ?? "")"
        cell.descLabel.text = "\(dicCountryName["description"] as? String ?? "")"
        cell.descLabel.numberOfLines = 0
        cell.NewLbl.layer.cornerRadius = 5
        cell.NewLbl.clipsToBounds = true
        
        let iReadVoice : Int? = Int((dicCountryName["is_app_viewed"] as? String ?? "0"))
        if(iReadVoice == 0){
            cell.NewLbl.isHidden = false
        }
        else{
            cell.NewLbl.isHidden = true
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDictionary = arrMeetingList.object(at: indexPath.section) as! NSDictionary
        self.CallReadStatusUpdateApi(String(describing: selectedDictionary["message_id"] as? NSNumber ?? 0), "ONLINECLASS")
        
        self.performSegue(withIdentifier: "OnlineDetailsSegue", sender: self)
        
        
    }
    func CallReadStatusUpdateApi(_ ID : String, _ type : String) {
        
        strApiFrom = "UpdateReadStatus"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        
        var requestStringer = baseUrlString! + READ_STATUS_UPDATE
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ID" : Int(ID),"Type" : type]
        
        let myString = Util.convertNSDictionary(toString: myDict)
        print("UpdateReadStatus \(requestString) \(myString)")
        
        apiCall.nsurlConnectionFunction(requestString, myString, "UpdateReadStatus")
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
    
    func callGetMeetingsApi(){
        if(Util .isNetworkConnected()){
            showLoading()
            strApiFrom = "meetings"
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
            var requestStringer = baseUrlString! + GET_MEETINGS_LIST
            
            let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
            
            if(appDelegate.isPasswordBind == "1"){
                requestStringer = baseReportUrlString! + GET_MEETINGS_LIST
            }
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let myDict:NSMutableDictionary = ["school_id":SchoolIDString,"member_id":ChildIDString]
            let myString = Util.convertDictionary(toString: myDict)
            print("Online \(requestString) \(myString)")
            apiCall.nsurlConnectionFunction(requestString,myString ,"meetings")
        }else{
            Util .showAlert("", msg: NETWORK_ERROR)
        }
    }
    
    func callPostCancelMeetingsApi(){
        if(Util .isNetworkConnected()){
            showLoading()
            strApiFrom = "cancelmeetings"
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
            let requestStringer = baseUrlString! + POST_CANCEL_MEETING
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["header_id":"11318","subheader_id":"20267","process_by":"10000239"]
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
            print("res \(csData) \(pagename)")
            
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
                        let arrD = Dict["data"] as? NSArray ?? []
                        arrMeetingList = NSMutableArray(array: arrD)
                        MainDetailTextArray = NSMutableArray(array: arrD)
                        
                        tablview.reloadData()
                        
                    }else{
                        //  Util.showAlert("", msg: NO_DATA_FOUND)
                        let alert = UIAlertController(title: "", message: NO_DATA_FOUND, preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { action in
                            self.dismiss(animated: true)
                            
                        }))
                        
                        DispatchQueue.main.async{
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                    
                    
                }else
                {
                    Util.showAlert("", msg: NO_DATA_FOUND)
                }
                
                
            }else if(strApiFrom.isEqual("UpdateReadStatus")){
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
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0{
            arrMeetingList = MainDetailTextArray
            self.tablview.reloadData()
        }else{
            let resultPredicate = NSPredicate(format: "%K CONTAINS[c] %@","subject_name", searchText)
            let arrSearchResults = MainDetailTextArray.filter { resultPredicate.evaluate(with: $0) } as NSArray
            arrMeetingList = NSMutableArray(array: arrSearchResults)
            if(arrMeetingList.count > 0){
                self.tablview.reloadData()
                print("DetailVoiceArray.count > 0")
            }else{
                print("noDataLabel.isHidden = false")
            }
            self.tablview.reloadData()
        }
        
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        search_bar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        SelectedSectionArray.removeAllObjects()
        arrMeetingList = MainDetailTextArray
        self.tablview.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        search_bar.resignFirstResponder()
    }
}
