//
//  SubmissionTVC.swift
//  School Chimes
//
//  Created by Chandhru on 09/06/25.
//

import UIKit
import AVFoundation
import AVKit

class SubmissionTVC: UITableViewCell, AVPlayerViewControllerDelegate, UIAdaptivePresentationControllerDelegate, SelectedId, UIPopoverPresentationControllerDelegate {
    func selectId(id: String?, edit: Bool?) {
        delegate?.selectId(id:id, edit: edit)
    }
    
    
    @IBOutlet weak var attachmentStack: UIStackView!
    @IBOutlet weak var EditBtn1: UIButton!
    @IBOutlet weak var EditBtn: UIButton!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var imgCount: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var assignmentTitle: UILabel!
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var timeLeft: UILabel!
    var FilesUrl:[FilePath]?
    var player: AVPlayer?
    var delegate:SelectedId?
    var selectedId:String?
    var edit:Bool?
    var delete:Bool?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Style outer view (rounded card style)
        outerView.layer.cornerRadius = 10
        outerView.layer.borderWidth = 1
        outerView.layer.borderColor = UIColor.systemGray5.cgColor
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 0.05
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 4
        outerView.layer.masksToBounds = false
        // Fonts
//        assignmentTitle.setFont(style: .body, size: FontSize.TitleSize)
//        subjectName.setFont(style: .body, size: FontSize.BodySize)
//        date.setFont(style: .body, size: FontSize.BodySize)
//        descriptionLbl.setFont(style: .body, size: FontSize.BodySize)
//        timeLeft.setFont(style: .body, size: FontSize.BodySize)
        EditBtn.isHidden = true
        EditBtn1.isHidden = true
        [img1, img2, img3, imgCount].forEach { $0?.isHidden = true }
        [img1, img2, img3].forEach {
            if let view = $0 {
                setBorderAndCornerRadius(for: view, cornerRadius: view.frame.width / 2)
            }
        }
        imgCount.layer.cornerRadius = imgCount.frame.width / 2
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        [img1,img2,img3].forEach { $0?.image = nil }
        imgCount.setTitle(nil, for: .normal)
    }
    func loadFiles(into cell: SubmissionTVC, files: [FilePath]) {
        // Hide all image views initially
        [cell.img1, cell.img2, cell.img3].forEach { $0?.isHidden = true }
        cell.imgCount.isHidden = true
        
        if files.isEmpty {
            cell.attachmentStack.isHidden = true
            return
        } else {
            cell.attachmentStack.isHidden = false
        }
        for (index, file) in files.prefix(3).enumerated() {
            guard let urlString = file.url, let url = URL(string: urlString) else { continue }
            let imageViews = [cell.img1, cell.img2, cell.img3]
            let imageView = imageViews[index]
            imageView?.isHidden = false
            
            if file.type?.lowercased() != "image" {
                imageView?.image = UIImage(named: getFileIconName(for: url)) ?? UIImage(systemName: "doc.fill")
            } else {
                imageView?.sd_setImage(with: url)
            }
        }
        if files.count > 3 {
            cell.imgCount.setTitle("+\(files.count - 3)", for: .normal)
            cell.imgCount.isHidden = false
        }
    }

    
    func setBorderAndCornerRadius(for view: UIView, cornerRadius: CGFloat = 8.0, borderWidth: CGFloat = 1.0, borderColor: UIColor = .lightGray) {
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = borderWidth
        view.layer.borderColor = borderColor.cgColor
        view.clipsToBounds = true
    }
    func edit(edit:Bool,delete:Bool,selectedId:String){
        self.selectedId = selectedId
        self.delete = delete
        self.edit = edit
        EditBtn.isHidden = !(edit || delete)
        EditBtn1.isHidden = !(edit || delete)
    }
    @IBAction func edit(_ sender: UIButton) {
        let popoverContentVC = PopupVC(edit: self.edit ?? false, delete: self.delete ?? false, selectedId: selectedId)
        popoverContentVC.delegate = self
        popoverContentVC.preferredContentSize = CGSize(width: 120, height: edit ?? false ? 90:50)
        popoverContentVC.modalPresentationStyle = .popover
        if let popoverController = popoverContentVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .down
            popoverController.delegate = self
        }
        
        // For iPhones: Present as a pop-up instead of full-screen
        if UIDevice.current.userInterfaceIdiom == .phone {
            popoverContentVC.modalPresentationStyle = .overFullScreen
            popoverContentVC.view.backgroundColor = UIColor(white: 0, alpha: 0.3) // Optional dim effect
        }
        if let topVC = getCurrentViewController() {
            topVC.present(popoverContentVC, animated: true, completion: nil)
        }
    }
    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController?.topMostViewController()
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
//extension SubmissionTVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//        return FilesUrl?.count ?? 0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        let cell = sumisionCollectionView.dequeueReusableCell(
//            withReuseIdentifier: CellConfingName.ImagePdfCvCell,
//            for: indexPath
//        ) as! ImagePdfCvCell
//
//        if let img = FilesUrl?[indexPath.row],
//           let urlString = img.url,
//           let url = URL(string: urlString) {
//
//            let fileType = img.type?.uppercased() ?? ""
//            
//            switch fileType {
//            case "IMAGE":
//                // Show actual image
//                cell.webView.isHidden = true
//                cell.imageView.isHidden = false
//                cell.imageView.sd_setImage(with: url, placeholderImage: ImageName.placeholder)
//                cell.IndicaterImageView.image = UIImage(named: "")
//                cell.hide = false
//                
//            case "VIDEO":
//                // Show video icon
//                cell.webView.isHidden = true
//                cell.imageView.isHidden = false
//                cell.imageView.image = UIImage(named: "video (1)")
//                cell.IndicaterImageView.image = UIImage(named: "video (1)")
//                cell.hide = true
//                
//            default:
//                // PDF / Docs / Unknown
//                cell.hide = false
//                cell.webView.isHidden = false
//                cell.imageView.isHidden = true
//                cell.webView.isUserInteractionEnabled = false
//                cell.webView.scrollView.isScrollEnabled = false
//                let request = URLRequest(url: url)
//                cell.webView.load(request)
//                let iconName = getFileIconName(for: url)
//                cell.IndicaterImageView.image = UIImage(named: iconName)
//            }
//
//        } else {
//            // Fallback if URL is invalid
//            cell.webView.isHidden = true
//            cell.imageView.isHidden = false
//            cell.imageView.image = UIImage(named: "placeholder") // placeholder image
//            cell.IndicaterImageView.image = UIImage(named: "placeholder")
//            cell.hide = false
//        }
//
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 100, height: 100)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("didSelectItemAt")
//        guard let file = FilesUrl?[indexPath.row], let urlString = file.url, let url = URL(string: urlString) else { return }
//        let fileExtension = url.pathExtension.lowercased()
//        
//        let vc = getCurrentViewController()
//            let vcc = ImageShowVc(nibName: nil, bundle: nil)
//            var homeworkDocs = FilesUrl ?? []
//            vcc.fileURL =  homeworkDocs
//            vcc.scrollIndex = indexPath
//            vcc.index = indexPath.row
//            vcc.modalPresentationStyle = .fullScreen
//            vc?.present(vcc, animated: true)
//    }
//   

//}
