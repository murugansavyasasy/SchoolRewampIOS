//
//  NoticeBoardVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 12/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import DropDown

class NoticeBoardVC: UIViewController,UITextViewDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,Apidelegate,UISearchBarDelegate{

    
    @IBOutlet weak var noticeBoardTop: NSLayoutConstraint!
    
    
    @IBOutlet weak var schoolDropDownHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var segmentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var schoolNameLbl: UILabel!
    @IBOutlet weak var schoolNmaeDropView: UIView!
    
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var search_bar: UISearchBar!
    @IBOutlet weak var noticeboardSubView: UIView!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var noticeboardListView: UIView!
    

    @IBOutlet weak var composeNoticeboardView: UIView!
    @IBOutlet weak var listTv: UITableView!
    @IBOutlet weak var btnTwo: UIButton!
    @IBOutlet weak var btnOne: UIButton!
    @IBOutlet weak var noticeSegment: UISegmentedControl!
    
    @IBOutlet weak var SchoolNameRegionalLbl: UILabel!
    @IBOutlet weak var toLbl: UILabel!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var toView: UIView!
    
    
    @IBOutlet weak var fromView: UIView!
    
    @IBOutlet var MyTableView: UITableView!
    @IBOutlet weak var TextMessageView: UITextView!
    @IBOutlet weak var topicHeadingTextField: UITextField!
    @IBOutlet weak var remainingCharactersLabel: UILabel!
    @IBOutlet weak var ConfirmButton: UIButton!
    @IBOutlet weak var SendTextMessageLabel: UILabel!
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var strCountryCode = String()
    var ScreenWidth = CGFloat()
    var selectedSchoolsArray = NSMutableArray()
    var schoolsArray = NSMutableArray()
    var strApiFrom = NSString()
    var MaxTextCount = Int()
    var strTextViewPlaceholder = String()
    var strLanguage = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    
    var display_time : String!
    var display_hours : String!
    var display_minutes : String!
    var url_time : String!
    var url_hours : String!
    var url_minutes : String!
    var display_date : String!
    var url_date : String!
    var dropDown  = DropDown()

    var DetailTextArray = NSMutableArray()

    var SelectedStr = String()
    var SelectedIndex = IndexPath()
    let utilObj = UtilClass()
    var altSting = String()
    var languageDictionary = NSDictionary()
    var MainDetailTextArray: NSMutableArray = NSMutableArray()
    var type : Int!
    var instituteId : Int!
    var staffId  : Int!
    var identifer = "TextFileTableViewCell"
    var bIsSeeMore = Bool()
    var SelectedSectionArray : NSMutableArray = NSMutableArray()

    var staffRole : String!

    var schoolIdArr : [String] = []

    var schoolNameArr : [String] = []

    //MARK: View Controller Delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noticeboardListView.isHidden = true
        var todaysDate = NSDate()
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM/dd/yyyy"
        var DateInFormat = dateFormatter.string(from: todaysDate as Date)
        
        HiddenLabel.isHidden = true
        fromLbl.text = DateInFormat
        toLbl.text = DateInFormat
        
        composeNoticeboardView.isHidden = true
        ConfirmButton.isUserInteractionEnabled = false
        ConfirmButton.layer.cornerRadius = 5
        ConfirmButton.layer.masksToBounds = true
        
        btnOne.setTitle("Compose Notice Board", for: .normal)
        btnTwo.setTitle("Notice Board", for: .normal)


