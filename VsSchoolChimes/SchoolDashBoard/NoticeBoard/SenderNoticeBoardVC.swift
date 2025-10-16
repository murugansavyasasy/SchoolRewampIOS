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
        guard let dayDate = dateFormatter.date(from: date) else { return }

        // ✅ Convert to desired date format: 10 Oct 2025
        dateFormatter.dateFormat = "dd MMM yyyy"
        let outputDateString = dateFormatter.string(from: dayDate)
        
        // ✅ Get the day name (e.g. Monday, Tuesday)
        let dayNameFormatter = DateFormatter()
        dayNameFormatter.dateFormat = "EEEE"  // Full day name
        let dayName = dayNameFormatter.string(from: dayDate)

        if dateSelection == true {
            fromDateLbl.text = outputDateString
            fromeDayLbl.text = dayName
            if let toText = toDateLbl.text?.replacingOccurrences(of: "\n", with: " ") {
                let labelFormatter = DateFormatter()
                labelFormatter.dateFormat = "dd MMM yyyy"
                if let toDate = labelFormatter.date(from: toText) {
                    if dayDate > toDate {
                        toDateLbl.text = outputDateString
                        toDayLbl.text = dayName
                    }
                }
            }
        } else {
            toDateLbl.text = outputDateString
            toDayLbl.text = dayName
        }
    }

    
    @IBOutlet weak var fromeDayLbl: UILabel!
    @IBOutlet weak var toDayLbl: UILabel!
    @IBOutlet weak var FromLbl: UILabel!
    @IBOutlet weak var ToLbl: UILabel!
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var dateOuterView: UIView!
    @IBOutlet weak var FromDateView: UIView!
    @IBOutlet weak var toDateView: UIView!
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var DisplayRangeLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var TittleDefLbl: UILabel!
    @IBOutlet weak var DescriptionDefLbl: UILabel!
    @IBOutlet weak var DescriptionLettersCount: UILabel!
    @IBOutlet weak var Attachmentview: ImageSelection!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var addPhotoLbl: UILabel!
    @IBOutlet weak var TitleTextfield: UITextField!
    @IBOutlet weak var TextfieldCharCountLbl: UILabel!
    @IBOutlet weak var NextBtn: UIButton!
    @IBOutlet weak var PopupView: UIView!
    @IBOutlet weak var menuNameLbl: UILabel!
    
    
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
    var delegate:EditObjectDelegate?
    var selectedVideoURL: URL?
    var editId: String?
    let standardDateFormat = DateFormatString.StandardFormat
    var editReport:Notice?
    override func viewDidLoad() {
        super.viewDidLoad()
        StyleAndTranslater()
        FromDateView.layer.cornerRadius = 8
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        menuNameLbl.setFont(style: .header, size: FontSize.HeaderSize)
        menuNameLbl.text = MenuStringFile.selectedMenuName
        DisplayRangeLbl.setRequiredText(CommonStringFile.Notice_Display_Date_Range)
        
        FromLbl.setFont(style: .title, size: FontSize.TitleSize)
        ToLbl.setFont(style: .title, size: FontSize.TitleSize)
        
//        dateOuterView.layer.borderColor = UIColor.lightGray.cgColor
//        dateOuterView.layer.borderWidth = 0.5
//        dateOuterView.layer.cornerRadius = 8
        
        FromDateView.layer.borderColor = UIColor.lightGray.cgColor
        FromDateView.layer.borderWidth = 0.5
        FromDateView.layer.cornerRadius = 8
        FromDateView.layer.borderWidth = 0.5
        
        toDateView.layer.borderColor = UIColor.lightGray.cgColor
        toDateView.layer.borderWidth = 0.5
        toDateView.layer.cornerRadius = 8
        toDateView.layer.borderWidth = 0.5
        
        let DateGesture = UITapGestureRecognizer(target: self, action: #selector(fromDate))
        FromDateView.addGestureRecognizer(DateGesture)
        
        let ToDateGesture = UITapGestureRecognizer(target: self, action: #selector(toDate))
        toDateView.addGestureRecognizer(ToDateGesture)
        
        setInitialDate("", "")
        setupPlaceholder()
        TitleTextfield.addDoneButton()
        textview.addDoneButton()
        imageSelection()
        Attachmentview.imageCollectionview.delegate = self
        Attachmentview.imageCollectionview.dataSource = self
        Attachmentview.imageCollectionview.backgroundColor = .clear
        textview.delegate = self
        TitleTextfield.delegate = self
        
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
        if let edit = editReport{
            fetchData(notice: edit)
        }
    }
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
    }
    func fetchData(notice: Notice?) {
        attachments.removeAll()
        
        guard let notice = notice else {
            // Clear UI for new notice
            TitleTextfield.text = ""
            textview.text = ""
            placeholderLabel.isHidden = !textview.text.isEmpty
            attachments.removeAll()
            Attachmentview.imageCollectionview.reloadData()
            editId = nil
            NextBtn.setTitle("Next", for: .normal)
            return
        }
    
        // Populate title and description
        TitleTextfield.text = notice.title
        textview.text = notice.description
        placeholderLabel.isHidden = !textview.text.isEmpty
        // Map attachments
        if let files = notice.file_path {
            attachments = files.map { file in
                let type = file.type?.lowercased() ?? ""
                return AttachmentItem(
                    image: nil,
                    imageURL: type != "video" ? file.url : nil,
                    fileType: type,
                    VideoURl: type == "video" ? URL(string: file.url ?? "") : nil
                )
            }
        }
        setInitialDate(notice.visible_from,notice.visible_to)
        Attachmentview.imageCollectionview.reloadData()
        editId = notice.id
        NextBtn.setTitle("Update", for: .normal)
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
            Attachmentview.imageCollectionview.reloadData()
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - Setting Current Date as Initial Date
    func setInitialDate(_ fromDate: String?, _ toDate: String?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let currentDate = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: 30, to: currentDate)!
        
        let startDate = (fromDate != nil ? dateFormatter.date(from: fromDate!) : nil) ?? currentDate
        let endDate   = (toDate   != nil ? dateFormatter.date(from: toDate!)   : nil) ?? futureDate
        
        // 📅 Date display formatter
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")
        displayFormatter.dateFormat = "dd MMM yyyy"
        let fromDisplay = displayFormatter.string(from: startDate)
        let toDisplay = displayFormatter.string(from: endDate)
        
        // 🗓 Day name formatter
        let dayNameFormatter = DateFormatter()
        dayNameFormatter.locale = Locale(identifier: "en_US_POSIX")
        dayNameFormatter.dateFormat = "EEEE"
        let fromDay = dayNameFormatter.string(from: startDate)
        let toDay = dayNameFormatter.string(from: endDate)
        
        // ✅ Set labels
        fromDateLbl.text = fromDisplay
        fromeDayLbl.text = fromDay
        toDateLbl.text = toDisplay
        toDayLbl.text = toDay
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
        
        textview.layer.cornerRadius = 10
        textview.layer.borderWidth = 1
        textview.layer.borderColor = UIColor.gray.cgColor
        
        NextBtn.layer.cornerRadius = 10
        
        //MARK: Label Font
        addPhotoLbl.setFont(style: .title, size: FontSize.TitleSize)
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
        if let fromDateString = fromDateLbl.text,
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
    @IBAction func viewHistory(_ sender: UIButton) {
        let vc = NoticeBoardVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
       present(vc, animated: true)
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
        user_inputs.FromDate = ConvertDateStringSmart(fromDateLbl.text ?? "")
        user_inputs.ToDate = ConvertDateStringSmart(toDateLbl.text ?? "")
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
                    TitleTextfield.text = ""
                    textview.text = ""
                    placeholderLabel.isHidden = !textview.text.isEmpty
                    attachments.removeAll()
                    Attachmentview.imageCollectionview.reloadData()
                    editId = nil
                    NextBtn.setTitle("Next", for: .normal)
//                    delegate?.editDta(edit: nil)
                    self.dismiss(animated: true)
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
                    selectPDF()
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
