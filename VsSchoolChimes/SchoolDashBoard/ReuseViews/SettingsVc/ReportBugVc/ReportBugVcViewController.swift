//
//  ReportBugVcViewController.swift
//  VsSchoolChimes
//
//  Created by admin on 28/10/24.
//

import UIKit
import PhotosUI
import DropDown

@available(iOS 14.0, *)
class ReportBugVcViewController: UIViewController, UITextViewDelegate, DeleteImge {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var selectModuleLbl: UILabel!
    @IBOutlet weak var ModuleDropDown: DropDown!
    @IBOutlet weak var textViewStack: UIStackView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var BugsTextview: UITextView!
    @IBOutlet weak var uploadView: RectangularDashedView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var AttachmentView: ImageSelection!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    var selectedImages: [UIImage] = []
    var attachments: [AttachmentItem] = []
    let dropDown = DropDown()
    var passValue = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackBtn.setTitle(MenuTapbar.shared.Report_a_bug, for: .normal)
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        BackBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft:.forceLeftToRight
        BackBtn.contentHorizontalAlignment = Language == "ar" ? .right:.left
        BackBtn.imageView?.applyRTLFlip(Language == "ar")
        
        BackBtn.setTitleFont(style: .primary, size:FontSize.HeaderSize)
        sendBtn.setTitleFont(style: .body, size:FontSize.TitleSize)
        
        sendBtn.layer.cornerRadius = 10
        sendBtn.semanticContentAttribute = .forceRightToLeft
        
        selectModuleLbl.setFont(style: .body, size: 14)
        ModuleDropDown.layer.cornerRadius = Colornames.CORadius10
        ModuleDropDown.layer.borderWidth = 0.5
        ModuleDropDown.layer.borderColor = UIColor.lightGray.cgColor
        
        BugsTextview.delegate = self
        BugsTextview.text = "Type content"//CommonStringFile.Enterbugs.translated()
        BugsTextview.textColor = UIColor.lightGray
        BugsTextview.addDoneButton()
        BugsTextview.layer.cornerRadius = Colornames.CORadius10
        BugsTextview.layer.borderWidth = 0.5
        BugsTextview.layer.borderColor = UIColor.lightGray.cgColor
        
        imageSelection()
        
