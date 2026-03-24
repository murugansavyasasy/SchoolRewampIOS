//////
//////  ImageShowVc.swift
//////  VsSchoolChimes
//////
//////  Created by admin on 18/11/24.
import UIKit
import SDWebImage
import WebKit
//import QuickLook


protocol DidSelectDelegate: AnyObject {
    func select(index: Int, value: String?, Img: [String], Pdf: String?, text: String?, type: String)
}

enum MediaType: String {
    case image
    case video
    case document // for pdf, doc, etc.
}

extension ImageShowVc: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

class ImageShowVc: UIViewController {
    
//    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
//        return previewURL == nil ? 0 : 1
//    }
//
//    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
//        return previewURL! as NSURL
//    }
//    
//    func previewControllerDidDismiss(_ controller: QLPreviewController) {
//
//        guard let url = previewURL else { return }
//
//        do {
//            try FileManager.default.removeItem(at: url)
//            print("✅ File deleted")
//        } catch {
//            print("❌ Error deleting file:", error)
//        }
//
//        previewURL = nil
//    }
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pdfView: WKWebView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var pageController: UIPageControl!
    
    var imageItems: [String] = []
    var imageURL: [FilePath] = []
    var fileURL: [FilePath] = []
    var attachment: [AttachmentItem]?
    var delegate: DidSelectDelegate?
    
    var pageName = ""
    var pdfUrl: String?
    var type: String?
    var index: Int?
    var subjectName: String?
    var scrollIndex: IndexPath?
    var downloadUrl: String?
    var fileType: String?
    var isPaymentReceipt = false
    var dateAndTimeForVideo : String = ""
//    var previewURL: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView.navigationDelegate = self
        titleLbl.text = subjectName
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(UINib(nibName: CellConfingName.ImageShowCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImageShowCVCell)
        cv.register(UINib(nibName: CellConfingName.VideoPlayerCVC, bundle: nil), forCellWithReuseIdentifier: CellConfingName.VideoPlayerCVC)
        
        pageController.numberOfPages = attachment?.count ?? fileURL.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        uiUpdate(type: type ?? "")
        let count = attachment?.count ?? fileURL.count
        
        DispatchQueue.main.async {
            self.cv.layoutIfNeeded()
            if let index = self.index, index < count {
                let indexPath = IndexPath(item: index, section: 0)
                self.cv.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                if let attachment = self.attachment{
                    self.saveBtn.isHidden = true
                }else{
                    self.downloadUrl = self.fileURL[index].url
                    self.fileType = self.fileURL[index].type
                    self.saveBtn.isHidden = false
                }
                   
                
                self.pageController.currentPage = index
            }
        }
    }
    
    @IBAction func saveToFolder(_ sender: UIButton) {
        let popoverVC = shareAndDownloadVc(nibName: nil, bundle: nil)
        popoverVC.view.backgroundColor = .white
        popoverVC.dowloadUrl = downloadUrl
        popoverVC.fileType = fileType
        popoverVC.isPaymentReceipt = isPaymentReceipt
        popoverVC.preferredContentSize = CGSize(width: 150, height: 100)
        popoverVC.modalPresentationStyle = .popover
        
        if let popover = popoverVC.popoverPresentationController {
            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .up
            popover.delegate = self
        }
        present(popoverVC, animated: true)
    }
    
    @IBAction func back(_ sender: Any) {
        if pageName == "Assigment" {
            delegate?.select(index: 0, value: "", Img: [""], Pdf: "", text: "", type: "")
        } else {
            dismiss(animated: true)
        }
    }
    
}

extension ImageShowVc: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachment?.count ?? fileURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let attachments = attachment, !attachments.isEmpty {
            let item = attachments[indexPath.item]
            let fileType = item.fileType.lowercased()
            let mediaType = MediaType(rawValue: fileType)
            print(fileType)
            switch mediaType {
            case .image:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageShowCVCell, for: indexPath) as! ImageShowCVCell
                if let urlStr = item.imageURL, let imageURL = URL(string: urlStr) {
                    cell.imageView.sd_setImage(with: imageURL, placeholderImage: item.image)
                } else {
                    cell.imageView.image = item.image
                }
                cell.imageView.isHidden = false
                cell.WebView.isHidden = true
                return cell
                
