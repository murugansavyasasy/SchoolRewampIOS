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
import AVFoundation
import AVKit
import QuickLook

@available(iOS 14.0, *)


class SenderAssignmentTextViewController: UIViewController,UIDocumentPickerDelegate, DeleteImge, Datepicker, UIPopoverPresentationControllerDelegate, VideoPickerManagerDelegate, QLPreviewControllerDataSource {
   

    
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
        attachments.remove(at: index)
        selectImgPdfview.imageCollectionview.reloadData()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none // This forces popover on iPhone
    }
    @IBOutlet weak var VideoView: UIView!
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
    @IBOutlet weak var addphotosheight: NSLayoutConstraint!
    @IBOutlet weak var CreateView: UIView!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var categoryDropDownLbl: UILabel!
    @IBOutlet weak var assignTitleTxtFld: UITextField!
    @IBOutlet weak var chooseRecipientsBtn: UIButton!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var categoryDropDownView: UIView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var selectImgPdfview: ImageSelection!
    @IBOutlet weak var VideoPlayBtn: UIButton!
    
    @IBOutlet weak var ClickTochooseVideoLbl: UILabel!
    @IBOutlet weak var VideoDeleteBtn: UIImageView!
    @IBOutlet weak var VideoThumbnailImg: UIImageView!
    var selectedShow = ""
   
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
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    var playerurl: URL?
    var isImage = false
    var selectedImgUrl: [FilePath] = []
    var fileUrls = [String]()
    var videoPicker: VideoPickerManager?
    var selectedVideoURL: URL?
    var DocumentpreviewURL : URL?
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    let staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var thumbnailURL: String?
    let thumbnailImageView = UIImageView()
    var attachments: [AttachmentItem] = []
