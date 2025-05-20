//
//  SenderAttachmentVC.swift
//  VsSchoolChimes
//
//  Created by Lakshmanan on 17/04/25.
//

import UIKit
import DropDown
import AVFoundation
import AVKit
import QuickLook

@available(iOS 14.0, *)
class SenderAttachmentVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate,UIDocumentPickerDelegate, DeleteImge {
    
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        if fileUrls.count != 0{
            fileUrls.remove(at: index)
        }
    
        selectImgPdfview.imageCollectionview.reloadData()
    }
    
    @IBOutlet weak var PopupView: UIView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var TextviewHeight: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var AddAttachmentsLbl: UILabel!
    @IBOutlet weak var letterscountLbl: UILabel!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addphotosheight: NSLayoutConstraint!
    @IBOutlet weak var AssignmenttypeLbl: UILabel!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var assignTitleTxtFld: UITextField!
    @IBOutlet weak var chooseRecipientsBtn: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var selectImgPdfview: ImageSelection!
    @IBOutlet weak var AssignmentTypeview: UIView!
    @IBOutlet weak var VideoView: UIView!
    @IBOutlet weak var VideoThumbnailImg: UIImageView!
    @IBOutlet weak var VideoPlayBtn: UIButton!
    @IBOutlet weak var ClickTochooseVideoLbl: UILabel!
    @IBOutlet weak var AddAtachmentStack: UIStackView!
    @IBOutlet weak var VideoDeleteBtn: UIImageView!
    @IBOutlet weak var AttachmentIcon: UIImageView!
    @IBOutlet weak var TitleLettersCount: UILabel!
    @IBOutlet weak var AttachmentDropdownHeight: NSLayoutConstraint!
    
    var selectedImages: [UIImage] = []
    let TypeDropDown = DropDown()
    let initialHeight: CGFloat = 60
    let maxHeight: CGFloat = 300
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    var playerurl: URL?
    var isImage = false
    var selectedImgUrl: [FilePath] = []
    var fileUrls = [String]()
    var VideoPath_URL : URL?
    var DocumentpreviewURL : URL?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var alert = CustomAlert()
    let vimeoAccessToken = "8d74d8bf6b5742d39971cc7d3ffbb51a"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StyleAndTranslater()
        BackBtn.applyBackButton()
        
        // Add observers for keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        assignTitleTxtFld.addDoneButton()
        contentTextView.addDoneButton()
        contentTextView.applyRightTxt()
        contentTextView.delegate = self
        assignTitleTxtFld.delegate = self
       
        AssignmenttypeLbl.applyRightTxt()
        DescriptionLbl.applyRightTxt()
        letterscountLbl.applyRightTxt()
        titleLbl.applyRightTxt()
        assignTitleTxtFld.applyRightTxt()
        
        let typeGesture = UITapGestureRecognizer(target: self, action: #selector(typeDropdown))
        AssignmentTypeview.addGestureRecognizer(typeGesture)
        
        let PlayGesture = UITapGestureRecognizer(target: self, action: #selector(ChooseVideoBtnAct))
        VideoView.addGestureRecognizer(PlayGesture)
        
        let DeleteGesture = UITapGestureRecognizer(target: self, action: #selector(closeVideo))
        VideoDeleteBtn.addGestureRecognizer(DeleteGesture)
        VideoDeleteBtn.isUserInteractionEnabled = true
        
        selectImgPdfview.imageCollectionview.delegate = self
        selectImgPdfview.imageCollectionview.dataSource = self
        
        imageSelection()
    }
    
    override func viewDidLayoutSubviews() {
        
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
    }
    
    func  StyleAndTranslater(){
        
        PopupView.layer.cornerRadius = 10
        PopupView.layer.shadowColor = UIColor.black.cgColor
        PopupView.layer.shadowOffset = CGSize(width: 0, height: 2)
        PopupView.layer.shadowRadius = 5
        PopupView.layer.shadowOpacity = 0.3
        
        AttachmentDropdownHeight.constant = 0
        AssignmentTypeview.isHidden = true
        TextviewHeight.constant = initialHeight
        
        //MARK: UI Update
        //AddAtachmentStack.isHidden = true
        VideoView.isHidden = true
        //selectImgPdfview.isHidden = true
        VideoDeleteBtn.isHidden = true

        VideoView.layer.cornerRadius = 10
        AssignmentTypeview.layer.cornerRadius = 10
        selectImgPdfview.layer.cornerRadius = 10
        contentTextView.layer.cornerRadius = 10
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.gray.cgColor
        chooseRecipientsBtn.backgroundColor = .button
        chooseRecipientsBtn.layer.cornerRadius = 10
        AssignmentTypeview.layer.borderWidth = 1
        AssignmentTypeview.layer.borderColor = UIColor.lightGray.cgColor
        AssignmentTypeview.backgroundColor = .white
        contentTextView.text = CommonStringFile.Description.translated()
        contentTextView.textColor = .lightGray
        
        //MARK: Button Font Style
        chooseRecipientsBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        BackBtn.setTitleFont(style: .primary, size: FontSize.TitleSize)
       
        //MARK: Label Font Style
        AddAttachmentsLbl.setFont(style: .title, size: FontSize.TitleSize)
        letterscountLbl.setFont(style: .body, size: FontSize.BodySize)
        TitleLettersCount.setFont(style: .body, size: FontSize.BodySize)
        DescriptionLbl.setFont(style: .title, size: FontSize.TitleSize)
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        AssignmenttypeLbl.setFont(style: .title, size: FontSize.TitleSize)
        ClickTochooseVideoLbl.setFont(style: .title, size: FontSize.TitleSize)
    }
    
    func imageSelection(){
        
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            fileUrls.removeAll()
            VideoPath_URL = nil
            selectedImages.append(image)
            user_inputs.selectedFileType = AttachmentTypeString.IMAGE
            selectImgPdfview.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            fileUrls.removeAll()
            VideoPath_URL = nil
            selectedImages.append(contentsOf: images)
            user_inputs.selectedFileType = AttachmentTypeString.IMAGE
            selectImgPdfview.imageCollectionview.reloadData()
        }

        PhotoPickerManager.shared.onFilePicked = { [self] data in
            
            if user_inputs.selectedFileType == AttachmentTypeString.IMAGE {
                selectedImages.removeAll()
            }
            
            if let fileUrl = URL(string:data.absoluteString){
                VideoPath_URL = nil
                fileUrls.append(data.absoluteString)
                let iconName = getFileIconName(for: fileUrl)
                if let img = UIImage(named: iconName){
                    selectedImages.append(img)
                }
                user_inputs.selectedFileType = AttachmentTypeString.DOCUMENT
            }
            selectImgPdfview.imageCollectionview.reloadData()
        }
    }
    
    // MARK: File Attachments Actions
    func selectImages() {
        if selectedImages.count < 5{
            PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: 5 - selectedImages.count - selectedImgUrl.count), from: self)
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    func openCamera(){
        
        if selectedImages.count < 5{
            PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    func selectDocuments() {
        
        if fileUrls.count < 5{
            PhotoPickerManager.shared.limiSelection = 5 - fileUrls.count
            PhotoPickerManager.shared.presentPicker(ofType: .file, from: self)
           
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
     
    @IBAction func backVc() {
        
        dismiss(animated: true)
    }
    
    @IBAction func chooseRecipientsAction(_ sender: UIButton) {
        
        if user_inputs.selectedFileType == "" {
            
            alert.showAlert(title: "", message: AlertstringFile.Please_Select_Attachment_Type, on: self)
        }else if user_inputs.selectedFileType == AttachmentTypeString.VIDEO && VideoPath_URL == nil {
            
            alert.showAlert(title: "", message: AlertstringFile.Please_Select_a_Video, on: self)
        }else if user_inputs.selectedFileType == AttachmentTypeString.IMAGE && selectedImages.isEmpty {
            
            alert.showAlert(title: "", message: AlertstringFile.Please_Select_a_Image, on: self)
        }else if user_inputs.selectedFileType == AttachmentTypeString.DOCUMENT && fileUrls.isEmpty {
            
            alert.showAlert(title: "", message: AlertstringFile.Please_Select_a_Document, on: self)
        }
        
        if assignTitleTxtFld.text != ""  && contentTextView.text != "" && contentTextView.text != CommonStringFile.Description {
            user_inputs.title = assignTitleTxtFld.text ?? ""
            user_inputs.description = contentTextView.text ?? ""
            user_inputs.selectedImg = selectedImages
            user_inputs.docUrl = fileUrls
            user_inputs.VideoPath = VideoPath_URL
            
            if isStaff(){
                let vc = SchoolListVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                vc.screen_type = Menu_id.AttachmentMenuId
                present(vc, animated: true)
            } else{
                let vc = RecipientVc(nibName: nil, bundle: nil)
                vc.ScreenType = Menu_id.AttachmentMenuId
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
            
        } else{
            
            alert
                .showAlert(
                    title: "",
                    message: AlertstringFile.enter_title_description,
                    on: self)
        }
    }
    
    func isStaff() -> Bool {
        if (staffDetailsCount?.count ?? 0 > 1) {
            if staff_role == PriorityType.is_principal ||
                staff_role == PriorityType.is_grouphead ||
                staff_role == PriorityType.is_admin {
                return true
            } else {
                
                return false
            }
        } else {
            return false
        }
    }
    
    @IBAction  func typeDropdown (){
        TypeDropDown.dataSource = [AttachmentTypeString.IMAGE, AttachmentTypeString.DOCUMENT,AttachmentTypeString.VIDEO]
        self.view.layoutIfNeeded()
        TypeDropDown.width = AssignmentTypeview.bounds.width
        TypeDropDown.bottomOffset = CGPoint(x: 0, y: AssignmentTypeview.bounds.height - 220)
        
        TypeDropDown.direction = .bottom
        TypeDropDown.show()
        TypeDropDown.selectionAction = { [self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            
            print("Images count",self.selectedImages.count)
            print("Document Count",self.fileUrls.count)
            // Update the label inside the UIView
            
            if item == AttachmentTypeString.VIDEO{
                
                self.isImage = false
                self.VideoView.isHidden = false
                self.AddAtachmentStack.isHidden = false
                self.selectImgPdfview.isHidden = true
                self.AddAttachmentsLbl.text = CommonStringFile.AddVideo.translated()
                self.AttachmentIcon.image = UIImage(systemName: "video.badge.plus.fill")
                user_inputs.selectedFileType = AttachmentTypeString.VIDEO
                self.fileUrls.removeAll()
                self.selectedImages.removeAll()
            }
            else if item == AttachmentTypeString.DOCUMENT{
                
                self.isImage = false
                self.VideoView.isHidden = true
                self.AddAtachmentStack.isHidden = false
                self.selectImgPdfview.isHidden = false
                self.AddAttachmentsLbl.text = CommonStringFile.AddDocuments.translated()
                self.AttachmentIcon.image = UIImage(systemName: "document.badge.plus.fill")
                user_inputs.selectedFileType = AttachmentTypeString.DOCUMENT
                self.selectedImages.removeAll()
                self.fileUrls.removeAll()
                self.VideoPath_URL = nil
                self.selectImgPdfview.imageCollectionview.reloadData()
            }
            else{
                
                if user_inputs.selectedFileType != AttachmentTypeString.IMAGE {
                    
                    self.selectedImages.removeAll()
                }
                
                self.isImage = true
                self.VideoView.isHidden = true
                self.AddAtachmentStack.isHidden = false
                self.selectImgPdfview.isHidden = false
                self.AddAttachmentsLbl.text = CommonStringFile.AddPhotos.translated()
                self.AttachmentIcon.image = UIImage(systemName: "camera.fill")
                user_inputs.selectedFileType = AttachmentTypeString.IMAGE
                self.fileUrls.removeAll()
                self.VideoPath_URL = nil
                self.selectImgPdfview.imageCollectionview.reloadData()
            }
            
            if let label = self.AssignmentTypeview.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self.AssignmenttypeLbl.text = item
            }
        }
    }
    
    
    //MARK: Video Picking Process Functions Starts
    @IBAction func ChooseVideoBtnAct(_ sender: Any) {
        if playerurl == nil{
            pickVideoFromGallery()
        }
    }
    
    @IBAction func PlayBtnAct(_ sender: Any) {
        if playerurl != nil{
            playVideo()
        }
        else{
            pickVideoFromGallery()
        }
    }
    
    
    func stopCurrentVideo() {
        player?.pause()
        player = nil
        playerViewController?.view.removeFromSuperview()
        playerViewController = nil
    }
    
    // MARK: This method is pick Video From Gallery
    @IBAction   func pickVideoFromGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.mediaTypes = ["public.movie"] // Only show videos
            imagePickerController.allowsEditing = true // Optional: allows users to edit video
            
            present(imagePickerController, animated: true, completion: nil)
        } else {
            print("Photo library not available.")
        }
    }
    
    // MARK: This method is called when the user has picked a video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            if playerurl != nil{
                stopCurrentVideo()
                playerurl = nil
            }
            
            selectImgPdfview.isHidden = true
            VideoView.isHidden = false
            
            selectedImages.removeAll()
            fileUrls.removeAll()
            user_inputs.selectedFileType = AttachmentTypeString.VIDEO
            
            VideoPath_URL = videoURL
            playerurl = videoURL
            print("Selected video URL: \(videoURL)")
            generateThumbnail(from: playerurl!)
            VideoDeleteBtn.isHidden = false
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: This method is called when the user cancels the picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Function to generate thumbnail from the video URL
    func generateThumbnail(from videoURL: URL){
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            
            VideoThumbnailImg.isHidden = false
            VideoThumbnailImg.layer.cornerRadius = 10
            VideoThumbnailImg.image = UIImage(cgImage: cgImage)
            ClickTochooseVideoLbl.isHidden = true
            VideoPlayBtn.isHidden = false
            VideoPlayBtn.setImage(UIImage(named: "play-button"), for: .normal)
            
        } catch {
            print("Error generating thumbnail: \(error)")
            
        }
    }
    
    @objc func playVideo() {
        VideoPlayBtn.isHidden = true
        VideoThumbnailImg.isHidden = true
        
        if let playerurl = playerurl {
            player = AVPlayer(url: playerurl)
            print("playerurl: \(playerurl)")
            
            playerViewController = AVPlayerViewController()
            playerViewController?.player = player
            playerViewController?.showsPlaybackControls = true
            
            self.addChild(playerViewController!)
            playerViewController?.view.frame = VideoView.bounds
            VideoView.addSubview(playerViewController!.view)
            playerViewController?.didMove(toParent: self)
            playerViewController?.view.layer.cornerRadius = 10
            playerViewController?.view.clipsToBounds = true
            player?.play()
            
            // Create image view as a close button
            let closeImageView = UIImageView()
            closeImageView.image = UIImage(systemName: "xmark.circle.fill") // Or your custom image
            closeImageView.tintColor = .systemRed
            closeImageView.isUserInteractionEnabled = true

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeVideo))
            closeImageView.addGestureRecognizer(tapGesture)

            closeImageView.translatesAutoresizingMaskIntoConstraints = false
            VideoView.addSubview(closeImageView)  // ✅ Added to VideoView, not playerViewController.view

            NSLayoutConstraint.activate([
                closeImageView.topAnchor.constraint(equalTo: VideoView.topAnchor, constant: -14),
                closeImageView.trailingAnchor.constraint(equalTo: VideoView.trailingAnchor, constant: 8),
                closeImageView.widthAnchor.constraint(equalToConstant: 30),
                closeImageView.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
    }

    @objc func closeVideo() {
        
        VideoThumbnailImg.image = nil
        VideoPlayBtn.isHidden = false
        ClickTochooseVideoLbl.isHidden = false
        VideoPlayBtn.setImage(UIImage(named: "Image"), for: .normal)
        VideoDeleteBtn.isHidden = true
        
        player?.pause()
        player = nil
        playerViewController?.view.removeFromSuperview()
        playerViewController = nil
        
        playerurl = nil
        VideoPath_URL = nil
        
        VideoView.isHidden = true
        selectImgPdfview.isHidden = false
        
        selectImgPdfview.imageCollectionview.reloadData()
    }
}


@available(iOS 14.0, *)
extension SenderAttachmentVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,QLPreviewControllerDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + selectedImages.count + selectedImgUrl.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0{
            
            let cell = selectImgPdfview.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.AttachmentCVCell, for: indexPath) as! AttachmentCVCell
            
            cell.layer.cornerRadius = 20
            return cell
        }else{
            
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.ImageCvCell,
                for: indexPath
            ) as! ImageCvCell
            
            cell.delegate = self
            cell.deleteBtn.tag = indexPath.item - 1
            
            let adjustedIndex = indexPath.item - 1
            
            // First show local selectedImages, then fallback to selectedImgUrl if index goes beyond
            if adjustedIndex < selectedImages.count {
                cell.imageViews.image = selectedImages[adjustedIndex]
            } else {
                let urlIndex = adjustedIndex - selectedImages.count
                if urlIndex < selectedImgUrl.count {
                    let urlString = selectedImgUrl[urlIndex].url ?? ""
                    if let url = URL(string: urlString) {
                        cell.imageViews.kf.setImage(with: url)
                    } else {
                        cell.imageViews.image = nil
                    }
                }
            }
            
            // Set collection view height dynamically
            let totalItems = selectedImages.count + selectedImgUrl.count
            collectionViewHeght.constant = totalItems <= 2 ? 120 : 220

            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (selectImgPdfview.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0{
            
            let alertController = UIAlertController(title: AlertstringFile.Select, message:AlertstringFile.Chooseanoption, preferredStyle: .actionSheet)
            
                // Camera option
                let cameraAction = UIAlertAction(title: AlertstringFile.Camera, style: .default) { [self] _ in
                    
                    openCamera()
                }
                alertController.addAction(cameraAction)
                
                // Gallery option
                let galleryAction = UIAlertAction(title: AlertstringFile.Gallery, style: .default) { [self] _ in
                    
                    selectImages()
                }
                alertController.addAction(galleryAction)
                
                let VideoAction = UIAlertAction(title: "Video", style: .default) { [self] _ in
                    
                    pickVideoFromGallery()
                }
                alertController.addAction(VideoAction)
                
                let DocumentAction = UIAlertAction(title: AlertstringFile.Document, style: .default) { [self] _ in
                    
                    selectDocuments()
                }
                alertController.addAction(DocumentAction)
           
            
            // Cancel action
            let cancelAction = UIAlertAction(title: AlertstringFile.Cancel, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            // Present the alert
            self.present(alertController, animated: true, completion: nil)
        }else{
            
            if user_inputs.selectedFileType == AttachmentTypeString.DOCUMENT {
                
                DocumentpreviewURL = URL(string: fileUrls[indexPath.item-1])
                
                let previewController = QLPreviewController()
                previewController.dataSource = self
                present(previewController, animated: true, completion: nil)
            }else {
                
                let vc = PreviewImageVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                vc.img = selectedImages[indexPath.item - 1]
                vc.type = user_inputs.selectedFileType
                present(vc, animated: true)
            }
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
       
        fileUrls.count == 0 ? 0:1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        if let Url = DocumentpreviewURL {
            
            return Url as QLPreviewItem
        }
        
        return NSURL(fileURLWithPath: "")
    }
}

@available(iOS 14.0, *)
extension SenderAttachmentVC : UITextViewDelegate,UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        
        // Compute the new text after the proposed change
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // If the new text count is within the limit, update the character count label and allow the change
        if updatedText.count <= 50 {
            TitleLettersCount.text = "\(updatedText.count) of 50"
            return true
        } else {
            // If the limit is exceeded, show an alert and reject the change
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            return false
        }
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTextView.text == CommonStringFile.Description.translated() {
            
            contentTextView.text = ""
            contentTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextView.text == "" {
            
            contentTextView.text = CommonStringFile.Description
            contentTextView.textColor = .lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Current text in the UITextView
        let currentText = textView.text ?? ""
        
        // Compute the new text length
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if newText.count <= 500 {
            letterscountLbl.text = "\(newText.count) of 500" // Update the character count label
            return true // Allow the change
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            //contentTxtView.isEditable = false // Optionally disable editing
            return false // Reject the change
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            // Adjust the scroll view content inset
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight+30, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            
            // Ensure the UITextView is visible
            scrollToView(contentTextView)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Reset the scroll view content inset
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    // UITextViewDelegate Method: Adjust the height of the UITextView dynamically
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.contentSize
        
        // Check if the content exceeds the initial height
        if size.height > initialHeight {
            // Update the height constraint based on content size
            let newHeight = min(size.height, maxHeight) // Cap the height to maxTextViewHeight
            TextviewHeight.constant = newHeight
            // Execute function when text exceeds boundary
            executeFunctionWhenTextExceeds()
        }
        
        // Animate the change for smoother UI
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        // Scroll to make the UITextView visible
        scrollToView(textView)
    }
    
    // Helper Method: Scroll to a specific view inside the UIScrollView
    func scrollToView(_ view: UIView) {
        // Calculate the frame of the view relative to the UIScrollView
        let rect = view.convert(view.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    // The function you want to execute when the text exceeds the boundary
    func executeFunctionWhenTextExceeds() {
        // Your custom logic here, e.g., log a message, trigger an event, etc.
        print("TextView content has exceeded the initial height.")
    }
    
}