        AttachmentView.imageCollectionview.register(UINib(nibName: CellConfingName.ImageCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        AttachmentView.imageCollectionview.register(UINib(nibName: CellConfingName.AttachmentCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.AttachmentCVCell)
        
        AttachmentView.imageCollectionview.delegate = self
        AttachmentView.imageCollectionview.dataSource = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let collection = UINib(nibName: CellConfingName.ImageCvCell, bundle: nil)
        collectionView.register(collection, forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        let tap = UITapGestureRecognizer(target: self, action:#selector(uploadImage) )
        uploadView.addGestureRecognizer(tap)
        
        let dropDown = UITapGestureRecognizer(target: self, action:#selector(ModuleDrop) )
        ModuleDropDown.addGestureRecognizer(dropDown)
    }
    
    @IBAction func ModuleDrop(){

        dropDown.dataSource = user_inputs.menuList
        dropDown.anchorView = ModuleDropDown
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            selectModuleLbl.text = item
        }
    }
    
    // MARK: - Picker Setup
    func imageSelection() {
        
        PhotoPickerManager.shared.onImagesPicked = { [weak self] images in
            guard let self = self else { return }
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            self.attachments.append(contentsOf: imageItems)
            AttachmentView.imageCollectionview.reloadData()
        }
        
        
        PhotoPickerManager.shared.onVideoPicked = { [weak self] data in
            guard let self = self else { return }
            user_inputs.selectedFileType = CommonStringFile.VIDEO
            self.attachments.append(
                AttachmentItem(image: nil, imageURL: nil, fileType: CommonStringFile.VIDEO, VideoURl: data)
            )
            AttachmentView.imageCollectionview.reloadData()
        }
    }
    
    @IBAction func uploadImage(){
        selectImages()
    }
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func SendBtnAct(_ sender: Any) {
     
       
//            var itemsToShare: [Any] = []
//            
//            for item in attachments {
//                if let image = item.image {
//                    itemsToShare.append(image)
//                } else if let videoURL = item.VideoURl {
//                    itemsToShare.append(videoURL)
//                } else if let imagePath = item.imageURL {
//                    itemsToShare.append(URL(fileURLWithPath: imagePath))
//                }
//            }
//            
//            guard !itemsToShare.isEmpty else { return }
//            
//            let activityVC = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
//            
//            // Exclude everything except Mail (Gmail will still appear if installed)
//            activityVC.excludedActivityTypes = [
//                .postToFacebook,
//                .postToTwitter,
//                .postToWeibo,
//                .message,
//                .print,
//                .copyToPasteboard,
//                .assignToContact,
//                .saveToCameraRoll,
//                .addToReadingList,
//                .postToFlickr,
//                .postToVimeo,
//                .postToTencentWeibo,
//                .airDrop,
//                .openInIBooks,
//                .markupAsPDF
//            ]
//            
//        activityVC.popoverPresentationController?.sourceView = sender as? UIView
//            present(activityVC, animated: true)
        openGmail()

    }
    
    func openGmail() {
        let to = "test@example.com"
        let subject = "My Subject"
        let body = "Hello, this is the body."

        let urlString = "googlegmail://co?to=\(to)&subject=\(subject)&body=\(body)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if BugsTextview.text == "Type content"/*CommonStringFile.Enterbugs.translated()*/ {
            BugsTextview.text = nil
            BugsTextview.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if BugsTextview.text.isEmpty{
            
            BugsTextview.text = "Type content"//CommonStringFile.Enterbugs.translated()
            BugsTextview.textColor = UIColor.lightGray
        }
    }
}

@available(iOS 14.0, *)
extension ReportBugVcViewController : UICollectionViewDelegate,UICollectionViewDataSource,PHPickerViewControllerDelegate{
    
    func selectImages() {
        let img = attachments.filter { $0.fileType == CommonStringFile.IMAGE }
        if attachments.count != 10{
            PhotoPickerManager.shared
                .presentPicker(
                    ofType: .gallery(selectionLimit: 10 - attachments.count),
                    from: self
                )
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    func VideoPick() {
        let video = attachments.filter { $0.fileType != CommonStringFile.VIDEO }
        
        if  video.count != 2{
            
            if attachments.count <= 10{
                PhotoPickerManager.shared.limiSelection = 10 - attachments.count
                PhotoPickerManager.shared.presentPicker(ofType: .video, from: self)
                
            }else{
                let alert = CustomAlert()
                alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            }
            
        }else{
            
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
        
    }
    
    // MARK: - PHPickerViewControllerDelegate
    /*func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    guard let self = self, let image = image as? UIImage, error == nil else { return }
                    DispatchQueue.main.async {
                        self.selectedImages.append(image)
                       
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }*/
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true, completion: nil)
            
            let group = DispatchGroup()
            
            for result in results {
                let itemProvider = result.itemProvider
                
                // ✅ Handle Images
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                        guard let self = self, let image = image as? UIImage, error == nil else {
                            group.leave()
                            return
                        }
                        
                        // Save compressed image to temp URL
                        let tempURL = FileManager.default.temporaryDirectory
                            .appendingPathComponent(UUID().uuidString + ".jpg")
                        
                        if let data = image.jpegData(compressionQuality: 0.75) {
                            try? data.write(to: tempURL)
                        }
                        
                        let attachment = AttachmentItem(
                            image: image,
                            imageURL: tempURL.path,
                            fileType: "image",
                            VideoURl: nil,
                            VimeoVideoURL: nil
                        )
                        
                        DispatchQueue.main.async {
                            self.selectedImages.append(image)
                            self.attachments.append(attachment)
                            self.collectionView.reloadData()
                        }
                        
                        group.leave()
                    }
                }
                
                // ✅ Handle Videos
                else if itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                    group.enter()
                    itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                        guard let self = self, let sourceURL = url else {
                            group.leave()
                            return
                        }
                        
                        // Compress video
                        let asset = AVAsset(url: sourceURL)
                        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
                        let tempURL = FileManager.default.temporaryDirectory
                            .appendingPathComponent(UUID().uuidString + ".mp4")
                        
                        exportSession?.outputURL = tempURL
                        exportSession?.outputFileType = .mp4
                        
                        exportSession?.exportAsynchronously {
                            if exportSession?.status == .completed {
                                let attachment = AttachmentItem(
                                    image: nil,
                                    imageURL: nil,
                                    fileType: "video",
                                    VideoURl: tempURL,
                                    VimeoVideoURL: nil
                                )
                                
                                DispatchQueue.main.async {
                                    self.attachments.append(attachment)
                                    self.collectionView.reloadData()
                                }
                            }
                            group.leave()
                        }
                    }
                }
            }
            
            // Optional: run something when all items are processed
            group.notify(queue: .main) {
                print("✅ All media processed, ready to use attachments")
            }
        }
    
    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attachments.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.AttachmentCVCell, for: indexPath) as! AttachmentCVCell
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
        let adjustedIndex = indexPath.item - 1
        let item = attachments[adjustedIndex]
        cell.delegate = self
        cell.deleteBtn.tag = adjustedIndex
        
