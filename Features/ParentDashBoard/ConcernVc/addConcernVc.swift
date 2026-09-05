//
//  addConcernVc.swift
//  School Chimes
//
//  Created by apple on 25/08/26.
//

import UIKit

class addConcernVc: UIViewController, DeleteImge {
    func deleteImage(index: Int) {
        attachments.remove(at: index)
        
        selectImgPdfview.imageCollectionview.reloadData()
    }
    
    @IBOutlet weak var toolBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var RaiseFullStackView: UIStackView!
    @IBOutlet weak var concernTypeFulStack: UIStackView!
    @IBOutlet weak var classteacherBtnName: UIButton!
    @IBOutlet weak var selectConcerTypeLbl: UILabel!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var managmentBtnName: UIButton!
    @IBOutlet weak var selectImgPdfview: ImageSelection!
  
    @IBOutlet weak var principalBtnName: UIButton!
    
    @IBOutlet weak var descrptionTextView: UITextView!
    @IBOutlet weak var concernDropdownView: UIView!
    var attachments: [AttachmentItem] = []
    let dropDown = DropDown()
    var dropDownData : [concernData]?
    var dropDownList = [String]()
    var selectedConcernListId : String?
    var selectedRole: String = "management"
    var vimeoUploader: VimeoUploader?
    var alert = CustomAlert()
    var loginAsType : Int?
    var selectedStudentID :String?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
        get_CatagoryListApi()
    }

    @IBAction func BackBtnAct(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
    @IBAction func checkBtnUpdate(_ sender: UIButton) {
        
        // Select only the tapped button
        if sender == managmentBtnName {
                selectedRole = "management"
            } else if sender == principalBtnName {
                selectedRole = "principal"
            } else if sender == classteacherBtnName {
                selectedRole = "class_teacher"
            }
           updateRadioButtons()
    }
    
  
    func updateRadioButtons() {
        let selectedImage = UIImage(systemName: "largecircle.fill.circle")
        let unselectedImage = UIImage(systemName: "circle")
        
        classteacherBtnName.setImage(
            classteacherBtnName.isSelected ? selectedImage : unselectedImage,
            for: .normal
        )
        
        principalBtnName.setImage(
            principalBtnName.isSelected ? selectedImage : unselectedImage,
            for: .normal
        )
        
        managmentBtnName.setImage(
            managmentBtnName.isSelected ? selectedImage : unselectedImage,
            for: .normal
        )
    }
    func setupUi(){
        // Management selected by default
        if loginAsType == 1{
            RaiseFullStackView.isHidden = true
            concernTypeFulStack.isHidden = true
            toolBarHeight.constant = 169
        }
         managmentBtnName.isSelected = true
         classteacherBtnName.isSelected = false
         principalBtnName.isSelected = false
        descrptionTextView.layer.cornerRadius = 10
        descrptionTextView.layer.borderWidth = 1
        descrptionTextView.layer.borderColor = UIColor.gray.cgColor
        concernDropdownView.setShadow(cornerRadius: 8)
        selectImgPdfview.imageCollectionview.delegate = self
        selectImgPdfview.imageCollectionview.dataSource = self
        selectImgPdfview.imageCollectionview.backgroundColor = .clear
        let concernTap = UITapGestureRecognizer(target: self, action: #selector(catagoryTapped))
        concernDropdownView.addGestureRecognizer(concernTap)
        imageSelection()
        
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
                        imageURL: nil,
                        fileType: CommonStringFile.VIDEO,
                        VideoURl: data
                    )
                )
            selectImgPdfview.imageCollectionview.reloadData()
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
    
    func openCamera() {
        if attachments.count < 10 {
            PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        } else {
            CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    func selectDocuments() {
        let remaining = 10 - attachments.count
        if remaining > 0 {
            PhotoPickerManager.shared.limiSelection = remaining
            PhotoPickerManager.shared.presentPicker(ofType: .file, from: self)
        } else {
            CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    func VideoPick() {
        let totalRemaining = 10 - attachments.count
        let videoCount = attachments.filter { $0.fileType.lowercased() == "video" }.count
        let videoRemaining = 2 - videoCount
        if totalRemaining <= 0 {
            CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        } else if videoRemaining <= 0 {
            CustomAlert().showAlert(title: "", message: AlertstringFile.You_can_only_select_up_to_video_files, on: self)
        } else {
            let pickLimit = min(totalRemaining, videoRemaining)
            PhotoPickerManager.shared.limiSelection = pickLimit
            PhotoPickerManager.shared.presentPicker(ofType: .video, from: self)
        }
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitBtnAct(_ sender: UIButton) {
        
        let description = descrptionTextView.text ?? ""

        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            CustomAlert().showAlert(
                title: "",
                message: AlertstringFile.Enter_description,
                on: self
            )
            
        } else {
            
            alert.showAlertCancel(
                title: "Raise concern",
                message: "Are you sure you want to raise this concern?",
                actionLbl1: "Raise",
                actionLbl2: "Cancel",
                on: self,
                onOk: { [weak self] in
                    
                    guard let self = self else { return }
                    
                    // UI values should be accessed on main thread
                    DispatchQueue.main.async {
                        
                        let description = self.descrptionTextView.text ?? ""
                        
                        self.uploadMedia(
                            file: self.attachments,
                            viewController: self,
                            title: "",
                            description: description
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
                            
                            // Don't access UITextView here.
                            // Use the String we already captured.
                            DispatchQueue.main.async {
                                
                                if self.loginAsType == 1 {
                                    self.ActionTaken_api(with: uploadedFiles, concern_type_id: self.selectedConcernListId ?? "", student_id: self.selectedStudentID ?? "", descrptionTextView: description)
                                }else{
                                    self.submit_concern_api(
                                        with: uploadedFiles,
                                        concern_type_id: self.selectedConcernListId ?? "",
                                        raised_to: self.selectedRole,
                                        descrptionTextView: description
                                    )
                                    
                                }
                                
                            }
                        }
                    }
                },
                onNo: {
                    print("Cancelled")
                }
            )
        }

        
    }
    
}
extension addConcernVc : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
            cell.imageViews.tintColor = .clear
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
                cell.imageViews.tintColor = .black
            }
            else if let vido = URL(string: item.VimeoVideoURL ?? ""){
                let iconName = getFileIconName(for: vido)
                cell.imageViews.image = UIImage(named: iconName)
            }
            else{
                cell.imageViews.image = nil
            }
            // Set collection view height dynamically
            let totalItems = attachments.count
            collectionViewHeght.constant = totalItems <= 2 ? 120 : collectionView.collectionViewLayout.collectionViewContentSize.height
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (selectImgPdfview.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from
        return CGSize(width: width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let remaining = Filecount.SelectImageAndDocumetCount - attachments.count
            if remaining > 0 {
                let alertController = UIAlertController(title: AlertstringFile.Select.translated(), message: AlertstringFile.Choose_file_type.translated(), preferredStyle: .actionSheet)
                let cameraAction = UIAlertAction(title: CommonStringFile.Camera, style: .default) { [self] _ in
                    openCamera()
                }
                alertController.addAction(cameraAction)
                let galleryAction = UIAlertAction(title: CommonStringFile.Photos, style: .default) { [self] _ in
                    selectImages()
                }
                alertController.addAction(galleryAction)
                let pdfAction = UIAlertAction(title: CommonStringFile.Document, style: .default) { [self] _ in
                    selectDocuments()
                }
                alertController.addAction(pdfAction)
//                let VideoAction = UIAlertAction(title:
//                                                    CommonStringFile.Video, style: .default) { [self] _ in
//                    let totalRemaining = Filecount.SelectImageAndDocumetCount - attachments.count
//                    let videoCount = attachments.filter { $0.fileType.lowercased() == "video" }.count
//                    let videoRemaining = Filecount.SelectVideoCount - videoCount
//                    if totalRemaining <= 0 {
//                        CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
//                    } else if videoRemaining <= 0 {
//                        CustomAlert()
//                            .showAlert(
//                                title: "",
//                                message: CommonStringFile.You_can_only_select_up_to2_video_files,
//                                on: self)
//                    }else{
//                        VideoPick()
//                    }
//                }
//                alertController.addAction(VideoAction)
                // Cancel action
                let cancelAction = UIAlertAction(
                    title: CommonStringFile.Cancel,
                    style: .cancel,
                    handler: nil
                )
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
            }else{
                CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            }
            
        }else{
            
            let attachment = attachments[indexPath.item - 1]
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.attachment = attachments
            imageVC.subjectName = MenuStringFile.selectedMenuName
            imageVC.scrollIndex = indexPath
            imageVC.index = indexPath.row - 1
            imageVC.type = attachment.fileType
            imageVC.modalPresentationStyle = .fullScreen
            present(imageVC, animated: true)
        }
    }
    
    @IBAction func catagoryTapped() {
        dropDown.anchorView = concernDropdownView
        dropDown.dataSource = dropDownList
        dropDown.show()
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y: concernDropdownView.bounds.height)
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            selectConcerTypeLbl.text = item
            selectedConcernListId = dropDownData?.filter{$0.name == item}.first?.id
        }
    }
    func get_CatagoryListApi() {
        APIService.shared.makeApi(url: ServiceUrl.admin_api_parent_concern_get_concern_types, parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_child_Details()?.access_token ?? "", isBaseUrl: false) { [weak self] (result: Result<concernRespSuc, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.status ?? false {
                    DispatchQueue.main.async {
                        self.dropDownData = response.data
                        
                        self.selectConcerTypeLbl.text = self.dropDownData?.first?.name ?? ""
                        
                        self.selectedConcernListId = self.dropDownData?.first?.id
                        for i in self.dropDownData ?? [] {
                            self.dropDownList.append(i.name ?? "")
                        }
                        
                    
                       
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                }
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
    
    func submit_concern_api(with uploadedFiles: [[String: String]],concern_type_id:String,raised_to:String, descrptionTextView:String) {
        
       
        APIService.shared.makeApi(url: ServiceUrl.admin_api_parent_concern_raise_concern, parameters: ["concern_type_id": concern_type_id  ,"raised_to":raised_to,"description" : descrptionTextView,"file_path":uploadedFiles], type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_child_Details()?.access_token ?? "", isBaseUrl: true) { [weak self] (result: Result<CommonApiSuc, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.status ?? false {
                    DispatchQueue.main.async {
                        
                        CustomAlert.showAlertWithOkAction(
                            title: AlertstringFile.Success,
                            message: response.message ?? "",
                            on: self
                        ) {self.dismiss(animated: true) }
                    }
                    
                }
                else{
                    
                    DispatchQueue.main.async {
                        
                        CustomAlert.showAlertWithOkAction(
                            title: AlertstringFile.Oops,
                            message: response.message ?? "",
                            on: self
                        ) {self.dismiss(animated: true) }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                    CustomAlert.showAlertWithOkAction(
                        title: AlertstringFile.Oops,
                        message: error.localizedDescription ,
                        on: self
                    ) {self.dismiss(animated: true) }
                }
            }
        }
        
    }
    
 
    
    func ActionTaken_api(with uploadedFiles: [[String: String]],concern_type_id:String,student_id:String, descrptionTextView:String) {
        
        APIService.shared.makeApi(url: ServiceUrl.admin_api_parent_concern_action_taken, parameters: ["concern_id": concern_type_id  ,"action":"action_taken","action_taken" : descrptionTextView,"action_file_path":uploadedFiles,"student_id":student_id], type: ApitTypeSringFile.PUT, token:  UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: true) { [weak self] (result: Result<CommonApiSuc, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.status ?? false {
                    DispatchQueue.main.async {
                        
                        CustomAlert.showAlertWithOkAction(
                            title: AlertstringFile.Success,
                            message: response.message ?? "",
                            on: self
                        ) {self.dismiss(animated: true) }
                    }
                    
                }
                else{
                    
                    DispatchQueue.main.async {
                        
                        CustomAlert.showAlertWithOkAction(
                            title: AlertstringFile.Oops,
                            message: response.message ?? "",
                            on: self
                        ) {self.dismiss(animated: true) }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                    CustomAlert.showAlertWithOkAction(
                        title: AlertstringFile.Oops,
                        message: error.localizedDescription ,
                        on: self
                    ) {self.dismiss(animated: true) }
                }
            }
        }
        
    }
}
