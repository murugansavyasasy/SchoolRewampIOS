//
//  AttachmentVCViewController.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 05/05/25.
//

import UIKit

class AttachmentVCViewController: UIViewController {

    private enum Constants {
        static let imageCellID = "AttachmentCvCollectionViewCell"
        static let bannerID = "BannerView"
        static let mockLabels = [
            "This is a nice house, but it must be expensive",
            "Wow, very nice design. It must have been hard to build this.dhgfgawifgiuawgifgauwgfuguygugiugwrfgisagfiugaisugfiugiugugiugiufgiagiffgaiugfgafgagsfgyuagygyugugauguagfuasuguaufauug vekjbvjefbvjhsbjghjesfbvjjv hjjhvhjvdjvjsjhvhjahjejvbajvhjbvdhjbvjbbjscbj wjbvjfjvjfvjbjabjbaebvjhhvjvbjhvbjbv jebejb jebjvbjabvjbs jv ",
            "I want to live in this, but I can't afford a flat.",
            "This looks stupid",
            "This one is also very modern looking.",
            "What a great design",
        ]
    }
    
  

    @IBOutlet weak var collectionView: UICollectionView!
 
    @IBOutlet weak var pinterestLayout: PinterestLayout!
   

    @IBOutlet weak var titleLabel: UILabel!
    
    var houseImages: [UIImage?] = []
    var houseLabels: [String] = []
    var attachmentData:[Attachment]?
    var filteredAttachments:[Attachment]?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var currentlyPlayingCell: AttachmentCvCollectionViewCell?
    private var currentlyPlayingIndexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        setupCollectionView()
//        fetchAttachments()
        
       

