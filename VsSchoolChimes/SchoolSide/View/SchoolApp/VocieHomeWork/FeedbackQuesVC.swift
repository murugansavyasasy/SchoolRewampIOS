//
//  FeedbackQuesVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 11/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class FeedbackQuesVC: UIViewController,Apidelegate,UITableViewDelegate, UITableViewDataSource,UITextViewDelegate{
    
    
    @IBOutlet weak var SubmitButton: UIButton!
    @IBOutlet weak var OthercommentLabel: UILabel!
    @IBOutlet weak var OthercommentTextview: UITextView!
    @IBOutlet weak var customFooterView: UIView!
    @IBOutlet weak var FeedbackTableView: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var hud : MBProgressHUD = MBProgressHUD()
    let utilObj = UtilClass()
    var arraySectionData: NSArray = []
    var arrayAnsKey: NSMutableArray = []
    var SelectedarrayAnsKey: NSMutableArray = []
    var arrFeedback: NSArray = []
    var dicCountryName : NSDictionary = [:]
    var RequestDict = NSMutableDictionary()
    var languageDict = NSDictionary()
    var strLanguage = String()
    var CellSelected : String = ""
    var strNoRecordAlert = String()
    var strNoInternet = String()
    var strSomething = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        // self.title = "Feedback to voicesnap"
        self.callSelectedLanguage()
        SubmitButton.layer.cornerRadius = 5
        SubmitButton.clipsToBounds = true
        OthercommentTextview.layer.borderWidth = 0.3
        OthercommentTextview.layer.cornerRadius = 3
        OthercommentTextview.clipsToBounds = true
        OthercommentTextview.layer.borderColor = UIColor.lightGray.cgColor
        
        if(Util .isNetworkConnected())
        {
            self.CallQues()
            
        }
        else
        {
            Util .showAlert("", msg: strNoInternet)
        }
        
        
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        setupTextViewAccessoryView()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            self.view.frame.origin.y -= 260
        }else
        {
            self.view.frame.origin.y -= 200
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.frame.origin.y = 0
        
    }
    
    func setupTextViewAccessoryView() {
        let toolBar: UIToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        let flexsibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(didPressDoneButton))
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        toolBar.items = [flexsibleSpace, doneButton]
        OthercommentTextview.inputAccessoryView = toolBar
    }
    
    @objc func didPressDoneButton(button: UIButton) {
        
        OthercommentTextview.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return arrFeedback.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let Sectiondict:NSDictionary = arrFeedback[section] as! NSDictionary
        arraySectionData = Sectiondict["AnswerList"] as! NSArray
        return arraySectionData.count
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat = 0
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            height = 45
        }else{
            height = 35
        }
        return height
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackQuesTVCell", for: indexPath) as! FeedbackQuesTVCell
        cell.backgroundColor = UIColor.clear
        let Sectiondict:NSDictionary = arrFeedback[indexPath.section] as! NSDictionary
        arraySectionData = Sectiondict["AnswerList"] as! NSArray
        let dict:NSDictionary = arraySectionData[indexPath.row] as! NSDictionary
        cell.FeedbackAnsLbl.text = String(describing: dict["Answer"]!)
        let strAns:String = arrayAnsKey.object(at: indexPath.section) as! String
        
        
        let strDictAns:String = String(describing: dict["AnswerID"]!)
        if(strAns == strDictAns )
        {
            cell.RadioImg.image = UIImage(named : "RadioSelect")
        }else{
            cell.RadioImg.image = UIImage(named : "RadioNormal")
        }
        
        return cell
        
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 80
        }else{
            return 65
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return customFooterView
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        let headerLabel = UILabel()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            headerView.frame = CGRect(x: 0, y: 0, width:
                                        tableView.bounds.size.width, height: 70)
            headerLabel.frame = CGRect(x: 0, y: 20, width:
                                        tableView.bounds.size.width, height: 50)
            headerLabel.font = UIFont(name: "Arial", size: 24)
        }
        else
        {
            
            headerView.frame = CGRect(x: 0, y: 0, width:
                                        tableView.bounds.size.width, height: 65)
            headerLabel.frame = CGRect(x: 0, y: 15, width:
                                        tableView.bounds.size.width, height: 45)
            headerLabel.font = UIFont(name: "Arial", size: 17)
            
            
        }
        
        headerLabel.numberOfLines = 3
        headerLabel.textColor = UIColor.black
        let dict:NSDictionary = arrFeedback[section] as! NSDictionary
        let strSection:String = String(describing: section + 1) + ") "
        let strAns : String = String(describing: dict["Question"]!)
        let strTitle : String = strSection + strAns
        headerLabel.text = strTitle
        //headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        if(strLanguage == "ar"){
            headerLabel.textAlignment = .right
        }else{
            headerLabel.textAlignment = .left
        }
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let Sectiondict:NSDictionary = arrFeedback[indexPath.section] as! NSDictionary
        arraySectionData = Sectiondict["AnswerList"] as! NSArray
        let dict:NSDictionary = arraySectionData[indexPath.row] as! NSDictionary
        
        CellSelected = "Yes"
        let strAns:String = String(describing: dict["AnswerID"]!)
        arrayAnsKey[indexPath.section] = strAns
        SelectedarrayAnsKey[indexPath.section] = String(describing: indexPath.section + 1) + "~" + strAns
        
        self.FeedbackTableView.reloadData()
        
        
    }
    
    
    func CallQues()
    {
        // var url : String = "http://106.51.127.215:8070/api/TeachersApiV4/GetFeedbackQuestions"
        
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        var requestStringer = baseUrlString! + FEEDBACKQUE
        let baseReportUrlString = UserDefaults.standard.object(forKey:NEWLINKREPORTBASEURL) as? String
        
        if(appDelegate.isPasswordBind == "1"){
            requestStringer = baseReportUrlString! + FEEDBACKQUE
        }
        let url = URL(string: requestStringer)
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print("error")
            }else{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! NSArray
                    
                    self.arrFeedback = json
                    self.utilObj.printLogKey(printKey: "csData", printingValue: json)
                    for i in 0..<self.arrFeedback.count
                    {
                        
                        self.arrayAnsKey[i] = ""
                        self.SelectedarrayAnsKey[i] = ""
                    }
                    OperationQueue.main.addOperation({
                        self.FeedbackTableView.reloadData()
                    })
                    
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
    }
    
    @IBAction func actionSubmit(_ sender: Any) {
        OthercommentTextview.resignFirstResponder()
        
        if(Util .isNetworkConnected())
        {
            if(CellSelected == "Yes")
            {
                self.CallSendFeedbackApi()
            }else
            {
                Util.showAlert("", msg: languageDict["select_feedback"] as? String)
            }
            
        }
        else
        {
            Util.showAlert("", msg: strNoInternet)
        }
    }
    
    
    func CallSendFeedbackApi()
    {
        showLoading()
        var APIarrayAnsKey: NSMutableArray = []
        for i in 0..<SelectedarrayAnsKey.count
        {
            let nullStr : String = SelectedarrayAnsKey[i] as! String
            if(nullStr != "")
            {
                APIarrayAnsKey.add(nullStr)
            }
            
        }
        
        let jsonString = APIarrayAnsKey.componentsJoined(by: ",")
        
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + INSERT_FEEDBACK_DETAIL
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        
        RequestDict.setValue(jsonString, forKey: "AnswerDetails")
        RequestDict.setValue(OthercommentTextview.text!, forKey: "OtherInfo")
        let myString = Util.convertDictionary(toString: RequestDict)
        apiCall.nsurlConnectionFunction(requestString, myString, "")
        
        
        
        
    }
    // MARK:- Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        
        hideLoading()
        if(csData != nil)
        {
            utilObj.printLogKey(printKey: "csData", printingValue: csData!)
            if let CheckedArray = csData as? NSArray
            {
                
                for i in 0..<CheckedArray.count
                {
                    let dict = CheckedArray[i] as! NSDictionary
                    let Status = String(describing: dict["result"]!)
                    let Message = String(describing: dict["Message"]!)
                    if(Status == "0")
                    {
                        Util.showAlert("", msg: Message)
                        
                        
                    }else{
                        
                        Util.showAlert("", msg: Message)
                        self.navigationController?.popViewController(animated: true)
                        
                    }
                }
                
            }
            else{
                Util.showAlert("", msg: strSomething)
            }
            
        }
        else
        {
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
    func navTitle(){
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        //titleLabel.textColor = UIColor (red:243.0/255.0, green: 191.0/255.0, blue: 145.0/255.0, alpha: 1)
        titleLabel.textColor = UIColor (red:166.0/255.0, green: 114.0/255.0, blue: 155.0/255.0, alpha: 1)
        let secondWord : String =  languageDict["feedback"] as? String ?? "Feedback"//"Feedback "
        let thirdWord : String  =  languageDict["to_voicesnap"] as? String ?? "to voicesnap"//"to voicesnap"
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
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
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
        languageDict = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.navigationController?.navigationBar.semanticContentAttribute = .forceRightToLeft
            self.view.semanticContentAttribute = .forceRightToLeft
            OthercommentLabel.textAlignment = .right
            OthercommentTextview.textAlignment = .right
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.navigationController?.navigationBar.semanticContentAttribute = .forceLeftToRight
            self.view.semanticContentAttribute = .forceLeftToRight
            OthercommentLabel.textAlignment = .left
            OthercommentTextview.textAlignment = .left
            
        }
        strNoRecordAlert = LangDict["no_records"] as? String ?? "No Record Found"
        strNoInternet = LangDict["check_internet"] as? String ?? "Check your Internet connectivity"
        strSomething = LangDict["catch_message"] as? String ?? "Something went wrong.Try Again"
        OthercommentLabel.text = languageDict["other_comments"] as? String
        SubmitButton.setTitle(languageDict["feedback_submit"] as? String, for: .normal)
        self.navTitle()
    }
    
    
}
