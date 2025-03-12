//
//  LeaveRequestVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 01/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper



class LeaveRequestVC: UIViewController,UITextViewDelegate,Apidelegate {
    @IBOutlet weak var TextMessageView: UITextView!
    @IBOutlet weak var FromDateLbl: UILabel!
    @IBOutlet weak var ToDateLbl: UILabel!
    @IBOutlet weak var FloatToLabel: UILabel!
    @IBOutlet weak var FloatFromLabel: UILabel!
    @IBOutlet weak var DoneButton: UIButton!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var FloatChooseDate: UILabel!
    @IBOutlet weak var DatePickerView: UIDatePicker!
    @IBOutlet weak var ApplyButton: UIButton!
    @IBOutlet weak var DateView: UIView!
    @IBOutlet weak var MainView: UIView!
    @IBOutlet weak var LeaveHistoryButton: UIButton!
    
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    @IBOutlet weak var AdView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var SelectedDate = Date()
    var pickerString = String()
    var strApiFrom = NSString()
    var ChildId = String()
    var SchoolId = String()
    var LeaveFromDate = String()
    var LeaveToDate = String()
    var strLanguage = String()
    var strPlaceholder = String()
    var languageDictionary = NSDictionary()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    
    var getadID : Int!
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    
    
    weak var timer: Timer?
    
    var menuId : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        
        
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        
        
        
        
        
        async {
            do {
                
                menuId = AdConstant.getMenuId as String
                print("menu_id:\(AdConstant.getMenuId)")
                
                
                
                let AdModal = AdvertismentModal()
                AdModal.MemberId = ChildId
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        
        self.callSelectedLanguage()
        
    }
    
    @IBAction func actionCancelButton(_ sender: UIButton) {
        DateView.isHidden = true
    }
    
    @IBAction func actionDoneButton(_ sender: UIButton) {
        DateView.isHidden = true
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .none
        dateFormatter1.dateFormat = "dd-MMM-yyyy"
        dateFormatter1.timeZone = NSTimeZone.default
        
        DatePickerView.datePickerMode = .date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        SelectedDate = DatePickerView.date
        let SelectedString = dateFormatter.string(from: DatePickerView.date)
        if(pickerString == "From")
        {
            print(SelectedDate)
            FromDateLbl.text = SelectedString
            dateFormatter1.dateFormat = "dd-MM-yyyy"
            LeaveFromDate = dateFormatter1.string(from: DatePickerView.date)
            
            utilObj.printLogKey(printKey: "LeaveFromDate", printingValue: LeaveFromDate)
            
            
            
        }else{
            ToDateLbl.text = SelectedString
            dateFormatter1.dateFormat = "dd-MM-yyyy"
            LeaveToDate = dateFormatter1.string(from: DatePickerView.date)
            utilObj.printLogKey(printKey: "LeaveFromDate", printingValue: LeaveFromDate)
            utilObj.printLogKey(printKey: "LeaveToDate", printingValue: LeaveToDate)
        }
    }
    
    func asignDefaultDate()
    {
        
        let dateFormatter = DateFormatter()
        let dateFormatter1 = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let CurrentDate = NSDate()
        let selectedDate = dateFormatter.string(from: CurrentDate as Date)
        FromDateLbl.text = selectedDate
        ToDateLbl.text = selectedDate
        dateFormatter1.dateFormat = "dd-MM-yyyy"
        LeaveFromDate = dateFormatter1.string(from: CurrentDate as Date)
        LeaveToDate = dateFormatter1.string(from: CurrentDate as Date)
        utilObj.printLogKey(printKey: "LeaveFromDate", printingValue: LeaveFromDate)
        utilObj.printLogKey(printKey: "LeaveToDate", printingValue: LeaveToDate)
        
    }
    //MARK: TEXTVIEW DELEGATE DELEGATE
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(TextMessageView.text == strPlaceholder)
        {
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        setupTextViewAccessoryView()
        if(TextMessageView.text == strPlaceholder)
        {
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
        return true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        textView.resignFirstResponder()
        return true
    }
    func textViewDidChange(_ textView: UITextView)
    {
        if(TextMessageView.text.count > 0)
        {
            ApplyButton.backgroundColor = utilObj.PARENT_NAV_BAR_COLOR
            ApplyButton.isUserInteractionEnabled = true
        }
        else
        {
            ApplyButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            ApplyButton.isUserInteractionEnabled = false
            
        }
        
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        
        if textView.text?.last == " "  && text == " "
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
            TextMessageView.text = strPlaceholder
            TextMessageView.textColor = UIColor.lightGray
        }
        
        TextMessageView.resignFirstResponder()
    }
    
    @IBAction func actionApplyButton(_ sender: UIButton) {
        dismissKeyboard()
        if(FromDateLbl.text == "")
        {
            Util.showAlert("", msg: languageDictionary["date_select"] as? String)
        }else if(ToDateLbl.text == "")
        {
            Util.showAlert("", msg: languageDictionary["to_date_alert"] as? String)
        }else if(TextMessageView.text == strPlaceholder || TextMessageView.text == " " || TextMessageView.text.count == 0)
        {
            Util.showAlert("", msg: languageDictionary["choose_reason"] as? String)
        }
        
        else{
            if(Util .isNetworkConnected())
            {
                
                self.CallApplyLeaveRequestApi()
                
            }
            else
            {
                Util .showAlert("", msg: strNoInternet)
            }
        }
        
        
    }
    
    
    
    //MARK: - Function of datePicker
    
    @IBAction func actionFromButton(_ sender: UIButton) {
        dismissKeyboard()
        ToDateLbl.text = ""
        DateView.isHidden = false
        pickerString = "From"
        self.DatePickerView.datePickerMode = UIDatePicker.Mode.date
        if #available(iOS 13.4, *) {
            DatePickerView.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        let result = formatter.string(from: date)
        let currentDate = formatter.date(from: result)
        self.DatePickerView.minimumDate = currentDate
        
        
    }
    
    
    //MARK: - Function of datePicker
    
    @IBAction func actionToButton(_ sender: UIButton) {
        dismissKeyboard()
        DateView.isHidden = false
        pickerString = "To"
        self.DatePickerView.minimumDate = SelectedDate
        self.DatePickerView.datePickerMode = UIDatePicker.Mode.date
        if #available(iOS 13.4, *) {
            DatePickerView.preferredDatePickerStyle = .wheels
        } else {
        }
        
        
    }
    
