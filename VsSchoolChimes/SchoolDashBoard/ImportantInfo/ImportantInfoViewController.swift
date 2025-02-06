//
//  ImportantInfoViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/7/24.
//

import UIKit
import WebKit

class ImportantInfoViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        webkitLoading()
        
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backVc))
        backView.addGestureRecognizer(backGesture)
    }

    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
   
    @IBAction func backVc() {
        dismiss(animated: true)
    }
    
    func webkitLoading() {
        var urlStr = "https://gradit.voicesnap.com/School/SchoolImportantUpdates?inputpar=9003769500"
        let url = URL (string: urlStr)
               let requestObj = URLRequest(url: url!)
               webView.load(requestObj)
    }

}
