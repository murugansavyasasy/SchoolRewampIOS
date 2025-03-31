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

@available(iOS 14.0, *)
class SenderNoticeBoardVC: UIViewController,UIDocumentPickerDelegate, DeleteImge, Datepicker {
    
    func date(date: String) {
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yy"
            let DayDate = dateFormatter.date(from: date)!
            // Change to output format
            dateFormatter.dateFormat = "EEE dd"
            let outputDateString = dateFormatter.string(from: DayDate)
            
            if dateSelection == true{
                fromdateBtn.setTitle(date, for: .normal)
                setFormattedDate(outputDateString, label: fromDateLbl)

            }else{
                todateBtn.setTitle(date, for: .normal)
                setFormattedDate(outputDateString, label: toDateLbl)
            }
        }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var HeadingLabel: UILabel!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var setTitle: UILabel!
    @IBOutlet weak var enterDetails: UILabel!
    @IBOutlet weak var outerTxt: UIView!
    @IBOutlet weak var contentCount: UILabel!
    @IBOutlet weak var calanderBtn: HalfColorButton!
    @IBOutlet weak var calanderBtn2: HalfColorButton!
    @IBOutlet weak var fromdateBtn: UIButton!
    @IBOutlet weak var todateBtn: UIButton!
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var costomView: ImageSelection!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var addPhotoLbl: UILabel!
    @IBOutlet weak var createDateLbl: UILabel!
    @IBOutlet weak var toDate: UILabel!
    @IBOutlet weak var fromDate: UILabel!
    @IBOutlet weak var eventTxt: UITextField!
    
    let photoPickManager = PhotoPickerManager.shared
    var selectedImages: [UIImage] = []
    var convertedImagesUrlArray = NSMutableArray()
    var dateSelection = false
    var imageUrlArray = NSMutableArray()
    var pdfData : Data? = nil
    var placeholderLabel: UILabel!
    var doneButton: UIButton!
    var datePicker: UIDatePicker!
    var activeButton: UIButton?
    var Title = ""
    var desript = ""
    var url : URL?
    let dateFormatter = DateFormatter()
    var initialHeight : CGFloat = 60
    var maxHeight : CGFloat = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StyleAndTranslater()
        setInitialDate()
        setupPlaceholder()
        eventTxt.addDoneButton()
        textview.addDoneButton()
        imageSelection()
        costomView.imageCollectionview.delegate = self
        costomView.imageCollectionview.dataSource = self
        
        textview.delegate = self
        eventTxt.delegate = self
        
