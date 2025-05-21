//
//  EventTVC.swift
//  School Chimes
//
//  Created by Chandhru on 15/05/25.
//

import UIKit

class EventTVC: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var CvHeight: NSLayoutConstraint!
    @IBOutlet weak var newView: UIImageView!
    @IBOutlet weak var forwordBtn: UIButton!
    @IBOutlet weak var dateLble: ShimmerLabel!
    @IBOutlet weak var descriptionLbl: ShimmerLabel!
    @IBOutlet weak var topics: ShimmerLabel!
    @IBOutlet weak var pageViewController: UIPageControl!
    @IBOutlet weak var ImageCollectionView: UICollectionView!
    @IBOutlet weak var subjectName: ShimmerLabel!
    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var SelectBtnHeight: NSLayoutConstraint!
    var countShimmer = 0
    private var docController: UIDocumentInteractionController?
    var event:EventList?
    var file_path:[FilePath]?
    override func awakeFromNib() {
        super.awakeFromNib()
        dateLble.setFont(style: .body, size: FontSize.BodySize)
        descriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        topics.setFont(style: .title, size: FontSize.TitleSize)
        forwordBtn.layer.cornerRadius = 4
        forwordBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        cellview.layer.cornerRadius = 10
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 4
        cellview.backgroundColor = .white
//        cellview.layer.masksToBounds = false
        
        let collection = UINib(nibName: CellConfingName.ImagePdfCvCell, bundle: nil)
        ImageCollectionView.register(collection, forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
        
        ImageCollectionView.delegate = self
        ImageCollectionView.dataSource = self
        
        if let flowLayout = ImageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 10
        }
        
        ImageCollectionView.reloadData()
        countShimmer = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureShimmer()
    }
    
    func configureShimmer() {
        dateLble.removeShimmer()
        descriptionLbl.removeShimmer()
        topics.removeShimmer()
        subjectName.removeShimmer()
    }
    
    func loadImage(urls: [FilePath]) {
        pageViewController.isHidden = false
        pageViewController.numberOfPages = urls.count
        file_path = urls
        pageViewController.currentPage = 0
        ImageCollectionView.reloadData()
    }
    
    @IBAction func forword(_ sender: UIButton) {

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return file_path?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImagePdfCvCell, for: indexPath) as! ImagePdfCvCell
        let docs = file_path
        if let img = docs?[indexPath.row] {
            let fileURL = URL(fileURLWithPath: img.url ?? "")
            let iconName = getFileIconName(for: fileURL)
            cell.IndicaterImageView.image = UIImage(named: iconName)
            if iconName != "image"{
                if let pdfURL = URL(string: img.url ?? "") {
                      let request = URLRequest(url: pdfURL)
                    cell.webView.load(request)
                    cell.webView.isHidden = false
                    cell.imageView.isHidden = true
                  } else {
                      cell.webView.isHidden = true
                      cell.imageView.isHidden = false
                  }
            }else{
                cell.webView.isHidden = true
                cell.imageView.isHidden = false
                cell.imageView.sd_setImage(with: URL(string: img.url ?? ""), placeholderImage: ImageName.placeholder)
            }
            
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: ImageCollectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let maxVisibleIndex = collectionView.indexPathsForVisibleItems.map({ $0.item }).max() {
            pageViewController.currentPage = maxVisibleIndex
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let file = file_path?[indexPath.row],
              let urlString = file.url,
              let url = URL(string: urlString) else { return }

        let fileExtension = url.pathExtension.lowercased()
        let isImage = file.type?.uppercased() == CommonStringFile.IMAGE

        let imageVC = ImageShowVc(nibName: nil, bundle: nil)
        imageVC.imageURL = file_path?.filter { $0.type?.uppercased() == CommonStringFile.IMAGE } ?? []
        imageVC.subjectName = subjectName.text
        imageVC.pdfUrl = file.url
        imageVC.scrollIndex = indexPath
        imageVC.type = isImage ? 2 : 0
        imageVC.modalPresentationStyle = .fullScreen

        getCurrentViewController()?.present(imageVC, animated: true)
    }


    func isWebViewPreviewable(_ ext: String) -> Bool {
        return ["pdf", "txt"].contains(ext.lowercased())
    }
    
    func openWithDocumentInteraction(url: URL) {
        docController = UIDocumentInteractionController(url: url)
        docController?.delegate = getCurrentViewController() as? UIDocumentInteractionControllerDelegate
        
        if !(docController?.presentPreview(animated: true) ?? false) {
            let fileExtension = url.pathExtension.lowercased()
            let appSuggestion = getAppSuggestion(for: fileExtension)
            
            let alert = UIAlertController(
                title: "App Required",
                message: "To open this '\(fileExtension)' file, please install a suitable app. For example: \(appSuggestion).",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            getCurrentViewController()?.present(alert, animated: true)
        }
    }
    
    func getAppSuggestion(for ext: String) -> String {
        switch ext {
        case "pdf":
            return "Adobe Acrobat Reader"
        case "doc", "docx":
            return "Microsoft Word or WPS Office"
        case "ppt", "pptx":
            return "Microsoft PowerPoint"
        case "xls", "xlsx":
            return "Microsoft Excel"
        case "txt", "rtf":
            return "Notepad++ or Apple Notes"
        default:
            return "a compatible document viewer"
        }
    }
    
    
    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController?.topMostViewController()
    }
}

