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
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchAttachments()
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
        let spacing: CGFloat = 8 + 8 + 8

        switch attachment.type {
        case "IMAGE":
            if let urlString = attachment.file_path?.first?.path,
               let url = URL(string: urlString),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                let ratio = (image.size.height * width) / image.size.width
                return titleHeight + descHeight + ratio + spacing
            } else {
                return titleHeight + descHeight + 200 + spacing
            }

        case "VIDEO":
            return titleHeight + descHeight + 300 + spacing
        case "DOCUMENT":
            return titleHeight + descHeight + 100 + spacing
        default:
            return titleHeight + descHeight + 80 + spacing
        }
    }


    func extractDimensions(from iframe: String) -> (width: String, height: String)? {
        guard let widthMatch = iframe.range(of: #"width=\"(\d+)\""#, options: .regularExpression),
              let heightMatch = iframe.range(of: #"height=\"(\d+)\""#, options: .regularExpression) else {
            return nil
        }

        let width = String(iframe[widthMatch]).replacingOccurrences(of: #"width=""#, with: "").replacingOccurrences(of: "\"", with: "")
        let height = String(iframe[heightMatch]).replacingOccurrences(of: #"height=""#, with: "").replacingOccurrences(of: "\"", with: "")

        print(width,width)
        return (width, height)
    }
    

}

extension AttachmentVCViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredAttachments?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.imageCellID, for: indexPath) as! AttachmentCvCollectionViewCell
        guard let data = filteredAttachments?[indexPath.row] else {
            return UICollectionViewCell()
        }

        cell.TitleLbl.text = data.title
        cell.timeAndDate.text = (data.date ?? "") + " - " + (data.time ?? "")
        cell.sentBy.text = data.sender_info
        cell.discreptionLbl.text = data.description

        switch data.type {
        case "IMAGE":
            cell.imageView.isHidden = false
            cell.webview.isHidden = true
            cell.imageView.sd_setImage(with: URL(string: data.file_path?.first?.path ?? ""), placeholderImage: ImageName.placeholder)

        case "VIDEO":
            cell.imageView.isHidden = true
            cell.webview.isHidden = false
            if let iframe = data.iframe {
                cell.loadVimeoVideo(iframe: iframe)
            }

        case "DOCUMENT":
            cell.imageView.isHidden = true
            cell.webview.isHidden = false
            if let docUrl = data.file_path?.first?.path, let url = URL(string: docUrl) {
                cell.webview.load(URLRequest(url: url))
            }

        default:
            cell.imageView.isHidden = true
            cell.webview.isHidden = true
        }

        return cell
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
                    self?.attachmentData = response.data
                    self?.filteredAttachments = response.data
                    self?.collectionView.delegate = self
                    self?.collectionView.dataSource = self
                    self?.collectionView.reloadData()
                   
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