        let collection = UINib(nibName: CellConfingName.ImageCvCell, bundle: nil)
        costomView.imageCollectionview.register(collection, forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
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
    override func viewWillAppear(_ animated: Bool) {
        if desript != ""{
            textview.text = desript
            placeholderLabel.isHidden = !Title.isEmpty
            contentCount.text = "\(textview.text.count) of 500"
        }
        if Title != ""{
            eventTxt.text =  Title
            
        }
    }
    func imageSelection(){
        photoPickManager.onImagePicked = { [weak self] images in
            guard let self = self else { return }
            // Handle selected images here
            if url != nil{
                selectedImages.removeAll()
                url = nil
            }
            selectedImages.append(contentsOf: images)
            
            print("selectedImage", selectedImages)
         /*   let images = images*/ // Array of images
            let presignedURLs = ["https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/2024-12-24/6063/file%3A///private/var/mobile/Containers/Data/Application/00E089B8-D267-441E-AAD4-3E35A102A925/tmp/vc_-5851419880403543277.png?Content-Type=image&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIA2NK3YMVHFMO66GYP%2F20241224%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Date=20241224T072154Z&X-Amz-Expires=90&X-Amz-Signature=786c9921f6135bf05cfd40390a3d62b43972895f224ac83c26dee7de1effce6a&X-Amz-SignedHeaders=host"] // Corresponding presigned URLs

            photoPickManager.getImageURLUsingPresignedURL(images: images, presignedURLs: presignedURLs) { uploadedURLs in
                print("Uploaded image URLs: \(uploadedURLs)")
            }

            
            //            for image in images {
            //                print("Selected image: \(image)")
//                            photoPickManager.uploadAWS(image: image)
            //            }
            
            
            
            costomView.imageCollectionview.reloadData()
            costomView.ActivityIndicator.stopAnimating()
        }
        photoPickManager.pdfUrl = { [weak self] pdfurl in
            guard let self = self else { return }
            selectedImages.removeAll()
            url = pdfurl.absoluteURL
            selectedImages.append(ImageName.pdf!)
//            setAttributedText(for: addPhotoLbl, with: CommonStringFile.AddPdfoptional.translated(), firstString: CommonStringFile.AddPdf.translated(), secondString:CommonStringFile.Optional.translated(), color1: .black, color2: .lightGray)
            //            url = URL(string:pdfurl)
            //            photoPickManager.uploadPDFFileToAWS(pdfData: pdfData ?? Data())
            costomView.imageCollectionview.reloadData()
            costomView.ActivityIndicator.stopAnimating()
        }
        photoPickManager.onCameraImagePicked = { [weak self] images in
            guard let self = self else { return }
            // Handle selected images here
            
            if url != nil{
                selectedImages.removeAll()
                url = nil
            }
            selectedImages.append(images)
            costomView.imageCollectionview.reloadData()
            costomView.ActivityIndicator.stopAnimating()
        }
        
        
        
        
    }
    
    //MARK: Setting Current Date as initial Date
    func setInitialDate() {
    
        dateFormatter.dateFormat = "EEE d MMM yyyy"
        let currentDate = Date() // Current date and time
        
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
        contentCount.applyRightTxt()
        eventTxt.applyRightTxt()
        textview.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !textview.text.isEmpty // Hide if text exists
    }
    
    func StyleAndTranslater(){
        
        //MARK: UI Changes
        outerTxt.layer.cornerRadius = 10
        outerTxt.layer.borderWidth = 0.5
        outerTxt.layer.borderColor = UIColor.black.cgColor
        
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        
        calanderBtn.layer.borderWidth = 1 // Border width
        calanderBtn.layer.borderColor = UIColor.gray.cgColor // Border color
        calanderBtn2.layer.borderWidth = 1 // Border width
        calanderBtn2.layer.borderColor = UIColor.gray.cgColor // Border color
        
        //MARK: Label Font
        HeadingLabel.setFont(style: .header, size: FontSize.HeaderSize)
        toDate.setFont(style: .body, size: FontSize.BodySize)
        toDate.setFont(style: .body, size: FontSize.BodySize)
        createDateLbl.setFont(style: .body, size: FontSize.BodySize)
        addPhotoLbl.setFont(style: .body, size: FontSize.BodySize)
        enterDetails.setFont(style: .body, size: FontSize.BodySize)
        setTitle.setFont(style: .body, size: FontSize.BodySize)
        todateBtn.setTitleFont(style: .body, size: 12)
        fromdateBtn.setTitleFont(style: .body, size: 12)
        
        //MARK: Translate
        HeadingLabel.text =  MenuTapbar.ComposeNotifications.translated()
        addPhotoLbl.text = CommonStringFile.UploadImagepdf.translated()
        setTitle.text = CommonStringFile.EventTitle.translated()
        eventTxt.placeholder = CommonStringFile.Title.translated()
        enterDetails.text = CommonStringFile.EventDetails.translated()
        setAttributedText(for: addPhotoLbl, with: CommonStringFile.UploadImagepdfoptional.translated(), firstString: CommonStringFile.UploadImagepdf.translated(), secondString:CommonStringFile.Optional.translated(), color1: .black, color2: .lightGray)
    }
    
    func setAttributedText(for label: UILabel, with text: String, firstString: String, secondString: String, color1: UIColor, color2: UIColor) {
        print(text)
        print(firstString)
        print(secondString)
        guard text.contains(firstString), text.contains(secondString) else { return } // Ensure both substrings exist in the text
        
        // Find ranges of the substrings
        let firstRange = (text as NSString).range(of: firstString)
        let secondRange = (text as NSString).range(of: secondString)
        
        // Create a mutable attributed string
        let attributedString = NSMutableAttributedString(string: text)
        
        // Apply colors to the respective ranges
        attributedString.addAttribute(.foregroundColor, value: color1, range: firstRange)
        attributedString.addAttribute(.foregroundColor, value: color2, range: secondRange)
        
        // Set the attributed string to the label
        label.attributedText = attributedString
    }
    
    
    @IBAction func SubmitAction(_ sender: Any) {
        
//        let vc = SelectRecipientVC(nibName: nil, bundle: nil)
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
        
        
        let detailViewController = SelectRecipientVC()
        let nav = UINavigationController(rootViewController: detailViewController)
        
        // 1 - Set modal presentation style
        nav.modalPresentationStyle = .pageSheet
        
        // 2 - Configure bottom sheet
        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom { _ in 470 }, .large()]
                } else {
                    // Fallback on earlier versions
                }
                sheet.prefersGrabberVisible = false // Hide grabber
                sheet.largestUndimmedDetentIdentifier = .large // REMOVE BACKGROUND DIMMING
            }
        } else {
            // Fallback on earlier versions
        }
        
        // 3 - Prevent dismiss on swipe down
        nav.isModalInPresentation = true
        
        // 4 - Present the bottom sheet
        present(nav, animated: true)
        
    }
    
    @IBAction func fromDate(_ sender: UIButton) {
        //showTimePicker(for: sender, date: true)
        dateSelection = true
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func toDate(_ sender: UIButton) {
       // showTimePicker(for: sender, date: false)
        dateSelection = false
        let vc = DatePickerVC(nibName: nil, bundle: nil)
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
    
    
    @IBAction func BackClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func next(_ sender: UIButton) {
        
//        let detailViewController = SelectRecipientVC()
//        let nav = UINavigationController(rootViewController: detailViewController)
//        
//        // 1 - Set modal presentation style
//        nav.modalPresentationStyle = .pageSheet
//        
//        // 2 - Configure bottom sheet
//        if #available(iOS 15.0, *) {
//            if let sheet = nav.sheetPresentationController {
//                if #available(iOS 16.0, *) {
//                    sheet.detents = [.custom { _ in 470 }, .large()]
//                } else {
//                    // Fallback on earlier versions
//                }
//                sheet.prefersGrabberVisible = false // Hide grabber
//                sheet.largestUndimmedDetentIdentifier = .large // REMOVE BACKGROUND DIMMING
//            }
//        } else {
//            // Fallback on earlier versions
//        }
//        
//        // 3 - Prevent dismiss on swipe down
//        nav.isModalInPresentation = true
//        
//        // 4 - Present the bottom sheet
//        present(nav, animated: true)
        
        
        let vc = SchoolListVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.screen_type = screenType.is_noticeboard
        present(vc, animated: true)
        
    }
    
    
    // MARK: File Attachments Actions
    
    func selectImages() {
        
        if selectedImages.count != 5{
            costomView.ActivityIndicator.startAnimating()
            photoPickManager.presentPhotoPicker(from: self, selectionLimit: 5 - selectedImages.count )
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
        
    }
    func openCamera(){
        if selectedImages.count != 5{
            costomView.ActivityIndicator.startAnimating()
            photoPickManager.openCamera(from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    func selectPDF() {
        costomView.ActivityIndicator.startAnimating()
        photoPickManager.pickPDF(from: self)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        costomView.imageCollectionview.reloadData()
    }
    
}

//MARK: Collectionview Delegate Functions
@available(iOS 14.0, *)
extension SenderNoticeBoardVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let cell = costomView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.AttachmentCVCell, for: indexPath) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        }else{
            let cell = costomView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
            cell.delegate = self
            cell.deleteBtn.tag = indexPath.item - 1
            if selectedImages.count > indexPath.item - 1 {
                // Assign the image starting from the second image in the selectedImages array
                cell.imageViews.image = selectedImages[indexPath.item - 1]
            } else {
                cell.imageViews.image = nil
            }
            if selectedImages.count <= 2{
                collectionViewHeght.constant = 120
            }else{
                collectionViewHeght.constant = 220
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (costomView.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from total width, then divide by 3
        
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
            let pdfAction = UIAlertAction(title: AlertstringFile.PDF, style: .default) { [self] _ in
                
                selectPDF()
            }
            alertController.addAction(pdfAction)
            let cancelAction = UIAlertAction(title:AlertstringFile.Cancel, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            if selectedImages.count > indexPath.item - 1 {
                let vc = PreviewImageVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                vc.selectedFileURL = url
                vc.img = selectedImages[indexPath.item - 1]
                present(vc, animated: true)
            }
            
        }
        
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            
            controller.dismiss(animated: true, completion: nil)
            
        }
        
        
    }
    
}

//MARK: Textview and TextField Delegate Functions
@available(iOS 14.0, *)
extension SenderNoticeBoardVC : UITextFieldDelegate,UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textview.text.isEmpty == true{
            textview.text = CommonStringFile.Description.translated()
            textview.textColor = .lightGray
        }
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
            contentCount.text = "\(updatedText.count) of 500" // Update the character count label
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
