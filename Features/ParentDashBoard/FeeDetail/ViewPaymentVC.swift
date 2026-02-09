//
//  ViewPaymentVC.swift
//  School Chimes
//
//  Created by Chandhru on 26/05/25.
//

import UIKit
import PDFKit
import QuickLook

class ViewPaymentVC: UIViewController,QLPreviewControllerDataSource {
    
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var documentView: UIView!
    var previewController = QLPreviewController()
    var documentURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        privewVc()
    }
    
    func privewVc(){
        var fileURL: [FilePath] = []
        fileURL.removeAll()
        fileURL.append(FilePath(url: "https://schoolchimes-fee-receipts.s3.ap-south-1.amazonaws.com/undefined/fee_receipt/PDF_1748065242703.pdf", type: ""))
        let vc = ImageShowVc()
        vc.fileURL = fileURL
        vc.subjectName = "Images & Docs"
        vc.index = 0
        vc.scrollIndex = IndexPath(row: 0, section: 0)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
   
    
    @IBAction func backBtn(_ sender: UIButton) {
        if let documentURL = documentURL {
            try? FileManager.default.removeItem(at: documentURL)
            print("PDF deleted manually")
        }
        dismiss(animated: true)
    }
    func downloadPDF(from url: URL) {
        let task = URLSession.shared.downloadTask(with: url) { [weak self] localURL, response, error in
            guard let self = self else { return }
            
            if let localURL = localURL, error == nil {
                // Save to a permanent location
                let fileManager = FileManager.default
                let docsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = docsPath.appendingPathComponent(url.lastPathComponent)
                
                // Remove if already exists
                try? fileManager.removeItem(at: destinationURL)
                
                do {
                    try fileManager.moveItem(at: localURL, to: destinationURL)
                    DispatchQueue.main.async {
                        self.documentURL = destinationURL
                        self.showDocument()
                    }
                } catch {
                    print("File move error: \(error)")
                }
            } else {
                print("Download error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        task.resume()
    }
    func showDocument() {
        // Prevent adding multiple times
        if previewController.parent == nil {
            previewController.dataSource = self
            previewController.view.translatesAutoresizingMaskIntoConstraints = false
            addChild(previewController)
            documentView.addSubview(previewController.view)
            
            // Add constraints to fit it properly
            NSLayoutConstraint.activate([
                previewController.view.leadingAnchor.constraint(equalTo: documentView.leadingAnchor),
                previewController.view.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
                previewController.view.topAnchor.constraint(equalTo: documentView.topAnchor),
                previewController.view.bottomAnchor.constraint(equalTo: documentView.bottomAnchor)
            ])
            
            previewController.didMove(toParent: self)
        }
    }
    
    @IBAction func dowloadBtn(_ sender: UIButton) {
        sender.isEnabled = false
        guard let fileURL = documentURL?.absoluteString, let filename = getFileName(from: fileURL) else {
            print("❌ Invalid file URL or file name")
            sender.isEnabled = true
            return
        }
        
        let downloader = FileDownloader()
        downloader.downloadFile(
            from: fileURL,
            folderName: "PaymentRecipts",
            fileName: filename
        ) { result in
            DispatchQueue.main.async { [self] in
                sender.isEnabled = true
                switch result {
                case .success(let filePath):
                    CustomAlert.showAlertWithOkAction(
                        title:"",
                        message: "\(filename) Downloaded successfully ✅",
                        on: self)
                    
                case .failure(let error):
                    CustomAlert.showAlertWithOkAction(
                        title:"",
                        message: "\(filename) Download Failed ❌",
                        on: self)
                }
            }
        }
    }
    
    
    // MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return documentURL! as QLPreviewItem
    }
    func getFileName(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        return url.lastPathComponent
    }
}
