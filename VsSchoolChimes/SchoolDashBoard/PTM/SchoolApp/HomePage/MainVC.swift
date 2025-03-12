//
//  MainVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 03/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit
import AVFoundation
import MarqueeLabel
import ObjectMapper

class MainVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate,UITextViewDelegate,Apidelegate,UIPopoverPresentationControllerDelegate
{
    //    UpdateDetailCell
    
    @IBOutlet weak var cell2ImgView: UIImageView!
    
    
    @IBOutlet weak var locationTop: NSLayoutConstraint!
    @IBOutlet weak var SchoolNameRegionalLbl: UILabel!
    @IBOutlet weak var updateDetailView: UIView!
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var mainBoxView: UIImageView!
    @IBOutlet weak var cvTopHeight: NSLayoutConstraint!
    @IBOutlet weak var appTitleView: UIViewX!
    @IBOutlet weak var schoolHeight: NSLayoutConstraint!
    @IBOutlet weak var schoolImgHeight: NSLayoutConstraint!
    @IBOutlet weak var mainboxHeight: NSLayoutConstraint!
    @IBOutlet weak var appTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var schoolLocationLblheight: NSLayoutConstraint!
    @IBOutlet weak var schoolNameLblHeight: NSLayoutConstraint!
    @IBOutlet weak var SchoolViewHeight: NSLayoutConstraint!
    @IBOutlet weak var MenuView: UIView!
    @IBOutlet weak var MenuPopupView: UIView!
    @IBOutlet weak var CollectionViewGrid: UICollectionView!
    @IBOutlet weak var helpTextView: UITextView!
    @IBOutlet weak var PopupChangePasswordView: UIView!
    @IBOutlet weak var PopupHelpView: UIView!
    @IBOutlet weak var ExistingPasswordText: UITextField!
    @IBOutlet weak var NewPasswordText: UITextField!
    @IBOutlet weak var VerifyNewPasswordText: UITextField!
    @IBOutlet weak var remainingCharactersLabel: UILabel!
    @IBOutlet weak var ShowExistingPswdButton: UIButton!
    @IBOutlet weak var ShowNewPswdButton: UIButton!
    @IBOutlet weak var ShowVerifyPswdButton: UIButton!
    @IBOutlet weak var CollectionViewTopHeight: NSLayoutConstraint!
    @IBOutlet weak var CollectionViewBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var CLogoutLabel: UILabel!
    @IBOutlet weak var CPasswordLabel: UILabel!
    @IBOutlet weak var CFAQLabel: UILabel!
    @IBOutlet weak var CLanguageLabel: UILabel!
    @IBOutlet weak var CHomeLabel: UILabel!
    @IBOutlet weak var CombinationBottomView: UIView!
    @IBOutlet weak var FAQLabel: UILabel!
    @IBOutlet weak var Languagelabel: UILabel!
    @IBOutlet weak var LogoutLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var SingleBottomView: UIView!
    @IBOutlet weak var SchoolView: UIView!
    @IBOutlet weak var SchoolNameLbl: UILabel!
    @IBOutlet weak var SchoolLocationLbl: UILabel!
    @IBOutlet weak var SchoolImg: UIImageView!
    @IBOutlet weak var lblscrollView: UILabel!
    
    @IBOutlet weak var nextView: UIView!
    
    @IBOutlet weak var cv: UICollectionView!
    
    
    @IBOutlet weak var nextLbl: UILabel!
    
    @IBOutlet weak var preLbl: UILabel!
    
    @IBOutlet weak var previousView: UIView!
    
    var appdelegateSelect : String!
    var  QuestionData : [UpdateDetailsData]! = []
    
    var CellIndexIdsArray : NSMutableArray = []
    var ArraySchoolData: NSArray = []
    var dicSchooldetail : NSDictionary = [:]
    var selectedRow = 0;
    var loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as? String
    var SegueArrayData: NSArray = []
    var NumberofCell = Int()
    var MainCellCount = Int()
    var DivideValue :CGFloat = CGFloat()
    var DivideColumn :CGFloat = CGFloat()
    var LanguageDict = NSDictionary()
    var arrayMessageSendLogo: NSArray = []
    var arrayMessageSend: NSArray = []
    var pickerArray = [String]()
    var MyTableString = String()
    var mystring = NSString()
    var popupHelpBtn : KLCPopup  = KLCPopup()
    var popupLoginAsBtn : KLCPopup  = KLCPopup()
    var popupChangePasswordBtn: KLCPopup  = KLCPopup()
    var popupSelectSchool : KLCPopup  = KLCPopup()
    let intiallength : integer_t = 460
    var strApiFrom = NSString()
    var strLoggedAS = String()
    var UserMobileNo = String()
    var UserPassword = String()
    var strCountryID = String()
    var popupLoading : KLCPopup = KLCPopup()
    var arrayForgetChangeDatas: NSArray = []
    var dicResponse: NSDictionary = [:]
    var CellIconsArray = [String]()
    var CellLabelNameArray = [String]()
    var CellSegueArray = [String]()
    var indexNumber = Int()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var LoginAsIndexInt = Int()
    var strCountryCode = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var strBookURL = String()
    var strBookenabled = String()
    let utilClass = UtilClass()
    var strLanguage = String()
    var memeberArrayString = String()
    var bookIndex = -1
    var arrMembersData = NSMutableArray()
    var stralerMsg = String()
    var NumberofCellPrincipal = 0
    var cellSegueArrayType : String!
    var clickableType : String!
    var staffRole : String!
    var schoolArrayString = String()
    var rowSelected : Int?
    var coutData : [countResponce] = []
    var OverAllCountValue  = 0;
    
    let deviceName = UIDevice.current.model
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        print("MAINVC")
        let userDefaults = UserDefaults.standard
        
        staffRole = userDefaults.string(forKey: DefaultsKeys.StaffRole)!
        print("staffRole",staffRole)
        if staffRole == "p5" {
            SchoolView.alpha = 0
            mainBoxView.alpha = 0
            SchoolViewHeight.constant = 0
            schoolImgHeight.constant = 0
            appTitleView.alpha = 0
            appTitleHeight.constant = 0
            mainboxHeight.constant = 0
//            schoolLocationLblheight.constant = 0
//            schoolNameLblHeight.constant = 0
            
        }
        
        
        
        
        SchoolLocationLbl.isHidden = false
        
        clearHelpText()
        addShadow(myView: MenuView)
        UserDefaults.standard.set("No" as NSString, forKey: LOGOUT)
        
        UserMobileNo = UserDefaults.standard.object(forKey:USERNAME) as! String
        
        appDelegate.strMobileNumber = UserMobileNo
        
        UserPassword = UserDefaults.standard.object(forKey:USERPASSWORD) as? String ?? ""
        
        strLoggedAS = UserDefaults.standard.object(forKey: LOGINASNAME) as? String ?? ""
        
        self.ButtonCornerDesign()
        callSelectedLanguage()

