//
//  ViewAssignmentVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 01/05/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit
import PDFKit

class ViewAssignmentVC: UIViewController ,UITableViewDataSource,UITableViewDelegate,Apidelegate {
    
    var selectedDictionary = [String: Any]() as NSDictionary
    var selectedImageDictionary = [String: Any]() as NSDictionary
    var DetailTextArray = NSMutableArray()
    var strApiFrom = NSString()
    var ChildId = String()
    var SchoolId = String()
    var strCountryCode = String()
    var viewFrom = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var assignmentDetailID = String()
    var fileType = String()
    var isStaff = String()
    
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var assignmentTableview: UITableView!
    
    var hud : MBProgressHUD = MBProgressHUD()
    var SelectedIndex = IndexPath()
    
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var languageDictionary = NSDictionary()
    
    var bIsArchive = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HiddenLabel.isHidden = true
        assignmentTableview.estimatedRowHeight = 50
        assignmentTableview.rowHeight = UITableView.automaticDimension
        if(isStaff == "false"){
            ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
            SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        }
        
        assignmentTableview.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        viewFrom == "Submission" ? (titleLabel.text = fileType) : (titleLabel.text = String(describing: selectedDictionary["Type"]!))
        
        self.callSelectedLanguage()
        if(Util .isNetworkConnected()){
            if(viewFrom == "Submission"){
                self.CallSubmissionAssignmentMessageApi()
            }else{
                self.CallAssignmentMessageApi()
            }
            
        }else{
            Util .showAlert("", msg: strNoInternet)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    
    
    // MARK:- Button Action
    @IBAction func actionBack(_ sender: Any){
        print("back12")
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "NotificationFromSubmitAssigment"), object: nil)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK:- TableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return DetailTextArray.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(viewFrom == "Submission" && fileType == "IMAGE"){
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return 350
            }else{
                return 250
            }
        }else if(viewFrom == "Submission" && fileType == "PDF"){
            // return UITableView.automaticDimension
            return 50
        }else if(String(describing: selectedDictionary["Type"]!) == "IMAGE"){
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return 350
            }else{
                return 250
            }
        }else{
            if(viewFrom.lowercased() == "view" && fileType == "PDF"){
                return 50
                
            }else{
                return UITableView.automaticDimension
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewAssignmentTVCell", for: indexPath) as! ViewAssignmentTVCell
        
        cell.backgroundColor = UIColor.clear
        cell.textView.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        let dict:NSDictionary = DetailTextArray[indexPath.row] as! NSDictionary
        cell.saveImage.isHidden = true
        cell.PDFImageIconwidth.constant = 0
        cell.PDFImageIcon.isHidden = true
        cell.saveImage.layer.cornerRadius = 5
        print("viewFrom\(viewFrom)")
        print("fileType\(fileType)")
        
        if(viewFrom == "Submission" && fileType == "IMAGE"){
            
            cell.contentView.backgroundColor = UIColor.clear
            cell.saveImage.isHidden = false
            cell.textDetailTextView.isHidden = true
            cell.imgView.contentMode = .scaleToFill
            cell.imgView.isHidden = false
            DispatchQueue.main.async {
                let imageUrl = NSURL(string: String(describing: dict["Content"]!))
                cell.contenImageView.sd_setImage(with: imageUrl as! URL, placeholderImage: UIImage(named: "placeHolder.png"), options: SDWebImageOptions.refreshCached)
            }
        }else if(viewFrom == "Submission" && fileType == "PDF"){
            cell.textView.isUserInteractionEnabled = false
            cell.textView.backgroundColor = UIColor.white
            cell.textDetailTextView.isHidden = false
            cell.imgView.isHidden = true
            let urlContent = String(describing: dict["Content"]!)
            cell.textDetailTextView.text = "PDF-\(indexPath.row+1)"
            
            
        }else if(String(describing: selectedDictionary["Type"]!) == "IMAGE"){
            cell.contentView.backgroundColor = UIColor.clear
            cell.textDetailTextView.isHidden = true
            cell.saveImage.isHidden = false
            cell.imgView.contentMode = .scaleToFill
            cell.imgView.isHidden = false
            DispatchQueue.main.async {
                let imageUrl = NSURL(string: String(describing: dict["Content"]!))
                
                cell.contenImageView.sd_setImage(with: imageUrl as! URL, placeholderImage: UIImage(named: "placeHolder.png"), options: SDWebImageOptions.refreshCached)
            }
        }else{
            cell.textDetailTextView.isHidden = false
            cell.textView.backgroundColor = UIColor.white
            cell.imgView.isHidden = true
            let urlContent = String(describing: dict["Content"]!)
            if(fileType == "PDF"){
                cell.textDetailTextView.text = urlContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                cell.textDetailTextView.text = "PDF-\(indexPath.row+1)"
                
            }else{
                cell.textDetailTextView.text = urlContent
            }
            
            
            cell.textDetailTextView.tintColor = .systemGreen
            cell.textDetailTextView.isEditable = false
            cell.textDetailTextView.dataDetectorTypes = .all
        }
        if(isStaff == "true"){
            cell.saveImage.isHidden = true
        }
        cell.saveImage.addTarget(self, action: #selector(actionSaveImageButton(sender:)), for: .touchUpInside)
        cell.saveImage.tag = indexPath.row
        
        if(String(describing: selectedDictionary["Type"]!) == "PDF" || fileType == "PDF" ){
            
            cell.PDFImageIconwidth.constant = 50
            cell.PDFImageIcon.isHidden = false
        }
        if(fileType == "IMAGE"){
            cell.PDFImageIcon.isHidden = true
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    @objc func actionSaveImageButton(sender: UIButton){
        let dict:NSDictionary = DetailTextArray[sender.tag] as! NSDictionary
        DispatchQueue.global(qos: .background).async {
            SDImageCache.shared().shouldDecompressImages = false
            SDWebImageDownloader.shared().shouldDecompressImages = false
            let urlstring : String =  String(describing: dict["Content"]!)
            
            var imagefull : UIImage = UIImage()
            let url = URL(string: urlstring.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            
            if let data = try? Data(contentsOf: url){
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict:NSDictionary = DetailTextArray[indexPath.row] as! NSDictionary
        if(viewFrom == "Submission" && fileType == "IMAGE"){
            selectedImageDictionary = DetailTextArray[indexPath.row] as! NSDictionary
            performSegue(withIdentifier: "ImageDetailAsssignmentSegue", sender: self)
        }else  if(viewFrom == "Submission" && fileType == "PDF"){
            let strUrl : String = String(describing: dict["Content"]!)
            let urlString = strUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            guard let url = URL(string: urlString!) else {
                return //be safe
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        else if(String(describing: selectedDictionary["Type"]!) == "PDF" ){
            let strUrl : String = String(describing: dict["Content"]!)
            let urlString = strUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            guard let url = URL(string: urlString!) else {
                return //be safe
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }else  if(String(describing: selectedDictionary["Type"]!) == "IMAGE"){
            selectedImageDictionary = DetailTextArray[indexPath.row] as! NSDictionary
            performSegue(withIdentifier: "ImageDetailAsssignmentSegue", sender: self)
        }
    }
    
    
    // MARK:- Api Calling
    func CallAssignmentMessageApi() {
        showLoading()
        strApiFrom = "CallAssignmentMessage"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_VIEW_STUDENT_ASSIGNMENT
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + POST_VIEW_STUDENT_ASSIGNMENT
        }
        
        
        if(bIsArchive){
            requestStringer = baseReportUrlString! + POST_VIEW_STUDENT_ASSIGNMENT
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ProcessBy": ChildId,
                                          "Type" : "0",
                                          "AssignmentId" : String(describing: selectedDictionary["AssignmentId"]!),
                                          "FileType" : String(describing: selectedDictionary["Type"]!),
                                          COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailAssignmentMessage")
    }
    
    
    func CallSubmissionAssignmentMessageApi() {
        showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        var requestStringer = baseUrlString! + POST_VIEW_STUDENT_ASSIGNMENT
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + POST_VIEW_STUDENT_ASSIGNMENT
        }
        if(bIsArchive){
            requestStringer = baseUrlString! + READ_STATUS_UPDATE_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ProcessBy": ChildId,
                                          "Type" : "1",
                                          "AssignmentId" : String(describing: selectedDictionary["AssignmentId"]!),
                                          "FileType" : fileType,
                                          COUNTRY_CODE: strCountryCode]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailAssignmentMessage")
    }
    
    
    
    // MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        
        if(csData != nil){
            
            if let CheckedArray = csData as? NSArray{
                
                if(CheckedArray.count > 0){
                    let Dict : NSDictionary = CheckedArray[0] as! NSDictionary
                    if(String(describing: Dict["result"]!) != "1"){
                        DetailTextArray = []
                        AlertMessage(strAlert: NO_RECORD_MESSAGE)
                    }else{
                        DetailTextArray = NSMutableArray(array: CheckedArray)
                        assignmentTableview.reloadData()
                    }
                    
                }else{
                    DetailTextArray = []
                    AlertMessage(strAlert: NO_RECORD_MESSAGE)
                }
                utilObj.printLogKey(printKey: "DetailTextArray", printingValue: DetailTextArray)
                assignmentTableview.reloadData()
                
                
            }
            else{
                AlertMessage(strAlert: strSomething)
            }
        }
        else
        {
            Util.showAlert("", msg: strSomething)
        }
        
        hideLoading()
        
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util.showAlert("", msg: strSomething)
        
    }
    
    // MARK: - Loading
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        // popupLoading.dismiss(true)
    }
    func AlertMessage(strAlert : String)
    {
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: strAlert, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Okaction")
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
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
                }
            } catch {
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDictionary = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Records Found.."
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ImageDetailAsssignmentSegue"){
            let segueid = segue.destination as! AssignmentImageDetailVC
            segueid.imageUrl = String(describing: selectedImageDictionary["Content"]!)
        }
        
    }
}
