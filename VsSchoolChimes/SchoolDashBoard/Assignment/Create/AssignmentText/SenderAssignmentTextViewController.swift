//
//  SenderAssignmentTextViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/19/24.
//

import UIKit
import DropDown
import AWSCore
import AWSS3

@available(iOS 14.0, *)
class SenderAssignmentTextViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate,UIDocumentPickerDelegate, DeleteImge, Datepicker {
    
    func date(date: String) {
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yy"
            let DayDate = dateFormatter.date(from: date)!
            // Change to output format
            dateFormatter.dateFormat = "EEE dd"
            let outputDateString = dateFormatter.string(from: DayDate)
            
           DateBtn.setTitle(date, for: .normal)
           setFormattedDate(outputDateString, label: CustomDateLbl)

        }
    
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        selectImgPdfview.imageCollectionview.reloadData()
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var TextviewHeight: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var CustomDateLbl: UILabel!
    @IBOutlet weak var customizedDateBtn: HalfColorButton!
    @IBOutlet weak var DateBtn: UIButton!
    @IBOutlet weak var AddphotosLbl: UILabel!
    @IBOutlet weak var SubmissionDateLbl: UILabel!
    @IBOutlet weak var letterscountLbl: UILabel!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var HeaderLbl: UILabel!
    @IBOutlet weak var addphotosheight: NSLayoutConstraint!
    @IBOutlet weak var CreateView: UIView!
    @IBOutlet weak var AssignmenttypeLbl: UILabel!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var categoryDropDownLbl: UILabel!
    @IBOutlet weak var assignTitleTxtFld: UITextField!
    @IBOutlet weak var chooseRecipientsBtn: UIButton!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var categoryDropDownView: UIView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var selectImgPdfview: ImageSelection!
    @IBOutlet weak var AssignmentTypeview: UIView!
    
    var selectedShow = ""
    var selectedImages: [UIImage] = []
    var getType = "Principal"
    var imageStr : [String] = []
    var currentImageCount = 0
    var schoolListArr = ["Sales","Vss","SSS","SSS2020"]
    var totalImageCount = 0
    var originalImagesArray = [UIImage]()
    var imageUrlArray = NSMutableArray()
    var  getImagePdfType : String!
    var convertedImagesUrlArray = NSMutableArray()
    let photoPickManager = PhotoPickerManager.shared
    let dropDown = DropDown()
    let TypeDropDown = DropDown()
    var datePicker : UIDatePicker!
    var doneButton : UIButton!
    var pdfData: Data?
    let customdate = DateFormatter()
    let formatter = DateFormatter()
    let initialHeight: CGFloat = 60
    let maxHeight: CGFloat = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StyleAndTranslater()
       
        
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
        
        keyboardDonebtn()
        contentTextView.delegate = self
        
        customdate.dateFormat = "EEE d"
        let customdatestring = customdate.string(from: Date())
        setFormattedDate(customdatestring, label: CustomDateLbl)
        
        formatter.dateFormat = "EEE d MMM yyyy"
        let dateBtntitle = formatter.string(from: Date())
        DateBtn.setTitle(dateBtntitle, for: .normal)
        
