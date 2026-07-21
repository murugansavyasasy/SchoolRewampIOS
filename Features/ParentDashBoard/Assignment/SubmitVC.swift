//
//  submitVC.swift
//  VsSchoolChimes
//
//  Created by admin on 20/12/24.
//

import UIKit

@available(iOS 14.0, *)

class SubmitVC: UIViewController,UIImagePickerControllerDelegate & UINavigationControllerDelegate,UIDocumentPickerDelegate, DeleteImge, UITextViewDelegate  {
    
    
    func deleteImage(index: Int) {
        attachments.remove(at: index)
        selectImgPdfview.imageCollectionview.reloadData()
    }
    
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var addPhotosLabel: UILabel!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeght: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var DescriptionTextview: UITextView!
    @IBOutlet weak var bagrountview: UIView!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var selectImgPdfview: ImageSelection!
    @IBOutlet weak var studentNameLbl: UILabel!
    
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
    var editReport : Submission?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let studentName = studentDetails?.name ?? ""
        let Standard = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        studentNameLbl.configureAsBackTitle(firstLine: studentName, secondLine: Standard)
        NameLbl.text = "Submit " + MenuStringFile.selectedMenuName
        setupUI()
        imageSelection()
        
        titleTxt.delegate = self
        DescriptionTextview.delegate = self
        selectImgPdfview.imageCollectionview.delegate = self
        selectImgPdfview.imageCollectionview.dataSource = self
        titleTxt.text = titleName
        adjustTextViewHeights()
        setupPlaceholder()
        //FontStyle
        NameLbl.setFont(style: .header, size: FontSize.HeaderSize)
        
