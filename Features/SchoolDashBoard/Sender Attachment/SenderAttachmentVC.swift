//
//  SenderAttachmentVC.swift
//  VsSchoolChimes
//
//  Created by Lakshmanan on 17/04/25.
//

import UIKit
//import DropDown
import AVFoundation
import AVKit
import QuickLook

@available(iOS 14.0, *)
class SenderAttachmentVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate,UIDocumentPickerDelegate, DeleteImge{
    
    func deleteImage(index: Int) {
        attachments.remove(at: index)
        
        selectImgPdfview.imageCollectionview.reloadData()
    }
    
    
    @IBOutlet weak var menuTitleLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var PopupView: UIView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var TextviewHeight: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var AddAttachmentsLbl: UILabel!
    @IBOutlet weak var letterscountLbl: UILabel!
    @IBOutlet weak var DescriptionLbl: UILabel!
    
    @IBOutlet weak var titleLbl: LocalizationLabel!
    @IBOutlet weak var addphotosheight: NSLayoutConstraint!
    @IBOutlet weak var AssignmenttypeLbl: UILabel!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var assignTitleTxtFld: UITextField!
    @IBOutlet weak var chooseRecipientsBtn: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var selectImgPdfview: ImageSelection!
    @IBOutlet weak var AssignmentTypeview: UIView!
    @IBOutlet weak var VideoView: UIView!
    @IBOutlet weak var AddAtachmentStack: UIStackView!
    @IBOutlet weak var AttachmentIcon: UIImageView!
    @IBOutlet weak var TitleLettersCount: UILabel!
    @IBOutlet weak var AttachmentDropdownHeight: NSLayoutConstraint!
    
