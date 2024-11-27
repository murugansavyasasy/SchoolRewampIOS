//
//  TermsAndCondVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 27/11/24.
//

import UIKit
import WebKit

//"https://schoolchimes.com/vs_web/terms_conditions/"
class TermsAndCondVC: UIViewController {

    @IBOutlet weak var Pdfview: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let pdfURL = URL(string: "https://schoolchimes.com/vs_web/terms_conditions/") {
              let request = URLRequest(url: pdfURL)
             Pdfview.load(request)
            
          }
            else {
              print("Invalid URL")
          }

        
    }
    
        @IBAction func BackAct(_ sender: Any) {
            
            dismiss(animated: true)
            
        }
    
    
        }