//    var childVC :  AssignmentReportVc?
    var thumbnailImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        StyleAndTranslater()
        videoPicker = VideoPickerManager(presenter: self, delegate: self)
            
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
        VideoView.isHidden = true
        assignTitleTxtFld.addDoneButton()
        contentTextView.addDoneButton()
        contentTextView.delegate = self
        contentTextView.applyRightTxt()
        categoryLbl.applyRightTxt()
        categoryDropDownLbl.applyRightTxt()
        DescriptionLbl.applyRightTxt()
        letterscountLbl.applyRightTxt()
        titleLbl.applyRightTxt()
        SubmissionDateLbl.applyRightTxt()
        assignTitleTxtFld.applyRightTxt()
        customdate.dateFormat = "EEE d"
        let customdatestring = customdate.string(from: Date())
        setFormattedDate(customdatestring, label: CustomDateLbl)
        
        formatter.dateFormat = "EEE d MMM yyyy"
        let dateBtntitle = formatter.string(from: Date())
        DateBtn.setTitle(dateBtntitle, for: .normal)
        
        let categoryGesture = UITapGestureRecognizer(target: self, action: #selector(categoryDropdown))
        categoryDropDownView.addGestureRecognizer(categoryGesture)
        let PlayGesture = UITapGestureRecognizer(target: self, action: #selector(chooseVideoTapped))
        VideoView.addGestureRecognizer(PlayGesture)
        
        let VideoDelete = UITapGestureRecognizer(target: self, action: #selector(deleteVideo))
        VideoDeleteBtn.addGestureRecognizer(VideoDelete)
   
        selectImgPdfview.imageCollectionview.delegate = self
        selectImgPdfview.imageCollectionview.dataSource = self
        imageSelection()
    }
    
   
//        
//    @IBAction func segmntAction(_ sender: UISegmentedControl) {
//        
//        if sender.selectedSegmentIndex == 0 {
//                removeChildVC()
//            } else {
//                addChildViewControllerToContainer()
//            }
//    }
//   
//   
//    func removeChildVC() {
////        guard let vc = childVC else { return }
////        vc.willMove(toParent: nil)
////        vc.view.removeFromSuperview()
////        vc.removeFromParent()
////        childVC = nil
//    }
//    func addChildViewControllerToContainer() {
////        let vc = AssignmentReportVc(nibName: nil, bundle: nil)
////        addChild(vc)
////        vc.view.frame = CreateView.bounds
////        CreateView.addSubview(vc.view)
////        vc.didMove(toParent: self)
////        self.childVC = vc // Save reference
//    }
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
           selectImgPdfview.isHidden = true
           collectionViewHeght.constant = 0
           selectedVideoURL = url
           self.thumbnailImage = generateThumbnail(for: url)

//           if let thumbnail = self.thumbnailImage {
//               self.thumbnailImageView.image = thumbnail
//               user_inputs.thumbNail = thumbnail
//           }
           VideoView.isHidden = false
           chooseRecipientsBtn.isHidden = false
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
           selectImgPdfview.isHidden = false
           collectionViewHeght.constant = 120
           selectImgPdfview.imageCollectionview.reloadData()
          
           
       }
    
    func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail: \(error)")
            return nil
        }
    }
    
    
    func imageSelection(){

            PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
                
                attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
                attachments.removeAll { $0.fileType != CommonStringFile.IMAGE }

                user_inputs.selectedFileType = CommonStringFile.IMAGE
                selectImgPdfview.imageCollectionview.reloadData()
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
                
                selectImgPdfview.imageCollectionview.reloadData()
            }
            
            PhotoPickerManager.shared.onFilePicked = { [self] data in
                // handle picked PDF
                user_inputs.selectedFileType = CommonStringFile.pdf
                attachments.append(AttachmentItem(image:nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf))
                attachments.removeAll { $0.fileType == CommonStringFile.IMAGE }

                selectImgPdfview.imageCollectionview.reloadData()
            }
            
        
    }
    
    override func viewDidLayoutSubviews() {
//        
//        view.applyGradient(
//            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
//            startPoint: CGPoint(x: 1, y: 0.5),
//            endPoint: CGPoint(x: 0, y: 0.5)
//        )
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
        contentTextView.text = CommonStringFile.Description.translated()
        contentTextView.textColor = .lightGray
        customizedDateBtn.layer.cornerRadius = 10
        customizedDateBtn.layer.borderWidth = 1
        customizedDateBtn.layer.borderColor = UIColor.gray.cgColor
        
        //MARK: Button Font Style
        chooseRecipientsBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        DateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Label Font Style
        AddphotosLbl.setFont(style: .title, size: FontSize.TitleSize)
        SubmissionDateLbl.setFont(style: .title, size: FontSize.TitleSize)
        letterscountLbl.setFont(style: .body, size: FontSize.BodySize)
        DescriptionLbl.setFont(style: .title, size: FontSize.TitleSize)
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        categoryDropDownLbl.setFont(style: .title, size: FontSize.TitleSize)
        categoryLbl.setFont(style: .title, size: FontSize.TitleSize)
        collectionViewHeght.constant = 120
       addphotosheight.constant = 20
        setAttributedText(for: AddphotosLbl, with: CommonStringFile.Add_attachment_optional.translated(), firstString: CommonStringFile.Add_attachment.translated(), secondString:CommonStringFile.Optional.translated(), color1: .black, color2: .lightGray)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        self.dismiss(animated: true, completion: nil)
        let selectedDate = sender.date
        print("Selected Date: \(selectedDate)")
    }

    @IBAction func chooseRecipientsAction(_ sender: UIButton) {
        
        guard let title = assignTitleTxtFld.text , !title.isEmpty, let contents = contentTextView.text , !contents.isEmpty
        else {
            CustomAlert
                .showAlertWithOkAction(
                    title: AlertstringFile.Alert_title,
                    message: AlertstringFile.Fill_All_Required_Fields,
                    on: self
                )
            return
        }
        
        let date = ConvertDateStringSmart(DateBtn.titleLabel?.text)
        
        // Step 1: Prepare all user_inputs data into one dictionary
        let params: [String: Any] = [
            assignmentResquestStringKey.title: title,
            assignmentResquestStringKey.description: contents,
            assignmentResquestStringKey.category: categoryDropDownLbl.text ?? "",
            assignmentResquestStringKey.submission_date: date,
        ]
        
//        user_inputs.selectedImg = selectedImages
//        user_inputs.docUrl =  fileUrls
        user_inputs.VideoPath = selectedVideoURL
        user_inputs.SelectedUrls = attachments
        
        let vc = RecipientVc(nibName: nil, bundle: nil)
        vc.Common_request_params = params
        vc.ScreenType = Menu_id.AttachmentMenuId
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
   
    
    @IBAction  func categoryDropdown (){
        dropDown.dataSource = ["GENERAL", "CLASS WORK", "PROJECT", "RESEARCH PAPER"]
        self.view.layoutIfNeeded()
        dropDown.width = categoryDropDownView.bounds.width
        dropDown.bottomOffset = CGPoint(x: 0, y: categoryDropDownView.bounds.height)
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
    
   
    // MARK: Handle Select Camera,Pdf,Image
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
            
            // Set collection view height dynamically
            let totalItems = attachments.count
            collectionViewHeght.constant = totalItems <= 2 ? 120 : 220

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
    
    @objc(numberOfPreviewItemsInPreviewController:) func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
       
        fileUrls.count == 0 ? 0:1
    }

    @objc(previewController:previewItemAtIndex:) func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        if let Url = DocumentpreviewURL {
            
            return Url as QLPreviewItem
        }
        
        return NSURL(fileURLWithPath: "")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
