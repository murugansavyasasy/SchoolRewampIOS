//
//  submitVC.swift
//  VsSchoolChimes
//
//  Created by admin on 20/12/24.
//

import UIKit

@available(iOS 14.0, *)

class SubmitVC: UIViewController,UIImagePickerControllerDelegate & UINavigationControllerDelegate,UIDocumentPickerDelegate, DeleteImge, UITextViewDelegate, VideoPickerManagerDelegate  {
    
    func deleteImage(index: Int) {
        attachments.remove(at: index)
        selectImgPdfview.imageCollectionview.reloadData()
    }
    
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var addPhotosLabel: UILabel!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeght: NSLayoutConstraint!
    @IBOutlet weak var descriptionCountLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var DescriptionTextview: UITextView!
    @IBOutlet weak var bagrountview: UIView!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var selectImgPdfview: ImageSelection!
    @IBOutlet weak var VideoView: UIView!
    @IBOutlet weak var VideoDeleteBtn: UIImageView!
    @IBOutlet weak var VideoPlayBtn: UIButton!
    @IBOutlet weak var VideoThumbnailImg: UIImageView!
    
    var placeholderLabel: UILabel!
    var attachments: [AttachmentItem] = []
    var url: URL?
    let photoPickManager = PhotoPickerManager.shared
    var titleName:String?
    var uploadedURLs: [String] = []
    let alert = CustomAlert()
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var id:String?
    let initialHeight: CGFloat = 120
    let maxHeight: CGFloat = 300
    var videoPicker: VideoPickerManager?
    var selectedVideoURL: URL?
    var vimeoUploader: VimeoUploader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NameLbl.text = studentDetails?.name
        StandardLbl.text = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        setupUI()
        videoPicker = VideoPickerManager(presenter: self, delegate: self)
        imageSelection()
        
        titleTxt.delegate = self
        DescriptionTextview.delegate = self
        selectImgPdfview.imageCollectionview.delegate = self
        selectImgPdfview.imageCollectionview.dataSource = self
        titleTxt.text = titleName
        adjustTextViewHeights()
        setupPlaceholder()
        //FontStyle
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        DescriptionTextview.addDoneButton()
        
