//
//  CertificatePreviewVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 07/08/25.
//

import UIKit
import WebKit

class CertificatePreviewVc: UIViewController {

    @IBOutlet weak var certificatedDateView: UIView!
    @IBOutlet weak var processingView: UIView!
    @IBOutlet weak var certificatedDateLbl: UILabel!
    @IBOutlet weak var requestOnLbl: UILabel!
    @IBOutlet weak var certificateTypeLbl: UILabel!
    @IBOutlet weak var reasonLbl: UILabel!
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var pendingMessageLbl: UILabel!
    @IBOutlet weak var certificateNameLbl: UILabel!
    
    var certificate = CertificateRequest()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Uiupdate()
    }

    func Uiupdate(){
        
        certificateNameLbl.text = certificate.type
        
        let reqDate = formattedDateStatus(from:certificate.requested_on ?? "" )
        requestOnLbl.text = reqDate
        certificateTypeLbl.text = certificate.type
        reasonLbl.text = certificate.reason
        fullview.layer.cornerRadius = 8
        
        pendingMessageLbl.text = certificate.message
        
        if let issuedOn = certificate.issued_on, !issuedOn.isEmpty {
            certificatedDateView.isHidden = false
            let certifiDate = formattedDateStatus(from: issuedOn)
            certificatedDateLbl.text = certifiDate
            processingView.isHidden = true
            webview.isHidden = false
        } else {
            print("Issued date is empty")
            certificatedDateView.isHidden = true
            processingView.isHidden = false
            webview.isHidden = true
        }

        
        if let url = URL(string: certificate.url ?? "") {
                    let request = URLRequest(url: url)
            webview.load(request)
                }
    }
    @IBAction func backbtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    

}
