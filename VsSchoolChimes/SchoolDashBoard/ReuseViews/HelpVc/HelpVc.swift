//
//  HelpVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit
import WebKit

class HelpVc: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var HelppageHeader: UILabel!
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    var passVale = 1
    var global = UserDefaultFileManager.get_globalSelection()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        webview.navigationDelegate = self
        HelppageHeader.text = MenuTapbar.shared.Help
        HelppageHeader.setFont(style: .header, size: FontSize.HeaderSize+3)
        
        webkitLoading()
    }
    
    func webkitLoading() {
        let urlStr = global?.helpline_url ?? ""
        let url = URL (string: urlStr)
               let requestObj = URLRequest(url: url!)
        webview.load(requestObj)
    }
    
    // MARK: - WKNavigationDelegate Methods

       // Show loading animation when page starts loading
       func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           
           ActivityIndicator.startAnimating()
       }

       // Hide loading animation when page finishes loading
       func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
           
           ActivityIndicator.stopAnimating()
           ActivityIndicator.isHidden = true
       }

       // Hide loading animation in case of an error
       func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
           
           ActivityIndicator.stopAnimating()
           ActivityIndicator.isHidden = true
           print("Error loading page: \(error.localizedDescription)")
       }

}
