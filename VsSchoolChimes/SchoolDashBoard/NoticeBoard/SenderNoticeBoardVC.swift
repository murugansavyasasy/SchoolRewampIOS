//
//  SenderNoticeBoardVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 18/11/24.
//

import UIKit
import AWSCore
import AWSS3
import SDWebImage
import SwiftUI
import QuickLook

@available(iOS 14.0, *)
class SenderNoticeBoardVC: UIViewController,UIDocumentPickerDelegate, DeleteImge, Datepicker, VideoPickerManagerDelegate, UIPopoverPresentationControllerDelegate {
    
    func date(date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = standardDateFormat
            let DayDate = dateFormatter.date(from: date)!
            // Change to output format
            dateFormatter.dateFormat = "EEE dd"
            let outputDateString = dateFormatter.string(from: DayDate)
            
            if dateSelection == true{
                fromdateBtn.setTitle(date, for: .normal)
                setFormattedDate(outputDateString, label: fromDateLbl)
                NewFromdateLbl.setFormattedDate(from: DayDate)
                // Check if To Date is set and valid
                if let toText = NewToDateLbl.text?.replacingOccurrences(of: "\n", with: " ") {
                    let labelFormatter = DateFormatter()
                    labelFormatter.dateFormat = "d EEE, MMM yyyy" // Matches formatted label

                    if let toDate = labelFormatter.date(from: toText) {
                        if DayDate > toDate {
                            // Auto-adjust To Date if From Date is later
                            NewToDateLbl.setFormattedDate(from: DayDate)
                        }
                    }
                }

            }else{
                todateBtn.setTitle(date, for: .normal)
                setFormattedDate(outputDateString, label: toDateLbl)
                NewToDateLbl.setFormattedDate(from: DayDate)
            }
        }
    
    
    @IBOutlet weak var DisplayRangeLbl: UILabel!
    @IBOutlet weak var ToLbl: UILabel!
    @IBOutlet weak var FromLbl: UILabel!
    @IBOutlet weak var NewToDateLbl: UILabel!
    @IBOutlet weak var NewFromdateLbl: UILabel!
    @IBOutlet weak var TodateTop: UIView!
    @IBOutlet weak var FromDateTop: UIView!
    @IBOutlet weak var ToDateView: UIView!
    @IBOutlet weak var FromDateView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var TittleDefLbl: UILabel!
    @IBOutlet weak var DescriptionDefLbl: UILabel!
    @IBOutlet weak var DescriptionLettersCount: UILabel!
    @IBOutlet weak var calanderBtn: HalfColorButton!
    @IBOutlet weak var calanderBtn2: HalfColorButton!
    @IBOutlet weak var fromdateBtn: UIButton!
    @IBOutlet weak var todateBtn: UIButton!
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var Attachmentview: ImageSelection!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var addPhotoLbl: UILabel!
    @IBOutlet weak var ToTittleDefLbl: UILabel!
    @IBOutlet weak var fromTitleDefLbl: UILabel!
    @IBOutlet weak var TitleTextfield: UITextField!
    @IBOutlet weak var TextfieldCharCountLbl: UILabel!
    @IBOutlet weak var NextBtn: UIButton!
    @IBOutlet weak var PopupView: UIView!
    @IBOutlet weak var VideoView: UIView!
    @IBOutlet weak var VideoThumbnailImg: UIImageView!
    @IBOutlet weak var VideoDeleteBtn: UIImageView!
    
    let photoPickManager = PhotoPickerManager.shared
    var dateSelection = false
    var placeholderLabel: UILabel!
    let dateFormatter = DateFormatter()
    var initialHeight : CGFloat = 60
    var maxHeight : CGFloat = 300
    var attachments: [AttachmentItem] = []
    var alert = CustomAlert()
    var DocumentpreviewURL: URL?
    var videoPicker: VideoPickerManager?
    var selectedVideoURL: URL?
    let standardDateFormat = "dd MMM yyyy"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StyleAndTranslater()
        FromDateView.layer.cornerRadius = 8
        ToDateView.layer.cornerRadius = 8
        FromDateTop.layer.cornerRadius = 8
        TodateTop.layer.cornerRadius = 8
        FromDateTop.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        TodateTop.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        
        DisplayRangeLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        FromLbl.setFont(style: .title, size: FontSize.TitleSize)
        ToLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        FromDateView.layer.cornerRadius = 10
        FromDateView.layer.shadowColor = UIColor.black.cgColor
        FromDateView.layer.shadowOffset = CGSize(width: 0, height: 2)
        FromDateView.layer.shadowRadius = 5
        FromDateView.layer.shadowOpacity = 0.3
        
