//
//  SendImageMessageVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 18/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class SendImageMessageVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,Apidelegate {
    
    @IBOutlet weak var StaffCollectionView: UICollectionView!
    @IBOutlet weak var StaffCollectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var OtherView: UIView!
    @IBOutlet weak var StaffView: UIView!
    @IBOutlet weak var SendImageLabel: UILabel!
    @IBOutlet weak var StaffViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var OthersViewHeight: NSLayoutConstraint!
    @IBOutlet weak var SendImageView: UIImageView!
    @IBOutlet weak var SendToAllButton: UIButton!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ChooseReciptents: UIButton!
    @IBOutlet weak var SendButton: UIButton!
    @IBOutlet weak var selectSchoolButton: UIButton!
    
    var selectedSchool:Array = [String]()
    var didselectedSchool:Array = [String]()
    var CollectionselectedSchool:Array = [String]()
    var PerformAction = String()
    var loginAsName = String()
    var StaffId = String()
    var SchoolId = String()
    var AlertSectionData = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var strApiFrom = NSString()
    var loginusername = String()
    var CallerTyepString = String()
    var uploadImageData : NSData? = nil
    var segueImage = UIImage()
    var DetailsOfSelectedSchool: NSMutableArray = []
    var SelectedSectionArrayDetail = [String]()
    var SelectedGroupArrayDetail = [String]()
    var SelectedSectionCodeArray = [String]()
    var SelectedGroupCodeArray = [String]()
    var SectionArrayData:Array = [String]()
    var GroupArrayData:Array = [String]()
    var SectionCodeArrayData:Array = [String]()
    var GroupCodeArrayData:Array = [String]()
    var SectionGroupDetailDic:NSDictionary = [String:Any]() as NSDictionary
    var AddtionalSectionDetail : NSMutableArray = []
    var StaffSelectedStudentIdArray:Array = [String]()
    var StaffSelectedSectionDetailArray : NSMutableArray = []
    var StaffSelectedStudentIDDetailArray:Array = [Any]()
    var StaffSectionDetailArray:Array = [Any]()
    var StaffSubjectDetailArray: NSMutableArray = []
    var CollectionViewString = String()
    var StaffMessageArray = [Any]()
    var SelectedStaffSectionDic:NSDictionary = [String:Any]() as NSDictionary
    var FirstTimeStaffGettingDetail = String()
    var DumpDetailOfSection:NSMutableArray = []
    var pRemoveSelectedSectionDetailArray: NSMutableArray = []
    var pMainSelectedDetailsofSubjectArray: NSMutableArray = []
    var strCountryCode = String()
    @IBOutlet weak var SelectSchoolCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        SelectSchoolCollectionView.isHidden = true
        StaffCollectionHeightConstraint.constant = 0
        StaffCollectionView.isHidden = true
        FirstTimeStaffGettingDetail = "FIRST"
        SelectSchoolCollectionView.alwaysBounceVertical =  true
        StaffCollectionView.alwaysBounceVertical =  true
        
        loginusername = UserDefaults.standard.object(forKey:USERNAME) as! String
        
        let defaults = UserDefaults.standard
        StaffId = defaults.string(forKey: DefaultsKeys.StaffID)!
        SchoolId = defaults.string(forKey: DefaultsKeys.SchoolD)!
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            OthersViewHeight.constant = 190
        }
        else
        {
            OthersViewHeight.constant = 160
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(SendImageMessageVC.catchNotification), name: NSNotification.Name(rawValue: "comeBack"), object:nil)
        nc.addObserver(self,selector: #selector(SendImageMessageVC.catchNotificationSection), name: NSNotification.Name(rawValue: "comeBackSection"), object:nil)
        nc.addObserver(self,selector: #selector(SendImageMessageVC.StaffCatchNotification), name: NSNotification.Name(rawValue: "StaffSectionComeback"), object:nil)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        buttonCornerDesign()
        SendImageView.image = segueImage
        uploadImageData = (segueImage.pngData() as NSData?)!
        
        loginAsName = UserDefaults.standard.object(forKey:LOGINASNAME) as! String
        if(loginAsName == "Staff")
        {   OthersViewHeight.constant = 5
            OtherView.isHidden = true
        }
        else
        {
            StaffViewHeightConst.constant = 5
            StaffView.isHidden = true
            self.checkCollectionArrayDataCount()
        }
        if(loginAsName == "Principal")
        {
            CallerTyepString = "M"
        }
        else
        {
            CallerTyepString = "A"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func buttonCornerDesign()
    {
        ChooseReciptents.layer.cornerRadius = 5
        ChooseReciptents.layer.masksToBounds = true
        SendToAllButton.layer.cornerRadius = 5
        SendToAllButton.layer.masksToBounds = true
        SendButton.layer.cornerRadius = 5
        SendButton.layer.masksToBounds = true
        selectSchoolButton.layer.cornerRadius = 5
        selectSchoolButton.layer.masksToBounds = true
        
    }
    
    //MARK: SELECT SCHOOL BUTTON ACTIONS
    @IBAction func actionSelectSchool(_ sender: Any) {
        let svc = self.storyboard?.instantiateViewController(withIdentifier: "SelectSchoolVC") as! SelectSchoolVC
        //svc.SegueSelectedDataArray = CollectionselectedSchool
        svc.SegueSelectedSchoolDetailArray = DetailsOfSelectedSchool
        self.present(svc, animated: false, completion: nil)
        
    }
    func checkCollectionArrayDataCount()
    {
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
    
    
    
    //MARK: COLLECTION VIEW
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
                
                OthersViewHeight.constant = 240
                
            }
            if(height == 2)
            {
                
                OthersViewHeight.constant = 280
                
                
            }
            if(height == 3)
            {
                OthersViewHeight.constant = 330
                
                
                
            }
            if(height == 4)
            {
                OthersViewHeight.constant = 375
                
                
            }
            if(height == 0)
            {
                
                OthersViewHeight.constant = 190
                collectionViewHeight.constant = 0
                
            }
            
            collectionViewHeight.constant = heightconst
            
        }
        else
        {
            
            OthersViewHeight.constant = 380
            collectionViewHeight.constant = 200
            
            
        }
        
    }
    
    func collectionviewheight()
    {
        let height = DetailsOfSelectedSchool.count
        
        if(height < 3)
        {
            let heightconst = SelectSchoolCollectionView.collectionViewLayout.collectionViewContentSize.height
            
            if(height == 1)
            {
                OthersViewHeight.constant = 200
            }
            if(height == 2)
            {
                OthersViewHeight.constant =  245
            }
            if(height == 0)
            {
                OthersViewHeight.constant =  160
                collectionViewHeight.constant = 0
            }
            
            collectionViewHeight.constant = heightconst
        }
        else
        {
            OthersViewHeight.constant = 250
            collectionViewHeight.constant = 100
        }
    }
    //MARK: SECTION SELECTION COMEBACK
    @objc func catchNotificationSection(notification:Notification) -> Void
    {
        PerformAction = notification.userInfo?["actionkey"] as! String
        if(PerformAction == "ok")
        {
            SelectedSectionArrayDetail = notification.userInfo?["SectionDetailArray"] as! [String]
            
            SelectedSectionCodeArray = notification.userInfo?["SectionCodeArray"] as! [String]
            
            
            SelectedGroupArrayDetail = notification.userInfo?["GroupDetailArray"] as! [String]
            
            SelectedGroupCodeArray = notification.userInfo?["GroupCodeArray"] as! [String]
        }
        else
        {
            SelectedSectionArrayDetail = notification.userInfo?["SectionDetailArray"] as! [String]
            SelectedSectionCodeArray = notification.userInfo?["SectionCodeArray"] as! [String]
            SelectedGroupArrayDetail = notification.userInfo?["GroupDetailArray"] as! [String]
            SelectedGroupCodeArray = notification.userInfo?["GroupCodeArray"] as! [String]
        }
        
    }
    //MARK: STAFF SECTION SELECTION COMEBACK
    @objc func StaffCatchNotification(notification:Notification) -> Void
    {
        CollectionViewString = "Staff"
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
    
    
    
    
    //MARK: SCHOOL SELECTION COMEBACK
    @objc func catchNotification(notification:Notification) -> Void {
        
        
        
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
                    OthersViewHeight.constant = 190
                    
                }
                else
                {
                    OthersViewHeight.constant = 160
                }
                
            }
        }
        
        
        
        
    }
    
    // MARK: SEND TO ALL SCHOOL ACTION
    @IBAction func actionSendToAllSchool(_ sender: Any) {
        self.SendImageToAllAsPrincipalapi()
        
    }
    
    
    @IBAction func actionCloseView(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: SEND IMAGE TO SELECTE SCHOOL
    @IBAction func actionSendImagetoSelectedSchool(_ sender: Any) {
        
        if(loginAsName == "Staff")
        {
            self.SendImageAsStaffapi()
        }
        else
        {
            self.SendImageAToSelectedStandardGroupASPrincipalapi()
        }
        
        
    }
    
    //MARK: Api calling
    
    
    func SendImageAsStaffapi()
    {
        
        showLoading()
        strApiFrom = "SendImageAsStaff"
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        let arrUserData : NSMutableArray = []
        let arrTargetCodeData : NSMutableArray = []
        
        for i in 0..<StaffSelectedSectionDetailArray.count
        {
            SelectedStaffSectionDic = StaffSelectedSectionDetailArray[i] as! NSDictionary
            let myTargetCodeDict:NSMutableDictionary = ["SecCode" : SelectedStaffSectionDic["ClassSecCode"]!,"SubCode" : SelectedStaffSectionDic["SubjectCode"]! ,"MsgToAll" : SelectedStaffSectionDic["MsgToAll"]! ,"Student" : SelectedStaffSectionDic["StudentIdArrayData"]!, COUNTRY_CODE: strCountryCode]
            arrTargetCodeData.add(myTargetCodeDict)
        }
        
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"TargetCode" : arrTargetCodeData]
        arrUserData.add(myDict)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: myDict)
        
        
        apiCall.callPassParmsImage(baseUrlString, myString, "ImageToAllPrincipal", uploadImageData as Data?)
        
        
        
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
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId, COUNTRY_CODE: strCountryCode]
        arrUserData.add(myDict)
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "GetSubjectDetail")
    }
    
    
    
    
    
    func SendImageAToSelectedStandardGroupASPrincipalapi()
    {
        showLoading()
        strApiFrom = "SendImageAsPrincipalToSelectedClass"
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        let arrUserData : NSMutableArray = []
        let arrGroupCodeData : NSMutableArray = []
        let arrSectionCodeData : NSMutableArray = []
        
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
        }
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"Seccode" : arrSectionCodeData,"GrpCode":arrGroupCodeData, COUNTRY_CODE: strCountryCode]
        arrUserData.add(myDict)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.callPassImageParms(baseUrlString, myString, "SendImageAsPrincipalToSelectedClass", uploadImageData as Data?)
    }
    
    
    func SendImageToAllAsPrincipalapi()
    {
        showLoading()
        strApiFrom = "ImageToAllPrincipal"
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        
        let arrUserData : NSMutableArray = []
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolId,"StaffID" : StaffId,"CallerType" : CallerTyepString,"CallerID": loginusername, COUNTRY_CODE: strCountryCode]
        arrUserData.add(myDict)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        
        let myString = Util.convertDictionary(toString: myDict)
        
        
        apiCall.callPassParms(baseUrlString, myString, "ImageToAllPrincipal", uploadImageData as Data?)
    }
    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        
        if(csData != nil)
        {
            if(strApiFrom.isEqual(to: "ImageToAllPrincipal"))
            {
                var  arrayDatas: NSArray = []
                var dicResponse: NSDictionary = [:]
                arrayDatas = csData!
                for var i in 0..<arrayDatas.count
                {
                    dicResponse = arrayDatas[i] as! NSDictionary
                }
                
                let myalertstring = dicResponse["Message"] as? String
                
                let mystatus = dicResponse["Status"] as? String
                
                
                
                if(mystatus == "y")
                {
                    Util.showAlert("", msg: myalertstring)
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
                else
                {
                    Util.showAlert("", msg: myalertstring)
                    dismiss(animated: false, completion: nil)
                    
                    
                }
                
                
                
            }
            else if(strApiFrom.isEqual(to: "SendImageAsPrincipalToSelectedClass"))
            {
                var  arrayDatas: NSArray = []
                var dicResponse: NSDictionary = [:]
                arrayDatas = csData!
                for var i in 0..<arrayDatas.count
                {
                    dicResponse = arrayDatas[i] as! NSDictionary
                }
                let myalertstring = dicResponse["Message"] as! String
                var mystatus = String()
                if let status = dicResponse["Status"] as? String
                {
                    mystatus = status
                }
                else{
                    mystatus = ""
                }
                
                if(mystatus == "y")
                {
                    
                    Util.showAlert("", msg: myalertstring)
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    
                }
                else
                {
                    Util.showAlert("", msg: myalertstring)
                    dismiss(animated: false, completion: nil)
                }
                
                
            }
            else if(strApiFrom.isEqual(to: "SendImageAsStaff"))
            {
                var  arrayDatas: NSArray = []
                var dicResponse: NSDictionary = [:]
                arrayDatas = csData!
                for var i in 0..<arrayDatas.count
                {
                    dicResponse = arrayDatas[i] as! NSDictionary
                }
                
                let myalertstring = dicResponse["Message"] as? String
                //print(myalertstring)
                let mystatus = dicResponse["Status"] as? String
                
                if(mystatus == "y"){
                    Util.showAlert("", msg: myalertstring)
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                    
                }else{
                    Util.showAlert("", msg: myalertstring)
                    dismiss(animated: true, completion: nil)
                }
            }else if(strApiFrom.isEqual(to: "GetSubjectDetail")){
                if((csData?.count)! > 0){
                    StaffSubjectDetailArray = csData!
                    actionMoveToSectionSelectionAsStaff()
                }else{
                    Util.showAlert("", msg: "No Record Found")
                    dismiss(animated: false, completion: nil)
                }
            }
        }else{
            Util.showAlert("", msg: "Server Response Failed")
        }
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        // print("Error")
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
    
    func actionMoveToSectionSelectionAsStaff(){
        let SectionVC = self.storyboard?.instantiateViewController(withIdentifier: "StaffSectionSelectionVC") as! StaffSectionSelectionVC
        SectionVC.SegueDetailsofSubjectArray = StaffSubjectDetailArray as! Array
        self.present(SectionVC, animated: false, completion: nil)
    }
    
    @IBAction func actionChooseRecipients(_ sender: Any) {
        if(FirstTimeStaffGettingDetail == "FIRST"){
            GetSubjectDetailAsStaffapi()
        }else{
            if(StaffSectionDetailArray.count > 0){
                let SectionVC = self.storyboard?.instantiateViewController(withIdentifier: "StaffSectionSelectionVC") as! StaffSectionSelectionVC
                SectionVC.DetailsofSubjectArray = StaffSectionDetailArray  as! Array
                SectionVC.AddtionalDetailsofSubjectArray = AddtionalSectionDetail
                SectionVC.SelectedSectionDetailArray = StaffSelectedSectionDetailArray
                SectionVC.SelectedDetailsofSubjectArray = DumpDetailOfSection as! NSMutableArray
                self.present(SectionVC, animated: false, completion: nil)
            }else{
                self.actionMoveToSectionSelectionAsStaff()
            }
        }
    }
}
