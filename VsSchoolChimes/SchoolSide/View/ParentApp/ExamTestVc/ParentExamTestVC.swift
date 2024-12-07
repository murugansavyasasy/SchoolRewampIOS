//
//  ExamTestVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 01/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper


class ParentExamTestVC: UIViewController, UITableViewDataSource,UITableViewDelegate,Apidelegate,UISearchBarDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate,UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var SectionHeaderView: UIView!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var SectionHeaderButton: UIButton!
    @IBOutlet weak var ExamSyllabusLabel: UILabel!
    @IBOutlet weak var ExamNameLabel: UILabel!
    @IBOutlet weak var ExamTestTable: UITableView!
    @IBOutlet weak var LogoutLabel: UILabel!
    @IBOutlet weak var FAQLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var selectedDictionary = [String: Any]() as NSDictionary
    var SelectedTextDict = [String: Any]() as NSDictionary
    var languageDictionary = NSDictionary()
    var DetailTextArray: NSMutableArray = NSMutableArray()
    var MainDetailTextArray: NSMutableArray = NSMutableArray()
    var SelectedSectionArray : NSMutableArray = NSMutableArray()
    var arrayCellData: NSArray = []
    var strApiFrom = NSString()
    var ChildId = String()
    var SchoolId = String()
    var strLanguage = String()
    var Screenheight = CFloat()
    var hud : MBProgressHUD = MBProgressHUD()
    var gestureRecognizer = UITapGestureRecognizer()
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var strCountryCode = String()
    var strExamName = String()
    var strSyllabus = String()
    var strSubject = String()
    var strDate = String()
    var strMark = String()
    var strSession = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    
    var getadID : Int!
    weak var timer: Timer?
    
    var menuId : String!
    
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    @IBOutlet weak var AdView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ParentExamTestVC")
        
        ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        ExamTestTable.reloadData()
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer()
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(ParentExamTestVC.LoadSelectedLanguageData), name: NSNotification.Name(rawValue: LANGUAGE_NOTIFICATION), object:nil)
        nc.addObserver(self,selector: #selector(ParentExamTestVC.UpdateLogoutSelection), name: NSNotification.Name(rawValue: "SettingNotification"), object:nil)
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        
        self.callSelectedLanguage()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    // MARK:- Button Action
    @IBAction func actionBack(_ sender: UIButton){
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBack"), object: nil)
        self.dismiss(animated: true, completion: nil)
        
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
        self.navigationController?.pushViewController(changePasswordVC, animated: true)
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
        print("ParentExam")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() )
        {
            self.showLogoutAlert()
        }
        
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
    
    // MARK: - TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        print(DetailTextArray.count)
        return DetailTextArray.count
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        let Sectiondict:NSDictionary = DetailTextArray[section] as! NSDictionary
        arrayCellData = Sectiondict["SubjectDetails"] as! NSArray
        return arrayCellData.count
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        let ExamLabel = UILabel()
        let ExamNameLabel = UILabel()
        let SyllabusLabel = UILabel()
        let ExamSyllabusLabel = UILabel()
        let ExamImageView = UIImageView()
        let DropDownImage = UIImageView()
        let SectionTapButton = UIButton()
        let Sectiondict:NSDictionary = DetailTextArray[section] as! NSDictionary
        
        let DescriptionText:String = String(describing: Sectiondict["ExaminationName"]!)
        let DescriptionText1:String = String(describing: Sectiondict["ExaminationSyllabus"]!)
        let ExamName : String = Util .checkNil(DescriptionText)
        let Stringlength : Int = ExamName.count
        let ExamSyllabus : String = Util .checkNil(DescriptionText1)
        let Stringlength1 : Int = ExamSyllabus.count
        
        ExamSyllabusLabel.numberOfLines = 0
        ExamNameLabel.numberOfLines = 0
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            let MuValue : Int = Stringlength/28
            let MuValue1 : Int = Stringlength1/28
            let headerViewheight : Int = Int(144  + ( 25 * CGFloat(MuValue)) + ( 25 * CGFloat(MuValue1)))
            
            let centerheight : Int = headerViewheight/2 - 15
            
            
            headerView.frame = CGRect(x:0, y: 0, width:
                                        tableView.bounds.size.width, height: CGFloat(headerViewheight))
            SectionTapButton.frame = CGRect(x:0, y: 0, width:
                                                tableView.bounds.size.width, height: CGFloat(headerViewheight))
            ExamLabel.frame = CGRect(x:15, y:10, width:
                                        tableView.bounds.size.width, height: 30)
            
            ExamNameLabel.frame = CGRect(x:15, y: 40, width:
                                            tableView.bounds.size.width - 40, height: (30 + 25 * CGFloat(MuValue)))
            
            let SyllabusYAxis : Int = Int(44 + (30 + 25 * CGFloat(MuValue)))
            
            SyllabusLabel.frame = CGRect(x:15, y: CGFloat(SyllabusYAxis), width:
                                            tableView.bounds.size.width, height: 30)
            
            ExamSyllabusLabel.frame = CGRect(x:15 , y: CGFloat(SyllabusYAxis + 30), width:
                                                tableView.bounds.size.width - 40, height: (30 + 25 * CGFloat(MuValue1)))
            ExamImageView.frame = CGRect(x:0, y: CGFloat(headerViewheight - 1) , width:
                                            tableView.bounds.size.width, height: 1)
            if(strLanguage == "ar"){
                DropDownImage.frame = CGRect(x:30, y: CGFloat(centerheight), width:
                                                30, height: 30)
            }else{
                DropDownImage.frame = CGRect(x:tableView.bounds.size.width -  30, y: CGFloat(centerheight), width:
                                                30, height: 30)
            }
            
            ExamSyllabusLabel.font = UIFont(name: "Arial", size: 24)
            ExamNameLabel.font = UIFont(name: "Arial", size: 24)
            ExamLabel.font = UIFont(name: "Arial", size: 24)
            SyllabusLabel.font = UIFont(name: "Arial", size: 24)
        }
        else
        {
            var  examValue : Int = 0
            var  syllabusValue : Int = 0
            var  centerheight : Int = 0
            var  headerViewheight : Int = 0
            if(Screenheight > 580)
            {
                let MuValue : Int = Stringlength/38
                
                let MuValue1 : Int = Stringlength1/38
                examValue = MuValue
                syllabusValue = MuValue1
                headerViewheight = Int(124  + ( 18 * CGFloat(MuValue)) + ( 18 * CGFloat(MuValue1)))
                centerheight = headerViewheight/2 - 10
                
            }else{
                let MuValue : Int = Stringlength/28
                let MuValue1 : Int = Stringlength1/28
                examValue = MuValue
                syllabusValue = MuValue1
                headerViewheight = Int(124  + ( 18 * CGFloat(MuValue)) + ( 18 * CGFloat(MuValue1)))
                centerheight = headerViewheight/2 - 10
            }
            
            headerView.frame = CGRect(x:0, y: 0, width:
                                        tableView.bounds.size.width, height: CGFloat(headerViewheight))
            SectionTapButton.frame = CGRect(x:0, y: 0, width:
                                                tableView.bounds.size.width, height: CGFloat(headerViewheight))
            ExamLabel.frame = CGRect(x:6, y:10, width:
                                        tableView.bounds.size.width, height: 25)
            
            ExamNameLabel.frame = CGRect(x:6, y: 35, width:
                                            tableView.bounds.size.width - 30, height: (25 + 18 * CGFloat(examValue)))
            
            let SyllabusYAxis : Int = Int(39 + (25 + 18 * CGFloat(examValue)))
            
            SyllabusLabel.frame = CGRect(x:6, y: CGFloat(SyllabusYAxis), width:
                                            tableView.bounds.size.width, height: 25)
            ExamSyllabusLabel.frame = CGRect(x:6 , y: CGFloat(SyllabusYAxis + 25), width:
                                                tableView.bounds.size.width - 30, height: (25 + 18 * CGFloat(syllabusValue)))
            ExamImageView.frame = CGRect(x:0, y: CGFloat(headerViewheight - 1), width:
                                            tableView.bounds.size.width, height: 1)
            if(strLanguage == "ar"){
                DropDownImage.frame = CGRect(x:20, y: CGFloat(centerheight), width:
                                                20, height: 20)
            }else{
                DropDownImage.frame = CGRect(x:tableView.bounds.size.width -  20, y: CGFloat(centerheight), width:
                                                20, height: 20)
            }
            
            ExamSyllabusLabel.font = UIFont(name: "Arial", size: 17)
            ExamNameLabel.font = UIFont(name: "Arial", size: 17)
            ExamLabel.font = UIFont(name: "Arial", size: 17)
            SyllabusLabel.font = UIFont(name: "Arial", size: 17)
            
            
        }
        
        ExamImageView.backgroundColor = UIColor(red: 154.0/255.0 , green: 154.0/255.0 , blue: 154.0/255.0 , alpha: 0.5)
        SyllabusLabel.textColor = UIColor.black
        ExamLabel.textColor = UIColor.black
        ExamSyllabusLabel.textColor = UIColor.darkGray
        ExamNameLabel.textColor = UIColor.darkGray
        
        if(SelectedSectionArray.contains(Sectiondict))
        {
            DropDownImage.image = UIImage(named: "downArrow")
        }else{
            DropDownImage.image = UIImage(named: "arrow")
        }
        ExamNameLabel.text = String(describing: Sectiondict["ExaminationName"]!)
        ExamSyllabusLabel.text = String(describing: Sectiondict["ExaminationSyllabus"]!)
        SyllabusLabel.text = strSyllabus
        ExamLabel.text = strExamName
        SectionTapButton.addTarget(self, action: #selector(SectionButtontapped(sender:)), for: .touchUpInside)
        SectionTapButton.tag = section
        headerView.addSubview(ExamLabel)
        headerView.addSubview(ExamNameLabel)
        headerView.addSubview(SyllabusLabel)
        headerView.addSubview(ExamSyllabusLabel)
        headerView.addSubview(ExamImageView)
        headerView.addSubview(DropDownImage)
        headerView.addSubview(SectionTapButton)
        if(strLanguage == "ar"){
            headerView.semanticContentAttribute = .forceRightToLeft
            DropDownImage.semanticContentAttribute = .forceRightToLeft
            
        }else{
            headerView.semanticContentAttribute = .forceLeftToRight
            DropDownImage.semanticContentAttribute = .forceLeftToRight
        }
        
        return headerView
    }
    
    
    @objc func SectionButtontapped(sender: UIButton)
    {
        noDataLabel.isHidden = true
        
        searchBar.resignFirstResponder()
        let SelectedSectionIndex = sender.tag
        let Sectiondict:NSDictionary = DetailTextArray[SelectedSectionIndex] as! NSDictionary
        
        
        if(SelectedSectionArray.contains(Sectiondict))
        {
            SelectedSectionArray.remove(Sectiondict)
        }
        else{
            SelectedSectionArray.removeAllObjects()
            SelectedSectionArray.add(Sectiondict)
        }
        
        ExamTestTable.reloadData()
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let Sectiondict:NSDictionary = DetailTextArray[section] as! NSDictionary
        
        let DescriptionText:String = String(describing: Sectiondict["ExaminationName"]!)
        let DescriptionText1:String = String(describing: Sectiondict["ExaminationSyllabus"]!)
        let ExamName : String = Util .checkNil(DescriptionText)
        let Stringlength : Int = ExamName.count
        let ExamSyllabus : String = Util .checkNil(DescriptionText1)
        let Stringlength1 : Int = ExamSyllabus.count
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            let MuValue : Int = Stringlength/28
            let MuValue1 : Int = Stringlength1/28
            let headerViewheight : Int = Int(144  + ( 25 * CGFloat(MuValue)) + ( 25 * CGFloat(MuValue1)))
            return CGFloat(headerViewheight)
        }else
        {
            
            
            var  headerViewheight : Int = 0
            if(Screenheight > 580)
            {
                let MuValue : Int = Stringlength/38
                let MuValue1 : Int = Stringlength1/38
                headerViewheight = Int(124  + ( 18 * CGFloat(MuValue)) + ( 18 * CGFloat(MuValue1)))
                return CGFloat(headerViewheight)
                
            }else{
                let MuValue : Int = Stringlength/28
                let MuValue1 : Int = Stringlength1/28
                headerViewheight = Int(124  + ( 18 * CGFloat(MuValue)) + ( 18 * CGFloat(MuValue1)))
                return CGFloat(headerViewheight)
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let Sectiondict:NSDictionary = DetailTextArray[indexPath.section] as! NSDictionary
        var Height : CFloat
        
        if(SelectedSectionArray.contains(Sectiondict))
        {
            
            print("ifif")
            Height = CFloat(UITableView.automaticDimension)
        }else{
            Height = 0
        }
        return CGFloat(Height)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        noDataLabel.isHidden = true
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "NewParentExamTestTVCell", for: indexPath) as! NewParentExamTestTVCell
        cell1.backgroundColor = UIColor.clear
        let Sectiondict:NSDictionary = DetailTextArray[indexPath.section] as! NSDictionary
        arrayCellData = Sectiondict["SubjectDetails"] as! NSArray
        let dict:NSDictionary = arrayCellData[indexPath.row] as! NSDictionary
        cell1.DateLabel.text = String(describing: dict["ExamDate"]!)
        cell1.SubjectLabel.text = String(describing: dict["Subname"]!)
        cell1.MarkLabel.text = String(describing: dict["maxMark"]!)
        cell1.SessionLabel.text = String(describing: dict["ExamSession"]!)
        cell1.FloatDateLabel.text = strDate
        cell1.FloatSubjectLabel.text = strSubject
        cell1.FloatMarkLabel.text = strMark
        cell1.FloatSessionLabel.text = strSession
        
        cell1.SyllabusLabel.text = dict["Syllabus"] == nil ? "" : String(describing: dict["Syllabus"]!)
        
        
        if(strLanguage == "ar"){
            cell1.SubjectLabel.textAlignment = .right
            cell1.MarkLabel.textAlignment = .left
            cell1.FloatSubjectLabel.textAlignment = .right
            cell1.FloatMarkLabel.textAlignment = .left
            cell1.DateLabel.textAlignment = .right
            cell1.SessionLabel.textAlignment = .left
            cell1.FloatDateLabel.textAlignment = .right
            cell1.FloatSessionLabel.textAlignment = .left
            cell1.SyllabusLabel.textAlignment = .right
            cell1.FloatSyllabusLabel.textAlignment = .right
            
            cell1.CellView.semanticContentAttribute = .forceRightToLeft
            
        }else{
            cell1.SubjectLabel.textAlignment = .left
            cell1.MarkLabel.textAlignment = .right
            cell1.FloatSubjectLabel.textAlignment = .left
            cell1.FloatMarkLabel.textAlignment = .right
            cell1.DateLabel.textAlignment = .left
            cell1.SessionLabel.textAlignment = .right
            cell1.FloatDateLabel.textAlignment = .left
            cell1.FloatSessionLabel.textAlignment = .right
            cell1.FloatSessionLabel.textAlignment = .right
            cell1.SyllabusLabel.textAlignment = .left
            cell1.FloatSyllabusLabel.textAlignment = .left
            
            cell1.CellView.semanticContentAttribute = .forceLeftToRight
        }
        
        return cell1
        
    }
    
    
    // MARK:- Api Calling
    func CallDetailExamTestMessageApi() {
        showLoading()
        strApiFrom = "CallDetailExamTestMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + EXAM_TEST_MESSAGE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + EXAM_TEST_MESSAGE
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        
        print("EXAMTESTTTT",requestString)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailExamTestMessage")
    }
    func CallReadStatusUpdateApi(_ circularDate : String,_ ID : String, _ type : String) {
        showLoading()
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
    
    // MARK: - Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        
        hideLoading()
        if(csData != nil)
        {
            utilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if(strApiFrom == "CallDetailExamTestMessage")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    MainDetailTextArray.removeAllObjects()
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["ExamId"]!)
                        let Message = String(describing: dict["ExaminationName"]!)
                        if(Status != "-1")
                        {
                            MainDetailTextArray.add(dict)
                            let arrayCellData :NSArray = dict["SubjectDetails"]
                            as! NSArray
                            let strExamID = String(describing: dict["ExamId"]!)
                            
                            Childrens.saveExamTestSectionDetail(arrayCellData as! [Any], ChildId, strExamID)
                            
                        }else{
                            AlertMessage(alrString: Message)
                            
                        }
                    }
                    DetailTextArray = MainDetailTextArray
                    Childrens.saveExamTestDetail(DetailTextArray as! [Any], ChildId)
                    utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                    ExamTestTable.reloadData()
                    
                    
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
        Util .showAlert("", msg: strSomething);
        
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(SelectedTextDict)
        
        if (segue.identifier == "ExamTestDetailSegue"){
            let segueid = segue.destination as! HomeWorkTextDetailVC
            
            segueid.selectedDictionary = SelectedTextDict
            segueid.SenderType = "ExamTest"
            
        }
    }
    
    func AlertMessage(alrString:String){
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: alrString, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.navigationController?.popViewController(animated: true)
            
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func navTitle(){
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        titleLabel.textColor = UIColor (red:0.0/255.0, green:183.0/255.0, blue: 190.0/255.0, alpha: 1)
        let secondWord  : String =  languageDictionary["exam_test"] as? String ?? "Exam Test"
        let thirdWord  : String =  languageDictionary["circulars"] as? String ?? "Circulars"
        let comboWord = secondWord + " " + thirdWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.white]
        let range = NSString(string: comboWord).range(of: secondWord)
        attributedText.addAttributes(attrs, range: range)
        titleLabel.attributedText = attributedText
        self.navigationItem.titleView = titleLabel
    }
    
    // MARK: - Table view header
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String){
        SelectedSectionArray.removeAllObjects()
        if textSearched.count == 0{
            DetailTextArray = MainDetailTextArray
            self.ExamTestTable.reloadData()
        }else{
            let resultPredicate = NSPredicate(format: "ExaminationName CONTAINS [c] %@ OR ExaminationSyllabus CONTAINS [c] %@ ", textSearched, textSearched)
            let arrSearchResults = MainDetailTextArray.filter { resultPredicate.evaluate(with: $0) } as NSArray
            DetailTextArray = NSMutableArray(array: arrSearchResults)
            if(DetailTextArray.count > 0){
                noDataLabel.isHidden = true
            }else{
                noDataLabel.isHidden = false
            }
            self.ExamTestTable.reloadData()
        }
        self.ExamTestTable.reloadData()
        gestureRecognizer.isEnabled = true
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        SelectedSectionArray.removeAllObjects()
        DetailTextArray = MainDetailTextArray
        self.ExamTestTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
    
    
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        gestureRecognizer.isEnabled = true
        return true
    }
    
    func SearchTap(_ gestureRecognizer: UIGestureRecognizer){
        searchBar.resignFirstResponder()
        gestureRecognizer.isEnabled = false
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
            self.ExamTestTable.semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            self.BottomView.semanticContentAttribute = .forceRightToLeft
            // self.searchBar.makeTextWritingDirectionRightToLeft(AnyClass.self)
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.ExamTestTable.semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            self.BottomView.semanticContentAttribute = .forceLeftToRight
            // self.searchBar.makeTextWritingDirectionLeftToRight(AnyClass.self)
        }
        HomeLabel.text = LangDict["home"] as? String
        //        LanguageLabel.text = LangDict["txt_language"] as? String
        FAQLabel.text = LangDict["faq"] as? String
        PasswordLabel.text = LangDict["txt_password"] as? String
        LogoutLabel.text = LangDict["txt_menu_setting"] as? String
        searchBar.placeholder = LangDict["search_exams"] as? String
        
        strExamName = LangDict["teacher_txt_exam_title"] as? String ?? "Exam Name"
        strSyllabus = LangDict["teacher_txt_exam_typemsg"] as? String ?? "Exam Syllabus"
        strSubject = LangDict["subject_title"] as? String ?? "Subject :"
        strMark = LangDict["max_mark"] as? String ?? "Date :"
        strDate = LangDict["subject_date"] as? String ?? "Max Mark :"
        strSession = LangDict["subject_session"] as? String ?? "Session :"
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
        
    }
    
    func loadViewData(){
        navTitle()
        noDataLabel.isHidden = true
        noDataLabel.text = strNoRecordAlert
        searchBar.resignFirstResponder()
        searchBar.text = ""
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ConferenceCallVC.SearchTap(_:)))
        gestureRecognizer.delegate = self
        self.view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.isEnabled = false
        Screenheight = CFloat(self.view.frame.size.height)
        if(Util .isNetworkConnected()){
            self.CallDetailExamTestMessageApi()
        }else{
            let DBArray : NSMutableArray = Childrens.getExamTest(fromDB: ChildId)
            if(DBArray.count > 0){
                DetailTextArray.removeAllObjects()
                MainDetailTextArray.removeAllObjects()
                
                for i in 0..<DBArray.count{
                    
                    let DBDict:NSMutableDictionary = DBArray[i] as! NSMutableDictionary
                    let strExamID = String(describing: DBDict["ExamId"]!)
                    let sectionarray : NSMutableArray = Childrens.getExamTestSectionDetail(fromDB: ChildId, getExamId: strExamID)
                    let Filtersectionarray : NSMutableArray =  NSMutableArray()
                    for j in 0..<sectionarray.count{
                        
                        let SecDict : NSDictionary = sectionarray[j] as! NSDictionary
                        if(!Filtersectionarray.contains(SecDict)){
                            Filtersectionarray.add(SecDict)
                        }
                    }
                    print(Filtersectionarray)
                    DBDict["SubjectDetails"] = Filtersectionarray
                    MainDetailTextArray.add(DBDict)
                    
                    print(MainDetailTextArray)
                    
                }
                DetailTextArray = MainDetailTextArray
                ExamTestTable.reloadData()
            }else{
                AlertMessage(alrString: strNoRecordAlert)
            }
        }
        
    }
    
    @objc func LoadSelectedLanguageData(notification:Notification) -> Void {
        self.callSelectedLanguage()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    
    
}
