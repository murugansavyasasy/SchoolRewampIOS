//
//  EventsVC.swift
//  VsSchoolChimes
//
//  Created by admin on 02/12/24.
//

import UIKit
import AWSCore
import AWSS3
import AVFoundation
import AVKit

protocol DeleteImge{
    func deleteImage(index:Int)
}
@available(iOS 14.0, *)
class EventsVC: UIViewController, UIDocumentPickerDelegate, DeleteImge, Datepicker, UIImagePickerControllerDelegate & UINavigationControllerDelegate{
    
    func date(date: String) {
        setInitialButtonTitles(date: date)
    }
    
    
    func deleteImage(index: Int) {
        attachments.remove(at: index)
        costomView.imageCollectionview.reloadData()
    }
    var effect:UIVisualEffect!
    
    @IBOutlet weak var selectCatagoriesTitle: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tittleCountLbl: UILabel!
    @IBOutlet weak var eventTxt: UITextField!
    @IBOutlet weak var EventTtleLbl: UILabel!
    @IBOutlet weak var placeTxt: UITextField!
    @IBOutlet weak var placeLbl: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var costomView: ImageSelection!
    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var TxtOuterview: UIView!
    @IBOutlet weak var contentCount: UILabel!
    @IBOutlet weak var eventDeatail: UILabel!
    @IBOutlet weak var addPhotoLbl: UILabel!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var viewHisrtoryBtn: UIButton!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var catagoryDropDownView: UIView!
    @IBOutlet weak var selectedCatagoryImg: UIImageView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateSelectionView: UIView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var selecctedCatagory: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backBtn: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var timeBtn: UIButton!
    