            case .video:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.VideoPlayerCVC, for: indexPath) as! VideoPlayerCVC
                if let videoURL = item.VideoURl {
                    cell.configure(with: videoURL, parentVC: self, dateAndTimeForVideo: dateAndTimeForVideo)
                }
                return cell
                
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageShowCVCell, for: indexPath) as! ImageShowCVCell
                if let urlStr = item.imageURL, let url = URL(string: urlStr) {
                    cell.WebView.load(URLRequest(url: url))
                }
                cell.imageView.isHidden = true
                cell.WebView.isHidden = false
                return cell
            }
        } else {
            let item = fileURL[indexPath.item]
            let fileType = item.type?.lowercased() ?? ""
            let mediaType = MediaType(rawValue: fileType)
            
            switch mediaType {
            case .image:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageShowCVCell, for: indexPath) as! ImageShowCVCell
                if let urlStr = item.url, let url = URL(string: urlStr) {
                    cell.imageView.sd_setImage(with: url, placeholderImage: ImageName.placeholder)
                }
                cell.imageView.isHidden = false
                cell.WebView.isHidden = true
                return cell
                
            case .video:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.VideoPlayerCVC, for: indexPath) as! VideoPlayerCVC
                if let urlStr = item.url, let videoUrl = URL(string: urlStr) {
                    cell.configure(with: videoUrl, parentVC: self, dateAndTimeForVideo: dateAndTimeForVideo)
                }
                return cell
                
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageShowCVCell, for: indexPath) as! ImageShowCVCell
                if let urlStr = item.url, let url = URL(string: urlStr) {
                    cell.WebView.load(URLRequest(url: url))
                }
//                cell.WebView.navigationDelegate = self
                cell.imageView.isHidden = true
                cell.WebView.isHidden = false
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cv.frame.width, height: cv.frame.height - 40)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: cv.contentOffset, size: cv.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let count = attachment?.count ?? fileURL.count
        
        guard let indexPath = cv.indexPathForItem(at: visiblePoint), indexPath.item < count else {
            print("❌ Invalid index during scroll")
            return
        }
        
        scrollIndex = indexPath
        
        if !fileURL.isEmpty {
            let item = fileURL[indexPath.item]
            downloadUrl = item.url
            fileType = item.type
        }
        pageController.currentPage = indexPath.item
    }
}

extension ImageShowVc: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        print("❌ WebView failed: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        print("❌ Provisional navigation failed: \(error.localizedDescription)")
    }
    
//    func webView(_ webView: WKWebView,
//                 decidePolicyFor navigationResponse: WKNavigationResponse,
//                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
//
//        guard let response = navigationResponse.response as? HTTPURLResponse,
//              let url = response.url else {
//            decisionHandler(.allow)
//            return
//        }
//
//        let mimeType = response.mimeType ?? ""
//
//        print("MIME TYPE:", mimeType)
//
//        // Handle both correct + wrong MIME
//        if mimeType == "application/pdf" ||
//           mimeType == "filetype/pdf" ||
//           url.absoluteString.lowercased().contains(".pdf") {
//
//            decisionHandler(.cancel)
//            openPDFManually(url: url)
//            return
//        }
//
//        decisionHandler(.allow)
//    }
//    
//    func openPDFManually(url: URL) {
//
//        URLSession.shared.downloadTask(with: url) { localURL, response, error in
//
//            guard let localURL = localURL else { return }
//
//            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
//
//            try? FileManager.default.removeItem(at: tempURL)
//
//            do {
//                try FileManager.default.moveItem(at: localURL, to: tempURL)
//
//                DispatchQueue.main.async {
//                    self.previewURL = tempURL
//                    let previewVC = QLPreviewController()
//                    previewVC.dataSource = self
//                    previewVC.delegate = self
//                    self.present(previewVC, animated: true)
//                }
//
//            } catch {
//                print("Error:", error)
//            }
//
//        }.resume()
//    }
}
