//
//  ImportantInfoViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/7/24.
//

import UIKit
import WebKit

class ImportantInfoViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var LoadingView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var BackBtn: UIButton!
    
    @IBOutlet weak var LoadingLbl: UILabel!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    var Header = "Important info"
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        webView.navigationDelegate = self
       
        webkitLoading()
    }

    override func viewDidLayoutSubviews() {
        
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
   
    @IBAction func backAct() {
        dismiss(animated: true)
    }
    
    func webkitLoading() {
        var urlStr = "https://gradit.voicesnap.com/School/SchoolImportantUpdates?inputpar=9003769500"
        let url = URL (string: urlStr)
               let requestObj = URLRequest(url: url!)
               webView.load(requestObj)
    }
    
    // MARK: - WKNavigationDelegate Methods

       // Show loading animation when page starts loading
       func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           LoadingView.isHidden = false
           ActivityIndicator.startAnimating()
       }

       // Hide loading animation when page finishes loading
       func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
           LoadingView.isHidden = true
           ActivityIndicator.stopAnimating()
       }

       // Hide loading animation in case of an error
       func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
           LoadingView.isHidden = true
           ActivityIndicator.stopAnimating()
           print("Error loading page: \(error.localizedDescription)")
       }

}
