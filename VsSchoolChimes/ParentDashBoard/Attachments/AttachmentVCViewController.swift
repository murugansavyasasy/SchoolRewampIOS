//
//  AttachmentVCViewController.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 05/05/25.
//

import UIKit

class AttachmentVCViewController: UIViewController {

    private enum Constants {
        static let imageCellID = "ImageCell"
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
    
    var numberOfCells = 100

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
        setupViews()
        
        fetchAttachments()
    }
    
//    private func loadData() {
//        houseImages = (0..<numberOfCells).map { return UIImage(named: "house\($0 % 10)") }
//        houseLabels = (0..<numberOfCells).map {
//            return Constants.mockLabels[$0 % Constants.mockLabels.count]
//        }
//    }
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func setupViews() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsets(top: 115, left: 6, bottom: 0, right: 6)
        
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: Constants.imageCellID)
        
        
        collectionView.register(BannerView.self, forSupplementaryViewOfKind: PinterestLayout.elementKindBanner, withReuseIdentifier: Constants.bannerID)
        
        pinterestLayout.delegate = self
        pinterestLayout.numberOfColumns = 2
        pinterestLayout.cellPadding = 6
        
    }
}


extension AttachmentVCViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout, heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let attachment = filteredAttachments?[indexPath.item],
              let urlString = attachment.file_path?.first?.path,
              let url = URL(string: urlString),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return 200 // Default/fallback height
        }

        let width = image.size.width
        let height = image.size.height
        guard width > 0 else { return 200 }

        let scaledImageHeight = (height * layout.cellWidth) / width
        let padding = ImageCell.Constants.padding

        let titleText = attachment.title ?? ""
        let descriptionText = attachment.description ?? ""
        let dateText = attachment.date ?? ""
        let timeText = attachment.time ?? ""
        let senderText = attachment.sender_info ?? ""

        let titleHeight = titleText.heightFitting(width: layout.cellWidth, font: ImageCell.Constants.font)
        let descriptionHeight = descriptionText.heightFitting(width: layout.cellWidth, font: ImageCell.Constants.font)
        let dateHeight = dateText.heightFitting(width: layout.cellWidth, font: ImageCell.Constants.font)
        let timeHeight = timeText.heightFitting(width: layout.cellWidth, font: ImageCell.Constants.font)
        let senderInfoHeight = senderText.heightFitting(width: layout.cellWidth, font: ImageCell.Constants.font)

        let totalTextHeight = titleHeight + descriptionHeight + dateHeight + timeHeight + senderInfoHeight
        let totalPadding = padding * 5

        return scaledImageHeight + totalTextHeight + totalPadding
    }



    func collectionView(_ collectionView: UICollectionView, layout: PinterestLayout, heightForBannerAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func numberOfItemsBeforeAds(in collectionView: UICollectionView) -> Int {
        return 10
    }
    

}

extension AttachmentVCViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("numberOfCellsnumberOfCells",numberOfCells)
        return filteredAttachments?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.imageCellID, for: indexPath)
        let cell = dequeuedCell as? ImageCell ?? ImageCell()
//        cell.imageView.image = houseImages[indexPath.item]
//        cell.titleLbl.text = houseLabels[indexPath.item]
//        cell.descriptionLbl.text = "saran"
//        cell.dateLbl.text = "13/10/2000"
//        cell.timeLbl.text = "10:30 Am"
//        cell.senderInfoLbl.text = "saran"
        
        guard let data = filteredAttachments?[indexPath.row] else {
            return UICollectionViewCell() // Safely return a default cell if data is nil
        }
        
        switch data.type?.uppercased() {
        case "VIDEO":
//            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.VideoTVCell, for: indexPath) as! VideoTVCell
//            cell.descriptionLbl.text = data.description
//            cell.datelbl.text = data.date
//            cell.videoName.text = data.title
            
           ""

        case "DOCUMENT":
           ""

        default:
            cell.imageView
                .sd_setImage(
                    with: URL(string: data.file_path?.first?.path ?? ""),
                    placeholderImage: ImageName.placeholder
                )
           
            cell.titleLbl.text = data.title
            cell.descriptionLbl.text = data.description
            cell.dateLbl.text = data.date
            cell.timeLbl.text = data.time
            cell.senderInfoLbl.text = data.sender_info
           
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
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case PinterestLayout.elementKindBanner:
            let dequeuedBanner = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.bannerID, for: indexPath) as? BannerView
            let cell = dequeuedBanner ?? BannerView()
            cell.imageView.image = UIImage(named: "sale-banner-templates")
            return cell
        default:
            fatalError()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y + scrollView.contentInset.top
        
        let dy = offsetY > 0 ? -offsetY : 0
//        titleLabel.transform = CGAffineTransform(translationX: 0, y: dy)
    }
    
}

extension String {
    func heightFitting(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        return boundingBox.height
    }
}
