//
//  PreviewImageVC.swift
//  VsSchoolChimes
//
//  Created by admin on 03/12/24.
//

import UIKit
import WebKit
import Kingfisher

class PreviewImageVC: UIViewController,WKNavigationDelegate {
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var pdfView: WKWebView!
    
    var img :UIImage?
    var selectedFileURL : URL?
    var type:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView.navigationDelegate = self
        deleteBtn.layer.cornerRadius = deleteBtn.frame.width/2
        deleteBtn.layer.borderColor = UIColor.black.cgColor
        deleteBtn.layer.borderWidth = 1
        
        if type?.uppercased() == AttachmentTypeString.IMAGE {
            
            ActivityIndicator.stopAnimating()
            imgView.isHidden = false
            pdfView.isHidden = true
            
            if img != nil{
                imgView.image = img
            }else{
                imgView.kf.setImage(with: selectedFileURL)
            }
        }else{
            
            if let url = selectedFileURL {
                loadPDF(from: url.absoluteString)
            }
        }
    }
    
    
    private func loadPDF(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL string.")
            return
        }
        
        if url.isFileURL {
            // Local PDF
            if FileManager.default.fileExists(atPath: url.path) {
                pdfView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
                print("📄 Loaded local PDF: \(url.path)")
            } else {
                print("❌ Local file does not exist: \(url.path)")
            }
            
        } else if url.scheme == "http" || url.scheme == "https" {
            // Remote PDF
            let request = URLRequest(url: url)
            pdfView.load(request)
            print("🌐 Loaded remote PDF: \(url)")
            
        } else {
            print("⚠️ Unsupported URL scheme: \(url.scheme ?? "nil")")
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        ActivityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ActivityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        ActivityIndicator.stopAnimating()
    }
}
