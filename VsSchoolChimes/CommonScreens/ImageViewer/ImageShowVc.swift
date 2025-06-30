//
//  ImageShowVc.swift
//  VsSchoolChimes
//
//  Created by admin on 18/11/24.
//

import UIKit
import SDWebImage
import WebKit

class ImageShowVc: UIViewController{
    
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pdfView: WKWebView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var PageController: UIPageControl!
    
    var imageIterms : [String] = []
    var imageURL : [FilePath] = []
    var FileURL : [FilePath] = []
    var delegate:DidSelectDelegate?
    var pageName = ""
    var pdfUrl:String?
    var type:Int?
    var index:Int?
    var subjectName:String?
    var scrollIndex:IndexPath?
    var dowloadUrl:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        pdfView.navigationDelegate = self
        TitleLbl.text = subjectName
        cv.delegate = self
        cv.dataSource = self
        
        cv.register(UINib(nibName: CellConfingName.ImageShowCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImageShowCVCell)
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)

        dowloadUrl = FileURL.first?.url
        PageController.numberOfPages = FileURL.count
        
    }

    @IBAction func saveToFolder(_ sender: UIButton) {
        sender.isEnabled = false
        guard let fileURL = dowloadUrl, let filename = getFileName(from: fileURL) else {
            print("❌ Invalid file URL or file name")
            sender.isEnabled = true
            return
        }
        
        let downloader = FileDownloader()
        downloader.downloadFile(
            from: fileURL,
            folderName: "SchoolChimesDownloads",
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
    func getFileName(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        return url.lastPathComponent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uiUpdate(type: type ?? 0)
        DispatchQueue.main.async {
            self.cv.layoutIfNeeded()
            if let index = self.index, index < self.FileURL.count {
                self.cv.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
        PageController.currentPage = index ?? 0
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    func uiUpdate(type:Int){
        DispatchQueue.main.async { [self] in
            switch type{
            case 0:
                cv.isHidden = false
                pdfView.isHidden = true
                textView.isHidden = true
            case 1:
                cv.isHidden = true
                pdfView.isHidden = true
                textView.isHidden = false
            case 2:
                ActivityIndicator.stopAnimating()
                cv.isHidden = false
                pdfView.isHidden = true
                textView.isHidden = true
            default:
                if let pdfURL = URL(string: pdfUrl ?? "") {
                    let request = URLRequest(url: pdfURL)
                    ActivityIndicator.startAnimating()
                    pdfView.load(request)
                    dowloadUrl = pdfUrl
                } else {
                    print("Invalid URL")
                }
                cv.isHidden = true
                textView.isHidden = true
                pdfView.isHidden = false
            }
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        if pageName == "Assigment"{
            delegate?.select(index: 0, value: "",Img:[""],Pdf:"",text:"",type:"")
            
        }else{
            dismiss(animated: true)
        }
    }
}

extension ImageShowVc : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FileURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageShowCVCell, for: indexPath) as! ImageShowCVCell
        
        switch type {
            
        case 0:
            if let url = URL(string: FileURL[indexPath.row].url ?? "") {
                let request = URLRequest(url: url)
                cell.WebView.load(request)
            }
            cell.WebView.isHidden = false
            
        case 2:
            cell.imageView.sd_setImage(with: URL(string: FileURL[indexPath.row].url ?? ""),placeholderImage: ImageName.placeholder)
            cell.WebView.isHidden = true
        default:
            ""
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width:cv.frame.width, height: cv.frame.height - 40)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let centerPoint = CGPoint(
            x: cv.bounds.midX,
            y: cv.bounds.midY
        )

        guard let indexPath = cv.indexPathForItem(at: centerPoint) else {
            print("❌ Could not detect center cell")
            return
        }

        scrollIndex = indexPath
        let fileItem = FileURL[indexPath.item]
        dowloadUrl = fileItem.url
        PageController.currentPage = indexPath.item
        print("✅ Final paged index: \(indexPath.item)")
    }
}

extension ImageShowVc : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        ActivityIndicator.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ActivityIndicator.stopAnimating()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        ActivityIndicator.stopAnimating()
    }
}
