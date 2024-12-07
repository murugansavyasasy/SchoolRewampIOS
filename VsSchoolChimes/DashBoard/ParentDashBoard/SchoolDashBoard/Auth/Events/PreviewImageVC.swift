//
//  PreviewImageVC.swift
//  VsSchoolChimes
//
//  Created by admin on 03/12/24.
//

import UIKit
import WebKit

class PreviewImageVC: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var outerView: UIView!
    var img :UIImage?
    var selectedFileURL : URL?
    @IBOutlet weak var pdfView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.image = img
        print(selectedFileURL)
        if selectedFileURL != nil {
            imgView.isHidden = true
            pdfView.isHidden = false
        }else{
            imgView.isHidden = false
            pdfView.isHidden = true
        }
        loadPDF()
//        outerView.layer.cornerRadius = 10
//        outerView.layer.shadowColor = UIColor.black.cgColor
//        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        outerView.layer.shadowRadius = 5
//        outerView.layer.shadowOpacity = 0.3
    }
    private func loadPDF() {
        
        guard let fileURL = selectedFileURL else {
            print("No selected file URL.")
            return
        }

        if FileManager.default.fileExists(atPath: fileURL.path) {
            pdfView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        } else {
            let url = "https://www.orimi.com/pdf-test.pdf"
            let request = URLRequest(url: URL(string: url)!)
            pdfView.load(request)
            print("File does not exist at path: \(fileURL.path)")
        }
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
