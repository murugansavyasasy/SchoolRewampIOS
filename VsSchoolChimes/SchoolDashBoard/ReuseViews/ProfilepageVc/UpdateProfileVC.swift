//
//  UpdateProfileVC.swift
//  School Chimes
//
//  Created by Chandhru on 02/09/25.
//

import UIKit
import PhotosUI

@available(iOS 14.0, *)
class UpdateProfileVC: UIViewController {
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var detailTable: UITableView!
    
    var profileSections: [ProfileSection] = []
    var attachments: [AttachmentItem] = []
    let transitionDelegate = TransitioningDelegate()
    var changedParams: [String: Any] = [:]
    var attachmentNode: String?
    var changeProfileImg: UIImage?
    var changeProfileUrl: URL?
    var profileNode: String = "photoPath"
    var isStudent = false
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImg.isUserInteractionEnabled = true

        // 2️⃣ Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        profileImg.addGestureRecognizer(tapGesture)
        setupUI()
        imageSelection()
        setupUserDetails(isStudent: isStudent)
    }
    init(isStudent: Bool = false) {
        self.isStudent = isStudent
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    // MARK: - Image Selection
    private func imageSelection() {
        PhotoPickerManager.shared.onCameraImagePicked = { [weak self] image in
            guard let self = self else { return }
            self.attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            self.attachmentNode = "documents"
            reloadDocumentSection()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [weak self] images in
            guard let self = self else { return }
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            self.attachments.append(contentsOf: imageItems)
            self.attachmentNode = "documents"
            reloadDocumentSection()
        }
        
        PhotoPickerManager.shared.onFilePicked = { [weak self] data in
            guard let self = self else { return }
            user_inputs.selectedFileType = CommonStringFile.pdf
            self.attachments.append(
                AttachmentItem(image: nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf)
            )
            self.attachmentNode = "documents"
            reloadDocumentSection()
        }
    }
    private func reloadDocumentSection() {
        
        if let documentSectionIndex = profileSections.firstIndex(where: { section in
            section.items.contains(where: { $0.node == "documents" })
        }) {
            detailTable.reloadSections(IndexSet(integer: documentSectionIndex), with: .automatic)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupUI() {
        profileImg.layer.cornerRadius = profileImg.frame.width / 2
        profileImg.clipsToBounds = true
        profileImg.layer.borderWidth = 1
        profileImg.layer.borderColor = UIColor.white.cgColor
        editBtn.layer.cornerRadius = editBtn.frame.width / 2
        editBtn.clipsToBounds = true
        
        detailTable.register(UINib(nibName: "UserDetailsTVC", bundle: nil), forCellReuseIdentifier: "UserDetailsTVC")
        detailTable.dataSource = self
        detailTable.delegate = self
        detailTable.tableFooterView = UIView()
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupUserDetails(isStudent: Bool) {
        let url = isStudent ? ServiceUrl.admin_api_student_profile_list : ServiceUrl.admin_api_staff_profile_list
        let token = isStudent
        ? UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        : UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
        
        APIService.shared.makeApi(
            url: url,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: token
        ) { [weak self] (result: Result<UserProfileResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status == true,
                       let data = response.data,
                       let firstProfileData = data.first {
                        
                        // Populate profileSections excluding photo section
                        self.profileSections = firstProfileData.getAllSections().filter { $0.title != "Photo" }
                        
                        // Set profile image if available
                        if let photoPathItems = firstProfileData.photoPath,
                           let photoItem = photoPathItems.first,
                           let photoPath = photoItem.value,
                           !photoPath.isEmpty,
                           let imageUrl = URL(string: photoPath) {
                            self.profileImg.kf.setImage(with: imageUrl)
                            self.changeProfileUrl = imageUrl
                            self.profileNode = photoItem.node ?? "photoPath"
                        }
                        
                        // Find document section and extract URLs into attachments
                        if let documentSection = self.profileSections.first(where: { section in
                            section.items.contains(where: { $0.node == "documents" })
                        }), let documentItem = documentSection.items.first(where: { $0.node == "documents" }) {
                            
                            if let files = documentItem.options {
                                self.attachments = files.map { urlString in
                                    let url = urlString
                                    let type = urlString.lowercased().hasSuffix(".jpg") || urlString.lowercased().hasSuffix(".png") ? "image" :
                                    urlString.lowercased().hasSuffix(".mp4") || urlString.lowercased().hasSuffix(".mov") ? "video" :
                                    urlString.lowercased().hasSuffix(".pdf") ? "pdf" :
                                    "unknown"
                                    
                                    if type == "image" {
                                        return AttachmentItem(image: nil, imageURL: url, fileType: "image")
                                    } else if type == "video" {
                                        return AttachmentItem(image: UIImage(systemName: "video"), imageURL: url, fileType: "video", VideoURl: URL(string: url))
                                    } else if type == "pdf" {
                                        return AttachmentItem(image: UIImage(systemName: "doc.richtext"), imageURL: url, fileType: "pdf")
                                    } else {
                                        return AttachmentItem(image: nil, imageURL: url, fileType: type)
                                    }
                                }
                            }
                        }
                        
                        // Reload the table view
                        self.detailTable.reloadData()
                        
                    } else {
                        self.showAlert(message: response.message ?? "Failed to load user details")
                    }
                    
                case .failure(let error):
                    print("API Error:", error.localizedDescription)
                    self.showAlert(message: "Failed to load user details")
                }
            }
        }
    }
    
    @objc func addDocs(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Select".translated(),
                                                message: "Choose an option".translated(),
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Camera".translated(), style: .default) { [weak self] _ in
            self?.openCamera()
        })
        alertController.addAction(UIAlertAction(title: "Gallery".translated(), style: .default) { [weak self] _ in
            self?.selectImages()
        })
        alertController.addAction(UIAlertAction(title: "Document".translated(), style: .default) { [weak self] _ in
            self?.selectPDF()
        })
        alertController.addAction(UIAlertAction(title: "Cancel".translated(), style: .cancel))
        
        // iPad support
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alertController, animated: true)
    }
    // MARK: File Attachments Actions
    func selectImages() {
        //        let img = attachments.filter { $0.fileType == CommonStringFile.IMAGE }
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
    func openCamera(){
        //        let img = attachments.filter { $0.fileType == CommonStringFile.IMAGE }
        if attachments.count != 10{
            PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    func selectPDF() {
        //        let pdf = attachments.filter { $0.fileType != CommonStringFile.IMAGE }
        if attachments.count != 10{
            PhotoPickerManager.shared.presentPicker(ofType: .file, from: self)
            PhotoPickerManager.shared.limiSelection = 10 - attachments.count
        }else{
            
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
        
    }
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        let cellFrameInSuperview = tappedImageView.convert(tappedImageView.bounds, to: nil)
        
        let vc = PreviewImageVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = transitionDelegate
        transitionDelegate.originFrame = cellFrameInSuperview
        
        vc.type = "IMAGE"
        if let img = changeProfileImg {
            vc.img = img
        } else {
            vc.selectedFileURL = changeProfileUrl
        }
        
        present(vc, animated: true)
    }


    @IBAction func changeProfile(_ sender: UIButton) {
        let alert = UIAlertController(title: "Select", message: "Choose an option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.openCameraForProfile()
        })
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { [weak self] _ in
            self?.openGalleryForProfile()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(alert, animated: true)
    }
    
    func openGalleryForProfile() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            showAlert(message: "Photo Library not available")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func openCameraForProfile() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(message: "Camera not available")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = CustomAlert()
        alert.showAlert(title: "", message: message, on: self)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

@available(iOS 14.0, *)
extension UpdateProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Section Count
    func numberOfSections(in tableView: UITableView) -> Int {
        return profileSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = profileSections[section].items
        if section == profileSections.count - 1 && isStudent {
            return items.count + 1
        }
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailsTVC", for: indexPath) as? UserDetailsTVC else {
            return UITableViewCell()
        }
        
        let section = profileSections[indexPath.section]
        let items = section.items
        
        let isLastSection = indexPath.section == profileSections.count - 1
        let isLastRow = indexPath.row == items.count
        cell.addAttachmentBtn.addTarget(self, action: #selector(addDocs(_:)), for: .touchUpInside)
        // Show update button only if it's the last section, last row, and isStudent is true
        if isLastSection && isLastRow && isStudent {
            cell.configure(with: nil, attachments: nil)
            cell.updateBtn.addTarget(self, action: #selector(updateButtonTapped(_:)), for: .touchUpInside)
        } else {
            let item = items[indexPath.row]
            cell.configure(with: item, attachments: attachments)
            cell.onValueChanged = { [weak self] changedKey, value in
                guard let self = self else { return }
                if let value = value {
                    print(changedKey)
                    print(value)
                    if item.node != "documents" { // Corrected from "document" to "documents"
                        if "\(value)" != "\(item.value ?? "")" {
                            self.changedParams[changedKey] = value
                        }
                    }
                }
            }
        }
        return cell
    }
    
    // MARK: Section Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionData = profileSections[section]
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor.systemGroupedBackground
        
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.primery
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = sectionData.title
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    @objc func updateButtonTapped(_ sender: UIButton) {
        let group = DispatchGroup()
        
        // Handle profile image upload if changed
        if let profileImage = changeProfileImg {
            group.enter()
            uploadProfileImage(profileImage) { [weak self] uploadedURL in
                if let self = self, let url = uploadedURL {
                    self.changedParams[self.profileNode] = url
                }
                group.leave()
            }
        }
        
        // Handle attachments upload if present
        if !attachments.isEmpty {
            group.enter()
            uploadMedia(file: attachments) { [weak self] urls, iframe, fileSize, embedUrl in
                if let self = self {
                    let uploadedFiles: [String] = urls.compactMap { urlString in
                        guard let url = URL(string: urlString) else { return nil }
                        return urlString
                    }
                    if let attachmentNode = self.attachmentNode {
                        self.changedParams[attachmentNode] = uploadedFiles
                    }
                }
                group.leave()
            }
        }
        
        // Once all uploads complete, call updateProfile
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.updateProfile(with: self.changedParams)
        }
    }
    
    
    private func uploadProfileImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        AWSUploadManager.shared.uploadFileToAWS(
            file: image,
            bucketPath: "uploads/images/",
            bucketName: "schoolchimes-communication",
            progressHandler: nil
        ) { url in
            completion(url)
        }
    }
    
    private func processAttachmentsAndUpdate() {
        if !attachments.isEmpty {
            uploadMedia(file: attachments) { [weak self] urls, iframe, fileSize, embedUrl in
                guard let self = self else { return }
                let uploadedFiles: [[String: String]] = urls.compactMap { urlString in
                    guard let url = URL(string: urlString) else { return nil }
                    
                    let fileType = url.pathExtension.lowercased()
                    let type = fileType == CommonStringFile.jpg ? CommonStringFile.IMAGE : url.pathExtension.uppercased()
                    
                    return [
                        CommonStringFile.url: urlString,
                        CommonStringFile.type: type
                    ]
                }
                
                if let attachmentNode = self.attachmentNode {
                    self.changedParams[attachmentNode] = uploadedFiles
                }
                
                self.updateProfile(with: self.changedParams)
            }
        } else {
            updateProfile(with: changedParams)
        }
    }
    
    func updateProfile(with parameters: [String: Any]) {
        guard !parameters.isEmpty else {
            showAlert(message: "No changes to update")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            APIService.shared.makeApi(
                url: ServiceUrl.admin_api_student_profile_pre_submission,
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
                            if response.status {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print("❌ API error: \(error.localizedDescription)")
                        self.showAlert(message: "Failed to update profile. Please try again.")
                    }
                }
            }
        }
    }
    
    // MARK: - Upload Media (Images + Video)
    private func uploadMedia(
        file: Any,
        completion: @escaping (_ urls: [String], _ iframeHTML: String?, _ fileSize: Int?, _ embedUrl: String?) -> Void
    ) {
        var uploadedURLs: [String] = []
        var completed = 0
        
        func updateAndCheckCompletion(total: Int, iframe: String? = nil, size: Int? = nil, embed: String? = nil) {
            let progress = (Double(completed) / Double(total)) * 100
            CircularProgressLoader.shared.updateProgress(to: progress)
            if completed == total {
                CircularProgressLoader.shared.hide()
                completion(uploadedURLs, iframe, size, embed)
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
                    // Upload local image to AWS
                    AWSUploadManager.shared.uploadFileToAWS(
                        file: image,
                        bucketPath: "uploads/images/",
                        bucketName: "schoolchimes-communication",
                        progressHandler: nil
                    ) { url in
                        if let uploadedURL = url {
                            uploadedURLs.append(uploadedURL)
                        }
                        completed += 1
                        updateAndCheckCompletion(total: total)
                    }
                } else if let fileURLStr = item.imageURL {
                    if fileURLStr.lowercased().hasPrefix("http") {
                        // Already an uploaded file (skip upload)
                        uploadedURLs.append(fileURLStr)
                        completed += 1
                        updateAndCheckCompletion(total: total)
                    } else if let fileURL = URL(string: fileURLStr) {
                        let path = item.fileType.lowercased() != CommonStringFile.IMAGE ? "uploads/Documents/" : "uploads/images/"
                        AWSUploadManager.shared.uploadFileToAWS(
                            file: fileURL,
                            bucketPath: path,
                            bucketName: "schoolchimes-communication",
                            progressHandler: nil
                        ) { url in
                            if let uploadedURL = url {
                                uploadedURLs.append(uploadedURL)
                            }
                            completed += 1
                            updateAndCheckCompletion(total: total)
                        }
                    } else {
                        print("❌ Invalid fileURL: \(fileURLStr)")
                        completed += 1
                        updateAndCheckCompletion(total: total)
                    }
                }
            }
            
        default:
            print("❌ Unsupported file type")
            completion([], nil, nil, nil)
        }
    }
}

// MARK: - UIImagePickerController Delegate
@available(iOS 14.0, *)
extension UpdateProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            profileImg.image = image
            changeProfileImg = image // Store the changed image
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