        let FromDateGuesture = UITapGestureRecognizer(target: self, action: #selector(FromDateAction))
        self.fromView.addGestureRecognizer(FromDateGuesture)
        
        
        let ToDateGuesture = UITapGestureRecognizer(target: self, action: #selector(ToDateAction))
        self.toView.addGestureRecognizer(ToDateGuesture)
        
        let userDefaults = UserDefaults.standard

        staffId = userDefaults.integer(forKey: DefaultsKeys.StaffID)

        staffRole = userDefaults.string(forKey: DefaultsKeys.StaffRole)!
        instituteId = userDefaults.integer(forKey: DefaultsKeys.SchoolD)

        print("SchoolListcount",appDelegate.LoginSchoolDetailArray.count)
        print("staffRole",staffRole)

        if staffRole == "p3" {
            btnOne.isHidden = true
            btnTwo.isHidden = true
            
            listTv.dataSource = self
                listTv.delegate = self
            search_bar.delegate = self

            segmentViewHeight.constant = 0
            CallDetailNoticeMessageApi()
            noticeBoardTop.constant = 100
            noticeboardListView.isHidden = false

        }else{
            noticeBoardTop.constant = 150

            btnOne.isHidden = false
            btnTwo.isHidden = false
            segmentViewHeight.constant = 40



        }

        
        
        if appDelegate.LoginSchoolDetailArray.count > 1 {
            schoolNmaeDropView.isHidden = false
            schoolNameLbl.isHidden = false
            noticeBoardTop.constant = 100

            schoolDropDownHeight.constant = 35

        }else{
            noticeBoardTop.constant = 150

            schoolNmaeDropView.isHidden = true
            schoolDropDownHeight.constant = 0
            schoolNameLbl.isHidden = true


        }



        let dropDownGesture  = UITapGestureRecognizer(target: self, action: #selector(schoolNameDropDownList))
        schoolNmaeDropView.addGestureRecognizer(dropDownGesture)
    }

    @IBAction func schoolNameDropDownList(){

        var StaffId: [Int] = []
        var schoolName: [String] = []


        schoolNameArr.forEach {arrType  in
//            StaffId.append((arrType.staffId))
            schoolName.append(arrType)

        }
//        let myArray = stafflistdata[1].staffName

        dropDown.dataSource = schoolName//4
        dropDown.anchorView = schoolNmaeDropView //5

        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)

        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7


        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")

            let selectedName = schoolNameArr[index]
               let selectedID = schoolIdArr[index]


            schoolNameLbl.text = selectedName
            instituteId = Int(selectedID)
            CallDetailNoticeMessageApi()
            print("selectedID \(selectedID)")



        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        
        self.callSelectedLanguage()
        let SendTextmessageLength = String(appDelegate.MaxGeneralSMSCountString)
        MaxTextCount = Int(SendTextmessageLength)!
        if(strLanguage == "ar"){
            SendTextMessageLabel.text =  SendTextmessageLength  + "/"
        }else{
            SendTextMessageLabel.text = "/" + SendTextmessageLength
        }
        
        
    }
    
    func Config()
    {
        TextMessageView.text = strTextViewPlaceholder
        TextMessageView.textColor = UIColor.lightGray
        ConfirmButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        ConfirmButton.isUserInteractionEnabled = false
        
        for  schoolDict in appDelegate.LoginSchoolDetailArray {
            let singleSchoolDictionary = schoolDict as? NSDictionary
            let schoolDic = NSMutableDictionary()
            schoolDic["SchoolId"] = singleSchoolDictionary?.object(forKey: "SchoolID")
            schoolDic["StaffID"] = singleSchoolDictionary?.object(forKey: "StaffID")
            schoolsArray.add(schoolDic)
            schoolIdArr.append(schoolDic["SchoolId"] as! String)
            selectedSchoolsArray.add(schoolDic)
        }
        
    }
    
    //MARK: Text Field Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // validateAllFields()
        if range.location == 0 && string == " " {
            
            return false
        }
        
        return true
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        
        if(TextMessageView.text == strTextViewPlaceholder)
        {
            TextMessageView.text = ""
            TextMessageView.textColor = UIColor.black
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        setupTextViewAccessoryView()
        if(TextMessageView.text == strTextViewPlaceholder)
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
        validateAllFields()
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
    
    //MARK: Button Action
    @IBAction func actionCloseView(_ sender: UIButton) {
        self.dismissKeyboard()
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionConfirmButton (_ sender: UIButton) {
        self.dismissKeyboard()
        if(Util .isNetworkConnected())
        {
            if((topicHeadingTextField.text?.count)! > 0)
            {
                self.callPrincipalNoticeBoardApi()
            }
        }
        else
        {
            Util .showAlert("", msg: strNoInternet)
        }
    }
    
    func dismissKeyboard()
    {
        TextMessageView.resignFirstResponder()
        topicHeadingTextField.resignFirstResponder()
    }
    
    //MARK: TABLEVIEW DELEGATE
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == MyTableView{
            if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 65
        }else{
            return 50
        }

    }else{
        if(indexPath.row <= (DetailTextArray.count - 1)){

            if(SelectedIndex == indexPath)
            {
                if(SelectedStr == "Selected")
                {
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        return 388
                    }else{
                        return 345
                    }
                }else{
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        return 299
                    }else{
                        return 199
                    }

                }

            }else
            {
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    return 299
                }else{
                    return 199
                }
            }
        }else{
            return 40
        }
    }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

