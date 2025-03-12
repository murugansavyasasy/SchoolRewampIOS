//
//  UploadSignatureVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll_IMac on 17/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit


class UploadSignatureVC: UIViewController,YPSignatureDelegate,Apidelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var signatureView: YPDrawSignatureView!
    
    var hud : MBProgressHUD = MBProgressHUD()
    
    var popupLoading : KLCPopup = KLCPopup()
    
    var uploadSignatureImage : NSData? = nil
    
    weak var selectedDetailDictionary = NSDictionary()
    weak var selectedDictionary = NSDictionary()
    
    var strAgreeText : NSString = ""
    var strUploadID : NSString = ""
    var ChildId = String()
    var SchoolId = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let utilObj = UtilClass()
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ChildId = String(describing: appDelegate.SchoolDetailDictionary["ChildID"]!)
        SchoolId = String(describing: appDelegate.SchoolDetailDictionary["SchoolID"]!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        clearButton.layer.cornerRadius = 5
        clearButton.clipsToBounds = true
        submitButton.layer.cornerRadius = 5
        submitButton.clipsToBounds = true
        submitButton.isUserInteractionEnabled = false
        submitButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        
        touchEnableforSignView()
    }
    @IBAction func actionBack(_ sender: Any)
    {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func touchEnableforSignView() -> Void {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UploadSignatureVC.handleTap(_:)))
        tap.delegate = self
        signatureView.addGestureRecognizer(tap)
        signatureView.isUserInteractionEnabled = true
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        submitButton.backgroundColor = UIColor(red: 1.0/255.0, green: 154.0/255.0, blue: 232.0/255.0, alpha: 1)
        submitButton.isUserInteractionEnabled = true;
    }
    
    // Function for clearing the content of signature view
    @IBAction func clearSignature(_ sender: Any) {
        submitButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        self.signatureView.clear()
        submitButton.isUserInteractionEnabled = false;
    }
    
    // Function for saving signature
    @IBAction func saveSignature(_ sender: UIButton) {
        if let signatureImage = self.signatureView.getSignature(scale: 10) {
            uploadSignatureImage = (signatureImage.pngData() as NSData?)!
            
            if(Util .isNetworkConnected())
            {
                callUploadSinature()
            }
            else
            {
                Util .showAlert("", msg: NETWORK_ERROR)
            }
        }
    }
    
    // MARK: - Delegate Methods
    
    
    func didStart() {
        submitButton.backgroundColor = UIColor(red: 1.0/255.0, green: 154.0/255.0, blue: 232.0/255.0, alpha: 1)
    }
    func didFinish() {
    }
    
    // MARK: - Api Calling
    func callUploadSinature() -> Void {
        
        showLoading()
        let arrUserDataa : NSMutableArray = []
        //{"ID":"124","ReplyText":"fdsfdfdf","ChildID":"450180","SchoolID":"1302"}
        let myDict:NSMutableDictionary = ["ChildID": ChildId,"SchoolID" : SchoolId,"ReplyText" : strAgreeText,"ID" :selectedDetailDictionary!.object(forKey: "MessageID") as Any,]
        
        let myString = Util.convertNSDictionary(toString: myDict)
        let myDict1:NSMutableDictionary = ["Info": arrUserDataa as Any]
        let arrInfo : NSMutableArray = []
        
        arrInfo.add(myDict1)
        let apiCall = API_call.init()
        apiCall.delegate = self;
        apiCall.callPassParms(myString, "upload", uploadSignatureImage as Data?)
    }
    
    // MARK: - Api Response
    @objc func responestring(_ csData: NSMutableArray?, _ pagename: String!) {
        
        if(csData != nil)
        {
            
            if((csData?.count)! > 0){
                for var i in 0..<(csData?.count)!
                {
                    let dicUser : NSDictionary = csData!.object(at: i) as! NSDictionary
                    let Mystring = String(describing: dicUser["Status"]!)
                    let Message = String(describing: dicUser["Message"]!)
                    if(Mystring == "y"){
                        
                        Util.showAlert("", msg: Message)
                        self.presentingViewController!.presentingViewController!.dismiss(animated: false, completion: nil)
                        
                    }else{
                        
                        Util.showAlert("", msg: Message)
                    }
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
        Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
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
    
}
