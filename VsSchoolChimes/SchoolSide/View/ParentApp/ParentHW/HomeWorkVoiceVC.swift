//
//  HomeWorkVoiceVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 05/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class HomeWorkVoiceVC: UIViewController ,UITableViewDelegate, UITableViewDataSource,Apidelegate {
    
    @IBOutlet weak var TextDateLabel: UILabel!
    @IBOutlet weak var HiddenLabel: UILabel!
    @IBOutlet weak var MyTableView: UITableView!
    
    var VoiceDict = NSDictionary()
    var SelectedVoiceDict = NSDictionary()
    var languageDictionary = NSDictionary()
    var DetailVoiceArray = NSMutableArray()
    var strApiFrom = NSString()
    var ChildId = String()
    var SchoolId = String()
    var SenderType = String()
    var strLanguage = String()
    var hud : MBProgressHUD = MBProgressHUD()
    var popupLoading : KLCPopup = KLCPopup()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    var Screenheight = CFloat()
    var urlData: URL?
    var strCountryCode = String()
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    var bIsArchive = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        HiddenLabel.isHidden = true
        ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        TextDateLabel.text = String(describing: VoiceDict["HomeworkDate"]!)
        bIsArchive = VoiceDict["is_Archive"] as? Bool ?? false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        strCountryCode = UserDefaults.standard.object(forKey: COUNTRY_CODE) as! String
        self.callSelectedLanguage()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DetailVoiceArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let dict = DetailVoiceArray[indexPath.row] as! NSDictionary
        let DescriptionText:String = String(describing: dict["HomeworkTitle"]!)
        let CheckNilText : String = Util .checkNil(DescriptionText)
        if(CheckNilText != "")        {
            let Stringlength : Int = CheckNilText.count
            
            if(UIDevice.current.userInterfaceIdiom == .pad){
                let MuValue : Int = Stringlength/61
                return (267 + ( 22 * CGFloat(MuValue)))
            }else{
                if(Screenheight > 580){
                    let MuValue : Int = Stringlength/50
                    return (198 + ( 18 * CGFloat(MuValue)))
                    
                }else{
                    let MuValue : Int = Stringlength/44
                    return (198 + ( 18 * CGFloat(MuValue)))
                }
            }
        }else{
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return 222
            }else{
                return 168
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VocieMessageTVCell", for: indexPath) as! VocieMessageTVCell
        cell.backgroundColor = UIColor.clear
        cell.NewLbl.isHidden = true
        let dict = DetailVoiceArray[indexPath.row] as! NSDictionary
        cell.SubjectLbl.text = String(describing: dict["HomeworkSubject"]!)
        cell.DiscriptionTextLbl.text = String(describing: dict["HomeworkTitle"]!)
        cell.playAudioButton.addTarget(self, action: #selector(actionplayAudioButton(sender:)), for: .touchUpInside)
        cell.playAudioButton.setTitle(languageDictionary["teacher_btn_voice_play"] as? String, for: .normal)
        cell.VocieMessageLabel.text = languageDictionary["hint_play_voice"] as? String
        cell.playAudioButton.tag = indexPath.row
        return cell
    }
    
    @objc func actionplayAudioButton(sender: UIButton){
        SelectedVoiceDict = DetailVoiceArray[sender.tag] as! NSDictionary
        downlaodvoice()
    }
    
    @IBAction func actionBack(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK:- Api Calling
    func CallDetailHomeWorkVocieApi() {
        showLoading()
        strApiFrom = "CallDetailHomeWorkVocieApi"
        let apiCall = API_call.init()
        apiCall.delegate = self;
        
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        var requestStringer = baseUrlString! + GET_HOMEWORK_FILES
        if(appDelegate.isPasswordBind == "1" ){
            requestStringer = baseReportUrlString! + GET_HOMEWORK_FILES
        }
        if(bIsArchive){
            requestStringer = baseReportUrlString! + GET_HOMEWORK_FILES_SEEMORE
        }
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"Date" : TextDateLabel.text!,"Type" : "VOICE", COUNTRY_CODE: strCountryCode,MOBILE_NUMBER : appDelegate.strMobileNumber , SCHOOLIID : SchoolId]
        utilObj.printLogKey(printKey: "myDict", printingValue: myDict)
        let myString = Util.convertNSDictionary(toString: myDict)
        utilObj.printLogKey(printKey: "myString", printingValue: myString!)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "CallDetailHomeWorkVocieApi")
    }
    
    // MARK: - Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        hideLoading()
        if(csData != nil){
            if(strApiFrom == "CallDetailHomeWorkVocieApi"){
                if let CheckedArray = csData as? NSArray{
                    let arrayData = CheckedArray
                    DetailVoiceArray.removeAllObjects()
                    if(arrayData.count > 0){
                        for i in 0..<arrayData.count{
                            let dict = CheckedArray[i] as! NSDictionary
                            var MutalDict : NSMutableDictionary = dict.mutableCopy() as! NSMutableDictionary
                            MutalDict["ID"] = String(describing: i)
                            DetailVoiceArray.add(MutalDict)
                        }
                    }else{
                        AlertMessage()
                    }
                    utilObj.printLogKey(printKey: "DetailVoiceArray", printingValue: DetailVoiceArray)
                    Childrens.saveHomeWorkVoiceDetail(DetailVoiceArray as! [Any], ChildId, getDateId: TextDateLabel.text!)
                    MyTableView.reloadData()
                }
                else{
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
        
        if (segue.identifier == "HomeWorkVoiceDetailSeg"){
            let segueid = segue.destination as! VoiceDetailVC
            segueid.urlData = urlData
            segueid.selectedDictionary = SelectedVoiceDict
            segueid.SenderName = "HomeWorkVocie"
            
        }
    }
    
    func AlertMessage(){
        
        let alertController = UIAlertController(title: languageDictionary["alert"] as? String, message: strNoRecordAlert, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: languageDictionary["teacher_btn_ok"] as? String, style: .default) {
            UIAlertAction in
            print("Okaction")
            self.navigationController?.popViewController(animated: true)
        }
        // Add the actions
        alertController.addAction(okAction)
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func downlaodvoice(){
        let strFilePath : String =  String(describing: SelectedVoiceDict["HomeworkContent"]!)
        let audioUrl = URL(string: strFilePath)
        if let audioUrl = URL(string: strFilePath) {
            
            let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
            let strpath = String(describing: SelectedVoiceDict["HomeworkID"]!) + ".MP3"
            let destinationUrl = documentsUrl.appendingPathComponent(strpath)
            urlData = destinationUrl
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "HomeWorkVoiceDetailSeg", sender: self)
                }
            } else {
                if(Util .isNetworkConnected())
                {
                    let sessionConfig = URLSessionConfiguration.default
                    let session = URLSession(configuration: sessionConfig)
                    let request = URLRequest(url:audioUrl)
                    let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                        if let tempLocalUrl = tempLocalUrl, error == nil {
                            // Success
                            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                                print("Successfully downloaded. Status code: \(statusCode)")
                            }
                            do {
                                try FileManager.default.copyItem(at: tempLocalUrl, to: destinationUrl)
                                print("Success")
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "HomeWorkVoiceDetailSeg", sender: self)
                                }
                            } catch (let writeError) {
                                print("Error creating a file \(destinationUrl) : \(writeError)")
                            }
                        } else {
                            print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
                        }
                    }
                    task.resume()
                }else{
                    Util .showAlert("", msg: strNoInternet)
                }
            }
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
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        self.loadViewData()
        
    }
    
    func loadViewData(){
        Screenheight = CFloat(self.view.frame.size.height)
        if(Util .isNetworkConnected()){
            self.CallDetailHomeWorkVocieApi()
        }else{
            DetailVoiceArray = Childrens.getHomeWorkVoiceDetail(fromDB: ChildId, getDateId: TextDateLabel.text!)
            if(DetailVoiceArray.count > 0){
                MyTableView.reloadData()
            }else{
                Util .showAlert("", msg: strNoInternet)
            }
        }
    }
    
}
