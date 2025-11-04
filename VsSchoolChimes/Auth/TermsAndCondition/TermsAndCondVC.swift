//
//  TermsAndCondVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 27/11/24.
//

import UIKit
import WebKit

//"https://schoolchimes.com/vs_web/terms_conditions/"
class TermsAndCondVC: UIViewController,WKNavigationDelegate {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var LoadingLbl: UILabel!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var LoadingView: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var Pdfview: WKWebView!
    var url : String?
    var tittleString:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Pdfview.navigationDelegate = self
        BackBtn.setTitle(tittleString ?? "", for: .normal)
        if let pdfURL = URL(string: url ?? "https://schoolchimes.com/vs_web/terms_conditions/") {
            let request = URLRequest(url: pdfURL)
            Pdfview.load(request)
        }
    }
    
    // MARK: - WKNavigationDelegate Methods
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        LoadingView.isHidden = false
        ActivityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LoadingView.isHidden = true
        ActivityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        LoadingView.isHidden = true
        ActivityIndicator.stopAnimating()
    }
    
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    
}