        let categoryGesture = UITapGestureRecognizer(target: self, action: #selector(categoryDropdown))
        categoryDropDownView.addGestureRecognizer(categoryGesture)
        
        let typeGesture = UITapGestureRecognizer(target: self, action: #selector(typeDropdown))
        AssignmentTypeview.addGestureRecognizer(typeGesture)
        
        selectImgPdfview.imageCollectionview.delegate = self
        selectImgPdfview.imageCollectionview.dataSource = self
        
        //        MARK: Gallery Image
        photoPickManager.onImagePicked = { [weak self] images in
            guard let self = self else { return }
            // Handle selected images here
            selectedImages.append(contentsOf: images)
            for image in images {
                print("Selected image: \(image)")
                //                collectionView.isHidden = false
                //                collectionView.delegate = self
                //                collectionView.dataSource = self
                //                photoPickManager.uploadAWS(image: image)
                
                selectImgPdfview.imageCollectionview.reloadData()
            }
        }
        
        //MARK: Camera Image
        photoPickManager.onCameraImagePicked = { [weak self] images in
            guard let self = self else { return }
            
            selectedImages.append(images)
            //            for image in images {
            print("Selected image: \(images)")
            //                collectionView.isHidden = false
            //                collectionView.delegate = self
            //                collectionView.dataSource = self
            photoPickManager.uploadAWS(image: images)
            //            }
        }
        
        //        MARK: PDF
        photoPickManager.onPdfPicked = { [weak self] pdf in
            print("Selectedpdf12 \(pdf)")
            self!.photoPickManager.uploadPDFFileToAWS(pdfData: pdf)
            guard let self = self else { return }
            // Handle selected images here
        }
        photoPickManager.onPdfString = { [weak self] pdf in
            print("Selectef12 \(pdf)")
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
    }
    
    func  StyleAndTranslater(){
        
        TextviewHeight.constant = initialHeight
        //MARK: UI Update
        CreateView.layer.cornerRadius = 10
        CreateView.layer.shadowColor = UIColor.black.cgColor
        CreateView.layer.shadowOffset = CGSize(width: 0, height: 2)
        CreateView.layer.shadowRadius = 5
        CreateView.layer.shadowOpacity = 0.3
        CreateView.layer.cornerRadius = 10
        AssignmentTypeview.layer.cornerRadius = 10
        categoryDropDownView.layer.cornerRadius = 10
        selectImgPdfview.layer.cornerRadius = 10
        contentTextView.layer.cornerRadius = 10
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.gray.cgColor
        chooseRecipientsBtn.backgroundColor = .button
        chooseRecipientsBtn.layer.cornerRadius = 10
        collectionViewHeght.constant = 0
        addphotosheight.constant = 0
        categoryDropDownView.layer.borderWidth = 1
        categoryDropDownView.layer.borderColor = UIColor.lightGray.cgColor
        categoryDropDownView.backgroundColor = .white
        AssignmentTypeview.layer.borderWidth = 1
        AssignmentTypeview.layer.borderColor = UIColor.lightGray.cgColor
        AssignmentTypeview.backgroundColor = .white
        contentTextView.text = CommonStringFile.Description.translated()
        contentTextView.textColor = .lightGray
        customizedDateBtn.layer.cornerRadius = 10
        customizedDateBtn.layer.borderWidth = 1
        customizedDateBtn.layer.borderColor = UIColor.gray.cgColor
        
        //MARK: Button Font Style
        //chooseImgBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        chooseRecipientsBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        DateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Label Font Style
        AddphotosLbl.setFont(style: .title, size: FontSize.TitleSize)
        SubmissionDateLbl.setFont(style: .title, size: FontSize.TitleSize)
        letterscountLbl.setFont(style: .body, size: FontSize.BodySize)
        DescriptionLbl.setFont(style: .title, size: FontSize.TitleSize)
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        HeaderLbl.setFont(style: .header, size: FontSize.HeaderSize)
        AssignmenttypeLbl.setFont(style: .title, size: FontSize.TitleSize)
        categoryDropDownLbl.setFont(style: .title, size: FontSize.TitleSize)
        categoryLbl.setFont(style: .title, size: FontSize.TitleSize)
        //subDateLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        self.dismiss(animated: true, completion: nil)
        let selectedDate = sender.date
        print("Selected Date: \(selectedDate)")
    }
    @IBAction func backVc() {
        
        dismiss(animated: true)
    }
    
    @IBAction func chooseRecipientsAction(_ sender: UIButton) {
    }
    
    @IBAction  func categoryDropdown (){
        dropDown.dataSource = ["GENERAL", "CLASS WORK", "PROJECT", "RESEARCH PAPER"]
        self.view.layoutIfNeeded()
        dropDown.width = categoryDropDownView.bounds.width
        dropDown.bottomOffset = CGPoint(x: 0, y: categoryDropDownView.bounds.height - 110)
        dropDown.direction = .bottom
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            // Update the label inside the UIView
            if let label = self?.categoryDropDownView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self!.categoryDropDownLbl.text = item
            }
        }
    }
    