        coutApi()
    }
    
    
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.title = ""
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = utilClass.PARENT_NAV_BAR_COLOR
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(MainVC.catchNotification), name: NSNotification.Name(rawValue: "comeBackMenu"), object:nil)
        nc.addObserver(self,selector: #selector(MainVC.catchNotification1), name: NSNotification.Name(rawValue: "AddcomeBackMenu"), object:nil)
        nc.addObserver(self,selector: #selector(MainVC.LoadSelectedLanguageData), name: NSNotification.Name(rawValue: LANGUAGE_NOTIFICATION), object:nil)
        
        nc.addObserver(self,selector: #selector(MainVC.UpdateLogoutSelection), name: NSNotification.Name(rawValue: "SettingNotification"), object:nil)
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        strCountryID = UserDefaults.standard.object(forKey: COUNTRY_ID) as! String
        self.callSelectedLanguage()
        
        //
        
        
        coutApi()
        let defaults = UserDefaults.standard
        var appLaunch = defaults.bool(forKey: "isAppAlreadyLaunchedOnce")
        print("appLaunchappLaunch",appLaunch)
        //        if appLaunch == true {
        let userDefaults = UserDefaults.standard
        var updateTime : Int!
        updateTime  =  userDefaults.integer(forKey: DefaultsKeys.updateTime)
        print("updateTime",updateTime)
        var randomAmountOfTime = Double(updateTime)
        DispatchQueue.main.asyncAfter(deadline: .now() + randomAmountOfTime) { [self] in
            let mainvc = UpdateDetailViewController(nibName: nil, bundle: nil)
            mainvc.memeberArrayString = memeberArrayString
            mainvc.schoolArrayString  = schoolArrayString
            mainvc.type = "School"
            mainvc.modalPresentationStyle = .formSheet
            present(mainvc, animated: true)
        }
        
        
    }
    
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        coutApi()
    }
    
    
    func ButtonCornerDesign(){
        PopupChangePasswordView.layer.cornerRadius = 8
        PopupChangePasswordView.layer.masksToBounds = true
        PopupHelpView.layer.cornerRadius = 8
        PopupHelpView.layer.masksToBounds = true
    }
    
    func LoadCollectionViewData(){
        if(NumberofCell > 10)
        {
            DivideColumn = 5
        }
        else if(NumberofCell > 6)
        {
            DivideColumn = 4
        }
        else
        {
            DivideColumn = 5
        }
        
        CollectionViewGrid.reloadData()
        
    }
    
    // MARK: TEXT VIEW EDITING STYLE FUNTIONS
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if(textField == self.VerifyNewPasswordText)
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.MenuPopupView.isHidden = true
    }
    
    
    // MARK: COLLECTION VIEW DELEGATE
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: (self.CollectionViewGrid.frame.size.width/3) - 10, height: 80)


    }
    
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        
        print("CellSegueArray.count",NumberofCell )
        
        print("QuestionData.count",QuestionData!.count )
        
        
        
        return CellSegueArray.count
        
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCVCell", for: indexPath) as! GridCVCell
        cell.backgroundColor = UIColor.clear
        cell.countView.isHidden = true
        
        print("CellIconsImgArray",CellIconsArray)
        if(CellIconsArray.count > indexPath.row) {
            if((UIImage(named: CellIconsArray[indexPath.row] as? String ?? "")) != nil) {
                print("Image existing")
                
                
                cell.iconWidth.constant = 40
                cell.iconHeight.constant = 40
                cell.cellIconTopCnstraints.constant = 15
                
                cell.CellIcon.image = UIImage(named: CellIconsArray[indexPath.row])
                
                
            }
            else {
//               
                print("Image is not existing")
            }
        }else{
            
        }
        
        
        
        
        if(CellLabelNameArray.count > indexPath.row) {
            cell.CellLabel.text = CellLabelNameArray[indexPath.row]
            
        }
        
        
        print("CellIndexIdsArrayrow",CellIndexIdsArray)
        
        
        if(self.CellIndexIdsArray[indexPath.row] as! String == "100"){
            print("RippleInside")
            if indexPath.row == 0 {
                cell.cellIconTopCnstraints.constant = -5
                cell.iconWidth.constant = 100
                cell.iconHeight.constant = 100
//                cell.CellIcon.contentMode = .scaleAspectFill
                cell.CellLabel.text = ""
                
                cell.CellIcon.image = UIImage.gifImageWithName("Ripple1")
            }
        }else{
//
            
            cell.iconHeight.constant = 35
            cell.iconWidth.constant = 35
            cell.cellIconTopCnstraints.constant = 13
            
        }
        
        if(self.CellIndexIdsArray[indexPath.row] as! String == "13"){
            
            
            if(OverAllCountValue > 0){
                            cell.countView.isHidden = false
                            cell.countLbl.isHidden = false

                           cell.countLbl.text = String(OverAllCountValue)
                        }
                        else{
                            cell.countView.isHidden = true
                            cell.countLbl.isHidden = true

                        }
                        
                    }else{
                        
                        cell.countView.isHidden = true
                        cell.countLbl.isHidden = true


                    }
        
        
        cell.CellView.layer.borderWidth = 0.3
        cell.CellView.layer.cornerRadius = 3
        cell.CellView.clipsToBounds = true
        cell.CellView.layer.borderColor = UIColor.lightGray.cgColor
        cell.CellView.layer.shadowColor = UIColor.black.cgColor
        cell.CellView.layer.shadowOpacity = 1
        cell.CellView.layer.shadowOffset = CGSize.zero
        
        return cell
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        indexNumber = indexPath.row
        
        
        
        
        
        print("indexPath\(indexPath.row)")
        print("12",CellSegueArray)
        if(indexPath.row == bookIndex){
            if(strBookenabled == "1")
            {
                UIApplication.shared.openURL(URL(string: strBookURL)!)
            }else{
                DispatchQueue.main.async {
                    print(self.CellSegueArray[indexPath.row])
                    if(self.CellSegueArray[indexPath.row] != ""){
                        self.performSegue(withIdentifier: self.CellSegueArray[indexPath.row], sender: nil)
                    }
                }
                
                
            }
        }else{
            
            print("menu_id",self.CellIndexIdsArray[indexPath.row])
            
            
            
            print("self.CellIndexIdsArray[indexPath.row111]",self.CellIndexIdsArray[indexPath.row])
            if(self.CellIndexIdsArray[indexPath.row] as! String == "21"){
                
                if appDelegate.LoginSchoolDetailArray.count > 1 {
                    appDelegate.mainSchoolPrincipalSegueArray.append("OfferMessageSegue")
                }else {
                    if staffRole == "p2" {
                        appDelegate.mainSchoolPrincipalSegueArray.append("OfferMessageSegue")
                    }
                }
                
            }
            
            if(self.CellIndexIdsArray[indexPath.row] as! String == "25"){
                
                
                appDelegate.mainSchoolPrincipalSegueArray.append("OfferMessageSegue")
                
                
            }
            
            
            
            if(self.CellIndexIdsArray[indexPath.row] as! String == "100"){
                
                
                let vc = UpdateDetailViewController(nibName: nil, bundle: nil)
                vc.memeberArrayString = memeberArrayString
                vc.skipType = 2
                vc.type = "School"
                vc.schoolArrayString  = schoolArrayString
                vc.modalPresentationStyle = .formSheet
                present(vc, animated: true)
            }
            
            //                print("G3",appDelegate.mainSchoolPrincipalSegueArray[indexPath.row])
            
            if(self.CellIndexIdsArray[indexPath.row] as! String == "21"){
                
                if appDelegate.LoginSchoolDetailArray.count > 1 {
                    appDelegate.mainSchoolPrincipalSegueArray.append("OfferMessageSegue")
                }else {
                    if staffRole == "p2" {
                        appDelegate.mainSchoolPrincipalSegueArray.append("OfferMessageSegue")
                    }
                }
                
            }
            
            print("CellIndexIdsA1Before",self.CellIndexIdsArray[indexPath.row])
            if(self.appDelegate.mainSchoolPrincipalSegueArray[indexPath.row] == ""){
                print("self.CellIndexIdsArray[indexPath.row]1111",self.CellIndexIdsArray[indexPath.row])
                
                
                if(self.CellIndexIdsArray[indexPath.row] as! String == "28"){
                    
                    
                    if staffRole == "p2" {
                        let vc = NewDailyCollectionViewController(nibName: nil, bundle: nil)
                        vc.modalPresentationStyle = .fullScreen
                        present(vc, animated: true)
                    }
                    
                }
                
                else  if(self.CellIndexIdsArray[indexPath.row] as! String == "29"){
                    print("getstaffRole11",staffRole)
                    if staffRole == "p2" {
                        let vc = StudentReportViewController(nibName: nil, bundle: nil)
                        vc.modalPresentationStyle = .fullScreen
                        present(vc, animated: true)
                    }
                    
                    
                }
                
                
                
                
                else if(self.CellIndexIdsArray[indexPath.row] as! String == "30"){
                    print("getstaffRole",staffRole)
                    if staffRole == "p2" {
                        let vc = PrincipalLessonPlanViewController(nibName: nil, bundle: nil)
                        vc.modalPresentationStyle = .fullScreen
                        present(vc, animated: true)
                    }
                    else  if staffRole == "p3"{
                        let vc = LessonPlanViewController(nibName: nil, bundle: nil)
                        vc.modalPresentationStyle = .fullScreen
                        present(vc, animated: true)
                    }
                } 
                else  if(self.CellIndexIdsArray[indexPath.row] as! String == "31"){
                    
                    
                    let vc = PendingFeeReportViewController(nibName: nil, bundle: nil)
                    
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
//
             
                else  if(self.CellIndexIdsArray[indexPath.row] as! String == "34"){


                    let vc = StaffPtmViewController(nibName: nil, bundle: nil)

                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }else  if(self.CellIndexIdsArray[indexPath.row] as! String == "35"){

                    
                    
             
////                    
//                    let storyboard = UIStoryboard(name: "staffNoticeBoard", bundle: nil)
//                                                                  let viewController = storyboard.instantiateInitialViewController() as! StaffnoticeBoardVcViewController
////
//                    viewController.modalPresentationStyle = .fullScreen
//                                                                  self.present(viewController, animated: true)
//                    
                    
                }
                else  if(self.CellIndexIdsArray[indexPath.row] as! String == "32"){


                    let vc = LocationViewController(nibName: nil, bundle: nil)

                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
                else  if(self.CellIndexIdsArray[indexPath.row] as! String == "33"){


                    let vc = LocationHistoryVc(nibName: nil, bundle: nil)

                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }

                else{
                    
                    
                    
                    Util .showAlert("", msg: "Coming Soon!!!")
                    
                }
                
            }
            
            else{
                self.performSegue(withIdentifier: self.appDelegate.mainSchoolPrincipalSegueArray[indexPath.row] as! String, sender: nil)
                print("[indexPath.row12]",appDelegate.mainSchoolPrincipalSegueArray[indexPath.row])
                rowSelected = indexPath.row
            }
            
        }
        
        
    }
    
    
    func addShadow(myView : UIView) {
        myView.layer.masksToBounds = false
        myView.layer.shadowOpacity = 0.7
        myView.layer.shadowOffset = CGSize.zero
        myView.layer.shadowRadius = 4
        myView.layer.shadowColor = UIColor.black.cgColor
    }
    
    
    // MARK: BUTTON ACTION
    
    @IBAction func actionMenuButton(_ sender: Any) {
        MenuPopupView.isHidden = false
        
    }
    
    @IBAction func actionPopupHelpView(_ sender: Any) {
        MenuPopupView.isHidden = true
        remainingCharactersLabel.text = String(intiallength)
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PopupHelpView.frame.size.height = 390
            PopupHelpView.frame.size.width = 400
            
        }
        helpTextView.text = "Enter message here.."
        helpTextView.textColor = UIColor.lightGray
        
        
        
        
        PopupHelpView.center = view.center
        PopupHelpView.alpha = 1
        PopupHelpView.transform = CGAffineTransform(scaleX: 0.8, y: 1.2)
        
        self.view.addSubview(PopupHelpView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [],  animations: {
            //use if you want to darken the background
            //self.viewDim.alpha = 0.8
            //go back to original form
            self.PopupHelpView.transform = .identity
        })
        
    }
    
    @IBAction func actionSendHelpText(_ sender: Any) {
        helpTextView.resignFirstResponder()
        if(helpTextView.text.count > 0 && helpTextView.text != "Enter message here..")
        {
            self.CallHelpSendApi()
            popupHelpBtn.dismiss(true)
            
        }
        else
        {
            Util.showAlert("", msg: "Enter Messsage")
        }
        
    }
    
    @IBAction func actionClearHelpText(_ sender: UITextView) {
        
        helpTextView.text = "Enter message here.."
        helpTextView.textColor = UIColor.lightGray
        remainingCharactersLabel.text = String(intiallength)
        helpTextView.resignFirstResponder()
        
        
    }
    
    
    @IBAction func actionCloseHelpView(_ sender: Any) {
        helpTextView.text = ""
        PopupHelpView.alpha = 0
        //        popupHelpBtn.dismiss(true)
        
    }
    
    @IBAction func actionPopupChangePasswordView(_ sender: Any) {
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            PopupChangePasswordView.frame.size.height = 520
            PopupChangePasswordView.frame.size.width = 500
        }
        MenuPopupView.isHidden = true
        popupChangePasswordBtn = KLCPopup(contentView: PopupChangePasswordView, showType: KLCPopupShowType.none , dismissType:KLCPopupDismissType.none,maskType: KLCPopupMaskType.dimmed , dismissOnBackgroundTouch:  false , dismissOnContentTouch: false )
        popupChangePasswordBtn.show()
    }
    func DismissKEY()
    {
        ExistingPasswordText.resignFirstResponder()
        NewPasswordText.resignFirstResponder()
        VerifyNewPasswordText.resignFirstResponder()
    }
    
    @IBAction func actionUpdateChangePassword(_ sender: Any) {
        
        DismissKEY()
        if((ExistingPasswordText.text?.count)! > 0  && (NewPasswordText.text?.count)! > 0 && (VerifyNewPasswordText.text?.count)! > 0)
        {
            
            if(NewPasswordText.text?.isEqual(VerifyNewPasswordText.text))!
            {
                self.CallChangePasswordApi()
            }
            
            else
            {
                Util.showAlert("", msg: "New Passwords Mismatching")
            }
        }
        else
        {
            Util.showAlert("", msg: "Enter Valid Passwords")
        }
        
        
    }
    
    @IBAction func actionCancelUpdatePassword(_ sender: Any) {
        DismissKEY()
        self.clearChangePasswordText()
        popupChangePasswordBtn.dismiss(true)
        
    }
    
    @IBAction func actionPopupLogoutBView(_ sender: Any) {
        self.alertWithAction()
    }
    
    @IBAction func actionShowExistingPassword(_ sender: Any) {
        if(ExistingPasswordText.isSecureTextEntry == false)
        {
            ExistingPasswordText.isSecureTextEntry = true
            ShowExistingPswdButton.isSelected = false
        }
        else
        {
            ExistingPasswordText.isSecureTextEntry = false
            ShowExistingPswdButton.isSelected = true
        }
    }
    
    @IBAction func actionShowNewPassword(_ sender: Any) {
        if(NewPasswordText.isSecureTextEntry == false)
        {
            NewPasswordText.isSecureTextEntry = true
            ShowNewPswdButton.isSelected = false
        }
        else
        {
            NewPasswordText.isSecureTextEntry = false
            ShowNewPswdButton.isSelected = true
        }
        
    }
    
    @IBAction func actionShowVerifyNewPassword(_ sender: Any) {
        if(VerifyNewPasswordText.isSecureTextEntry == false)
        {
            VerifyNewPasswordText.isSecureTextEntry = true
            ShowVerifyPswdButton.isSelected = false
        }
        else
        {
            VerifyNewPasswordText.isSecureTextEntry = false
            ShowVerifyPswdButton.isSelected = true
        }
    }
    
    
    
    func clearChangePasswordText()
    {
        ExistingPasswordText.text = ""
        NewPasswordText.text = ""
        VerifyNewPasswordText.text = ""
        ExistingPasswordText.isSecureTextEntry = true
        ShowExistingPswdButton.isSelected = false
        VerifyNewPasswordText.isSecureTextEntry = true
        ShowVerifyPswdButton.isSelected = false
        NewPasswordText.isSecureTextEntry = true
        ShowNewPswdButton.isSelected = false
        
    }
    func clearHelpText()
    {
        helpTextView.text = "Enter message here.."
        helpTextView.textColor = UIColor.lightGray
        helpTextView.layer.borderWidth = 1
        helpTextView.layer.cornerRadius = 5
        helpTextView.layer.masksToBounds = true
        helpTextView.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    // MARK: - TAB BUTTON ACTION
    
    @IBAction func actionTabHome(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func actionTabLanguage(_ sender: Any) {
        let languageVC  = self.storyboard?.instantiateViewController(withIdentifier: "ChooseLanguageVC") as! ChooseLanguageVC
        languageVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(languageVC, animated: true, completion: nil)
    }
    
    @IBAction func actionTabChangePassword(_ sender: Any) {
        let changePasswordVC  = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordVC") as! ParentChangePasswordVC
        changePasswordVC.strFrom = "ChangePassword"
        changePasswordVC.strFromStaff = "Staff"
        changePasswordVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(changePasswordVC, animated: true, completion: nil)
    }
    
    @IBAction func actionFAQ(_ sender: Any) {
        let faqVC  = self.storyboard?.instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
        faqVC.fromVC = "Staff"
        self.navigationController?.pushViewController(faqVC, animated: true)
    }
    
    @IBAction func actionTabLogout(_ sender: UIButton) {
        self.showPopover(sender, Titletext: "")
        UserDefaults.standard.removeObject(forKey: DefaultsKeys.getgroupHeadRole)
        print("123456789345678")
    }
    
    func callLogoutAction(){
        let changePasswordVC  = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordVC") as! ParentChangePasswordVC
        changePasswordVC.strFromStaff = "Staff"
        changePasswordVC.strFrom = "Logout"
        self.navigationController?.pushViewController(changePasswordVC, animated: true)
    }
    
    // MARK: API CALLING
    func CallHelpSendApi() {
        showLoading()
        strApiFrom = "help"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        let requestStringer = baseUrlString! + HELP_METHOD
        
        let arrUserData : NSMutableArray = []
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["MobileNumber": UserMobileNo,"HelpText" : helpTextView.text]
        
        arrUserData.add(myDict)
        
        let myString = Util.convertDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "help")
    }
    
    func CallChangePasswordApi()
    {
        showLoading()
        strApiFrom = "ChangePassword"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        let requestStringer = baseUrlString! + CHANGEPSWD_METHOD
        let arrUserData : NSMutableArray = []
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["MobileNumber" : UserMobileNo, "NewPassword": NewPasswordText.text!,"OldPassword" : ExistingPasswordText.text!,]
        arrUserData.add(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "ChangePassword")
    }
    
    func CallSchoolDetailApi() {
        showLoading()
        strApiFrom = "SchoolDetail"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        let requestStringer = baseUrlString! + SCHOOLDETAIL_METHOD
        
        let arrUserData : NSMutableArray = []
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["MobileNumber" : UserMobileNo ,"CallerType" : "M"]
        
        arrUserData.add(myDict)
        
        let myString = Util.convertDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "SchoolDetail")
    }
    
    func CallVersionCheckApi()
    {
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
        memberArray()
        strApiFrom = "changeLang"
        let apiCall = API_call.init()
        apiCall.delegate = self
        let baseUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_LANGUAGE_CHANGE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        
        print("MAinrequestStringer",requestStringer)
        if(appDelegate.isPasswordBind == "1"){
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        
        let myDict:NSMutableDictionary = ["MemberData" : arrMembersData,"LanguageId": "1",COUNTRY_ID : strCountryCode]
        print(requestString)
        
        print("MenuDetails",myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        
        Constants.printLogKey("myDict", printValue: myDict)
        Constants.printLogKey("requestStringer", printValue: requestStringer)
        apiCall.nsurlConnectionFunction(requestString, myString, "deviceToken")
    }
    
    
    // MARK: API RESPONSES
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom.isEqual(to: "help"))
            {
                //print(csData)
                if((csData?.count)! > 0){
                    for var i in 0..<(csData?.count)!
                    {
                        let dicUser : NSDictionary = csData!.object(at: i) as! NSDictionary
                        
                        let Mystring = dicUser["Message"] as! String
                        Util.showAlert("", msg: Mystring)
                        popupHelpBtn.dismiss(true)
                        MenuPopupView.isHidden = true
                    }
                }
            }else if(strApiFrom.isEqual(to: "default")){
                if((csData?.count)! > 0)
                {
                    let dict : NSDictionary = csData?.object(at: 0) as! NSDictionary
                    if(dict["UpdateAvailable"] != nil){
                        if let arrayLan = dict[LANGUAGES] as? NSArray {
                            let arraylanguage : NSArray = dict[LANGUAGES] as! NSArray
                            appDelegate.LanguageArray = arraylanguage
                            appDelegate.strOfferLink = dict["Offerslink"] as? String ?? ""
                            appDelegate.strProductLink = dict["NewProductLink"] as? String ?? ""
                            appDelegate.strProfileLink = dict["ProfileLink"] as? String ?? ""
                            appDelegate.strProfileTitle = dict["ProfileTitle"] as? String ?? ""
                            appDelegate.strUploadPhotoTitle = dict["UploadProfileTitle"] as? String ?? ""
                            appDelegate.Helplineurl = dict["helplineURL"] as? String ?? ""
                            appDelegate.FeePaymentGateway = dict["FeePaymentGateway"] as? String ?? ""
                            
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
                        UserDefaults.standard.set(VideoSizeLimitAlert, forKey: VIDEOSIZELIMITALERT)
                        UserDefaults.standard.set(AdTimerInterval, forKey: ADTIMERINTERVAL)
                        
                    }
                }
                CallLanguageChangeApi()
                
            }else if(strApiFrom.isEqual(to: "changeLang")){
                guard let responseArray = csData else {
                    return
                    
                }
                print("RES : \(responseArray)")
                arrayForgetChangeDatas = responseArray
                
                for i in 0..<arrayForgetChangeDatas.count
                {
                    dicResponse = arrayForgetChangeDatas[i] as! NSDictionary
                    //                    print(dicResponse)
                    let myalertstatus = dicResponse["Status"] as? String ?? ""
                    if(myalertstatus == "1"){
                        assignParentStaffIDS(selectedDict: dicResponse)


                    }
                    
                 
                
                    
                }
                print("loadCellArrayData1ResponString")
                
                loadCellArrayData()
                
            }else  if(strApiFrom.isEqual(to: "ChangePassword"))
            {
                
                arrayForgetChangeDatas = csData!
                for var i in 0..<arrayForgetChangeDatas.count
                {
                    dicResponse = arrayForgetChangeDatas[i] as! NSDictionary
                }
                let myalertstring = String(describing: dicResponse["Message"]!)
                let myStatus = String(describing: dicResponse["Status"]!)
                
                if(myStatus == "1")
                {
                    Util.showAlert("", msg: myalertstring)
                    popupChangePasswordBtn.dismiss(true)
                    performSegue(withIdentifier: "BackToLoginSegue", sender: self)
                }
                else
                {
                    Util.showAlert("", msg: myalertstring)
                }
            }
            
        }
        else
        {
            
        }
        
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        // print("Error")
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
    //logged
    func TitleForNavigation(){
        let titleLabel = UILabel()
        
        titleLabel.frame = CGRect(x: 0, y:-30, width: self.view.frame.width , height: 45)
        
        titleLabel.textColor = .white
        
        var strLogged : String = String()
        if(strLoggedAS == "Staff"){
            strLogged = LanguageDict["as_staff"] as? String ?? "Staff"
        }else  if(strLoggedAS == "Admin"){
            strLogged = LanguageDict["as_admin"] as? String ?? "Admin"
        }else  if(strLoggedAS == "Principal"){
            strLogged = LanguageDict["as_principal"] as? String ?? "Principal"
        }else  if(strLoggedAS == "GroupHead"){
            strLogged = LanguageDict["as_grouphead"] as? String ?? "GroupHead"
        }else{
            strLogged = appDelegate.staffDisplayRole
        }
        
        let thirdWord :String  = strLogged + "    "
        let comboWord = thirdWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.white]
        let range = NSString(string: comboWord).range(of: "")
        attributedText.addAttributes(attrs, range: range)
        
        let imageAttachment =  NSTextAttachment()
        imageAttachment.image = UIImage(named:"navicon")
        let imageOffsetY:CGFloat = -25.0;
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: 42, height: 50)
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        
        attributedText.append(attachmentString)
        
        titleLabel.attributedText = attributedText
        titleLabel.textAlignment = .left;
        self.navigationItem.titleView = titleLabel
        
        
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        print("prepare",indexNumber)
        print("segue.identifier11",segue.identifier)
        print("CellLabelNameArray[indexNumber]",CellLabelNameArray[indexNumber])
        print("MainCellIconsArray[indexNumber]",CellIconsArray[indexNumber])
        if (segue.identifier == "AbsenteesSegue"){
            let segueid = segue.destination as! AbsentenceVC
            segueid.Selectedindexnumber = indexNumber
            segueid.fromVC = CellIconsArray[indexNumber]
            
        }else if (segue.identifier == "MainToSchoolSelectionSegue"){
            let segueid = segue.destination as! SchoolSelectionVC
            print("CellIconsArray[indexNumber]",CellIconsArray[indexNumber])
            segueid.fromVC = CellIconsArray[indexNumber]
            
            print("clickableType",clickableType)
            
            
            
        }else if (segue.identifier == "OfferMessageSegue"){
            let segueid = segue.destination as! NewProductOfferVC
            segueid.viewFromString = CellIconsArray[indexNumber]
        }
        
    }
    
    @objc func catchNotification(notification:Notification) -> Void{
        print("Notification Menu22")
    }
    
    @objc func catchNotification1(notification:Notification) -> Void{
        print("Notification Add")
    }
    @objc func LoadSelectedLanguageData(notification:Notification) -> Void{
        self.callSelectedLanguage()
    }
    
    func alertWithAction(){
        let alertController = UIAlertController(title: "Logout", message: "Are you sure want to logout?", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.logoutAction()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func logoutAction(){
        Childrens.deleteTables()
        UserDefaults.standard.set("Yes" as NSString, forKey: FIRSTTIMELOGINAS)
        UserDefaults.standard.set("Yes" as NSString, forKey: LOGOUT)
        DispatchQueue.main.async {
            self.appDelegate.mainSchoolPrincipalSegueArray = []
            
            self.performSegue(withIdentifier: "BackToLoginSegue", sender: nil)
        }
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        if(Util .isNetworkConnected())
        {
            self.CallLanguageChangeApi()
        }
        strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }else{
                    print("loadCellArrayData1CallSelectedLanguage")
                    
                    self.loadCellArrayData()
                }
            } catch {
                print("loadCellArrayData1Catche")
                
                self.loadCellArrayData()
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        LanguageDict = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.CollectionViewGrid.semanticContentAttribute = .forceRightToLeft
            self.SingleBottomView.semanticContentAttribute = .forceRightToLeft
            self.CombinationBottomView.semanticContentAttribute = .forceRightToLeft
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.SingleBottomView.semanticContentAttribute = .forceLeftToRight
            self.CollectionViewGrid.semanticContentAttribute = .forceLeftToRight
            self.CombinationBottomView.semanticContentAttribute = .forceLeftToRight
            
        }
        
        FAQLabel.text = LangDict["faq"] as? String
        PasswordLabel.text = LangDict["txt_password"] as? String
        LogoutLabel.text = LangDict["txt_menu_setting"] as? String
        
        CHomeLabel.text = LangDict["home"] as? String
        CFAQLabel.text = LangDict["faq"] as? String
        CPasswordLabel.text = LangDict["txt_password"] as? String
        CLogoutLabel.text = LangDict["txt_menu_setting"] as? String
        print("loadCellArrayData1LoadLanguage")
        
        self.loadCellArrayData()
        
    }
    
    
    func loadCellArrayData(){
        self.TitleForNavigation()
        let strcombination : String  = UserDefaults.standard.object(forKey: COMBINATION) as! String
        if(strcombination == "Yes"){
            CombinationBottomView.isHidden = false
            SingleBottomView.isHidden = true
        }else{
            CombinationBottomView.isHidden = true
            SingleBottomView.isHidden = false
        }
        
        Constants.printLogKey("appDelegate.LanguageArray", printValue: appDelegate.LanguageArray)
        Constants.printLogKey("LoginAsIndexInt", printValue: LoginAsIndexInt)
        print("LoginAsIndexInt",LoginAsIndexInt)
        
        MainCellCount = 0
        CellIconsArray.removeAll()
        CellLabelNameArray.removeAll()
        CellSegueArray.removeAll()
        let Dict : NSDictionary = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
        strBookenabled  = String(describing: Dict["isBooksEnabled"]!)
        strBookURL = String(describing: Dict["OnlineBooksLink"]!)
        Constants.printLogKey("CellSegueArray", printValue: CellSegueArray)
        
        
        if(LoginAsIndexInt == 0 || LoginAsIndexInt == 1 || LoginAsIndexInt == 2 || LoginAsIndexInt == 3 || LoginAsIndexInt == 4 ){
            var principalIndexArray  = UserDefaults.standard.object(forKey: PRINCIPLE_ARRAY_INDEX) as! NSArray
            var schoolLabelArray : NSArray = UserDefaults.standard.object(forKey: "PRINCIPLE_ARRAY_MENUNAMES") as? NSArray ?? []
            
            
            print("QuestionData!!!",QuestionData.count)
            
            
            print("schoolLabelArrayschoolLabelArray11111",schoolLabelArray)
            //
            let arryMut : NSMutableArray = NSMutableArray(array: schoolLabelArray)
            //                arryMut.removeAllObjects()
            if QuestionData.count > 0 {
                arryMut.insert("update_100" , at: 0)
                print("LoadCondition")

//

            }
                       
//            arryMut.add("PTM_34")
//            arryMut.add("NoticeBoard_35")
         
            schoolLabelArray =  arryMut as NSArray
            Constants.printLogKey("parentLabelArray", printValue: schoolLabelArray)
            print("schoolLabelArray1111",schoolLabelArray)
            
            
            
            
            Constants.printLogKey("principalIndexArray", printValue: principalIndexArray)
            //   let schoolLabelArray : NSArray = appDelegate.mainSchoolArrray[strLanguage] as! NSArray
            print("schoolLabelArray",schoolLabelArray)
            
            
         


            //* menu dynamic add
            //            CellSegueArray.append("Fee Pending Report_31")
            //*/
            
            print("before333",CellSegueArray)
            
            CellSegueArray = schoolLabelArray as! [String]
            
            print("schoolLabelArrayloop",schoolLabelArray)
            print("before Loop",CellSegueArray.count)
            print("before222",CellSegueArray)
            for i in 0..<CellSegueArray.count{
                let result = CellSegueArray[i].split(separator: "_")
                
                if(result[1] == "18"){
                    
                    if let index = CellSegueArray.index(of: CellSegueArray[i]) {
                        CellSegueArray.remove(at: index)
                        break
                    }
                    
                }
                
                
                //
            }
            
            
            if(strBookenabled != "1")
            {
                let arryMut : NSMutableArray = NSMutableArray(array: principalIndexArray)
                arryMut.remove("18")
                //* menu dynamic add
//
                // *//


                principalIndexArray = arryMut
            }
            Constants.printLogKey("principalIndexArray", printValue: principalIndexArray)
            MainCellCount = principalIndexArray.count
            var iMIndex = 0
            for i in 0..<principalIndexArray.count{
                let index : NSString = String(describing: principalIndexArray[i]) as NSString
                
                if(index.integerValue == 18){
                    bookIndex = i
                }
                if appDelegate.mainSchoolPrincipalSegueArray.count > index.integerValue {
                    cellSegueArrayType = "Principal"
                    print("CellSegueArray.append",CellSegueArray.count)
                    
                    print("CellSegueArray.append",CellSegueArray.count)
                }
            }
            appDelegate.mainSchoolPrincipalSegueArray = []
            print("empty.sCellSegueArray",CellSegueArray.count)
            print("emptyschoolLabelArray",schoolLabelArray)
            print("empty.mainSchoolPrincipalSegueArray",appDelegate.mainSchoolPrincipalSegueArray.count)
            
            print("iddddtrftrtrr")
            //            }
            print("empty.sCellSegueArray23456",CellSegueArray)
            for idd in 0..<schoolLabelArray.count{
                
                
                
                let strtite = schoolLabelArray[idd] as? String ?? ""
                print("MEnu \(strtite) Index : \(idd)")
                let result = strtite.split(separator: "_")
                print("result.count",result.count)
                print("result.count111",result)
                
                if(result.count > 0){
                    var imageName = "\(String(result[1]))"
                    print("imageName \(imageName)")
                    indexNumber = Int(imageName)!
                    print("imageName \(imageName)")
                    
                    
                    if(imageName != "18"){
                        
                        
                        imageName = "p\(imageName)"
                        CellIconsArray.append(imageName)
                        CellLabelNameArray.append(String(result[0]))
                        CellIndexIdsArray.add(String(result[1]))
                        
                        print("CellIndexIdsArraylSegueArray",CellIndexIdsArray)
                        
                        
                        if(result[1] == "100"){
                            
                            appDelegate.mainSchoolPrincipalSegueArray.append("MainToSchoolSelectionSegue")
                            
                            
                            
                        }
                        
                        
                        
                        
                        
                        
                        if(result[1] == "0"){
                            
                            
                            appDelegate.mainSchoolPrincipalSegueArray.append("EmergencyVoiceSegue")
                            
                            
                            
                        }
                        else  if(result[1] == "1"){
                            print("appDelegate.LoginSchoolDetailArray.count",appDelegate.LoginSchoolDetailArray.count)
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                print("if login")
                                appDelegate.mainSchoolPrincipalSegueArray.append("MainToSchoolSelectionSegue")
                                
                            }
                            else{
                                print("else login")
                                if staffRole == "p2" || staffRole == "p1" {
                                    
                                    appDelegate.mainSchoolPrincipalSegueArray.append("VoiceMessageSegue")
                                }else {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("StaffVoiceMessageVC")
                                }
                            }
                        }
                        else  if(result[1] == "2"){
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("MainToSchoolSelectionSegue")
                                
                            }else{
                                if staffRole == "p2" {
                                    let userDefaults = UserDefaults.standard
                                    //                                    var StaffRole : String!
                                    userDefaults.set("Principal", forKey: DefaultsKeys.staffDisplayRole)
                                    appDelegate.mainSchoolPrincipalSegueArray.append("TextMessageSegue")
                                }
                                else{
                                    
                                    appDelegate.mainSchoolPrincipalSegueArray.append("StaffTextVC")
                                }
                            }
                        }
                        
                        else  if(result[1] == "3"){
                            //
                            print("staffRolestaffRole",staffRole)
                            
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("NoticeBoardSegue")
                                
                            }else{
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("NoticeBoardSegue")
                                }
                                else{
                                    appDelegate.mainSchoolPrincipalSegueArray.append("")
                                }
                            }
                        }
                        else  if(result[1] == "4"){
                            //
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("SchoolEventsSegue")
                                
                            }else{
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("SchoolEventsSegue")
                                }else{
                                    appDelegate.mainSchoolPrincipalSegueArray.append("")
                                }
                            }
                        }
                        else  if(result[1] == "5"){
                            //
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("ImageMessageSegue")
                                
                            }else{
                                
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("ImageMessageSegue")
                                }else{
                                    appDelegate.mainSchoolPrincipalSegueArray.append("StaffImageVC")
                                }
                            }
                            
                        }
                        
                        else  if(result[1] == "6"){
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("AbsenteesSegue")
                            }else{
                                if staffRole == "p2" {
                                    //                                    ViewAbsenteesDateViceSegue
                                    appDelegate.mainSchoolPrincipalSegueArray.append("AbsenteesSegue")
                                }
                            }
                        }
                        
                        else  if(result[1] == "7"){
                            //School Strength
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("AbsenteesSegue")
                            }else{
                                if staffRole == "p2" {
                                    //                                    ViewSchoolStrengthSegue
                                    appDelegate.mainSchoolPrincipalSegueArray.append("AbsenteesSegue")
                                }
                            }
                            
                        }
                        else  if(result[1] == "9"){
                            //
                            
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("TextHomeworkSelectSchoolSegue")
                                
                            }else{
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("TextHomeworkSegue")
                                }else{
                                    
                                    
                                    appDelegate.mainSchoolPrincipalSegueArray.append("TextHomeworkSegue")
                                }
                            }
                        }
                        else  if(result[1] == "10"){
                            //
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("VoiceHomeworkSelectSchoolSegue")
                                
                            }else{
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("VoiceHomeworkSegue")
                                }else{
                                    appDelegate.mainSchoolPrincipalSegueArray.append("VoiceHomeworkSegue")
                                }
                            }
                        }
                        
                        
                        else  if(result[1] == "11"){
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("ExamTestSelectSchoolSegue")
                                
                            }else{
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("DirectExamTestSegue")
                                }else{
                                    
                                    
                                    appDelegate.mainSchoolPrincipalSegueArray.append("DirectExamTestSegue")
                                }
                            }
                        }
                        
                        
                        
                        else  if(result[1] == "12"){
                            //Attendance Marking p12
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("AttendanceSelectSchoolSegue")
                                
                            }else{
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("AttendanceMessageSegue")
                                }else{
                                    appDelegate.mainSchoolPrincipalSegueArray.append("AttendanceMessageSegue")
                                }
                            }
                        }
                        
                        else  if(result[1] == "13"){
                            //Messages From Management  p13
                            
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                
                                //
                                appDelegate.mainSchoolPrincipalSegueArray.append("AbsenteesSegue")
                                //                                }
                            }else{
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("MsgMgmtSegue")
                                }else{
                                    appDelegate.mainSchoolPrincipalSegueArray.append("MsgMgmtSegue")
                                }
                            }
                        }
                        else  if(result[1] == "14"){
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("FeedbackSegue")
                            }else{
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("FeedbackSegue")
                                }
                            }
                            //
                        }
                        else  if(result[1] == "21"){
                            //                      Very Important Info
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("OfferMessageSegue")
                            }else {
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("OfferMessageSegue")
                                }
                            }
                        }
                        else  if(result[1] == "18"){
                            //                      Very Important Info
                            appDelegate.mainSchoolPrincipalSegueArray.append("")
                            //
                        }
                        
                        else  if(result[1] == "16"){
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("ConferenceSchoolListSegue")
                            }else{
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("ConferenceSchoolListSegue")
                                }
                            }
                        }
                        else  if(result[1] == "17"){
                            //                              leave Request
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("StaffLeaveRequestSegue")
                                //
                            }else{
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("StaffLeaveRequestSegue")
                                }else{
                                    appDelegate.mainSchoolPrincipalSegueArray.append("StaffLeaveRequestSegue")
                                }
                            }
                        }
                        else  if(result[1] == "25"){
                            //                      Very Important Info
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("OfferMessageSegue")
                            }else {
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("OfferMessageSegue")
                                }
                            }
                        }
                        
                        
                        
                        else  if(result[1] == "22"){
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("CreateAssignmentSegue")
                            }else{
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("CreateAssignmentSegue")
                                }else{
                                    appDelegate.mainSchoolPrincipalSegueArray.append("CreateAssignmentSegue")
                                    
                                }
                            }
                        }
                        
                        else  if(result[1] == "23"){
                            
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("UploadVimeoVideoSegue")
                            }else{
                                
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("UploadVimeoVideoSegue")
                                }else{
                                    appDelegate.mainSchoolPrincipalSegueArray.append("UploadVimeoVideoSegue")
                                    
                                }
                            }
                        }
                        
                        else  if(result[1] == "24"){
                            
                            
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("AbsenteesSegue")
                                
                            }else{
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("studentChatSegue")
                                    
                                }else {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("studentChatSegue")
                                }
                            }
                        }
                        
                        else  if(result[1] == "26"){
                            
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("MainToSchoolSelectionSegue")
                                //
                            }else{
                                if staffRole == "p2" {
                                    appDelegate.mainSchoolPrincipalSegueArray.append("CreateOnlineSeg")
                                }else{
                                    appDelegate.mainSchoolPrincipalSegueArray.append("CreateOnlineSeg")
                                }
                            }
                        }
                        else  if(result[1] == "28"){
                            
                            
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("MainToSchoolSelectionSegue")
                                
                            }else{
                                appDelegate.mainSchoolPrincipalSegueArray.append("")
                                
                            }
                            
                        }
                        else  if(result[1] == "29"){
                            
                            
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("MainToSchoolSelectionSegue")
                                
                            }else{
                                appDelegate.mainSchoolPrincipalSegueArray.append("")
                                
                            }
                            
                            
                        }
                        else  if(result[1] == "30"){
                            
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                appDelegate.mainSchoolPrincipalSegueArray.append("MainToSchoolSelectionSegue")
                            }else{
                                
                                if staffRole == "p2" {
                                    
                                    appDelegate.mainSchoolPrincipalSegueArray.append("")
                                }else if staffRole == "p3"{
                                    //
                                    appDelegate.mainSchoolPrincipalSegueArray.append("")
                                    
                                }
                            }
                        }
                        
                        else  if(result[1] == "31"){
                            print("PendingReport")
                            if appDelegate.LoginSchoolDetailArray.count > 1 {
                                
                                appDelegate.mainSchoolPrincipalSegueArray.append("MainToSchoolSelectionSegue")
                            }else{
                                
                                if staffRole == "p2" {
                                    
                                    appDelegate.mainSchoolPrincipalSegueArray.append("")
                                }else if staffRole == "p3"{
                                    //
                                    appDelegate.mainSchoolPrincipalSegueArray.append("")
                                    
                                }
                            }
                        } else  if(result[1] == "32"){
                            print("PendingReport")
                            if appDelegate.LoginSchoolDetailArray.count > 1 {

                                                                appDelegate.mainSchoolPrincipalSegueArray.append("MainToSchoolSelectionSegue")
                            }else{

                                if staffRole == "p2" {

                                    appDelegate.mainSchoolPrincipalSegueArray.append("")
                                                                    }else if staffRole == "p3"{
                                                                        //
                                                                        appDelegate.mainSchoolPrincipalSegueArray.append("")
                                    //
                                    //                                }
                                }
                                else{
                                                                                                        appDelegate.mainSchoolPrincipalSegueArray.append("")
                                                                                                    }
                            }
                        }
                        
                        if(result[1] == "33"){
                            print("PendingReport")
                            if appDelegate.LoginSchoolDetailArray.count > 1 {

                                                                appDelegate.mainSchoolPrincipalSegueArray.append("MainToSchoolSelectionSegue")
                            }else{

                                if staffRole == "p2" {

                                    appDelegate.mainSchoolPrincipalSegueArray.append("")
                                                                    }else if staffRole == "p3"{
                                                                        //
                                                                        appDelegate.mainSchoolPrincipalSegueArray.append("")
                                    //
                                    //                                }
                                }
                            }
                        }
                        
                        if(result[1] == "34"){
                            print("PendingReport")
                            if appDelegate.LoginSchoolDetailArray.count > 1 {

                                                                appDelegate.mainSchoolPrincipalSegueArray.append("MainToSchoolSelectionSegue")
                            }else{

                                if staffRole == "p2" {

                                    appDelegate.mainSchoolPrincipalSegueArray.append("")
                                                                    }else if staffRole == "p3"{
                                                                        //
                                                                        appDelegate.mainSchoolPrincipalSegueArray.append("")
                                    //
                                    //                                }
                                }
                                
                                else{
                                                                                                        appDelegate.mainSchoolPrincipalSegueArray.append("")
                                                                                                    }
                            }
                        }
                        
                        
                        
                        if(result[1] == "35"){
                            print("PendingReport")
                            if appDelegate.LoginSchoolDetailArray.count > 1 {

                                                                appDelegate.mainSchoolPrincipalSegueArray.append("MainToSchoolSelectionSegue")
                            }else{

                                if staffRole == "p2" {

                                    appDelegate.mainSchoolPrincipalSegueArray.append("")
                                                                    }else if staffRole == "p3"{
                                                                        //
                                                                        appDelegate.mainSchoolPrincipalSegueArray.append("")
                                    //
                                    //                                }
                                }
                                
                                
                                else{
                                    appDelegate.mainSchoolPrincipalSegueArray.append("")
                                                                                                    }
                            }
                        }
                        
                        
                        
                        
                        else{
                            
                            
                        }
                        
                    }
                    
                    
                    
                    
                    
                    
                }else{
                    print("0th Index")
                    CellLabelNameArray.append(strtite)
                    appDelegate.mainSchoolPrincipalSegueArray.append("TextMessageSegue")
                    CellIconsArray.append(strtite)
                    
                    
                }
                
            }
            print("appDelegate.mainSchoolPrincipalSegueArrayCount",appDelegate.mainSchoolPrincipalSegueArray.count)
            print("mainSchoolDetail",appDelegate.mainSchoolPrincipalSegueArray)
            Constants.printLogKey("CellLabelNameArray", printValue: CellLabelNameArray)
            
        }
        
        
        
        if(appDelegate.LoginSchoolDetailArray.count > 1)
        {
            SchoolView.isHidden = true
            SchoolViewHeight.constant = 0
            
            
            NumberofCell = MainCellCount
            print("appDelegate.LoginSchoolDetailArray.count > 1",NumberofCell)
        }else
        {
            
            NumberofCell = MainCellCount
            print("else..count > 1",NumberofCell)
            SchoolView.isHidden = false
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                SchoolViewHeight.constant = 150
            }else{
                SchoolViewHeight.constant = 110
            }
            SchoolNameLbl.text = String(describing: Dict["SchoolName"]!)
            SchoolLocationLbl.text = String(describing: Dict["city"]!)

            var schoolNameReg  =  Dict["SchoolNameRegional"] as? String

                                if schoolNameReg != "" && schoolNameReg != nil {

                                    SchoolNameRegionalLbl.text = schoolNameReg
                            SchoolNameRegionalLbl.isHidden = false

            //                        cell.locationTop.constant = 4
                                }else{
                                SchoolNameRegionalLbl.isHidden = true
                        //            cell.SchoolNameRegional.backgroundColor = .red
                                    locationTop.constant = -10

                                }


            SchoolImg.sd_setImage(with: URL(string: String(describing: Dict["SchoolLogo"]!)), placeholderImage: UIImage(named: "placeHolder.png"), options: SDWebImageOptions.refreshCached)
            
            
        }
        LoadCollectionViewData()
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            self.CollectionViewTopHeight.constant = 20
            self.CollectionViewBottomHeight.constant = 20
            
        }else{
            if(self.view.frame.height > 600){
                self.CollectionViewTopHeight.constant = 10
                self.CollectionViewBottomHeight.constant = 10
                
            }else{
                self.CollectionViewTopHeight.constant = 0
                self.CollectionViewBottomHeight.constant = 0
            }
        }
        if(appDelegate.isParent == "true")
        {
            self.navigationItem.setHidesBackButton(false, animated:true)
            
        }else
        {
            self.navigationItem.setHidesBackButton(true, animated:true)
        }
        if(strcombination == "Yes"){
            self.navigationItem.setHidesBackButton(false, animated:true)
            
            let backButton = UIBarButtonItem(image: UIImage(named: "backarrow"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MainVC.BackAction))
            self.navigationItem.leftBarButtonItem = backButton
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.backgroundColor = .orange
        self.navigationController?.navigationBar.barTintColor = .white
        
        UserDefaults.standard.set("Yes", forKey: AT_VERY_FIRST_TIME)
        UserDefaults.standard.set("Yes" as NSString, forKey: FIRSTTIMELOGINAS)
        UserDefaults.standard.set("No" as NSString, forKey: LOGOUT)
        if(UIDevice.current.userInterfaceIdiom == .pad){
            self.navigationController?.navigationBar.frame.size.height = 60
        }
        setNavColor()
        NumberofCell = CellLabelNameArray.count
        MenuPopupView.isHidden = true
        ExistingPasswordText.keyboardType = UIKeyboardType.numbersAndPunctuation
        NewPasswordText.keyboardType = UIKeyboardType.numbersAndPunctuation
        VerifyNewPasswordText.keyboardType = UIKeyboardType.numbersAndPunctuation
        
    }
    
    
    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)
        
        return arr
    }
    
    @objc func BackAction(sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func setNavColor(){
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = utilClass.SCHOOL_NAV_BAR_COLOR
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    func memberArray(){
        var idArray : NSMutableArray = NSMutableArray()
        var schoolIdArray : NSMutableArray = NSMutableArray()
        let userDefaults = UserDefaults.standard
        for i in 0..<appDelegate.LoginSchoolDetailArray.count{
            let Dict : NSDictionary =  appDelegate.LoginSchoolDetailArray[i] as! NSDictionary
            idArray.add(String(describing: Dict["StaffID"]!))
            schoolIdArray.add(String(describing: Dict["SchoolID"]!))
            DefaultsKeys.school_type.removeAll()
            var staffIDs =  Dict["StaffID"]
            var schollids = Dict["SchoolID"]
            var school_type =  Dict["school_type"]
            var biometricEnable =  Dict["biometricEnable"]
            userDefaults.set(school_type, forKey: DefaultsKeys.school_type)
            userDefaults.set(staffIDs, forKey: DefaultsKeys.StaffID)
            userDefaults.set(schollids, forKey: DefaultsKeys.SchoolD)
            //            userDefaults.set(stringconvert,forKey: DefaultsKeys.school_type)
            print("DefaultsKeys.Dict[SchoolID]",Dict["SchoolID"])
            print("DefaultsKeys.Dict[StaffID]",Dict["StaffID"])
            print("DefaultsKeys.biometricEnable",Dict["biometricEnable"])
            print("DefaultallowVideoDownload",Dict["allowVideoDownload"])
            userDefaults.set(biometricEnable, forKey: DefaultsKeys.biometricEnable)
            
            
           
                                            var getvalue = Dict["allowVideoDownload"]
                                           
            userDefaults.set(getvalue, forKey: DefaultsKeys.allowVideoDownload)
                                            
//                                            print("downloadNodeRole", DefaultsKeys.biometricEnable)
            //                                }
            let dicMembers = ["type" : "staff",
                              "id" : String(describing: Dict["StaffID"]!),
                              "schoolid" : String(describing: Dict["SchoolID"]!)
            ]
            
            arrMembersData.add(dicMembers)
        }
        schoolArrayString = schoolIdArray.componentsJoined(by: "~")
        memeberArrayString = idArray.componentsJoined(by: "~")
        //        userDefaults.set(memeberArrayString, forKey: DefaultsKeys.MemberidTild)
        print(memeberArrayString)
        
    }
    
    func assignParentStaffIDS(selectedDict : NSDictionary){
        
        
        
        let strMenuID  : String = String(describing: selectedDict[IS_MENU_ID]!)
        let MenuIDArray = strMenuID.components(separatedBy: ",") as NSArray
        Constants.printLogKey("menuIDArray", printValue: MenuIDArray)
        let strMenuName  : String = String(describing: selectedDict["menu_name"]!)
        let menu_namearr = strMenuName.components(separatedBy: ",") as NSArray
        print("menu_namearr",menu_namearr)
        
        UserDefaults.standard.set(menu_namearr, forKey: "PRINCIPLE_ARRAY_MENUNAMES")
        
        
        
        stralerMsg = selectedDict["alert_message"] as? String ?? ""
        lblscrollView.text = stralerMsg
        loadCellArrayData()
        print("loadCellArrayData1assignParentStaffIDS")
    }
    
    
    // MARK: - Popover delegate  & Functions
    func showPopover(_ base: UIView, Titletext: String)
    {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DropDownVC") as? DropDownVC {
            
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .popover
            viewController.fromVC = "setting"
            
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
    
    @objc func UpdateLogoutSelection(notification:Notification) -> Void
    {
        print("Main")
        var selectString = notification.object as? String ?? ""
        selectString = selectString.lowercased()
        let log = LanguageDict["txt_menu_logout"] as? String ?? ""
        if(selectString == log.lowercased()){
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() )
            {
                self.showLogoutAlert()
            }
        }else if(selectString.contains("edit")){
            callEditProfile()
        }else if(selectString.contains("help")){
            callhelp()
        }
        else{
            callUploadDocumentView()
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
        let alertController = UIAlertController(title: LanguageDict["txt_menu_logout"] as? String, message: LanguageDict["want_to_logut"] as? String, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: LanguageDict["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.moveToLogInScreen(strFromStaff: "Staff")
        }
        let cancelAction = UIAlertAction(title: LanguageDict["teacher_cancel"] as? String, style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func coutApi(){

        print("appDelSchoolDetailnt",appDelegate.LoginSchoolDetailArray.count)

        DefaultsKeys.coutData.removeAll()
        var scholId = ""
        var staffId = ""
        
        var CountModal1 : [CountReqModal] = []
        for i in 0..<appDelegate.LoginSchoolDetailArray.count{
            
            
            let Dict : NSDictionary =  appDelegate.LoginSchoolDetailArray[i] as! NSDictionary
            staffId = (String(describing: Dict["StaffID"]!))
            scholId    = (String(describing: Dict["SchoolID"]!))
          
            let couts = CountReqModal()
            couts.SchoolID = scholId
            couts.staffId = staffId
            
            CountModal1.append(couts)
         
        }
        
        
        let countStr = CountModal1.toJSONString()
        print("requessttttt",countStr)

        print("requessttttt",countStr)

        CountRequest.call_request(param: countStr!){
            [self] (res) in
            
            print("responsAPiii",res)

            if DefaultsKeys.failedErrorCode == 404 {
                print("DefaultsKeys.failedErrorCode",DefaultsKeys.failedErrorCode)
            }else{

                let coutnsResp : [countResponce] = Mapper<countResponce>().mapArray(JSONString: res)!

                OverAllCountValue = 0;
                for i in 0..<coutnsResp.count
                {

                    OverAllCountValue = OverAllCountValue + Int(coutnsResp[i].OVERALLCOUNT)!
                }




                //        defaultkcoutData.append(contentsOf: coutnsResp)

                DefaultsKeys.coutData.append(contentsOf: coutnsResp)
                CollectionViewGrid.reloadData()
            }

        }
        
        
        
        print("coutDatacoutData",coutData.count)
      
        
        
    }
    
    
}



