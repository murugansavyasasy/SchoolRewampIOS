//
//  PdfDetailVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll_IMac on 17/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class PdfDetailVC: UIViewController,UIGestureRecognizerDelegate,UIWebViewDelegate {
    
    var selectedDictionary = NSDictionary()
    var selectedPDFDictionary = NSDictionary()
    
    @IBOutlet var TextDateLabel: UILabel!
    @IBOutlet var TextTitleLabel: UILabel!
    
    @IBOutlet  var PopupLoadingUIView: UIView!
    @IBOutlet  var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var YesButton: UIButton!
    @IBOutlet weak var NoButton: UIButton!
    @IBOutlet weak var NoImage: UIImageView!
    @IBOutlet weak var YesImage: UIImageView!
    
    var hud : MBProgressHUD = MBProgressHUD()
    
    var popupLoading : KLCPopup = KLCPopup()
    
    @IBOutlet weak var PopupSignatureUIView: UIView!
    
    @IBOutlet weak var signhere: UILabel!
    @IBOutlet weak var myWebView: UIWebView!
    
    var uploadSignatureImage : NSData? = nil
    
    var strAgreeText : NSString = ""
    var strUploadID : NSString = ""
    var strDraw : NSString = ""
    var strSignQuestion : NSString = ""
    var strSignView : NSString = ""
    @IBOutlet var SignatureUIView: UIView!
    
    @IBOutlet weak var signQuestionlbl: UILabel!
    
    let singcolorText :UIColor = UIColor (red:1.0/255.0, green: 154.0/255.0, blue: 232.0/255.0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        TextDateLabel.text = selectedPDFDictionary["Time"] as? String
        TextTitleLabel.text = selectedPDFDictionary["Subject"] as? String
        
        PopupLoadingUIView.isHidden = true
    }
    
    @IBAction func actionBack(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        callWebView()
        
        let tapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TappedOnSignherView(_:)))
        signhere?.addGestureRecognizer(tapped)
        tapped.delegate = self
        signhere.isUserInteractionEnabled = false
        
    }
    
    
    @objc func TappedOnSignherView(_ sender: UITapGestureRecognizer){
        
        
        YesImage.image = UIImage (named : "Disable_Gray")
        NoImage.image = UIImage (named : "Disable_Gray")
        signhere.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "UploadSeg", sender: self)
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
    }
    func callWebView() -> Void {
        
        showLoading()
        
        activityIndicator.startAnimating()
        
        self.view.bringSubviewToFront(PopupLoadingUIView)
        
        signhere.textColor = UIColor.gray
        
        let website:String =  String(describing: selectedPDFDictionary["URL"]!)
        
        strUploadID = String(describing: selectedPDFDictionary["MessageID"]!) as NSString
        
        myWebView.delegate = self
        
        
        let pdfUrl:URL = URL(string: website.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        
        
        
        let req = NSURLRequest(url: pdfUrl)
        print(req)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now())
        {
            self.myWebView.loadRequest(req as URLRequest)
        }
        
        myWebView.scalesPageToFit = true
        
    }
    
    @IBAction func actionYesButton(_ sender: UIButton) {
        
        YesImage.image = UIImage (named : "Enable_Green")
        NoImage.image = UIImage (named : "Disable_Gray")
        
        strAgreeText = "Yes"
        signhere.textColor = singcolorText
        signhere.isUserInteractionEnabled = true
        
    }
    
    @IBAction func actionNoButton(_ sender: UIButton) {
        
        YesImage.image = UIImage (named : "Disable_Gray")
        NoImage.image = UIImage (named : "Enable_Green")
        
        strAgreeText = "No"
        signhere.textColor = singcolorText
        signhere.isUserInteractionEnabled = true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "UploadSeg")
        {
            let segueid = segue.destination as! UploadSignatureVC
            segueid.selectedDetailDictionary = selectedPDFDictionary
            segueid.selectedDictionary = selectedDictionary
            segueid.strAgreeText = strAgreeText
            
            
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        PopupLoadingUIView.isHidden = true
        activityIndicator.stopAnimating()
        hideLoading()
        Util.showAlert("", msg: SERVER_RESPONSE_FAILED)
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        PopupLoadingUIView.isHidden = true
        activityIndicator.stopAnimating()
        hideLoading()
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
    
    deinit
    {
        self.myWebView.loadRequest(NSURLRequest(url: NSURL(string: "about:blank")! as URL) as URLRequest)
        
        
    }
    
}