    @IBAction  func typeDropdown (){
        TypeDropDown.dataSource = ["TEXT", "IMAGE", "PDF"]
        self.view.layoutIfNeeded()
        TypeDropDown.width = AssignmentTypeview.bounds.width
        TypeDropDown.bottomOffset = CGPoint(x: 0, y: AssignmentTypeview.bounds.height - 220)
        
        TypeDropDown.direction = .bottom
        TypeDropDown.show()
        TypeDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            // Update the label inside the UIView
            if item == "TEXT"{
                
                self!.collectionViewHeght.constant = 0
                self!.addphotosheight.constant = 0
            }
            else if item == "PDF"{
                self!.collectionViewHeght.constant = 120
                self!.addphotosheight.constant = 20
                self!.AddphotosLbl.text = CommonStringFile.AddPdf.translated()
            }
            else{
                self!.collectionViewHeght.constant = 120
                self!.addphotosheight.constant = 20
                self!.AddphotosLbl.text = CommonStringFile.AddPhotos.translated()
            }
            if let label = self?.AssignmentTypeview.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self!.AssignmenttypeLbl.text = item
            }
        }
    }
    
    @IBAction func chooseImgBtnAction(_ sender: UIButton) {
        presentSelectionAlert()
    }
    
    
    @IBAction func presentSelectionAlert() {
        let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
        
        // Camera option
        let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { [self] _ in
            openCamera()
        }
        alertController.addAction(cameraAction)
        
        // Gallery option
        let galleryAction = UIAlertAction(title: "Gallery".translated(), style: .default) { [self] _ in
            selectImages()
        }
        alertController.addAction(galleryAction)
        
        let pdfAction = UIAlertAction(title: "Pdf".translated(), style: .default) { [self] _ in
            selectPdf()
        }
        alertController.addAction(pdfAction)
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func selectImages() {
        photoPickManager.presentPhotoPicker(from: self, selectionLimit: 3)
    }
    
    func selectPdf() {
        photoPickManager.pickPDF(from: self)
    }
    
    // MARK: Handle Select Camera,Pdf,Image
    @IBAction func openCamera() {
        // Check if the camera is available
        photoPickManager.openCamera(from: self)
        //        if UIImagePickerController.isSourceTypeAvailable(.camera) {
        //            let imagePicker = UIImagePickerController()
        //            imagePicker.delegate = self
        //            imagePicker.sourceType = .camera
        //            imagePicker.allowsEditing = true // Allows editing of the captured image
        //            present(imagePicker, animated: true, completion: nil)
        //        } else {
        //            // Camera is not available, show an alert
        //            let alert = UIAlertController(title: "Camera Not Available".translated(), message: "This device has no camera.".translated(), preferredStyle: .alert)
        //            alert.addAction(UIAlertAction(title: "OK".translated(), style: .default, handler: nil))
        //            present(alert, animated: true, completion: nil)
        //        }
    }
    
    
    // Handle the image once it has been captured
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            // Use the captured image
            // For example, display it in an image view or save it
            print("Captured Image: \(image)")
            self.selectedImages.append(image)
        } else if let image = info[.originalImage] as? UIImage {
            print("Captured Image: \(image)")
            self.selectedImages.append(image)
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Handle cancellation
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func DateBtnAct(_ sender: Any) {
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
  
}


@available(iOS 14.0, *)
extension SenderAssignmentTextViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    // MARK: - UICollectionView DataSource
    //       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //           return selectedImages.count
    //       }
    //
    //       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
    //           cell.imageViews.image = selectedImages[indexPath.item]
    //           return cell
    //       }
    //
    //       // MARK: - UICollectionView Delegate
    //       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //           // Delete the selected image
    //           selectedImages.remove(at: indexPath.item)
    //           collectionView.deleteItems(at: [indexPath])
    //       }
    //
    //
    //}
    //
    //@available(iOS 14.0, *)
    //extension SenderAssignmentTextViewController: UICollectionViewDelegateFlowLayout {
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        let width = (collectionView.frame.width - 20) / 3 // Adjust based on how many columns you want
    //        return CGSize(width: width, height: width)
    //    }
    //
    //
    //
    //
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let cell = selectImgPdfview.imageCollectionview.dequeueReusableCell(withReuseIdentifier: "AttachmentCVCell", for: indexPath) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        }else{
            let cell = selectImgPdfview.imageCollectionview.dequeueReusableCell(withReuseIdentifier: "ImageCvCell", for: indexPath) as! ImageCvCell
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
        
        let width = (selectImgPdfview.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
            //
            // Camera option
            let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { [self] _ in
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
                
                //selectPDF()
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
                
                // Safe unwrapping of imgView before assigning
                vc.img = selectedImages[indexPath.item - 1]
                //
                present(vc, animated: true)
            }
        }
    }
    
}

@available(iOS 14.0, *)
extension SenderAssignmentTextViewController : UITextViewDelegate{
    
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
    
    func keyboardDonebtn(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        assignTitleTxtFld.inputAccessoryView = toolbar
        contentTextView.inputAccessoryView = toolbar
        
    }
    @objc func doneKeyboard() {
        view.endEditing(true)  // Dismiss the keyboard
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
