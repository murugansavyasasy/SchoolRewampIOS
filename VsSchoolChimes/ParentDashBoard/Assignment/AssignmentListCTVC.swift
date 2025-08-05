//
//  AssignmentListCTVC.swift
//  VsSchoolChimes
//
//  Created by admin on 21/11/24.
//

import UIKit
import AVKit
protocol SumitionDelegate{
    func sumition(index:Int)
}
class AssignmentListCTVC: UITableViewCell, AVPlayerViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var attachmentCVHeight: NSLayoutConstraint!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var viewSumitionBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var SubjectLabel: UILabel!
    @IBOutlet weak var SendBySecLbl: UILabel!
    @IBOutlet weak var SubCountSec: UILabel!
    @IBOutlet weak var DueSecLbl: UILabel!
    @IBOutlet weak var CategorySecLbl: UILabel!
    @IBOutlet weak var imgHeght: NSLayoutConstraint!
    @IBOutlet weak var spirelview: UIView!
    @IBOutlet weak var outImg: UIImageView!
    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var sendByLbl: UILabel!
    @IBOutlet weak var sumissionLbl: UILabel!
    @IBOutlet weak var dueDateLbl: UILabel!
    @IBOutlet weak var CreaterdDate: UILabel!
    @IBOutlet weak var NotSubmitedBtn: UIButton!
    @IBOutlet weak var ForwardBtn: UIButton!
    @IBOutlet weak var AttachmentCV: UICollectionView!
    @IBOutlet weak var cvBaseview: UIView!
    @IBOutlet weak var leftLbl: UILabel!
    @IBOutlet weak var PageController: UIPageControl!
    
    var didSelectDelegate : DidSelectDelegate?
    var Delegate : SumitionDelegate?
    var FilesUrl : [FilePath]?
    var videoUrl :String?
    var player: AVPlayer?
    var iframe:String?
    var staff = false{
        didSet{
            if staff {
                viewSumitionBtn.isHidden = true
                NotSubmitedBtn.isHidden = false
                deleteBtn.isHidden = false
                leftLbl.isHidden = true
            }else{
                submitBtn.isHidden = false
                NotSubmitedBtn.isHidden = true
                deleteBtn.isHidden = true
                leftLbl.isHidden = false
            }
        }
    }
    var id:String?
    var submitcount:Int?
    var unsubmitcount:Int?
    var assignmentId:String?
       override func awakeFromNib() {
           super.awakeFromNib()
           let collection = UINib(nibName:CellConfingName.ImagePdfCvCell, bundle: nil)
           AttachmentCV.register(collection, forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
           
           AttachmentCV.delegate = self
           AttachmentCV.dataSource = self

           spirelview.layer.cornerRadius = 10
           spirelview.layer.shadowColor = UIColor.black.cgColor
           spirelview.layer.shadowOffset = CGSize(width: 4, height: 4)
           spirelview.layer.shadowRadius = 3
           spirelview.layer.shadowOpacity = 0.5
           spirelview.layer.masksToBounds = false
           outImg.translatesAutoresizingMaskIntoConstraints = false
           NotSubmitedBtn.layer.cornerRadius = 10
           deleteBtn.layer.cornerRadius = 4
           submitBtn.layer.cornerRadius = 10
           viewSumitionBtn.layer.cornerRadius = 10
           ForwardBtn.layer.cornerRadius = 4
           
           cvBaseview.layer.cornerRadius = 10
           cvBaseview.layer.shadowColor = UIColor.black.cgColor
           cvBaseview.layer.shadowOffset = CGSize(width: 0, height: 2)
           cvBaseview.layer.shadowRadius = 5
           cvBaseview.layer.shadowOpacity = 0.3
           cvBaseview.layer.masksToBounds = false
           AttachmentCV.layer.masksToBounds = true
           AttachmentCV.layer.cornerRadius = 10
           
           //MARK: Label Font
           SendBySecLbl.setFont(style: .body, size: FontSize.BodySize)
           SubCountSec.setFont(style: .body, size: FontSize.BodySize)
           DueSecLbl.setFont(style: .body, size: FontSize.BodySize)
           CategorySecLbl.setFont(style: .body, size: FontSize.BodySize)
           SubjectLabel.setFont(style: .title, size: FontSize.TitleSize)
           DescriptionLbl.setFont(style: .body, size: FontSize.BodySize)

           
           tittleLbl.setFont(style: .title, size: FontSize.TitleSize)
           categoryLbl.setFont(style: .body, size: FontSize.BodySize)
           sendByLbl.setFont(style: .body, size: FontSize.BodySize)
           sumissionLbl.setFont(style: .body, size: FontSize.BodySize)
           dueDateLbl.setFont(style: .body, size: FontSize.BodySize)
           CreaterdDate.setFont(style: .body, size: FontSize.BodySize)

           //MARK: Button Font
           submitBtn.setTitleFont(style: .body, size: FontSize.BodySize)
           NotSubmitedBtn.setTitleFont(style: .body, size: FontSize.BodySize)
           viewSumitionBtn.setTitleFont(style: .body, size: FontSize.BodySize)
           ForwardBtn.setTitleFont(style: .body, size: FontSize.BodySize)
           PageController.numberOfPages = FilesUrl?.count ?? 0
           PageController.currentPage = 0
       }

       override func layoutSubviews() {
           super.layoutSubviews()
           let contentViewHeight = contentView.frame.height - 30
           imgHeght.constant = contentViewHeight
       }
//    func confic(_ files:[FilePath]){
//        FilesUrl = files
//        PageController.numberOfPages = FilesUrl?.count ?? 0
//        PageController.currentPage = 0
//        AttachmentCV.reloadData()
//    }
    
    @IBAction func notSubmited(_ sender: UIButton) {
        if let currentVC = getCurrentViewController() {
            if unsubmitcount != 0 {
                let vcc = SubmitedAssignmentVC(nibName: nil, bundle: nil)
                vcc.type = "NOTSUBMITTED"
                vcc.id = id
                vcc.titleString = tittleLbl.text
                vcc.subject = SubjectLabel.text
                vcc.modalPresentationStyle = .fullScreen
                currentVC.present(vcc, animated: true, completion: nil)
            }
        }
    }
    @IBAction func submit(_ sender: UIButton) {
        if let currentVC = getCurrentViewController() {
            if staff{
                if submitcount != 0{
                    let vcc = SubmitedAssignmentVC(nibName: nil, bundle: nil)
                    vcc.type = "SUBMITTED"
                    vcc.id = id
                    vcc.titleString = tittleLbl.text
                    vcc.subject = SubjectLabel.text
                    vcc.modalPresentationStyle = .fullScreen
                    currentVC.present(vcc, animated: true, completion: nil)
                }
            }else{
                if #available(iOS 14.0, *) {
                    let vcc = SubmitVC(nibName: nil, bundle: nil)
                    vcc.titleName = tittleLbl.text
                    vcc.id = id
                    vcc.modalPresentationStyle = .fullScreen
                    currentVC.present(vcc, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    @IBAction func viewAssignment(_ sender: UIButton) {
        if #available(iOS 14.0, *) {
            if let currentVC = getCurrentViewController() {
                let vcc = AssignmentSummitionVC(nibName: nil, bundle: nil)
                vcc.titleName = tittleLbl.text
                vcc.subject = SubjectLabel.text
                vcc.id = id
                vcc.modalPresentationStyle = .fullScreen
                currentVC.present(vcc, animated: true, completion: nil)
            }
        }
    }
    
}

extension AssignmentListCTVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return FilesUrl?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = AttachmentCV.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImagePdfCvCell, for: indexPath) as! ImagePdfCvCell
        
        if let img = FilesUrl?[indexPath.row] {
            let fileURL = URL(fileURLWithPath: img.url ?? "")
            let iconName = getFileIconName(for: fileURL)
            attachmentCVHeight.constant = 100
            if iconName != "image" {
                if img.type?.uppercased() == "VIDEO"{
                    cell.hide = true
                    attachmentCVHeight.constant = 150
                    if let url = URL(string: img.url ?? "") {
                     let request = URLRequest(url: url)
                        cell.webView.load(request)
                     }
                    cell.webView.isHidden = false
                    cell.imageView.isHidden = true
                    
                    let iconImage = UIImage(named: "")
//                    cell.imageView.image = UIImage(named: "video (1)")
                    cell.IndicaterImageView.image = iconImage
                }else{
                    if let pdfURL = URL(string: img.url ?? ""){
                        cell.hide = false
                        let request = URLRequest(url: pdfURL)
                        cell.webView.load(request)
                        cell.webView.isHidden = false
                        cell.webView.isUserInteractionEnabled = false  // ✅ Add this
                        cell.webView.scrollView.isScrollEnabled = false // ✅ Optional
                        cell.imageView.isHidden = true
                        
                    } else {
                        cell.webView.isHidden = true
                        cell.imageView.isHidden = false
                    }
                    let iconImage = UIImage(named: iconName)
                    cell.IndicaterImageView.image = iconImage
                }
            } else {
                cell.hide = false
                cell.webView.isHidden = true
                cell.imageView.isHidden = false
                cell.imageView.sd_setImage(with: URL(string: img.url ?? ""), placeholderImage: ImageName.placeholder)
                let iconImage = UIImage(named: iconName)
                cell.IndicaterImageView.image = iconImage
            }
            
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let img = FilesUrl?[indexPath.row] {
            if img.type?.uppercased() == "VIDEO" {
                return CGSize(width: collectionView.frame.width, height: 150)
            }
        }
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt")
        guard let file = FilesUrl?[indexPath.row], let urlString = file.url, let url = URL(string: urlString) else { return }
                let fileExtension = url.pathExtension.lowercased()
        
                let vc = getCurrentViewController()
        if file.type?.uppercased() == "VIDEO"{
//            playVimeoVideo(from: file.url ?? "")
            let vcc = VideoPreviewVc(nibName: nil, bundle: nil)
            vcc.url = file.url
            vcc.titles = tittleLbl.text
            vcc.modalPresentationStyle = .fullScreen
            vc?.present(vcc, animated: true)
            
        }else{
            let vcc = ImageShowVc(nibName: nil, bundle: nil)
            vcc.imageURL = FilesUrl?.filter({ img in
                img.type?.uppercased() == CommonStringFile.IMAGE
            }) ?? []
            vcc.fileURL =  FilesUrl ?? []
            vcc.pdfUrl = FilesUrl?[indexPath.row].url
            vcc.scrollIndex = indexPath
//            vcc.type = FilesUrl?[indexPath.row].type?.uppercased() != CommonStringFile.IMAGE ? 0 : 2
            vcc.index = indexPath.row
            vcc.modalPresentationStyle = .fullScreen
            vc?.present(vcc, animated: true)
        }
    }
    func playVimeoVideo(from url: String) {
        if let videoID = extractVimeoID(from: url) {
            let vc = getCurrentViewController()
            fetchVimeoVideoFiles(videoID: videoID, accessToken: YOUR_VIMEO_TOKEN) { urls in
                if let firstURLString = urls.first,
                   let videoURL = URL(string: firstURLString) {
                    
                    DispatchQueue.main.async {
                        let player = AVPlayer(url: videoURL)
                        self.player = player
                        
                        let playerViewController = AVPlayerViewController()
                        playerViewController.player = player
                        playerViewController.delegate = self
                        playerViewController.presentationController?.delegate = self
                        
                        vc?.present(playerViewController, animated: true) {
                            player.play()
                        }
                    }
                } else {
                    print("No video URLs found or error")
                }
            }
        } else {
            print("Invalid Vimeo URL")
        }
    }
    
    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController?.topMostViewController()
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let maxVisibleIndex = collectionView.indexPathsForVisibleItems.map({ $0.item }).max() {
            PageController.currentPage = maxVisibleIndex
        }
    }
}