        let DeleteGesture = UITapGestureRecognizer(target: self, action: #selector(deleteVideo))
        VideoDeleteBtn.addGestureRecognizer(DeleteGesture)
    }
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.Description
        placeholderLabel.font = DescriptionTextview.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8) // Adjust padding
        DescriptionTextview.applyRightTxt()
        DescriptionTextview.applyRightTxt(with: placeholderLabel)
        DescriptionTextview.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !DescriptionTextview.text.isEmpty // Hide if text exists
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue, Colornames.gradientgreen],
                           startPoint: CGPoint(x: 1, y: 0.5),
                           endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    // MARK: - Setup
    
    func setupUI() {
        VideoView.layer.cornerRadius = 10
        VideoView.isHidden = true
        //          bagrountview.layer.cornerRadius = 10
        //          bagrountview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        //          bagrountview.clipsToBounds = true
        DescriptionTextview.layer.cornerRadius = 10
        DescriptionTextview.layer.borderWidth = 1
        DescriptionTextview.layer.borderColor = UIColor.gray.cgColor
        
        submitBtn.layer.cornerRadius = 10
        submitBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        descriptionLbl.setFont(style: .title, size: FontSize.TitleSize)
        descriptionCountLbl.setFont(style: .body, size: FontSize.BodySize)
        
        addPhotosLabel.setRequiredText(CommonStringFile.Add_attachment)
        descriptionLbl.setRequiredText(CommonStringFile.Description)
    }
    
    // MARK: - IBActions
    
    @IBAction func submitBtn(_ sender: UIButton) {
        
        if DescriptionTextview.text != "", id != nil, !attachments.isEmpty {
            
            uploadAWSMedia(file: attachments) { [self] in
                CircularProgressLoader.shared.hide()
                
                let uploadedFiles: [[String: String]] = uploadedURLs.compactMap { urlString in
                    guard let url = URL(string: urlString) else { return nil }
                    
                    let fileType = url.pathExtension.lowercased()
                    let type = fileType == CommonStringFile.jpg ? CommonStringFile.IMAGE : url.pathExtension.uppercased()
                    
                    return [
                        CommonStringFile.url: urlString,
                        CommonStringFile.type: type
                    ]
                }
                
                sendAttachment(with: uploadedFiles, iframe: "", file_size: "")
            }
            
        }else if DescriptionTextview.text != "", id != nil, selectedVideoURL != nil {
            
            guard let videoURL = selectedVideoURL else {return}
            let selectedType = user_inputs.selectedFileType
            var uploadedFiles: [[String: String]] = []
            var fileSizeValue = ""
            var iframe = ""
            startUpload(from: self, videoURL: videoURL , title: titleTxt.text, description: DescriptionTextview.text) {videoURLString,iframeHTML,fileSize,finalEmbedUrl in
                
                if let videoURLString = videoURLString {
                    uploadedFiles = [[CommonStringFile.url: videoURLString,
                                      CommonStringFile.type: "video"]]
                    if let iframeHTML = iframeHTML {
                        iframe = iframeHTML
                        
                    }
                    if let size = fileSize {
                        fileSizeValue = self.convertSize(size)//String(size)
                    }
                    self.sendAttachment(with: uploadedFiles, iframe: iframe, file_size: fileSizeValue)
                }
            }
        }
        else {
            DispatchQueue.main.async {
                self.alert.showAlert(
                    title: AlertstringFile.Alert_title,
                    message: "Please provide a description and minimum one attachment.",
                    on: self
                )
            }
        }
        
    }
    
    func convertSize(_ sizeInBytes: Int) -> String {
        let kb = 1024.0
        let mb = kb * 1024
        let gb = mb * 1024
        let size = Double(sizeInBytes)
        
        switch size {
        case 0..<kb:
            return String(format: "%.0f B", size)
        case kb..<mb:
            return String(format: "%.2f KB", size / kb)
        case mb..<gb:
            return String(format: "%.2f MB", size / mb)
        default:
            return String(format: "%.2f GB", size / gb)
        }
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: File Attachments Actions
    func selectImages() {
        let img = attachments.filter { $0.fileType == CommonStringFile.IMAGE }
        if img.count != 5{
            PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: 5 - img.count), from: self)
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
        
    }
    func openCamera(){
        let img = attachments.filter { $0.fileType == CommonStringFile.IMAGE }
        if img.count != 5{
            PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    func selectPDF() {
        let pdf = attachments.filter { $0.fileType != CommonStringFile.IMAGE }
        if pdf.count != 5{
            PhotoPickerManager.shared.presentPicker(ofType: .file, from: self)
            PhotoPickerManager.shared.limiSelection = 5 - pdf.count
        }else{
            
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    func imageSelection(){
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            
            attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            attachments.removeAll { $0.fileType == CommonStringFile.pdf }
            selectedVideoURL = nil
            
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            selectImgPdfview.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            attachments.append(contentsOf: imageItems)
            if imageItems.count != 0{
                attachments.removeAll { $0.fileType == CommonStringFile.pdf }
            }
            selectedVideoURL = nil
            selectImgPdfview.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onFilePicked = { [self] data in
            // handle picked PDF
            user_inputs.selectedFileType = CommonStringFile.pdf
            attachments.append(AttachmentItem(image:nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf))
            attachments.removeAll { $0.fileType == CommonStringFile.IMAGE }
            selectedVideoURL = nil
            selectImgPdfview.imageCollectionview.reloadData()
        }
    }
    
    func selectVideo() {
        videoPicker?.pickVideo()
    }
    
    @IBAction func playVideoTapped(_ sender: UIButton) {
        VideoDeleteBtn.isHidden = true
        if let url = selectedVideoURL {
            videoPicker?.playVideo(from: url, in: VideoView)
        } else {
            videoPicker?.pickVideo()
        }
    }
    
    @IBAction func deleteVideo(){
        
        videoPickerManagerDidCloseVideo()
    }
    
    // MARK: - Delegate Methods
    func videoPickerManager(didPickVideo url: URL) {
        
        attachments.removeAll()
        selectImgPdfview.isHidden = true
        collectionViewHeght.constant = 0
        selectedVideoURL = url
        
        VideoView.isHidden = false
    }
    
    func videoPickerManager(didGenerateThumbnail image: UIImage) {
        VideoThumbnailImg.isHidden = false
        VideoThumbnailImg.image = image
    }
    
    func videoPickerManagerDidCloseVideo() {
        selectedVideoURL = nil
        VideoThumbnailImg.image = nil
        VideoView.isHidden = true
        selectImgPdfview.isHidden = false
        collectionViewHeght.constant = 120
        selectImgPdfview.imageCollectionview.reloadData()
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == DescriptionTextview {
            adjustTextViewHeights()
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    func adjustTextViewHeights() {
        // Title height (set via code only)
        let titleSize = CGSize(width: titleTxt.frame.width, height: .infinity)
        let estimatedTitleHeight = titleTxt.sizeThatFits(titleSize).height
        titleHeight.constant = max(estimatedTitleHeight, 40)
        
        // Description height (set by user typing)
        let descSize = CGSize(width: DescriptionTextview.frame.width, height: .infinity)
        let estimatedDescHeight = DescriptionTextview.sizeThatFits(descSize).height
        descriptionHeght.constant = max(estimatedDescHeight, 150)
        
        view.layoutIfNeeded()
    }
    
}
@available(iOS 14.0, *)
extension SubmitVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1 + attachments.count /*selectedImages.count + selectedImgUrl.count*/
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // First cell is the "Add Attachment" button cell
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.AttachmentCVCell,
                for: indexPath
            ) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.ImageCvCell,
                for: indexPath
            ) as! ImageCvCell
            
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
            } else {
                cell.imageViews.image = nil
            }
            
            // Assuming you have an array of UIImage from selected files
            
            
            // Set collection view height dynamically
            let totalItems = attachments.count
            collectionViewHeght.constant = totalItems <= 2 ? 120 : 220
            
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (selectImgPdfview.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let alert = UIAlertController(title: "Select".translated(),
                                          message: "Choose an option".translated(),
                                          preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera".translated(), style: .default) { [weak self] _ in
                self?.openCamera()
            })
            alert.addAction(UIAlertAction(title: "Gallery".translated(), style: .default) { [weak self] _ in
                self?.selectImages()
            })
            alert.addAction(UIAlertAction(title: "Document".translated(), style: .default) { [weak self] _ in
                self?.selectPDF()
            })
            alert.addAction(UIAlertAction(title: "Video".translated(), style: .default) { [weak self] _ in
                self?.selectVideo()
            })
            alert.addAction(UIAlertAction(title: "Cancel".translated(), style: .cancel))
            present(alert, animated: true)
        } else {
            if attachments.count > indexPath.item - 1 {
                let vc = PreviewImageVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                if attachments[indexPath.item - 1].fileType != CommonStringFile.IMAGE{
                    if let url = attachments[indexPath.item - 1].imageURL{
                        vc.selectedFileURL = URL(string: url)
                    }
                } else{
                    if let img = attachments[indexPath.item - 1].image {
                        vc.img = attachments[indexPath.item - 1].image
                    }else{
                        vc.selectedFileURL = URL(string: attachments[indexPath.item - 1].imageURL ?? "")
                    }
                    
                }
                vc.type = attachments[indexPath.item - 1].fileType
                present(vc, animated: true)
            }
        }
    }
    private func uploadAWSMedia(file: Any, completion: @escaping () -> Void) {
        var completed = 0
        func updateAndCheckCompletion(total: Int) {
            let progress = (Double(completed) / Double(total)) * 100
            CircularProgressLoader.shared.updateProgress(to: progress)
            if completed == total {
                CircularProgressLoader.shared.hide()
                completion()
            }
        }
        switch file {
            // 🎙️ Case: Audio File from String (URL Path)
        case let files as String:
            guard let audioURL = URL(string: files) else {
                print("❌ Invalid audio URL.")
                return
            }
            let total = 1
            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)
            let today_date = AwsCurrentDateString()
            AWSUploadManager.shared.uploadFileToAWS(
                file: audioURL,
                bucketPath:  "communication" + "/" + (UserDefaultFileManager
                    .get_staff_Details()?.school_id ?? "") + "/" + today_date
                ,
                bucketName: "schoolchimes-communication",
                progressHandler: { progress in
                    CircularProgressLoader.shared.updateProgress(to: progress)
                },
                completion: { url in
                    if let uploadedURL = url {
                        print("✅ Audio uploaded: \(uploadedURL)")
                        user_inputs.voice_link = uploadedURL
                    } else {
                        print("❌ Audio upload failed.")
                    }
                    
                    completed += 1
                    let progress = (Double(completed) / Double(total)) * 100
                    CircularProgressLoader.shared.updateProgress(to: progress)
                    
                    if completed == total {
                        CircularProgressLoader.shared.hide()
                        completion()
                    }
                }
            )
            
            // 🖼️ Case: Array of Images
        case let images as [UIImage]:
            let total = images.count
            guard !images.isEmpty else {
                completion()
                return
            }
            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)
            
            for (index, img) in images.enumerated() {
                AWSUploadManager.shared.uploadFileToAWS(
                    file: img,
                    bucketPath: "uploads/images/",
                    bucketName: "schoolchimes-communication",
                    progressHandler: { progress in
                        // Optional: Update progress per file individually if you want
                    },
                    completion: { [self] url in
                        if let uploadedURL = url {
                            uploadedURLs.append(uploadedURL)
                            
                        } else {
                            print("❌ Failed to upload image \(index)")
                        }
                        
                        completed += 1
                        let progress = (Double(completed) / Double(total)) * 100
                        CircularProgressLoader.shared.updateProgress(to: progress)
                        if completed == total {
                            CircularProgressLoader.shared.hide()
                            // Do something with uploadedURLs if needed
                            completion()
                        }
                    }
                )
            }
            // 🖼️ Case: Array of Images
        case let files as [String]:
            let total = files.count
            guard !files.isEmpty else {
                completion()
                return
            }
            
            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)
            
            for (index, url) in files.enumerated() {
                guard let PdfURL = URL(string: url) else {
                    print("❌ Invalid audio URL.")
                    return
                }
                AWSUploadManager.shared.uploadFileToAWS(
                    file: PdfURL,
                    bucketPath: "uploads/Documents/",
                    bucketName: "schoolchimes-communication",
                    progressHandler: { progress in
                        // Optional: Update progress per file individually if you want
                    },
                    completion: { [self] url in
                        if let uploadedURL = url {
                            uploadedURLs.append(uploadedURL)
                            
                        } else {
                            print("❌ Failed to upload image \(index)")
                        }
                        
                        completed += 1
                        let progress = (Double(completed) / Double(total)) * 100
                        CircularProgressLoader.shared.updateProgress(to: progress)
                        
                        if completed == total {
                            CircularProgressLoader.shared.hide()
                            // Do something with uploadedURLs if needed
                            completion()
                        }
                    }
                )
            }
        case let attachments as [AttachmentItem]:
            let uploadableItems = attachments.filter { $0.image != nil || $0.imageURL != nil }
            let total = uploadableItems.count
            guard total > 0 else {
                completion()
                return
            }
            
            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)
            
            for item in uploadableItems {
                if let image = item.image {
                    // 🖼️ Upload local image
                    AWSUploadManager.shared.uploadFileToAWS(
                        file: image,
                        bucketPath: "uploads/images/",
                        bucketName: "schoolchimes-communication",
                        progressHandler: nil,
                        completion: { url in
                            if let uploadedURL = url {
                                self.uploadedURLs.append(uploadedURL)
                            }
                            completed += 1
                            updateAndCheckCompletion(total: total)
                        }
                    )
                } else if let fileURLStr = item.imageURL {
                    if fileURLStr.lowercased().starts(with: "http") {
                        self.uploadedURLs.append(fileURLStr)
                        completed += 1
                        updateAndCheckCompletion(total: total)
                    } else if let fileURL = URL(string: fileURLStr) {
                        let path = item.fileType.lowercased() != CommonStringFile.IMAGE ? "uploads/Documents/" : "uploads/images/"
                        
                        AWSUploadManager.shared.uploadFileToAWS(
                            file: fileURL,
                            bucketPath: path,
                            bucketName: "schoolchimes-communication",
                            progressHandler: nil,
                            completion: { url in
                                if let uploadedURL = url {
                                    self.uploadedURLs.append(uploadedURL)
                                }
                                completed += 1
                                updateAndCheckCompletion(total: total)
                            }
                        )
                    } else {
                        print("❌ Invalid fileURL: \(fileURLStr)")
                        completed += 1
                        updateAndCheckCompletion(total: total)
                    }
                }
            }
        default:
            print("❌ Unsupported file type")
            return
        }
    }
    
    func startUpload(from viewController: UIViewController,videoURL: URL, title: String, description: String, completion: @escaping (_ videoURLString: String?, _ iframeHTML: String?, _ fileSize: Int?,_ embedUrl: String?) -> Void) {
        print("📂 Selected video URL: \(videoURL)")
        
        CircularProgressLoader.shared.show()
        
        vimeoUploader = VimeoUploader(accessToken: YOUR_VIMEO_TOKEN, presentingViewController: viewController)
        //        vimeoUploader?.userProvidedThumbnail = user_inputs.thumbNail
        vimeoUploader?.upload(videoFileURL: videoURL, title: title, description: description, progress: { progress in
            print("📊 Upload progress: \(progress * 100)%")
            CircularProgressLoader.shared.updateProgress(to: progress)
        }, completion: { videoURL, iframeHTML, fileSize, finalEmbedUrl in
            CircularProgressLoader.shared.hide()
            
            if let videoURL = videoURL {
                print("✅ Video uploaded! Watch it at: \(videoURL)")
                if let iframeHTML = iframeHTML {
                    print("💻 Embed HTML: \(iframeHTML)")
                }
                if let size = fileSize {
                    print("📦 File size: \(size) bytes")
                }
                if let emb = finalEmbedUrl {
                    print("📦 File : \(emb)")
                }
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: videoURL))
                
                
                completion(videoURL, iframeHTML, fileSize, finalEmbedUrl)
            } else {
                print("❌ Upload failed!")
                completion(nil, nil, nil,nil)
            }
        })
    }
    
    
    func sendAttachment(with uploadedFiles: [[String: String]],iframe:String,file_size:String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let parameters: [String: Any] = [
                "id": self.id ?? "",
                "description": self.DescriptionTextview.text ?? "",
                "iframe": iframe,
                "file_size": file_size,
                "file_path": uploadedFiles
            ]
            
            APIService.shared.makeApi(
                url: ServiceUrl.comm_api_assignment_submit_assignment,
                parameters: parameters,
                type: ApitTypeSringFile.POST,
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
                            self.gotoDashboard()
                        }
                    }
                case .failure(let error):
                    print("❌ API error: \(error.localizedDescription)")
                    // Optionally show error alert here
                }
            }
        }
    }
    
    func gotoDashboard(){
        self.dismiss(animated: false, completion: nil)
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Current text in the UITextView
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if newText.count <= 500 {
            descriptionCountLbl.text = "\(newText.count) / 500" // Update the character count label
            return true // Allow the change
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            return false // Reject the change
        }
    }
    
}
