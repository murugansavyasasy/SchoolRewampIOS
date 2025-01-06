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
class SenderAssignmentTextViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate,UIDocumentPickerDelegate, DeleteImge {
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        selectImgPdfview.imageCollectionview.reloadData()
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createDatepicker()
        StyleAndTranslater()
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
        contentTextView.delegate = self
        
        customdate.dateFormat = "EEE d"
        let customdatestring = customdate.string(from: Date())
        setcustomDate(attributedLbl: customdatestring)
        
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
        
        //        MARK: Camera Image
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
    
    func  StyleAndTranslater(){
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
        contentTextView.text = TexviewStringFile.Enter_Assignment_Description
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
            else{
                self!.collectionViewHeght.constant = 120
                self!.addphotosheight.constant = 20
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
    
    
    @IBAction func CustomDateBtnAct(_ sender: Any) {
        
        showDatepicker(button: sender as! UIButton)
    }
    
    @IBAction func DateBtnAct(_ sender: Any) {
        
        showDatepicker(button: sender as! UIButton)
    }
    
    func createDatepicker(){
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        datePicker.backgroundColor = .white
        
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        
        datePicker.isHidden = true
        self.view.addSubview(datePicker!)
        
        // Initialize and configure Done button
        doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.isHidden = true
        doneButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 8
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        self.view.addSubview(doneButton)
        
    }
    
    func showDatepicker(button: UIButton) {
        datePicker.isHidden = false
        doneButton.isHidden = false
        
        let buttonFrame = button.convert(button.bounds, to: self.view)
        
        // Set the frame for the datePicker
        let pickerYPosition = view.frame.minY + 110
        datePicker.frame = CGRect(x: (self.view.frame.width - 300) / 2, y: pickerYPosition, width: 300, height: 300)
        
        // Set appearance for datePicker
        datePicker.backgroundColor = .white
        datePicker.layer.shadowColor = UIColor.black.cgColor
        datePicker.layer.shadowOffset = CGSize(width: 0, height: 2)
        datePicker.layer.shadowRadius = 5
        datePicker.layer.shadowOpacity = 0.3
        datePicker.layer.cornerRadius = 20
        
        doneButton.frame = CGRect(x: datePicker.frame.maxX - 80, y: pickerYPosition + datePicker.frame.height - 40, width: 70, height: 30)
        
        // Add both datePicker and Done button to the view
        self.view.addSubview(datePicker)
        self.view.addSubview(doneButton)
    }
    
    @IBAction func doneButtonTapped(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "EEE d MMM yyyy"
        let datelabel = dateFormatter.string(from: datePicker.date)
        DateBtn.setTitle(datelabel, for: .normal)
        
        
        customdate.dateFormat = "EEE d"
        let attributedLbl = customdate.string(from: datePicker.date)
        setcustomDate(attributedLbl: attributedLbl)
        datePicker.isHidden = true
        doneButton.isHidden = true
    }
    
    func setcustomDate(attributedLbl : String){
        
        let words = attributedLbl.split(separator: " ")
        
        let attributedString = NSMutableAttributedString(string: attributedLbl)
        
        // Define the ranges for the two words
        let firstWordRange = (attributedLbl as NSString).range(of: String(words[0]))
        let secondWordRange = (attributedLbl as NSString).range(of: String(words[1]))
        
        let dayfont = UIFont(name: "Poppins-Medium", size: 14)
        let datefont = UIFont(name: "Poppins-Bold", size: 14)
        
        // Apply color and font to the first word
        attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: firstWordRange)
        attributedString.addAttribute(.font, value: dayfont, range: firstWordRange)
        
        // Apply  color and font to the second word
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: secondWordRange)
        attributedString.addAttribute(.font, value: datefont, range: secondWordRange)
        
        // Assign the attributed string to the label
        CustomDateLbl.attributedText = attributedString
        
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
        if contentTextView.text == TexviewStringFile.Enter_Assignment_Description {
            
            contentTextView.text = ""
            contentTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextView.text == "" {
            
            contentTextView.text = TexviewStringFile.Enter_Assignment_Description
            contentTextView.textColor = .lightGray
        }
    }
}
