//
//  ImageTVCTableViewController.swift
//  VoicesnapParentApp
//
//  Created by PREMKUMAR on 16/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class ImageTVCTableViewController: UITableViewController,Apidelegate,UISearchBarDelegate {
    
    var typesArray: NSMutableArray = []
    var strApiFrom = NSString()
    var ChildId = String()
    var SchoolId = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var selectedDictionary = NSDictionary()
    var strSelectDate = NSString ()
    var SenderType = NSString ()
    var Screenheight = CFloat()
    var search_Bar : UISearchBar!
    var ChildIDString = String()
    
    var getadID : Int!
    
    @IBOutlet weak var search_bar: UISearchBar!
    
    @IBOutlet weak var TextDateLabel: UILabel!
    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var TextDetailstableview: UITableView!
    var ImageSelectedDict = [String: Any]() as NSDictionary
    var detailsDictionaryfull = NSDictionary()
    var languageDict = NSDictionary()
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    let tableBg :UIColor = UIColor (red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 0.9)
    var hud : MBProgressHUD = MBProgressHUD()
    var altSting = String()
    var bIsSeeMore = Bool()
    var bIsArchive = Bool()
    var MainDetailTextArray: NSMutableArray = NSMutableArray()
    var SelectedSectionArray : NSMutableArray = NSMutableArray()
    
    
    var imgaeURl : String  = ""
    var AdName : String  = ""
    var imageCount : Int  = 0
    var firstImage : Int  = 0
    
    
    weak var timer: Timer?
    
    var menuId : String!
    
    var imgView : UIImageView!
    var AdView : UIView!
    var adViewHeight : NSLayoutConstraint!
    var appBgImage : UIImageView!
    var popupLoading : KLCPopup = KLCPopup()
    override func viewDidLoad() {
        super.viewDidLoad()
        //        TextDetailstableview.backgroundColor = .blue
        search_bar.delegate = self
        search_bar.backgroundColor = .white
        search_bar.tintColor = UIColor(named: "serach_color")
        search_bar.placeholder = "Search"
        
        
        self.TextDetailstableview.keyboardDismissMode = .onDrag
        
        self.TextDetailstableview.tableHeaderView = tableHeaderView
        //        self.TextDetailstableview.backgroundColor = tableBg
        self.view.backgroundColor = .white
        
        
        bIsSeeMore = false
        if(appDelegate.isPasswordBind == "0"){
            bIsSeeMore = true
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
    }
    //CallImageDetailApi
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        //            searchActive = false
        self.search_Bar.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        // print("Warning!! in image")
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    @IBAction func actionBack(_ sender: UIButton)
    {
        if(SenderType == "FromStaff")
        {
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: "comeBackStaff"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }else
        {
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: "comeBack"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(typesArray.count == 0){
            if(appDelegate.isPasswordBind != "0"){
                emptyView()
            }
            return 0
        }else{
            restoreView()
            if(!bIsSeeMore){
                return typesArray.count + 1
                
            }else{
                return typesArray.count
                
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // let vw = UIView()
        tableHeaderView.backgroundColor = UIColor.clear
        search_bar.delegate = self
        search_bar.endEditing(true)
        search_bar.backgroundColor = .white
        search_bar.tintColor = UIColor(named: "serach_color")
        search_bar.placeholder = "Search"
        //
        
        return tableHeaderView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row <= (typesArray.count - 1)){
            
            
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "ImageFileTableViewCell", for: indexPath) as! ImageFileTableViewCell
            
            let detailsDictionary = typesArray.object(at: indexPath.row) as! NSDictionary
            
            cell1.TimeLbl.text =  String(describing: detailsDictionary["Time"]!)
            cell1.SubjectLbl.text = String(describing: detailsDictionary["Subject"]!)
            cell1.DateLbl.text = String(describing: detailsDictionary["Date"]!)
            if(SenderType == "FromStaff")
            {
                cell1.TitleLbl.text = ""
            }else{
                cell1.TitleLbl.text = String(describing: detailsDictionary["Description"]!)
            }
            DispatchQueue.global(qos: .background).async {
                
                
                cell1.MyImageView?.setIndicatorStyle(.whiteLarge)
                cell1.MyImageView?.setShowActivityIndicator(true)
                
                SDImageCache.shared().shouldDecompressImages = false
                SDWebImageDownloader.shared().shouldDecompressImages = false
                
                DispatchQueue.main.async {
                    
                    cell1.MyImageView.sd_setImage(
                        with: NSURL(string: (detailsDictionary["URL"] as? String)!) as URL?,
                        placeholderImage: nil,
                        options: SDWebImageOptions.retryFailed,
                        progress: nil,
                        completed: { (image, error, cacheType, imageUrl) in
                            
                            guard let image = image else {
                                cell1.MyImageView.image = UIImage(named: "placeHolder")
                                return }
                            //  print("Image arrived!")
                            cell1.MyImageView.image = self.resizeImage(image: image, newWidth: 100)
                            cell1.MyImageView?.setShowActivityIndicator(false)
                        }
                    )
                    
                }
            }
            
            cell1.ViewFullImageButton.setTitle(languageDict["hint_save_image"] as? String, for: .normal)
            cell1.SaveButton.setTitle(languageDict["btn_save_image"] as? String, for: .normal)
            
            cell1.MyImageView?.isUserInteractionEnabled = true
            cell1.MyImageView?.tag = indexPath.row
            
            cell1.NewLbl.tag = indexPath.row
            cell1.ViewFullImageButton.addTarget(self, action: #selector(ViewFullImage(sender:)), for: .touchUpInside)
            cell1.ViewFullImageButton.tag = indexPath.row
            cell1.SaveButton.addTarget(self, action: #selector(ImageTVCTableViewController.SaveImageButton(sender:)), for: .touchUpInside)
            cell1.SaveButton.tag = indexPath.row
            let iReadVoice : Int? = Int((detailsDictionary["AppReadStatus"] as? String)!)
            // iReadVoice = 0
            if(iReadVoice == 0){
                
                cell1.NewLbl.isHidden = false
                
            }
            else
            {
                cell1.NewLbl.isHidden = true
                
                
            }
            cell1.backgroundColor = UIColor.clear
            
            return cell1
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreTVCell", for: indexPath) as! SeeMoreTVCell
            
            print("SeeMoreTVCell9")
            
            if(SenderType == "FromStaff"){
                
                cell.SeeMoreBtn.isHidden = true
                
            }
            else{
                cell.SeeMoreBtn.isHidden = false
                
            }
            cell.SeeMoreBtn.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
            cell.backgroundColor = .clear
            return cell
            
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let newHeight = newWidth
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0,width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row <= (typesArray.count - 1)){
            
            let dict = typesArray[indexPath.row] as! NSDictionary
            
            var DescriptionText = String()
            var CheckNilText = String()
            if(SenderType == "FromStaff")
            {
                CheckNilText = ""
            }else
            {
                DescriptionText = String(describing: dict["Description"]!)
                CheckNilText  = Util .checkNil(DescriptionText)
            }
            
            
            if(CheckNilText != "")        {
                
                let Stringlength : Int = CheckNilText.count
                
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    
                    let MuValue : Int = Stringlength/61
                    if(indexPath.row <= (typesArray.count - 1)){
                        return (412 + ( 22 * CGFloat(MuValue)))
                        
                    }else{
                        return (412 + 40 + ( 22 * CGFloat(MuValue)))
                        
                    }
                }else{
                    if(indexPath.row <= (typesArray.count - 1)){
                        
                        if(Screenheight > 580)
                        {
                            let MuValue : Int = Stringlength/50
                            return (268 + ( 18 * CGFloat(MuValue)))
                            
                        }else{
                            let MuValue : Int = Stringlength/44
                            return (268 + ( 18 * CGFloat(MuValue)))
                        }
                    }else{
                        if(Screenheight > 580)
                        {
                            let MuValue : Int = Stringlength/50
                            return (268 + 40 + ( 18 * CGFloat(MuValue)))
                            
                        }else{
                            let MuValue : Int = Stringlength/44
                            return (268 + 40 + ( 18 * CGFloat(MuValue)))
                        }
                    }
                }
                
            }
            else{
                if(indexPath.row <= (typesArray.count - 1)){
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        return 358
                    }else{
                        return 238
                    }
                }else{
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        return 358 + 40
                    }else{
                        return 238 + 40
                    }
                }
                
            }
        }else{
            return 40
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "ImageFileTableViewCell", for: indexPath) as! ImageFileTableViewCell
        cell1.NewLbl.tag = indexPath.row
        
        let detailsDictionary = typesArray.object(at: indexPath.row) as! NSDictionary
        
        detailsDictionaryfull = detailsDictionary
        
        let dict = NSMutableDictionary(dictionary: detailsDictionary)
        
        var iReadVoice : Int? = Int((detailsDictionary["AppReadStatus"] as? String)!)
        
        //  iReadVoice = 0
        bIsArchive = dict["is_Archive"] as? Bool ?? false
        
        if(iReadVoice == 0){
            cell1.NewLbl.isHidden = false
            
            dict["AppReadStatus"] = "1"
            
            typesArray[indexPath.row] = dict
            //
            if(SenderType == "FromStaff")
            {
                CallStaffImageReadStatusUpdateApi(String(describing: detailsDictionary["ID"]!) , "IMAGE")
            }else
            {
                
                
                CallReadStatusUpdateApi(String(describing: detailsDictionary["MessageID"]!) , "IMAGE")
            }
            
        }
        else
        {
            cell1.NewLbl.isHidden = true
            
        }
        //callViewFullImage(indexPath.row)
        TextDetailstableview.reloadData()
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ImageDetailVCSeg", sender: self)
        }
        
    }
    @objc func ViewFullImage(sender: UIButton)
    {
        let buttonTag = sender.tag
        
        callViewFullImage(buttonTag)
        
    }
    func callViewFullImage(_ buttonTag : NSInteger) -> Void {
        
        let detailsDictionary = typesArray.object(at: buttonTag) as! NSDictionary
        
        detailsDictionaryfull = detailsDictionary
        
        let dict = NSMutableDictionary(dictionary: detailsDictionary)
        
        let iReadVoice : Int? = Int((detailsDictionary["AppReadStatus"] as? String)!)
        
        bIsArchive = dict["is_Archive"] as? Bool ?? false
        
        if(iReadVoice == 0){
            
            dict["AppReadStatus"] = "1"
            
            typesArray[buttonTag] = dict
            
            if(SenderType == "FromStaff")
            {
                CallStaffImageReadStatusUpdateApi(String(describing: detailsDictionary["ID"]!) , "IMAGE")
            }else
            {
                CallReadStatusUpdateApi(String(describing: detailsDictionary["MessageID"]!) , "IMAGE")
            }
            
        }
        else
        {
            
        }
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ImageDetailVCSeg", sender: self)
        }
        
        
    }
    
    @objc func SaveImageButton (sender : UIButton)
    {
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
        
        showLoading()
        // mystring = "ImageFile"
        let buttonTag = sender.tag
        
        let detailsDictionary = typesArray.object(at: buttonTag) as! NSDictionary
        
        detailsDictionaryfull = detailsDictionary
        
        let dict = NSMutableDictionary(dictionary: detailsDictionary)
        bIsArchive = dict["is_Archive"] as? Bool ?? false
        
        let iReadVoice : Int? = Int((detailsDictionary["AppReadStatus"] as? String)!)
        
        
        if(iReadVoice == 0){
            
            dict["AppReadStatus"] = "1"
            
            typesArray[buttonTag] = dict
            
            if(SenderType == "FromStaff")
            {
                CallStaffImageReadStatusUpdateApi(String(describing: detailsDictionary["MessageID"]!) , "IMAGE")
            }else
            {
                CallReadStatusUpdateApi(String(describing: detailsDictionary["MessageID"]!) , "IMAGE")
            }
            
        }
        
        DispatchQueue.global(qos: .background).async {
            
            
            SDImageCache.shared().shouldDecompressImages = false
            SDWebImageDownloader.shared().shouldDecompressImages = false
            let urlstring : String =  String(describing: detailsDictionary["URL"]!)
            
            var imagefull : UIImage = UIImage()
            let url = URL(string: urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            //  print(url)
            if let data = try? Data(contentsOf: url)
            {
                let image: UIImage = UIImage(data: data)!
                imagefull = image
            }
            
            DispatchQueue.main.async {
                
                UIImageWriteToSavedPhotosAlbum(imagefull, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                
            }
        }
        
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        hideLoading()
        if error != nil {
            Util.showAlert("", msg: SAVE_ERROR)
            
        } else {
            Util.showAlert("", msg: SAVE_SUCCESS)
            
        }
    }
    
    func CallReadStatusUpdateApi(_ ID : String, _ type : String) {
        
        strApiFrom = "UpdateReadStatus"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        
        var requestStringer = baseUrlString! + READ_STATUS_UPDATE
        if(bIsArchive){
            requestStringer = baseUrlString! + READ_STATUS_UPDATE_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ID" : ID,"Type" : type, COUNTRY_CODE: strCountryCode]
        
        let myString = Util.convertNSDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "UpdateReadStatus")
    }
    
    func CallStaffImageReadStatusUpdateApi(_ ID : String, _ type : String) {
        //showLoading()
        
        strApiFrom = "StaffImageReadStatus"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        
        var requestStringer = baseUrlString! + READ_STATUS_UPDATE
        
        
        if(bIsArchive){
            requestStringer = baseUrlString! + READ_STATUS_UPDATE_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //{"ID":"16037816","Type":"SMS"}
        let myDict:NSMutableDictionary = ["ID" : ID,"Type" : type, COUNTRY_CODE: strCountryCode]
        
        let myString = Util.convertNSDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "StaffImageReadStatus")
    }
    
    
    func CallStaffImageMessageApi() {
        showLoading()
        strApiFrom = "CallStaffImageMessageApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_FILES_STAFF
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_FILES_STAFF
        }
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //{"SchoolId":"1235","MemberId":"112712","CircularDate":"20-05-2018","Type":"VOICE"}
        let myDict:NSMutableDictionary = ["SchoolId": SchoolId,"MemberId" : ChildId,"CircularDate" : TextDateLabel.text!,"Type" : "IMAGE", COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallStaffImageMessageApi")
    }
    
    func CallSeeMoreStaffImageMessageApi() {
        showLoading()
        strApiFrom = "CallSeeMoreStaffImageMessageApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + GET_FILES_STAFF_ARCHIVE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_FILES_STAFF_ARCHIVE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //{"SchoolId":"1235","MemberId":"112712","CircularDate":"20-05-2018","Type":"VOICE"}
        let myDict:NSMutableDictionary = ["SchoolId": SchoolId,"MemberId" : ChildId,"CircularDate" : TextDateLabel.text!,"Type" : "IMAGE", COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallSeeMoreStaffImageMessageApi")
    }
    func CallImageDetailApi() {
        showLoading()
        strApiFrom = "CallImageDetailApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_EMERGENCY_FILES
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_EMERGENCY_FILES
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        //{"ChildID":"7466","SchoolID":"1806","Type":"VOICE"}
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, "Type" : "IMAGE", COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber ]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallImageDetailApi")
    }
    
    func CallSeeMoreImageDetailApi() {
        showLoading()
        strApiFrom = "CallSeeMoreImageDetailApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + GET_EMERGENCY_FILES_SEEMORE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + GET_EMERGENCY_FILES_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId, "Type" : "IMAGE", COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber ]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallSeeMoreImageDetailApi")
    }
    
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        
        
        if(csData != nil)
        {
            utilObj.printLogKey(printKey: "csData", printingValue: csData)
            if(strApiFrom == "StaffImageReadStatus"){
                if((csData?.count)! > 0){
                    TextDetailstableview.reloadData()
                }
            }else if(strApiFrom == "UpdateReadStatus"){
                if((csData?.count)! > 0){
                    TextDetailstableview.reloadData()
                }
            }
            else if(strApiFrom == "CallImageDetailApi")
            {
                typesArray.removeAllObjects()
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["Status"]!)
                        let Message = String(describing: dict["Message"]!)
                        if(Status == "1")
                        {
                            typesArray.add(dict)
                            MainDetailTextArray.add(dict)
                            
                        }else{
                            
                            //  AlerMessage()
                            altSting = Message
                            if(appDelegate.isPasswordBind == "0"){
                                AlerMessage()
                            }
                            
                        }
                    }
                    utilObj.printLogKey(printKey: "typesArray", printingValue: typesArray)
                    TextDetailstableview.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }else if(strApiFrom == "CallSeeMoreImageDetailApi")
            {
                // typesArray.removeAllObjects()
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["Status"]!)
                        let Message = String(describing: dict["Message"]!)
                        if(Status == "1")
                        {
                            typesArray.add(dict)
                            MainDetailTextArray.add(dict)
                            
                        }else{
                            
                            AlerMessage()
                            
                        }
                    }
                    utilObj.printLogKey(printKey: "typesArray", printingValue: typesArray)
                    TextDetailstableview.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            
            if(strApiFrom == "CallStaffImageMessageApi")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["ID"]!)
                        
                        let Message = String(describing: dict["URL"]!)
                        let CheckNilText : String = Util .checkNil(Status)
                        if(CheckNilText != "")
                        {
                            typesArray.add(dict)
                            MainDetailTextArray.add(dict)
                        }else{
                            AlerMessage()
                            
                            
                        }
                    }
                    
                    TextDetailstableview.reloadData()
                    
                    
                }
                else{
                    Util.showAlert("", msg: strSomething)
                }
            }
            else if(strApiFrom == "CallSeeMoreStaffImageMessageApi")
            {
                if let CheckedArray = csData as? NSArray
                {
                    let arrayData = CheckedArray
                    for i in 0..<arrayData.count
                    {
                        let dict = CheckedArray[i] as! NSDictionary
                        let Status = String(describing: dict["ID"]!)
                        
                        let Message = String(describing: dict["URL"]!)
                        let CheckNilText : String = Util .checkNil(Status)
                        if(CheckNilText != "")
                        {
                            typesArray.add(dict)
                            MainDetailTextArray.add(dict)
                        }else{
                            AlerMessage()
                            //HiddenLabel.isHidden = false
                            //HiddenLabel.text = Message
                            
                        }
                    }
                    
                    TextDetailstableview.reloadData()
                    
                    
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
        
        Util .showAlert("", msg: pagename.localizedDescription);
        
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ImageDetailVCSeg")
        {
            let segueid = segue.destination as! ImageDetailVC
            segueid.SenderType = SenderType
            segueid.selectedDictionary = detailsDictionaryfull
        }
    }
    
    func showLoading() -> Void {
        //  self.view.window?.userInteractionEnabled = false
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        
        hud.hide(true)
    }
    func AlerMessage()
    {
        
        let alertController = UIAlertController(title: languageDict["alert"] as? String, message: strNoRecordAlert, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: languageDict["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            // print("Okaction")
            self.dismiss(animated: true, completion: nil)
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
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
                }else{
                    self.loadViewData()
                }
            } catch {
                self.loadViewData()
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDict = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        loadViewData()
    }
    
    func loadViewData(){
        Screenheight = CFloat(self.view.frame.size.height)
        if(Util .isNetworkConnected()){
            if(SenderType == "FromStaff"){
                if(appDelegate.LoginSchoolDetailArray.count > 0){
                    let dict:NSDictionary = appDelegate.LoginSchoolDetailArray[0] as! NSDictionary
                    ChildId = String(describing: dict["StaffID"]!)
                    SchoolId = String(describing: dict["SchoolID"]!)
                    TextDateLabel.text = String(describing: ImageSelectedDict["Date"]!)
                    bIsArchive = ImageSelectedDict["is_Archive"] as? Bool ?? false
                    
                    if(Util .isNetworkConnected()){
                        if(bIsArchive){
                            CallSeeMoreStaffImageMessageApi()
                        }else{
                            CallStaffImageMessageApi()
                            
                        }
                    }else{
                        Util .showAlert("", msg: strNoInternet)
                    }
                }else{
                    Util.showAlert("", msg: strNoRecordAlert)
                }
            }else{
                TextDateLabel.text = languageDict["recent_photos"] as? String
                ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
                SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
                self.CallImageDetailApi()
            }
        }else{
            Util .showAlert("", msg: strNoInternet)
        }
    }
    //Mark:- SeeMore Feature
    func emptyView(){
        let noview : UIView = UIView(frame: CGRect(x: 0, y: 10, width: self.TextDetailstableview.bounds.size.width, height: self.TextDetailstableview.bounds.size.height))
        
        let noDataLabel: UILabel = UILabel(frame: CGRect(x: 10, y:  10, width: self.TextDetailstableview.bounds.size.width, height: 60))
        noDataLabel.text = "No messages for the day. Click See More for previous messages."
        noDataLabel.textColor = .red
        print("noDataLabel.text",noDataLabel.text)
        noDataLabel.backgroundColor = UIColor(named: "NoDataColor")
        
        
        noDataLabel.numberOfLines = 0
        
        noDataLabel.textAlignment = NSTextAlignment.center
        noview.addSubview(noDataLabel)
        
        let button = UIButton(frame: CGRect(x: self.TextDetailstableview.bounds.size.width - 108, y: noDataLabel.frame.height + 10, width: 100, height: 32))
        button.setTitle(SEE_MORE_TITLE, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(utilObj.PARENT_NAV_BAR_COLOR, for: .normal)
        button.addTarget(self, action: #selector(self.seeMoreButtonTapped), for: .touchUpInside)
        noview.addSubview(button)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 3
        button.layer.borderColor = utilObj.PARENT_NAV_BAR_COLOR.cgColor
        
        
        
        search_Bar = UISearchBar(frame: CGRect(x: 5, y:90, width: 400, height: 40))
        
        search_Bar.backgroundColor = .white
        search_Bar.tintColor = UIColor(named: "serach_color")
        search_Bar.placeholder = "Search"
        
        
        AdView = UIImageView(frame: CGRect(x:10, y:780, width: 400, height: 60))
        
        imgView = UIImageView(frame: CGRect(x:10, y:780, width: 400, height: 60))
        
        async {
            await AdConstant.AdRes(memId: ChildIDString, memType: "student", menu_id: AdConstant.getMenuId as String, school_id: SchoolId)
            menuId = AdConstant.getMenuId as String
            print("menu_id:\(AdConstant.getMenuId)")
        }
        
        self.TextDetailstableview.backgroundView = noview
        DispatchQueue.main.asyncAfter(deadline: .now()) { [self] in
            startTimer()
            
        }
        
        
        imgView.contentMode = .scaleToFill
        noview.addSubview(AdView)
        noview.addSubview(imgView)
        noview.addSubview(search_Bar)
        
        AdView.isUserInteractionEnabled = true
        
        let imgTap = AdGesture (target: self, action: #selector(viewTapped))
        AdView.addGestureRecognizer(imgTap)
        
        
    }
    
    func startTimer() {
        
        if AdConstant.adDataList.count > 0 {
            
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
                
                self!.imgView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
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
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    
    func restoreView(){
        self.TextDetailstableview.backgroundView = nil
    }
    
    @objc func seeMoreButtonTapped(sender : UIButton) {
        //Write button action here
        bIsSeeMore = true
        self.TextDetailstableview.reloadData()
        CallSeeMoreImageDetailApi()
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0{
            typesArray = MainDetailTextArray
            self.TextDetailstableview.reloadData()
        }else{
            let resultPredicate = NSPredicate(format: "%K CONTAINS[c] %@","Subject", searchText)
            let arrSearchResults = MainDetailTextArray.filter { resultPredicate.evaluate(with: $0) } as NSArray
            typesArray = NSMutableArray(array: arrSearchResults)
            if(typesArray.count > 0){
                self.TextDetailstableview.reloadData()
                print("DetailVoiceArray.count > 0")
            }else{
                print("noDataLabel.isHidden = false")
            }
            //
        }
        
        
    }
    
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        search_Bar.endEditing(true)
    }
    
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        typesArray =  MainDetailTextArray
        self.TextDetailstableview.reloadData()
    }
}
