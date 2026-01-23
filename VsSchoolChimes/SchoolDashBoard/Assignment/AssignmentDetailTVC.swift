//
//  AssignmentDetailTVC.swift
//  School Chimes
//
//  Created by Chandhru on 08/08/25.
//

import UIKit
import SDWebImage

protocol AssignmentDetailTVCDelegate: AnyObject {
    func didSelectAttachment(at index: Int, allAttachments: [FilePath], subjectName: String)
}

class AssignmentDetailTVC: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var attachmentLbl: UILabel!
    @IBOutlet weak var attachmentCollectionView: UICollectionView!
    @IBOutlet weak var attachmentCollectionHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    private var attachmentList: [FilePath] = []
    weak var delegate: AssignmentDetailTVCDelegate?
    var dateAndTimeForVideo : String = ""
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    // MARK: - Configure
    func configureCell(with assignment: Report, attachments: [FilePath]) {
        titleLbl.text = assignment.title ?? ""
        descriptionLbl.text = assignment.description ?? ""
        dateAndTimeForVideo = (assignment.date ?? "") + " " + (assignment.time ?? "")
        attachmentList = attachments
        attachmentLbl.text = "𓄲 Attachments (\(attachments.count))"
        attachmentLbl.isHidden = attachments.count == 0
        
        reloadCollectionAndUpdateHeight()
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

// MARK: - UICollectionView
extension AssignmentDetailTVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachmentList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AttachmentCVC", for: indexPath) as? AttachmentCVC else {
            return UICollectionViewCell()
        }
        
        let file = attachmentList[indexPath.item]
        
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
        if let urlString = file.url,
           let path = URL(string: urlString) {
            let fullFileName = path.lastPathComponent
            let fileName = fullFileName.components(separatedBy: "-").last ?? fullFileName
            cell.imageNameLbl.text = fileName
        }


        if let sizeURL = URL(string: file.url ?? "") {
            getRemoteFileSize(from: sizeURL) { sizeString in
                DispatchQueue.main.async {
                    cell.imageTypeSizeLbl.text = "\( sizeString ?? "").\(file.type ?? "")"
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
