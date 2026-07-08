
//
//  SenderAssignmentTextViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/19/24.
//

import UIKit
//import DropDown
import AWSCore
import AWSS3
import AVFoundation
import AVKit
import QuickLook
import Kingfisher

@available(iOS 14.0, *)
class SenderAssignmentTextViewController: UIViewController,
                                          UIDocumentPickerDelegate,
                                          DeleteImge,
                                          Datepicker,
                                          UIPopoverPresentationControllerDelegate,
                                          QLPreviewControllerDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var TextviewHeight: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var dateBtn: UIButton!
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
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var categoryDropDownView: UIView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var selectImgPdfview: ImageSelection!
    
    // MARK: - Public/External Dependencies (kept as-is)
    var selectedShow = ""
    var getType = "Principal"
    var imageStr: [String] = []
    var currentImageCount = 0
    var schoolListArr = ["Sales","Vss","SSS","SSS2020"]
    var totalImageCount = 0
    var originalImagesArray = [UIImage]()
    var imageUrlArray = NSMutableArray()
    var getImagePdfType: String!
    var convertedImagesUrlArray = NSMutableArray()
    let photoPickManager = PhotoPickerManager.shared
    let dropDown = DropDown()
    let TypeDropDown = DropDown()
    var doneButton: UIButton!
    var pdfData: Data?
    let initialHeight: CGFloat = 60
    let maxHeight: CGFloat = 300
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    var playerurl: URL?
    var isImage = false
    var selectedImgUrl: [FilePath] = []
    var fileUrls = [String]()
    var videoPicker: VideoPickerManager?
    var delegate:EditObjectDelegate?
    var selectedVideoURL: URL?
    var DocumentpreviewURL: URL?
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    let staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    let thumbnailImageView = UIImageView()
    var attachments: [AttachmentItem] = []
    var editId: String?
    var thumbnailImage: UIImage?
    var placeholderLabel: UILabel!
    var editReport : Report?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        backBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName,
                                      secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        StyleAndTranslater()
        setupPlaceholderIfNeeded()
        contentTextView.delegate = self
        
        // Observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        assignTitleTxtFld.addDoneButton()
        assignTitleTxtFld.placeholder = "Title".translated()
        contentTextView.addDoneButton()
        categoryLbl.setRequiredText("Category".translated())
        SubmissionDateLbl.setRequiredText("Submission Date".translated())
        dateView.layer.borderColor = UIColor.lightGray.cgColor
        dateView.layer.borderWidth = 0.5
        dateView.layer.cornerRadius = 8
        dateBtn.layer.cornerRadius = 8
        dateBtn.backgroundColor = .blue.withAlphaComponent(0.6)
        setInitialButtonTitles(date:nil)
        let categoryGesture = UITapGestureRecognizer(target: self, action: #selector(categoryDropdown))
        categoryDropDownView.addGestureRecognizer(categoryGesture)
        selectImgPdfview.imageCollectionview.delegate = self
        selectImgPdfview.imageCollectionview.dataSource = self
        cancelBtn.isHidden = true
        imageSelection()
        updateCollectionHeight()
        if let edit = editReport{
            fetchData(notice: edit)
        }
        let dateTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectDateTapped))
        dateView.isUserInteractionEnabled = true
        dateView.addGestureRecognizer(dateTapGesture)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc private func selectDateTapped() {
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.minimumDate = Date()
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        present(vc, animated: false)
    }
    // MARK: - Datepicker (protocol)
    func date(date: String) {
        setInitialButtonTitles(date: date)
    }
    func setInitialButtonTitles(date dateString: String?, inputFormat: String = "dd MMM yyyy") {

        let parser = DateFormatter()
        parser.locale = LocaleManager.shared.displayLocale
        parser.dateFormat = inputFormat
        
        let dateToUse: Date
        if let dateString = dateString, let parsedDate = parser.date(from: dateString) {
            dateToUse = parsedDate
        } else {
            dateToUse = Date()
        }
        let displayDateFormatter = DateFormatter()
        displayDateFormatter.locale = LocaleManager.shared.displayLocale
        displayDateFormatter.dateFormat = "dd MMM yyyy"
        let displayTimeFormatter = DateFormatter()
        displayTimeFormatter.locale = LocaleManager.shared.displayLocale
        displayTimeFormatter.timeStyle = .short
        let dayFormatter = DateFormatter()
        dayFormatter.locale = LocaleManager.shared.displayLocale
        dayFormatter.dateFormat = "EEEE"
        dateLbl.text = displayDateFormatter.string(from: dateToUse)
        dayLbl.text = dayFormatter.string(from: dateToUse)
    }
    func deleteImage(index: Int) {
        guard attachments.indices.contains(index) else { return }
        attachments.remove(at: index)
        selectImgPdfview.imageCollectionview.reloadData()
        updateCollectionHeight()
    }
    // MARK: - Setup UI/Styles
    func StyleAndTranslater() {
        self.selectImgPdfview.imageCollectionview.backgroundColor = .clear
        TextviewHeight.constant = initialHeight
        
        categoryDropDownView.layer.cornerRadius = 10
        selectImgPdfview.layer.cornerRadius = 10
        
        contentTextView.layer.cornerRadius = 10
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.gray.cgColor
        
        chooseRecipientsBtn.backgroundColor = UIColor.primery
        cancelBtn.backgroundColor = .red
        chooseRecipientsBtn.layer.cornerRadius = 10
        cancelBtn.layer.cornerRadius = 10
        
        collectionViewHeght.constant = 0
        addphotosheight.constant = 0
        
        categoryDropDownView.layer.borderWidth = 1
        categoryDropDownView.layer.borderColor = UIColor.lightGray.cgColor
        categoryDropDownView.backgroundColor = .white
        
        // Fonts
        chooseRecipientsBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        cancelBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        AddphotosLbl.setFont(style: .title, size: FontSize.TitleSize)
        SubmissionDateLbl.setFont(style: .title, size: FontSize.TitleSize)
        letterscountLbl.setFont(style: .body, size: FontSize.BodySize)
        DescriptionLbl.setFont(style: .title, size: FontSize.TitleSize)
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        titleLbl.setRequiredText(CommonStringFile.Title)
        DescriptionLbl.setRequiredText(CommonStringFile.Description)
        
        categoryDropDownLbl.setFont(style: .title, size: FontSize.TitleSize)
        categoryLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        collectionViewHeght.constant = 120
        addphotosheight.constant = 20
        
        setAttributedText(for: AddphotosLbl,
                          with: CommonStringFile.Add_attachment_optional.translated(),
                          firstString: CommonStringFile.Add_attachment.translated(),
                          secondString: CommonStringFile.Optional.translated(),
                          color1: .black,
                          color2: .lightGray)
    }
    
    private func setupPlaceholderIfNeeded() {
        // Add a visible placeholder label inside UITextView
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.Description.translated()
        placeholderLabel.font = contentTextView.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8)
        contentTextView.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !(contentTextView.text?.isEmpty ?? true) &&
        contentTextView.textColor != .lightGray
    }
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func viewHistory(_ sender: UIButton) {
        let vc = AssignmentReport(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
       present(vc, animated: true)
    }
    // MARK: - Fetch/Edit Data
    func fetchData(notice: Report?) {
        attachments.removeAll()
        
        if let notice = notice {
            assignTitleTxtFld.text = notice.title
            contentTextView.text = notice.description
            contentTextView.textColor = .black
            placeholderLabel?.isHidden = !contentTextView.text.isEmpty
            
            if let files = notice.file_path {
                attachments = files.map { file in
                    let type = (file.type ?? "").lowercased()
                    return AttachmentItem(
                        image: nil,
                        imageURL: type != "video" ? file.url : nil,
                        fileType: type,
                        VideoURl: type == "video" ? URL(string: file.url ?? "") : nil
                    )
                }
            }
            updateTextViewHeight(contentTextView)
            editId = notice.id
            chooseRecipientsBtn.setTitle("Update", for: .normal)
            cancelBtn.isHidden = false
        } else {
            assignTitleTxtFld.text = ""
            contentTextView.text = CommonStringFile.Description.translated()
            contentTextView.textColor = .lightGray
            placeholderLabel?.isHidden = false
            
            attachments.removeAll()
            editId = nil
            chooseRecipientsBtn.setTitle("Next", for: .normal)
        }
        selectImgPdfview.imageCollectionview.reloadData()
        updateCollectionHeight()
    }
    
  
    
    // MARK: - Image / PDF selection
    func imageSelection(){
        
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            
            attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            //            attachments.removeAll { $0.fileType != CommonStringFile.IMAGE }
            
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
        if attachments.count != 10{
            PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    func selectPDF() {
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
    
    @IBAction func cancel(_ sender: UIButton) {
        assignTitleTxtFld.text = ""
        contentTextView.text = ""
        placeholderLabel.isHidden = !contentTextView.text.isEmpty
        attachments.removeAll()
        selectImgPdfview.imageCollectionview.reloadData()
        editId = nil
        
        chooseRecipientsBtn.setTitle("Next", for: .normal)
        cancelBtn.isHidden = true
        updateTextViewHeight(contentTextView)
        delegate?.editDta(edit: nil)
    }
    @IBAction func chooseRecipientsAction(_ sender: UIButton) {
        let title = assignTitleTxtFld.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !title.isEmpty, contentTextView.text?.count != 0 else {
            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Alert_title,
                                              message: AlertstringFile.Fill_All_Required_Fields,
                                              on: self)
            return
        }
        let dateBtnTitle = dateLbl.text ?? ""
        let submissionDate = ConvertDateStringSmart(dateBtnTitle) // Kept as your helper
        
        var params: [String: Any] = [
            assignmentResquestStringKey.title: title,
            assignmentResquestStringKey.description: contentTextView.text ?? "",
            assignmentResquestStringKey.category: categoryDropDownLbl.text ?? "",
            assignmentResquestStringKey.submission_date: submissionDate
        ]
        
        user_inputs.VideoPath = selectedVideoURL
        user_inputs.SelectedUrls = attachments
        if sender.titleLabel?.text == "Update"{
            let com = commonApi_forSending()
            params[SendAttachmentStringFile.id] = editId
            com.SendingAttachmentFlow(
                selectedAcadimicYearId: 0,
                edit: true,
                target_type:0,
                selectedId: [],
                baseURL: ServiceUrl.comm_api_assignment_update,
                subjectId: "",
                message:"",
                from: self,
                Common_request_params: params,
                isBaseUrl: true
            ) { response in
                DispatchQueue.main.async {
                    CircularProgressLoader.shared.hide()
                    CustomAlert.showAlertWithOkAction(
                        title: AlertstringFile.Success,
                        message: response.message,
                        on: self
                    ) { [self] in
                        assignTitleTxtFld.text = ""
                        contentTextView.text = ""
                        placeholderLabel.isHidden = !contentTextView.text.isEmpty
                        attachments.removeAll()
                        selectImgPdfview.imageCollectionview.reloadData()
                        editId = nil
                        
                        chooseRecipientsBtn.setTitle("Next", for: .normal)
                        cancelBtn.isHidden = true
                        updateTextViewHeight(contentTextView)
                        self.dismiss(animated: true)
                    }
                }
            }
            
        }else{
            let vc = RecipientVc(nibName: nil, bundle: nil)
            vc.Common_request_params = params
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        
    }
    
    @objc func categoryDropdown() {
        dropDown.dataSource = ["GENERAL", "CLASS WORK", "PROJECT", "RESEARCH PAPER"]
        view.layoutIfNeeded()
        dropDown.anchorView = categoryDropDownView
        dropDown.bottomOffset = CGPoint(x: 0, y: dropDown.anchorView?.plainView.bounds.height ?? 0)
        dropDown.direction = .bottom
        dropDown.selectionAction = { [weak self] (_, item: String) in
            self?.categoryDropDownLbl.text = item
        }
        dropDown.show()
    }
    
   
    // MARK: - QLPreviewControllerDataSource
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return DocumentpreviewURL == nil ? 0 : 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return (DocumentpreviewURL as NSURL?) ?? NSURL(fileURLWithPath: "")
    }
    
    // MARK: - Keyboard
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let kbHeight = frame.height
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kbHeight + 30, right: 0)
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        scrollToView(contentTextView)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    // MARK: - Helpers
    func scrollToView(_ view: UIView) {
        let rect = view.convert(view.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    func updateTextViewHeight(_ textView: UITextView) {
        let size = textView.contentSize
        let newHeight = max(60, min(size.height, maxHeight))
        TextviewHeight.constant = newHeight
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    func updateCollectionHeight() {
        let totalItems = attachments.count
        addphotosheight.constant = totalItems > 0 ? 20 : 20
        view.layoutIfNeeded()
    }
    
}

// MARK: - CollectionView
@available(iOS 14.0, *)
extension SenderAssignmentTextViewController: UICollectionViewDelegate,
                                              UICollectionViewDataSource,
                                              UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView,cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.AttachmentCVCell,for: indexPath) as! AttachmentCVCell
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
            }else{
                cell.imageViews.image = nil
            }
            let totalItems = attachments.count
            collectionViewHeght.constant = totalItems <= 2 ? 120 : collectionView.collectionViewLayout.collectionViewContentSize.height
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalSpacing: CGFloat = 30 // as per your comment
        let width = (selectImgPdfview.imageCollectionview.frame.width - totalSpacing) / 3
        return CGSize(width: width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let alertController = UIAlertController(title: "Select".translated(),
                                                    message: "Choose an option".translated(),
                                                    preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Camera".translated(), style: .default) { [weak self] _ in
                self?.openCamera()
            })
            alertController.addAction(UIAlertAction(title: "Gallery".translated(), style: .default) { [weak self] _ in
                self?.selectImages()
            })
            alertController.addAction(UIAlertAction(title: "Document".translated(), style: .default) { [weak self] _ in
                self?.selectPDF()
            })
            alertController.addAction(UIAlertAction(title: "Video", style: .default) { [weak self] _ in
                self?.VideoPick()
            })
            alertController.addAction(UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil))
            
            present(alertController, animated: true)
        } else {
            let attachment = attachments[indexPath.item - 1]
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.attachment = attachments
            imageVC.subjectName = "Event"
            imageVC.scrollIndex = indexPath
            imageVC.index = indexPath.row - 1
            imageVC.type = attachment.fileType
            imageVC.modalPresentationStyle = .fullScreen
            present(imageVC, animated: true)
        }
    }
}

// MARK: - UITextViewDelegate
@available(iOS 14.0, *)
extension SenderAssignmentTextViewController: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        updateTextViewHeight(textView)
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        updateTextViewHeight(textView)
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        scrollToView(textView)
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
