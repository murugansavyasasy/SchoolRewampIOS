//
//  AbsenteesRecordVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 13/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class AbsenteesRecordVC: UIViewController,UITableViewDataSource,UITableViewDelegate,Apidelegate {
    
    @IBOutlet var myTableView: UITableView!
    @IBOutlet weak var HeaderViewHeight: NSLayoutConstraint!
    @IBOutlet var HeaderView: UIView!
    @IBOutlet var TotalStaffStrengthLbl: UILabel!
    @IBOutlet var TotalStudentStrengthLbl: UILabel!
    @IBOutlet var FloatStudentLabel: UILabel!
    @IBOutlet var FloatStaffLabel: UILabel!
    var DifferString = String()
    var strApiFrom = String()
    var SchoolIDString = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var arrStatus:NSMutableArray = []
    var SchoolStrengthArray = NSArray()
    var DictSectionTitleString = String()
    let UtilObj = UtilClass()
    var strLanguage = String()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var LangDict = NSDictionary()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        HeaderView.isHidden = true
        HeaderViewHeight.constant = 0
        if(DifferString == "DateVice")
        {
            HeaderView.isHidden = true
            HeaderViewHeight.constant = 0
            DictSectionTitleString = "SectionWise"
            
        }else{
            
            HeaderView.isHidden = false
            DictSectionTitleString = "Sections"
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                HeaderViewHeight.constant = 126
            }else
            {
                HeaderViewHeight.constant = 88
                
            }
            if(SchoolStrengthArray.count == 0)
            {
                if(UtilObj.IsNetworkConnected())
                {
                    self.GetSchoolStrengthDetailApiCalling()
                }
                else
                {
                    Util.showAlert("", msg:strNoInternet )
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
        TitleForNavigation()
        if(SchoolStrengthArray.count > 0)
        {
            for i in 0..<SchoolStrengthArray.count // pass your array count
            {
                self.arrStatus.add("0")
            }
        }
        myTableView.reloadData()
        
    }
    //MARK: TABLEVIEW DELEGATE
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 65
        }else{
            return 50
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let ExpandCell =  Bundle.main.loadNibNamed("SectionHeader", owner: self, options: nil)?[0] as! SectionHeader
        ExpandCell.SectionCount.layer.cornerRadius = 5
        ExpandCell.SectionCount.layer.masksToBounds = true
        ExpandCell.SectionCountView.layer.cornerRadius = 5
        ExpandCell.SectionCountView.layer.masksToBounds = true
        let Dict = SchoolStrengthArray[section] as! NSDictionary
        if(DifferString == "DateVice")
        {
            ExpandCell.SectionTitle.text = String(describing: Dict["ClassName"]!)
            ExpandCell.SectionCount.text =  String(describing: Dict["TotalAbsentees"]!)
        }else{
            ExpandCell.SectionTitle.text = String(describing: Dict["StdName"]!)
            ExpandCell.SectionCount.text =  String(describing: Dict["TotalStudents"]!)
        }
        
        ExpandCell.btnExpand.tag = section
        ExpandCell.btnExpand.addTarget(self, action: #selector(AbsenteesRecordVC.headerCellButtonTapped(_sender:)), for: UIControl.Event.touchUpInside)
        
        let str:String = arrStatus[section] as! String
        if str == "0"
        {
            UIView.animate(withDuration: 2) { () -> Void in
                ExpandCell.imgArrow.image = UIImage(named :"arrow")
                let angle =  CGFloat(M_PI * 2)
                let tr = CGAffineTransform.identity.rotated(by: angle)
                ExpandCell.imgArrow.transform = tr
            }
        }
        else
        {
            UIView.animate(withDuration: 2) { () -> Void in
                ExpandCell.imgArrow.image = UIImage(named :"downArrow")
                let angle =  CGFloat(M_PI * 2)
                let tr = CGAffineTransform.identity.rotated(by: angle)
                ExpandCell.imgArrow.transform = tr
            }
        }
        
        return ExpandCell
    }
    @objc func headerCellButtonTapped(_sender: UIButton)
    {
        let str:String = arrStatus[_sender.tag] as! String
        if str == "0"
        {
            arrStatus[_sender.tag] = "1"
            
        }
        else
        {
            arrStatus[_sender.tag] = "0"
        }
        myTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 70
        }else{
            return 50
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        let str:String = arrStatus[section] as! String
        let dict = SchoolStrengthArray[section] as! NSDictionary
        
        let CellRowArray = dict[DictSectionTitleString] as? NSArray
        
        if str == "0"
        {
            return 0
        }
        return  (CellRowArray?.count)!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AbsenteesRecordTVCell", for: indexPath) as! AbsenteesRecordTVCell
        cell.backgroundColor = UIColor.clear
        let dict = SchoolStrengthArray[indexPath.section] as! NSDictionary
        
        let SectionArray = dict[DictSectionTitleString] as! NSArray
        if(DifferString == "DateVice")
        {
            let CellDict = SectionArray[indexPath.row] as! NSDictionary
            cell.SecNameLbl.text = String(describing: CellDict["SectionName"]!)
            cell.TotalStudentLbl.text =   String(describing: CellDict["TotalAbsentees"]!)
            
        }else{
            let CellDict1 = SectionArray[indexPath.row] as! NSDictionary
            cell.SecNameLbl.text = String(describing: CellDict1["SecName"]!)
            cell.TotalStudentLbl.text =  String(describing: CellDict1["TotalStudents"]!)
        }
        
        if(strLanguage == "ar"){
            cell.SecNameLbl.textAlignment = .right
        }else{
            cell.SecNameLbl.textAlignment = .left
        }
        
        
        return cell;
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return SchoolStrengthArray.count
    }
    func TitleForNavigation()
    {
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        // titleLabel.textColor = UIColor (red:243.0/255.0, green: 191.0/255.0, blue: 145.0/255.0, alpha: 1)
        titleLabel.textColor = UIColor (red:166.0/255.0, green: 114.0/255.0, blue: 155.0/255.0, alpha: 1)
        let secondWord : String = "School"
        let thirdWord : String = "Strength"
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
    }
    //MARK: API CALLING
    func GetSchoolStrengthDetailApiCalling()
    {
        showLoading()
        strApiFrom = "GetSchoolStrengthDetailApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_SCHOOL_STRENGTH_DETAIL
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_SCHOOL_STRENGTH_DETAIL
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["SchoolId" : SchoolIDString]
        
        let myString = Util.convertDictionary(toString: myDict)
        UtilObj.printLogKey(printKey: "REQ", printingValue: myString)
        
        UtilObj.printLogKey(printKey: strApiFrom, printingValue: requestStringer)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "GetSchoolStrengthDetailApi")
    }    
    //MARK: API RESPONSE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        
        hideLoading()
        if(csData != nil)
        {
            UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if(strApiFrom.isEqual("GetSchoolStrengthDetailApi"))
            {
                if((csData?.count)! > 0)
                {
                    let ResponseArray = NSArray(array: csData!)
                    print(ResponseArray)
                    let Dict = ResponseArray[0] as! NSDictionary
                    if(Dict["Standards"] != nil)
                    {
                        if let arr = Dict["Standards"] as? NSArray{
                            SchoolStrengthArray = Dict["Standards"] as! NSArray
                            if(SchoolStrengthArray.count > 0)
                            {
                                TotalStaffStrengthLbl.text = String(describing: Dict["TotalStaffStrength"]!)
                                TotalStudentStrengthLbl.text = String(describing: Dict["TotalStudentStrength"]!)
                                for i in 0..<SchoolStrengthArray.count
                                {
                                    self.arrStatus.add("0")
                                }
                                myTableView.reloadData()
                                
                            }
                            else{
                                Util.showAlert("", msg: strNoRecordAlert)
                            }
                        }else{
                            Util.showAlert("", msg: strNoRecordAlert)
                        }
                        
                    }
                    
                    
                }else{
                    Util.showAlert("", msg: strNoRecordAlert)
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
        // print("Error")
        Util .showAlert("", msg: strSomething);
        
    }
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
        let strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
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
        self.LangDict = LangDict
        strLanguage = Language
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        FloatStaffLabel.text  = LangDict["staff"] as? String
        FloatStudentLabel.text  = LangDict["students"] as? String
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
    
}