    let TypeDropDown = DropDown()
    let initialHeight: CGFloat = 60
    let maxHeight: CGFloat = 300
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    var playerurl: URL?
    var isImage = false
    var selectedImgUrl: [FilePath] = []
    var VideoPath_URL : URL?
    var DocumentpreviewURL : URL?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var alert = CustomAlert()
    var attachments: [AttachmentItem] = []
    var videoPicker: VideoPickerManager?
    var selectedVideoURL: URL?
    var placeholderLabel: UILabel?
    var editId : String?
    var Editattachment =  Attachment()
    var tourKey = "senderAttachment"
    override func viewDidLoad() {
        super.viewDidLoad()
        StyleAndTranslater()
       
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        setupPlaceholder()
        assignTitleTxtFld.addDoneButton()
        contentTextView.addDoneButton()
       
        contentTextView.delegate = self
        assignTitleTxtFld.delegate = self
        
        let typeGesture = UITapGestureRecognizer(target: self, action: #selector(typeDropdown))
        AssignmentTypeview.addGestureRecognizer(typeGesture)
        selectImgPdfview.imageCollectionview.delegate = self
        selectImgPdfview.imageCollectionview.dataSource = self
        selectImgPdfview.imageCollectionview.backgroundColor = .clear
        imageSelection()
        menuTitleLbl.setFont(style: .header, size: FontSize.HeaderSize)
        menuTitleLbl.text = MenuStringFile.selectedMenuName
        chooseRecipientsBtn.setTitle(CommonStringFile.NEXT.translated(), for: .normal)
        if let id = editId,id != ""{
            menuTitleLbl.text = MenuStringFile.Update_Existing + MenuStringFile.selectedMenuName
            setSelectedHomeWork(
                title:  Editattachment.title ?? "",
                content: Editattachment.description ?? "",
                imageUrls: Editattachment.file_path ?? [],
                editId: Editattachment.id ?? ""
            )
        }
    }
    
    @IBAction func backBtnAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func setSelectedHomeWork(
        title:String,
        content:String,
        imageUrls:[FilePath],
        editId:String
    ){
        placeholderLabel?.isHidden = true
        contentTextView.text = content
        contentTextView.textColor = content != "" ? .black:.lightGray
        assignTitleTxtFld.text = title
        self.editId = editId
        chooseRecipientsBtn.setTitle(CommonStringFile.UPDATE.translated(), for: .normal)
        let imageItems: [AttachmentItem] = imageUrls.map { file in
            let type = file.type?.lowercased() ?? ""
            return AttachmentItem(
                image: nil,
                imageURL: type != "video" ? file.url : nil,
                fileType: type,
                VideoURl: type == "video" ? URL(string: file.url ?? "") : nil)}
        attachments = imageItems
        updateTextViewHeight(contentTextView)
        attachments.removeAll()
        attachments.append(contentsOf: imageItems)
        selectImgPdfview.imageCollectionview.reloadData()
    }
    deinit {// Remove observers
        NotificationCenter.default.removeObserver(self)
    }
    
    func  StyleAndTranslater(){
        AttachmentDropdownHeight.constant = 0
        AssignmentTypeview.isHidden = true
        TextviewHeight.constant = initialHeight
        //MARK: UI Update
        VideoView.isHidden = true
        VideoView.layer.cornerRadius = 10
        selectImgPdfview.layer.cornerRadius = 10
        contentTextView.layer.cornerRadius = 10
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.gray.cgColor
        chooseRecipientsBtn.backgroundColor = UIColor.backGroundClr
        chooseRecipientsBtn.layer.cornerRadius = 10
        AssignmentTypeview.layer.cornerRadius = 10
        AssignmentTypeview.layer.borderWidth = 1
        AssignmentTypeview.layer.borderColor = UIColor.lightGray.cgColor
        AssignmentTypeview.backgroundColor = .white
        //MARK: Button Font Style
        chooseRecipientsBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        BackBtn.setTitleFont(style: .primary, size: FontSize.TitleSize)
        //MARK: Label Font Style
        AddAttachmentsLbl.setRequiredText(CommonStringFile.Add_attachment)
        titleLbl.setRequiredText(CommonStringFile.Title)
        DescriptionLbl.setRequiredText(CommonStringFile.Description)
        letterscountLbl.setFont(style: .body, size: FontSize.BodySize)
        TitleLettersCount.setFont(style: .body, size: FontSize.BodySize)
        AssignmenttypeLbl.setFont(style: .title, size: FontSize.TitleSize)
        assignTitleTxtFld.placeholder = CommonStringFile.Title.translated()
    }
    
    @IBAction func viewHistory(_ sender: UIButton) {
        let vc = AttachHistroyVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
    
    @IBAction func backVc() {
        dismiss(animated: true)
    }
    
    @IBAction func chooseRecipientsAction(_ sender: UIButton) {
        guard let textFieldText = assignTitleTxtFld.text, !textFieldText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let textViewText = contentTextView.text, !textViewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alert.showAlert(title: "", message: AlertstringFile.enter_title_description, on: self)
            return}
        if attachments.isEmpty && selectedVideoURL == nil {
            alert.showAlert(title: "", message: AlertstringFile.Please_Add_Attachment, on: self)
        }else {
            user_inputs.SelectedUrls = attachments
            user_inputs.VideoPath = selectedVideoURL
            var params: [String: Any] = [
                SendAttachmentStringFile.title: textFieldText,
                SendAttachmentStringFile.description: textViewText
            ]
            if let editId = editId,!editId.isEmpty{
                let com = commonApi_forSending()
                params[SendAttachmentStringFile.id] = editId
                com.SendingAttachmentFlow(
                    selectedAcadimicYearId: 0,
                    edit: true,
                    target_type:0,
                    selectedId: [],
                    baseURL: ServiceUrl.comm_api_attachment_update,
                    subjectId: "",
                    message:"",
                    from: self,
                    Common_request_params: params, isBaseUrl: true
                ) { response in
                    DispatchQueue.main.async {
                        CircularProgressLoader.shared.hide()
                        CustomAlert.showAlertWithOkAction(
                            title: AlertstringFile.Success,
                            message: response.message,
                            on: self
                        ) { [self] in
                            attachments.removeAll()
                            assignTitleTxtFld.text = ""
                            contentTextView.text = ""
                            dismiss(animated: true)
                        }
                    }
                }
            }else{
                if isStaff(){
                    let vc = SchoolListVC(nibName: nil, bundle: nil)
                    vc.Common_request_params = params
                    vc.modalPresentationStyle = .fullScreen
                    vc.screen_type = Menu_id.AttachmentMenuId
                    present(vc, animated: true)
                } else{
                    let vc = RecipientVc(nibName: nil, bundle: nil)
                    vc.Common_request_params = params
                    vc.ScreenType = Menu_id.AttachmentMenuId
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
            }
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
            return false}
    }
    
    @IBAction  func typeDropdown (){
        TypeDropDown.dataSource = [AttachmentTypeString.IMAGE, AttachmentTypeString.DOCUMENT,AttachmentTypeString.VIDEO]
        self.view.layoutIfNeeded()
        TypeDropDown.width = AssignmentTypeview.bounds.width
        TypeDropDown.bottomOffset = CGPoint(x: 0, y: AssignmentTypeview.bounds.height - 220)
        TypeDropDown.direction = .bottom
        TypeDropDown.show()
        TypeDropDown.selectionAction = { [self] (index: Int, item: String) in
            if item == AttachmentTypeString.VIDEO{
                self.isImage = false
                self.VideoView.isHidden = false
                self.AddAtachmentStack.isHidden = false
                self.selectImgPdfview.isHidden = true
                self.AddAttachmentsLbl.text = CommonStringFile.AddVideo.translated()
                self.AttachmentIcon.image = UIImage(systemName: "video.badge.plus.fill")
                user_inputs.selectedFileType = AttachmentTypeString.VIDEO
                self.attachments.removeAll()
            }
            else if item == AttachmentTypeString.DOCUMENT{
                self.isImage = false
                self.VideoView.isHidden = true
                self.AddAtachmentStack.isHidden = false
                self.selectImgPdfview.isHidden = false
                self.AddAttachmentsLbl.text = CommonStringFile.AddDocuments.translated()
                self.AttachmentIcon.image = UIImage(systemName: "document.badge.plus.fill")
                user_inputs.selectedFileType = AttachmentTypeString.DOCUMENT
                self.attachments.removeAll()
                self.VideoPath_URL = nil
                self.selectImgPdfview.imageCollectionview.reloadData()
            }
            else{
                if user_inputs.selectedFileType != AttachmentTypeString.IMAGE {
                    self.attachments.removeAll()
                }
                self.isImage = true
                self.VideoView.isHidden = true
                self.AddAtachmentStack.isHidden = false
                self.selectImgPdfview.isHidden = false
                self.AddAttachmentsLbl.text = CommonStringFile.AddPhotos.translated()
                self.AttachmentIcon.image = UIImage(systemName: "camera.fill")
                user_inputs.selectedFileType = AttachmentTypeString.IMAGE
                self.VideoPath_URL = nil
                self.selectImgPdfview.imageCollectionview.reloadData()
            }
            if let label = self.AssignmentTypeview.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self.AssignmenttypeLbl.text = item
            }
        }
    }
    
}


@available(iOS 14.0, *)
extension SenderAttachmentVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,QLPreviewControllerDataSource{
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
                let VideoAction = UIAlertAction(title:
                                                    CommonStringFile.Video, style: .default) { [self] _ in
                    let totalRemaining = Filecount.SelectImageAndDocumetCount - attachments.count
                    let videoCount = attachments.filter { $0.fileType.lowercased() == "video" }.count
                    let videoRemaining = Filecount.SelectVideoCount - videoCount
                    if totalRemaining <= 0 {
                        CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
                    } else if videoRemaining <= 0 {
                        CustomAlert()
                            .showAlert(
                                title: "",
                                message: CommonStringFile.You_can_only_select_up_to2_video_files,
                                on: self)
                    }else{
                        VideoPick()
                    }
                }
                alertController.addAction(VideoAction)
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
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        attachments.count == 0 ? 0:1
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
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel?.text = CommonStringFile.Description.translated()
        placeholderLabel?.font = contentTextView.font
        placeholderLabel?.textColor = .lightGray
        placeholderLabel?.positionAsPlaceholder(in: contentTextView)
        contentTextView.addSubview(placeholderLabel!)
        placeholderLabel?.isHidden = !contentTextView.text.isEmpty // Hide if text. exists
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel?.isHidden = !contentTextView.text.isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel?.isHidden = !contentTextView.text.isEmpty
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        return true // Allow the change
        updateTextViewHeight(textView)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight+30, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            scrollToView(contentTextView)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel?.isHidden = !contentTextView.text.isEmpty
        let size = textView.contentSize
        if size.height > initialHeight {
            let newHeight = min(size.height, maxHeight)
            TextviewHeight.constant = newHeight
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        scrollToView(textView)
    }
    func updateTextViewHeight(_ textView: UITextView) {
        let size = textView.contentSize
        let newHeight = max(60, min(size.height, maxHeight)) // Min = 60, Max = maxHeight
        TextviewHeight.constant = newHeight
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()}
    }
    func scrollToView(_ view: UIView) {
        let rect = view.convert(view.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
}
