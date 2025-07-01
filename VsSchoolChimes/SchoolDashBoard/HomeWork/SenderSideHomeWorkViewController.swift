//
//  SenderSideHomeWorkViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/15/24.
//

import UIKit
import DropDown
import Kingfisher
import PDFKit

@available(iOS 14.0, *)
class SenderSideHomeWorkViewController: UIViewController, DeleteImge, SelectNotice, VideoPickerManagerDelegate, UITextFieldDelegate {
    func didTapButton(title: String, content: String, items: [FilePath]) {
        print("sdhbh")
    }
    func deleteImage(index: Int) {
        attachments.remove(at: index)
        uploadAttachmentView.imageCollectionview.reloadData()
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ToStdOrSecBtnBottom: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var ComposeHomeworkView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var TitleTxtfield: UITextField!
    @IBOutlet weak var DetailsLbl: UILabel!
    @IBOutlet weak var DetailsTxtview: UITextView!
    @IBOutlet weak var wordsCountLbl: UILabel!
    @IBOutlet weak var titleCountLbl: UILabel!
    @IBOutlet weak var uploadattachmentLbl: UILabel!
    @IBOutlet weak var uploadAttachmentView: ImageSelection!
    @IBOutlet weak var RecipientBtn: UIButton!
    @IBOutlet weak var TextViewheight: NSLayoutConstraint!
    
    @IBOutlet weak var VideoDeleteBtn: UIImageView!
    @IBOutlet weak var VideoThumbnailImg: UIImageView!
    @IBOutlet weak var VideoView: UIView!
    var attachments: [AttachmentItem] = []
    let photoPickManager = PhotoPickerManager.shared
    let Img = ImageName()
    let formatter = DateFormatter()
    var image = "image/pdf"
    var delegate : HistorySelectDelegate?
    let customdate = DateFormatter()
    let initialHeight: CGFloat = 60
    let maxHeight: CGFloat = 300
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var alert = CustomAlert()
    var videoPicker: VideoPickerManager?
    var selectedVideoURL: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        videoPicker = VideoPickerManager(presenter: self, delegate: self)
        DetailsTxtview.applyRightTxt()
        TitleTxtfield.applyRightTxt()
        wordsCountLbl.applyRightTxt()
        NotificationCenter.default.addObserver( self,selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification,object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),name: UIResponder.keyboardWillHideNotification, object: nil)
        let VideoDelete = UITapGestureRecognizer(target: self, action: #selector(deleteVideo))
        VideoDeleteBtn.addGestureRecognizer(VideoDelete)
        TitleTxtfield.addDoneButton()
        DetailsTxtview.addDoneButton()
        StyleAndTranslater()
        uploadAttachmentView.imageCollectionview.delegate = self
        uploadAttachmentView.imageCollectionview.dataSource = self
        DetailsTxtview.delegate = self
        TitleTxtfield.delegate = self
        VideoView.isHidden = true
        ComposeHomeworkView.isHidden = false
        ComposeHomeworkView.alpha = 1
        imageSelection()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setSelectedHomeWork(title:String,content:String,imageUrls:[FilePath]){
        DetailsTxtview.text = content
        DetailsTxtview.textColor = content != "" ? .black:.lightGray
        TitleTxtfield.text = title
        let imageItems = imageUrls.map {
            AttachmentItem(image: nil, imageURL: $0.url, fileType:$0.type ?? "")
        }
        let size = DetailsTxtview.sizeThatFits(CGSize(width: DetailsTxtview.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = min(max(size.height, initialHeight), maxHeight)
        TextViewheight.constant = newHeight
        attachments.removeAll()
        attachments.append(contentsOf: imageItems)
        wordsCountLbl.text = "\(content.count) / 500"
        uploadAttachmentView.imageCollectionview.reloadData()
    }
    
    func StyleAndTranslater(){
        
        //MARK: UI Update
        TextViewheight.constant = initialHeight
        DetailsTxtview.layer.cornerRadius = 10
        DetailsTxtview.layer.borderWidth = 1
        DetailsTxtview.layer.borderColor = UIColor.lightGray.cgColor
        RecipientBtn.layer.cornerRadius = 10
        DetailsTxtview.text = CommonStringFile.Description
        DetailsTxtview.textColor = .lightGray
        customdate.dateFormat = "EEE d"
        RecipientBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Label Font Style
        titleLbl.setRequiredText(CommonStringFile.Title)
        DetailsLbl.setRequiredText(CommonStringFile.Description)
        wordsCountLbl.setFont(style: .body, size: FontSize.BodySize)
        titleCountLbl.setFont(style: .body, size: FontSize.BodySize)
        uploadattachmentLbl.setFont(style: .title, size: FontSize.TitleSize)
        setAttributedText(for: uploadattachmentLbl, with: CommonStringFile.Add_attachment_optional.translated(), firstString: CommonStringFile.Add_attachment.translated(), secondString:CommonStringFile.Optional.translated(), color1: .black, color2: .lightGray)
    }
    
    @IBAction func deleteVideo(){
        
        videoPickerManagerDidCloseVideo()
    }
    
    @IBAction func chooseVideoTapped(_ sender: UIButton) {
        videoPicker?.pickVideo()
    }
    
    func pickVideoFromGallery(){
        
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
    
    // MARK: - Delegate Methods
    func videoPickerManager(didPickVideo url: URL) {
        attachments.removeAll()
        uploadAttachmentView.isHidden = true
        collectionViewHeight.constant = 0
        selectedVideoURL = url
        VideoView.isHidden = false
        RecipientBtn.isHidden = false
    }
    
    func videoPickerManager(didGenerateThumbnail image: UIImage) {
        VideoThumbnailImg.isHidden = false
        VideoThumbnailImg.image = image
    }
    
    func videoPickerManagerDidCloseVideo() {
        selectedVideoURL = nil
        VideoThumbnailImg.image = nil
        VideoView.isHidden = true
        //          / chooseRecipientsBtn.isHidden = true
        uploadAttachmentView.isHidden = false
        collectionViewHeight.constant = 120
        uploadAttachmentView.imageCollectionview.reloadData()
        
        
    }
    
    
    func imageSelection(){
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            
            attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            attachments.removeAll { $0.fileType != CommonStringFile.IMAGE }
            
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            attachments.append(contentsOf: imageItems)
            if imageItems.count != 0{
                attachments.removeAll { $0.fileType != CommonStringFile.IMAGE }
            }
            
            //            let selectedImages: [UIImage] = images // Your selected images
            //
            //            if let pdfData = createMultiPagePDF(from: selectedImages) {
            //                previewPDF(data: pdfData, in: uploadAttachmentView)
            //            }
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onFilePicked = { [self] data in
            // handle picked PDF
            user_inputs.selectedFileType = CommonStringFile.pdf
            attachments.append(AttachmentItem(image:nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf))
            attachments.removeAll { $0.fileType == CommonStringFile.IMAGE }
            
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        
    }
    
    
    
    @available(iOS 15.0, *)
    @IBAction func RecipentBtnAct(_ sender: Any) {
        if TitleTxtfield.text != ""  && DetailsTxtview.text != "" && DetailsTxtview.text != CommonStringFile.Description{
            user_inputs.SelectedUrls = attachments
            user_inputs.VideoPath = selectedVideoURL
            let params: [String: Any] = [
                assignmentResquestStringKey.title: TitleTxtfield.text ?? "",
                assignmentResquestStringKey.description: DetailsTxtview.text ?? "",
            ]
            let vc = RecipientVc(nibName: nil, bundle: nil)
            vc.ScreenType = Menu_id.homeWorkMenuId
            vc.Common_request_params = params
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }else{
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
    
    
    
    
    // MARK: Set gradient colours for Button
    func gradientcolours(button : UIButton,colours : [CGColor]) {
        
        button.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        // Create and configure the gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colours
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = button.layer.cornerRadius
        
        // Insert the gradient layer into the button's layer
        button.layer.insertSublayer(gradientLayer, at: 0)
        
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
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
}

@available(iOS 14.0, *)
extension  SenderSideHomeWorkViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
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
            collectionViewHeight.constant = totalItems <= 2 ? 120 : 220
            
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (uploadAttachmentView.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
            //
            // Camera option
            let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { [self] _ in
                //
                openCamera()
            }
            alertController.addAction(cameraAction)
            
            // Gallery option
            let galleryAction = UIAlertAction(title: "Gallery".translated(), style: .default) { [self] _ in
                selectImages()
                //
            }
            alertController.addAction(galleryAction)
            
            //             PDF option
            let pdfAction = UIAlertAction(title: "Document".translated(), style: .default) { [self] _ in
                selectPDF()
            }
            alertController.addAction(pdfAction)
            
            let VideoAction = UIAlertAction(title: "Video", style: .default) { [self] _ in
                
                pickVideoFromGallery()
            }
            alertController.addAction(VideoAction)
            // Cancel action
            let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }else{
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
    
}


@available(iOS 14.0, *)
extension SenderSideHomeWorkViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if DetailsTxtview.text == CommonStringFile.Description {
            DetailsTxtview.text = ""
            DetailsTxtview.textColor = .black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if DetailsTxtview.text == "" {
            DetailsTxtview.text = CommonStringFile.Description
            DetailsTxtview.textColor = .gray
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = min(max(size.height, initialHeight), maxHeight)
        TextViewheight.constant = newHeight
        DetailsTxtview.isScrollEnabled = size.height > maxHeight
        
        // Ensure layout updates
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        // Adjust view position with keyboard
        if DetailsTxtview.isFirstResponder {
            self.adjustForKeyboardHeight()
        }
    }
    
    // Helper to adjust outerView position dynamically
    private func adjustForKeyboardHeight() {
        guard let keyboardFrame = UIResponder.keyboardFrameEndUserInfoKey as? CGRect else { return }
        let availableSpace = self.view.frame.height - keyboardFrame.height
        let textViewBottom = outerView.frame.origin.y + outerView.frame.height
        
        if textViewBottom > availableSpace {
            let overlap = textViewBottom - availableSpace + 20 // Add some padding
            UIView.animate(withDuration: 0.3) {
                self.outerView.transform = CGAffineTransform(translationX: 0, y: -overlap)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Current text in the UITextView
        let currentText = textView.text ?? ""
        
        // Compute the new text length
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if newText.count <= 500 {
            wordsCountLbl.text = "\(newText.count) / 500" // Update the character count label
            return true // Allow the change
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            return false // Reject the change
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Current text
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count <= 50 {
            titleCountLbl.text = "\(newText.count) / 50" // Update count label
            return true
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            return false
        }
    }

    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight+30, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            scrollToView(DetailsTxtview)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Reset the scroll view content inset
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    func scrollToView(_ view: UIView) {
        // Calculate the frame of the view relative to the UIScrollView
        let rect = view.convert(view.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    func createMultiPagePDF(from images: [UIImage]) -> Data? {
        guard !images.isEmpty else { return nil }
        
        let firstImage = images[0]
        let pageRect = CGRect(x: 0, y: 0, width: firstImage.size.width, height: firstImage.size.height)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData { context in
            for image in images {
                context.beginPage()
                image.draw(in: CGRect(origin: .zero, size: image.size))
            }
        }
        
        return data
    }
    
    
    func previewPDF(data: Data, in containerView: UIView) {
        let pdfView = PDFView(frame: containerView.bounds)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.autoScales = true
        pdfView.document = PDFDocument(data: data)
        containerView.addSubview(pdfView)
        
        NSLayoutConstraint.activate([
            pdfView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            pdfView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
}
extension String {
    func boundingHeight(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
        return ceil(boundingBox.height)
    }
}

struct AttachmentItem {
    var image: UIImage?         // for local images
    var imageURL: String?       // for remote
    var fileType: String        // "image", "pdf", etc.
}
