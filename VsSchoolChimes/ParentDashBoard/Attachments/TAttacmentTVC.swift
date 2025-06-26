//
//  TAttacmentTVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 21/04/25.
//

import UIKit

class TAttacmentTVC: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var readImg: UIImageView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var homeworkDocs: [FilePath]?
    var attachment:Attachment?
    var ManagementData:ManagemantMessageData?
    var delegate:ReadUpades?
    var ManagementDelegate:ReadUpadesManagemant?
    private var docController: UIDocumentInteractionController?
    override func awakeFromNib() {
        super.awakeFromNib()
        dateLbl.setFont(style: .body, size: FontSize.BodySize)
        descriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        outerView.layer.cornerRadius = 20
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: CellConfingName.ImagePdfCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
        
    }
    func confic(_ attacment:[FilePath]){
        homeworkDocs = attacment
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeworkDocs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImagePdfCvCell, for: indexPath) as! ImagePdfCvCell
        if let img = homeworkDocs?[indexPath.row] {
            cell.imageView.sd_setImage(with: URL(string: img.url ?? ""), placeholderImage: ImageName.placeholder)
            let fileURL = URL(fileURLWithPath: img.url ?? "")
            let iconName = getFileIconName(for: fileURL)
            let iconImage = UIImage(named: iconName)
            cell.IndicaterImageView.image = iconImage
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:100, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let file = homeworkDocs?[indexPath.row], let urlString = file.url, let url = URL(string: urlString) else { return }
        let fileExtension = url.pathExtension.lowercased()
        if let data = attachment{
            delegate?.readStatus(attachment: data)
        }
        if let data = ManagementData {
          //  ManagementDelegate?.readStatus(attachment: ManagementData ?? [])
        }
        
        let vc = getCurrentViewController()
        let vcc = ImageShowVc(nibName: nil, bundle: nil)
        vcc.imageURL = homeworkDocs ?? []
        var homeworkDocs = homeworkDocs ?? []
        let filePath = homeworkDocs[indexPath.row]
        homeworkDocs.remove(at: indexPath.row)
        homeworkDocs.insert(filePath, at: 0)
        vcc.FileURL =  homeworkDocs
        vcc.subjectName = titleLbl.text
        vcc.type = 2
        vcc.modalPresentationStyle = .fullScreen
        vc?.present(vcc, animated: true)
    }
    
    
    //    func openWithDocumentInteraction(url: URL) {
    //        docController = UIDocumentInteractionController(url: url)
    //        docController?.delegate = getCurrentViewController() as? UIDocumentInteractionControllerDelegate
    //
    //        if !(docController?.presentPreview(animated: true) ?? false) {
    //            let fileExtension = url.pathExtension.lowercased()
    //            let appSuggestion = getAppSuggestion(for: fileExtension)
    //
    //            let alert = UIAlertController(
    //                title: "App Required",
    //                message: "To open this '\(fileExtension)' file, please install a suitable app. For example: \(appSuggestion).",
    //                preferredStyle: .alert
    //            )
    //            alert.addAction(UIAlertAction(title: "OK", style: .default))
    //            getCurrentViewController()?.present(alert, animated: true)
    //        }
    //    }
    
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
