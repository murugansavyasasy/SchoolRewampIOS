
//  ImageCvCell.swift
//  VsSchoolChimes
//
//  Created by admin on 28/10/24.
//

import UIKit
import WebKit

class ImageCvCell: UICollectionViewCell, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageViews: UIImageView!
    
    @IBOutlet weak var imageCount: UILabel!
    @IBOutlet weak var pdf: WKWebView!
    @IBOutlet weak var TrashIcon: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    var delegate:DeleteImge?
    var selectedFileURL : URL? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        pdf.navigationDelegate = self
        imageCount.layer.cornerRadius = imageCount.frame.width/2
        TrashIcon.layer.cornerRadius = TrashIcon.frame.width/2
        TrashIcon.layer.borderWidth = 1
        TrashIcon.layer.borderColor = UIColor.black.cgColor
        ActivityIndicator.stopAnimating()
        let filePath = "file:///private/var/mobile/Containers/Data/Application/4881C40B-0842-4004-A75C-A6C2B640BCCF/tmp/com.voicesnap.schoolmessenger-Inbox/sample.pdf"
        guard let fileURL = URL(string: filePath) else {
            print("Invalid file URL.")
            
            return
        }
        ActivityIndicator.hidesWhenStopped = true
    }
    
    
    // This method is called when a link is clicked within the web view
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // Check the URL clicked
        if let url = navigationAction.request.url {
            if url.absoluteString == "https://www.specificlink.com" {
                // Handle specific click
                print("Specific link clicked")
                // You can handle the click here, for example, open another view
            } else {
                // Allow the navigation for other URLs
                print("Other link clicked: \(url.absoluteString)")
            }
        }
        
        // Allow navigation (or cancel it)
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        ActivityIndicator.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ActivityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        ActivityIndicator.stopAnimating()
        print("Error loading page: \(error.localizedDescription)")
    }
    @IBAction func deleteImg(_ sender: UIButton) {
        delegate?.deleteImage(index: sender.tag)
    }
    
}
