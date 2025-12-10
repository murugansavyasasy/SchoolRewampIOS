//
//  LSRWSubmisionListVC.swift
//  School Chimes
//
//  Created by Chandhru on 19/08/25.
//

import UIKit

enum AttachmentSection {
    case media([FilePath])
    case audios([FilePath])
}

@available(iOS 15.0, *)
class LSRWSubmisionListVC: UIViewController,
                           UICollectionViewDelegate,
                           UICollectionViewDataSource,
                           UICollectionViewDelegateFlowLayout, AudioPlaybackDelegate {
   
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
        
        if let st_id = student_id {
            remarkView.isHidden = false
            backBtn.configureAsBackButton(firstLine: backTitle1 ?? "",
                                          secondLine: backTitle2 ?? "")
        } else {
            remarkView.isHidden = true
            backBtn.setTitle("My Submission", for: .normal)
        }
        
        lsrwCV.register(UINib(nibName: CellConfingName.VideoPlayerCVC, bundle: nil),
                        forCellWithReuseIdentifier: CellConfingName.VideoPlayerCVC)
        lsrwCV.register(UINib(nibName: "AudioCVC", bundle: nil),
                        forCellWithReuseIdentifier: "AudioCVC")
        lsrwCV.register(UINib(nibName: CellConfingName.ImagePdfCvCell, bundle: nil),
                        forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
        lsrwCV.register(UICollectionReusableView.self,
                        forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: "SectionHeader")
        
        prepareAttachments()
        lsrwCV.reloadData()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50
        updateSliderUI(for: Int(slider.value))
    }
    
    // MARK: - Prepare Sections (MEDIA + AUDIO)
    private func prepareAttachments() {
        filterSection.removeAll()
        
        guard let attachment = attachment else { return }
        let audioExtensions = ["m4a", "mp3", "wav", "aac", "caf", "flac", "ogg","audio"]
        let media = attachment.filter { item in
            guard let type = item.type?.lowercased() else { return false }
            return !audioExtensions.contains { type.contains($0) }
        }
        
        if !media.isEmpty {
            filterSection.append(.media(media))
        }
        let audios = attachment.filter { item in
            guard let type = item.type?.lowercased() else { return false }
            return audioExtensions.contains { type.contains($0) }
        }
        
        if !audios.isEmpty {
            filterSection.append(.audios(audios))
        }
    }
    
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func updateRemark(_ sender: UIButton) {
        let parms: [String: Any] = [
            "id": id ?? "",
            "student_id": student_id ?? "",
            "percentage": percentageLbl.text ?? ""
        ]
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
                }
            }
        }
    }
    // MARK: - Slider
    @IBAction func sliderChanged(_ sender: UISlider) {
        updateSliderUI(for: Int(sender.value))
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
            let rect = CGRect(x: (size.width - textSize.width) / 2,
                              y: (size.height - textSize.height) / 2,
                              width: textSize.width,
                              height: textSize.height)
            attributedString.draw(in: rect)
        }
    }
    // MARK: - Audio Delegate
    func audioCell(_ cell: AudioCVC, willStartPlayingAtIndex index: Int) {
        stopAllOtherAudioCells(except: index)
    }
    
    func audioCell(_ cell: AudioCVC, didStopPlayingAtIndex index: Int) {
        print("🎵 Audio stopped at index \(index)")
    }
    private func stopAllOtherAudioCells(except playingIndex: Int) {
        guard let collectionView = lsrwCV else { return }
        
        for cell in collectionView.visibleCells {
            if let audioCell = cell as? AudioCVC, audioCell.cellIndex != playingIndex {
                audioCell.stopPlayback()
            }
        }
    }
    private func stopAllAudioPlayback() {
        guard let collectionView = lsrwCV else { return }
        
        for cell in collectionView.visibleCells {
            if let audioCell = cell as? AudioCVC {
                audioCell.stopPlayback()
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filterSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        switch filterSection[section] {
        case .media(let list): return list.count
        case .audios(let list): return list.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch filterSection[indexPath.section] {
            
        case .media(let list):
            let file = list[indexPath.row]
            
            if file.type?.lowercased() == "video" {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CellConfingName.VideoPlayerCVC,
                    for: indexPath) as! VideoPlayerCVC
                if let url = URL(string: file.url ?? "") {
                    cell.configure(with: url, parentVC: self)
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CellConfingName.ImagePdfCvCell,
                    for: indexPath) as! ImagePdfCvCell
                if file.type?.uppercased() == CommonStringFile.IMAGE{
                    cell.imageView.isHidden = false
                    cell.webView.isHidden = true
                    
                    if let urlStr = file.url, let url = URL(string: urlStr) {
                        cell.imageView.kf.setImage(with: url)
                    }
                }else{
                    cell.imageView.isHidden = true
                    cell.webView.isHidden = false
                    
                    if let urlStr = file.url, let url = URL(string: urlStr) {
                        
                        var request = URLRequest(url: url)
                        request.cachePolicy = .reloadIgnoringLocalCacheData
                        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
                        request.setValue("no-store", forHTTPHeaderField: "Pragma")
                        request.setValue("no-cache, no-store, must-revalidate", forHTTPHeaderField: "Cache-Control")
                        request.setValue("0", forHTTPHeaderField: "Expires")
                        
                        cell.webView.load(request)
                    }
                    
                }
                
                return cell
            }
            
        case .audios(let list):
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "AudioCVC",
                for: indexPath) as! AudioCVC
            if let urlStr = list[indexPath.row].url, let url = URL(string: urlStr) {
                cell.audioURL = url
            }
            cell.audioDelegate = self
            cell.waveView.setParentCell(cell)
            return cell
        }
    }
    
    
    // MARK: - Header
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
        
        guard indexPath.section == 0 else { return header }
        
        var yOffset: CGFloat = 0
        
        if let text = titleSting, !text.isEmpty {
            let label = UILabel()
            label.text = text
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .darkGray
            label.numberOfLines = 0
            
            let maxWidth = collectionView.frame.width - 32
            let size = label.sizeThatFits(
                CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
            )
            label.frame = CGRect(x: 16, y: yOffset,
                                 width: maxWidth, height: size.height)
            header.addSubview(label)
            yOffset += size.height + 8
        }
        
        let title = UILabel(frame: CGRect(x: 16, y: yOffset,
                                          width: collectionView.frame.width - 32,
                                          height: 30))
        title.font = UIFont.boldSystemFont(ofSize: 18)
        title.text = "🖼 Files"
        header.addSubview(title)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard section == 0 else { return .zero }
        
        var height: CGFloat = 30
        
        if let text = titleSting, !text.isEmpty {
            let label = UILabel()
            label.text = text
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 0
            
            let maxWidth = collectionView.frame.width - 32
            let size = label.sizeThatFits(
                CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
            )
            height += size.height + 8
        }
        
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    
    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch filterSection[indexPath.section] {
            
        case .media(let list):
            let file = list[indexPath.row]
            
            if file.type?.lowercased() == "video" {
                let width = collectionView.frame.width
                let spacing: CGFloat = 8
                let cellWidth = (width - spacing * 3) / 2
                return CGSize(width: cellWidth, height: cellWidth)
            } else {
                let width = collectionView.frame.width
                let spacing: CGFloat = 8
                let cellWidth = (width - spacing * 3) / 2
                return CGSize(width: cellWidth, height: cellWidth)
            }
            
        case .audios:
            return CGSize(width: collectionView.frame.width - 20, height: 60)
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
    
    
    // MARK: - Selection
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        switch filterSection[indexPath.section] {
            
        case .media(let items):
            let file = items[indexPath.row]
            
            if file.type == "video" {
                let vc = ImageShowVc()
                vc.fileURL = items
                vc.subjectName = "Videos"
                vc.index = indexPath.row
                vc.scrollIndex = indexPath
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            } else {
                let vc = ImageShowVc()
                vc.fileURL = items
                vc.subjectName = "Images & Docs"
                vc.index = indexPath.row
                vc.scrollIndex = indexPath
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
            
        case .audios:
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
