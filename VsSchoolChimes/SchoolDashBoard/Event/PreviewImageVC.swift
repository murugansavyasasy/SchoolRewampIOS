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

    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var outerView: UIView!
    var img :UIImage?
    var selectedFileURL : URL?
    var type:String?
    @IBOutlet weak var pdfView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        pdfView.navigationDelegate = self
        
       
        if type?.uppercased() != "IMAGE" {
            imgView.isHidden = true
            pdfView.isHidden = false
        }else{
            if img != nil{
                imgView.image = img
            }else{
                imgView.kf.setImage(with: selectedFileURL)
            }
            
            ActivityIndicator.stopAnimating()
            imgView.isHidden = false
            pdfView.isHidden = true
        }
        if let url = selectedFileURL {
            loadPDF(from: url.absoluteString)
        }
        
    }
    private func loadPDF(from urlString: String) {
        if urlString.starts(with: "file://") {
            // Local PDF
            guard let localURL = URL(string: urlString),
                  FileManager.default.fileExists(atPath: localURL.path) else {
                print("❌ Local file does not exist or invalid path.")
                return
            }

            pdfView.loadFileURL(localURL, allowingReadAccessTo: localURL.deletingLastPathComponent())
            print("📄 Loaded local PDF: \(localURL.path)")

        } else if urlString.starts(with: "http") {
            // Remote PDF
            guard let remoteURL = URL(string: urlString) else {
                print("❌ Invalid remote URL.")
                return
            }

            let request = URLRequest(url: remoteURL)
            pdfView.load(request)
            print("🌐 Loaded remote PDF: \(remoteURL)")
            
        } else {
            print("⚠️ Unknown file type or unsupported URL.")
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