    var placeholderLabel: UILabel!
    var timePicker: UIDatePicker!
    var doneButton2: UIButton!
    var time = "Jan\n15"
    var dateSelection = false
    var url : URL?
    let photoPickManager = PhotoPickerManager.shared
    let AlertMessage = AlertstringFile()
    var isKeyboardVisible = false
    let dateFormatter = DateFormatter()
    let timeFormatter = DateFormatter()
    var initialHeight : CGFloat = 60
    var maxHeight : CGFloat = 300
    var attachments: [AttachmentItem] = []
    var videoPicker: VideoPickerManager?
    var delegate:EditObjectDelegate?
    var selectedVideoURL: URL?
    var images = [String]()
    var dropDownList = [String]()
    var eventListRespons : [EventCategory]?
    var editId: String?
    let dropDown = DropDown()
    var editReport:EventList?
    var categoryId:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        backBtn.configureAsBackTitle(firstLine: "Event", secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        eventTxt.placeholder = CommonStringFile.Title.translated()
        
        dateView.layer.borderColor = UIColor.lightGray.cgColor
        dateView.layer.borderWidth = 0.5
        dateView.layer.cornerRadius = 8
        dateBtn.layer.cornerRadius = 8
        timeView.layer.cornerRadius = 8
        dateBtn.backgroundColor = .blue.withAlphaComponent(0.6)
        timeView.layer.borderColor = UIColor.lightGray.cgColor
        timeView.layer.borderWidth = 0.5
        eventTxt.delegate = self
        contentTxtView.delegate = self
        eventTxt.applyRightTxt()
        EventTtleLbl.applyRightTxt()
        placeTxt.applyRightTxt()
        placeLbl.applyRightTxt()
        contentTxtView.applyRightTxt()
        contentCount.applyRightTxt()
        eventDeatail.applyRightTxt()
        addPhotoLbl.applyRightTxt()
        fromLbl.applyRightTxt()
        eventTxt.applyRightTxt()
        StyleAndTranslate()
        setupTimePicker()
        setInitialButtonTitles(date:nil)
        registerCell()
        setupPlaceholder()
        placeTxt.addDoneButton()
        eventTxt.addDoneButton()
        contentTxtView.addDoneButton()
        imageSelection()
        costomView.imageCollectionview.backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(catagoryTapped))
        catagoryDropDownView.isUserInteractionEnabled = true
        catagoryDropDownView.addGestureRecognizer(tapGesture)
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
            fetchData(eventList: edit)
        }
        viewHisrtoryBtn.setShadow()
        let dateTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectDateTapped))
        dateSelectionView.isUserInteractionEnabled = true
        dateSelectionView.addGestureRecognizer(dateTapGesture)
    }
    @objc private func selectDateTapped() {
        dateSelection = true
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.minimumDate = Date()
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        get_CatagoryListApi()
    }
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
    }
    func fetchData(eventList: EventList?) {
        attachments.removeAll()
        
        if let eventList = eventList {
            placeTxt.text = eventList.venue ?? ""
            eventTxt.text = eventList.title ?? ""
            contentTxtView.text = eventList.description ?? ""
            placeholderLabel.isHidden = !(contentTxtView.text?.isEmpty ?? true)
            
            if let filePaths = eventList.file_path {
                let imageItems: [AttachmentItem] = filePaths.compactMap { file in
                    guard let url = file.url else { return nil }
                    let type = file.type?.lowercased() ?? ""
                    return AttachmentItem(
                        image: nil,
                        imageURL: type != "video" ? url : nil,
                        fileType: type,
                        VideoURl: type == "video" ? URL(string: url) : nil
                    )
                }
                attachments = imageItems
            }
            
            costomView.imageCollectionview.reloadData()
            editId = eventList.id
            
            if let category = eventList.category,
               let event = self.eventListRespons?.first(where: { $0.name == category }) {
                self.selecctedCatagory.text = event.name
                if let urlString = event.url, let url = URL(string: urlString) {
                    self.selectedCatagoryImg.kf.setImage(with: url)
                }
            }
            
            nextBtn.setTitle("Update", for: .normal)
            updateTextViewHeight(contentTxtView)
        } else {
            placeTxt.text = ""
            eventTxt.text = ""
            contentTxtView.text = ""
            placeholderLabel.isHidden = true
            attachments.removeAll()
            costomView.imageCollectionview.reloadData()
            editId = nil
            
            nextBtn.setTitle("Next", for: .normal)
            updateTextViewHeight(contentTxtView)
        }
    }
    func updateTextViewHeight(_ textView: UITextView) {
        let size = textView.contentSize
        let newHeight = min(size.height, maxHeight)
        textViewHeightConstraint.constant = newHeight
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func get_CatagoryListApi() {
        APIService.shared.makeApi(url: ServiceUrl.admin_api_school_event_categories, parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "") { [weak self] (result: Result<EventCategoryResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.status {
                    DispatchQueue.main.async {
                        self.eventListRespons = response.data
                        self.dropDownList.removeAll()
                        self.images.removeAll()
                        self.selecctedCatagory.text = self.eventListRespons?.first?.name
                        self.selectedCatagoryImg.kf.setImage(with: URL(string: response.data.first?.url ?? ""))
                        for item in response.data {
                            self.dropDownList.append(item.name ?? "")
                            self.images.append(item.url ?? "")
                        }
                        
                        self.dropDown.dataSource = self.dropDownList
                        self.dropDown.imageURLs = self.images
                        
                        for index in 0..<self.images.count {
                            if let cell = self.dropDown.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? DropDownCell {
                                self.dropDown.configureCell(cell, at: index)
                            }
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func imageSelection(){
        
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            
            attachments.append(AttachmentItem(image: image, imageURL: nil, fileType: CommonStringFile.IMAGE))
            //            attachments.removeAll { $0.fileType != CommonStringFile.IMAGE }
            
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            costomView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            user_inputs.selectedFileType = CommonStringFile.IMAGE
            
            let imageItems = images.map {
                AttachmentItem(image: $0, imageURL: nil, fileType: CommonStringFile.IMAGE)
            }
            attachments.append(contentsOf: imageItems)
            costomView.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onFilePicked = { [self] data in
            // handle picked PDF
            user_inputs.selectedFileType = CommonStringFile.pdf
            attachments.append(AttachmentItem(image:nil, imageURL: data.absoluteString, fileType: CommonStringFile.pdf))
            costomView.imageCollectionview.reloadData()
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
            costomView.imageCollectionview.reloadData()
        }
    }
    
    @objc func catagoryTapped() {
        dropDown.anchorView = catagoryDropDownView
        dropDown.show()
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y: catagoryDropDownView.bounds.height)
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            selectedCatagoryImg.kf.setImage(with: URL(string: images[index]))
            selecctedCatagory.text = item
            categoryId = eventListRespons?.filter{$0.name == item}.first?.id
        }
    }
    
    func setInitialButtonTitles(date dateString: String?, inputFormat: String = "dd MMM yyyy") {
        let savedCode = UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en"
        let localeID = normalizedLocaleIdentifier(for: savedCode)
        let locale = Locale(identifier: localeID)
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = inputFormat
        
        let dateToUse: Date
        if let dateString = dateString, let parsed = parser.date(from: dateString) {
            dateToUse = parsed
        } else {
            dateToUse = Date()
        }
        let displayDateFormatter = DateFormatter()
        displayDateFormatter.locale = locale
        displayDateFormatter.dateFormat = "dd MMM yyyy"
        
        let displayTimeFormatter = DateFormatter()
        displayTimeFormatter.locale = locale
        displayTimeFormatter.timeStyle = .short
        
        let dayFormatter = DateFormatter()
        dayFormatter.locale = locale
        dayFormatter.dateFormat = "EEEE"
        dateLbl.text = displayDateFormatter.string(from: dateToUse)
        timeBtn.setTitle(displayTimeFormatter.string(from: dateToUse), for: .normal)
        dayLbl.text = dayFormatter.string(from: dateToUse)
        
        contentCount.applyRightTxt()
    }
    
    func StyleAndTranslate(){
        catagoryDropDownView.setShadow(cornerRadius: 8)
        fromLbl.setFont(style: .title, size: FontSize.TitleSize)
        addPhotoLbl.setFont(style: .title, size: FontSize.TitleSize)
        tittleCountLbl.setFont(style: .body, size: FontSize.BodySize)
        
        contentCount.setFont(style: .body, size: FontSize.BodySize)
        placeLbl.setRequiredText(CommonStringFile.Venue.translated())
        EventTtleLbl.setRequiredText(CommonStringFile.Title.translated())
        selectCatagoriesTitle.setRequiredText(CommonStringFile.SelectCatagorie.translated())
        eventDeatail.setRequiredText(CommonStringFile.Description.translated())
        fromLbl.setRequiredText(CommonStringFile.Starts_on.translated())
        addPhotoLbl.text = CommonStringFile.UploadImagepdfoptional.translated()
        placeTxt.placeholder = CommonStringFile.egChennai.translated()
        
        setAttributedText(for: addPhotoLbl, with: CommonStringFile.Add_attachment_optional.translated(), firstString: CommonStringFile.Add_attachment.translated(), secondString: CommonStringFile.Optional.translated(), color1: .black, color2: .lightGray)
        
        contentTxtView.layer.cornerRadius = 10
        contentTxtView.layer.borderWidth = 1
        contentTxtView.layer.borderColor = UIColor.gray.cgColor
    }
    
    func registerCell(){
        costomView.imageCollectionview.delegate = self
        costomView.imageCollectionview.dataSource = self
    }
    
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.Description.translated()
        placeholderLabel.font = contentTxtView.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8)
        contentTxtView.applyRightTxt()
        contentTxtView.applyRightTxt(with: placeholderLabel)
        contentTxtView.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !contentTxtView.text.isEmpty
    }
    
    func setupTimePicker() {
        timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
        }
        timePicker.backgroundColor = .white
        timePicker.isHidden = true
        timePicker.minimumDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        self.view.addSubview(timePicker)
        doneButton2 = UIButton(type: .system)
        doneButton2.setTitle(AlertstringFile.Done, for: .normal)
        doneButton2.isHidden = true
        doneButton2.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        doneButton2.setTitleColor(.white, for: .normal)
        doneButton2.layer.cornerRadius = 8
        doneButton2.addTarget(self, action: #selector(selectedTime), for: .touchUpInside)
        self.view.addSubview(doneButton2)
    }
    
    @objc func selectedTime() {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let selectedTime = timePicker.date
        let formattedTime = timeFormatter.string(from: selectedTime)
        
        if dateSelection == true{
            timeBtn.setTitle(formattedTime, for: .normal)
        }
        timePicker.isHidden = true
        doneButton2.isHidden = true
    }
    
    
    func showTimePicker(for button: UIButton, date: Bool) {
        let buttonFrame = button.convert(button.bounds, to: self.view)
        timePicker.isHidden = false
        doneButton2.isHidden = false
        applyTimeRestrictionBasedOnSelectedDate()
        let pickerYPosition = buttonFrame.minY - 210
        timePicker.frame = CGRect(x: (self.view.frame.width - 250) / 2, y: pickerYPosition, width: 250, height: 200)
        timePicker.backgroundColor = .white
        timePicker.layer.shadowColor = UIColor.black.cgColor
        timePicker.layer.shadowOffset = CGSize(width: 0, height: 2)
        timePicker.layer.shadowRadius = 5
        timePicker.layer.shadowOpacity = 0.3
        timePicker.layer.cornerRadius = 20
        doneButton2.frame = CGRect(x: timePicker.frame.maxX - 80, y: pickerYPosition + timePicker.frame.height - 40, width: 70, height: 30)
        self.view.addSubview(timePicker)
        self.view.addSubview(doneButton2)
    }
    func applyTimeRestrictionBasedOnSelectedDate() {
        guard let selectedDateText = dateLbl.text else { return }
        
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        
        guard let selectedDate = df.date(from: selectedDateText) else { return }
        
        let today = Date()
        let calendar = Calendar.current
        
        if calendar.isDate(selectedDate, inSameDayAs: today) {
            timePicker.minimumDate = today
        } else {
            timePicker.minimumDate = nil
        }
    }
    
    @IBAction func ToTimeBtn(_ sender: UIButton) {
        showTimePicker(for: sender, date: false)
        dateSelection = true
    }
    @IBAction func chooseSchool(_ sender: UIButton) {
        
        if placeTxt.text?.count != 0 && eventTxt.text?.count != 0 && contentTxtView.text?.count != 0{
            
            user_inputs.SelectedUrls = attachments
            user_inputs.VideoPath = selectedVideoURL
            let date = convertDate(dateLbl?.text ?? "")
            var params: [String: Any] = [
                assignmentResquestStringKey.title: eventTxt.text ?? "",
                assignmentResquestStringKey.description: contentTxtView.text ?? "",
                assignmentResquestStringKey.venue: placeTxt.text ?? "",
                assignmentResquestStringKey.event_time: timeBtn.titleLabel?.text ?? "",
                assignmentResquestStringKey.event_date:date ?? "",
                assignmentResquestStringKey.category:categoryId ?? 0
            ]
            if sender.titleLabel?.text == "Update"{
                let com = commonApi_forSending()
                params[SendAttachmentStringFile.id] = editId
                com.SendingAttachmentFlow(
                    selectedAcadimicYearId: 0,
                    edit: true,
                    target_type:0,
                    selectedId: [],
                    baseURL: ServiceUrl.admin_api_school_event_update,
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
                            placeTxt.text = ""
                            eventTxt.text = ""
                            contentTxtView.text = ""
                            placeholderLabel.isHidden = !contentTxtView.text.isEmpty
                            attachments.removeAll()
                            costomView.imageCollectionview.reloadData()
                            editId = nil
                            
                            nextBtn.setTitle("Next", for: .normal)
                            updateTextViewHeight(contentTxtView)
                            self.dismiss(animated: true)
                        }
                    }
                }
                
            }else{
                let vc = RecipientVc(nibName: nil, bundle: nil)
                vc.ScreenType = Menu_id.event
                vc.Common_request_params = params
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "Alert", message: AlertstringFile.Fill_All_Required_Fields, on: self)
        }
        
    }
    
    @IBAction func viewHistory(_ sender: UIButton) {
        let vc = EventHistoryVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
//MARK: Collectionview Delegate Functions
@available(iOS 14.0, *)
extension EventsVC : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + attachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (costomView.imageCollectionview.frame.width - 30) / 3
        return CGSize(width: width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let remaining = Filecount.SelectImageAndDocumetCount - attachments.count
            
            if remaining > 0 {
                
                let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
                
                // Camera option
                let cameraAction = UIAlertAction(title: CommonStringFile.Camera, style: .default) { [self] _ in
                    openCamera()
                }
                alertController.addAction(cameraAction)
                let galleryAction = UIAlertAction(title: CommonStringFile.Photos, style: .default) { [self] _ in
                    selectImages()
                    //
                }
                alertController.addAction(galleryAction)
                let pdfAction = UIAlertAction(title: CommonStringFile.Document, style: .default) { [self] _ in
                    selectPDF()
                }
                alertController.addAction(pdfAction)
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
            
        }else {
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
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        controller.dismiss(animated: true, completion: nil)
        
    }
}
//MARK: Text view delegate Functions
@available(iOS 14.0, *)
extension EventsVC : UITextViewDelegate,UITextFieldDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return true
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        let size = textView.contentSize
        if size.height > initialHeight {
            let newHeight = min(size.height, maxHeight)
            textViewHeightConstraint.constant = newHeight
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        scrollToView(textView)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight+30, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            scrollToView(contentTxtView)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Reset the scroll view content inset
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    func scrollToView(_ view: UIView) {
        let rect = view.convert(view.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
}



class HalfColorButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        let coloredLayer = CALayer()
        coloredLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height * 0.4)
        coloredLayer.backgroundColor = UIColor.white.cgColor
        self.layer.sublayers?.removeAll(where: { $0 is CALayer })
        self.layer.addSublayer(coloredLayer)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
}
