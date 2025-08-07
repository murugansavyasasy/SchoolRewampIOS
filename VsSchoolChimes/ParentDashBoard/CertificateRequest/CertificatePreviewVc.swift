//
//  CertificatePreviewVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 07/08/25.
//

import UIKit
import WebKit

class CertificatePreviewVc: UIViewController {

    @IBOutlet weak var webview: WKWebView!
  
    @IBOutlet weak var fullview: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fullview.layer.cornerRadius = 8
        if let url = URL(string: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/Documents//file-sample_150kB.pdf") {
                    let request = URLRequest(url: url)
            webview.load(request)
                }
       
    }


    @IBAction func backbtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    

}