        DescriptionTextview.addDoneButton()
        
    }
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.Description.translated()
        placeholderLabel.font = DescriptionTextview.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.positionAsPlaceholder(in: DescriptionTextview)
        DescriptionTextview.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !DescriptionTextview.text.isEmpty // Hide if text exists
        if let edit = editReport{
            fetchData(notice: edit)
        }
    }
    func fetchData(notice: Submission?) {
        attachments.removeAll()
        if let notice = notice {
            titleTxt.text = notice.title ?? ""
            DescriptionTextview.text = notice.description
            id = notice.id
            DescriptionTextview.textColor = .black
            placeholderLabel?.isHidden = !DescriptionTextview.text.isEmpty
            adjustTextViewHeights()
            submitBtn.setTitle("Update".translated(), for: .normal)
            if let files = notice.file_path {
                attachments = files.map { file in
                    let type = (file.type ?? "").lowercased()
                    return AttachmentItem(
                        image: nil,
                        imageURL: file.url,
                        fileType: type,
                        VideoURl: nil
                    )
                }
                selectImgPdfview.imageCollectionview.reloadData()
                
            }
        }
    }
    
    // MARK: - Setup
    
    func setupUI() {
        DescriptionTextview.layer.cornerRadius = 10
        DescriptionTextview.layer.borderWidth = 1
        DescriptionTextview.layer.borderColor = UIColor.gray.cgColor
        
        submitBtn.layer.cornerRadius = 10
        submitBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        descriptionLbl.setFont(style: .title, size: FontSize.TitleSize)
        setAttributedText(
            for: addPhotosLabel,
            with: CommonStringFile.Add_attachment_optional.translated(),
            firstString: CommonStringFile.Add_attachment.translated(),
            secondString: CommonStringFile.Optional.translated(),
            color1: .black,
            color2: .lightGray
        )
        descriptionLbl.setRequiredText(CommonStringFile.Description)
    }
    
    @IBAction func submitBtn(_ sender: UIButton) {
        let alert = CustomAlert()
        if DescriptionTextview.text != "", id != nil{
            uploadMedia(
                file: attachments,
                viewController: self,
                title: titleTxt.text,
                description: DescriptionTextview.text ?? ""
            ) { [weak self] urls, iframe, fileSize, embedUrl in
                guard let self = self else { return }
                
                var uploadedFiles: [[String: String]] = []
                for urlString in urls {
                    guard let url = URL(string: urlString) else {
                        print("❌ Invalid URL: \(urlString)")
                        continue
                    }
                    
                    let ext = url.pathExtension.lowercased()
                    var type = ""
                    if ["jpg", "jpeg", "png", "gif", "heic"].contains(ext) {
                        type = CommonStringFile.IMAGE
                    } else if urlString.contains("vimeo.com") {
                        type = CommonStringFile.VIDEO
                    } else {
                        type = ext.uppercased()
                    }
                    uploadedFiles.append([
                        CommonStringFile.url: urlString,
                        CommonStringFile.type: type
                    ])
                }
                
                let iframeValue = iframe ?? ""
                let fileSizeStr = fileSize != nil ? "\(fileSize!)" : ""
                
                sendAttachment(with: uploadedFiles, iframe: "", file_size: "")
            }
            
        }else {
            DispatchQueue.main.async {
                self.alert.showAlert(
                    title: AlertstringFile.Alert_title,
                    message: "Please provide a description and minimum one attachment.",
                    on: self
                )
            }
        }
        
    }
    func paketApiCall(params:[String:Any]){
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_pauket_add_points,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: studentDetails?.access_token ?? "", isBaseUrl: true
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {

                guard let self = self else { return }

                switch result {
                case .success(let response):
                    self.dismiss(animated: true)
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(response.message, duration: 2.0, position: .bottom)
                    }
                case .failure(let error):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(error.localizedDescription, duration: 2.0, position: .bottom)
                    }
                    self.dismiss(animated: true)
                }
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
    
    func openCamera(){
        let remaining = 10 - attachments.count
        if remaining > 0 {
            let limit = max(remaining , 0)
            if limit > 0 {
                PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
            } else {
                CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            }
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    
    // MARK: File Attachments Actions
    func selectImages() {
        let remaining = 10 - attachments.count
        if remaining > 0 {
            let limit = max(remaining , 0)
            if limit > 0 {
                PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: limit), from: self)
            } else {
                CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            }
        } else {
            CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    
    func selectPDF() {
        let remaining = 10 - attachments.count
        if remaining > 0 {
            PhotoPickerManager.shared.limiSelection = remaining
            PhotoPickerManager.shared.presentPicker(ofType: .file, from: self)
        } else {
            CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    
    func imageSelection(){
        
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            
            attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            selectImgPdfview.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            attachments.append(contentsOf: imageItems)
            selectImgPdfview.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onFilePicked = { [self] data in
            // handle picked PDF
            user_inputs.selectedFileType = CommonStringFile.pdf
            attachments.append(AttachmentItem(image:nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf))
            selectImgPdfview.imageCollectionview.reloadData()
        }
        PhotoPickerManager.shared.onVideoPicked = { [self] data in
            // handle picked PDF
            user_inputs.selectedFileType = CommonStringFile.VIDEO
            attachments
                .append(
                    AttachmentItem(
                        image:nil,
                        imageURL: data.absoluteString,
                        fileType: CommonStringFile.VIDEO,
                        VideoURl:nil
                    )
                )
            selectImgPdfview.imageCollectionview.reloadData()
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
            
            
            // Set collection view height dynamically
            let totalItems = attachments.count
            collectionViewHeght.constant = totalItems <= 2 ? 120 : collectionView.collectionViewLayout.collectionViewContentSize.height
            
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
                self?.VideoPick()
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
    private func uploadMedia(
        file: Any,
        viewController: UIViewController,
        title: String = "",
        description: String = "",
        completion: @escaping (_ urls: [String], _ iframeHTML: String?, _ fileSize: Int?, _ embedUrl: String?) -> Void
    ) {
        var uploadedURLs: [String] = []
        var completed = 0
        var iframeValue: String?
        var fileSizeValue: Int?
        var embedUrlValue: String?
        
        func updateAndCheckCompletion(total: Int) {
            let progress = (Double(completed) / Double(total)) * 100
            CircularProgressLoader.shared.updateProgress(to: progress)
            if completed == total {
                CircularProgressLoader.shared.hide()
                completion(uploadedURLs, iframeValue, fileSizeValue, embedUrlValue)
            }
        }
        
        switch file {
        case let attachments as [AttachmentItem]:
            let uploadableItems = attachments.filter { $0.image != nil || $0.imageURL != nil }
            let total = uploadableItems.count
            guard total > 0 else {
                completion([], nil, nil, nil)
                return
            }
            
            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)
            
            for item in uploadableItems {
                if let image = item.image {
                    // 🖼 Local image → upload to AWS
                    AWSUploadManager.shared.uploadFileToAWS(
                        file: image,
                        progressHandler: nil
                    ) { url in
                        if let uploadedURL = url {
                            uploadedURLs.append(uploadedURL)
                        }
                        completed += 1
                        updateAndCheckCompletion(total: total)
                    }
                    
                } else if let fileURLStr = item.imageURL,
                          let fileURL = URL(string: fileURLStr) {
                    
                    if item.fileType.uppercased() == CommonStringFile.VIDEO {
                        if fileURLStr.contains("vimeo.com") {
                            uploadedURLs.append(fileURLStr)
                            completed += 1
                            updateAndCheckCompletion(total: total)
                        } else {
                            CircularProgressLoader.shared.show()
                            vimeoUploader = VimeoUploader(
                                accessToken: YOUR_VIMEO_TOKEN,
                                presentingViewController: viewController
                            )
                            vimeoUploader?.upload(
                                videoFileURL: fileURL,
                                title: title,
                                description: description,
                                progress: { progress in
                                    CircularProgressLoader.shared.updateProgress(to: progress * 100)
                                },
                                completion: { videoURL, iframeHTML, fileSize, finalEmbedUrl in
                                    if let finalEmbedUrl = finalEmbedUrl {
                                        uploadedURLs.append(finalEmbedUrl)
                                    }
                                    iframeValue = iframeHTML
                                    fileSizeValue = fileSize
                                    embedUrlValue = finalEmbedUrl
                                    
                                    completed += 1
                                    updateAndCheckCompletion(total: total)
                                }
                            )
                        }
                        
                    } else {
                        if fileURLStr.lowercased().starts(with: "http") {
                            uploadedURLs.append(fileURLStr)
                            completed += 1
                            updateAndCheckCompletion(total: total)
                        } else {
                            let path = item.fileType.uppercased() != CommonStringFile.IMAGE
                            ? "uploads/Documents/"
                            : "uploads/images/"
                            
                            AWSUploadManager.shared.uploadFileToAWS(
                                file: fileURL,
                                progressHandler: nil
                            ) { url in
                                if let uploadedURL = url {
                                    uploadedURLs.append(uploadedURL)
                                }
                                completed += 1
                                updateAndCheckCompletion(total: total)
                            }
                        }
                    }
                    
                } else {
                    print("❌ Invalid fileURL: \(item.imageURL ?? "nil")")
                    completed += 1
                    updateAndCheckCompletion(total: total)
                }
            }
            
        default:
            print("❌ Unsupported file type")
            completion([], nil, nil, nil)
        }
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
            let baseURL = (submitBtn.currentTitle == "Update".translated())
            ? ServiceUrl.comm_api_assignment_update_submission
            :ServiceUrl.comm_api_assignment_submit_assignment
            let type = (submitBtn.currentTitle == "Update".translated())
            ? ApitTypeSringFile.PUT
            :ApitTypeSringFile.POST
            APIService.shared.makeApi(
                url: baseURL,
                parameters: parameters,
                type: type,
                token: UserDefaultFileManager.get_child_Details()?.access_token ?? "", isBaseUrl: true
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
                            if user_inputs.clearTempData(){
                                let parms = [ "mobile_number": UserDefaultFileManager.get_staff_Details()?.mobile_no ?? "",
                                              "activity": "SUBMIT_ASSIGNMENT",
                                              "user_type": 1,
                                              "menu_id": Menu_id.staffSelectedMenuId] as [String : Any]
                                self.paketApiCall(params:parms)
                            }
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
        return true
    }
    
}
