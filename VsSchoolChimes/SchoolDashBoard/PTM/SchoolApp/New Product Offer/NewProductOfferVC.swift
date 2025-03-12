//
//  NewProductOfferVC.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MacMini2 on 02/07/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class NewProductOfferVC: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var myWebView: UIWebView!
    var hud : MBProgressHUD = MBProgressHUD()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var viewFromString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        callSelectedLanguage()
        loadWebURl()
    }
    //MARK: Webview delegate
    
    func loadWebURl(){
        let strUserMobileNo : String =   UserDefaults.standard.object(forKey: USERNAME) as! String
        var strURL : String!
        if(viewFromString == "p21"){
            strURL  = appDelegate.strOfferLink + strUserMobileNo
        }else{
            strURL = appDelegate.strProductLink + strUserMobileNo
        }
        
        showLoading()
        let url = URL(string: strURL)
        myWebView.loadRequest(URLRequest(url: url!))
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        hideLoading()
    }
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
    }
    
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
            
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        if(viewFromString == "p21"){
            self.title = LangDict["special_offer"] as? String
            self.title = "Important Info"
        }else{
            self.title = "New Products"
        }
        
    }
    
}