//        if btnOne.backgroundColor == UIColor(named: "CustomOrange") {
print("tableView",tableView)
            if tableView == MyTableView{

                let isPrincipal = appDelegate.isPrincipal as NSString
                let isAdmin = appDelegate.isAdmin as NSString

                return appDelegate.LoginSchoolDetailArray.count
//            }
        }else{
//            if tableView == listTv{
                if(DetailTextArray.count == 0){
                    
                    if(appDelegate.isPasswordBind != "0"){
                        emptyView()
//                    }else{
//                        emptyView()
                    }
                    return 0
                }else{
                    restoreView()
                    if(!bIsSeeMore){
                        return DetailTextArray.count + 1
                    }else{
                        return DetailTextArray.count
                    }
                }
            }

//    }
//        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == MyTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeBoardTVCell", for: indexPath) as! NoticeBoardTVCell
            let schoolDict = appDelegate.LoginSchoolDetailArray .object(at: indexPath.row) as? NSDictionary
            cell.SchoolNameLbl.text = schoolDict?["SchoolName"] as? String
            var schoolNameReg  =  schoolDict?["SchoolNameRegional"] as? String

            schoolNameArr.append(schoolDict?["SchoolName"] as! String)
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
        }else{
            if(indexPath.row <= (DetailTextArray.count - 1)){
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "TextFileTableViewCell", for: indexPath) as! TextFileTableViewCell
                cell1.backgroundColor = UIColor.clear
                cell1.NewLbl.isHidden = true
                let dict = DetailTextArray[indexPath.row] as! NSDictionary
                cell1.TimeLbl.text = String(describing: dict["Day"]!)
                cell1.DateLbl.text = String(describing: dict["Date"]!)
                cell1.SubjectLbl.text = String(describing: dict["NoticeBoardTitle"]!)
                cell1.NoticeTextView.text = String(describing: dict["NoticeBoardContent"]!)
                let TextFieldChar : String = String(describing: dict["NoticeBoardContent"]!)

                cell1.NoticeTextView.tintColor = .systemGreen
                cell1.NoticeTextView.isEditable = false
                cell1.NoticeTextView.dataDetectorTypes = .all

                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    if(TextFieldChar.count > 200)
                    {
                        cell1.ExtendArrow.isHidden = false
                        cell1.NoticeButton.tag = indexPath.row

                        cell1.NoticeButton.addTarget(self, action: #selector(ExpandView(sender:)), for: .touchUpInside)

                    }else{
                        cell1.ExtendArrow.isHidden = true
                        cell1.ExtendArrow.image = UIImage(named: "GrayDownArrow")
                        cell1.NoticeButton.isUserInteractionEnabled = false
                    }

                }else
                {
                    if(TextFieldChar.count > 110)
                    {
                        cell1.ExtendArrow.isHidden = false
                        cell1.NoticeButton.tag = indexPath.row

                        cell1.NoticeButton.addTarget(self, action: #selector(ExpandView(sender:)), for: .touchUpInside)

                    }else{
                        cell1.ExtendArrow.isHidden = true
                        cell1.ExtendArrow.image = UIImage(named: "GrayDownArrow")
                        cell1.NoticeButton.isUserInteractionEnabled = false
                    }

                }
                return cell1
            }

            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreTVCell", for: indexPath) as! SeeMoreTVCell
                print("6")
                cell.SeeMoreBtn.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
                cell.backgroundColor = .clear
                return cell

            }

        }

    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