    @IBAction func actionLeaveHistoryButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LeaveHistorySegue", sender: self)
    }
    
    func dismissKeyboard()
    {
        TextMessageView.resignFirstResponder()
    }
    
    // MARK: - Api Calling
    func CallApplyLeaveRequestApi() {
        showLoading()
        strApiFrom = "CallApplyLeaveRequestApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + APPLY_LEAVE_REQUEST
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        
        print("APPLYLEAVE",requestString)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId,"LeaveFromDate": LeaveFromDate,"LeaveToDate": LeaveToDate,"Reason": TextMessageView.text!, COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallApplyLeaveRequestApi")
    }
    
    // MARK: - Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        
        hideLoading()
        if(csData != nil)
        {
            utilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if(strApiFrom == "CallApplyLeaveRequestApi")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["Status"]!)
                        let Message = String(describing: dict["Message"]!)
                        if(Status == "1")
                        {
                            Util.showAlert("", msg: Message)
                            self.navigationController?.popViewController(animated: true)
                            
                        }else{
                            
                            Util.showAlert("", msg: Message)
                            
                        }
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
    
    func navTitle()
    {
        
        let titleLabel = UILabel()
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        titleLabel.textColor = UIColor (red:0.0/255.0, green:183.0/255.0, blue: 190.0/255.0, alpha: 1)
        let secondWord =  languageDictionary["leave"] as? String
        let thirdWord   = languageDictionary["requesttttt"] as? String
        let comboWord = (secondWord ?? "Leave" ) + " " + (thirdWord ?? "Request")
        let attributedText = NSMutableAttributedString(string:comboWord)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.white]
        let range = NSString(string: comboWord).range(of: secondWord ?? "Leave")
        attributedText.addAttributes(attrs, range: range)
        
        titleLabel.attributedText = attributedText
        self.navigationItem.titleView = titleLabel
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
                }else{
                    self.loadViewData()
                }
            } catch {
                self.loadViewData()
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDictionary = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            TextMessageView.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            TextMessageView.textAlignment = .left
        }
        strPlaceholder =  LangDict["hint_leave_reason"] as? String ?? "Reason for leave"
        LeaveHistoryButton.setTitle(LangDict["leave_history"] as? String , for: .normal)
        ApplyButton.setTitle(LangDict["requesttttt"] as? String , for: .normal)
        
        FloatFromLabel.text = LangDict["txt_from"] as? String
        FloatToLabel.text = LangDict["txt_to"] as? String
        FloatChooseDate.text = LangDict["choose_date"] as? String
        CancelButton.setTitle(LangDict["teacher_cancel"] as? String , for: .normal)
        DoneButton.setTitle(LangDict["teacher_btn_ok"] as? String , for: .normal)
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
        
    }
    
    func loadViewData(){
        DateView.isHidden = true
        navTitle()
        pickerString = "From"
        ApplyButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        LeaveHistoryButton.layer.cornerRadius = 5
        LeaveHistoryButton.clipsToBounds = true
        ApplyButton.layer.cornerRadius = 5
        ApplyButton.clipsToBounds = true
        MainView.layer.cornerRadius = 8
        MainView.clipsToBounds = true
        DateView.layer.cornerRadius = 8
        DateView.clipsToBounds = true
        TextMessageView.text = strPlaceholder
        TextMessageView.textColor = UIColor.lightGray
        asignDefaultDate()
    }
    
    
    
}