        ToDateView.layer.cornerRadius = 10
        ToDateView.layer.shadowColor = UIColor.black.cgColor
        ToDateView.layer.shadowOffset = CGSize(width: 0, height: 2)
        ToDateView.layer.shadowRadius = 5
        ToDateView.layer.shadowOpacity = 0.3
        
        let DateGesture = UITapGestureRecognizer(target: self, action: #selector(fromDate))
        FromDateView.addGestureRecognizer(DateGesture)
        
        let ToDateGesture = UITapGestureRecognizer(target: self, action: #selector(toDate))
        ToDateView.addGestureRecognizer(ToDateGesture)
        
        setInitialDate()
        setupPlaceholder()
        TitleTextfield.addDoneButton()
        textview.addDoneButton()
        imageSelection()
        Attachmentview.imageCollectionview.delegate = self
        Attachmentview.imageCollectionview.dataSource = self
        
        textview.delegate = self
        TitleTextfield.delegate = self
        
        videoPicker = VideoPickerManager(presenter: self, delegate: self)
        
        VideoView.isHidden = true
        
        let VideoDelete = UITapGestureRecognizer(target: self, action: #selector(deleteVideo))
        VideoDeleteBtn.addGestureRecognizer(VideoDelete)
        
        let collection = UINib(nibName: CellConfingName.ImageCvCell, bundle: nil)
        Attachmentview.imageCollectionview.register(collection, forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
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
    }
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    func imageSelection(){
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            
            attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            attachments.removeAll { $0.fileType == CommonStringFile.pdf }
            selectedVideoURL = nil

            user_inputs.selectedFileType = CommonStringFile.IMAGE
            Attachmentview.imageCollectionview.reloadData()
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
            Attachmentview.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onFilePicked = { [self] data in
            // handle picked PDF
            user_inputs.selectedFileType = CommonStringFile.pdf
            attachments.append(AttachmentItem(image:nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf))
            attachments.removeAll { $0.fileType == CommonStringFile.IMAGE }
            selectedVideoURL = nil
            Attachmentview.imageCollectionview.reloadData()
        }
    }
    
    @IBAction func deleteVideo(){
        
        videoPickerManagerDidCloseVideo()
    }
    
    func pickVideoFromGallery(){
        
        videoPicker?.pickVideo()
    }
    
    @IBAction func playVideoTapped(_ sender: UIButton) {
        if let url = selectedVideoURL {
            videoPicker?.playVideo(from: url, in: VideoView)
        } else {
            videoPicker?.pickVideo()
        }
    }
    
    // MARK: - Delegate Methods
    func videoPickerManager(didPickVideo url: URL) {
        attachments.removeAll()
        Attachmentview.isHidden = true
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
        //          / chooseRecipientsBtn.isHidden = true
        Attachmentview.isHidden = false
        collectionViewHeght.constant = 120
        Attachmentview.imageCollectionview.reloadData()
    }
    
    //MARK: Setting Current Date as initial Date
    func setInitialDate() {
    
        
        let currentDate = Date() // Current date and time
        dateFormatter.dateFormat = standardDateFormat
        
        NewFromdateLbl.setFormattedDate(from: currentDate)
        NewToDateLbl.setFormattedDate(from: currentDate)
        
        let formattedDate = dateFormatter.string(from: currentDate)
        fromdateBtn.setTitle(formattedDate, for: .normal)
        todateBtn.setTitle(formattedDate, for: .normal)
        
        dateFormatter.dateFormat = "EEE d"
        let customDate = dateFormatter.string(from: currentDate)
        
        setFormattedDate(customDate, label: fromDateLbl)
        setFormattedDate(customDate, label: toDateLbl)
    }
    
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.Description.translated()
        placeholderLabel.font = textview.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8) // Adjust padding
        textview.applyRightTxt()
        textview.applyRightTxt(with: placeholderLabel)
        DescriptionLettersCount.applyRightTxt()
        TitleTextfield.applyRightTxt()
        textview.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !textview.text.isEmpty // Hide if text exists
    }
    
    func StyleAndTranslater(){
        
        //MARK: UI Changes
        PopupView.layer.cornerRadius = 10
        PopupView.layer.shadowColor = UIColor.black.cgColor
        PopupView.layer.shadowOffset = CGSize(width: 0, height: 2)
        PopupView.layer.shadowRadius = 5
        PopupView.layer.shadowOpacity = 0.3
        
        calanderBtn.layer.borderWidth = 1 // Border width
        calanderBtn.layer.borderColor = UIColor.gray.cgColor // Border color
        calanderBtn2.layer.borderWidth = 1 // Border width
        calanderBtn2.layer.borderColor = UIColor.gray.cgColor // Border color
        
        textview.layer.cornerRadius = 10
        textview.layer.borderWidth = 1
        textview.layer.borderColor = UIColor.gray.cgColor
        
        NextBtn.layer.cornerRadius = 10
        
        //MARK: Label Font
        ToTittleDefLbl.setFont(style: .body, size: FontSize.BodySize)
        fromTitleDefLbl.setFont(style: .body, size: FontSize.BodySize)
        addPhotoLbl.setFont(style: .body, size: FontSize.BodySize)
        ToTittleDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        fromTitleDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        todateBtn.setTitleFont(style: .body, size: 12)
        fromdateBtn.setTitleFont(style: .body, size: 12)
        DescriptionLettersCount.setFont(style: .body, size: FontSize.BodySize)
        TextfieldCharCountLbl.setFont(style: .body, size: FontSize.BodySize)
        NextBtn.setTitleFont(style: .body, size: FontSize.TitleSize)
        
        //MARK: Translate
        
        TittleDefLbl.setRequiredText(CommonStringFile.Title.translated())
        DescriptionDefLbl.setRequiredText(CommonStringFile.Description.translated())
        addPhotoLbl.text = CommonStringFile.Add_attachment_optional.translated()
        TitleTextfield.placeholder = CommonStringFile.Title.translated()
        setAttributedText(for: addPhotoLbl, with: CommonStringFile.Add_attachment_optional.translated(), firstString: CommonStringFile.Add_attachment.translated(), secondString:CommonStringFile.Optional.translated(), color1: .black, color2: .lightGray)
    }

    
    @IBAction func fromDate(_ sender: Any) {
        //showTimePicker(for: sender, date: true)
        dateSelection = true
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.minimumDate = Date()
        dateFormatter.dateFormat = "dd MMM yyyy"
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
        
    }
    
    @IBAction func toDate(_ sender: Any) {
        
            dateSelection = false
            let vc = DatePickerVC(nibName: nil, bundle: nil)
            dateFormatter.dateFormat = "dd MMM yyyy"

            // Set minimum to fromDate
            if let fromDateString = fromdateBtn.titleLabel?.text,
               let fromDate = dateFormatter.date(from: fromDateString) {
                vc.minimumDate = fromDate
            } else {
                vc.minimumDate = Date()
            }

            vc.dateSelection = 2
            vc.delegate = self
            vc.modalPresentationStyle = .overCurrentContext
            vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.present(vc, animated: false)
    }
    
    func setFormattedDate(_ date: String, label: UILabel) {
           let weekdayFont = UIFont.systemFont(ofSize: 12) // Smaller font for weekday
           let dayFont = UIFont.boldSystemFont(ofSize: 22)  // Larger font for day number
           
           // Function to create an attributed string from a given date
           func createAttributedText(from date: String) -> NSMutableAttributedString {
               let components = date.split(separator: " ")
               guard components.count > 1 else {
                   print("Error: Invalid date format")
                   return NSMutableAttributedString()
               }
               
               let day = components[0]
               let month = components[1]
               
               let attributedText = NSMutableAttributedString()
               attributedText.append(NSAttributedString(string: "\(day)\n", attributes: [
                   .font: weekdayFont,
                   .foregroundColor: UIColor.darkGray
               ]))
               attributedText.append(NSAttributedString(string: "\(month)", attributes: [
                   .font: dayFont,
                   .foregroundColor: UIColor.black
               ]))
               
               // Set paragraph style for centered alignment
               let paragraphStyle = NSMutableParagraphStyle()
               paragraphStyle.alignment = .center
               attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
               
               return attributedText
           }
           
           // Create attributed text and set to label
           label.attributedText = createAttributedText(from: date)
           label.numberOfLines = 0
       }
    
    
    @IBAction func next(_ sender: UIButton) {
        let school_count = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    
        guard let textFieldText = TitleTextfield.text, !textFieldText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let textViewText = textview.text, !textViewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alert.showAlert(title: "", message: AlertstringFile.enter_title_description, on: self)
                return
            }
            
            user_inputs.title = TitleTextfield.text ?? ""
            user_inputs.description = textview.text
            user_inputs.FromDate = ConvertDateStringSmart(fromdateBtn.titleLabel?.text ?? "")
            user_inputs.ToDate = ConvertDateStringSmart(todateBtn.titleLabel?.text ?? "")
            user_inputs.SelectedUrls = attachments
            user_inputs.VideoPath = selectedVideoURL
            
           
                let vc = SchoolListVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
           
    }
    
