//
//  HomeViewController.swift
//  waly
//
//  Created by decoders on 28/01/21.
//

import Foundation
import UIKit


class EditProfileVC : UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var myWebView: UIWebView!

    var hud : MBProgressHUD = MBProgressHUD()
var strPageFrom = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let strMobileNo = UserDefaults.standard.object(forKey: USERNAME) as! String
    var StudentIDString = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        if(strPageFrom == "edit"){
            let strProfile = "\(appDelegate.strProfileTitle)"
            StudentIDString = String(describing: self.appDelegate.SchoolDetailDictionary["ChildID"]!)
            self.title = strProfile

            loadWebURl()
        }else{
            self.title = "Help"
            loadhelp()
        }
        

    }
    
  
    //MARK: Webview delegate
       
       func loadWebURl(){
        let strProfileLink = "\(appDelegate.strProfileLink)\(StudentIDString)"
        print("loading web urll\(strProfileLink)")

        let url = URL(string: strProfileLink)
           myWebView.loadRequest(URLRequest(url: url!))
           
       }
    func loadhelp(){
        let strhelplink = "\(appDelegate.Helplineurl)"
        print("loading web urll\(strhelplink)")
        
        let helpurl = URL(string: strhelplink)
        myWebView.loadRequest(URLRequest(url: helpurl!))
    }
       
       
    func webViewDidStartLoad(_ webView: UIWebView) {
        showLoading()
      }

      func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
      {
        hideLoading()
      }

      func webViewDidFinishLoad(_ webView: UIWebView)
      {
        hideLoading()

      }
    @IBAction func actionDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAccept(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func showLoading() -> Void {
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        hud.hide(true)
    }
    
}

