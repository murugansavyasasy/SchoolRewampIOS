//
//  AttachmentsVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 28/07/25.
//

import UIKit

extension AttachmentsVc: AttachmentHeaderViewDelegate {
    func didTapSeeMore(in header: AttachmentHeaderCell) {
        isHeaderExpanded.toggle()
        cv.collectionViewLayout.invalidateLayout()
        cv.reloadSections(IndexSet(integer: 0))
    }
}
class AttachmentsVc: UIViewController {
    @IBOutlet weak var cv: UICollectionView!
    var attachmentHeaders: [AttachmentHeaderInfo] = []
    var attachmentFiles: [[FilePath]] = []
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var attachmentData = [Attachment]()
    var filteredAttachments:[Attachment]?
    var SearchAttachments:[Attachment]?
    var isHeaderExpanded: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

//
        cv.register(UINib(nibName: "PreviewCell", bundle: nil), forCellWithReuseIdentifier: "PreviewCell")
        
        cv.register(UINib(nibName: "AttachmentHeaderCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "AttachmentHeaderCell")
        
        
        fetchAttachments()
    }


    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true)
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
            
            guard let self = self else { return }
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self.hideLottieProgressLoader()
                }
                
                switch result {
                case .success(let response):
                    if response.status == true {
//                        self.hideView(ishide: true)
                        self.attachmentData = response.data ?? []
                        self.filteredAttachments = response.data
                        self.SearchAttachments = response.data

                        // Separate headers and file_paths
                        self.attachmentHeaders = []
                        self.attachmentFiles = []

                        for item in self.attachmentData {
                            let header = AttachmentHeaderInfo(
                                title: item.title ?? "",
                                description: item.description ?? "",
                                date: item.date ?? "",
                                time: item.time ?? "",
                                sender_info: item.sender_info ?? ""
                            )
                            self.attachmentHeaders.append(header)
                            self.attachmentFiles.append(item.file_path ?? [])
                        }
                        self.cv.delegate = self
                        self.cv.dataSource = self
                        self.cv.reloadData()
                    } else {
//                        self.hideView(ishide: false)
//                        self.NodataLbl.text = response.message
                    }

                case .failure(_):
                    ""
                }
            }
        }
    }

}

extension AttachmentsVc : UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("attachmentHeaders",attachmentHeaders.count)
        return attachmentHeaders.count
       }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachmentFiles[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data  = attachmentFiles[indexPath.section][indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PreviewCell",
            for: indexPath) as? PreviewCell
        else{
            return UICollectionViewCell()
        }
    
        if data.type == "IMAGE"{
            cell.imageView.isHidden = false
            cell.webview.isHidden = true
            cell.imageView
                .sd_setImage(
                    with: URL(string: data.url ?? ""),
                    placeholderImage: UIImage(named: "placeholder")
                )
        }else  if data.type == "VIDEO" {
            cell.imageView.image = UIImage(named: "video (1)")
        }else{
            let fileURL = URL(fileURLWithPath: data.url ?? "")
            let iconName = getFileIconName(for: fileURL)
            let iconImage = UIImage(named: iconName)
            cell.imageView.image = iconImage
//            cell.imageView.layer.borderColor = UIColor.black.cgColor
//            cell.imageView.layer.borderWidth = 0.5
            
        }
        
       
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = (collectionView.frame.width-20)/3
        return CGSize(width: size, height: size)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "AttachmentHeaderCell",
                    for: indexPath) as! AttachmentHeaderCell

            let headerData = attachmentHeaders[indexPath.section]
            header
                .configure(
                    title:headerData.title ?? "" ,
                    description: headerData.description ?? "", isExpanded: isHeaderExpanded,
                    date: headerData.date ?? ""
                )

            header.delegate = self
            
                return header
            }
        
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let header = Bundle.main.loadNibNamed("AttachmentHeaderCell", owner: self, options: nil)?.first as? AttachmentHeaderCell else {
            return CGSize(width: collectionView.frame.width, height: 100)
        }
        let headerData = attachmentHeaders[section]
    
        header.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 1000) // Arbitrary height for fitting
        header
            .configure(
                title: headerData.title ?? "",
                description: headerData.description ?? "",
                isExpanded: isHeaderExpanded,
                date: headerData.date ?? ""
            )

        header.layoutIfNeeded()
        let targetSize = CGSize(width: collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height)
        let size = header.systemLayoutSizeFitting(targetSize,
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
        
        print("sizesizesize",size)
        return size
    }




    
}
struct AttachmentHeaderInfo {
    let title: String?
    let description: String?
    let date: String?
    let time: String?
    let sender_info: String?
}
