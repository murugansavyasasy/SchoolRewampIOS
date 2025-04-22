//
//  PreviewImageVC.swift
//  VsSchoolChimes
//
//  Created by admin on 03/12/24.
//

import UIKit
import WebKit

class PreviewImageVC: UIViewController,WKNavigationDelegate {

    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var pdfView: WKWebView!
    
    var img :UIImage?
    var selectedFileURL : URL?
    
    /*(override func viewDidLoad() {
        super.viewDidLoad()
        pdfView.navigationDelegate = self
        
        imgView.image = img
        if  user_inputs.selectedFileType == "DOCUMENT" {
            imgView.isHidden = true
            pdfView.isHidden = false
            if let url = selectedFileURL{
                loadPDF(url)
            }
            
        }else{
            ActivityIndicator.stopAnimating()
            imgView.isHidden = false
            pdfView.isHidden = true
        }
    }
    
 func loadPDF(_ url:URL) {

        if FileManager.default.fileExists(atPath: url.path) {
            pdfView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            let url = "https://www.orimi.com/pdf-test.pdf"
            let request = URLRequest(url: URL(string: url)!)
            pdfView.load(request)
        }
    }*/
    
    override func viewDidLoad() {
           super.viewDidLoad()
           
           // Set the navigation delegate
           pdfView.navigationDelegate = self
           
           // Set the image if available
           imgView.image = img
           
           // Handle document vs. image previewing
           if user_inputs.selectedFileType == "DOCUMENT" {
               imgView.isHidden = true
               pdfView.isHidden = false
               
               guard let originalURL = selectedFileURL else {
                   // If no file URL is provided, load default PDF.
                   loadDefaultPDF()
                   return
               }
               
               // Copy the file to a persistent location (Documents directory)
               if let persistentURL = prepareFileForLoading(originalURL: originalURL) {
                   loadPDF(from: persistentURL)
               } else {
                   // If copying fails, fallback
                   loadDefaultPDF()
               }
           } else {
               // For non-document types, show the image view only
               ActivityIndicator.stopAnimating()
               imgView.isHidden = false
               pdfView.isHidden = true
           }
       }
       
       // MARK: - File Handling Methods
       /// Copies the file from its original URL to the Documents directory and returns the new URL.
       func prepareFileForLoading(originalURL: URL) -> URL? {
           let fileManager = FileManager.default
           let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
           let destinationURL = documentsDir.appendingPathComponent(originalURL.lastPathComponent)
           
           do {
               // Remove an existing file at destination if needed.
               if fileManager.fileExists(atPath: destinationURL.path) {
                   try fileManager.removeItem(at: destinationURL)
               }
               try fileManager.copyItem(at: originalURL, to: destinationURL)
               return destinationURL
           } catch {
               print("Error copying file to Documents directory: \(error)")
               return nil
           }
       }
       
       /// Loads the PDF using `loadFileURL` if the file exists, otherwise falls back.
       func loadPDF(from url: URL) {
           if FileManager.default.fileExists(atPath: url.path) {
               // Allow reading from the file's directory.
               pdfView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
           } else {
               loadDefaultPDF()
           }
       }
       
       /// Loads a default PDF from an online source.
       func loadDefaultPDF() {
           guard let url = URL(string: "https://www.orimi.com/pdf-test.pdf") else { return }
           let request = URLRequest(url: url)
           pdfView.load(request)
       }
       
       // Optionally, if you encounter caching or access issues between successive file loads,
       // you might want to recreate your WKWebView instance.
       func resetWebView() {
           pdfView.navigationDelegate = nil
           pdfView.removeFromSuperview()
           
           let newWebView = WKWebView(frame: outerView.bounds)
           newWebView.navigationDelegate = self
           outerView.addSubview(newWebView)
           
           // You might need to update constraints or frames accordingly.
           // Then update your reference if needed.
           self.pdfView = newWebView
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
