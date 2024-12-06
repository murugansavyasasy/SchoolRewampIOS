//
//  ParentTableVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 08/06/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit
import MarqueeLabel
import ObjectMapper

class ParentTableVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate,Apidelegate,UIPopoverPresentationControllerDelegate
{
    var ArrayChildData: NSArray = []
    var popupMenu : KLCPopup  = KLCPopup()
    var popupHelpBtn : KLCPopup  = KLCPopup()
    var popupChangePasswordBtn: KLCPopup  = KLCPopup()
    var dicChilddetail : NSDictionary = [:]
    var dicResponse: NSDictionary = [:]
    var selectedDictionary = NSDictionary()
    var languageDictionary = NSDictionary()
    var selectedUnRead = NSString()
    var unReadCountArray: NSMutableArray = []
    var arrayForgetChangeDatas: NSArray = []
    var strTitleName = String()
    var strApiFrom = NSString()
    var fromVC = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var UserMobileNo = String()
    var UserPassword = String()
    var strcombination : String  = String()
    var strLanguage = String()
    var strLoginAs = String()
    var strCountryCode = String()
    var strCountryID = String()
    var memeberArrayString = String()
    var strPopOverFrom = String()
    let UtilObj = UtilClass()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    


    @IBOutlet weak var remainingCharactersLabel: UILabel!
    @IBOutlet weak var LoginAsLabel: UILabel!
    
    @IBOutlet  var MenuPopupView: UIView!
    @IBOutlet  var MenuView: UIView!
    @IBOutlet  var helpTextView: UITextView!
    @IBOutlet  var ParentTableView: UITableView!
    @IBOutlet var PopupMenuView: UIView!
    @IBOutlet var PopupChangePasswordView: UIView!
    @IBOutlet var PopupHelpView: UIView!
    
    @IBOutlet weak var ExistingPassword: UITextField!
    @IBOutlet weak var NewPasswordLabel: UITextField!
    @IBOutlet weak var VerifyNewPasswordLabel: UITextField!
    @IBOutlet weak var ShowExistingPswdButton: UIButton!
    @IBOutlet weak var ShowVerifyPswdButton: UIButton!
    @IBOutlet weak var ShowNewPswdButton: UIButton!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var LogoutLabel: UILabel!
    @IBOutlet weak var FAQLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var PrincipalHeightConst: NSLayoutConstraint!
    var stralerMsg = String()
    
    var SelSchool = String()
    var  QuestionData : [UpdateDetailsData]! = []
    
    
    
    @IBOutlet weak var PrincipalView: UIView!
    
    
    var popupLoading : KLCPopup = KLCPopup()
    
    var NumberOfCollectionCell = [4,14,9,2]
    
    var SelectedLoginIndexInt = 0
    
    let utilClass = UtilClass()
    var arrMembersData = NSMutableArray()
    var staffRole : String!
    var SchoolIDString = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("1VC")
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        UtilObj.printLogKey(printKey: "ArrayChildData", printingValue: ArrayChildData)
        ParentTableView.reloadData()
        helpText()
        addShadow(MenuView)
        
        
        let userDefaults = UserDefaults.standard
        
        staffRole = userDefaults.string(forKey: DefaultsKeys.StaffRole)!
        
        
        
        
        UserMobileNo = UserDefaults.standard.object(forKey: USERNAME) as! String
        
