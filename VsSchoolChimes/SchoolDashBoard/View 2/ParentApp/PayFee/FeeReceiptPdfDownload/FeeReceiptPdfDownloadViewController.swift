//
//  FeeReceiptPdfDownloadViewController.swift
//  VoicesnapSchoolApp
//
//  Created by APPLE on 27/01/23.
//  Copyright © 2023 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper
import WebKit
import KRProgressHUD
class FeeReceiptPdfDownloadViewController: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var feeReceiptWebView: WKWebView!
    @IBOutlet weak var downloadView: UIView!
    
    var getInvoiceId : String!
    var schoolId : String!
    
    
    var downloadUrl : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //        feeReceiptWebView.del
        
        print("getInvoiceId",getInvoiceId)
        GetFeeDetailReceiptPdfLink()
        
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backVc))
        viewBack.addGestureRecognizer(backGesture)
        
        
        
        let downloadGesture = UITapGestureRecognizer(target: self, action: #selector(open_url))
        downloadView.addGestureRecognizer(downloadGesture)
        
    }
    
    
    @IBAction func backVc() {
        dismiss(animated: true)
    }
    
    
    @IBAction  func GetGownloadUrl(){
        
    }
    
    
    
    
    //
    
    func downloadImage(from url: URL) {
        
        print("Download Started")
        KRProgressHUD.show()
        getData(from:url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            //
            print("Download Finished")
            KRProgressHUD.dismiss()
            DispatchQueue.main.async() { [weak self] in
            }
        }
        
        
        
    }
    
    
    
    
    func showToast(message : String, font: UIFont) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } 
    
    
    
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func GetFeeDetailReceiptPdfLink () {
        
        let feeReceiptPdfLinkModal = FeeReceiptPdfDownloadModal()
        
        
        feeReceiptPdfLinkModal.SchoolID = schoolId
        feeReceiptPdfLinkModal.InvoiceId = getInvoiceId
        
        
        let feeReceiptPdfLinkModallStr = feeReceiptPdfLinkModal.toJSONString()
        
        FeeReceiptPdfDownloadRequest.call_request(param: feeReceiptPdfLinkModallStr!) {
            [self]   (res) in
            
            
            
            
            
            let feeReceiptResponse : FeeReceiptPdfDownloadResponse = Mapper<FeeReceiptPdfDownloadResponse>().map(JSONString: res)!
            
            print("feeReceiptResponse.data",feeReceiptResponse.data)
            downloadUrl  = feeReceiptResponse.data
            
            
            if feeReceiptResponse.Status.elementsEqual("1"){
                let url = URL (string: feeReceiptResponse.data)
                let requestObj = URLRequest(url: url!)
                feeReceiptWebView.load(requestObj)
                
                //                GetGownloadUrl ()
                
                
            }
            
            
            
            
        }
        
    }
    
    
    @IBAction func open_url(){
        
        print("open_url","\(downloadUrl)")
        let url = downloadUrl
        let urlget = URL(string:downloadUrl)!
        
        print("urrrrlll",url)
        
        let fileName = urlget.lastPathComponent
        
        savePdf(urlString: url!, fileName: fileName)
        
        
        
    }
    
    func savePdf(urlString:String, fileName:String) {
        DispatchQueue.main.async {
            let url = URL(string: urlString)
            let pdfData = try? Data.init(contentsOf: url!)
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = "\(fileName).pdf"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            do {
                try pdfData?.write(to: actualPath, options: .atomic)
                print("pdf successfully saved!")
                self.view.makeToast("Pdf successfully saved!")
                
            } catch {
                print("Pdf could not be saved")
                self.view.makeToast("Pdf could not be saved")
            }
        }
    }
    
}


class downloadGesture  : UITapGestureRecognizer {
    var url : URL!
}