        if let image = item.image {
            cell.imageViews.image = image
        } else if let urlStr = item.imageURL, let url = URL(string: urlStr) {
            if item.fileType.uppercased() != CommonStringFile.IMAGE {
                let iconName = getFileIconName(for: url)
                cell.imageViews.image = UIImage(named: iconName)
            } else {
                cell.imageViews.kf.setImage(with: url)
            }
        } else if let vido = item.VideoURl{
            let iconName = getFileIconName(for: vido)
            cell.imageViews.image = UIImage(named: iconName)
            
        }else{
            
            cell.imageViews.image = nil
        }
        
        // Set collection view height dynamically
        let totalItems = attachments.count
        collectionViewHeight.constant = totalItems <= 2 ? 120 : collectionView.collectionViewLayout.collectionViewContentSize.height
       
        return cell
    }
    
    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let remaining = Filecount.SelectImageAndDocumetCount - attachments.count
            
            if remaining > 0 {
                let alertController = UIAlertController(
                    title: "Select".translated(),
                    message: "Choose an option".translated(),
                    preferredStyle: .actionSheet
                )
                
                // 🖼 Gallery option
                let galleryAction = UIAlertAction(
                    title: CommonStringFile.Photos,
                    style: .default
                ) { [self] _ in
                    selectImages()
                }
                alertController.addAction(galleryAction)
                
                // 🎥 Video option
                let videoAction = UIAlertAction(
                    title: CommonStringFile.Video,
                    style: .default
                ) { [self] _ in
                    let totalRemaining = Filecount.SelectImageAndDocumetCount - attachments.count
                    let videoCount = attachments.filter { $0.fileType.lowercased() == "video" }.count
                    let videoRemaining = Filecount.SelectVideoCount - videoCount
                    
                    if totalRemaining <= 0 {
                        CustomAlert()
                            .showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
                    } else if videoRemaining <= 0 {
                        CustomAlert()
                            .showAlert(title: "",
                                       message: CommonStringFile.You_can_only_select_up_to2_video_files,
                                       on: self)
                    } else {
                        VideoPick()
                    }
                }
                alertController.addAction(videoAction)
                
                // ❌ Cancel option
                let cancelAction = UIAlertAction(
                    title: CommonStringFile.Cancel,
                    style: .cancel,
                    handler: nil
                )
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                CustomAlert()
                    .showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            }
        }else {
            
            let vc = ImageShowVc(nibName: nil, bundle: nil)
            vc.attachment = attachments
            vc.scrollIndex = indexPath
            vc.index = indexPath.item - 1
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        
    }
    
    
    func deleteImage(index: Int) {
        attachments.remove(at: index)
        AttachmentView.imageCollectionview.reloadData()
    }
    
    @IBAction func addImagesButtonTapped(_ sender: UIButton) {
        selectImages()
    }
}
@available(iOS 14.0, *)
extension ReportBugVcViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want
        return CGSize(width: width, height: width)
    }
}



