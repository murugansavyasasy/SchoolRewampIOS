//
//  PreviewImageVC.swift
//  VsSchoolChimes
//
//  Created by chandhru on 03/12/24.

import UIKit
import WebKit
import Kingfisher
import AVFoundation
import AVKit

class PreviewImageVC: UIViewController, WKNavigationDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var pdfView: WKWebView!
    @IBOutlet weak var scrollView: UIScrollView!

    var img: UIImage?
    var selectedFileURL: URL?
    var type: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView.navigationDelegate = self
        deleteBtn.layer.cornerRadius = deleteBtn.frame.width / 2
        deleteBtn.layer.borderColor = UIColor.red.cgColor
        deleteBtn.layer.borderWidth = 1
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.zoomScale = 1.0
        
        // Optional double-tap zoom
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        
        if type?.uppercased() == AttachmentTypeString.IMAGE {
            ActivityIndicator.stopAnimating()
            imgView.isHidden = false
            pdfView.isHidden = true
            
            if let image = img {
                imgView.image = image
            } else if let url = selectedFileURL {
                imgView.kf.setImage(with: url)
            }
        }else {
            pdfView.isHidden = false
                
            if let url = selectedFileURL {
                loadPDF(from: url.absoluteString)
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1.0 {
            scrollView.setZoomScale(2.5, animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
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
            } else {
                print("❌ Local file does not exist: \(url.path)")
            }
            
        } else if url.scheme == "http" || url.scheme == "https" {
            let request = URLRequest(url: url)
            pdfView.load(request)
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
