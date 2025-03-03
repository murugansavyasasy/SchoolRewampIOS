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
    var passValue = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Pdfview.navigationDelegate = self
        
        if let pdfURL = URL(string: "https://schoolchimes.com/vs_web/terms_conditions/") {
            let request = URLRequest(url: pdfURL)
            Pdfview.load(request)
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        if passValue == 1{
            view.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
            outerView.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        }else{
            view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
            outerView.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
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