print("schoolsArray",schoolsArray)
        print("selectedSchoolsArray",selectedSchoolsArray)

        if btnOne.backgroundColor == UIColor(named: "CustomOrange"){
            if(selectedSchoolsArray .contains(schoolsArray.object(at: indexPath.row)))
            {
                selectedSchoolsArray.remove(schoolsArray.object(at: indexPath.row))
            }else{
                selectedSchoolsArray.add(schoolsArray.object(at: indexPath.row))
            }
            self.validateAllFields()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if btnOne.backgroundColor == UIColor(named: "CustomOrange"){
            if(selectedSchoolsArray .contains(schoolsArray.object(at: indexPath.row)))
            {
                selectedSchoolsArray.remove(schoolsArray.object(at: indexPath.row))
            }else{
                selectedSchoolsArray.add(schoolsArray.object(at: indexPath.row))
            }
            self.validateAllFields()
        }
    }
    
    //MARK: Api Calling
    
    func callPrincipalNoticeBoardApi()
    {
        
        
        var todate : String!
        var fromdate : String!
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "MMM-dd-yyyy"
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "dd-MM-yyyy"
        
        
        let dateString = fromLbl.text
        
        if let date = inputDateFormatter.date(from: dateString!) {
            let outputDateString = outputDateFormatter.string(from: date)
            fromdate = outputDateString
            print(outputDateString) // "2024 May 30"
        } else {
            print("Invalid date format")
        }
        
        
        
        let inputDateFormatter1 = DateFormatter()
        inputDateFormatter1.dateFormat = "MMM-dd-yyyy"
        
        let outputDateFormatter1 = DateFormatter()
        outputDateFormatter1.dateFormat = "dd-MM-yyyy"
        
        let dateString1 = toLbl.text
        
        if let date1 = inputDateFormatter.date(from: dateString1!) {
            let outputDateString1 = outputDateFormatter1.string(from: date1)
            print(outputDateString1)
            todate = outputDateString1
        } else {
            print("Invalid date format")
        }
        
        
        
        
        
        
        showLoading()
        strApiFrom = "PrincipalNoticeBoard"
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + ManageNoticeBoard
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = [
            "TopicHeading" : topicHeadingTextField.text!,
            "TopicBody" : TextMessageView.text!,
            "FromDate": fromdate,
            "ToDate": todate,
            "Schools" : selectedSchoolsArray, COUNTRY_CODE: strCountryCode]
        
        print("FromDate",fromdate)
        print("ToDate",todate)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: myDict)
        print("myDict",myDict)
        print("requestString",requestString)
        apiCall.nsurlConnectionFunction(requestString, myString, "PrincipalNoticeBoard Api")
    }
    
    //MARK: Api Response
    
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom.isEqual(to: "PrincipalNoticeBoard"))
            {
                if((csData?.count)! > 0)
                {
                    let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                    if let status = dicUser["Status"] as? NSString
                    {
                        let Status = status
                        let Message = dicUser["Message"] as! NSString
                        
                        if(Status .isEqual(to: "1")){
                            Util.showAlert("", msg: Message as String?)
                            dismiss(animated: false, completion: nil)
                        }else{
                            Util.showAlert("", msg: Message as String?)
                        }
                    }else{
                        if(dicUser["Message"] != nil){
                            Util.showAlert("", msg: String(describing: dicUser["Message"]!))
                        }else{
                            Util.showAlert("", msg: strSomething)
                        }
                        
                    }
                }else
                {
                    Util.showAlert("", msg: strSomething)
                }

        }   else if(strApiFrom == "CallDetailNoticeMessage")
        {
            if let CheckedArray = csData as? NSArray
            {
                let arrayData = CheckedArray
                for i in 0..<arrayData.count
                {
                    let dict = CheckedArray[i] as! NSDictionary
                    let Status = String(describing: dict["Status"]!)
                    let Message = dict["Message"] as? String ?? ""
                    altSting = Message
                    if(Status == "1")
                    {
                        let dict = arrayData[i] as! NSDictionary
                        var MutalDict : NSMutableDictionary = dict.mutableCopy() as! NSMutableDictionary

                        MutalDict["ID"] = String(describing: i)
                        DetailTextArray.add(MutalDict)
                        MainDetailTextArray.add(MutalDict)
                    }else{

                        if(appDelegate.isPasswordBind == "0"){
                            Util.showAlert("", msg: Message)


                        }


                    }
                }

                DetailTextArray =  MainDetailTextArray
                print("detailstaffId",staffId)
                Childrens.saveSchoolNoticeBoardDetail(DetailTextArray as! [Any] , String(staffId))

                utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)


                 listTv.reloadData()

            }
            else{
                Util.showAlert("", msg: strSomething)
            }
        }
        if(strApiFrom == "CallSeeMoreDetailNoticeMessage")
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
                        let dict = arrayData[i] as! NSDictionary
                        var MutalDict : NSMutableDictionary = dict.mutableCopy() as! NSMutableDictionary

                        MutalDict["ID"] = String(describing: i)
                        DetailTextArray.add(MutalDict)
                    }else{
                        Util.showAlert("", msg: Message)

//                        AlertMessage(strAlert: Message)




                    }
                }


                Childrens.saveSchoolNoticeBoardDetail(DetailTextArray as! [Any] , String(staffId))

                utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)

