//
//  PaymentWebVC.swift
//  VoicesnapSchoolApp
//
//  Created by Madhav@Veni on 07/02/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import Foundation

class PaymentWebVC: UIViewController,Apidelegate,UIWebViewDelegate{
    
    @IBOutlet weak var myWebView: UIWebView!
    var hud : MBProgressHUD = MBProgressHUD()
    var ChildIDString = String()
    var SchoolIDString = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navTitle()
        
        ChildIDString = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolIDString = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
        
        CallPaymentInfoApi()
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func CallPaymentInfoApi()
    {
        showLoading()
        let apiCall = API_call.init()
        apiCall.delegate = self;
        let baseUrlString = UserDefaults.standard.object(forKey:PARENTBASEURL) as? String
        let requestStringer = baseUrlString! + GET_PAYMENT_URL
        
        
        let requestString = requestStringer.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        
        let myDict:NSMutableDictionary = ["ChildID" : ChildIDString,"SchoolID": SchoolIDString]
        Constants.printLogKey("Device myDict", printValue: myDict)
        
        let myString = Util.convertNSDictionary(toString: myDict)
        
        apiCall.nsurlConnectionFunction(requestString, myString, "deviceToken")
    }
    //MARK: API RESPONSE DELEGATE
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!){
        hideLoading()
        
        if(csData != nil){
            var Message = String()
            var Status = String()
            
            if((csData?.count)! > 0){
                if (csData == nil){
                    
                }else{
                    if((csData?.count)! > 0){
                        let dicUser : NSDictionary = csData!.object(at: 0) as! NSDictionary
                        Status = String(describing: dicUser["Status"]!)
                        Message = String(describing: dicUser["Message"]!)
                        if(Status == "1"){
                            showLoading()
                            self.myWebView.loadRequest(NSURLRequest(url: NSURL(string: String(describing: dicUser["URL"]!))! as URL) as URLRequest)
                            
                        }else{
                            Util .showAlert("", msg: Message)
                        }
                    }
                }
            }else{
                Util.showAlert("", msg: Message as String?)
            }
            
        }else{
            Util .showAlert("", msg: "");
        }
    }
    
    @objc func failedresponse(_ pagename: Error!) {
        hideLoading()
        Util .showAlert("", msg: "strSomething");
    }
    
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hideLoading()
    }
    
    func navTitle()
    {
        
        let titleLabel = UILabel()
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.view.frame.width , height: 45)
        titleLabel.textColor = UIColor (red:0.0/255.0, green:183.0/255.0, blue: 190.0/255.0, alpha: 1)
        let secondWord = "Make "
        let thirdWord   = "Payment"
        let comboWord = secondWord + thirdWord
        let attributedText = NSMutableAttributedString(string:comboWord)
        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22), NSAttributedString.Key.foregroundColor: UIColor.white]
        let range = NSString(string: comboWord).range(of: secondWord)
        attributedText.addAttributes(attrs, range: range)
        
        titleLabel.attributedText = attributedText
        self.navigationItem.titleView = titleLabel
    }
    
}
