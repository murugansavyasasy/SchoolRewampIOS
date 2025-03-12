//
//  FeeDetailVC.swift
//  Sample RazorPay
//
//  Created by Preethi on 18/09/20.
//  Copyright © 2020 shenll. All rights reserved.
//

import UIKit
import WebKit
import ObjectMapper

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
}



class FeeDetailVC: UIViewController,Apidelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var feeDetailReceiptTv: UITableView!
    
    @IBOutlet weak var adViewHeight: NSLayoutConstraint!
    @IBOutlet weak var AdView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var invoiceView: UIView!
    @IBOutlet weak var paymentView: UIView!
    
    @IBOutlet weak var paymentWebView: WKWebView!
    
    
    @IBOutlet weak var amountToPaidLabel: UILabel!
    @IBOutlet weak var onLineChargesLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    
    @IBOutlet weak var lateFeeChargesLabel: UILabel!
    @IBOutlet weak var lateFeeAmountLabel: UILabel!
    @IBOutlet weak var lateFeeView: UIView!
    
    @IBOutlet weak var mainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var latefeeViewHeight: NSLayoutConstraint!
    
    // MARK:- UILabel Deceleration
    @IBOutlet weak var alertView: UIView!
    
    // MARK:- UISegmentedControl Deceleration
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK:- NSLayoutConstraint Deceleration
    @IBOutlet weak var makeButtonHeight: NSLayoutConstraint!
    
    // MARK:- UISegmentedControl Deceleration
    @IBOutlet weak var makePaymentButton: UIButton!
    
    var selectedTermSection = NSMutableArray()
    var selectedTermRow = NSMutableArray()
    var selectedMonthlySection = NSMutableArray()
    var selectedMonthlyRow = NSMutableArray()
    var termFeeSectionArray = NSMutableArray()
    var monthlyFeeSectionArray = NSMutableArray()
    var selectedTermFeeArray = NSMutableArray()
    var selectedOtherFeeArray = NSMutableArray()
    var selectedTermFeeRowArray = NSMutableArray()
    var selectedOtherFeeRowArray = NSMutableArray()
    var transferPaymentArray = NSMutableArray()
    var languageDictionary = NSDictionary()
    var lateFeeArray = NSMutableArray()
    let rowIdentifier = "FeeDetailReceiptTableViewCell"
    var getReceipt : [FeeDetailReceiptData] = []
    
    //MARK: - INSTANCE VARIABLES
    
    
    // var razorpay: Razorpay!

    
    let PAYMENT_URL = "https://api.razorpay.com/v1/payments/"
    
    // MARK:- Int Deceleration
    var strSegmentIndex = 0
    var vsPayAmount : Double  = 0.0
    var PaidAmount  : Double = 0.0
    var razorPaymentAmount  : Double = 0.0
    var lateFeeAmount  : Double = 0.0
    var getadID : Int!
    // MARK:- String Deceleration
    var strApiFrom = ""
    var strChildName = String()
    var ChildIDString = String()
    var razorApiKey = String()
    var razorSecretKey = String()
    var paymentID = String()
    var SchoolIDString = String()
    var strLanguage = String()
    var termTitle = String()
    var otherTitle = String()
    var strSomething = String()
    var strOnlinePaymentAvailable = String()
    var alrMaxMessage = "Please pay previous Term Fees"
    var altOtherMessage = "Please pay previous Month Fees"
    var discountTitle = String()
    var amountPaidTitle = String()
    var accountId = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let UtilObj = UtilClass()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var isLateFeeConfig = String()
    var SchoolId = String()
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    
    
    weak var timer: Timer?
    
    var menuId : String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Fee Details"
        
        loadWebView()
        
        feeDetailReceiptTv.delegate = self
        feeDetailReceiptTv.dataSource = self
        ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
    
        async {
            do {
                //               
                menuId = AdConstant.getMenuId as String
                print("menu_id:\(AdConstant.getMenuId)")
                
                
                
                let AdModal = AdvertismentModal()
                AdModal.MemberId = ChildIDString
                AdModal.MemberType = "student"
                
                
                AdModal.MenuId = menuId
                AdModal.SchoolId = SchoolIDString
                
                
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
        
        
        
        
        
        
        
        
        
        
        self.initialLoad()
        
        
        
        let imgTap = AdGesture (target: self, action: #selector(viewTapped))
        AdView.addGestureRecognizer(imgTap)
        
        
        let rowNib = UINib(nibName: rowIdentifier, bundle: nil)
        feeDetailReceiptTv.register(rowNib, forCellReuseIdentifier: rowIdentifier)
        
        
        
    }
    
    func startTimer() {
        
        print("AdConstant1adDataListcount",AdConstant.adDataList.count)
        if AdConstant.adDataList.count > 0 {
            print("IFCONDITON",AdConstant.adDataList.count)
            let url : String =  AdConstant.adDataList[0].contentUrl!
            self.imgaeURl = AdConstant.adDataList[0].redirectUrl!
            self.AdName = AdConstant.adDataList[0].advertisementName!
            self.getadID = AdConstant.adDataList[0].id!
            self.imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
            
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
                //                
                self!.imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
            }
        }else {
            print("adDataListISEMPTY")
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
    
    
    func loadWebView() {
        ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        
        var studId = ChildIDString
        var schoolId = SchoolIDString
        
        print("studId\(studId)")
        print("schoolId\(schoolId)")
        appDelegate.FeePaymentGateway =  appDelegate.FeePaymentGateway.replacingOccurrences(of: ":student_id/:school_id", with: "")
        let str_url = appDelegate.FeePaymentGateway + "\(studId)" + "/" + "\(schoolId)"
        print("WebURL",str_url)
        let url: URL = URL(string: str_url)!
        //    http://testing.schoolchimes.com/#/online-fee-payment/7783339/5512/details
        paymentWebView.load(URLRequest(url: url))
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func initialLoad(){
        self.title = "Fee Details"
        //
        self.alertView.isHidden = true
        strChildName = String(describing: appDelegate.SchoolDetailDictionary["ChildName"]!)
        ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        self.segmentedControl.selectedSegmentIndex = 0
        self.callSelectedLanguage()
        self.GetFeeDetailApiCalling()
    }
    
    @objc func termSectionTabAction(sender: UIButton){
        let buttonTag = sender.tag
        
        if(self.selectedTermSection.contains(buttonTag)){
            self.selectedTermSection.remove(buttonTag)
        }else{
            self.selectedTermSection.add(buttonTag)
        }
    }
    
    @objc func monthlySectionTabAction(sender: UIButton){
        let buttonTag = sender.tag
        if(self.selectedMonthlySection.contains(buttonTag)){
            self.selectedMonthlySection.remove(buttonTag)
        }else{
            self.selectedMonthlySection.add(buttonTag)
        }
    }
    
    @objc func actionTermDetailButton(sender: UIButton){
        let buttonTag = sender.accessibilityIdentifier
        if(self.selectedTermRow.contains(buttonTag)){
            self.selectedTermRow.remove(buttonTag)
        }else{
            self.selectedTermRow.add(buttonTag)
        }
        
        print(selectedTermRow)
    }
    
    @objc func actionMonthlyDetailButton(sender: UIButton){
        let buttonTag = sender.accessibilityIdentifier
        if(self.selectedMonthlyRow.contains(buttonTag)){
            self.selectedMonthlyRow.remove(buttonTag)
        }else{
            self.selectedMonthlyRow.add(buttonTag)
        }
        print(selectedMonthlyRow)
        //        self.monthlyFeeTableView.reloadData()
    }
    
    
    @objc func actionTermRadioButton(sender: UIButton){
        let buttonTag : String = sender.accessibilityIdentifier!
        let SectionRow = buttonTag.components(separatedBy: ":")
        
        let section: Int = Int(SectionRow[0])!
        let row: Int = Int(SectionRow[1])!
        
        let sectionDict : NSDictionary =  self.termFeeSectionArray[section] as! NSDictionary
        
        let cellArray : NSArray = sectionDict["FeesDetails"] as! NSArray
        
        let dueResultPredicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K != %@","IsPaid" ,"No","FeeName","VSTotal")
        
        let dueArray = cellArray.filter { dueResultPredicate.evaluate(with: $0) } as NSArray
        
        
        
        
        var notContainArray = NSMutableArray()
        for i in 0..<section{
            
            let sectionDict : NSDictionary =  self.termFeeSectionArray[i] as! NSDictionary
            
            let cellArray : NSArray = sectionDict["FeesDetails"] as! NSArray
            
            let dueResultPredicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K != %@","IsPaid" ,"No","FeeName","VSTotal")
            
            let dueArray1 = cellArray.filter { dueResultPredicate.evaluate(with: $0) } as NSArray
            
            if(!self.selectedTermFeeArray.contains(i) && dueArray1.count > 0){
                notContainArray.add("1")
            }
        }
        
        if(notContainArray.count > 0){
            self.showAlert(alert: "", message: alrMaxMessage)
        }else{
            
            if(self.selectedTermFeeRowArray.contains(buttonTag)){
                self.selectedTermFeeRowArray.remove(buttonTag)
                if(self.selectedTermFeeArray.contains(section)){
                    self.selectedTermFeeArray.remove(section)
                }
                
                let sectionCellValue = section + 1
                for k in sectionCellValue..<self.termFeeSectionArray.count{
                    if(self.selectedTermFeeArray.contains(k)){
                        self.selectedTermFeeArray.remove(k)
                    }
                    
                    let sectionDict : NSDictionary =  self.termFeeSectionArray[k] as! NSDictionary
                    
                    let cellArray : NSArray = sectionDict["FeesDetails"] as! NSArray
                    
                    let dueResultPredicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K != %@","IsPaid" ,"No","FeeName","VSTotal")
                    
                    let dueArray1 = cellArray.filter { dueResultPredicate.evaluate(with: $0) } as NSArray
                    
                    for j in 0..<dueArray1.count{
                        let sectionRow1 = String(describing: sectionCellValue ) + ":" +  String(describing: j)
                        if(self.selectedTermFeeRowArray.contains(sectionRow1)){
                            self.selectedTermFeeRowArray.remove(sectionRow1)
                        }
                        
                    }
                    
                }
            }else{
                self.selectedTermFeeRowArray.add(buttonTag)
                var selectedRowCount = NSMutableArray()
                for j in 0..<dueArray.count{
                    let sectionRow1 = String(describing: section ) + ":" +  String(describing: j)
                    
                    if(self.selectedTermFeeRowArray.contains(sectionRow1)){
                        selectedRowCount.add("1")
                    }
                    
                }
                if(selectedRowCount.count == dueArray.count){
                    if(!self.selectedTermFeeArray.contains(section)){
                        self.selectedTermFeeArray.add(section)
                    }
                }
                
                
            }
            
            //
        }
        
    }
    
    @objc func actionMonthlyRadioButton(sender: UIButton){
        
        let buttonTag : String = sender.accessibilityIdentifier!
        let SectionRow = buttonTag.components(separatedBy: ":")
        
        let section: Int = Int(SectionRow[0])!
        let row: Int = Int(SectionRow[1])!
        
        let sectionDict : NSDictionary =  self.monthlyFeeSectionArray[section] as! NSDictionary
        let sectionArray : NSArray = sectionDict["FeeDetails"] as! NSArray
        if(sectionArray.count > 0){
            let sectionDict : NSDictionary = sectionArray[0] as! NSDictionary
            let cellArray : NSArray = sectionDict["MonthDetails"] as! NSArray
            
            
            let dueResultPredicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K != %@","IsPaid" ,"No","MonthName","VSTotal")
            
            let dueArray = cellArray.filter { dueResultPredicate.evaluate(with: $0) } as NSArray
            
            var notContainArray = NSMutableArray()
            for i in 0..<section{
                
                let sectionDict : NSDictionary =  self.monthlyFeeSectionArray[i] as! NSDictionary
                let sectionArray : NSArray = sectionDict["FeeDetails"] as! NSArray
                
                if(sectionArray.count > 0){
                    let sectionDict : NSDictionary = sectionArray[0] as! NSDictionary
                    let cellArray : NSArray = sectionDict["MonthDetails"] as! NSArray
                    
                    
                    let dueResultPredicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K != %@","IsPaid" ,"No","MonthName","VSTotal")
                    
                    let dueArray1 = cellArray.filter { dueResultPredicate.evaluate(with: $0) } as NSArray
                    
                }
            }
            
            if(notContainArray.count > 0){
                self.showAlert(alert: "", message: altOtherMessage)
            }else{
                
                var notContainArray = NSMutableArray()
                for i in 0..<row{
                    let sectionRow =  String(describing: section ) + ":" +  String(describing: i)
                    if(!self.selectedOtherFeeRowArray.contains(sectionRow)){
                        notContainArray.add("1")
                    }
                }
                
                if(notContainArray.count > 0){
                    self.showAlert(alert: "", message: altOtherMessage)
                }else{
                    if(self.selectedOtherFeeRowArray.contains(buttonTag)){
                        
                        for k in row..<dueArray.count{
                            let index = String(describing: section) + ":" +   String(describing: k)
                            if(self.selectedOtherFeeRowArray.contains(index)){
                                self.selectedOtherFeeRowArray.remove(index)
                            }
                            
                        }
                        
                        
                        if(self.selectedOtherFeeArray.contains(section)){
                            self.selectedOtherFeeArray.remove(section)
                        }
                    }else{
                        self.selectedOtherFeeRowArray.add(buttonTag)
                    }
                }
                
            }
            
        }
        
        print(selectedOtherFeeRowArray)
    }
    
    
    
    
    func downloadImage(from url: URL) {
        
        
        
        getData(from:url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            
            DispatchQueue.main.async() { [weak self] in
                
            }
        }
        
        
        
        //
    }
    
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    @objc func termFeeRadioAction(sender: UIButton){
        //ccc
        let buttonTag = sender.tag
        let sectionDict : NSDictionary =  self.termFeeSectionArray[buttonTag] as! NSDictionary
        let cellArray : NSArray = sectionDict["FeesDetails"] as! NSArray
        
        let dueResultPredicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K != %@","IsPaid" ,"No","FeeName","VSTotal")
        
        let dueArray = cellArray.filter { dueResultPredicate.evaluate(with: $0) } as NSArray
        
        var notContainArray = NSMutableArray()
        for i in 0..<buttonTag{
            let sectionDict : NSDictionary =  self.termFeeSectionArray[i] as! NSDictionary
            let cellArray : NSArray = sectionDict["FeesDetails"] as! NSArray
            
            let dueResultPredicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K != %@","IsPaid" ,"No","FeeName","VSTotal")
            
            let dueArray1 = cellArray.filter { dueResultPredicate.evaluate(with: $0) } as NSArray
            
            if(!self.selectedTermFeeArray.contains(i) && dueArray1.count > 0){
                notContainArray.add("1")
            }
        }
        
        if(notContainArray.count > 0){
            self.showAlert(alert: "", message: alrMaxMessage)
        }else{
            if(self.selectedTermFeeArray.contains(buttonTag)){
                for k in buttonTag..<self.termFeeSectionArray.count{
                    let sectionDict : NSDictionary =  self.termFeeSectionArray[k] as! NSDictionary
                    let cellArray : NSArray = sectionDict["FeesDetails"] as! NSArray
                    
                    let dueResultPredicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K != %@","IsPaid" ,"No","FeeName","VSTotal")
                    
                    let dueArray1 = cellArray.filter { dueResultPredicate.evaluate(with: $0) } as NSArray
                    
                    if(self.selectedTermFeeArray.contains(k)){
                        self.selectedTermFeeArray.remove(k)
                        for i in 0..<dueArray1.count{
                            let sectionRow =  String(describing: k ) + ":" + String(describing: i)
                            if(self.selectedTermFeeRowArray.contains(sectionRow)){
                                self.selectedTermFeeRowArray.remove(sectionRow)
                            }
                        }
                    }else{
                        for i in 0..<dueArray1.count{
                            let sectionRow =  String(describing: k ) + ":" + String(describing: i)
                            if(self.selectedTermFeeRowArray.contains(sectionRow)){
                                self.selectedTermFeeRowArray.remove(sectionRow)
                            }
                        }
                    }
                }
            }else{
                self.selectedTermFeeArray.add(buttonTag)
                
                for i in 0..<dueArray.count{
                    let sectionRow =  String(describing: buttonTag ) + ":" + String(describing: i)
                    if(!self.selectedTermFeeRowArray.contains(sectionRow)){
                        self.selectedTermFeeRowArray.add(sectionRow)
                    }
                }
            }
            
            
        }
    }
    
    @objc func monthlyFeeRadioAction(sender: UIButton){
        let buttonTag = sender.tag
        var notContainArray = NSMutableArray()
        let sectionDict : NSDictionary =  self.monthlyFeeSectionArray[buttonTag] as! NSDictionary
        let sectionArray : NSArray = sectionDict["FeeDetails"] as! NSArray
        if(sectionArray.count > 0){
            let sectionDict : NSDictionary = sectionArray[0] as! NSDictionary
            let cellArray : NSArray = sectionDict["MonthDetails"] as! NSArray
            
            let dueResultPredicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K != %@","IsPaid" ,"No","MonthName","VSTotal")
            
            let dueArray = cellArray.filter { dueResultPredicate.evaluate(with: $0) } as NSArray
            
            for i in 0..<buttonTag{
                let sectionDict : NSDictionary =  self.monthlyFeeSectionArray[i] as! NSDictionary
                let sectionArray : NSArray = sectionDict["FeeDetails"] as! NSArray
                if(sectionArray.count > 0){
                    let sectionDict : NSDictionary = sectionArray[0] as! NSDictionary
                    let cellArray : NSArray = sectionDict["MonthDetails"] as! NSArray
                    
                    
                    let dueResultPredicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K != %@","IsPaid" ,"No","MonthName","VSTotal")
                    
                    let dueArray1 = cellArray.filter { dueResultPredicate.evaluate(with: $0) } as NSArray
                    
                    
                }
                
                
            }
            
            if(self.selectedOtherFeeArray.contains(buttonTag)){
                self.selectedOtherFeeArray.remove(buttonTag)
                for i in 0..<dueArray.count{
                    let sectionRow = String(describing: buttonTag ) + ":" + String(describing: i)
                    
                    if(self.selectedOtherFeeRowArray.contains(sectionRow)){
                        self.selectedOtherFeeRowArray.remove(sectionRow)
                    }
                }
            }else{
                self.selectedOtherFeeArray.add(buttonTag)
                for i in 0..<dueArray.count{
                    let sectionRow = String(describing: buttonTag ) + ":" + String(describing: i)
                    if(!self.selectedOtherFeeRowArray.contains(sectionRow)){
                        self.selectedOtherFeeRowArray.add(sectionRow)
                    }
                }
            }
            //
        }
        
    }
    
    
    
    @IBAction func actionTermFeeDownButton(_ sender: UIButton) {
        self.selectedTermRow.removeAllObjects()
        self.selectedTermSection.removeAllObjects()
    }
    
    @IBAction func actionMonthlyFeeDownButton(_ sender: UIButton) {
        self.selectedMonthlyRow.removeAllObjects()
        self.selectedMonthlySection.removeAllObjects()
        //        self.monthlyFeeTableView.reloadData()
    }
    
    @IBAction func actionMakePayment(_ sender: UIButton) {
        if(Util .isNetworkConnected()){
            PaidAmount  = 0.0
            // vsPayAmount = 0.0
            var vsFinalPayAmount : Double = 0.0
            
            var otherChargesAmount : Double = 0.0
            
            var termArray = NSMutableArray()
            var otherFeeArray = NSMutableArray()
            var otherFeeDict = NSMutableDictionary()
            var otherArray = NSMutableArray()
            var lateFeeDict = NSMutableDictionary()
            
            lateFeeArray = []
            transferPaymentArray = []
            var otherFeePaidAmount : Double = 0.0
            appDelegate.razorPaymentDict.removeAllObjects()
            if(self.selectedTermFeeArray.count > 0 || self.selectedOtherFeeArray.count > 0 || self.selectedTermFeeRowArray.count > 0 || self.selectedOtherFeeRowArray.count > 0){
                
                appDelegate.razorPaymentDict["StudentId"] =  self.ChildIDString
                appDelegate.razorPaymentDict["SchoolID"] =  self.SchoolIDString
                
                for i in 0..<self.termFeeSectionArray.count{
                    let sectionDict : NSDictionary =  self.termFeeSectionArray[i] as! NSDictionary
                    let cellArray : NSArray = sectionDict["FeesDetails"] as! NSArray
                    let dueResultPredicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K != %@","IsPaid" ,"No","FeeName","VSTotal")
                    let dueArray = cellArray.filter { dueResultPredicate.evaluate(with: $0) } as NSArray
                    print(dueArray)
                    if(selectedTermFeeArray.contains(i)){
                        for j in 0..<dueArray.count{
                            let Dict : NSDictionary = dueArray[j] as! NSDictionary
                            let myDict:NSMutableDictionary =
                            ["TermGroupTypeId" : String(describing: Dict["TermGroupTypeId"]!),
                             "FeeId" : String(describing: Dict["FeeId"]!),
                             "FeeAmount" : String(describing: Dict["FeeAmount"]!),
                             "PaidAmount" :  String(describing: Dict["AmountToBePaid"]!),
                             "Pending" :  String(describing: Dict["Pending"]!),
                             "DiscountAmount" :  String(describing: Dict["DiscountAmount"]!),
                             "DiscountAmountFlag" :   String(describing: Dict["AmountToBePaid"]!) == "0" ? "1" : "0",
                            ]
                            lateFeeDict = [
                                "feeId": String(describing: Dict["FeeId"]!),
                                "feeGroupTypeId": String(describing: Dict["TermGroupTypeId"]!),
                                "otherFeeMonthId":"0"]
                            
                            if(!lateFeeArray.contains(lateFeeDict)){
                                lateFeeArray.add(lateFeeDict)
                                
                            }
                            
                            let paid : Double = Double(String(describing: Dict["AmountToBePaid"]!)) as! Double
                            let otherCharge : Double = Double(String(describing: Dict["OtherChargesRP"]!)) as! Double
                            self.PaidAmount = self.PaidAmount  + paid
                            otherChargesAmount = otherChargesAmount + otherCharge
                            
                            
                            termArray.add(myDict)
                            
                            let transferDict:NSMutableDictionary =
                            ["account" : String(describing: Dict["AccountID"]!),
                             "amount" : String(describing: Dict["AmountToBePaidRP"]!),
                             "currency" : "INR"]
                            self.transferPaymentArray.add(transferDict)
                            
                        }
                    }else{
                        
                        for j in 0..<selectedTermFeeRowArray.count{
                            let index : String  = selectedTermFeeRowArray[j] as! String
                            let sectionRow = index.components(separatedBy: ":")
                            
                            let section: Int = Int(sectionRow[0])!
                            let row: Int = Int(sectionRow[1])!
                            
                            
                            if(section == i){
                                let Dict : NSDictionary = dueArray[row] as! NSDictionary
                                let myDict:NSMutableDictionary =
                                ["TermGroupTypeId" : String(describing: Dict["TermGroupTypeId"]!),
                                 "FeeId" : String(describing: Dict["FeeId"]!),
                                 "FeeAmount" : String(describing: Dict["FeeAmount"]!),
                                 "PaidAmount" :  String(describing: Dict["AmountToBePaid"]!),
                                 "Pending" :  String(describing: Dict["Pending"]!),
                                 "DiscountAmount" :  String(describing: Dict["DiscountAmount"]!),
                                 "DiscountAmountFlag" :  String(describing: Dict["AmountToBePaid"]!) == "0" ? "1" : "0",
                                ]
                                let paid : Double = Double(String(describing: Dict["AmountToBePaid"]!)) as! Double
                                let otherCharge : Double = Double(String(describing: Dict["OtherChargesRP"]!)) as! Double
                                self.PaidAmount = self.PaidAmount  + paid
                                print("vsPayAmount21 \(vsPayAmount)")
                                
                                // vsPayAmount = vsPayAmount  + otherCharge
                                otherChargesAmount = otherChargesAmount + otherCharge
                                
                                print("vsPayAmount2 \(vsPayAmount) : otherCharge \(otherCharge)")
                                
                                termArray.add(myDict)
                                lateFeeDict = [
                                    "feeId": String(describing: Dict["FeeId"]!),
                                    "feeGroupTypeId": String(describing: Dict["TermGroupTypeId"]!),
                                    "otherFeeMonthId":"0"]
                                
                                lateFeeArray.add(lateFeeDict)
                                
                                let transferDict:NSMutableDictionary =
                                ["account" : String(describing: Dict["AccountID"]!),
                                 "amount" : String(describing: Dict["AmountToBePaidRP"]!),
                                 "currency" : "INR"]
                                self.transferPaymentArray.add(transferDict)
                            }
                            
                            
                        }
                    }
                }
                
                print("vsPayAmount Final \(vsPayAmount)")
                
                
                for i in 0..<self.monthlyFeeSectionArray.count{
                    let sectionDict : NSDictionary =  self.monthlyFeeSectionArray[i] as! NSDictionary
                    let sectionArray : NSArray = sectionDict["FeeDetails"] as! NSArray
                    if(sectionArray.count > 0){
                        let sectionDict : NSDictionary = sectionArray[0] as! NSDictionary
                        let cellArray : NSArray = sectionDict["MonthDetails"] as! NSArray
                        
                        let dueResultPredicate = NSPredicate(format: "%K CONTAINS[c] %@ AND %K != %@","IsPaid" ,"No","MonthName","VSTotal")
                        let dueArray = cellArray.filter { dueResultPredicate.evaluate(with: $0) } as NSArray
                        if(selectedOtherFeeArray.contains(i)){
                            for j in 0..<dueArray.count{
                                let Dict : NSDictionary = dueArray[j] as! NSDictionary
                                let myDict:NSMutableDictionary =
                                ["MonthId" : String(describing: Dict["MonthId"]!),
                                 "AmountPerMonth" : String(describing: Dict["AmountPerMonth"]!),
                                 "PaidAmount" :  String(describing: Dict["AmountToBePaid"]!),
                                 "Pending" :  String(describing: Dict["Pending"]!),
                                 "DiscountAmount" :  String(describing: Dict["DiscountAmount"]!),
                                 
                                ]
                                let paid : Double = Double(String(describing: Dict["AmountToBePaid"]!)) as! Double
                                let otherCharge : Double = Double(String(describing: Dict["OtherChargesRP"]!)) as! Double
                                otherFeePaidAmount =  otherFeePaidAmount + paid
                                self.PaidAmount = self.PaidAmount  + paid
                                print("vsPayAmount31 \(vsPayAmount)")
                                otherChargesAmount = otherChargesAmount + otherCharge
                                
                                
                                // vsPayAmount = vsPayAmount  + otherCharge
                                print("vsPayAmount3 \(vsPayAmount) : otherCharge \(otherCharge)")
                                
                                otherArray.add(myDict)
                                
                                lateFeeDict = [
                                    "feeId": String(describing: sectionDict["FeeId"]!),
                                    "feeGroupTypeId": String(describing: sectionDict["TermGroupTypeId"]!),
                                    "otherFeeMonthId":  String(describing: Dict["MonthId"]!)]
                                
                                lateFeeArray.add(lateFeeDict)
                                let transferDict:NSMutableDictionary =
                                ["account" : String(describing: Dict["AccountID"]!),
                                 "amount" : String(describing: Dict["AmountToBePaidRP"]!),
                                 "currency" : "INR"]
                                self.transferPaymentArray.add(transferDict)
                                
                            }
                        }else{
                            
                            for j in 0..<selectedOtherFeeRowArray.count{
                                
                                
                                let index : String  = selectedOtherFeeRowArray[j] as! String
                                let sectionRow = index.components(separatedBy: ":")
                                
                                let section: Int = Int(sectionRow[0])!
                                let row: Int = Int(sectionRow[1])!
                                
                                
                                
                                
                                if(section == i){
                                    let Dict : NSDictionary = dueArray[row] as! NSDictionary
                                    let myDict:NSMutableDictionary =
                                    ["MonthId" : String(describing: Dict["MonthId"]!),
                                     "AmountPerMonth" : String(describing: Dict["AmountPerMonth"]!),
                                     "PaidAmount" :  String(describing: Dict["AmountToBePaid"]!),
                                     "Pending" :  String(describing: Dict["Pending"]!),
                                     "DiscountAmount" :  String(describing: Dict["DiscountAmount"]!),
                                     
                                    ]
                                    let paid : Double = Double(String(describing: Dict["AmountToBePaid"]!)) as! Double
                                    let otherCharge : Double = Double(String(describing: Dict["OtherChargesRP"]!)) as! Double
                                    otherFeePaidAmount =  otherFeePaidAmount + paid
                                    self.PaidAmount = self.PaidAmount  + paid
                                    print("vsPayAmount41 \(vsPayAmount)")
                                    otherChargesAmount = otherChargesAmount + otherCharge
                                    
                                    // vsPayAmount = vsPayAmount  + otherCharge
                                    print("vsPayAmount4 \(vsPayAmount) : otherCharge \(otherCharge)")
                                    otherArray.add(myDict)
                                    lateFeeDict = [
                                        "feeId": String(describing: sectionDict["FeeId"]!),
                                        "feeGroupTypeId": String(describing: sectionDict["TermGroupTypeId"]!),
                                        "otherFeeMonthId":  String(describing: Dict["MonthId"]!)]
                                    
                                    lateFeeArray.add(lateFeeDict)
                                    
                                    let transferDict:NSMutableDictionary =
                                    ["account" : String(describing: Dict["AccountID"]!),
                                     "amount" : String(describing: Dict["AmountToBePaidRP"]!),
                                     "currency" : "INR"]
                                    self.transferPaymentArray.add(transferDict)
                                    
                                }
                            }
                        }
                        
                        otherFeeDict["TermGroupTypeId"] =  String(describing: sectionDict["TermGroupTypeId"]!)
                        otherFeeDict["FeeId"] =  String(describing: sectionDict["FeeId"]!)
                        otherFeeDict["FeeAmount"] =  String(describing: sectionDict["FeeAmount"]!)
                        otherFeeDict["PaidAmount"] =  String(describing: otherFeePaidAmount)
                        otherFeeDict["DiscountAmount"] =  String(describing: sectionDict["DiscountAmount"]!)
                        otherFeeDict["DiscountAmountFlag"] =  Int(otherFeePaidAmount) == 0 ? "1" : "0"
                        
                    }
                    
                    
                }
                
                
                
                otherFeeDict["monthDetails"] =  otherArray
                otherFeeArray.add(otherFeeDict)
                
                vsFinalPayAmount = vsPayAmount  + otherChargesAmount
                
                self.razorPaymentAmount = PaidAmount + (vsFinalPayAmount/100)
                self.totalAmountLabel.text =  "₹ " + String(format: "%.2f",  self.razorPaymentAmount )
                self.amountToPaidLabel.text =  "₹ " + String(format: "%.2f",  self.PaidAmount)
                self.onLineChargesLabel.text =  "₹ " + String(format: "%.2f", (vsFinalPayAmount/100))
                appDelegate.razorPaymentDict["TotalAmount"] =  String(describing:  self.PaidAmount)
                appDelegate.razorPaymentDict["TermFees"] = termArray
                appDelegate.razorPaymentDict["OtherFees"] = otherFeeArray
                
                if(Int(self.PaidAmount) == 0){
                    print("No Fees to paid")
                    self.callFeePaymentApiCall()
                }else{
                    //mainViewHeight.constant = 410
                    // isLateFeeConfig = "0"
                    if(isLateFeeConfig == "1"){
                        mainViewHeight.constant = 410
                        latefeeViewHeight.constant = 60
                        lateFeeView.isHidden = false
                        callLateFeePaymentApiCall()
                        
                    }else{
                        mainViewHeight.constant = 350
                        latefeeViewHeight.constant = 0
                        lateFeeView.isHidden = true
                        self.alertView.isHidden = false
                    }
                    
                }
                
            }else{
                self.showAlert(alert: "", message: "Please choose a fees")
            }
        }else{
            Util .showAlert("", msg: NETWORK_ERROR)
        }
        
    }
    
    @IBAction func actionCancel(_ sender: UIButton) {
        mainViewHeight.constant = 410
        self.alertView.isHidden = true
    }
    
    @IBAction func payNowClicked(_ sender: Any) {
        if(Util .isNetworkConnected()){
            let options: [String:Any] = [
                "amount" : String(format: "%.0f",  (self.razorPaymentAmount * 100)) , //mandatory in paise like:- 1000 paise ==  10 rs
                "description": "Payment Transfer",
                "image": UIImage(named: "oldSplashLogo") as Any,
                "name": strChildName,
                
                
            ]
            
            // razorpay?.open(options)
            self.navigationController?.isNavigationBarHidden = true
            
        }else{
            Util .showAlert("", msg: NETWORK_ERROR)
        }
        
    }
    
    @IBAction func segmentSelection(_ sender: UISegmentedControl){
        
        print("strSegmentIndex",strSegmentIndex)
        
        
        
        
        
        
        if segmentedControl.selectedSegmentIndex == 0 {
            paymentView.isHidden = false
            invoiceView.isHidden = true
        }else if segmentedControl.selectedSegmentIndex == 1 {
            paymentView.isHidden = true
            invoiceView.isHidden = false
            feeDetailReceiptTv.dataSource = self
            feeDetailReceiptTv.delegate = self
            feeDetailReceiptTv.reloadData()
            GetFeeDetailReceipt()
        }
    }
    
    // MARK:- Api Deceleration
    
    func GetFeeDetailApiCalling(){
        
        if(Util .isNetworkConnected()){
            showLoading()
            strApiFrom = "GetFeeDetails"
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
            let requestStringer = baseUrlString! + GET_NEW_PAID_FEE_METHOD + self.ChildIDString + "&SchoolID=" + self.SchoolIDString
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["SchoolID" : SchoolIDString,"ChildID" : ChildIDString]
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.getFunction(requestString, "GetPaidFeeDetailApi")
        }else{
            Util .showAlert("", msg: NETWORK_ERROR)
        }
    }
    
    func callCaptureApiCall(){
        if(Util .isNetworkConnected()){
            showLoading()
            strApiFrom = "Capture"
            let strSecretKey = self.razorApiKey + ":" + self.razorSecretKey
            
            let token =  "Basic " + strSecretKey.toBase64()
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let requestStringer = PAYMENT_URL  + paymentID + "/capture"
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["amount" : String(describing: Int((self.razorPaymentAmount * 100))) ,"currency" : "INR"]
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.callRazorPayment(requestString, myString, token, "Capture")
        }else{
            Util .showAlert("", msg: NETWORK_ERROR)
        }
        
    }
    
    func callTransferApiCall(){
        if(Util .isNetworkConnected()){
            showLoading()
            strApiFrom = "Transfer"
            let strSecretKey = self.razorApiKey + ":" + self.razorSecretKey
            
            let token =  "Basic " + strSecretKey.toBase64()
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let requestStringer = PAYMENT_URL + paymentID + "/transfers"
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            
            let myDict:NSMutableDictionary = ["transfers" : self.transferPaymentArray]
            let myString = Util.convertDictionary(toString: myDict)
            apiCall.callRazorPayment(requestString, myString, token, "Transfer")
        }else{
            Util .showAlert("", msg: NETWORK_ERROR)
        }
        
    }
    
    func callFeePaymentApiCall(){
        if(Util .isNetworkConnected()){
            showLoading()
            strApiFrom = "FeePayment"
            let apiCall = API_call.init()
            apiCall.delegate = self;
            let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
            let requestStringer = baseUrlString! + POST_PAYMENT_FEE
            let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let jsonData = try! JSONSerialization.data(withJSONObject:  appDelegate.razorPaymentDict, options: [])
            
            var jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            print(jsonString!)
            
            apiCall.nsurlConnectionFunction(requestString, jsonString,"FeePayment")
        }else{
            Util .showAlert("", msg: NETWORK_ERROR)
        }
    }
    func callLateFeePaymentApiCall(){
        
        showLoading()
        strApiFrom = "latefee"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_LATE_FEES
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["SchoolID" : SchoolIDString,"lateFeeDetails" : lateFeeArray]
        let myString = Util.convertDictionary(toString: myDict)
        apiCall.nsurlConnectionFunction(requestString, myString,"GetExamDetailApi")
    }
    //MARK: API RESPONSE
    
    
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!){
        hideLoading()
        if(csData != nil){
            if(strApiFrom.isEqual("GetFeeDetails")){
                
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                let emptyDict : NSDictionary = NSDictionary()
                let Dict : NSDictionary = csData?.mutableCopy() as? NSDictionary ?? emptyDict
                
                UtilObj.printLogKey(printKey: "Dict", printingValue: Dict)
                if(Dict.count > 0){
                    
                    let Status = String(describing: Dict["Status"]!)
                    let Message = Dict["Message"] as? String
                    let strAlertString = Message!
                    if(Status == "1"){
                        //                        self.termTitleLabel.text =  String(describing: Dict["TermFeesDisplayName"]!)
                        //                        self.otherTitleLabel.text =  String(describing: Dict["OtherFeesDisplayName"]!)
                        self.lateFeeChargesLabel.text =  String(describing: Dict["LateFeeDisplayName"]!)
                        self.isLateFeeConfig =  Dict["isLateFeeConfig"] as? String ?? ""
                        self.amountPaidTitle  =  String(describing: Dict["OnlineFeesAmountToBePaidDisplayName"]!)
                        self.discountTitle =  String(describing: Dict["TermFeesDiscountDisplayName"]!)
                        self.strOnlinePaymentAvailable =  String(describing: Dict["onlinepayment"]!)
                        self.vsPayAmount = Double(String(describing: Dict["VSpayRP"]!)) as! Double
                        self.razorSecretKey = String(describing: Dict["RazorPayApiKey"]!)
                        self.razorApiKey = String(describing: Dict["RazorPayKeyId"]!)
                        
                        

                        let feeArray = Dict["TermFees"] as! NSArray
                        self.termFeeSectionArray = NSMutableArray(array: feeArray)
                        let monthlyArray = Dict["OtherFees"] as! NSArray
                        self.monthlyFeeSectionArray = NSMutableArray(array: monthlyArray)
                        //
                        if(strOnlinePaymentAvailable == "Yes" && strSegmentIndex == 0){
                            self.makeButtonHeight.constant = 40
                            self.makePaymentButton.isHidden = true
                        }else{
                            self.makeButtonHeight.constant = 0
                            self.makePaymentButton.isHidden = true
                        }
                        
                        if(self.termFeeSectionArray.count == 0 && self.monthlyFeeSectionArray.count == 0){
                            self.AlertWithCloseView(strAlert: Message!)
                        }
                        
                    }else{
                    }
                    
                    
                }else
                {
                    Util.showAlert("", msg: NO_PAID_FOUNT)
                }
                
                
            }
            else if(strApiFrom.isEqual("latefee")){
                
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                let emptyDict : NSDictionary = NSDictionary()
                let Dict : NSDictionary = csData?.mutableCopy() as? NSDictionary ?? emptyDict
                
                UtilObj.printLogKey(printKey: "Dict", printingValue: Dict)
                if(Dict.count > 0){
                    
                    let Status = String(describing: Dict["Status"]!)
                    let Message = Dict["Message"] as? String
                    let strAlertString = Message!
                    if(Status == "1"){
                        self.lateFeeAmount = Double(String(describing: Dict["lateFeeAmount"]!)) as! Double
                        self.lateFeeAmountLabel.text =  "₹ " + String(format: "%.2f",  self.lateFeeAmount )
                        
                        self.razorPaymentAmount = razorPaymentAmount + lateFeeAmount
                        self.totalAmountLabel.text =  "₹ " + String(format: "%.2f",  self.razorPaymentAmount )
                        
                        self.alertView.isHidden = false
                        
                        
                    }else{
                    }
                    
                    
                }else
                {
                    Util.showAlert("", msg: NO_PAID_FOUNT)
                }
                
                
            }
            else  if(strApiFrom.isEqual("Capture")){
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                let emptyDict : NSDictionary = NSDictionary()
                let Dict : NSDictionary = csData?.mutableCopy() as? NSDictionary ?? emptyDict
                
                UtilObj.printLogKey(printKey: "Dict", printingValue: Dict)
                if(Dict.count > 0){
                    
                    if(Dict["status"] != nil){
                        if(String(describing: Dict["status"]!) == "captured"){
                            if(Dict["card_id"] != nil){
                                self.accountId = String(describing: Dict["card_id"]!)
                            }
                            self.callTransferApiCall()
                        }else{
                            self.showAlert(alert: "", message: PAYMENT_FAILED_ALERT)
                        }
                        
                    }else{
                        self.showAlert(alert: "", message: PAYMENT_FAILED_ALERT)
                    }
                    
                }else{
                    self.showAlert(alert: "", message: PAYMENT_FAILED_ALERT)
                }
            }else  if(strApiFrom.isEqual("Transfer")){
                UtilObj.printLogKey(printKey: "csData", printingValue: csData!)
                let emptyDict : NSDictionary = NSDictionary()
                let Dict : NSDictionary = csData?.mutableCopy() as? NSDictionary ?? emptyDict
                
                UtilObj.printLogKey(printKey: "Dict", printingValue: Dict)
                if(Dict.count > 0){
                    
                    if(Dict["entity"] != nil){
                        if(String(describing: Dict["entity"]!) == "collection"){
                            self.callFeePaymentApiCall()
                        }else{
                            self.showAlert(alert: "", message: PAYMENT_FAILED_ALERT)
                        }
                        
                    }else{
                        self.showAlert(alert: "", message: PAYMENT_FAILED_ALERT)
                    }
                    
                }else{
                    self.showAlert(alert: "", message: PAYMENT_FAILED_ALERT)
                }
            } else if(strApiFrom == "FeePayment")
            {
                
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        if(dict["Status"] != nil){
                            let Status = String(describing: dict["Status"]!)
                            let Message = String(describing: dict["Message"]!)
                            if(Status == "1"){
                                self.showAlert(alert: "", message: Message)
                                self.selectedTermRow.removeAllObjects()
                                self.selectedTermSection.removeAllObjects()
                                self.selectedMonthlyRow.removeAllObjects()
                                self.selectedMonthlySection.removeAllObjects()
                                
                                self.selectedTermFeeArray.removeAllObjects()
                                self.selectedOtherFeeArray.removeAllObjects()
                                self.selectedTermFeeRowArray.removeAllObjects()
                                self.selectedOtherFeeRowArray.removeAllObjects()
                                
                                self.GetFeeDetailApiCalling()
                            }else{
                                self.showAlert(alert: "", message: Message)
                            }
                        }
                        
                    }
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
        }else
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
    
    func AlertWithCloseView(strAlert : String)
    {
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: strAlert, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    

    func onPaymentSuccess(_ payment_id: String) {
        self.paymentID = payment_id
        self.alertView.isHidden = true
        self.callCaptureApiCall()
        
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        let alert = UIAlertController(title: "Error", message: "\(code)\n\(str)", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
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
                    
                }
            } catch {
                
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDictionary = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            
            self.view.semanticContentAttribute = .forceLeftToRight
            
        }
        
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        
    }
    
    
    
    
    func GetFeeDetailReceipt () {
        
        let feeReceiptModal = FeeDetailReceiptModal()
        print("SchoolId",SchoolIDString)
        print("chilId",ChildIDString)
        
        
        feeReceiptModal.SchoolID = SchoolIDString
        feeReceiptModal.ChildID = ChildIDString
        feeReceiptModal.FeeCategory = "1"
        
        
        let feeReceiptModalStr = feeReceiptModal.toJSONString()
        print("msgFromModalStr",feeReceiptModal)
        
        FeeDetailReceiptRequest.call_request(param: feeReceiptModalStr!) {
            [self]   (res) in
            
            
            
            
            
            let feeReceiptResponse : FeeDetailReceiptResponse = Mapper<FeeDetailReceiptResponse>().map(JSONString: res)!
            
            
            
            getReceipt = feeReceiptResponse.data
            
            feeDetailReceiptTv.dataSource = self
            feeDetailReceiptTv.delegate = self
            feeDetailReceiptTv.reloadData()
            
        }
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getReceipt.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rowIdentifier, for: indexPath) as! FeeDetailReceiptTableViewCell
        let receipt : FeeDetailReceiptData = getReceipt[indexPath.row]
        cell.InvoiceNumberLbl.text = receipt.invoiceNo
        print("cell.InvoiceNumberLbl.text", cell.InvoiceNumberLbl.text)
        cell.InvoiceDateLbl.text = receipt.invoiceDate
        cell.InvoiceAmountLbl.text = receipt.invoiceAmount
        
        
        let viewInvoiceGesture = feeReceiptPdfGesture(target: self, action: #selector(gotoInvoice))
        viewInvoiceGesture.invoiceId = receipt.id
        cell.viewInvoice.addGestureRecognizer(viewInvoiceGesture)
        return cell
    }
    
    
    @IBAction func gotoInvoice(ges: feeReceiptPdfGesture) {
        let vc = FeeReceiptPdfDownloadViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.getInvoiceId = ges.invoiceId
        vc.schoolId = SchoolId
        present(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 198
    }
    
    
}



class feeReceiptPdfGesture :  UITapGestureRecognizer{
    var invoiceId : String!
    var getschoolId : String!
}