//                NoticeBoardTableview.reloadData()


            }
            else{
                Util.showAlert("", msg: strSomething)
            }
        }
        else if(strApiFrom == "UpdateReadStatus")
        {
            if((csData?.count)! > 0){

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
    
    //MARK: Loading Indicator
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        
    }
    
    func validateAllFields()
    {
        if(TextMessageView.text.count > 0 && (topicHeadingTextField.text?.count)! > 0  && selectedSchoolsArray.count > 0 && TextMessageView.text != strTextViewPlaceholder)
        {
            ConfirmButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
            ConfirmButton.isUserInteractionEnabled = true
        }
        else
        {
            ConfirmButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            ConfirmButton.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func actionValueChanged(_ sender: UITextField) {
        validateAllFields()
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        let bundle = Bundle(for: Swift.type(of: self))
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
            topicHeadingTextField.textAlignment = .right
            TextMessageView.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            topicHeadingTextField.textAlignment = .left
            TextMessageView.textAlignment = .left
        }
        strTextViewPlaceholder = LangDict["teacher_nb_hint_msg"] as? String ?? "Type content here"
        ConfirmButton.setTitle(LangDict["teacher_txt_send"] as? String, for: .normal)
        topicHeadingTextField.placeholder = LangDict["teacher_nb_hint_title"] as? String ?? "Type News Topic?"
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.Config()
        
    }
    
    
    
    
    @IBAction func FromDateAction(){
        
        RPickerTwo.selectDate(title: "Select Date", cancelText: "Cancel", datePickerMode: .date, style: .Inline, didSelectDate: {[weak self] (today_date) in
            
            self?.display_date = today_date.dateString("MMM/dd/yyyy")
            self?.url_date = today_date.dateString("dd/M/yyyy")
            self?.fromLbl.text = self!.display_date
            
        })
    }
    
    
    @IBAction func ToDateAction(){
        RPickerTwo.selectDate(title: "Select Date", cancelText: "Cancel", datePickerMode: .date, style: .Inline, didSelectDate: {[weak self] (today_date) in
            
            
            self?.display_date = today_date.dateString("MMM/dd/yyyy")
            self?.url_date = today_date.dateString("dd/M/yyyy")
            self?.toLbl.text = self!.display_date
            
        })
        
    }
    









    @IBAction func btnOneAct(_ sender: Any) {
        btnOne.backgroundColor = UIColor(named: "CustomOrange")
        btnOne.titleLabel?.textColor = .white
        btnTwo.backgroundColor = .white
        btnTwo.titleLabel?.textColor = .black

        noticeboardListView.isHidden = true

    }
    

    @IBAction func btn2Act(_ sender: Any) {
//        appDelegate.LoginSchoolDetailArray.coun
        appDelegate.LoginSchoolDetailArray
        let userDefaults = UserDefaults.standard

        noticeboardListView.isHidden = false
        instituteId = userDefaults.integer(forKey: DefaultsKeys.SchoolD)
        staffId = userDefaults.integer(forKey: DefaultsKeys.StaffID)


    CallDetailNoticeMessageApi()

    listTv.dataSource = self
        listTv.delegate = self
    search_bar.delegate = self
//        CallDetailNoticeMessageApi()
        btnTwo.backgroundColor = UIColor(named: "CustomOrange")
        btnOne.backgroundColor = .white
        btnTwo.titleLabel?.textColor = .white
        btnOne.titleLabel?.textColor = .black




    }


//    NOTICEBOARD
    func CallDetailNoticeMessageApi() {
        showLoading()
        strApiFrom = "CallDetailNoticeMessage"

        let apiCall = API_call.init()
        apiCall.delegate = self;

        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + NOTICE_BOARD_MESSAGE


        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String

        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + NOTICE_BOARD_MESSAGE
        }

        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolID" : instituteId]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        print("requestStringer1",requestStringer)

        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailNoticeMessage")
    }


    func CallSeeMoreDetailNoticeMessageApi() {
        showLoading()
        strApiFrom = "CallSeeMoreDetailNoticeMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;

        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + NOTICE_BOARD_MESSAGE_SEEMORE

        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String

        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + NOTICE_BOARD_MESSAGE_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolID" : instituteId]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        print("requestStringer2",requestStringer)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)

        apiCall.nsurlConnectionFunction(requestString, myString, "CallSeeMoreDetailNoticeMessage")
    }



    // MARK: - TableView Delegates





    func emptyView(){
        let noview : UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.listTv.bounds.size.width, height: self.listTv.bounds.size.height))

        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y:  8, width: self.listTv.bounds.size.width, height: 60))
        noDataLabel.text = altSting
        noDataLabel.textColor = .red
        noDataLabel.backgroundColor = UIColor(named: "NoDataColor")

        noDataLabel.numberOfLines = 0

        noDataLabel.textAlignment = NSTextAlignment.center
        noview.addSubview(noDataLabel)

        let button = UIButton(frame: CGRect(x: self.listTv.bounds.size.width - 108, y: noDataLabel.frame.height + 30, width: 100, height: 32))
        button.setTitle(SEE_MORE_TITLE, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        button.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        noview.addSubview(button)
        button.titleLabel?.font = .systemFont(ofSize: 12)

        button.layer.cornerRadius = 5
        button.layer.borderWidth = 3
        button.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor

        self.listTv.backgroundView = noview
    }
    func restoreView(){
        self.listTv.backgroundView = nil
    }

    @objc func seeMoreButtonTapped(sender : UIButton) {
        //Write button action here
        bIsSeeMore = true
        self.listTv.reloadData()
        CallSeeMoreDetailNoticeMessageApi()





    }

    @objc func ExpandView(sender: UIButton){
        let SenderButton = sender
        SelectedIndex = IndexPath(row: sender.tag, section: 0)
        let cell = listTv.cellForRow(at: SelectedIndex) as! TextFileTableViewCell
        if(SenderButton.isSelected){
            SelectedStr = "Selected"
            SenderButton.isSelected = false
            cell.ExtendArrow.image = UIImage(named: "GrayUpArrow")
        }else{
            SelectedStr = "NotSelected"
            SenderButton.isSelected = true

            cell.ExtendArrow.image = UIImage(named: "GrayDownArrow")

        }
        listTv.reloadData()

    }



    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText.count == 0{
            DetailTextArray =  MainDetailTextArray
            self.listTv.reloadData()
        }else{
            let resultPredicate = NSPredicate(format: "NoticeBoardContent CONTAINS [c] %@ OR NoticeBoardTitle CONTAINS [c] %@ ", searchText, searchText)
            let arrSearchResults = MainDetailTextArray.filter { resultPredicate.evaluate(with: $0) } as NSArray
            DetailTextArray = NSMutableArray(array: arrSearchResults)
            if(DetailTextArray.count > 0){
                self.listTv.reloadData()
                print("DetailVoiceArray.count > 0")
            }else{
                print("noDataLabel.isHidden = false")
                altSting = "No Records"
                                emptyView()
            }
            //            CallDetailSeeMoreEmergencyVocieApi()
            self.listTv.reloadData()
        }


    }


    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        search_bar.endEditing(true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //        self.NoticeBoardTableview.reloadData()
        //        CallSeeMoreDetailNoticeMessageApi()

        search_bar.resignFirstResponder()
    }


    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("searchBar.resignFirstResponder()")

        searchBar.resignFirstResponder()
        print("searchBar.resignFirstResponder()")
        print(DetailTextArray.count)

        SelectedSectionArray.removeAllObjects()
        DetailTextArray = MainDetailTextArray
        self.listTv.reloadData()
    }

}
