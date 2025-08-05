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
import AVFoundation
import AVKit

@available(iOS 14.0, *)
class SenderNoticeBoardVC: UIViewController,UIDocumentPickerDelegate, DeleteImge, Datepicker, UIPopoverPresentationControllerDelegate {
    
    func date(date: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = standardDateFormat
        let DayDate = dateFormatter.date(from: date)!
        // Change to output format
        dateFormatter.dateFormat = DateFormatString.Day_and_date
        let outputDateString = dateFormatter.string(from: DayDate)
        
        if dateSelection == true{
            fromdateBtn.setTitle(date, for: .normal)
            setFormattedDate(outputDateString, label: fromDateLbl)
            NewFromdateLbl.setFormattedDate(from: DayDate)
            // Check if To Date is set and valid
            if let toText = NewToDateLbl.text?.replacingOccurrences(of: "\n", with: " ") {
                let labelFormatter = DateFormatter()
                labelFormatter.dateFormat = DateFormatString.Date_Day_month_year
                if let toDate = labelFormatter.date(from: toText) {
                    if DayDate > toDate {
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
    //    @IBOutlet weak var VideoThumbnailImg: UIImageView!
    
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
    var editId: String?
    let standardDateFormat = DateFormatString.StandardFormat
    override func viewDidLoad() {
        super.viewDidLoad()
        StyleAndTranslater()
        FromDateView.layer.cornerRadius = 8
        ToDateView.layer.cornerRadius = 8
        FromDateTop.layer.cornerRadius = 8
        TodateTop.layer.cornerRadius = 8
        FromDateTop.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        TodateTop.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        
        DisplayRangeLbl.setRequiredText(CommonStringFile.Notice_Display_Date_Range)
        
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
        VideoView.isHidden = true
        
        
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
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    func fetchData(notice:Notice?){
        attachments.removeAll()
        if let notice = notice{
            TitleTextfield.text = notice.title
            textview.text = notice.description
            placeholderLabel.isHidden = !textview.text.isEmpty
            if let files = notice.file_path {
                let imageItems: [AttachmentItem] = files.map { file in
                    let type = file.type?.lowercased() ?? ""
                    return AttachmentItem(
                        image: nil,
                        imageURL: type != "video" ? file.url : nil,
                        fileType: type,
                        VideoURl: type == "video" ? URL(string: file.url ?? "") : nil
                    )
                }

                attachments = imageItems
            } else {
                attachments = []
            }

            Attachmentview.imageCollectionview.reloadData()
            editId = notice.id
            NextBtn.setTitle("Update", for: .normal)
        }else{
            TitleTextfield.text = ""
            textview.text = ""
            placeholderLabel.isHidden = !textview.text.isEmpty
            attachments.removeAll()
            Attachmentview.imageCollectionview.reloadData()
            editId = nil
            NextBtn.setTitle("Next", for: .normal)
        }
    }
    func imageSelection(){
        
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            
            attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            //            attachments.removeAll { $0.fileType != CommonStringFile.IMAGE }
            
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            Attachmentview.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            attachments.append(contentsOf: imageItems)
            //            if imageItems.count != 0{
            //                attachments.removeAll { $0.fileType != CommonStringFile.IMAGE }
            //            }
            Attachmentview.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onFilePicked = { [self] data in
            // handle picked PDF
            user_inputs.selectedFileType = CommonStringFile.pdf
            attachments.append(AttachmentItem(image:nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf))
            //            attachments.removeAll { $0.fileType == CommonStringFile.IMAGE }
            Attachmentview.imageCollectionview.reloadData()
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
            //            attachments.removeAll { $0.fileType == CommonStringFile.IMAGE }
            Attachmentview.imageCollectionview.reloadData()
        }
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
        
        dateFormatter.dateFormat = DateFormatString.Day_and_date
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
        addPhotoLbl.setFont(style: .title, size: FontSize.TitleSize)
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
        dateFormatter.dateFormat = DateFormatString.StandardFormat
        vc.dateSelection = 2
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
        
    }
    
    @IBAction func toDate(_ sender: Any) {
        
        dateSelection = false
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        dateFormatter.dateFormat = DateFormatString.StandardFormat
        
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
        
        //        assignmentResquestStringKey.title = TitleTextfield.text ?? ""
        //        assignmentResquestStringKey.description = textview.text
        user_inputs.FromDate = ConvertDateStringSmart(fromdateBtn.titleLabel?.text ?? "")
        user_inputs.ToDate = ConvertDateStringSmart(todateBtn.titleLabel?.text ?? "")
        user_inputs.SelectedUrls = attachments
        user_inputs.VideoPath = selectedVideoURL
        var params: [String: Any] = [
            SendAttachmentStringFile.title: textFieldText,
            SendAttachmentStringFile.description: textViewText,
            SendAttachmentStringFile.visible_from : user_inputs.FromDate,
            SendAttachmentStringFile.visible_to : user_inputs.ToDate
        ]
        if sender.titleLabel?.text == "Update"{
            let com = commonApi_forSending()
            params[SendAttachmentStringFile.id] = editId
            sendAttachmentFlow(via: com, url: ServiceUrl.admin_api_notice_board_update, Common_request_params: params)
        }else{
            let vc = SchoolListVC(nibName: nil, bundle: nil)
            vc.Common_request_params = params
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    private func sendAttachmentFlow(
        via comm: commonApi_forSending,
        url baseURL: String,
        Common_request_params: [String: Any]
    ) {
        comm.SendingAttachmentFlow(
            selectedAcadimicYearId: 0,
            edit: true,
            target_type:0,
            selectedId: [],
            baseURL: baseURL,
            subjectId: "",
            message:"",
            from: self,
            Common_request_params: Common_request_params
        ) { response in
            DispatchQueue.main.async {
                CircularProgressLoader.shared.hide()
                CustomAlert.showAlertWithOkAction(
                    title: AlertstringFile.Success,
                    message: response.message,
                    on: self
                ) { [self] in
                    dismiss(animated: true)
                }
            }
        }
    }
    
    // MARK: File Attachments Actions
    func selectImages() {
        let img = attachments.filter { $0.fileType == CommonStringFile.IMAGE }
        if attachments.count != 10{
            PhotoPickerManager.shared
                .presentPicker(
                    ofType: .gallery(selectionLimit: 10 - attachments.count),
                    from: self
                )
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
        
    }
    func openCamera(){
        let img = attachments.filter { $0.fileType == CommonStringFile.IMAGE }
        if attachments.count != 10{
            PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    func selectPDF() {
        let pdf = attachments.filter { $0.fileType != CommonStringFile.IMAGE }
        if attachments.count != 10{
            PhotoPickerManager.shared.presentPicker(ofType: .file, from: self)
            PhotoPickerManager.shared.limiSelection = 10 - attachments.count
        }else{
            
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
        
    }
    
    func VideoPick() {
        let video = attachments.filter { $0.fileType != CommonStringFile.VIDEO }
        
        if  video.count != 2{
            
            if attachments.count <= 10{
                PhotoPickerManager.shared.limiSelection = 10 - attachments.count
                PhotoPickerManager.shared.presentPicker(ofType: .video, from: self)
                
            }else{
                let alert = CustomAlert()
                alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            }
            
        }else{
            
            let alert = CustomAlert()
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
                
            }else{
                
                cell.imageViews.image = nil
            }
            
            // Set collection view height dynamically
            let totalItems = attachments.count
            collectionViewHeght.constant = totalItems <= 2 ? 120 : collectionView.collectionViewLayout.collectionViewContentSize.height
            return cell
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (Attachmentview.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
           
            let remaining = 10 - attachments.count
            
            if remaining > 0 {
                
                let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
                
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
                
                //   VIDEO option
                let VideoAction = UIAlertAction(title: "Video", style: .default) { [self] _ in
                    
                    let totalRemaining = 10 - attachments.count
                    let videoCount = attachments.filter { $0.fileType.lowercased() == "video" }.count
                    let videoRemaining = 2 - videoCount
                    
                    if totalRemaining <= 0 {
                        CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
                    } else if videoRemaining <= 0 {
                        CustomAlert().showAlert(title: "", message: "You can only select up to 2 video files.", on: self)
                    }else{
                        
                        VideoPick()
                        
                    }
                }
                alertController.addAction(VideoAction)
                // Cancel action
                let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }else{
                
                CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            }
            
        } else {
            let attachment = attachments[indexPath.item - 1]
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.attachment = attachments
            imageVC.subjectName = "NoticeBoard"
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
//        if updatedText.count <= 50 {
            TextfieldCharCountLbl.text = "\(updatedText.count) / 50"
            return true
//        } else {
//            // If the limit is exceeded, show an alert and reject the change
//            let alert = CustomAlert()
//            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
//            return false
//        }
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
//        if updatedText.count <= 500 {
            DescriptionLettersCount.text = "\(updatedText.count) / 500" // Update the character count label
            return true // Allow the change
//        } else {
//            let alert = CustomAlert()
//            alert.showAlert(title: "", message: AlertstringFile.Reach_Your_Limit, on: self)
//            //            contentTxtView.isEditable = false // Optionally disable editing
//            return false // Reject the change
//        }
    }
    
    func adjustTextViewHeightWithConstraint(_ textView: UITextView) {
        let size = textView.contentSize
        if size.height > initialHeight {
            let newHeight = min(size.height, maxHeight)
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
