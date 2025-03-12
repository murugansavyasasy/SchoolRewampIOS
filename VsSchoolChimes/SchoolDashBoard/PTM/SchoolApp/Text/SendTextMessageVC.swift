//
//  SendTextMessageVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 18/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class SendTextMessageVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,Apidelegate{
    
    @IBOutlet weak var StaffViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var StaffCollectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var StaffCollectionView: UICollectionView!
    @IBOutlet weak var OtherViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var OtherView: UIView!
    @IBOutlet weak var StaffView: UIView!
    @IBOutlet weak var StaffViewHeight: NSLayoutConstraint!
    @IBOutlet weak var SendMessageTextView: UITextView!
    @IBOutlet weak var SendtoAllButton: UIButton!
    @IBOutlet weak var SelectSchoolCollectionView: UICollectionView!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var ChooseReciptents: UIButton!
    
    let loginusername = UserDefaults.standard.object(forKey:USERNAME) as? String
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var strApiFrom = NSString()
    var selectedSchool:Array = [String]()
    var didselectedSchool:Array = [String]()
    var CollectionselectedSchool:Array = [String]()
    var CollectionSectionArray:Array = [String]()
    var PerformAction = String()
    var SegueText = String()
    var CollectionViewString = String()
    var ArrayData:Array = [String]()
    var loginAsName = String()
    var DetailsOfSelectedSchool: NSMutableArray = []
    var StaffSubjectDetailArray: NSMutableArray = []
    var SelectedSectionArrayDetail = [String]()
    var SelectedGroupArrayDetail = [String]()
    var SelectedSectionCodeArray = [String]()
    var SelectedGroupCodeArray = [String]()
    var DumpDetailOfSection:NSMutableArray = []
    var AddtionalSectionDetail:NSMutableArray = []
    var pRemoveSelectedSectionDetailArray: NSMutableArray = []
    var pMainSelectedDetailsofSubjectArray: NSMutableArray = []
    var StaffSelectedStudentIdArray:Array = [String]()
    var StaffSelectedSectionDetailArray : NSMutableArray = []
    var StaffSelectedStudentIDDetailArray:Array = [Any]()
    var StaffSectionDetailArray:Array = [Any]()
    var StaffMessageArray = [Any]()
    var SelectedStaffSectionDic:NSDictionary = [String:Any]() as NSDictionary
    var StaffId = String()
    var UserMobileNo = String()
    var CallerTypeName = String()
    var FirstTimeStaffGettingDetail = String()
    var SchoolId = String()
    var SectionArrayData:Array = [String]()
    var GroupArrayData:Array = [String]()
    var SectionCodeArrayData:Array = [String]()
    var GroupCodeArrayData:Array = [String]()
    var SectionGroupDetailDic:NSDictionary = [String:Any]() as NSDictionary
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        CollectionViewString = "School"
        
        SendMessageTextView.text = SegueText
        
        FirstTimeStaffGettingDetail = "FIRST"
        StaffId = UserDefaults.standard.object(forKey: STAFFID) as! String
        SchoolId = UserDefaults.standard.object(forKey: SCHOOLID) as! String
        UserMobileNo = UserDefaults.standard.object(forKey:USERNAME) as! String
        SendButton.isUserInteractionEnabled = false
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            OtherViewHeight.constant = 190
            
        }
        else
        {
            OtherViewHeight.constant = 160
            
        }
        
        
        SelectSchoolCollectionView.isHidden = true
        StaffCollectionHeightConstraint.constant = 0
        StaffCollectionView.isHidden = true
        
        view.isOpaque = false
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(SendTextMessageVC.catchNotification), name: NSNotification.Name(rawValue: "comeBack"), object:nil)
        nc.addObserver(self,selector: #selector(SendTextMessageVC.catchNotificationSection), name: NSNotification.Name(rawValue: "comeBackSection"), object:nil)
        nc.addObserver(self,selector: #selector(SendTextMessageVC.StaffCatchNotification), name: NSNotification.Name(rawValue: "StaffSectionComeback"), object:nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.ButtonCornerDesign()
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        SelectSchoolCollectionView.alwaysBounceVertical =  true
        StaffCollectionView.alwaysBounceVertical =  true
        
        if(loginAsName == "Staff")
        {
            self.OtherView.isHidden = true
            OtherViewHeight.constant = 0
            
            
        }
        else
        {
            
            if(loginAsName == "Principal")
            {
                CallerTypeName = "M"
            }
            else{
                CallerTypeName = "A"
            }
            
            
            StaffView.isHidden = true
            StaffViewHeightConst.constant = 0
            if(DetailsOfSelectedSchool.count > 0)
            {
                SendButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
                SendButton.isUserInteractionEnabled = true
                
                
            }
            else
            {
                SendButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
                SendButton.isUserInteractionEnabled = false
                
                
            }
            
            
        }
        
    }
    
    
    @IBOutlet weak var actionSelectSchool: UIButton!
    
    @IBAction func actionSelectSchool(_ sender: Any) {
        let svc = self.storyboard?.instantiateViewController(withIdentifier: "SelectSchoolVC") as! SelectSchoolVC
        svc.SegueSelectedSchoolDetailArray = DetailsOfSelectedSchool
        self.present(svc, animated: false, completion: nil)
        
    }
    func ButtonCornerDesign()
    {
        
        SendMessageTextView.isUserInteractionEnabled = false
        actionSelectSchool.layer.cornerRadius = 5
        actionSelectSchool.layer.masksToBounds = true
        
        ChooseReciptents.layer.cornerRadius = 5
        ChooseReciptents.layer.masksToBounds = true
        
        SendtoAllButton.layer.cornerRadius = 5
        SendtoAllButton.layer.masksToBounds = true
        
        SendButton.layer.cornerRadius = 5
        SendButton.layer.masksToBounds = true
    }
    
    //MARK: collectionView
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if(CollectionViewString == "Staff")
        {
            return 1
        }
        else
        {
            return DetailsOfSelectedSchool.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if(CollectionViewString == "Staff")
        {
            return StaffSelectedSectionDetailArray.count
        }
        else
        {
            return 1
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if(CollectionViewString == "Staff")
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StaffSendMessageCVCell", for: indexPath) as! StaffSendMessageCVCell
            cell.layer.cornerRadius = 5
            cell.layer.masksToBounds = true
            SelectedStaffSectionDic = StaffSelectedSectionDetailArray[indexPath.row] as! NSDictionary
            let SectionName = SelectedStaffSectionDic["Class"] as! String
            let Section = SelectedStaffSectionDic["Section"] as! String
            cell.SectionNameLabel.text = SectionName + " - " + Section
            cell.SubjectNameLabel.text = SelectedStaffSectionDic["SubjectName"] as? String
            return cell
        }
        else
        {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectSchoolCVCell", for: indexPath) as! SelectSchoolCVCell
            cell.layer.cornerRadius = 5
            cell.layer.masksToBounds = true
            
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                cell.frame.size.width = 590
                
            }
            else
            {
                cell.frame.size.width = 270
                
            }
            
            
            
            
            if(loginAsName == "Group Head")
            {
                cell.EditButton.isHidden = true
                
            }
            cell.EditButton.layer.cornerRadius = 5
            cell.EditButton.layer.borderWidth = 1
            cell.EditButton.layer.borderColor = UIColor.gray.cgColor
            cell.EditButton.layer.masksToBounds = true
            let DictioanryData = DetailsOfSelectedSchool[indexPath.row] as! NSDictionary
            cell.SelectedSchoolNameLabel.text = DictioanryData["SchoolName"] as? String
            cell.EditButton.addTarget(self, action: #selector(actionEditView(sender:)), for: .touchUpInside)
            cell.EditButton.tag = indexPath.section
            cell.DeleteButton?.layer.setValue(indexPath.section, forKey: "delete")
            cell.DeleteButton.addTarget(self, action: #selector(actionDeleteItemInCollectionView(sender:)), for: .touchUpInside)
            
            return cell
        }
        
    }
    
    @objc func actionEditView(sender:UIButton)
    {
        let Buttontag = sender.tag
        let sectionSelection = self.storyboard?.instantiateViewController(withIdentifier: "SelectSectionVC") as! SelectSectionVC
        
        sectionSelection.SchoolDetailArrayData.append(DetailsOfSelectedSchool[Buttontag])
        sectionSelection.SegueSelectedSectionArray = SelectedSectionArrayDetail
        sectionSelection.SegueSelectedSectionCodeArray = SelectedSectionCodeArray
        sectionSelection.SegueSelectedGroupArray = SelectedGroupArrayDetail
        sectionSelection.SegueSelectedGroupCodeArray = SelectedGroupCodeArray
        
        
        self.present(sectionSelection, animated: false, completion: nil)
    }
    @objc func actionDeleteItemInCollectionView(sender: UIButton)
    {
        
        let i : Int = (sender.layer.value(forKey: "delete")) as! Int
        
        DetailsOfSelectedSchool.removeObject(at: i)
        self.SelectSchoolCollectionView.reloadData()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            collectionviewheightIpad()
            
        }
        else
        {
            collectionviewheight()
        }
        if(DetailsOfSelectedSchool.count > 0)
        {
            SendButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
            SendButton.isUserInteractionEnabled = true
            
            
        }
        else
        {
            SendButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            SendButton.isUserInteractionEnabled = false
            
            
        }
        
        
        
    }
    func collectionviewheightIpad()
    {
        let height = DetailsOfSelectedSchool.count
        
        if(height < 5)
        {
            let heightconst = SelectSchoolCollectionView.collectionViewLayout.collectionViewContentSize.height
            
            
            if(height == 1)
            {
                
                OtherViewHeight.constant = 240
                
            }
            if(height == 2)
            {
                
                OtherViewHeight.constant = 280
                
                
            }
            if(height == 3)
            {
                OtherViewHeight.constant = 330
                
                
                
            }
            if(height == 4)
            {
                OtherViewHeight.constant = 375
                
                
            }
            if(height == 0)
            {
                
                OtherViewHeight.constant = 190
                collectionViewHeight.constant = 0
                
            }
            
            collectionViewHeight.constant = heightconst
            
        }
        else
        {
            
            OtherViewHeight.constant = 380
            collectionViewHeight.constant = 200
            
            
        }
        
        
    }
    
    func collectionviewheight()
    {
        let height = DetailsOfSelectedSchool.count
        // print(height)
        if(height < 3)
        {
            let heightconst = SelectSchoolCollectionView.collectionViewLayout.collectionViewContentSize.height
            
            
            if(height == 1)
            {
                
                OtherViewHeight.constant = 200
                
            }
            if(height == 2)
            {
                
                OtherViewHeight.constant =  245
                
                
            }
            if(height == 0)
            {
                OtherViewHeight.constant =  160
                collectionViewHeight.constant = 0
                
                
            }
            
            collectionViewHeight.constant = heightconst
            
        }
        else
        {
            
            OtherViewHeight.constant = 250
            collectionViewHeight.constant = 100
            
            
        }
    }
    
    
    @objc func StaffCatchNotification(notification:Notification) -> Void
    {
        CollectionViewString = "Staff"
        
        
        //print("staff notification")
        PerformAction = notification.userInfo?["actionkey"] as! String
        
        if(PerformAction == "ok")
        {
            FirstTimeStaffGettingDetail = "Second"
            
            
            StaffCollectionView.isHidden = false
            SendButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
            SendButton.isUserInteractionEnabled = true
            
            
            StaffSectionDetailArray = notification.userInfo?["SectionDetail"] as! [Any]
            StaffSelectedSectionDetailArray = notification.userInfo?["SelectedSectionDetail"] as! NSMutableArray
            DumpDetailOfSection = notification.userInfo?["MainSelectedSectionDetail"] as! NSMutableArray
            AddtionalSectionDetail = notification.userInfo?["AddtionalSectionDetail"] as! NSMutableArray
            
            
            
            
            StaffCollectionHeightConstraint.constant = 80
            StaffViewHeightConst.constant = 130
            self.StaffCollectionView.reloadData()
        }
        else
        {
            FirstTimeStaffGettingDetail = "Second"
            StaffSectionDetailArray = notification.userInfo?["SectionDetail"] as! [Any]
            StaffSelectedSectionDetailArray = notification.userInfo?["SelectedSectionDetail"] as! NSMutableArray
            DumpDetailOfSection = notification.userInfo?["MainSelectedSectionDetail"] as! NSMutableArray
            AddtionalSectionDetail = notification.userInfo?["AddtionalSectionDetail"] as! NSMutableArray
            
            
            StaffCollectionView.isHidden = true
            StaffCollectionHeightConstraint.constant = 0
            StaffViewHeightConst.constant = 45
            
            
        }
        
        
    }
    
    @objc func catchNotificationSection(notification:Notification) -> Void
    {
        //print("SectioncatchNotification")
        PerformAction = notification.userInfo?["actionkey"] as! String
        if(PerformAction == "ok")
        {
            SelectedSectionArrayDetail = notification.userInfo?["SectionDetailArray"] as! [String]
            //print(SelectedSectionArrayDetail)
            SelectedSectionCodeArray = notification.userInfo?["SectionCodeArray"] as! [String]
            //print(SelectedSectionCodeArray)
            
            SelectedGroupArrayDetail = notification.userInfo?["GroupDetailArray"] as! [String]
            // print(SelectedGroupArrayDetail)
            SelectedGroupCodeArray = notification.userInfo?["GroupCodeArray"] as! [String]
            //print(SelectedGroupCodeArray)
        }
        else
        {
            
            SelectedSectionArrayDetail = notification.userInfo?["SectionDetailArray"] as! [String]
            
            SelectedSectionCodeArray = notification.userInfo?["SectionCodeArray"] as! [String]
            
            
            SelectedGroupArrayDetail = notification.userInfo?["GroupDetailArray"] as! [String]
            
            SelectedGroupCodeArray = notification.userInfo?["GroupCodeArray"] as! [String]
            
            
        }
        
        
    }
    
    //MARK: Staff Collection view
    
    
    @objc func catchNotification(notification:Notification) -> Void
    {
        
        
        
        PerformAction = notification.userInfo?["actionkey"] as! String
        
        if(PerformAction == "ok")
        {
            
            DetailsOfSelectedSchool = notification.userInfo?["SchoolDetail"] as! NSMutableArray
            
            
            for i in 0..<DetailsOfSelectedSchool.count
            {
                SectionGroupDetailDic = DetailsOfSelectedSchool[i] as! NSDictionary
                
                
                let Groupcode = SectionGroupDetailDic["GrpCode"] as! NSArray
                let SecCode = SectionGroupDetailDic["StdCode"] as! NSArray
                for i in 0..<Groupcode.count
                {
                    let mygroupdic:NSDictionary = Groupcode.object(at: i) as! NSDictionary
                    let mystring = mygroupdic["GroupName"] as! String
                    let groupid = mygroupdic["GroupCode"] as! String
                    GroupArrayData.append(mystring)
                    GroupCodeArrayData.append(groupid)
                }
                for i in 0..<SecCode.count
                {
                    let mygroupdic:NSDictionary = SecCode.object(at: i) as! NSDictionary
                    let mystring = mygroupdic["Stdname"] as! String
                    let mystdid = mygroupdic["StdId"] as! String
                    SectionArrayData.append(mystring)
                    SectionCodeArrayData.append(mystdid)
                    
                }
                SelectedSectionCodeArray = SectionCodeArrayData
                SelectedGroupCodeArray = GroupCodeArrayData
            }
            
            SelectSchoolCollectionView.isHidden = false
            self.SelectSchoolCollectionView.reloadData()
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                collectionviewheightIpad()
                
            }
            else
            {
                collectionviewheight()
            }
        }
        else
        {
            DetailsOfSelectedSchool = notification.userInfo?["SchoolDetail"] as! NSMutableArray
            if(DetailsOfSelectedSchool.count > 0)
            {   SelectSchoolCollectionView.isHidden = false
                self.SelectSchoolCollectionView.reloadData()
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    collectionviewheightIpad()
                    
                }
                else
                {
                    collectionviewheight()
                }
                
            }
            else
            {
                SelectSchoolCollectionView.isHidden = true
                collectionViewHeight.constant = 0
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    OtherViewHeight.constant = 190
                    
                }
                else
                {
                    OtherViewHeight.constant = 160
                }
                
            }
        }
        
        
        
        
    }
    //MARK: Send To All School
    
    
    @IBAction func actionSendToAllSchool(_ sender: Any) {
        
        self.SendSmsToAllAsPrincipalapi()
        
    }
    
    @IBAction func actionCloseView(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func actionSendSmsToParticularSectionGroup(_ sender: Any) {
        if(loginAsName == "Staff")
        {
            self.SendSmsAsStaffapi()
        }
        else
        {
            self.SendSmsAToSelectedStandardGroupASPrincipalapi()
        }
    }
    
    
    
    
    //MARK: API CALLING
    func SendSmsAsStaffapi()
    {
        showLoading()
        strApiFrom = "SmsToAsStaff"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SENDSMS_STAFF
        
        let arrUserData : NSMutableArray = []
        let arrTargetCodeData : NSMutableArray = []
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        
        
        for i in 0..<StaffSelectedSectionDetailArray.count
        {
            SelectedStaffSectionDic = StaffSelectedSectionDetailArray[i] as! NSDictionary
            let message = SelectedStaffSectionDic["MsgToAll"] as! String
            if(message == "T")
            {
                SelectedStaffSectionDic.setValue([], forKey: "StudentIdArrayData")
            }
            let myTargetCodeDict:NSMutableDictionary = ["SecCode" : SelectedStaffSectionDic["ClassSecCode"]!,"SubCode" : SelectedStaffSectionDic["SubjectCode"]! ,"MsgToAll" : SelectedStaffSectionDic["MsgToAll"]! ,"Student" : SelectedStaffSectionDic["StudentIdArrayData"]!]
            arrTargetCodeData.add(myTargetCodeDict)
        }
        
        
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Message" : SegueText,"TargetCode": arrTargetCodeData]
        arrUserData.add(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "SmsToAsStaff")
    }
    
    
    
    
    func SendSmsAToSelectedStandardGroupASPrincipalapi()
    {
        showLoading()
        strApiFrom = "SendSmsAsPrincipalToSelectedClass"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SELECTEDSTANDARD_GROUP_PRINCIPAL
        
        let arrUserData : NSMutableArray = []
        let arrGroupCodeData : NSMutableArray = []
        let arrSectionCodeData : NSMutableArray = []
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        for i in 0..<SelectedSectionCodeArray.count
        {
            let mystring = SelectedSectionCodeArray[i]
            let SectionDic:NSDictionary = ["TargetCode" : mystring]
            arrSectionCodeData.add(SectionDic)
            
            
        }
        for i in 0..<SelectedGroupCodeArray.count
        {
            let mystring = SelectedGroupCodeArray[i]
            let GroupDic:NSDictionary = ["TargetCode" : mystring]
            arrGroupCodeData.add(GroupDic)
            //print(arrGroupCodeData)
            
        }
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Message" : SendMessageTextView.text,"Seccode" : arrSectionCodeData,"GrpCode":arrGroupCodeData]
        arrUserData.add(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "SendSmsAsPrincipalToSelectedClass")
        
        
    }
    
    func GetAllSectionOfSchool()
    {
        showLoading()
        strApiFrom = "GetSectionDetail"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SECTION_DETAIL
        
        let arrUserData : NSMutableArray = []
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolID" : "10000001"]
        arrUserData.add(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetSectionDetail")
    }
    
    
    func GetAllStandardOfSchool()
    {
        showLoading()
        strApiFrom = "GetStandardDetail"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + STANDARD_DETAIL
        
        let arrUserData : NSMutableArray = []
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolID" : "10000001"]
        arrUserData.add(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetStandardDetail")
    }
    
    
    func GetSubjectDetailAsStaffapi()
    {
        showLoading()
        strApiFrom = "GetSubjectDetail"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SUBJECT_DETAIL
        
        let arrUserData : NSMutableArray = []
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId]
        arrUserData.add(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetSubjectDetail")
    }
    
    
    
    
    
    func SendSmsToSchoolAsAdminapi()
    {
        showLoading()
        strApiFrom = "SmsToSchoolAdmin"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SENDSMSTOSCHOOL_ADMIN
        
        let arrUserData : NSMutableArray = []
        let arrSchoolData : NSMutableArray = []
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let mySchoolDic = ["ID":["10000852","10000859"]]
        arrSchoolData.add(mySchoolDic)
        let myDict:NSMutableDictionary = ["Message" : SendMessageTextView.text,"School" : arrSchoolData]
        arrUserData.add(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        //print(myString!)
        apiCall.nsurlConnectionFunction(requestString, myString, "SmsToSchoolAdmin")
    }
    
    
    
    
    func SendSmsToAllAsPrincipalapi()
    {
        showLoading()
        strApiFrom = "SmsToAllPrincipal"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + SENDSMSTOALL_PRINCIPLE
        let arrUserData : NSMutableArray = []
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Message" : SendMessageTextView.text,"CallerType":CallerTypeName,"CallerID":UserMobileNo]
        arrUserData.add(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "SmsToAllPrincipal")
    }
    
    
    //MARK: API RESPONSE
    
    
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom.isEqual(to: "SmsToAllPrincipal"))
            {
                var  arrayDatas: NSArray = []
                var dicResponse: NSDictionary = [:]
                arrayDatas = csData!
                for var i in 0..<arrayDatas.count
                {
                    dicResponse = arrayDatas[i] as! NSDictionary
                }
                
                let myalertstring = dicResponse["Message"] as! String
                let mystatus = dicResponse["Status"] as! String
                
                
                if(mystatus == "y")
                {
                    Util.showAlert("", msg: myalertstring)
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    
                    
                }
                else
                {
                    Util.showAlert("", msg: myalertstring)
                    dismiss(animated: true, completion: nil)
                    
                }
                
                
                
            }
            else if(strApiFrom.isEqual(to: "SendSmsAsPrincipalToSelectedClass"))
            {
                var  arrayDatas: NSArray = []
                var dicResponse: NSDictionary = [:]
                arrayDatas = csData!
                
                for var i in 0..<arrayDatas.count
                {
                    dicResponse = arrayDatas[i] as! NSDictionary
                }
                
                let myalertstring = dicResponse["Message"] as! String
                
                let mystatus = dicResponse["Status"] as! String
                
                
                
                if(mystatus == "y")
                {
                    Util.showAlert("", msg: myalertstring)
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    
                    
                }
                else
                {
                    Util.showAlert("", msg: myalertstring)
                    dismiss(animated: true, completion: nil)
                    
                }
                
                
            }
            else if(strApiFrom.isEqual(to: "SmsToAsStaff"))
            {
                var  arrayDatas: NSArray = []
                var dicResponse: NSDictionary = [:]
                arrayDatas = csData!
                for var i in 0..<arrayDatas.count
                {
                    dicResponse = arrayDatas[i] as! NSDictionary
                }
                
                let myalertstring = dicResponse["Message"] as! String
                let mystatus = dicResponse["Status"] as! String
                
                
                
                if(mystatus == "Y")
                {
                    Util.showAlert("", msg: myalertstring)
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    
                    
                }
                else
                {
                    Util.showAlert("", msg: myalertstring)
                    dismiss(animated: true, completion: nil)
                }
            }
            
            else if(strApiFrom.isEqual(to: "GetSubjectDetail"))
            {
                
                if((csData?.count)! > 0)
                {
                    StaffSubjectDetailArray = csData!
                    actionMoveToSectionSelectionAsStaff()
                    
                    
                    
                }
                else
                {
                    Util.showAlert("", msg: "No Record Found")
                    dismiss(animated: false, completion: nil)
                    
                }
                
            }
            
            
        }
        else
        {
            Util.showAlert("", msg: "Server Response Failed")
        }
        
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        
        Util .showAlert("", msg: "Server connection failed!");
        
    }
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        
    }
    @IBAction func actionChooseRecepients(_ sender: Any) {
        
        if(FirstTimeStaffGettingDetail == "FIRST")
        {
            self.GetSubjectDetailAsStaffapi()
        }
        else
        {
            if(StaffSectionDetailArray.count > 0)
            {
                let SectionVC = self.storyboard?.instantiateViewController(withIdentifier: "StaffSectionSelectionVC") as! StaffSectionSelectionVC
                SectionVC.DetailsofSubjectArray = StaffSectionDetailArray as! Array
                SectionVC.AddtionalDetailsofSubjectArray = AddtionalSectionDetail
                SectionVC.SelectedSectionDetailArray = StaffSelectedSectionDetailArray
                SectionVC.SelectedDetailsofSubjectArray = DumpDetailOfSection as! NSMutableArray
                self.present(SectionVC, animated: false, completion: nil)
            }
            else
            {
                self.actionMoveToSectionSelectionAsStaff()
            }
        }
    }
    
    func actionMoveToSectionSelectionAsStaff()
    {
        let SectionVC = self.storyboard?.instantiateViewController(withIdentifier: "StaffSectionSelectionVC") as! StaffSectionSelectionVC
        SectionVC.SegueDetailsofSubjectArray = StaffSubjectDetailArray  as! Array
        
        SectionVC.SendTextMessage = SegueText
        self.present(SectionVC, animated: false, completion: nil)
    }
    
    
    
    
    
}
