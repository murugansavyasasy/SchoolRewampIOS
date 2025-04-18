//
//  SenderSideHomeWorkViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/15/24.
//

import UIKit
import DropDown
import Kingfisher

@available(iOS 14.0, *)
class SenderSideHomeWorkViewController: UIViewController, DeleteImge, SelectNotice {
    func didTapButton(title: String, content: String, items: [FilePath]) {
        print("sdhbh")
    }
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
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
    @IBOutlet weak var uploadattachmentLbl: UILabel!
    @IBOutlet weak var uploadAttachmentView: ImageSelection!
    @IBOutlet weak var RecipientBtn: UIButton!
    @IBOutlet weak var TextViewheight: NSLayoutConstraint!
    var selectedImages: [UIImage] = []
    var selectedImgUrl: [FilePath] = []
    var url : URL?
    let photoPickManager = PhotoPickerManager.shared
    let Img = ImageName()
    let formatter = DateFormatter()
    var image = "image/pdf"
    var delegate : HistorySelectDelegate?
    let customdate = DateFormatter()
    let initialHeight: CGFloat = 60
    let maxHeight: CGFloat = 300
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let  staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    override func viewDidLoad() {
        super.viewDidLoad()
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
        DetailsTxtview.delegate = self

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
        selectedImgUrl = imageUrls
        wordsCountLbl.text = "\(content.count) of 500"
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
        let customdatestring = customdate.string(from: Date())

        RecipientBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Label Font Style
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        DetailsLbl.setFont(style: .title, size: FontSize.TitleSize)
        wordsCountLbl.setFont(style: .body, size: FontSize.BodySize)
        uploadattachmentLbl.setFont(style: .title, size: FontSize.TitleSize)
        
    }
    


    func imageSelection(){
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            if url != nil{
                selectedImages.removeAll()
                url = nil
            }
            selectedImages.append(image)
            user_inputs.selectedFileType = "IMAGE"
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            if url != nil{
                selectedImages.removeAll()
                url = nil
            }
            user_inputs.selectedFileType = "IMAGE"
            selectedImages.append(contentsOf: images)
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onPdfPicked = { [self] data in
            // handle picked PDF
            selectedImages.removeAll()
            url = data.absoluteURL
            user_inputs.selectedFileType = "pdf"
            selectedImages.append(ImageName.pdf!)
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        
    }
    
    

    @available(iOS 15.0, *)
    @IBAction func RecipentBtnAct(_ sender: Any) {
        if TitleTxtfield.text != ""  && DetailsTxtview.text != ""{
            user_inputs.title = TitleTxtfield.text ?? ""
            user_inputs.description = DetailsTxtview.text ?? ""
            user_inputs.selectedImg = selectedImages
            
            
            if isStaff(){
                let vc = SchoolListVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                vc.screen_type = Menu_id.homeWorkMenuId
                present(vc, animated: true)
            }else{
                let vc = RecipientVc(nibName: nil, bundle: nil)
                vc.ScreenType = Menu_id.homeWorkMenuId
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
        }else{
            
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

    @available(iOS 15.0, *)
    func uploadSelectedImages() {
        guard !selectedImages.isEmpty else { return }
        
        var uploadedImageURLs: [String] = []
        let total = selectedImages.count
        var completed = 0
        
        DispatchQueue.main.async {
            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)
        }
        
        for image in selectedImages {
            AWSUploadManager.shared
                .uploadFileToAWS(
                    file: image,
                    bucketPath: "uploads/images/",
                    bucketName: "schoolchimes-communication"
                ) { url in
                if let url = url {
                    uploadedImageURLs.append(url)
                }
                
                completed += 1
                let progress = (Double(completed) / Double(total)) * 100
                
                DispatchQueue.main.async {
                    CircularProgressLoader.shared.updateProgress(to: progress)
                    print(progress)
                    if completed == total {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            CircularProgressLoader.shared.hide()
                            print("✅ Uploads finished: \(uploadedImageURLs)")
                        }
                    }
                }
            }
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
        if selectedImages.count != 5{
            PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: 5 - selectedImages.count - selectedImgUrl.count), from: self)
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
        
    }
    func openCamera(){
        let count = selectedImages.count - selectedImgUrl.count
        if count != 5{
            PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    func selectPDF() {
        PhotoPickerManager.shared.presentPicker(ofType: .pdf, from: self)
        
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
        
        return 1 + selectedImages.count + selectedImgUrl.count
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
            
            cell.delegate = self
            cell.deleteBtn.tag = indexPath.item - 1
            
            let adjustedIndex = indexPath.item - 1
            
            // First show local selectedImages, then fallback to selectedImgUrl if index goes beyond
            if adjustedIndex < selectedImages.count {
                cell.imageViews.image = selectedImages[adjustedIndex]
            } else {
                let urlIndex = adjustedIndex - selectedImages.count
                if urlIndex < selectedImgUrl.count {
                    let urlString = selectedImgUrl[urlIndex].path ?? ""
                    if let url = URL(string: urlString) {
                        cell.imageViews.kf.setImage(with: url)
                    } else {
                        cell.imageViews.image = nil
                    }
                }
            }
            
            // Set collection view height dynamically
            let totalItems = selectedImages.count + selectedImgUrl.count
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
                //
                selectImages()
                //
            }
            alertController.addAction(galleryAction)
            
            //             PDF option
            let pdfAction = UIAlertAction(title: "PDF".translated(), style: .default) { [self] _ in
                
                selectPDF()
            }
            alertController.addAction(pdfAction)
            
            // Cancel action
            let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            // Present the alert
            self.present(alertController, animated: true, completion: nil)
        }else{
            if selectedImages.count > indexPath.item - 1 {
                let vc = PreviewImageVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                vc.selectedFileURL = url
                // Safe unwrapping of imgView before assigning
                vc.img = selectedImages[indexPath.item - 1]
                //
                present(vc, animated: true)
            }
            
        }
        
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            
            controller.dismiss(animated: true, completion: nil)
            
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
            wordsCountLbl.text = "\(newText.count) of 500" // Update the character count label
            return true // Allow the change
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            return false // Reject the change
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


