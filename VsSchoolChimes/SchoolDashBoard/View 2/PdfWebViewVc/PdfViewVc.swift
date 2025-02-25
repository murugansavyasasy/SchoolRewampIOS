//
//  PdfViewVc.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 05/11/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import WebKit
import KRProgressHUD

class PdfViewVc: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    var myurlstring = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("myurlstring",myurlstring)
      
        KRProgressHUD.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
            KRProgressHUD.dismiss()
        }
        
        
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        
        if let url = URL(string: myurlstring) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }


   

    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
}
