//
//  ConferenceCallVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 13/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class ConferenceCallVC: UIViewController,Apidelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate{
    
    @IBOutlet weak var SelectAllLabel: UILabel!
    @IBOutlet weak var StaffListLabel: UILabel!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var noDataLabel : UILabel!
    @IBOutlet weak var MakeCallButton: UIButton!
    @IBOutlet weak var StaffListTableView: UITableView!
    @IBOutlet weak var SelectImage: UIImageView!
    @IBOutlet weak var SelectAllButton: UIButton!
    
    var MainStaffArray : NSMutableArray = NSMutableArray()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    var strApiFrom = NSString()
    var SchoolId = String()
    var StaffId = String()
    var StudentDetailDictionary:NSDictionary = [String:Any]() as NSDictionary
    var StaffNameArray : NSMutableArray = NSMutableArray()
    var SelectedStaffIDArray : NSMutableArray = NSMutableArray()
    var ChoosenStaffIDArray : Array = [Any]()
    var SelectedStaffNameArray : Array = [String]()
    var StaffIDArray : Array = [String]()
    var StudentCount = Int()
    var gestureRecognizer = UITapGestureRecognizer()
    var SchoolDetailDict:NSDictionary = NSDictionary()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        noDataLabel.isHidden = true
        MakeCallButton.isUserInteractionEnabled = false
        MakeCallButton.backgroundColor = UIColor.lightGray
        SchoolId = String(describing: SchoolDetailDict["SchoolID"]!)
        StaffId = String(describing: SchoolDetailDict["StaffID"]!)
        MakeCallButton.layer.cornerRadius = 5
        MakeCallButton.clipsToBounds = true
        SelectAllButton.isSelected = true
        
        if(Util .isNetworkConnected()){
            self.GetAllStaffListAPICalling()
        }else{
            Util .showAlert("", msg: strNoInternet)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.callSelectedLanguage()
        searchBar.resignFirstResponder()
        searchBar.text = ""
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ConferenceCallVC.SearchTap(_:)))
        gestureRecognizer.delegate = self
        self.view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: TABLE VIEW
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat = 0
        if(UIDevice.current.userInterfaceIdiom == .pad){
            height =  72
        }else{
            height =  52
        }
        return height
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return StaffNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConferenceCallTVCell", for: indexPath) as! ConferenceCallTVCell
        
        let dicResponse : NSDictionary = StaffNameArray[indexPath.row] as! NSDictionary
        
        if(String(describing: dicResponse["StaffType"]!) == "Authorized Caller"){
            let StaffName : String = String(describing: dicResponse["StaffName"]!) + " *"
            cell.StaffNameLbl.text = StaffName
        }else{
            cell.StaffNameLbl.text = String(describing: dicResponse["StaffName"]!)
        }
        
        if(SelectedStaffIDArray.count > 0){
            if(SelectedStaffIDArray.contains(dicResponse)){
                cell.SelectImg.image = UIImage(named: "CheckBoximage")
                self.StaffListTableView.selectRow(at: indexPath, animated: false, scrollPosition:UITableView.ScrollPosition.none)
            }else{
                cell.SelectImg.image = UIImage(named: "UnChechBoxImage")
                self.StaffListTableView.deselectRow(at: indexPath, animated: false)
            }
        }else{
            cell.SelectImg.image = UIImage(named: "UnChechBoxImage")
            self.StaffListTableView.deselectRow(at: indexPath, animated: false)
        }
        if(SelectedStaffIDArray.count == 0){
            MakeCallButton.isUserInteractionEnabled = false
            MakeCallButton.backgroundColor = UIColor.lightGray
            SelectImage.image = UIImage(named: "UnChechBoxImage")
            SelectAllButton.isSelected = true
        }else if(SelectedStaffIDArray.count == StaffNameArray.count){
            MakeCallButton.isUserInteractionEnabled = true
            MakeCallButton.backgroundColor = UIColor (red:232.0/255.0, green:127.0/255.0, blue: 32.0/255.0, alpha: 1)
            
            SelectImage.image = UIImage(named: "CheckBoximage")
            SelectAllButton.isSelected = false
        }else{
            
            SelectImage.image = UIImage(named: "UnChechBoxImage")
            SelectAllButton.isSelected = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        noDataLabel.isHidden = true
        searchBar.resignFirstResponder()
        MakeCallButton.isUserInteractionEnabled = true
        MakeCallButton.backgroundColor = UIColor (red:232.0/255.0, green:127.0/255.0, blue: 32.0/255.0, alpha: 1)
        let Dict : NSDictionary = StaffNameArray[indexPath.row] as! NSDictionary
        SelectedStaffIDArray.add(Dict)
        
        StaffListTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        noDataLabel.isHidden = true
        searchBar.resignFirstResponder()
        let deselecteddata : NSDictionary = StaffNameArray[indexPath.row] as! NSDictionary
        if(SelectedStaffIDArray.contains(deselecteddata)){
            SelectedStaffIDArray.remove(deselecteddata)
            StudentCount = SelectedStaffIDArray.count
        }else{
            SelectedStaffIDArray.add(deselecteddata)
        }
        StaffListTableView.reloadData()
        
    }
    //MARK: BUTTON ACTIONS
    
    @IBAction func actionMakeCall(_ sender: Any){
        ChoosenStaffIDArray.removeAll()
        
        for i in 0..<SelectedStaffIDArray.count{
            let dicResponse : NSDictionary = SelectedStaffIDArray[i] as! NSDictionary
            
            let mystring = String(describing: dicResponse["StaffId"]!)
            let StudentDic:NSDictionary = ["ID" : mystring]
            ChoosenStaffIDArray.append(StudentDic)
            print(ChoosenStaffIDArray)
        }
        if(Util .isNetworkConnected()){
            self.GetMakeConferenceCallAPICalling()
            
        }else{
            Util .showAlert("", msg: strNoInternet)
        }
    }
    
    @IBAction func actionCancel(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: ACTION SELECT ALL STUDENT
    @IBAction func actionSelectedAllStudent(_ sender: Any) {
        searchBar.resignFirstResponder()
        if(SelectAllButton.isSelected == true){
            StudentCount = StaffNameArray.count
            
            SelectImage.image = UIImage(named: "CheckBoximage")
            SelectAllButton.isSelected = false
            var StaffArray : Array = [Any]()
            for i in 0..<StaffNameArray.count{
                let Dict : NSDictionary = StaffNameArray[i] as! NSDictionary
                StaffArray.append(Dict)
            }
            SelectedStaffIDArray = NSMutableArray(array: StaffArray)
            MakeCallButton.isUserInteractionEnabled = true
            MakeCallButton.backgroundColor = UIColor (red:232.0/255.0, green:127.0/255.0, blue: 32.0/255.0, alpha: 1)
            self.StaffListTableView.reloadData()
        }else{
            for i in 0..<SelectedStaffIDArray.count{
                let Dict : NSDictionary = StaffNameArray[i] as! NSDictionary
                SelectedStaffIDArray.remove(Dict)
            }
            SelectImage.image = UIImage(named: "UnChechBoxImage")
            SelectAllButton.isSelected = true
            MakeCallButton.isUserInteractionEnabled = false
            MakeCallButton.backgroundColor = UIColor.lightGray
            self.StaffListTableView.reloadData()
        }
    }
    
    func GetAllStaffListAPICalling(){
        showLoading()
        strApiFrom = "GetStaffList"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_ALL_STAFFLIST
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_ALL_STAFFLIST
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        print("requestString",requestString)
        let myDict:NSMutableDictionary = ["DialerId" : StaffId,"SchoolId" : SchoolId , COUNTRY_CODE: strCountryCode]
        let myString = Util.convertNSDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "GetStaffList")
    }
    
    func GetMakeConferenceCallAPICalling(){
        showLoading()
        strApiFrom = "ConferenceCallAPI"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + MAKE_CONFERENCE_CALL
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["DialerId" : StaffId,"StaffIDList" : ChoosenStaffIDArray , COUNTRY_CODE: strCountryCode]
        let myString = Util.convertNSDictionary(toString: myDict)
        print(myString!)
        print(baseUrlString!)
        apiCall.nsurlConnectionFunction(requestString, myString, "ConferenceCallAPI")
    }
    // MARK: API RESPONSE
    
    @objc func responestring(_ csData: NSMutableArray!, _ pagename: String!)
    {
        hideLoading()
        
        if(csData != nil){
            if(strApiFrom.isEqual(to: "GetStaffList")){
                var  arrayDatas: NSArray = []
                var dicResponse: NSDictionary = [:]
                arrayDatas = csData
                var AlertString = String()
                
                StaffIDArray.removeAll()
                StaffNameArray.removeAllObjects()
                MainStaffArray.removeAllObjects()
                if(arrayDatas.count > 0){
                    dicResponse = arrayDatas[0] as! NSDictionary
                    AlertString = String(describing: dicResponse["StaffName"]!)
                    
                    let staffId = String(describing: dicResponse["StaffId"]!)
                    let StarID = String(describing: dicResponse["StaffType"]!)
                    
                    if(!staffId.isEqual("0")){
                        MainStaffArray = NSMutableArray(array: arrayDatas)
                        StaffNameArray = MainStaffArray
                        StaffListTableView.reloadData()
                    }else{
                        Util.showAlert("", msg: AlertString)
                        dismiss(animated: false, completion: nil)
                    }
                    StaffListTableView.reloadData()
                }else{
                    Util.showAlert("", msg: AlertString)
                    dismiss(animated: false, completion: nil)
                }
            }else if(strApiFrom.isEqual(to: "ConferenceCallAPI")){
                var  arrayDatas: NSArray = []
                var dicResponse: NSDictionary = [:]
                arrayDatas = csData
                var AlertString = String()
                if(arrayDatas.count > 0){
                    dicResponse = arrayDatas[0] as! NSDictionary
                    AlertString = String(describing: dicResponse["Message"]!)
                    
                    let staffId = String(describing: dicResponse["Status"]!)
                    if(staffId == "1"){
                        CallfuncAfterSuccess()
                        Util.showAlert("", msg: AlertString)
                    }else{
                        Util.showAlert("", msg: AlertString)
                    }
                    
                }else{
                    Util.showAlert("", msg: strSomething)
                }
            }
        }else{
            Util.showAlert("", msg: strSomething)
        }
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        
        Util.showAlert("", msg: strSomething)
        
    }
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        
    }
    
    func CallfuncAfterSuccess(){
        SelectedStaffNameArray.removeAll()
        SelectedStaffIDArray.removeAllObjects()
        
        SelectImage.image = UIImage(named: "UnChechBoxImage")
        SelectAllButton.isSelected = true
        MakeCallButton.isUserInteractionEnabled = false
        MakeCallButton.backgroundColor = UIColor.lightGray
        self.StaffListTableView.reloadData()
    }
    // MARK: - Table view header
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String){
        SelectedStaffIDArray.removeAllObjects()
        if textSearched.count == 0{
            StaffNameArray = MainStaffArray as! NSMutableArray
            self.StaffListTableView.reloadData()
        }else{
            
            let resultPredicate = NSPredicate(format: "%K CONTAINS[c] %@","StaffName" ,textSearched)
            let arrSearchResults = MainStaffArray.filter { resultPredicate.evaluate(with: $0) } as NSArray
            
            StaffNameArray = NSMutableArray(array: arrSearchResults)
            if(StaffNameArray.count > 0){
                noDataLabel.isHidden = true
            }else{
                noDataLabel.isHidden = false
            }
            
            self.StaffListTableView.reloadData()
        }
        self.StaffListTableView.reloadData()
        gestureRecognizer.isEnabled = true
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        SelectedStaffIDArray.removeAllObjects()
        StaffNameArray = MainStaffArray
        self.StaffListTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        gestureRecognizer.isEnabled = true
        return true
    }
    
    @objc func SearchTap(_ gestureRecognizer: UIGestureRecognizer){
        searchBar.resignFirstResponder()
        gestureRecognizer.isEnabled = false
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
        
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            SelectAllLabel.textAlignment = .left
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            SelectAllLabel.textAlignment = .right
        }
        SelectAllLabel.text = LangDict["teacher_txt_select"] as? String
        StaffListLabel.text = LangDict["staff_list"] as? String
        searchBar.placeholder = LangDict["search_staffs"] as? String
        MakeCallButton.setTitle(LangDict["make_call"] as? String, for: .normal)
        strNoRecordAlert = LangDict["no_staffs"] as? String ?? "No Staff"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        noDataLabel.text = strNoRecordAlert
        
    }
}
