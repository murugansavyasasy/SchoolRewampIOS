//
//  ContentCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 31/07/25.
//

import UIKit

class ContentCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var sendByLbl: UILabel!
    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    
    @IBOutlet weak var cv: UICollectionView!
    var attachmentFiles: [FilePath]?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cv.register(UINib(nibName: "PreviewCell", bundle: nil), forCellWithReuseIdentifier: "PreviewCell")
        cv.delegate = self
        cv.dataSource = self
    }
    
    
    func configure(with files: [FilePath]?,sendBy:String) {
        sendByLbl.text = sendBy
           self.attachmentFiles = files
        cv.isScrollEnabled = false
           cv.reloadData()
           layoutIfNeeded()
           updateCollectionViewHeight()
       }

       func updateCollectionViewHeight() {
           cv.layoutIfNeeded()
           let height = cv.collectionViewLayout.collectionViewContentSize.height
           cvHeight.constant = height
       }
    
   

       func collectionContentHeight() -> CGFloat {
           cv.layoutIfNeeded()
           return cv.collectionViewLayout.collectionViewContentSize.height
       }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachmentFiles?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data  = attachmentFiles?[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PreviewCell",
            for: indexPath) as? PreviewCell
        else{
            return UICollectionViewCell()
        }
      
    
        if data?.type == "IMAGE"{
            cell.imageView.isHidden = false
            cell.webview.isHidden = true
            cell.imageView
                .sd_setImage(
                    with: URL(string: data?.url ?? ""),
                    placeholderImage: UIImage(named: "placeholder")
                )
        }else  if data?.type == "VIDEO" {
            cell.imageView.image = UIImage(named: "video (1)")
        }else{
            let fileURL = URL(fileURLWithPath: data?.url ?? "")
            let iconName = getFileIconName(for: fileURL)
            let iconImage = UIImage(named: iconName)
            cell.imageView.image = iconImage
//            cell.imageView.layer.borderColor = UIColor.black.cgColor
//            cell.imageView.layer.borderWidth = 0.5
            
        }
        
       
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let file = attachmentFiles?[indexPath.row],
              let urlString = file.url,
             let url = URL(string: urlString) else { return }
        
        let fileType = file.type?.uppercased()
        
        if fileType == CommonStringFile.VIDEO {
            
            playVideo(for: file.url ?? "")
        }else{
            
            let isImage = fileType == CommonStringFile.IMAGE
            
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            let homeworkDocs = attachmentFiles ?? []
            imageVC.fileURL = homeworkDocs
            imageVC.subjectName = "Attachments"
            imageVC.pdfUrl = file.url
            imageVC.scrollIndex = indexPath
            imageVC.index = indexPath.row
//            imageVC.type = isImage ? 2 : 0
            imageVC.modalPresentationStyle = .fullScreen
//            imageVC.FileURL = attachmetList ?? []
            let currentController = getCurrentViewController()
            currentController?.present(imageVC, animated: true)
        }
    }
    
    func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
    }
    
    func playVideo(for item: String) {
        let vc = VideoPreviewVc(nibName: nil, bundle: nil)
        vc.url = item
        vc.titles =  "Attachments"
        vc.modalPresentationStyle = .fullScreen
        let currentController = getCurrentViewController()
        currentController?.present(vc, animated: true)
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = (collectionView.frame.width-20)/3
        return CGSize(width: size, height: size)
    }
    
    
}
