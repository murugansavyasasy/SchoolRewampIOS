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

        var imageHeight: CGFloat = 180
        let spacing: CGFloat = 8 + 8 + 8

        
        guard let attachment = filteredAttachments?[indexPath.item],
         let urlString = attachment.file_path?.first?.path,
         let url = URL(string: urlString),
         let data = try? Data(contentsOf: url),
         let image = UIImage(data: data) else {
         return 200 // Default/fallback height
         }
         
         let widths = image.size.width
         let heights = image.size.height
         guard width > 0 else { return 200 }
        imageHeight = (heights * width) / widths
        return titleHeight + descHeight + imageHeight + spacing
    }

    
//    func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
//     guard let attachment = filteredAttachments?[indexPath.item],
//     let urlString = attachment.file_path?.first?.path,
//     let url = URL(string: urlString),
//     let data = try? Data(contentsOf: url),
//     let image = UIImage(data: data) else {
//     return 200 // Default/fallback height
//     }
//     
//     let width = image.size.width
//     let height = image.size.height
//     guard width > 0 else { return 200 }
//     
//     let scaledImageHeight = (height * layout.cellWidth) / width
//     let padding = ImageCell.Constants.padding
//     
//     let titleText = attachment.title ?? ""
//     let descriptionText = attachment.description ?? ""
//     let dateText = attachment.date ?? ""
//     let timeText = attachment.time ?? ""
//     let senderText = attachment.sender_info ?? ""
//     
//     let titleHeight = titleText.heightFitting(width: layout.cellWidth, font: ImageCell.Constants.font)
//     let descriptionHeight = descriptionText.heightFitting(width: layout.cellWidth, font: ImageCell.Constants.font)
//     let dateHeight = dateText.heightFitting(width: layout.cellWidth, font: ImageCell.Constants.font)
//     let timeHeight = timeText.heightFitting(width: layout.cellWidth, font: ImageCell.Constants.font)
//     let senderInfoHeight = senderText.heightFitting(width: layout.cellWidth, font: ImageCell.Constants.font)
//     
//     let totalTextHeight = titleHeight + descriptionHeight + dateHeight + timeHeight + senderInfoHeight
//     let totalPadding = padding * 5
//     
//     return scaledImageHeight + totalTextHeight + totalPadding
//     }
}

extension AttachmentVCViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredAttachments?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.imageCellID, for: indexPath) as! AttachmentCvCollectionViewCell
       
        guard let data = filteredAttachments?[indexPath.row] else {
         return UICollectionViewCell() // Safely return a default cell if data is nil
         }
        
        cell.imageView
            .sd_setImage(
                with: URL(string: data.file_path?.first?.path ?? ""),
                placeholderImage: ImageName.placeholder
            )
        cell.TitleLbl.text = data.title
        cell.discreptionLbl.text = data.description
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
