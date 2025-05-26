//
//  NoticeBoardTvcellTableViewCell.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit
import SDWebImage

protocol SelectNotice: AnyObject {
    
    func didTapButton(title: String, content: String, items: [FilePath])
}

@available(iOS 14.0, *)
class NoticeBoardTvcellTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var SelectBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var dicriptContent: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var Pinview: UIView!
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pagecontroller: UIPageControl!
    @IBOutlet weak var pagecontrollerheight: NSLayoutConstraint!
    @IBOutlet weak var newView: UIView!
    @IBOutlet weak var SelectBtn: UIButton!
    @IBOutlet weak var CollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var CollectionBaseview: UIView!
    
    var delegate : SelectNotice?
    
    var homeworkDocs:[FilePath]?
    private var docController: UIDocumentInteractionController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        CollectionBaseview.layer.cornerRadius = 10
        CollectionBaseview.layer.shadowColor = UIColor.black.cgColor
        CollectionBaseview.layer.shadowOffset = CGSize(width: 0, height: 2)
        CollectionBaseview.layer.shadowRadius = 5
        CollectionBaseview.layer.shadowOpacity = 0.3
        
        // Inner content view with corner radius
        collectionview.layer.cornerRadius = 10
        collectionview.layer.masksToBounds = true
        
        newView.isHidden = true
        pinImage.layer.masksToBounds = true
        datelbl.setFont(style: .body, size: FontSize.BodySize)
        dicriptContent.setFont(style: .body, size: FontSize.BodySize)
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        SelectBtn.layer.cornerRadius = 10
        SelectBtn.setTitleFont(style: .body, size: FontSize.BodySize)
       
        pagecontroller.isHidden = true
        
        cellview.layer.cornerRadius = 10
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 3
        cellview.layer.masksToBounds = false
        cellview.layer.borderWidth = 0.5
        cellview.layer.borderColor = UIColor.systemGray.cgColor
        
        Pinview.layer.cornerRadius = Pinview.frame.width/2
        
        let collection = UINib(nibName:CellConfingName.ImagePdfCvCell, bundle: nil)
        collectionview.register(collection, forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
        
        collectionview.delegate = self
        collectionview.dataSource = self
        
        pagecontroller.numberOfPages = homeworkDocs?.count ?? 0
    }
    
    func loadImage(urls: [FilePath]) {
        collectionview.isHidden = false
        pagecontroller.isHidden = false
        homeworkDocs = urls
        pagecontroller.numberOfPages = homeworkDocs?.count ?? 0
        pagecontroller.currentPage = 0
        collectionview.reloadData()
    }
    
    @IBAction func Select(_ sender: UIButton) {
                delegate?.didTapButton(title: TitleLbl.text!, content: dicriptContent.text!, items: homeworkDocs ?? [])
        
        
    }
  
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
       
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        return homeworkDocs?.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImagePdfCvCell, for: indexPath) as! ImagePdfCvCell
        
        if let img = homeworkDocs?[indexPath.row] {
            let fileURL = URL(fileURLWithPath: img.url ?? "")
            let iconName = getFileIconName(for: fileURL)
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
            let iconImage = UIImage(named: iconName)
            cell.IndicaterImageView.image = iconImage
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 110)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let file = homeworkDocs?[indexPath.row], let urlString = file.url, let url = URL(string: urlString) else { return }
        let fileExtension = url.pathExtension.lowercased()
        
        //        if isWebViewPreviewable(fileExtension) || file.type?.lowercased() == "image" {
        let vc = getCurrentViewController()
        let vcc = ImageShowVc(nibName: nil, bundle: nil)
        vcc.imageURL = homeworkDocs?.filter({ img in
            img.type?.uppercased() == CommonStringFile.IMAGE
        }) ?? []
        vcc.FileURL = homeworkDocs ?? []
        vcc.pdfUrl = homeworkDocs?[indexPath.row].url
        vcc.scrollIndex = indexPath
        vcc.type = homeworkDocs?[indexPath.row].type?.uppercased() != CommonStringFile.IMAGE ? 0 : 2
        vcc.modalPresentationStyle = .fullScreen
        vc?.present(vcc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        pagecontroller.currentPage = indexPath.item
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
