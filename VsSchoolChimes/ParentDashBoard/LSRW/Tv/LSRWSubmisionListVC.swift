//
//  LSRWSubmisionListVC.swift
//  School Chimes
//
//  Created by Chandhru on 19/08/25.
//

import UIKit

enum AttachmentSection {
    case videos([FilePath])
    case audios([FilePath])
    case images([FilePath])
}

@available(iOS 15.0, *)
class LSRWSubmisionListVC: UIViewController,
                           UICollectionViewDelegate,
                           UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var remarkView: UIView!
    @IBOutlet weak var slider: CustomSlider!
    @IBOutlet weak var percentageLbl: UILabel!
    @IBOutlet weak var lsrwCV: UICollectionView!
    @IBOutlet weak var backBtn: UIButton!
    var attachment: [FilePath]?
    var filterSection: [AttachmentSection] = []
    var id :String?
    var student_id :String?
    var backTitle1:String?
    var backTitle2:String?
    var titleSting:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        lsrwCV.delegate = self
        lsrwCV.dataSource = self
        slider.transform = CGAffineTransform(scaleX: 1, y: 1.5)
        if let st_id = student_id{
            remarkView.isHidden = false
            backBtn.configureAsBackButton(firstLine: backTitle1 ?? "", secondLine:backTitle2 ?? "")
        }else{
            remarkView.isHidden = true
            backBtn.setTitle("My Submission", for: .normal)
        }
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
        
        prepareAttachments()
        lsrwCV.reloadData()
        
        // Slider setup
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50
        updateSliderUI(for: Int(slider.value))
    }
    
    private func prepareAttachments() {
        filterSection.removeAll()
        
        let videos = attachment?.filter { $0.type?.lowercased() == "video" } ?? []
        if !videos.isEmpty { filterSection.append(.videos(videos)) }
        
        let audios = attachment?.filter { $0.type?.lowercased() == "audio" } ?? []
        if !audios.isEmpty { filterSection.append(.audios(audios)) }
        
        let images = attachment?.filter { ["image", "pdf"].contains($0.type?.lowercased() ?? "") } ?? []
        if !images.isEmpty { filterSection.append(.images(images)) }
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func updateRemark(_ sender: UIButton) {
        let parms:[String:Any] = ["id":id ?? "","student_id":student_id ?? "","percentage":percentageLbl.text ?? ""]
        remoarkLSRW(with: parms)
    }
    func remoarkLSRW(with parameters: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            APIService.shared.makeApi(
                url: ServiceUrl.lms_api_lsrw_remark,
                parameters: parameters,
                type: ApitTypeSringFile.PUT,
                token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
            ) { [weak self] (result: Result<Send_AttachmentResponse, Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        CustomAlert.showAlertWithOkAction(
                            title: response.status ? AlertstringFile.Success : AlertstringFile.Alert_title,
                            message: response.message,
                            on: self
                        ) {
                            self.dismiss(animated: true)
                        }
                    }
                case .failure(let error):
                    print("❌ API error: \(error.localizedDescription)")
                    // Optionally show error alert here
                }
            }
        }
    }
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
        return filterSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch filterSection[section] {
        case .videos(let list): return list.count
        case .audios(let list): return list.count
        case .images(let list): return list.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch filterSection[indexPath.section] {
        case .videos(let list):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.VideoPlayerCVC,
                for: indexPath) as? VideoPlayerCVC else { return UICollectionViewCell() }
            let file = list[indexPath.row]
            if let url = URL(string:file.url ?? "") { cell.configure(with:url, parentVC: self) }
            return cell
            
        case .audios(let list):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "AudioCVC",
                for: indexPath) as? AudioCVC else { return UICollectionViewCell() }
            let file = list[indexPath.row]
//            cell.configure(with: file)
            return cell
            
        case .images(let list):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.ImagePdfCvCell,
                for: indexPath) as? ImagePdfCvCell else { return UICollectionViewCell() }
            let file = list[indexPath.row]
            cell.imageView.kf.setImage(with: URL(string:file.url ?? ""))
            return cell
        }
    }
    
    // MARK: - Header View
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "SectionHeader",
            for: indexPath
        )
        header.subviews.forEach { $0.removeFromSuperview() }

        // Show description and title ONLY for the first section
        guard indexPath.section == 0 else { return header }

        var yOffset: CGFloat = 0

        // Description label
        if let text = titleSting, !text.isEmpty {
            let descriptionLabel = UILabel()
            descriptionLabel.font = UIFont.systemFont(ofSize: 14)
            descriptionLabel.textColor = .darkGray
            descriptionLabel.numberOfLines = 0
            descriptionLabel.lineBreakMode = .byWordWrapping
            descriptionLabel.text = text

            let maxWidth = collectionView.frame.width - 32
            let descriptionSize = descriptionLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
            descriptionLabel.frame = CGRect(x: 16, y: yOffset, width: maxWidth, height: descriptionSize.height)
            header.addSubview(descriptionLabel)

            yOffset += descriptionSize.height + 8
        }

        // Title label
        let titleLabel = UILabel(frame: CGRect(x: 16, y: yOffset,
                                               width: collectionView.frame.width - 32,
                                               height: 30))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.text = "🖼 Files"
        header.addSubview(titleLabel)

        return header
    }

    // MARK: - Dynamic Header Height
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        // Only show header for the first section
        guard section == 0 else {
            return .zero
        }

        var height: CGFloat = 30 // for title label

        if let text = titleSting, !text.isEmpty {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.text = text

            let maxWidth = collectionView.frame.width - 32
            let size = label.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
            height += size.height + 8
        }

        return CGSize(width: collectionView.frame.width, height: height)
    }



    
    // MARK: - FlowLayout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let spacing: CGFloat = 8
        let totalSpacing = spacing * 3
        let cellWidth = (width - totalSpacing) / 2
        
        switch filterSection[indexPath.section] {
        case .videos: return CGSize(width: cellWidth, height: cellWidth)
        case .audios: return CGSize(width: collectionView.frame.width - 20, height: 60)
        case .images: return CGSize(width: cellWidth, height: cellWidth)
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch filterSection[indexPath.section] {
        case .videos(let videos):
            guard indexPath.item < videos.count else { return }
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.fileURL = videos
            imageVC.subjectName = "Videos"
            imageVC.index = indexPath.item
            imageVC.scrollIndex = indexPath
            imageVC.modalPresentationStyle = .fullScreen
            present(imageVC, animated: true)
            
        case .images(let images):
            guard indexPath.item < images.count else { return }
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.fileURL = images
            imageVC.subjectName = "Images & Docs"
            imageVC.index = indexPath.item
            imageVC.scrollIndex = indexPath
            imageVC.modalPresentationStyle = .fullScreen
            present(imageVC, animated: true)
            
        default:
            break
        }
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
