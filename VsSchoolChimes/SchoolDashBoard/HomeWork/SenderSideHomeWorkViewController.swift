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
import AVFoundation
import AVKit

@available(iOS 14.0, *)
class SenderSideHomeWorkViewController: UIViewController, DeleteImge, SelectNotice, UITextFieldDelegate {
    func didTapButton(title: String, content: String, items: [FilePath],editId:String) {
        print("sdhbh")
    }
    func deleteImage(index: Int) {
        attachments.remove(at: index)
        uploadAttachmentView.imageCollectionview.reloadData()
    }
    
    @IBOutlet weak var headerView: UIStackView!
    @IBOutlet weak var BackBtnNm: UIButton!
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
    var selectedVideoURL: URL?
    var editId : String?
    var selectNotice: EditObjectDelegate?
    var EditHomeWork = Homework()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackBtnNm
            .configureAsBackButton(
                firstLine: "Create New " + MenuStringFile.selectedMenuName,
                secondLine: staffDetails?.school_name ?? ""

            )
        
        
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        DetailsTxtview.applyRightTxt()
        TitleTxtfield.applyRightTxt()
        wordsCountLbl.applyRightTxt()
        NotificationCenter.default.addObserver( self,selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification,object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),name: UIResponder.keyboardWillHideNotification, object: nil)
        TitleTxtfield.addDoneButton()
        DetailsTxtview.addDoneButton()
        StyleAndTranslater()
        uploadAttachmentView.imageCollectionview.delegate = self
        uploadAttachmentView.imageCollectionview.dataSource = self
        uploadAttachmentView.imageCollectionview.backgroundColor = .clear
        DetailsTxtview.delegate = self
        TitleTxtfield.delegate = self
        VideoView.isHidden = true
        ComposeHomeworkView.isHidden = false
        ComposeHomeworkView.alpha = 1
        imageSelection()
        
        if editId != "" {
            BackBtnNm
                .configureAsBackButton(
                    firstLine: "Update Existing " + MenuStringFile.selectedMenuName,
                    secondLine: staffDetails?.school_name ?? ""
                )
            
            setSelectedHomeWork(
                title:EditHomeWork.title ?? "",
                content:EditHomeWork.description ?? "",
                imageUrls:EditHomeWork.file_path ?? [] ,
                editId:EditHomeWork.id ?? ""
            )
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @IBAction func backBtnAct(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
    
    func setSelectedHomeWork(
        title:String,
        content:String,
        imageUrls:[FilePath],
        editId:String
    ){
        DetailsTxtview.text = content
        DetailsTxtview.textColor = content != "" ? .black:.lightGray
        TitleTxtfield.text = title
        self.editId = editId
        RecipientBtn.setTitle("UPDATE", for: .normal)
        let imageItems: [AttachmentItem] = imageUrls.map { file in
            let type = file.type?.lowercased() ?? ""
            return AttachmentItem(
                image: nil,
                imageURL: type != "video" ? file.url : nil,
                fileType: type,
                VideoURl: type == "video" ? URL(string: file.url ?? "") : nil
            )
        }
        attachments = imageItems
        
        
        
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
    
    
    
    
    
    func imageSelection(){
        
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            
            attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            attachments.append(contentsOf: imageItems)
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onFilePicked = { [self] data in
            // handle picked PDF
            user_inputs.selectedFileType = CommonStringFile.pdf
            attachments.append(AttachmentItem(image:nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf))
            uploadAttachmentView.imageCollectionview.reloadData()
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
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        
        
    }
    
    
    @available(iOS 15.0, *)
    @IBAction func RecipentBtnAct(_ sender: Any) {
        if TitleTxtfield.text != ""  && DetailsTxtview.text != "" && DetailsTxtview.text != CommonStringFile.Description{
            user_inputs.SelectedUrls = attachments
            user_inputs.VideoPath = selectedVideoURL
            var params: [String: Any] = [
                assignmentResquestStringKey.title: TitleTxtfield.text ?? "",
                assignmentResquestStringKey.description: DetailsTxtview.text ?? "",
            ]
            
            if (sender as AnyObject).titleLabel.text == "UPDATE"{
                
                let com = commonApi_forSending()
                params[SendAttachmentStringFile.id] = editId
                com.SendingAttachmentFlow(
                    selectedAcadimicYearId: 0,
                    edit: true,
                    target_type:0,
                    selectedId: [],
                    baseURL: ServiceUrl.comm_api_homework_update,
                    subjectId: "",
                    message:"",
                    from: self,
                    Common_request_params: params
                ) { response in
                    DispatchQueue.main.async {
                        CircularProgressLoader.shared.hide()
                        CustomAlert.showAlertWithOkAction(
                            title: AlertstringFile.Success,
                            message: response.message,
                            on: self
                        ) { [self] in
                            print("success")
                            editId = nil
                            RecipientBtn.setTitle("Next", for: .normal)
                            TitleTxtfield.text = ""
                            DetailsTxtview.text = ""
                            attachments.removeAll()
                            uploadAttachmentView.imageCollectionview.reloadData()
                            dismiss(animated: true)
                        }
                    }
                }
                
            }else{
                let vc = RecipientVc(nibName: nil, bundle: nil)
                vc.ScreenType = Menu_id.homeWorkMenuId
                vc.Common_request_params = params
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
            
            
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
        
        PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
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
            CustomAlert().showAlert(title: "", message: "", on: self)
        } else {
            // Ensure both limits respected
            let pickLimit = min(totalRemaining, videoRemaining)
            PhotoPickerManager.shared.limiSelection = pickLimit
            PhotoPickerManager.shared.presentPicker(ofType: .video, from: self)
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
            } else if let vido = item.VideoURl{
                let iconName = getFileIconName(for: vido)
                cell.imageViews.image = UIImage(named: iconName)
                
            }
            else if let vido = URL(string: item.VimeoVideoURL ?? ""){
                let iconName = getFileIconName(for: vido)
                cell.imageViews.image = UIImage(named: iconName)
                
            }
            else{
                cell.imageViews.image = nil
            }
            
            let totalItems = attachments.count
            collectionViewHeight.constant = totalItems <= 2 ? 120 : collectionView.collectionViewLayout.collectionViewContentSize.height
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (uploadAttachmentView.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let remaining = Filecount.SelectImageAndDocumetCount - attachments.count
            
            if remaining > 0 {
                
                let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
                
                // Camera option
                let cameraAction = UIAlertAction(title: CommonStringFile.Camera, style: .default) { [self] _ in
                    //
                    openCamera()
                }
                alertController.addAction(cameraAction)
                
                // Gallery option
                let galleryAction = UIAlertAction(title: CommonStringFile.Photos, style: .default) { [self] _ in
                    selectImages()
                    //
                }
                alertController.addAction(galleryAction)
                
                //             PDF option
                let pdfAction = UIAlertAction(title: CommonStringFile.Document, style: .default) { [self] _ in
                    selectDocuments()
                }
                alertController.addAction(pdfAction)
                
                //   VIDEO option
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
                                on: self
                            )
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
            imageVC.subjectName = "HomeWork"
            imageVC.scrollIndex = indexPath
            imageVC.index = indexPath.row - 1
            imageVC.type = attachment.fileType
            imageVC.modalPresentationStyle = .fullScreen
            present(imageVC, animated: true)
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
        
        //        if newText.count <= 500 {
        //            wordsCountLbl.text = "\(newText.count) / 500" // Update the character count label
        return true // Allow the change
        //        } else {
        //            let alert = CustomAlert()
        //            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        //            return false // Reject the change
        //        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Current text
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        //        if newText.count <= 50 {
        //            titleCountLbl.text = "\(newText.count) / 50" // Update count label
        return true
        //        } else {
        //            let alert = CustomAlert()
        //            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        //            return false
        //        }
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
    var fileType: String
    var VideoURl : URL?// "image", "pdf", etc.
    var VimeoVideoURL : String?
    var displayName : String?
}
