//
//  LSRWSubmisionListVC.swift
//  School Chimes
//
//  Created by Chandhru on 19/08/25.
//

import UIKit

@available(iOS 15.0, *)
class LSRWSubmisionListVC: UIViewController,
                           UICollectionViewDelegate,
                           UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var lsrwCV: UICollectionView!
    
    var attachment: [FilePath]?
    var videos: [FilePath] = []
    var audios: [FilePath] = []
    var images: [FilePath] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lsrwCV.delegate = self
        lsrwCV.dataSource = self
        
        lsrwCV.register(UINib(nibName: CellConfingName.VideoPlayerCVC, bundle: nil),
                        forCellWithReuseIdentifier: CellConfingName.VideoPlayerCVC)
        lsrwCV.register(UINib(nibName: "AudioCVC", bundle: nil),
                        forCellWithReuseIdentifier: "AudioCVC")
        lsrwCV.register(UINib(nibName: CellConfingName.ImagePdfCvCell, bundle:nil),
                        forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
        
        // 👉 Dummy data
        attachment = [
            FilePath(url: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/2025-04-04/5512/960x0.jpg", type: "image"),
            FilePath(url: "https://example.com/sample2.pdf", type: "pdf"),
            FilePath(url: "https://player.vimeo.com/video/1097487862?h=57b122eb27", type: "video"),
            FilePath(url: "https://example.com/sample4.mp3", type: "audio"),
            FilePath(url: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//A09E6930-B2B3-441D-94DE-58916BD39CB7.jpg", type: "image"),
            FilePath(url: "https://example.com/sample6.mp3", type: "audio"),
            FilePath(url: "https://player.vimeo.com/video/1097487862?h=57b122eb27", type: "video"),
        ]
        
        prepareAttachments()
        lsrwCV.reloadData()
    }
    
    private func prepareAttachments() {
        videos = attachment?.filter { $0.type?.lowercased() == "video" } ?? []
        audios = attachment?.filter { $0.type?.lowercased() == "audio" } ?? []
        images = attachment?.filter { ["image", "pdf"].contains($0.type?.lowercased() ?? "") } ?? []
    }

    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    // MARK: - CollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3 // video, audio, image/pdf
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return videos.count
        case 1: return audios.count
        case 2: return images.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
            
        case 0: // video
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.VideoPlayerCVC,
                for: indexPath
            ) as? VideoPlayerCVC else {
                return UICollectionViewCell()
            }
            let file = videos[indexPath.row]
            if let url = URL(string:file.url ?? ""){
                cell.configure(with:url, parentVC: self)
            }
            return cell
            
        case 1: // audio
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "AudioCVC",
                for: indexPath
            ) as? AudioCVC else {
                return UICollectionViewCell()
            }
            let file = audios[indexPath.row]
//            cell.configure(with: file)
            return cell
            
        case 2: // image/pdf
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.ImagePdfCvCell,
                for: indexPath
            ) as? ImagePdfCvCell else {
                return UICollectionViewCell()
            }
            let file = images[indexPath.row]
//            cell.configure(with: file)
            cell.imageView.kf.setImage(with: URL(string:file.url ?? ""))
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    
    // MARK: - FlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let spacing: CGFloat = 8
        let totalSpacing = spacing * 3
        let cellWidth = (width - totalSpacing) / 2
        
        switch indexPath.section {
        case 0:
            return CGSize(width: cellWidth, height: cellWidth) // video full width
        case 1:
            return CGSize(width: collectionView.frame.width - 20, height: 60) // audio two per row
        case 2:
            return CGSize(width: cellWidth, height: cellWidth) // image/pdf square grid
        default:
            return CGSize(width: cellWidth, height: cellWidth)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
