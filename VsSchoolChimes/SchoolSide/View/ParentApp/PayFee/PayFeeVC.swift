//
//  PayFeeVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 15/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class PayFeeVC: UIViewController,UITableViewDelegate, UITableViewDataSource,Apidelegate{
    @IBOutlet weak var PayFeesTableView: UITableView!
    @IBOutlet weak var MonthlyFees: UIButton!
    @IBOutlet weak var FooterView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var LogoutLabel: UILabel!
    @IBOutlet weak var FAQLabel: UILabel!
    @IBOutlet weak var PasswordLabel: UILabel!
    @IBOutlet weak var LanguageLabel: UILabel!
    @IBOutlet weak var HomeLabel: UILabel!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var MakePaymentFees: UIButton!
    
    
    var StrTableFrom = String()
    var strApiFrom = String()
    var AlertString = String()
    var ChildIDString = String()
    var SchoolIDString = String()
    var SelectedInvoiceID = String()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var arrPaidFee : NSArray = []
    var OverAllPendingFeeArr : NSArray = []
    var arrPendingFee : NSMutableArray = []
    var selectedPaidFeeDict = NSDictionary()
    var MonthlyFeeArray : NSArray = []
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedInvoiceDict = NSDictionary()
    var strLanguage = String()
    var languageDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StrTableFrom = "Paid"
        MonthlyFees.isHidden = true
        MakePaymentFees.isHidden = true
        
        ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        segmentedControl.selectedSegmentIndex = 0
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(PayFeeVC.LoadSelectedLanguageData), name: NSNotification.Name(rawValue: LANGUAGE_NOTIFICATION), object:nil)
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.callSelectedLanguage()
        MonthlyFees.layer.cornerRadius = 5
        MonthlyFees.clipsToBounds = true
        
        MakePaymentFees.layer.cornerRadius = 5
        MakePaymentFees.clipsToBounds = true
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if(StrTableFrom == "Paid")
        {
            return 1
        }else{
            
            return arrPendingFee.count
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(StrTableFrom == "Paid")
        {
            return arrPaidFee.count
        }else{
            let ArrayVal:NSMutableArray = arrPendingFee[section]  as! NSMutableArray
            return ArrayVal.count
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height : CGFloat = 0
        
        if(StrTableFrom == "Paid")
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                height =  195
                
            }else{
                height =  186
                
            }
            
        }else{
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                height =  45
                
            }else{
                height =  35
                
            }
            
        }
        return height
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(StrTableFrom == "Paid")
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaidFeesTVCell", for: indexPath) as! PaidFeesTVCell
            cell.backgroundColor = UIColor.clear
            
            let Dict:NSDictionary = arrPaidFee[indexPath.row] as! NSDictionary
            cell.CreatedOnLbl.text = ": " + String(describing: Dict["CreatedOn"]!)
            cell.PaymentTypeLbl.text = ": " + String(describing: Dict["PaymentType"]!)
            let strRejected : String = String(describing: Dict["IsRejected"]!)
            if(strRejected == "0")
            {
                cell.PaymentSuccessLbl.text = ": Successfull"
            }else
            {
                cell.PaymentSuccessLbl.text = ": Rejected"
            }
            
            let TotalFee = Double(String(describing: Dict["TotalPaid"]!))
            
            cell.TotalPaidLbl.text = ": " + String(format: "%.2f", TotalFee!)
            let LateFee = Double(String(describing: Dict["LateFee"]!))
            
            cell.LateFeeLbl.text = ": " + String(format: "%.2f", LateFee!)
            
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "upcomingFeesTVCell", for: indexPath) as! upcomingFeesTVCell
            cell.backgroundColor = UIColor.white
            
            let ArrayVal:NSMutableArray = arrPendingFee[indexPath.section]  as! NSMutableArray
            let Dict : NSMutableDictionary = ArrayVal[indexPath.row] as! NSMutableDictionary
            cell.FeeTitleLbl.text = String(describing: Dict["Title"]!)
            
            
            cell.FeeValueLbl.text = ": " + String(describing: Dict["Value"]!)
            
            
            
            return cell
        }
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(StrTableFrom == "Paid")
        {
            let Dict:NSDictionary = arrPaidFee[indexPath.row] as! NSDictionary
            selectedInvoiceDict = Dict
            self.performSegue(withIdentifier: "FeeInvoiceSegue", sender: self)
        }else
        {
            
        }
        
        
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.3
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.3
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView : UIView = UIView()
        if(StrTableFrom == "Paid")
        {
            footerView.backgroundColor = UIColor.clear
            
        }else{
            footerView.backgroundColor = UIColor.lightGray
        }
        return footerView
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let headerView : UIView = UIView()
        
        
        if(StrTableFrom == "Paid")
        {
            headerView.backgroundColor = UIColor.clear
        }else{
            headerView.backgroundColor = UIColor.lightGray
        }
        return headerView
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            StrTableFrom = "Paid"
            MonthlyFees.isHidden = true
            MakePaymentFees.isHidden = true
            
            if(Util .isNetworkConnected())
            {
                self.GetPaidFeeDetailApiCalling()
            }
            else
            {
                arrPaidFee =  Childrens.getPastFee(fromDB: ChildIDString)
                if(arrPaidFee.count > 0)
                {
                    PayFeesTableView.reloadData()
                }else{
                    PayFeesTableView.reloadData()
                    Util .showAlert("", msg: NETWORK_ERROR)
                }
            }
        case 1:
            StrTableFrom = "Upcoming"
            
            if(Util .isNetworkConnected())
            {
                self.GetPendingFeeDetailApiCalling()
                
            }
            else
            {
                let reponsearr : NSMutableArray =  Childrens.getUpcomingFee(fromDB: ChildIDString)
                self.FilterUpcomingFee(filterArr: reponsearr)
                MonthlyFees.isHidden = false
                MakePaymentFees.isHidden = false
                
                if(arrPendingFee.count > 0)
                {
                    MonthlyFees.isHidden = false
                    MakePaymentFees.isHidden = false
                    PayFeesTableView.reloadData()
                }else{
                    MonthlyFees.isHidden = true
                    MakePaymentFees.isHidden = true
                    PayFeesTableView.reloadData()
                    Util .showAlert("", msg: NETWORK_ERROR)
                }
            }
        default:
            break;
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
    
    @IBAction func actionTabLogout(_ sender: Any) {
        let changePasswordVC  = self.storyboard?.instantiateViewController(withIdentifier: "ParentChangePasswordVC") as! ParentChangePasswordVC
        changePasswordVC.strFrom = "Logout"
        changePasswordVC.strFromStaff = "Child"
        changePasswordVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(changePasswordVC, animated: true, completion: nil)
    }
    
    //MARK:Monthly Fee button action
    
    @IBAction func actionMonthlyFeeButton(_ sender: UIButton) {
        
        
        if(Util .isNetworkConnected())
        {
            if(OverAllPendingFeeArr.count > 0)
            {
                MonthlyFeeArray = OverAllPendingFeeArr
                
                
                self.performSegue(withIdentifier: "monthlyFeesSegue", sender: self)
                
            }else
            {
                Util.showAlert("", msg: NO_RECORD_MESSAGE)
            }
        }else
        {
            OverAllPendingFeeArr = Childrens.getMonthlyFee(fromDB: ChildIDString)
            if(OverAllPendingFeeArr.count > 0)
            {
                MonthlyFeeArray = OverAllPendingFeeArr
                self.performSegue(withIdentifier: "monthlyFeesSegue", sender: self)
            }else{
                Util .showAlert("", msg: NETWORK_ERROR)
            }
        }
        
        
    }
    
    @IBAction func actionMakePaymentButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "makePaymentSeg", sender: self)
        
    }
    
    
    func GetPaidFeeDetailApiCalling()
    {
        showLoading()
        strApiFrom = "GetPaidFeeDetailApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + GET_PAID_FEE_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolIDString,"ChildID" : ChildIDString]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString,"GetPaidFeeDetailApi")
    }
    func GetPendingFeeDetailApiCalling()
    {
        showLoading()
        strApiFrom = "GetPendingFeeDetailApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + GET_PENDING_FEE_METHOD
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolIDString,"ChildID" : ChildIDString]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString,"GetPendingFeeDetailApi")
    }
    //MARK: API RESPONSE
    
    
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!)
    {
        hideLoading()
        if(csData != nil)
        {
            if(strApiFrom.isEqual("GetPaidFeeDetailApi"))
            {
                MonthlyFees.isHidden = true
                MakePaymentFees.isHidden = true
                
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                let emptyDict : NSDictionary = NSDictionary()
                let Dict : NSDictionary = csData?.mutableCopy() as? NSDictionary ?? emptyDict
                
                UtilObj.printLogKey(printKey: "Dict", printingValue: Dict)
                
                
                if let CheckedArray = Dict["StudentInvoices"] as? NSArray
                {
                    if(CheckedArray.count > 0){
                        let dicUser : NSDictionary = CheckedArray[0] as! NSDictionary
                        let Status = String(describing: dicUser["result"]!)
                        let Message = dicUser["Message"] as? String
                        let strAlertString = Message!
                        if(Status != "-2"){
                            
                            UtilObj.printLogKey(printKey: "CheckedArray", printingValue: CheckedArray)
                            arrPaidFee = CheckedArray
                            appDelegate.ArrPaidFeeDetail =  arrPaidFee
                            Childrens.savePastFeeDetail(arrPaidFee as! [Any], ChildIDString)
                            
                        }else{
                            Util.showAlert("", msg: strAlertString)
                        }
                        PayFeesTableView.reloadData()
                        
                    }else
                    {
                        PayFeesTableView.reloadData()
                        Util.showAlert("", msg: NO_PAID_FOUNT)
                    }
                    
                }else
                {
                    PayFeesTableView.reloadData()
                    Util.showAlert("", msg: NO_PAID_FOUNT)
                }
            }
            else      if(strApiFrom.isEqual("GetPendingFeeDetailApi"))
            {
                arrPendingFee.removeAllObjects()
                let Dict : NSDictionary = csData?.mutableCopy() as! NSDictionary
                
                UtilObj.printLogKey(printKey: "Dict", printingValue: Dict)
                
                let MonthlyArray = Dict["StudentMonthlyFees"] as? NSArray
                OverAllPendingFeeArr = MonthlyArray!
                if(OverAllPendingFeeArr.count > 0)
                {
                    MonthlyFees.isHidden = false
                    MakePaymentFees.isHidden = false
                    
                    Childrens.saveMonthlyFeeDetail(OverAllPendingFeeArr as! [Any], ChildIDString)
                    
                }else
                {
                    MonthlyFees.isHidden = true
                    MakePaymentFees.isHidden = true
                    
                    
                }
                
                if let CheckedArray = Dict["StudentFeeDetails"] as? NSArray
                {
                    if(CheckedArray.count > 0)                   {
                        
                        MonthlyFees.isHidden = false
                        MakePaymentFees.isHidden = false
                        
                        self.FilterUpcomingFee(filterArr: CheckedArray)
                        Childrens.saveUpcomingFeeDetail(CheckedArray as! [Any], ChildIDString)
                        
                        PayFeesTableView.reloadData()
                        
                    }else
                    {
                        MonthlyFees.isHidden = true
                        MakePaymentFees.isHidden = true
                        
                        PayFeesTableView.reloadData()
                        Util.showAlert("", msg: NO_PENDING_FOUNT)
                    }
                    
                }else
                { PayFeesTableView.reloadData()
                    Util.showAlert("", msg: NO_PENDING_FOUNT)
                }
            }
        }
        
        else
        {
            Util.showAlert("", msg: SERVER_ERROR)
        }
        hideLoading()
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
    
    func navTitle(){
        let titleLabel = UILabel()
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        // titleLabel.textColor = UIColor (red:128.0/255.0, green:205.0/255.0, blue: 244.0/255.0, alpha: 1)
        titleLabel.textColor = UIColor (red:0.0/255.0, green:183.0/255.0, blue: 190.0/255.0, alpha: 1)
        let secondWord : String  = languageDictionary["fee"] as? String ?? "Fee"
        let thirdWord  : String  = languageDictionary["details"] as? String ?? "Details"
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
    
    
    func FilterUpcomingFee(filterArr : NSArray)
    {
        arrPendingFee.removeAllObjects()
        
        
        for i in 0..<filterArr.count
        {
            let Dict:NSDictionary = filterArr[i] as! NSDictionary
            var CheckedArr:NSMutableArray = NSMutableArray()
            CheckedArr.removeAllObjects()
            let DescriptionText:String = String(describing: Dict["FeeName"]!)
            let FeeName : String = Util .checkNil(DescriptionText)
            if(FeeName == "" || FeeName == "0")
            {
                
            }else{
                let CheckedDict : NSMutableDictionary = ["Title": "FeeName", "Value": String(describing: Dict["FeeName"]!)]
                CheckedArr.add(CheckedDict)
                //CheckedArr.adding(CheckedDict)
                
            }
            let TotalDist:String = String(describing: Dict["Total"]!)
            let Total : String = Util .checkNil(TotalDist)
            if(Total == "" || Total == "0")
            {
                
            }else{
                let TotalFee = Double(String(describing: Dict["Total"]!))
                
                let CheckedDict : NSMutableDictionary = ["Title": "Total", "Value": String(format: "%.2f", TotalFee!)]
                CheckedArr.add(CheckedDict)
            }
            let yearlyDist:String = String(describing: Dict["Yearly"]!)
            let yearly : String = Util .checkNil(yearlyDist)
            if(yearly == "" || yearly == "0")
            {
                
            }else{
                let YearlyFee = Double(String(describing: Dict["Yearly"]!))
                
                let CheckedDict : NSMutableDictionary = ["Title": "Yearly", "Value": String(format: "%.2f", YearlyFee!)]
                CheckedArr.add(CheckedDict)
                
            }
            
            
            let TermDict:String = String(describing: Dict["Term_I"]!)
            let CheckTerm1 : String = Util .checkNil(TermDict)
            if(CheckTerm1 == "" || CheckTerm1 == "0")
            {
                
            }else{
                
                let Term1Fee = Double(String(describing: Dict["Term_I"]!))
                
                let StrTerm1 : String = String(format: "%.2f", Term1Fee!) + " From " + String(describing: Dict["Term1_From"]!) + " To " + String(describing: Dict["Term1_To"]!)
                let CheckedDict : NSMutableDictionary = ["Title": "Term_I", "Value": StrTerm1]
                CheckedArr.add(CheckedDict)
            }
            let Term2Dict:String = String(describing: Dict["Term_II"]!)
            let CheckTerm2 : String = Util .checkNil(Term2Dict)
            if(CheckTerm2 == "" || CheckTerm2 == "0")
            {
                
            }else{
                
                let Term2Fee = Double(String(describing: Dict["Term_II"]!))
                
                let StrTerm1 : String = String(format: "%.2f", Term2Fee!) + " From " + String(describing: Dict["Term2_From"]!) + " To " + String(describing: Dict["Term2_To"]!)
                
                let CheckedDict : NSMutableDictionary = ["Title": "Term_II", "Value": StrTerm1]
                CheckedArr.add(CheckedDict)
                
            }
            let Term3Dict:String = String(describing: Dict["Term_III"]!)
            let CheckTerm3 : String = Util .checkNil(Term3Dict)
            if(CheckTerm3 == "" || CheckTerm3 == "0")
            {
                
            }else{
                let Term3Fee = Double(String(describing: Dict["Term_III"]!))
                
                let StrTerm1 : String = String(format: "%.2f", Term3Fee!) + " From " + String(describing: Dict["Term3_From"]!) + " To " + String(describing: Dict["Term3_To"]!)
                let CheckedDict : NSMutableDictionary = ["Title": "Term_III", "Value": StrTerm1]
                CheckedArr.add(CheckedDict)
            }
            let Term4Dict:String = String(describing: Dict["Term_IV"]!)
            let CheckTerm4 : String = Util .checkNil(Term4Dict)
            if(CheckTerm4 == "" || CheckTerm4 == "0")
            {
                
            }else{
                let Term4Fee = Double(String(describing: Dict["Term_IV"]!))
                
                let StrTerm1 : String = String(format: "%.2f", Term4Fee!) + " From " + String(describing: Dict["Term4_From"]!) + " To " + String(describing: Dict["Term4_To"]!)
                let CheckedDict : NSMutableDictionary = ["Title": "Term_IV", "Value": StrTerm1]
                CheckedArr.add(CheckedDict)
            }
            
            UtilObj.printLogKey(printKey: "CheckedArr", printingValue: CheckedArr)
            
            arrPendingFee.add(CheckedArr)
            UtilObj.printLogKey(printKey: "arrPendingFee", printingValue: arrPendingFee)
            
            
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "monthlyFeesSegue")
        {
            let segueid = segue.destination as! MonthlyFeesVC
            segueid.MonthlyFeeArray = MonthlyFeeArray
        }
        else if(segue.identifier == "FeeInvoiceSegue")
        {
            let segueid = segue.destination as! FeeInvoiceVC
            segueid.InvoiceDict = selectedInvoiceDict
            
            
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
            self.view.semanticContentAttribute = .forceRightToLeft
            self.PayFeesTableView.semanticContentAttribute = .forceRightToLeft
            BottomView.semanticContentAttribute = .forceRightToLeft
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.PayFeesTableView.semanticContentAttribute = .forceLeftToRight
            BottomView.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            
            
        }
        HomeLabel.text = LangDict["home"] as? String
        //        LanguageLabel.text = LangDict["txt_language"] as? String
        FAQLabel.text = LangDict["faq"] as? String
        PasswordLabel.text = LangDict["txt_password"] as? String
        LogoutLabel.text = LangDict["txt_menu_setting"] as? String
        strNoRecordAlert = LangDict["no_exams"] as? String ?? "No Exams Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        segmentedControl.setTitle(LangDict["paid_details"] as? String, forSegmentAt: 0)
        segmentedControl.setTitle(LangDict["upcomming"] as? String, forSegmentAt: 1)
        
        self.loadViewData()
        
    }
    
    func loadViewData(){
        navTitle()
        
        if(Util .isNetworkConnected())
        {
            self.GetPaidFeeDetailApiCalling()
        }
        else
        {
            arrPaidFee =  Childrens.getPastFee(fromDB: ChildIDString)
            if(arrPaidFee.count > 0)
            {
                PayFeesTableView.reloadData()
            }else{
                Util .showAlert("", msg: NETWORK_ERROR)
            }
            
        }
    }
    
    @objc func LoadSelectedLanguageData(notification:Notification) -> Void {
        self.callSelectedLanguage()
    }
    
}