    // MARK: File Attachments Actions
    func selectImages() {
        let img = attachments.filter { $0.fileType == CommonStringFile.IMAGE }
        if img.count != 5{
            PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: 5 - img.count), from: self)
            
        }else{
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    func openCamera(){
        let img = attachments.filter { $0.fileType == CommonStringFile.IMAGE }
        if img.count != 5{
            PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        }else{
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    func selectPDF() {
        let pdf = attachments.filter { $0.fileType == CommonStringFile.pdf }
        if pdf.count != 5{
            PhotoPickerManager.shared.presentPicker(ofType: .file, from: self)
            PhotoPickerManager.shared.limiSelection = 5 - pdf.count
        }else{
            
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func deleteImage(index: Int) {
        attachments.remove(at: index)
        Attachmentview.imageCollectionview.reloadData()
    }
    
}

//MARK: Collectionview Delegate Functions
@available(iOS 14.0, *)
extension SenderNoticeBoardVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,QLPreviewControllerDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0{
            
            let cell = Attachmentview.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.AttachmentCVCell, for: indexPath) as! AttachmentCVCell
            
            cell.layer.cornerRadius = 20
            return cell
        }else{
            
            let cell = Attachmentview.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
            
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
            
            collectionViewHeght.constant = attachments.count <= 2 ? 120 : 220
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (Attachmentview.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let alertController = UIAlertController(title: AlertstringFile.Select, message: AlertstringFile.Chooseanoption, preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title:AlertstringFile.Camera, style: .default) { [self] _ in
                openCamera()
            }
            alertController.addAction(cameraAction)
            
            let galleryAction = UIAlertAction(title: AlertstringFile.Gallery, style: .default) { [self] _ in
                selectImages()
            }
            alertController.addAction(galleryAction)
            
            let pdfAction = UIAlertAction(title: AlertstringFile.Document, style: .default) { [self] _ in
                
                selectPDF()
            }
            alertController.addAction(pdfAction)
            
            let VideoAction = UIAlertAction(title: "Video", style: .default) { [self] _ in
                
                pickVideoFromGallery()
            }
            alertController.addAction(VideoAction)
            
            let cancelAction = UIAlertAction(title:AlertstringFile.Cancel, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }else{
        
            if  attachments[indexPath.item - 1].fileType != AttachmentTypeString.IMAGE {
                
                DocumentpreviewURL = URL(string: attachments[indexPath.item-1].imageURL ?? "")
                let previewController = QLPreviewController()
                previewController.dataSource = self
                present(previewController, animated: true, completion: nil)
            }else {
                
                let vc = PreviewImageVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                if let img = attachments[indexPath.item - 1].image {
                    vc.img = attachments[indexPath.item - 1].image
                }else{
                    vc.selectedFileURL = URL(string: attachments[indexPath.item - 1].imageURL ?? "")
                }
                vc.type = user_inputs.selectedFileType
                present(vc, animated: true)
            }
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

//MARK: Textview and TextField Delegate Functions
@available(iOS 14.0, *)
extension SenderNoticeBoardVC : UITextFieldDelegate,UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        
        // Compute the new text after the proposed change
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // If the new text count is within the limit, update the character count label and allow the change
        if updatedText.count <= 50 {
            TextfieldCharCountLbl.text = "\(updatedText.count) of 50"
            return true
        } else {
            // If the limit is exceeded, show an alert and reject the change
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            return false
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty // Toggle visibility
        adjustTextViewHeightWithConstraint(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Calculate the new length of the text
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        if updatedText.count <= 500 {
            DescriptionLettersCount.text = "\(updatedText.count) of 500" // Update the character count label
            return true // Allow the change
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Reach_Your_Limit, on: self)
            //            contentTxtView.isEditable = false // Optionally disable editing
            return false // Reject the change
        }
    }
    
    func adjustTextViewHeightWithConstraint(_ textView: UITextView) {
        let size = textView.contentSize
        
        // Check if the content exceeds the initial height
        if size.height > initialHeight {
            // Update the height constraint based on content size
            let newHeight = min(size.height, maxHeight) // Cap the height to maxTextViewHeight
            textViewHeightConstraint.constant = newHeight
        }
        
        // Animate the change for smoother UI
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        // Scroll to make the UITextView visible
        scrollToView(textView)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            // Adjust the scroll view content inset
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight+30, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            
            // Ensure the UITextView is visible
            scrollToView(textview)
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
