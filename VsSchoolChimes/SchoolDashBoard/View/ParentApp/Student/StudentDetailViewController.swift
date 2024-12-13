//
//  StudentDetailViewController.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 10/06/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//
//New changs
import UIKit
import AVFoundation
import MarqueeLabel
import Photos
import ObjectMapper




class StudentDetailViewController: UIViewController ,Apidelegate ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIPopoverPresentationControllerDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    @IBOutlet weak var locationTop: NSLayoutConstraint!
    
    @IBOutlet weak var SchoolNameRegionalLbl: UILabel!
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    @IBOutlet weak var SchoolViewTop: NSLayoutConstraint!
    @IBOutlet weak var AdView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var CollectionViewTopHeight: NSLayoutConstraint!
    @IBOutlet weak var CollectionViewBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var SchoolViewHeight: NSLayoutConstraint!
    var mystring = NSString()
    @IBOutlet weak var SchoolLogoImage: UIImageView!
    @IBOutlet weak var SchoolNameLabel: UILabel!
    @IBOutlet weak var SchoolSubView: UIView!
    @IBOutlet weak var LogoutLabel: UILabel!
    @IBOutlet weak var FAQLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var SchoolView: UIView!
    @IBOutlet weak var SchoolLocationLabel: UILabel!
    @IBOutlet weak var CollectionViewGrid: UICollectionView!
    var selectedDictionary = NSDictionary()
    var strApiFrom = NSString()
    var hud : MBProgressHUD = MBProgressHUD()
    var detailsArray: NSMutableArray = []
    var typesArray: NSMutableArray = []
    var arrUserData: NSArray = []
    var selectedUnRead = NSString()
    var strSelectDate : NSString = ""
    var UnreadCountArray : NSMutableArray = []
    var parentIndexArray : NSArray = []
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    var strBookURL = String()
    var strLanguage = String()
    var strCountryCode = String()
    var NumberofCell = 0
    var bookIndex = -1
    var CellLabelNameArray : NSMutableArray = []
    var CellIndexIdsArray : NSMutableArray = []
    var CellIconsArray : NSMutableArray = []
    var CellSegueArray : NSMutableArray = []
    var strBookenabled : String = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var languageDictionary = NSDictionary()
    var SchoolIDString = String()
    var ChildIDString = String()
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    weak var timer: Timer?
    var image_choose: Bool = false
    
    var SelectedAssets = [PHAsset]()
    
    //    var updateTime = Int!
    var menuId : String!
    var DivideColumn :CGFloat = CGFloat()
    
    var getadID : Int!
    var strEmergencyVoiceCount : String = ""
    var strVoiceCount : String = ""
    var strSMSCount : String = ""
    var strNoticeCount : String = ""
    var strEventCount : String = ""
    var strImageCount : String = ""
    var strPDFCount : String = ""
    var strHomeworkCount : String = ""
    var strExamTestCount : String = ""
    var strExam_marks : String = ""
    var strVideoCount : String = ""
    var  strAssignmentCount : String = ""
    var strOnlineCount : String = ""
    
    
    
    var schoolArrayString = String()
    var rowSelected : Int?
    var arrMembersData = NSMutableArray()
    var newArrMembersData = NSMutableArray()
    var memeberArrayString = String()
    var stralerMsg = String()
    var staffRole : String!
    var  QuestionData : [UpdateDetailsData]! = []
    var arrayList : [Int] = []
    @IBOutlet weak var lblscrollView:MarqueeLabel!
    
    
    var ChildId : String!
    
    let deviceName = UIDevice.current.model
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("11VC")
        let userDefaults = UserDefaults.standard
        
        staffRole = userDefaults.string(forKey: DefaultsKeys.StaffRole)!
        
        lblscrollView.text = "\(stralerMsg) "
        lblscrollView.font = .systemFont(ofSize: 15)
        
        SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        
        SchoolLocationLabel.isHidden = false
        let defaults = UserDefaults.standard
        //        print("SchoolId",SchoolId)
        
        print("SchoolIDString",SchoolIDString)
        
       
        print("Device name: \(deviceName)")


        var schoolNameReg  = userDefaults.string(forKey: DefaultsKeys.SchoolNameRegional)!

               if schoolNameReg != "" && schoolNameReg != nil {

                   SchoolNameRegionalLbl.isHidden = false
                   SchoolNameRegionalLbl.text = schoolNameReg

print("schoolNameReg",schoolNameReg)
                   locationTop.constant = 4
               }else{
                   SchoolNameRegionalLbl.isHidden = true
                   print("schoolNameRegEmpty",schoolNameReg)
       //            cell.SchoolNameRegional.backgroundColor = .red
                   locationTop.constant = -18

               }


        ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        print("ChildIdChildId",ChildId)
        var SecID = String(describing: appDelegate.SchoolDetailDictionary["sectionId"]!)
        var ClassID = String(describing: appDelegate.SchoolDetailDictionary["classId"]!)
       

        var SchoolNameRegional = String(describing: appDelegate.SchoolDetailDictionary["SchoolNameRegional"]!)
       defaults.set(ClassID, forKey: DefaultsKeys.ClassID)
        defaults.set(SecID, forKey: DefaultsKeys.SectionId)
       


        defaults.set(SchoolNameRegional, forKey: DefaultsKeys.SchoolNameRegional)

        defaults.set(ChildId, forKey: DefaultsKeys.studentId)
        ChildIDString = defaults.string(forKey:DefaultsKeys.chilId)!
        print("classIdclassId",ClassID)
        print("sectionIdsectionId",SecID)
        print("ChildIDString",ChildIDString)
        print("StaffDetailsVC11226789")
        async {
            
            await AdConstant.AdRes(memId: ChildIDString, memType: "student", menu_id: AdConstant.getMenuId as String, school_id: SchoolIDString)
            menuId = AdConstant.getMenuId as String
            print("menu_id:\(AdConstant.getMenuId)")
            
            
        }
        
        
        
        
        
        async {
            do {
                //
                menuId = AdConstant.getMenuId as String
                print("menu_id:\(AdConstant.getMenuId)")
                
                
                
                let AdModal = AdvertismentModal()
                AdModal.MemberId = ChildId
                AdModal.MemberType = "student"
                if AdConstant.mgmtVoiceType == "1" {
                    AdModal.MenuId = "0"
                }
                AdModal.MenuId = menuId
                AdModal.SchoolId = SchoolIDString
                
                
                let admodalStr = AdModal.toJSONString()
                
                
                print("admodalStr22221",admodalStr)
                AdvertismentRequest.call_request(param: admodalStr!) { [self]
                    
                    (res) in
                    
                    let adModalResponse : [AdvertismentResponse] = Mapper<AdvertismentResponse>().mapArray(JSONString: res)!
                    
                    
                    
                    //            var adDataList : [MenuData] = []
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
        }else{
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    override func viewWillAppear(_ animated: Bool) {
        
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(StudentDetailViewController.catchNotification), name: NSNotification.Name(rawValue: "comeBack"), object:nil)
        nc.addObserver(self,selector: #selector(StudentDetailViewController.LoadSelectedLanguageData), name: NSNotification.Name(rawValue: LANGUAGE_NOTIFICATION), object:nil)
        nc.addObserver(self,selector: #selector(StudentDetailViewController.UpdateLogoutSelection), name: NSNotification.Name(rawValue: "SettingNotification"), object:nil)
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        //        updateDetailsApi()
        self.callSelectedLanguage()
        CallLanguageChangeApi()
        
        let defaults = UserDefaults.standard
        var appLaunch = defaults.bool(forKey: "isAppAlreadyLaunchedOnce")
        print("appLaunchappLaunch",appLaunch)
        
        
        let userDefaults = UserDefaults.standard
        
        var updateTime : Int!
        updateTime  =  userDefaults.integer(forKey: DefaultsKeys.updateTime)
        
        
        
        
        
        var changPos  = userDefaults.integer(forKey: DefaultsKeys.lastUpdateList)
        var listCount  = userDefaults.integer(forKey: DefaultsKeys.updateListCount)
        
        print("changPos",changPos)
        print("listCount",listCount)
        
        if listCount == changPos {
            print("No Update Detail Data")
        }else{
            
            
            
            let defaults = UserDefaults.standard
            var appLaunch = defaults.bool(forKey: "isAppAlreadyLaunchedOnce")
            print("appLaunchappLaunch",appLaunch)
            let userDefaults = UserDefaults.standard
            var updateTime : Int!
            updateTime  =  userDefaults.integer(forKey: DefaultsKeys.updateTime)
            print("updateTime",updateTime)
            var randomAmountOfTime = Double(updateTime)
            
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + randomAmountOfTime) { [self] in
                let mainvc = UpdateDetailViewController(nibName: nil, bundle: nil)
                mainvc.memeberArrayString = memeberArrayString
                mainvc.type = "parent"
                mainvc.schoolArrayString  = schoolArrayString
                mainvc.modalPresentationStyle = .formSheet
                present(mainvc, animated: true)
            }
        }
        





    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        self.title = ""
        
    }
    
    
    func setTopViewInitial() -> Void {
        
        SchoolNameLabel.text = String(describing: selectedDictionary["SchoolName"]!)
        SchoolLocationLabel.text = String(describing: selectedDictionary["SchoolCity"]!)
        
        SchoolLogoImage.sd_setImage(with: URL(string: String(describing: selectedDictionary["SchoolLogoUrl"]!)), placeholderImage: UIImage(named: "placeHolder.png"), options: SDWebImageOptions.refreshCached)
        
        mystring = "Student"
        
        setInitialViews()
        if(Util.isNetworkConnected())
        {
            CallTotalUnReadCountApi()
        }
        else
        {
            UnreadCountArray = UserDefaults.standard.array(forKey: "UNREADCOUNT")! as NSArray as! NSMutableArray
            CollectionViewGrid.reloadData()
        }
        
    }
    @objc func catchNotification(notification:Notification) -> Void {
        print("Notification Comnebback")
        if(Util .isNetworkConnected()){
            CallTotalUnReadCountApi()
        }
        
    }
    
    @objc func LoadSelectedLanguageData(notification:Notification) -> Void {
        self.callSelectedLanguage()
    }
    
    func setInitialViews(){
        
        self.navigationItem.setHidesBackButton(false, animated:true)
        let backButton = UIBarButtonItem(image: UIImage(named: "backarrow"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(StudentDetailViewController.BackAction))
        self.navigationItem.leftBarButtonItem = backButton
        
        self.title = String(describing: selectedDictionary["ChildName"]!)
    }
    @objc func BackAction(sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    deinit
    {
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    
    
    
    
    func LoadCollectionViewData(){
        if(NumberofCell > 10)
        {
            DivideColumn = 3
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
    // MARK: - CollectionView Delegates
    // MARK: COLLECTION VIEW DELEGATE
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        if deviceName == "iPhone 8" || deviceName == "iPhone" {
//            return CGSize(width: (self.CollectionViewGrid.frame.size.width/3) - 10, height: (self.CollectionViewGrid.frame.size.height/3) - 12)
//        }
//        else{
            return CGSize(width: (self.CollectionViewGrid.frame.size.width/3) - 10, height: 75)
//                            (self.CollectionViewGrid.frame.size.height/3) - 12)
//        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //
        return NumberofCell
        //        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        //
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ParentGridCVCell", for: indexPath) as! ParentGridCVCell
        cell.backgroundColor = UIColor.clear
        
        //        Numb
        cell.CellView.layer.borderWidth = 0.3
        cell.CellView.layer.cornerRadius = 3
        cell.CellView.clipsToBounds = true
        cell.CellView.layer.borderColor = UIColor.lightGray.cgColor
        cell.CellView.layer.shadowColor = UIColor.black.cgColor
        cell.CellView.layer.shadowOpacity = 1
        cell.CellView.layer.shadowOffset = CGSize.zero
        
        print("CellArrayIcon",CellIconsArray.count)
        if(CellIconsArray.count > indexPath.row) {
            if((UIImage(named: CellIconsArray[indexPath.row] as? String ?? "")) != nil) {
                print("Image existing1",CellIconsArray[indexPath.row])
                cell.iconHeight.constant = 35
                cell.iconWidth.constant = 35
                cell.cellIconTop1.constant = 10
                
                
                cell.CellIcon.image = UIImage(named: CellIconsArray[indexPath.row] as? String ?? "")
                
            }
            else {
//
             
            }
        }
        
        
        cell.CellLabel.text = CellLabelNameArray[indexPath.row] as? String ?? ""
        cell.UnreadMessageCountLabel.isHidden = true
        
        
        
        print("NameCellIndexIdsArra",CellIndexIdsArray[indexPath.row])
        
        if(self.CellIndexIdsArray[indexPath.row] as! String == "100"){
            if indexPath.row == 0 {
                print("Ripple1Ripple11111")
                cell.iconHeight.constant = 100
                cell.iconWidth.constant = 100
                
//                cell.CellIcon.contentMode = .scaleAspectFill
                cell.cellIconTop1.constant = -5
                cell.CellIcon.image = UIImage.gifImageWithName("Ripple1")
                cell.CellLabel.text = ""
                
                cell.UnreadMessageCountLabel.isHidden = true
            }
        } else{

            cell.iconHeight.constant = 35
            cell.iconWidth.constant = 35
            cell.cellIconTop1.constant = 10

        }
        print("UnreadCountArrayCountCell",UnreadCountArray)
        if(UnreadCountArray.count > 0)
        {
            if(UnreadCountArray.count > indexPath.row)
            {
                let unreadCount : String = UnreadCountArray[indexPath.row] as? String ?? ""
                print("unreadCount",unreadCount)
                if(unreadCount != "0")
                {
                    cell.UnreadMessageCountLabel.layer.cornerRadius = 0.5 * cell.UnreadMessageCountLabel.bounds.size.width
                    cell.UnreadMessageCountLabel.clipsToBounds = true
                    cell.UnreadMessageCountLabel.isHidden = false
                    cell.UnreadMessageCountLabel.text = unreadCount
                    
                    //
                    
                }else{
                    cell.UnreadMessageCountLabel.isHidden = true
                }
                
            }else{
                cell.UnreadMessageCountLabel.isHidden = true
            }
        }
        
        return cell
        //        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //
        
        
        
        
        
        let indexNumber = indexPath.row
        if(indexNumber == bookIndex)
        {
            
            if(strBookenabled == "1")
            {
                UIApplication.shared.openURL(URL(string: strBookURL)!)
                
            }else{
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: self.CellSegueArray[indexPath.row] as! String, sender: nil)
                    
                }
            }
        }
        
        else{
            
            
            print("menu_id11111",self.CellIndexIdsArray[indexPath.row])
            
            
            print("appDelegate.mainParentSegueArray",appDelegate.mainParentSegueArray.count)
            
            if(self.appDelegate.mainParentSegueArray[indexPath.row] == ""){
                print("IDGET",self.CellIndexIdsArray[indexPath.row])
                
                if(self.CellIndexIdsArray[indexPath.row] as! String == "23"){
                    //                    let vc = CertificateRequestViewController(nibName: nil, bundle: nil)
                    let vc = ClassTimeTableViewController(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }else if (self.CellIndexIdsArray[indexPath.row] as! String == "24"){
                    callEditProfile()
                }else if(self.CellIndexIdsArray[indexPath.row] as! String == "25"){
                    let vc = CertificateRequestViewController(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
//
                else if(self.CellIndexIdsArray[indexPath.row] as! String == "26"){
                    let vc = PTMViewController(nibName: nil, bundle: nil)
//                    vc.studentId =
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
                else if(self.CellIndexIdsArray[indexPath.row] as! String == "22"){
                    let vc = LsrwListShowViewController(nibName: nil, bundle: nil)
//                   
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }

                else if(self.CellIndexIdsArray[indexPath.row] as! String == "100"){
                    
                    
                    let vc = UpdateDetailViewController(nibName: nil, bundle: nil)
                    vc.memeberArrayString = memeberArrayString
                    vc.type = "parent"
                    vc.skipType = 2
                    vc.schoolArrayString  = schoolArrayString
                    vc.modalPresentationStyle = .formSheet
                    present(vc, animated: true)
                }
                
                
                else{
                    
                    Util .showAlert("", msg: "Coming Soon!!!")
                    
                }
                
            }
            
            else{
                
                self.performSegue(withIdentifier: self.appDelegate.mainParentSegueArray[indexPath.row] as! String, sender: nil)
                rowSelected = indexPath.row
                
                print("appDelegate.mainParentSegueArray[indexPath.row]",appDelegate.mainParentSegueArray[indexPath.row])
                
            }
            
            
            
            print("CellSegueArray.count",CellSegueArray.count)
            print("indexPath.row",indexPath.row)
            
            
            AdConstant.getMenuId = CellIndexIdsArray[indexPath.row] as! NSString
            //                    }
            print("AdConstantgetMenuId111", AdConstant.getMenuId)
            //                }
            
            
            //            }
        }
    }
    
    
    
    // MARK: - Button Action
    
    func actionAudioTableViewPopupBtn(sender : UIButton) {
        mystring = "VOICE"
        let buttonTag = sender.tag
        let dicSelect : NSDictionary = detailsArray.object(at: buttonTag) as! NSDictionary
        strSelectDate = dicSelect.object(forKey: "Date") as! String as NSString
        
        if(Util .isNetworkConnected())
        {
            CallDetailsApi(dicSelect.object(forKey: "Date") as! String, "VOICE")
        }
        else
        {
            Util .showAlert("", msg: strNoInternet)
        }
    }
    
    func actionTextTableViewPopupBtn(sender : UIButton) {
        mystring = "SMS"
        
        let buttonTag = sender.tag
        
        let dicSelect : NSDictionary = detailsArray.object(at: buttonTag) as! NSDictionary
        
        strSelectDate = dicSelect.object(forKey: "Date") as! String as NSString
        
        if(Util .isNetworkConnected())
        {
            CallDetailsApi(dicSelect.object(forKey: "Date") as! String, "SMS")
        }
        else
        {
            Util .showAlert("", msg: strNoInternet)
        }
        
    }
    
    func actionPdfTableviewPopupBtn(sender : UIButton) {
        mystring = "PDF"
        let buttonTag = sender.tag
        
        let dicSelect : NSDictionary = detailsArray.object(at: buttonTag) as! NSDictionary
        
        strSelectDate = dicSelect.object(forKey: "Date") as! String as NSString
        
        
        if(Util .isNetworkConnected())
        {
            CallDetailsApi(dicSelect.object(forKey: "Date") as! String, "PDF")
            
        }
        else
        {
            Util .showAlert("", msg: strNoInternet)
        }
        
    }
    
    
    func actionImageTableViewPopupBtn(sender : UIButton) {
        mystring = "IMAGE"
        let buttonTag = sender.tag
        
        let dicSelect : NSDictionary = detailsArray.object(at: buttonTag) as! NSDictionary
        
        strSelectDate = dicSelect.object(forKey: "Date") as! String as NSString
        
        if(Util .isNetworkConnected())
        {
            CallDetailsApi(dicSelect.object(forKey: "Date") as! String, "IMAGE")
        }
        else
        {
            Util .showAlert("", msg: strNoInternet)
        }
        
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
        changePasswordVC.strFromStaff = "Child"
        changePasswordVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(changePasswordVC, animated: true, completion: nil)
    }
    
    @IBAction func actionFAQ(_ sender: Any) {
        let faqVC  = self.storyboard?.instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
        faqVC.fromVC = "Parent"
        self.navigationController?.pushViewController(faqVC, animated: true)
    }
    
    @IBAction func actionTabLogout(_ sender: UIButton) {
        
        self.showPopover(sender, Titletext: "")
    }
    
    func callLogoutAction(){
        let changePasswordVC  = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordVC") as! ParentChangePasswordVC
        changePasswordVC.strFrom = "Logout"
        changePasswordVC.strFromStaff = "Child"
        UserDefaults.standard.removeObject(forKey: DefaultsKeys.getgroupHeadRole)
        self.navigationController?.pushViewController(changePasswordVC, animated: true)
    }
    
    
    //MARK: - Popover delegate  & Functions
    func showPopover(_ base: UIView, Titletext: String)
    {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DropDownVC") as? DropDownVC {
            
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .popover
            viewController.fromVC = "settings"
            
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
        print("SDetails")
        
        var selectString = notification.object as? String ?? ""
        selectString = selectString.lowercased()
        let log = languageDictionary["txt_menu_logout"] as? String ?? ""
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
        newViewController.instuteId = SchoolIDString
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func showLogoutAlert(){
        let alertController = UIAlertController(title: languageDictionary["txt_menu_logout"] as? String, message: languageDictionary["want_to_logut"] as? String, preferredStyle: .alert)
        
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
    // MARK: - Api Calling
    func CallDetailsApi(_ circularDate : String, _ type : String) {
        strApiFrom = "detailss"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + GETFILES
        print("123",requestStringer)
        let arrUserData : NSMutableArray = []
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["fn" : "GetFiles","ChildID": selectedDictionary.object(forKey: "ChildID") as Any,"SchoolID" : selectedDictionary.object(forKey: "SchoolID") as Any,"CircularDate" : circularDate,"Type" : type, COUNTRY_CODE: strCountryCode]
        
        arrUserData.add(myDict)
        let myString = Util.convertNSMutableArray(toString: arrUserData)
        
        
        apiCall.nsurlConnectionFunction(requestString, myString, strApiFrom as String?)
    }
    
    
    func CallChildDetailsApi() {
        strApiFrom = "details"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_MSG_CONT
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
        }
        let arrUserData : NSMutableArray = []
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["fn" : "GetMessageCount","ChildID": selectedDictionary.object(forKey: "ChildID") as Any,"SchoolID" : selectedDictionary.object(forKey: "SchoolID") as Any, COUNTRY_CODE: strCountryCode]
        
        arrUserData.add(myDict)
        
        let myString = Util.convertNSMutableArray(toString: arrUserData)
        apiCall.nsurlConnectionFunction(requestString, myString, "details")
    }
    func CallReadStatusUpdateApi(_ circularDate : String,_ ID : String, _ type : String) {
        strApiFrom = "detailssss"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + READ_STATUS_UPDATE
        
        let arrUserData : NSMutableArray = []
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        
        let myDict:NSMutableDictionary = ["fn" : "ReadStatusUpdate","ChildID": selectedDictionary.object(forKey: "ChildID") as Any,"SchoolID" : selectedDictionary.object(forKey: "SchoolID") as Any,"Date" : circularDate,"Type" : type,"ID" : ID, COUNTRY_CODE: strCountryCode]
        
        arrUserData.add(myDict)
        
        let myString = Util.convertNSMutableArray(toString: arrUserData)
        
        
        apiCall.nsurlConnectionFunction(requestString, myString, type)
    }
    
    func CallTotalUnReadCountApi() {
        strApiFrom = "unread"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        var requestStringer = baseReportUrlString! + UNREAD_MSG_COUNT
        
        
        print("appDelegateisPasswordBind",appDelegate.isPasswordBind)
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + UNREAD_MSG_COUNT
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        print("UNREADREQrequestString",requestString)
        
        let SchoolId = String(describing: selectedDictionary["SchoolID"]!)
        let ChildlId = String(describing: selectedDictionary["ChildID"]!)
        
        let myDict:NSMutableDictionary = ["SchoolID": SchoolId,"ChildID": ChildlId]
        //                                          , COUNTRY_CODE: strCountryCode]
        
        print("UNREADREQ",myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "unread")
    }
    // MARK: - Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        
        
        print("responestringstrApiFrom",strApiFrom)
        print("csDatacsData1",csData)
        if(csData != nil || csData?.count == 0)
        {
            if(strApiFrom == "unread")
            {
                
                
                UtilObj.printLogKey(printKey: "UNREADRES", printingValue: csData)
                if let checkArray = csData as? NSArray
                {
                    let Responsedict = checkArray[0] as! NSDictionary
                    if(Responsedict["EMERGENCYVOICE"] != nil){
                        strEmergencyVoiceCount = String(describing: Responsedict["EMERGENCYVOICE"]!)
                        print("strEmergencyVoiceCount",strEmergencyVoiceCount)
                        
                        strVoiceCount = String(describing: Responsedict["VOICE"]!)
                        
                        strSMSCount  = String(describing: Responsedict["SMS"]!)
                        
                        strNoticeCount = String(describing: Responsedict["NOTICEBOARD"]!)
                        
                        strEventCount  = String(describing: Responsedict["EVENTS"]!)
                        
                        strImageCount = String(describing: Responsedict["IMAGE"]!)
                        
                        strPDFCount  = String(describing: Responsedict["PDF"]!)
                        
                        strHomeworkCount  = String(describing: Responsedict["HOMEWORK"]!)
                        
                        strExamTestCount  = String(describing: Responsedict["EXAM"]!)
                        strExam_marks = String(describing: Responsedict["EXAMMARKS"]!)
                        strVideoCount  =  "0"
                        if(Responsedict["VIDEO"] != nil){
                            strVideoCount = String(describing: Responsedict["VIDEO"]!)
                        }
                        strAssignmentCount  =  "0"
                        if(Responsedict["ASSIGNMENT"] != nil){
                            strAssignmentCount = String(describing: Responsedict["ASSIGNMENT"]!)
                        }
                        strOnlineCount  =  "0"
                        if(Responsedict["ONLINECLASS"] != nil){
                            strOnlineCount = String(describing: Responsedict["ONLINECLASS"]!)
                        }
                        
                        let  notificationCountArray  : NSArray = ["0"+"_100",strEmergencyVoiceCount+"_0",strVoiceCount+"_1",strSMSCount+"_2",strHomeworkCount+"_3",strExamTestCount+"_4",strExam_marks+"_5",strPDFCount+"_6",strNoticeCount+"_7",strEventCount+"_8","0"+"_9","0"+"_10","0"+"_11",strImageCount+"_12","0"+"_13","0"+"_14","0"+"_15","0"+"_16","0"+"_17",strAssignmentCount+"_18",strVideoCount+"_19",strOnlineCount+"_20","0"+"_21","0"+"_22","0"+"_23","0"+"_24","0"+"_25"]
                        
                        var unreadArray : NSMutableArray = NSMutableArray()
                        print("parentIndexArray.count",parentIndexArray)
                        
                        unreadArray.add("0")
                        for i in 0..<parentIndexArray.count{
                            let index : NSString = String (describing:parentIndexArray[i]) as NSString
                            UtilObj.printLogKey(printKey: "index", printingValue: index)
                            UtilObj.printLogKey(printKey: "parentIndexArray", printingValue: parentIndexArray.count)
                            UtilObj.printLogKey(printKey: "notificationCountArray", printingValue: notificationCountArray.count)
                            
                            for j in 0..<notificationCountArray.count{
                                
                                var value : String!
                                
                                value  = notificationCountArray[j] as! String
                                let result = value.split(separator: "_")
                                
                                
                                if(index as String == result[1]){
                                    print("result[1]",result[1])
                                    print("index[1]",index)
                                    
                                    unreadArray.add(result[0])
                                    
                                    
                                }
                                
                            }
                            
                            
                            
                        }
                        
                        
                        UnreadCountArray = unreadArray
                        
                        
                        UtilObj.printLogKey(printKey: "UnreadCountArray", printingValue: UnreadCountArray)
                        UserDefaults.standard.set(UnreadCountArray, forKey: "UNREADCOUNT")
                        CollectionViewGrid.reloadData()
                    }
                }
            }
            else if(strApiFrom.isEqual(to: "changeLang")){
                print("strApiFromcsData")
                guard let responseArray = csData else {
                    return
                }
                print("NEWLANGUAGE \(responseArray)")
                for  i in 0..<responseArray.count
                {
                    let  dicResponse = responseArray[i] as! NSDictionary
                    if(dicResponse["Status"] != nil){
                        let myalertstatus = String(describing: dicResponse["Status"]!)
                        if(myalertstatus == "1"){
                            assignParentStaffIDS(selectedDict: dicResponse)
                            print("dicResponseAPI",dicResponse)
                        }
                    }
                    
                }
                
                self.loadCellArrayData()
                
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
    
    
    
    
    
    func showAlertInView(message: NSString) -> Void {
        let alertView = UIAlertController(title: "", message: message as String, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            
        })
        alertView.addAction(action)
        self.present(alertView, animated: true, completion: nil)
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
                    //
                    self.loadCellArrayData()
                }
            } catch {
                //
                self.loadCellArrayData()
            }
        }
    }
    func memberArray(){
        
        
        
        print("appDelegateLoginParentDetailArray",appDelegate.LoginParentDetailArray)
        print("appDelegateselectedDictionary",selectedDictionary)
        
        var idArray : NSMutableArray = NSMutableArray()
        var schoolIdArray : NSMutableArray = NSMutableArray()
        for i in 0..<appDelegate.LoginParentDetailArray.count{
            let Dict : NSDictionary =  appDelegate.LoginParentDetailArray[i] as! NSDictionary
            idArray.add(String(describing: Dict["ChildID"]!))
            schoolIdArray.add(String(describing: Dict["SchoolID"]!))
            let dicMembers = ["type" : "parent",
                              "id" : String(describing: Dict["ChildID"]!),
                              "schoolid" : String(describing: Dict["SchoolID"]!)
            ]
            
            arrMembersData.add(dicMembers)
            
            
        }
        for i in 0..<appDelegate.LoginSchoolDetailArray.count{
            let Dict : NSDictionary =  appDelegate.LoginSchoolDetailArray[i] as! NSDictionary
            idArray.add(String(describing: Dict["StaffID"]!))
            let dicMembers = ["type" : "staff",
                              "id" : String(describing: Dict["StaffID"]!),
                              "schoolid" : String(describing: Dict["SchoolID"]!)
            ]
            
            arrMembersData.add(dicMembers)
        }
        
        memeberArrayString = idArray.componentsJoined(by: "~")
        schoolArrayString = schoolIdArray.componentsJoined(by: "~")
        print("schoolArrayString1",schoolArrayString)
        print(memeberArrayString)
        
        
    }
    func CallLanguageChangeApi(){
        memberArray()
        strApiFrom = "changeLang"
        let apiCall = API_call.init()
        apiCall.delegate = self
        let baseUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_LANGUAGE_CHANGE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        print("StudentDetailViewControllerrequestStringer",requestStringer)
        if(appDelegate.isPasswordBind == "1"){
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        
        
        
        print("ChildId12345678",ChildId)

        
        let dicMembers = ["type" : "parent",
                          "id" : ChildId,
                          "schoolid" : SchoolIDString
        ]
        
        newArrMembersData.add(dicMembers)
        
        let myMemberData:[String: Any] = ["type" : "parent","id": ChildId,"schoolid" : SchoolIDString]
        
        print("newArrMembersData",newArrMembersData)
        
        let myDict:NSMutableDictionary = ["MemberData" : newArrMembersData,"LanguageId": "1",COUNTRY_ID : strCountryCode]
        
        
        print("StudentDetailViewControllermyDict",myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        print(requestString)
        
        print(myString)
        
        Constants.printLogKey("myDict", printValue: myDict)
        Constants.printLogKey("requestStringer", printValue: requestStringer)
        apiCall.nsurlConnectionFunction(requestString, myString, "deviceToken")
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDictionary = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.SchoolSubView.semanticContentAttribute = .forceRightToLeft
            self.CollectionViewGrid.semanticContentAttribute = .forceRightToLeft
            self.BottomView.semanticContentAttribute = .forceRightToLeft
            self.SchoolNameLabel.textAlignment = .right
            self.SchoolLocationLabel.textAlignment = .right
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.SchoolSubView.semanticContentAttribute = .forceLeftToRight
            self.CollectionViewGrid.semanticContentAttribute = .forceLeftToRight
            self.BottomView.semanticContentAttribute = .forceLeftToRight
            self.SchoolNameLabel.textAlignment = .left
            self.SchoolLocationLabel.textAlignment = .left
            
        }
        HomeLabel.text = LangDict["home"] as? String
        FAQLabel.text = LangDict["faq"] as? String
        PasswordLabel.text = LangDict["txt_password"] as? String
        LogoutLabel.text = LangDict["txt_menu_setting"] as? String
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        //
        self.loadCellArrayData()
    }
    
    func loadCellArrayData(){
        //
        
        
        
        strBookenabled  = String(describing: selectedDictionary["isBooksEnabled"]!)
        strBookURL = String(describing: selectedDictionary["OnlineBooksLink"]!)
        //        var addInNToDelArray =
        var childIndexArray : NSArray = UserDefaults.standard.object(forKey: PARENT_ARRAY_INDEX) as! NSArray
        //
        Constants.printLogKey("childIndexArray", printValue: childIndexArray)
        Constants.printLogKey("strBookenabled", printValue: strBookenabled)
        if(strBookenabled != "1")
        {
            let arryMut : NSMutableArray = NSMutableArray(array: childIndexArray)
            arryMut.remove("15")
            childIndexArray = arryMut as NSArray
            print("arryMutchildIndexArray",childIndexArray)
        }
        Constants.printLogKey("childIndexArray", printValue: childIndexArray)
        
        CellLabelNameArray.removeAllObjects()
        CellIconsArray.removeAllObjects()
        CellSegueArray.removeAllObjects()
        
        
        var parentLabelArray : NSArray = UserDefaults.standard.object(forKey: "PARENT_ARRAY_MENUNAMES") as? NSArray ?? []
        
        
//         Menus Add pananum apdina
         let arryMut : NSMutableArray = NSMutableArray(array: parentLabelArray)

         parentLabelArray =  arryMut as NSArray
         
        
        //        QuestionData.count + 1
        print("QuestionData1.count",QuestionData.count)
        if QuestionData.count > 0 {
            let arryMut : NSMutableArray = NSMutableArray(array: parentLabelArray)
            print("beforeadd",arryMut)
            arryMut.insert("MainToSchoolSelectionSegue_100" , at: 0)
            print("afteradd",arryMut)
            parentLabelArray =  arryMut as NSArray
//            arryMut.add("PTM_26")
            print("afteraddchildIndexArray",parentLabelArray)
            Constants.printLogKey("parentLabelArray", printValue: parentLabelArray)
            print("afteraddchildIndexArray",childIndexArray)
        }
        //        childIndexArray = parentLabelArray
        print("parentLabelArraparentLabelArrayy",parentLabelArray)
        for i in 0..<childIndexArray.count{
            let index : NSString = String(describing: childIndexArray[i]) as NSString
            
            if(index.integerValue == 15){
                bookIndex = i
            }
            
            
            if appDelegate.mainParentIconArray.count > index.integerValue {
                
                CellSegueArray.add(appDelegate.mainParentSegueArray[index.integerValue])
            }
            
        }
        
        //        print("parent",parentLabelArray.count)
        //        parentLabelArray.addingObjects(from: ["MainToSchoolSelectionSegue_00"])
        //        addObject(["MainToSchoolSelectionSegue_00"])
        print("parentLabelArrayparentLabelArray",parentLabelArray)
        print("CountchildIndexArray",childIndexArray.count)
        print("parentLabelArrayCount",parentLabelArray)
        CellIndexIdsArray.removeAllObjects()
        CellLabelNameArray.removeAllObjects()
        CellIconsArray.removeAllObjects()
        appDelegate.mainParentSegueArray.removeAll()
        appDelegate.mainParentIconArray.removeAll()
        
        for idd in 0..<parentLabelArray.count {
            print("parentLabelArray.count",parentLabelArray.count)
            
            
            let strtite = parentLabelArray[idd] as? String ?? ""
            print("MEnu \(strtite) Index : \(idd)")
            var result = strtite.split(separator: "_")
            if(result.count > 0){
                //Name Get panranga
                print("MEnu \(result[0]) Index : \(idd)")
                print("MenuIds \(idd)")
                var imageName = "\(String(result[1]))"
                print("imageName1 \(imageName)")
                if(imageName != "15"){
                    imageName = "s\(imageName)"
                    CellIndexIdsArray.add(String(result[1]))
                    
                    // name ah array la store pannranga
                    CellLabelNameArray.add(String(result[0]))
                    
                    print("CellLabelNameArray.courtt",CellLabelNameArray)
                    print("CellIndexIdsArray.courtt",CellIndexIdsArray)
                    
                    
                    if(result[1] == "100"){
                        print("RippleCond",imageName)
                        
                        CellIconsArray.add(imageName)
                        appDelegate.mainParentIconArray.append("")
                        appDelegate.mainParentSegueArray.append("")
                        
                    }
                    
                    else if(result[1] == "0"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("emergency")
                        appDelegate.mainParentSegueArray.append("EmergencyVCSeg")
                    }
                    
                    else if(result[1] == "1"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("GeneralVoice")
                        appDelegate.mainParentSegueArray.append("VoiceVCSeg")
                        
                    } else if(result[1] == "2"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("text")
                        appDelegate.mainParentSegueArray.append("ParentTextMessageSegue")
                    }
                    
                    else if(result[1] == "3"){
                        CellIconsArray.add(imageName)
                        
                        
                        
                        appDelegate.mainParentIconArray.append("HomeWork")
                        appDelegate.mainParentSegueArray.append("ParentHomeworkSegue")
                        
                    }  else if(result[1] == "4"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("exam")
                        appDelegate.mainParentSegueArray.append("ParentExamTestSegue")
                        
                    } else if(result[1] == "5"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("ExamMark")
                        appDelegate.mainParentSegueArray.append("ExamMarkSegue")
                    }
                    
                    else if(result[1] == "6"){
                        CellIconsArray.add(imageName)
                        
                        
                        
                        appDelegate.mainParentIconArray.append("Documents")
                        appDelegate.mainParentSegueArray.append("PdfVCSeg")
                        
                    }else if(result[1] == "7"){
                        CellIconsArray.add(imageName)
                        
                        
                        
                        appDelegate.mainParentIconArray.append("notice")
                        appDelegate.mainParentSegueArray.append("NoticeSegue")
                    }
                    
                    else if(result[1] == "8"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("events")
                        appDelegate.mainParentSegueArray.append("EventSegue")
                        
                    }  else if(result[1] == "9"){
                        CellIconsArray.add(imageName)
                        
                        
                        
                        appDelegate.mainParentIconArray.append("absentees")
                        appDelegate.mainParentSegueArray.append("AttendanceVCSegue")
                        
                    } else if(result[1] == "10"){
                        CellIconsArray.add(imageName)
                        
                        appDelegate.mainParentIconArray.append("school_strength")
                        appDelegate.mainParentSegueArray.append("LeaveRequestSegue")
                    }
                    
                    else if(result[1] == "11"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("PayfeeIcon")
                        appDelegate.mainParentSegueArray.append("PayFeeSegue")
                        
                    }
                    else if(result[1] == "12"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("photos")
                        appDelegate.mainParentSegueArray.append("ImgTVCSeg")
                        
                    }
                    
                    else if(result[1] == "13"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("Library")
                        appDelegate.mainParentSegueArray.append("ParentLibrarySegue")
                        
                    }
                    
                    else if(result[1] == "14"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("StaffDetail")
                        appDelegate.mainParentSegueArray.append("StaffDetailSegue")
                    }
                    
                    
                    
                    else if(result[1] == "18"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("assignment")
                        appDelegate.mainParentSegueArray.append("AssignmentListSegue")
                        
                    }
                    
                    else if(result[1] == "19"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("VimeoVideo")
                        appDelegate.mainParentSegueArray.append("VideoMenuSegue")
                        
                    }
                    
                    else if(result[1] == "20"){
                        CellIconsArray.add(imageName)
                        
                        appDelegate.mainParentIconArray.append("onlineclass")
                        appDelegate.mainParentSegueArray.append("OnlineViewSeg")
                        
                    }
                    
                    else if(result[1] == "21"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("idea")
                        appDelegate.mainParentSegueArray.append("")
                        
                        
                    }
                    
                    else if(result[1] == "22"){
                        CellIconsArray.add(imageName)
                        
                        
                        appDelegate.mainParentIconArray.append("SmallIcon")
                        appDelegate.mainParentSegueArray.append("")
                        
                        
                    }
                    
                    else if(result[1] == "23"){
                        CellIconsArray.add(imageName)
                        
                        appDelegate.mainParentIconArray.append("time_table")
                        appDelegate.mainParentSegueArray.append("")
                        
                        
                    }
                    
                    else if(result[1] == "24"){
                        
                        CellIconsArray.add(imageName)
                        appDelegate.mainParentSegueArray.append("")
                    }
                    else if(result[1] == "25"){
                        print("Result25")
                        CellIconsArray.add(imageName)
                        appDelegate.mainParentIconArray.append("certification")
                        appDelegate.mainParentSegueArray.append("")
                        
                    } else if(result[1] == "26"){
                        print("Result25")
                        CellIconsArray.add(imageName)
                        appDelegate.mainParentIconArray.append("PTM")
                        appDelegate.mainParentSegueArray.append("")

                    }

                    else{
                        appDelegate.mainParentSegueArray.append("")
                        CellIconsArray.add("SmallIcon")
                        
                    }
                    
                }
                
            }else{
                
                CellLabelNameArray.add(strtite)
                CellIconsArray.add(strtite)
            }
            
        }
        
        
        print("AfterLoop",CellIconsArray.count)
        print("AfterLoopCoiu",CellIconsArray)
        
        print("AfterCEllCellLabelNameArray",CellLabelNameArray.count)
        print("AfterCellIndexIdsArray",CellIndexIdsArray.count)
        
        LoadCollectionViewData()
        
        print("appDelegate.mainParentSegueArray",appDelegate.mainParentSegueArray.count)
        print("appDelegateDATA",appDelegate.mainParentSegueArray)
        if(UIDevice.current.userInterfaceIdiom == .pad){
            self.SchoolViewHeight.constant = 120
            self.CollectionViewTopHeight.constant = 20
        }else{
            self.SchoolViewHeight.constant = 90
            if(self.view.frame.height > 600){
                self.CollectionViewTopHeight.constant = 10
                
            }else{
                self.CollectionViewTopHeight.constant = 0
                
            }
        }
        
        
        NumberofCell = CellLabelNameArray.count
        parentIndexArray = childIndexArray as NSArray
        setTopViewInitial()
        
        setInitialViews()
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