        // Sample Data Array
        let attachments: [Attachment] = [
            Attachment(
                id: "101",
                type: "DOCUMENT",
                title: "Monthly Report",
                description: "Detailed report for April",
                date: "2025-04-30",
                time: "09:00 AM",
                sender_info: "Accounts Dept",
                is_unread: true,
                is_archive: false,
                file_path: [
                    FilePath(path: "https://www.antennahouse.com/hubfs/xsl-fo-sample/pdf/basic-link-1.pdf", type: "DOCUMENT")
                ],
                iframe: "<iframe src='https://example.com/viewer?file=april_report.pdf'></iframe>"
            ),
            
            Attachment(
                id: "102",
                type: "IMAGE",
                title: "Event Poster",
                description: "Poster for upcoming science fair",
                date: "2025-05-01",
                time: "03:45 PM",
                sender_info: "School Admin",
                is_unread: false,
                is_archive: false,
                file_path: [
                    FilePath(path: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//2A451347-56EB-49B1-84E7-DBD25BBDF39B.jpg", type: "IMAGE")
                ],
                iframe: nil
            ),
            
            Attachment(
                id: "103",
                type: "VIDEO",
                title: "Assembly Highlights",
                description: "Highlights from the morning assembly",
                date: "2025-05-02",
                time: "08:30 AM",
                sender_info: "Media Team",
                is_unread: true,
                is_archive: true,
                file_path: [
                    FilePath(path: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", type: "VIDEO")
                ],
                iframe: ""
            ),
            
            Attachment(
                id: "103",
                type: "VIDEO",
                title: "Assembly Highlightsssssss",
                description: "Highlights from the morning assemblyssssssss",
                date: "2025-05-02",
                time: "08:30 AM",
                sender_info: "Media Team",
                is_unread: true,
                is_archive: true,
                file_path: [
                    FilePath(path: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", type: "VIDEO")
                ],
                iframe: ""
            )
            
        ]
        filteredAttachments = attachments
    
       collectionView.delegate = self
       collectionView.dataSource = self
       collectionView.reloadData()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func setupCollectionView() {
            if let layout = collectionView.collectionViewLayout as? PinterestLayout {
                layout.delegate = self
            }

            collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "AttachmentCvCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"AttachmentCvCollectionViewCell")
        }
}


extension AttachmentVCViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let attachment = filteredAttachments?[indexPath.item] else { return 0 }
        let width = (collectionView.bounds.width / 2) - 16

        let titleFont = UIFont.boldSystemFont(ofSize: 14)
        let descFont = UIFont.systemFont(ofSize: 12)

        let titleHeight = attachment.title?.heights(withConstrainedWidth: width, font: titleFont) ?? 0
        let descHeight = attachment.description?.heights(withConstrainedWidth: width, font: descFont) ?? 0
        let dateAndtime = attachment.date?.heights(
            withConstrainedWidth: width,
            font: descFont
        ) ?? 0
        
        
        let spacing: CGFloat = 8 + 8 + 8

        switch attachment.file_path?.first?.type {
        case "IMAGE":
            if let urlString = attachment.file_path?.first?.path{
              
                return dateAndtime + 20 + titleHeight + descHeight + 270 + spacing
            } else {
                return titleHeight + descHeight + 200 + spacing
            }

        case "VIDEO":
            return  dateAndtime + 20 + titleHeight + descHeight + 270 + spacing
        case "DOCUMENT":
            return   dateAndtime + 20 + 300 + spacing
        default:
            return titleHeight + descHeight + 80 + spacing
        }
    }

}

extension AttachmentVCViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        
//        if let videoCell = cell as? AttachmentCvCollectionViewCell {
//            videoCell.player?.pause()
//            videoCell.playerLayer?.removeFromSuperlayer()
//            if currentlyPlayingIndexPath == indexPath {
//                currentlyPlayingIndexPath = nil
//            }
//        }
//    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return filteredAttachments?.count ?? 0
        return filteredAttachments?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if indexPath.row == (filteredAttachments?.count ?? 0) {
               // SEE ALL cell
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "seeMore", for: indexPath) as! seeMore
               cell.seeAllButton.setTitle("See All", for: .normal)
               cell.seeAllButton.addTarget(self, action: #selector(seeAllTapped), for: .touchUpInside)
               return cell
           }
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.imageCellID, for: indexPath) as! AttachmentCvCollectionViewCell
        guard let data = filteredAttachments?[indexPath.row] else {
            return UICollectionViewCell()
        }

        cell.TitleLbl.text = data.title
        cell.timeAndDate.text = (data.date ?? "") + " - " + (data.time ?? "")
        cell.sentBy.text = data.sender_info
        cell.discreptionLbl.text = data.description

        switch data.file_path?.first?.type {
        case "IMAGE":
            cell.imageView.isHidden = false
            cell.webOuterView.isHidden = true
            cell.webview.isHidden = true
            cell.imageView.sd_setImage(with: URL(string: data.file_path?.first?.path ?? ""), placeholderImage: ImageName.placeholder)

        case "VIDEO":
            cell.imageView.isHidden = true
            cell.webOuterView.isHidden = false
            cell.webview.isHidden = true
            cell.sentBy.isHidden = true
    
//            cell.webOuterView.contentMode = .scaleAspectFill
            cell.webOuterView.clipsToBounds = true
            cell.webOuterView.layer.cornerRadius = 10
            
            if let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
                  cell.configureVideo(with: url)
              }
            
            
            cell.onPlayPressed = { [weak self] tappedCell in
                // Pause any previously playing cell
                if let current = self?.currentlyPlayingCell, current != tappedCell {
                    current.pauseIfNeeded()
                }

                // Set current playing cell
                self?.currentlyPlayingCell = tappedCell
            }
            
        case "DOCUMENT":
            cell.imageView.isHidden = true
            cell.webOuterView.isHidden = false
            cell.webview.isHidden = false
            if let docUrl = data.file_path?.first?.path, let url = URL(string: docUrl) {
                cell.webview.load(URLRequest(url: url))
            }
            cell.sentBy.isHidden = true

        default:
            cell.imageView.isHidden = true
            cell.webOuterView.isHidden = true
        }

        return cell
    }

    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        
        let vc = AttachmentViewer(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
        
    }
    
    @objc func seeAllTapped() {
        print("See All Clicked")
    }
    
    private func fetchAttachments() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_communication_attachment_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token:studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<AttachmentsResponse, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self?.hideLottieProgressLoader()
                }
                
                switch result {
                case .success(let response):
                    if response.status == true {
                        self?.attachmentData = response.data
                        self?.filteredAttachments = response.data
                        self?.collectionView.delegate = self
                        self?.collectionView.dataSource = self
                        self?.collectionView.reloadData()
                    }else{
                        
                        self?.attachmentData = response.data
                        self?.filteredAttachments = response.data
                        self?.collectionView.delegate = self
                        self?.collectionView.dataSource = self
                        self?.collectionView.reloadData()
                    }
                   
                   
                case .failure(let error):
                    print("Error fetching attachments:", error.localizedDescription)
                }
            }
        }
    }
     
   

    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y + scrollView.contentInset.top
//        
//        let dy = offsetY > 0 ? -offsetY : 0
////        titleLabel.transform = CGAffineTransform(translationX: 0, y: dy)
//    }
    
    
    
}



extension String {
    func heights(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
        return ceil(boundingBox.height)
    }
}
