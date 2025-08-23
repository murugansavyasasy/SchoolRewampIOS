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
    
    @IBOutlet weak var slider: CustomSlider!
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var lsrwCV: UICollectionView!
    
    var attachment: [FilePath]?
    var videos: [FilePath] = []
    var audios: [FilePath] = []
    var images: [FilePath] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lsrwCV.delegate = self
        lsrwCV.dataSource = self
        slider.transform = CGAffineTransform(scaleX: 1, y: 1.5)
        
        // Cell register
        lsrwCV.register(UINib(nibName: CellConfingName.VideoPlayerCVC, bundle: nil),
                        forCellWithReuseIdentifier: CellConfingName.VideoPlayerCVC)
        lsrwCV.register(UINib(nibName: "AudioCVC", bundle: nil),
                        forCellWithReuseIdentifier: "AudioCVC")
        lsrwCV.register(UINib(nibName: CellConfingName.ImagePdfCvCell, bundle:nil),
                        forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
        
        // Header register
        lsrwCV.register(UICollectionReusableView.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: "SectionHeader")
        
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
        
        // Slider setup
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50
        updateSliderUI(for: Int(slider.value))
    }
    
    private func prepareAttachments() {
        videos = attachment?.filter { $0.type?.lowercased() == "video" } ?? []
        audios = attachment?.filter { $0.type?.lowercased() == "audio" } ?? []
        images = attachment?.filter { ["image", "pdf"].contains($0.type?.lowercased() ?? "") } ?? []
    }

    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func updateRemark(_ sender: UIButton) {}
    
    // MARK: - Slider Action
    @IBAction func sliderChanged(_ sender: UISlider) {
        let percentage = Int(sender.value)
        updateSliderUI(for: percentage)
    }
    
    private func updateSliderUI(for percentage: Int) {
        percentageLbl.text = "\(percentage)%"
        
        let emoji: String
        switch percentage {
        case 0..<25: emoji = "😞"
        case 25..<50: emoji = "😐"
        case 50..<75: emoji = "🙂"
        case 75...100: emoji = "🤩"
        default: emoji = "❓"
        }
        
        if let image = emojiToImage(emoji: emoji, size: CGSize(width: 40, height: 40)) {
            slider.setThumbImage(image, for: .normal)
        }
    }
    
    // ✅ Fixed emoji scaling
    private func emojiToImage(emoji: String, size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let fontSize = min(size.width, size.height) * 0.8
            let font = UIFont.systemFont(ofSize: fontSize)
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .paragraphStyle: paragraph
            ]
            
            let attributedString = NSAttributedString(string: emoji, attributes: attributes)
            let textSize = attributedString.size()
            
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            attributedString.draw(in: rect)
        }
    }
    
    // MARK: - CollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        case 0:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.VideoPlayerCVC,
                for: indexPath) as? VideoPlayerCVC else { return UICollectionViewCell() }
            let file = videos[indexPath.row]
            if let url = URL(string:file.url ?? "") { cell.configure(with:url, parentVC: self) }
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "AudioCVC",
                for: indexPath) as? AudioCVC else { return UICollectionViewCell() }
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.ImagePdfCvCell,
                for: indexPath) as? ImagePdfCvCell else { return UICollectionViewCell() }
            let file = images[indexPath.row]
            cell.imageView.kf.setImage(with: URL(string:file.url ?? ""))
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    // MARK: - Section Headers (Titles only)
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "SectionHeader",
                for: indexPath
            )
            
            // clear old subviews
            header.subviews.forEach { $0.removeFromSuperview() }
            
            let titleLabel = UILabel(frame: CGRect(x: 16, y: 0,
                                                   width: collectionView.frame.width - 32,
                                                   height: 30))
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            titleLabel.textColor = .black
            
            switch indexPath.section {
            case 0: titleLabel.text = "📹 Videos"
            case 1: titleLabel.text = "🎵 Audios"
            case 2: titleLabel.text = "🖼 Images & Docs"
            default: titleLabel.text = ""
            }
            
            header.addSubview(titleLabel)
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
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
        case 0: return CGSize(width: cellWidth, height: cellWidth)
        case 1: return CGSize(width: collectionView.frame.width - 20, height: 60)
        case 2: return CGSize(width: cellWidth, height: cellWidth)
        default: return CGSize(width: cellWidth, height: cellWidth)
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

class CustomSlider: UISlider {
    var trackHeight: CGFloat = 6
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        rect.size.height = trackHeight
        return rect
    }
}
