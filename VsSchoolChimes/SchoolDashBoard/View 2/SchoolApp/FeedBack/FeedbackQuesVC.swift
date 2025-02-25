//
//  FeedbackQuesVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 11/06/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class FeedbackQuesVC: UIViewController,Apidelegate,UITableViewDelegate, UITableViewDataSource,UITextViewDelegate{
    var hud : MBProgressHUD = MBProgressHUD()
    let utilObj = UtilClass()
    
    var arraySectionData: NSArray = []
    
    var arrayAnsKey: NSMutableArray = []
    var SelectedarrayAnsKey: NSMutableArray = []
    var arrFeedback: NSArray = []
    var dicCountryName : NSDictionary = [:]
    var RequestDict = NSMutableDictionary()
    
    var jsonString : String = ""
    var CellSelected : String = ""
    @IBOutlet weak var SubmitButton: UIButton!
    
    @IBOutlet weak var OthercommentTextview: UITextView!
    @IBOutlet weak var customFooterView: UIView!
    
    
    @IBOutlet weak var FeedbackTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Feedback to voicesnap"
        SubmitButton.layer.cornerRadius = 5
        SubmitButton.clipsToBounds = true
        
        self.CallQues()
    }
     func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
     {
        textView.becomeFirstResponder()
        return true
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
  func textViewShouldEndEditing(_ textView: UITextView) -> Bool
 {
   textView.resignFirstResponder()
   return true
 }
    
    func textViewDidChange(_ textView: UITextView)
    {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        return 35
        
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
            return 70
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
            headerLabel.frame = CGRect(x: 0, y: 10, width:
                tableView.bounds.size.width, height: 50)
            headerLabel.font = UIFont(name: "Arial", size: 24)
        }
        else
        {
            
            headerView.frame = CGRect(x: 0, y: 0, width:
                tableView.bounds.size.width, height: 65)
            headerLabel.frame = CGRect(x: 0, y: 10, width:
                tableView.bounds.size.width, height: 45)
            headerLabel.font = UIFont(name: "Arial", size: 17)
            
            
        }
        //headerLabel.font = UIFont(name: "Verdana", size: 20)
        headerLabel.numberOfLines = 3
        headerLabel.textColor = UIColor.black
        let dict:NSDictionary = arrFeedback[section] as! NSDictionary
        let strSection:String = String(describing: section + 1) + ") "
        let strAns : String = String(describing: dict["Question"]!)
        let strTitle : String = strSection + strAns
        headerLabel.text = strTitle
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! FeedbackQuesTVCell
        let dict:NSDictionary = arraySectionData[indexPath.row] as! NSDictionary
        CellSelected = "Yes"
        let strAns:String = String(describing: dict["AnswerID"]!)
        arrayAnsKey[indexPath.section] = strAns
        SelectedarrayAnsKey[indexPath.section] = String(describing: indexPath.section) + "~" + strAns
        
        FeedbackTableView.reloadData()
        
        
    }
    
    
    func CallQues()
    {
        // var url : String = "http://106.51.127.215:8070/api/TeachersApiV4/GetFeedbackQuestions"
        let url = URL(string: FEEDBACK_URL)
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
                        
                        self.arrayAnsKey[i] = " "
                        self.SelectedarrayAnsKey[i] = " "
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
    
    
    if(Util .isNetworkConnected())
    {
         if(CellSelected == "Yes")
         {
            self.CallSendFeedbackApi()
        }else
         {
             Util.showAlert("", msg: SELECT_FEEDBACK)
        }
    
    }
    else
    {
    Util.showAlert("", msg: NO_INTERNET)
    }
    }
    
    
    func CallSendFeedbackApi()
    {
        utilObj.printLogKey(printKey: "SelectedarrayAnsKey", printingValue: SelectedarrayAnsKey)
         utilObj.printLogKey(printKey: "arrayAnsKey", printingValue: arrayAnsKey)
        
        do
        {
            if let postData : NSData = try JSONSerialization.data(withJSONObject: SelectedarrayAnsKey, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData?
            {
                jsonString = NSString(data: postData as Data, encoding: String.Encoding.utf8.rawValue)! as String
            }
        }
        catch
        {
            // print(error)
        }
        utilObj.printLogKey(printKey: "jsonString", printingValue: jsonString)
        
        showLoading()
       
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:BASEURL) as? String
        let requestStringer = baseUrlString! + INSERT_FEEDBACK_DETAIL
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        
       // let myDict:NSMutableDictionary = ["StudentID" : StudentIDString,"Option" : OPTION_LIBRARY_METHOD]
        
        RequestDict.setValue(SelectedarrayAnsKey, forKey: "AnswerDetails")
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
                 let Status = String(describing: dict["Status"]!)
                 let Message = String(describing: dict["Message"]!)
                 if(Status == "1")
                 {
                 Util.showAlert("", msg: Message)
                 self.navigationController?.popViewController(animated: true)
                 
                 }else{
                 
                 Util.showAlert("", msg: Message)
                 
                 }
                 }
                
            }
            else{
                Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
            }
            
        }
        else
        {
            Util.showAlert("", msg: SERVER_ERROR)
        }
        
        
        
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
        
    }
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
        // popupLoading = KLCPopup(contentView: hud, showType: KLCPopupShowType.none , dismissType:KLCPopupDismissType.none,maskType: KLCPopupMaskType.dimmed , dismissOnBackgroundTouch:  false , dismissOnContentTouch: false )
        //popupLoading.dimmedMaskAlpha =  0
        //popupLoading.show()
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
        //popupLoading.dismiss(true)
    }
    
    
}