        UserPassword =  UserDefaults.standard.object(forKey:USERPASSWORD) as? String ?? ""
        appDelegate.strMobileNumber = UserMobileNo
        
    }
    override func viewWillAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(ParentTableVC.UpdateFAQSelection), name: NSNotification.Name(rawValue: "FAQNotification"), object:nil)
        nc.addObserver(self,selector: #selector(ParentTableVC.UpdateLogoutSelection), name: NSNotification.Name(rawValue: "SettingNotification"), object:nil)
        
        nc.addObserver(self,selector: #selector(ParentTableVC.LoadSelectedLanguageData), name: NSNotification.Name(rawValue: LANGUAGE_NOTIFICATION), object:nil)
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        strCountryID = UserDefaults.standard.object(forKey: COUNTRY_ID) as! String
        self.callSelectedLanguage()
        
        //      
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.barTintColor =  UIColor (red:0.0/255.0, green:96.0/255.0, blue: 100.0/255.0, alpha: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK:- TextField Delegates
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if(helpTextView.text == "Enter message here..")
        {
            helpTextView.text = ""
            helpTextView.textColor = UIColor.black
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setupTextViewAccessoryView()
        if(helpTextView.text == "Enter message here..")
        {
            helpTextView.text = ""
            helpTextView.textColor = UIColor.black
        }
        return true
    }
    
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentCharacterCount = helpTextView.text?.count ?? 0
        
        if (range.length + range.location > currentCharacterCount){
            
            return false
        }
        
        let newLength = currentCharacterCount + text.count - range.length
        
        let length : integer_t
        
        length = integer_t(460 - newLength)
        
        
        remainingCharactersLabel.text = String (length)
        
        if(length <= 0){
            
            return false
        }
        else {
            return true
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
        helpTextView.inputAccessoryView = toolBar
    }
    
    @objc func didPressDoneButton(button: UIButton) {
        if( helpTextView.text == "" ||  helpTextView.text!.count == 0 || ( helpTextView.text!.trimmingCharacters(in: .whitespaces).count) == 0){
            helpTextView.text = "Enter message here.."
            helpTextView.textColor = UIColor.lightGray
        }
        
        helpTextView.resignFirstResponder()
    }
    
    //MARK: TEXTFIELD DELEGATE
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.MenuPopupView.isHidden = true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if(textField == self.VerifyNewPasswordLabel)
        {
            self.PopupChangePasswordView.frame.origin.y -= 100
            
        }
        else
        {
            self.PopupChangePasswordView.frame.origin.y = 0
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool
    {
        self.PopupChangePasswordView.frame.origin.y = 0
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        
        
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        
        if(newLength == 21)
        {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(ArrayChildData.count > 0)
        {
            MenuPopupView.isHidden = true
            ParentTableView.isHidden = false
        }
        return ArrayChildData.count
        
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let childDict = ArrayChildData.object(at: indexPath.row) as! NSDictionary
        let isNotv = childDict["IsNotAllow"] as? String ?? "0"
        if(isNotv == "0"){
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return 270
            }else{
                return 190
            }
            
        }else{
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return 320
            }else{
                return 230
            }
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomParentTableViewCell", for: indexPath) as! CustomParentTableViewCell
        cell.backgroundColor = UIColor.clear
        
        dicChilddetail = ArrayChildData.object(at: indexPath.row) as! NSDictionary
        
        cell.StudentNameLabel.text =  String(describing: dicChilddetail["ChildName"]!)
        
        cell.StudentRollNoLabel.text = String(describing: dicChilddetail["RollNumber"]!)
        
        let strStandard:String  = String(describing: dicChilddetail["StandardName"]!)
        let strSection:String = String(describing: dicChilddetail["SectionName"]!)
        cell.StudentClassLabel.text = strStandard + " - " + strSection
        cell.SchoolLocationLabel.text = String(describing: dicChilddetail["SchoolCity"]!)
        cell.SchoolNameLabel.text = String(describing: dicChilddetail["SchoolName"]!)


        var schoolNameReg  = String(describing: dicChilddetail["SchoolNameRegional"]!)

        if schoolNameReg != "" && schoolNameReg != nil {

            cell.SchoolNameRegional.text = schoolNameReg
            cell.SchoolNameRegional.isHidden = false

            cell.locationTop.constant = 4
        }else{
            cell.SchoolNameRegional.isHidden = true
//            cell.SchoolNameRegional.backgroundColor = .red
            cell.locationTop.constant = -34

        }

        cell.SchoolLogoImage.sd_setImage(with: URL(string: String(describing: (dicChilddetail["SchoolLogoUrl"]!))), placeholderImage: UIImage(named: "placeHolder.png"))
        
        cell.FloatRollNoLabel.text = languageDictionary["child_roll_no"] as? String
        cell.FlaotClassLabel.text = languageDictionary["child_class"] as? String
        cell.FloatLabel.text = languageDictionary["childname"] as? String
        cell.noteLabel.text = languageDictionary["note"] as? String
        let isNotv = dicChilddetail["IsNotAllow"] as? String ?? "0"
        
        
        
        if(isNotv == "0"){
            cell.noteView.isHidden = true
            cell.noteViewHeight.constant = 0
            cell.noteInfoLabel.text = ""
            if(UIDevice.current.userInterfaceIdiom == .pad){
                cell.cellViewHeight.constant = 250
            }else{
                cell.cellViewHeight.constant = 180
            }
            
        }else{
            if(UIDevice.current.userInterfaceIdiom == .pad){
                cell.cellViewHeight.constant = 320
            }else{
                cell.cellViewHeight.constant = 220
            }
            cell.noteView.isHidden = false
            if(UIDevice.current.userInterfaceIdiom == .pad){
                cell.noteViewHeight.constant = 70
            }else{
                cell.noteViewHeight.constant = 40
            }
            
            cell.noteInfoLabel.text = String(describing: dicChilddetail["DisplayMessage"]!)
        }
        
        if(strLanguage  == "ar"){
            cell.cellView1.semanticContentAttribute = .forceRightToLeft
            cell.cellView2.semanticContentAttribute = .forceRightToLeft
            cell.FloatRollNoLabel.textAlignment = .right
            cell.StudentNameLabel.textAlignment = .right
            cell.StudentClassLabel.textAlignment = .right
            cell.StudentRollNoLabel.textAlignment = .right
            cell.SchoolNameLabel.textAlignment = .right
            cell.SchoolNameRegional.textAlignment = .right
            cell.SchoolLocationLabel.textAlignment = .right
            cell.FloatLabel.textAlignment = .right
            
        }else{
            cell.cellView1.semanticContentAttribute = .forceLeftToRight
            cell.cellView2.semanticContentAttribute = .forceLeftToRight
            cell.FloatRollNoLabel.textAlignment = .left
            cell.StudentNameLabel.textAlignment = .left
            cell.StudentClassLabel.textAlignment = .left
            cell.StudentRollNoLabel.textAlignment = .left
            cell.SchoolNameLabel.textAlignment = .left
            cell.SchoolLocationLabel.textAlignment = .left
            cell.SchoolNameRegional.textAlignment = .left
            cell.FloatLabel.textAlignment = .left
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedDictionary = ArrayChildData.object(at: indexPath.row) as! NSDictionary
        let isNotv = selectedDictionary["IsNotAllow"] as? String ?? "0"
        print("SELECT CHILD : \(selectedDictionary)")
        if(isNotv == "0"){
            appDelegate.SchoolDetailDictionary = selectedDictionary
            SelSchool = selectedDictionary["SchoolID"] as! String
            var selectSchoolName = selectedDictionary["SchoolNameRegional"] as! String
           
            let defaults = UserDefaults.standard
            defaults.set(SelSchool, forKey: DefaultsKeys.SchoolD)
            defaults.set(selectSchoolName, forKey: DefaultsKeys.SchoolNameRegional)
           

            print("UserDefaultsSchoolID2345",SelSchool)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "ShowStudentViewSegue", sender: self)
            }
        }
    }
    // MARK: - Button Action
    
    @IBAction func actionUpdateChangePassword(_ sender: Any) {
        
        DismissKEY()
        if(ExistingPassword.text?.count == 0){
            Util.showAlert("",msg: ENTER_VALID_PASSWORD)
        }
        else if(NewPasswordLabel.text?.count == 0){
            Util.showAlert("",msg: ENTER_VALID_PASSWORD)
        }else if(VerifyNewPasswordLabel.text?.count == 0){
            Util.showAlert("",msg: ENTER_VALID_PASSWORD)
        }
        else if(ExistingPassword.text?.isEqual(UserPassword))!
        {
            if(NewPasswordLabel.text?.isEqual(VerifyNewPasswordLabel.text))!
            {
                
                if(Util .isNetworkConnected())
                {
                    self.CallChangePasswordApi()
                }
                else
                {
                    Util .showAlert("", msg: NETWORK_ERROR)
                }
            }
            else
            {
                Util.showAlert("", msg: "Password Mismatch Please Enter Correctly")
            }
        }
        else
        {
            Util.showAlert("", msg: "Please Enter Your Existing Password Correctly")
        }
    }
    func TappedOnImage(_ sender: UITapGestureRecognizer){
        
        let buttonTag = sender.view?.tag
        
        selectedDictionary = ArrayChildData.object(at: buttonTag!) as! NSDictionary
        selectedUnRead = unReadCountArray.object(at: buttonTag!) as! NSString
        
        performSegue(withIdentifier: "ShowStudentViewSegue", sender: self)
    }
    @IBAction func PopupMenuItems(_ sender: Any)
    {
        MenuPopupView.isHidden = false
    }
    
    
    @IBAction func actionPopupHelpBtn(_ sender: Any) {
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PopupHelpView.frame.size.height = 390
            PopupHelpView.frame.size.width = 400
            
        }
        MenuPopupView.isHidden = true
        helpTextView.text = "Enter message here.."
        helpTextView.textColor = UIColor.lightGray
        //
        //        
        //        G3
        
        PopupHelpView.center = view.center
        PopupHelpView.alpha = 1
        PopupHelpView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(PopupHelpView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            
            self.PopupHelpView.transform = .identity
        })
        print("ParentTablePopup")
        
        
    }
    
    @IBAction func actionSendHelpMsgButton(_ sender: Any) {
        helpTextView.resignFirstResponder()
        if(helpTextView.text.count > 0 && helpTextView.text != "Enter message here..")
        {
            
            if(Util .isNetworkConnected())
            {
                self.CallHelpSendApi()
            }
            else
            {
                Util .showAlert("", msg: NETWORK_ERROR)
            }
            popupHelpBtn.dismiss(true)
            
        }else{
            
            Util.showAlert("", msg: "Enter message")
        }
        
    }
    
    
    @IBAction func actionPopupChangePasswordBtn(_ sender: Any) {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PopupChangePasswordView.frame.size.height = 520
            PopupChangePasswordView.frame.size.width = 500
        }
        MenuPopupView.isHidden = true
        popupChangePasswordBtn = KLCPopup(contentView: PopupChangePasswordView, showType: KLCPopupShowType.none , dismissType:KLCPopupDismissType.none,maskType: KLCPopupMaskType.dimmed , dismissOnBackgroundTouch:  false , dismissOnContentTouch: false )
        
        popupChangePasswordBtn.show()
        
    }
    
    
    @IBAction func actionPopupLogoutBtn(_ sender: Any) {
        Childrens.deleteTables()
        UserDefaults.standard.set("Yes" as NSString, forKey: LOGOUT)
        UserDefaults.standard.removeObject(forKey: DefaultsKeys.getgroupHeadRole)
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "BackToLoginParent", sender: self)
        }
    }
    
    @IBAction func actionPopupCloseHelpBtn(_ sender: Any) {
        PopupHelpView.alpha = 0
        popupHelpBtn.dismiss(true)
        
    }
    
    
    @IBAction func closePopupChangePasswordBtn(_ sender: Any) {
        DismissKEY()
        popupChangePasswordBtn.dismiss(true)
    }
    
    @IBAction func actionCancelChangePassword(_ sender: Any) {
        DismissKEY()
        popupChangePasswordBtn.dismiss(true)
    }
    
    func DismissKEY()
    {
        NewPasswordLabel.resignFirstResponder()
        ExistingPassword.resignFirstResponder()
        VerifyNewPasswordLabel.resignFirstResponder()
    }
    
    @IBAction func actionExistingPassword(_ sender: Any) {
        if(ExistingPassword.isSecureTextEntry == false)
        {
            ExistingPassword.isSecureTextEntry = true
            ShowExistingPswdButton.isSelected = false
        }
        else
        {
            ExistingPassword.isSecureTextEntry = false
            ShowExistingPswdButton.isSelected = true
        }
        
    }
    
    
    @IBAction func actionShowNewPassword(_ sender: Any) {
        
        if(NewPasswordLabel.isSecureTextEntry == false)
        {
            NewPasswordLabel.isSecureTextEntry = true
            ShowNewPswdButton.isSelected = false
        }
        else
        {
            NewPasswordLabel.isSecureTextEntry = false
            ShowNewPswdButton.isSelected = true
        }
    }
    
    @IBAction func actionShowVerifyPassword(_ sender: Any) {
        if(VerifyNewPasswordLabel.isSecureTextEntry == false)
        {
            VerifyNewPasswordLabel.isSecureTextEntry = true
            ShowVerifyPswdButton.isSelected = false
        }
        else
        {
            VerifyNewPasswordLabel.isSecureTextEntry = false
            ShowVerifyPswdButton.isSelected = true
        }
    }
    
    // MARK: - TAB BUTTON ACTION
    
    
    
    @IBAction func actionTabLanguage(_ sender: Any) {
        let languageVC  = self.storyboard?.instantiateViewController(withIdentifier: "ChooseLanguageVC") as! ChooseLanguageVC
        languageVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(languageVC, animated: true, completion: nil)
    }
    
    @IBAction func actionTabChangePassword(_ sender: Any) {
        let changePasswordVC  = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordVC") as! ParentChangePasswordVC
        changePasswordVC.strFrom = "ChangePassword"
        changePasswordVC.strFromStaff = "Child"
        changePasswordVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(changePasswordVC, animated: true, completion: nil)
    }
    
    @IBAction func actionFAQ(_ sender: UIButton) {
        if(strcombination == "Yes"){
            self.strPopOverFrom = "FAQ"
            self.showPopover(sender, Titletext: "")
        }else{
            let faqVC  = self.storyboard?.instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
            faqVC.Dict = ArrayChildData[0] as! NSDictionary
            faqVC.fromVC = "Parent"
            self.navigationController?.pushViewController(faqVC, animated: true)
        }
    }
    
    @IBAction func actionTabLogout(_ sender: UIButton) {
        self.strPopOverFrom = "setting"
        self.showPopover(sender, Titletext: "")
    }
    
    func callLogoutAction(){
        let changePasswordVC  = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordVC") as! ParentChangePasswordVC
        changePasswordVC.strFrom = "Logout"
        changePasswordVC.strFromStaff = "Child"
        
        self.navigationController?.pushViewController(changePasswordVC, animated: true)
    }
    
    
    // MARK: - Popover delegate  & Functions
    func showPopover(_ base: UIView, Titletext: String)
    {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DropDownVC") as? DropDownVC {
            
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .popover
            viewController.fromVC = self.strPopOverFrom
            
            if let pctrl = navController.popoverPresentationController {
                pctrl.delegate = self
                pctrl.sourceView = base
                pctrl.permittedArrowDirections = .down
                pctrl.sourceRect = base.bounds
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func movetoFAQScreen(){
        let faqVC  = self.storyboard?.instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
        faqVC.Dict = ArrayChildData[0] as! NSDictionary
        faqVC.fromVC = fromVC
        self.navigationController?.pushViewController(faqVC, animated: true)
    }
    
    @objc func UpdateLogoutSelection(notification:Notification) -> Void
    {
        print("PTable")
        
        var selectString = notification.object as? String ?? ""
        selectString = selectString.lowercased()
        let log = languageDictionary["txt_menu_logout"] as? String ?? ""
        if(selectString == log.lowercased()){
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() )
            {
                self.showLogoutAlert()
            }
        }else if(selectString.contains("Edit")){
            callEditProfile()
        }else if(selectString.contains("help")){
            callhelp()
        }
        
        
    }
    
    func callEditProfile(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        newViewController.strPageFrom = "edit"
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    func callhelp(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        newViewController.strPageFrom = "help"
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    func callUploadDocumentView(){
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "UploadDocPhotosVC") as! UploadDocPhotosVC
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    
    func showLogoutAlert(){
        let alertController = UIAlertController(title: languageDictionary["txt_menu_logout"] as? String, message: languageDictionary["want_to_logut"] as? String, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.moveToLogInScreen(strFromStaff: "Child")
        }
        let cancelAction = UIAlertAction(title: languageDictionary["teacher_cancel"] as? String, style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func UpdateFAQSelection(notification:Notification) -> Void
    {
        Constants.printLogKey("Notificaqtion", printValue: notification.object)
        let selectedString  : String = notification.object as! String
        if(selectedString == "FAQ - Parents"){
            self.fromVC = "Parent"
        }else{
            self.fromVC = "Staff"
        }
        movetoFAQScreen()
        
    }
    
    @objc func LoadSelectedLanguageData(notification:Notification) -> Void{
        self.callSelectedLanguage()
    }
    
    // MARK: - Api Calling
    func CallVersionCheckApi()
    {
        // showLoading()
        strApiFrom = "default"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + CHECK_UPDATE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["VersionCode": VERSION_VALUE, "AppID" : "3","DeviceType" : DEVICE_TYPE, COUNTRY_CODE: strCountryCode,COUNTRY_ID : strCountryID]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "version")
    }
    
    func CallLanguageChangeApi(){
        //showLoading()
        memberArray()
        strApiFrom = "changeLang"
        let apiCall = API_call.init()
        apiCall.delegate = self
        let baseUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_LANGUAGE_CHANGE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        
        let myDict:NSMutableDictionary = ["MemberData" : arrMembersData,"LanguageId": "1",COUNTRY_ID : strCountryCode]
        print(myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        
        Constants.printLogKey("myDict", printValue: myDict)
        Constants.printLogKey("requestStringer", printValue: requestStringer)
        apiCall.nsurlConnectionFunction(requestString, myString, "deviceToken")
    }
    
    func CallHelpSendApi() {
        //showLoading()
        strApiFrom = "help"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + GET_HELP
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber": UserMobileNo,"HelpText" : helpTextView.text, COUNTRY_CODE: strCountryCode]
        
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        UtilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "help")
    }
    
    func CallChangePasswordApi()
    {
        //showLoading()
        strApiFrom = "ChangePassword"
        
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + CHANGEPASSWROD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //{"MobileNumber":"9840547017","OldPassword":"1234","NewPassword":"1234"}
        let myDict:NSMutableDictionary = ["NewPassword": NewPasswordLabel.text! ,"OldPassword" : ExistingPassword.text!,"MobileNumber" : UserMobileNo, COUNTRY_CODE: strCountryCode]
        UtilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        UtilObj.printLogKey(printKey: "myString", printingValue: myString!)
        apiCall.nsurlConnectionFunction(requestString, myString, "ChangePassword")
    }
    
    //MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        if(csData != nil || csData?.count == 0)
        {
            if(strApiFrom.isEqual(to: "unread"))
            {
                unReadCountArray = NSMutableArray.init()
                if((csData?.count)! > 0){
                    for var i in 0..<(csData?.count)!
                    {
                        let dicUser : NSDictionary = csData!.object(at: i) as! NSDictionary
                        print(dicUser)
                        let Mystring = dicUser["TotalUnreadCount"] as! NSString
                        unReadCountArray.add(Mystring)
                    }
                }
                ParentTableView.reloadData()
            }else if(strApiFrom.isEqual(to: "default")){
                if((csData?.count)! > 0)
                {
                    let dict : NSDictionary = csData?.object(at: 0) as! NSDictionary
                    if(dict["UpdateAvailable"] != nil){
                        if let arrayLan = dict[LANGUAGES] as? NSArray{
                            let arraylanguage : NSArray = dict[LANGUAGES] as! NSArray
                            appDelegate.LanguageArray = arraylanguage
                            appDelegate.strOfferLink = dict["Offerslink"] as? String ?? ""
                            appDelegate.strProductLink = dict["NewProductLink"] as? String ?? ""
                            appDelegate.strProfileLink = dict["ProfileLink"] as? String ?? ""
                            appDelegate.strProfileTitle = dict["ProfileTitle"] as? String ?? ""
                            appDelegate.strUploadPhotoTitle = dict["UploadProfileTitle"] as? String ?? ""
                            appDelegate.otpMobileNumber = dict["OtpDialInbound"] as? String ?? ""
                            appDelegate.Helplineurl = dict["helplineURL"] as? String ?? ""
                            appDelegate.FeePaymentGateway = dict["FeePaymentGateway"] as? String ?? ""
                            
                            print(appDelegate.otpMobileNumber)
                            
                            Constants.printLogKey("arraylanguage", printValue: arraylanguage)
                            UserDefaults.standard.set(arraylanguage, forKey: LANGUAGE_ARRAY)
                        }
                        let VideoJson = String(describing: dict.object(forKey: VIDEOJSON)!)
                        let VideoSizeLimit = String(describing: dict.object(forKey: VIDEOSIZELIMIT)!)
                        let VideoSizeLimitAlert = String(describing: dict.object(forKey: VIDEOSIZELIMITALERT)!)
                        let AdTimerInterval = String(describing: dict.object(forKey: ADTIMERINTERVAL)!)
                        
                        appDelegate.VimeoToken = VideoJson
                        appDelegate.videoSize = VideoSizeLimit
                        appDelegate.videoSizeAlert = VideoSizeLimitAlert
                        appDelegate.AdTimerInterval = AdTimerInterval
                        
                        UserDefaults.standard.set(VideoJson, forKey: VIDEOJSON)
                        UserDefaults.standard.set(VideoSizeLimit, forKey: VIDEOSIZELIMIT)
                        UserDefaults.standard.set(AdTimerInterval, forKey: ADTIMERINTERVAL)
                        UserDefaults.standard.set(VideoSizeLimitAlert, forKey: VIDEOSIZELIMITALERT)
                        
                    }
                }
                CallLanguageChangeApi()
                
            }
            else if(strApiFrom.isEqual(to: "help")){
                PopupMenuItems(self)
                if((csData?.count)! > 0){
                    for var i in 0..<(csData?.count)!
                    {
                        let dicUser : NSDictionary = csData!.object(at: i) as! NSDictionary
                        
                        let Mystring = String(describing: dicUser["Message"]!)
                        Util.showAlert("", msg: Mystring)
                        popupHelpBtn.dismiss(true)
                        MenuPopupView.isHidden = true
                    }
                }
            }
            else if(strApiFrom.isEqual(to: "changeLang")){
                guard let responseArray = csData else {
                    return
                }
                arrayForgetChangeDatas = responseArray
                for var i in 0..<arrayForgetChangeDatas.count
                {
                    dicResponse = arrayForgetChangeDatas[i] as! NSDictionary
                    if(dicResponse["Status"] != nil){
                        let myalertstatus = String(describing: dicResponse["Status"]!)
                        if(myalertstatus == "1"){
                            assignParentStaffIDS(selectedDict: dicResponse)
                        }
                    }
                    
                }
                
                
            }
            else
            {
                popupChangePasswordBtn.dismiss(true)
                
                guard let responseArray = csData else {
                    return
                }
                arrayForgetChangeDatas = responseArray
                for var i in 0..<arrayForgetChangeDatas.count
                {
                    dicResponse = arrayForgetChangeDatas[i] as! NSDictionary
                    
                    
                    let myalertstatus = String(describing: dicResponse["Status"]!)
                    if(myalertstatus == "1"){
                        let myalertstring = String(describing: dicResponse["Message"]!)
                        Util.showAlert("", msg: myalertstring)
                        UserDefaults.standard.set("Yes" as NSString, forKey: LOGOUT)
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "BackToLoginSegue", sender: self)
                        }
                    }else{
                        let myalertstring = String(describing: dicResponse["Message"]!)
                        Util.showAlert("", msg: myalertstring)
                    }
                }
            }
            
        }
        else
        {
            Util.showAlert("", msg: SERVER_ERROR)
        }
    }
    //
    @objc func failedresponse(_ pagename: Error!) {
        //hideLoading()
        //print("Error")
        Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
        
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
    
    func addShadow(_ myView : UIView) {
        myView.layer.masksToBounds = false
        myView.layer.shadowOpacity = 0.7
        myView.layer.shadowOffset = CGSize.zero
        myView.layer.shadowRadius = 4
        myView.layer.shadowColor = UIColor.black.cgColor
    }
    
    func navTitle()
    {
        
        let titleLabel = UILabel()
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        // titleLabel.textColor = UIColor (red:128.0/255.0, green:205.0/255.0, blue: 244.0/255.0, alpha: 1)
        titleLabel.textColor = UIColor (red:0.0/255.0, green:183.0/255.0, blue: 190.0/255.0, alpha: 1)
        titleLabel.textColor = .white
        let secondWord : String =   languageDictionary["choose"] as? String ?? "Choose"
        let thirdWord : String  = strTitleName
        let comboWord = secondWord + " " + thirdWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.white]
        let range = NSString(string: comboWord).range(of: secondWord)
        attributedText.addAttributes(attrs, range: range)
        
        titleLabel.attributedText = attributedText
        if(strLanguage == "ar"){
            titleLabel.textAlignment = .right
        }else{
            titleLabel.textAlignment = .left
        }
        self.navigationItem.titleView = titleLabel
        setNavColor()
    }
    func setNavColor(){
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = utilClass.PARENT_NAV_BAR_COLOR
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func helpText(){
        helpTextView.text = "Enter message here.."
        helpTextView.textColor = UIColor.lightGray
        helpTextView.layer.borderWidth = 1
        helpTextView.layer.cornerRadius = 5
        helpTextView.layer.masksToBounds = true
        helpTextView.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    //Principal button action
    
    @IBAction func actionPrincipalButton(_ sender: Any) {
        
        if(Util .isNetworkConnected())
        {
            self.performSegue(withIdentifier: "ParentToPrincipalSegue", sender: self)
        }
        else
        {
            Util .showAlert("", msg: NETWORK_ERROR)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ShowStudentViewSegue")
        {
            let segueid = segue.destination as! StudentDetailViewController
            segueid.selectedDictionary = selectedDictionary
            print("segueid.selectedDictionary",selectedDictionary)
            segueid.stralerMsg = stralerMsg
            segueid.QuestionData = QuestionData
            //            segueid.SchoolIDString = SelSchool
            
        }
        else if (segue.identifier == "ParentToPrincipalSegue")
        {
            let segueid = segue.destination as! MainVC
            segueid.LoginAsIndexInt = SelectedLoginIndexInt
            print("QuestionData123456",QuestionData.count)
            segueid.QuestionData = QuestionData
            
        }
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
            self.PrincipalView.semanticContentAttribute = .forceRightToLeft
            self.ParentTableView.semanticContentAttribute = .forceRightToLeft
            self.BottomView.semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.ParentTableView.semanticContentAttribute = .forceLeftToRight
            self.PrincipalView.semanticContentAttribute = .forceLeftToRight
            self.BottomView.semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            
        }
        FAQLabel.text = LangDict["faq"] as? String
        PasswordLabel.text = LangDict["txt_password"] as? String
        LogoutLabel.text = LangDict["txt_menu_setting"] as? String
        
        self.loadViewData()
        
    }
    
    func loadViewData(){
        self.navigationItem.setHidesBackButton(true, animated:true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.navigationController?.navigationBar.barTintColor =  UIColor (red:0.0/255.0, green:96.0/255.0, blue: 100.0/255.0, alpha: 1)
        
        strLoginAs =  UserDefaults.standard.object(forKey: LOGINASNAME) as! String
        UserDefaults.standard.set("Yes", forKey: AT_VERY_FIRST_TIME)
        
        strcombination  = UserDefaults.standard.object(forKey: COMBINATION) as! String
        if(strLoginAs == "Parent"){
            PrincipalView.isHidden = true
            PrincipalHeightConst.constant = 0
            strTitleName = languageDictionary["your_child"] as? String ??  "Your Child"
            
        }
        else if(strcombination == "Yes")
        {
            PrincipalView.isHidden = false
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                PrincipalHeightConst.constant = 150
            }else{
                
                PrincipalHeightConst.constant = 110
            }
            
            let loginAs : String = languageDictionary[strLoginAs] as? String ??  strLoginAs
            let floatValue : String = languageDictionary["login_as"] as? String ??  "Login As "
            
            LoginAsLabel.text = loginAs
            
            strTitleName = languageDictionary["role"] as? String ?? "Your Roll"
        }
        
        else
        {
            PrincipalView.isHidden = false
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                PrincipalHeightConst.constant = 150
            }else{
                
                PrincipalHeightConst.constant = 110
            }
            let loginAs : String = languageDictionary[strLoginAs] as? String ??  strLoginAs
            let floatValue : String = languageDictionary["login_as"] as? String ??  "Login As "
            
            LoginAsLabel.text = loginAs
            strTitleName = languageDictionary["role"] as? String ??  "Your Roll"
            
        }
        
        navTitle()
        PopupHelpView.layer.cornerRadius = 8
        PopupHelpView.clipsToBounds = true
        PopupChangePasswordView.layer.cornerRadius = 8
        PopupChangePasswordView.clipsToBounds = true
        MenuPopupView.isHidden = true
        UserDefaults.standard.set("No" as NSString, forKey: LOGOUT)
        ParentTableView.reloadData()
        if(Util .isNetworkConnected())
        {
            self.CallVersionCheckApi()
        }
    }
    
    func memberArray(){
        var idArray : NSMutableArray = NSMutableArray()
        
        for i in 0..<appDelegate.LoginParentDetailArray.count{
            let Dict : NSDictionary =  appDelegate.LoginParentDetailArray[i] as! NSDictionary
            idArray.add(String(describing: Dict["ChildID"]!))
            
            //   {"MemberData":[{"type":"parent","id":"5191710","schoolid":"5512"}],"LanguageId":"1","CountryID":"1"}
            let dicMembers = ["type" : "parent",
                              "id" : String(describing: Dict["ChildID"]!),
                              "schoolid" : String(describing: Dict["SchoolID"]!)
            ]
            
            let defaults = UserDefaults.standard
            var getschollId : String!
            defaults.set(Dict["SchoolID"], forKey: DefaultsKeys.SchoolD)
            defaults.set(Dict["classId"], forKey: DefaultsKeys.ClassID)
            defaults.set(Dict["SchoolNameRegional"], forKey: DefaultsKeys.SchoolNameRegional)
            defaults.set(Dict["sectionId"], forKey: DefaultsKeys.SectionId)
            getschollId  = defaults.string(forKey:DefaultsKeys.SchoolD)
            print("UserDefaultsSchoolID11",Dict["classId"])

            SchoolIDString = Dict["SchoolID"] as! String
            arrMembersData.add(dicMembers)
            
            
        }
        //
        
        memeberArrayString = idArray.componentsJoined(by: "~")
        print("childArr",memeberArrayString)
        
        
        let defaults = UserDefaults.standard
        defaults.set(memeberArrayString, forKey: DefaultsKeys.chilId)
        
        updateDetailsApi()
        //        ChildIDS = memeberArrayString
        
    }
    
    func assignParentStaffIDS(selectedDict : NSDictionary){
        
        
        print("RES12 \(selectedDict)")
        
        let strMenuID  : String = String(describing: selectedDict[IS_MENU_ID]!)
        let MenuIDArray = strMenuID.components(separatedBy: ",") as NSArray
        Constants.printLogKey("menuIDArray", printValue: MenuIDArray)
        print("appDelegate.isParent \(appDelegate.isParent)")
        
        UserDefaults.standard.set(MenuIDArray, forKey: PARENT_ARRAY_INDEX)
        let strMenuName  : String = String(describing: selectedDict["menu_name"]!)
        let menu_namearr = strMenuName.components(separatedBy: ",") as NSArray
        // UserDefaults.standard.set(menu_namearr, forKey: "PRINCIPLE_ARRAY_MENUNAMES")
        UserDefaults.standard.set(menu_namearr, forKey: "PARENT_ARRAY_MENUNAMES")
        
        var childIndexArray : NSArray = UserDefaults.standard.object(forKey: PARENT_ARRAY_INDEX) as? NSArray ?? []
        print("childIndexArray \(childIndexArray)")
        
        stralerMsg = selectedDict["alert_message"] as? String ?? ""
        
    }
    
    
    func updateDetailsApi(){
        
        //
        
        let modal = UpdateDetailsModal()
        
        
        modal.instituteid = SchoolIDString
        modal.staff_role = staffRole
        modal.member_id = memeberArrayString
        
        let modal_str = modal.toJSONString()
        print("modal_str",modal_str)
        
        UpdateDetailRequest.call_request(param: modal_str!) {
            [self]
            (res) in
            
            print("resresres",res)
            
            let modal_response : [UpdateDetailsResponse] = Mapper<UpdateDetailsResponse>().mapArray(JSONString: res)!
            
            if modal_response[0].status == 1 {
                
                self.QuestionData = modal_response[0].dataList
                print("QuestionDatas",QuestionData.count)
                //
            }else{
                //                   
            }
        }
        
    }
    
    
    
    
    
    
}
