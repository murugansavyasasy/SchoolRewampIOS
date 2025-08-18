import UIKit

class LSWTaskTVC: UITableViewCell{

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var attachmentLbl: UILabel!
    @IBOutlet weak var attachmentCollectionView: UICollectionView!
    @IBOutlet weak var attachmentCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var exportRecordBtn: UIButton!
    @IBOutlet weak var reminderBtn: UIButton!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var iconBtn: UIButton!
    @IBOutlet weak var type: UILabel!
    // MARK: - Lifecycle
    // MARK: - Properties
    private var attachmentList: [FilePath] = []
    weak var delegate: AssignmentDetailTVCDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        attachmentCollectionView.delegate = self
        attachmentCollectionView.dataSource = self
        attachmentCollectionView.register(UINib(nibName: "AttachmentCVC", bundle: nil), forCellWithReuseIdentifier: "AttachmentCVC")
        attachmentCollectionView.register(UINib(nibName: "AudioCVC", bundle: nil), forCellWithReuseIdentifier: "AudioCVC")
    }
    // MARK: - Configure
    func configureCell(with assignment: LSRWTask, attachments: [FilePath]) {
        outerView.setShadow()
        titleLbl.text = assignment.title
        type.text = "\(assignment.activity_type)"
        descriptionLbl.text = assignment.description
        // Icon button setup
        let iconConfig = getIconConfiguration(for: assignment.activity_type)
        iconBtn.setTitle(assignment.activity_type.icon, for: .normal)
        iconBtn.backgroundColor = iconConfig.backgroundColor
        iconBtn.setTitleColor(iconConfig.textColor, for: .normal)
        dateBtn.setTitle(formattedDateStatus(from: assignment.created_on ?? ""), for: .normal)
        dateBtn.setImage(UIImage(systemName: "calendar")?.withRenderingMode(.alwaysTemplate), for: .normal)
        reminderBtn.layer.cornerRadius = 8
        exportRecordBtn.layer.cornerRadius = 8
        attachmentList = attachments
        attachmentLbl.text = "𓄲 Attachments (\(attachments.count))"
        reloadCollectionAndUpdateHeight()
    }
    private func getIconConfiguration(for type: LSRWType) -> (backgroundColor: UIColor, textColor: UIColor) {
        switch type {
        case .listening:
            return (.systemBlue.withAlphaComponent(0.2), .systemBlue)
        case .speaking:
            return (.systemGreen.withAlphaComponent(0.2), .systemGreen)
        case .reading:
            return (.systemOrange.withAlphaComponent(0.2), .systemOrange)
        case .writing:
            return (.systemPurple.withAlphaComponent(0.2), .systemPurple)
        }
    }
    // MARK: - Collection View Setup
    private func setupCollectionView() {
        attachmentCollectionView.register(UINib(nibName: "AttachmentCVC", bundle: nil),
                                          forCellWithReuseIdentifier: "AttachmentCVC")
        attachmentCollectionView.delegate = self
        attachmentCollectionView.dataSource = self
    }
    
    private func reloadCollectionAndUpdateHeight() {
        attachmentCollectionView.reloadData()
        attachmentCollectionView.layoutIfNeeded()
        attachmentCollectionHeight.constant = attachmentCollectionView.collectionViewLayout.collectionViewContentSize.height
    }
}
extension LSWTaskTVC:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return attachmentList.count
   }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let file = attachmentList[indexPath.item]
        
        // 🔊 AUDIO CELL
        if file.type?.lowercased() == "audio" {
            if #available(iOS 15.0, *) {
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "AudioCVC",
                    for: indexPath
                ) as? AudioCVC else {
                    return UICollectionViewCell()
                }
                
                if let urlString = file.url, let url = URL(string: urlString) {
                    cell.audioURL = url   // ✅ IMP: assign audio file to cell
                }
                
                return cell
            } else {
                return UICollectionViewCell()
            }
        }
        
        // 📎 ATTACHMENT CELL
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AttachmentCVC",
            for: indexPath
        ) as? AttachmentCVC else {
            return UICollectionViewCell()
        }
        
        // Detect file type
        if let fileType = file.type?.uppercased() {
            switch fileType {
            case CommonStringFile.IMAGE:
                cell.imgIconBtn.setTitle("IMG", for: .normal)
                cell.imgIconBtn.backgroundColor = UIColor.blue.withAlphaComponent(0.15)
            case CommonStringFile.VIDEO:
                cell.imgIconBtn.setTitle("VID", for: .normal)
                if #available(iOS 15.0, *) {
                    cell.imgIconBtn.backgroundColor = UIColor.systemMint.withAlphaComponent(0.15)
                }
            default:
                cell.imgIconBtn.setTitle("DOC", for: .normal)
                cell.imgIconBtn.backgroundColor = UIColor.orange.withAlphaComponent(0.15)
            }
        } else {
            cell.imgIconBtn.setTitle("DOC", for: .normal)
        }
        
        // File name extract
        if let urlString = file.url,
           let path = URL(string: urlString) {
            let fullFileName = path.lastPathComponent
            let fileName = fullFileName.components(separatedBy: "-").last ?? fullFileName
            cell.imageNameLbl.text = fileName
        }
        
        // File size fetch
        if let sizeURL = URL(string: file.url ?? "") {
            getRemoteFileSize(from: sizeURL) { sizeString in
                DispatchQueue.main.async {
                    cell.imageTypeSizeLbl.text = "\(sizeString ?? "").\(file.type ?? "")"
                }
            }
        }
        
        return cell
    }

   func getRemoteFileSize(from url: URL, completion: @escaping (String?) -> Void) {
       var request = URLRequest(url: url)
       request.httpMethod = "HEAD"
       
       URLSession.shared.dataTask(with: request) { _, response, _ in
           if let httpResponse = response as? HTTPURLResponse,
              let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length"),
              let size = Double(contentLength) {
               let sizeInKB = size / 1024.0
               let sizeString: String
               if sizeInKB > 1024 {
                   sizeString = String(format: "%.1f MB", sizeInKB / 1024.0)
               } else {
                   sizeString = String(format: "%.0f KB", sizeInKB)
               }
               completion(sizeString)
           } else {
               completion(nil)
           }
       }.resume()
   }

   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       let file = attachmentList[indexPath.row]
       delegate?.didSelectAttachment( at: indexPath.row, allAttachments: attachmentList, subjectName: titleLbl.text ?? "")
   }
   
   func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
       
       let spacing: CGFloat = 0
       let itemsPerRow: CGFloat = 2
       let totalSpacing = (itemsPerRow - 1) * spacing
       let availableWidth = collectionView.frame.width - totalSpacing
       let itemWidth = floor(availableWidth / itemsPerRow)
       
       return CGSize(width: itemWidth, height: 70)
   }

   func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
       return 0
   }

   func collectionView(_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       minimumLineSpacingForSectionAt section: Int) -> CGFloat {
       return 0
   }

}
