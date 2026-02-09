//
//  ImportantInfoViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/7/24.
//

import UIKit
import WebKit

class ImportantInfoViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backBtnNm: UIButton!
    @IBOutlet weak var LoadingView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var LoadingLbl: UILabel!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var menuNameLbl: UILabel!
    
    var global = UserDefaultFileManager.get_globalSelection()
    
    var Child_details = UserDefaultFileManager.get_child_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        webView.navigationDelegate = self
        menuNameLbl.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName,secondLine: Child_details?.school_name ?? "")
        webkitLoading()
    }

   
    @IBAction func backAct() {
        dismiss(animated: true)
    }
    
    func webkitLoading() {
        var Weburl = ""
        if Menu_id.e_books == Menu_id.staffSelectedMenuId{
            Weburl = global?.ebooks_url ?? ""
        }else if Menu_id.Alert == Menu_id.staffSelectedMenuId{
            Weburl = global?.offers_link ?? ""
        }else if Menu_id.Market_place == Menu_id.staffSelectedMenuId{
            Weburl = global?.market_place_url ?? ""
        }
        let url = URL (string: Weburl)
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
