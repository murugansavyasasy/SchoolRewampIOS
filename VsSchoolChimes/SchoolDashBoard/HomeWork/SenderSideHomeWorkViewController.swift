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
    
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        uploadAttachmentView.imageCollectionview.reloadData()
    }
    
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ToStdOrSecBtnBottom: NSLayoutConstraint!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var CalenderViewTodateBtnTop: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var ReportView: UIView!
    @IBOutlet weak var TV: UITableView!
    @IBOutlet weak var SectionView: UIView!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var StandardView: UIView!
    @IBOutlet weak var CalendarView: UIView!
    @IBOutlet weak var homeworkBtn: UIButton!
    @IBOutlet weak var ReportBtn: UIButton!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var Buttonstackview: UIStackView!
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
    @IBOutlet weak var calenderHeight: NSLayoutConstraint!
    @IBOutlet weak var SectionLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var CustomDateBtn: HalfColorButton!
    @IBOutlet weak var customDateLbl: UILabel!
    @IBOutlet weak var acidamicYrDropView: UIView!
    @IBOutlet weak var acodumicYearLbl: UILabel!
    
    @IBOutlet weak var acodomicYearLbl: UILabel!
    @IBOutlet weak var acodumicHeight: NSLayoutConstraint!
    @IBOutlet weak var datePicker: UIDatePicker!
    var selectedImages: [UIImage] = []
    var selectedImgUrl: [FilePath] = []
    var url : URL?
    let photoPickManager = PhotoPickerManager.shared
    let Img = ImageName()
    let formatter = DateFormatter()
    let standardDropdown = DropDown()
    let SectionDropdown = DropDown()
    let acidamicdrops = DropDown()
    var image = "image/pdf"
    var delegate : HistorySelectDelegate?
    let customdate = DateFormatter()
    let initialHeight: CGFloat = 60
    let maxHeight: CGFloat = 300
    var homeWorkList:[Homework]?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let  staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var sectionsDetails: [sectionsDetail]?
    var standardDetails: [StandardDetail]?
    var sectionList = [String]()
    var standerdList = [String]()
    var AcadimicYearDatas : [AcadimicYearData] = []
    var accadimYr :[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        acodumicYearLbl.isHidden = true
        acidamicYrDropView.isHidden = true
        acodumicHeight.constant = 0
        selectDate()
        getacadmicYr()
        BackBtn.applyBackButton()
        DetailsTxtview.applyRightTxt()
        TitleTxtfield.applyRightTxt()
        wordsCountLbl.applyRightTxt()
        NotificationCenter.default.addObserver( self,selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification,object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),name: UIResponder.keyboardWillHideNotification, object: nil)
        
        TitleTxtfield.addDoneButton()
        DetailsTxtview.addDoneButton()
        StyleAndTranslater()
        SearchBar.isHidden = true
        uploadAttachmentView.imageCollectionview.delegate = self
        uploadAttachmentView.imageCollectionview.dataSource = self
        TV.delegate = self
        TV.dataSource = self
        DetailsTxtview.delegate = self
        
        let nib = UINib(nibName: CellConfingName.ImageCvCell, bundle: nil)
        uploadAttachmentView.imageCollectionview.register(nib, forCellWithReuseIdentifier: CellConfingName.ImageCvCell)
        
        let imgPdfTV = UINib(nibName:CellConfingName.NoticeBoardTvcellTableViewCell, bundle: nil)
        TV.register(imgPdfTV, forCellReuseIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell)
        
        let voiceTV = UINib(nibName:CellConfingName.HomeworkreportTV, bundle: nil)
        TV.register(voiceTV, forCellReuseIdentifier: CellConfingName.HomeworkreportTV)
        
        let standardTap = UITapGestureRecognizer(target: self, action: #selector(SelectStandard))
        StandardView.addGestureRecognizer(standardTap)
        
        let sectionTap = UITapGestureRecognizer(target: self, action: #selector(SelectSection))
        SectionView.addGestureRecognizer(sectionTap)
        let acidmaciyrClick = UITapGestureRecognizer(target: self, action:
                                                        #selector(academicYearDrop_action))
        acidamicYrDropView.addGestureRecognizer(acidmaciyrClick)
        acidamicYrDropView.layer.cornerRadius = 4
        acidamicYrDropView.layer.shadowColor = UIColor.black.cgColor
        acidamicYrDropView.layer.shadowOffset = CGSize(width: 0, height: 2)
        acidamicYrDropView.layer.shadowRadius = 5
        acidamicYrDropView.layer.shadowOpacity = 0.3
        acidamicYrDropView.layer.cornerRadius = 8
        ComposeHomeworkView.isHidden = false
        ComposeHomeworkView.alpha = 1
        ReportView.isHidden = true
        ReportView.alpha = 0
        calenderHeight.constant = 0
        imageSelection()
    }
    @IBAction func academicYearDrop_action() {
        accadimYr.removeAll()
        for i in 0..<(AcadimicYearDatas.count) {
            accadimYr.append(AcadimicYearDatas[i].year ?? "")
        }
        acidamicdrops.anchorView = acidamicYrDropView
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acidamicYrDropView.bounds.height)
        acidamicdrops.show()
        
        acidamicdrops.selectionAction = { [self] (index: Int, item: String) in
            acodomicYearLbl.text = item
        }
        
    }
    func getacadmicYr(){
        APIService.shared
            .makeApi(url: ServiceUrl.comm_recipient_get_academic_year_list , parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <get_academic_yearSuc,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            //                        listTable.isHidden = true
                            AcadimicYearDatas = successMessage.data ?? []
                            for i in 0..<(AcadimicYearDatas.count){
                                if AcadimicYearDatas[i].current_academic_year ?? false == true{
                                    acodomicYearLbl.text = AcadimicYearDatas[i].year
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func StyleAndTranslater(){
        //MARK: UI Update
        TextViewheight.constant = initialHeight
        Buttonstackview.layer.cornerRadius = 20
        homeworkBtn.layer.cornerRadius = 20
        ReportBtn.layer.cornerRadius = 20
        DetailsTxtview.layer.cornerRadius = 10
        DetailsTxtview.layer.borderWidth = 1
        DetailsTxtview.layer.borderColor = UIColor.lightGray.cgColor
        RecipientBtn.layer.cornerRadius = 10
        CalendarView.layer.cornerRadius = 10
        CalendarView.layer.borderWidth = 1
        CalendarView.layer.borderColor = UIColor.lightGray.cgColor
        SectionView.layer.cornerRadius = 10
        StandardView.layer.cornerRadius = 10
        DetailsTxtview.text = CommonStringFile.Description
        DetailsTxtview.textColor = .lightGray
        CustomDateBtn.layer.cornerRadius = 10
        CustomDateBtn.layer.borderWidth = 1
        CustomDateBtn.layer.borderColor = UIColor.gray.cgColor
        customdate.dateFormat = "EEE d"
        let customdatestring = customdate.string(from: Date())
        setcustomDate(attributedLbl: customdatestring)
        
        //MARK: set Gradient colours for Button
        gradientcolours(button: homeworkBtn, colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        
        gradientcolours(button: ReportBtn, colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        ReportBtn.setTitleColor(UIColor.black, for: .normal)
        
        //MARK: Button Font Style
        dateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        homeworkBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        ReportBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        RecipientBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        
        //MARK: Label Font Style
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        DetailsLbl.setFont(style: .title, size: FontSize.TitleSize)
        wordsCountLbl.setFont(style: .body, size: FontSize.BodySize)
        uploadattachmentLbl.setFont(style: .title, size: FontSize.TitleSize)
        StandardLbl.setFont(style: .title, size: FontSize.TitleSize)
        SectionLbl.setFont(style: .title, size: FontSize.TitleSize)
        
    }
    
    @IBAction func datePicker(_ sender: UIDatePicker) {
        selectDate(date: sender.date)
    }
    
//    func showDatepicker(){
////        let datePicker = UIDatePicker()
////        datePicker.datePickerMode = .date
////        datePicker.preferredDatePickerStyle = .inline
////
////        datePicker.maximumDate = Date()
////        let calendar = Calendar.current
////        if let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) {
////            datePicker.minimumDate = thirtyDaysAgo
////        }
////        datePicker.transform = CGAffineTransform(scaleX: 0.75, y: 0.65)
////        datePicker.frame = CalendarView.bounds
////        datePicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
////        CalendarView.addSubview(datePicker)
//        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
//    }
//    
//    @objc func dateChanged(_ sender: UIDatePicker) {
//        
//    }
    func selectDate(date: Date = Date()) {
        formatter.dateFormat = "EEE d MMM yyyy"
        let label = formatter.string(from: date)
        
        calenderHeight.constant = 0
        CalenderViewTodateBtnTop.constant = 0
        CalendarView.isHidden = true
        dateBtn.isHidden = false
        dateBtn.setTitle(label, for: .normal)
        dateBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)

        customdate.dateFormat = "EEE d"
        let attributedLbl = customdate.string(from: date)
        setcustomDate(attributedLbl: attributedLbl)
    }

    @IBAction func SelectStandard() {
        // Setup dropdown anchor and data source
           standardDropdown.anchorView = StandardView
           standardDropdown.dataSource = standerdList
           standardDropdown.bottomOffset = CGPoint(x: 0, y: StandardView.bounds.height)
           standardDropdown.direction = .bottom
           standardDropdown.show()

           standardDropdown.selectionAction = { [weak self] (index: Int, item: String) in
               guard let self = self else { return }
               guard let selectedSections = standardDetails?[index].sections else { return }
               sectionsDetails = selectedSections
               sectionList.removeAll()
               sectionList.append(contentsOf: selectedSections.compactMap { $0.name })
               SectionLbl.text = selectedSections.first?.name ?? ""
               if let label = self.StandardView.subviews.compactMap({ $0 as? UILabel }).first {
                   label.text = item
               }

               self.CalendarView.isHidden = true
               self.calenderHeight.constant = 0
               self.CalenderViewTodateBtnTop.constant = 0
           }
        
        
    }
    
    @IBAction func SelectSection() {
        SectionDropdown.anchorView = SectionView
        SectionDropdown.dataSource = sectionList
        SectionDropdown.show()
        SectionDropdown.bottomOffset = CGPoint(x: 0, y: SectionView.bounds.height)
        standardDropdown.direction = .bottom
        SectionDropdown.selectionAction = { [self] (index: Int, item: String) in
            
            if index < sectionsDetails?.count ?? 0{
                GetHomeWorkReport(sectionsDetails?[index].id, dateBtn.titleLabel?.text ?? "")
            }
            if let label = SectionView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.text = item
            }
            
            CalendarView.isHidden = true
            calenderHeight.constant = 0
            CalenderViewTodateBtnTop.constant = 0
            SearchBar.isHidden = false
            TV.isHidden = false
            TV.reloadData()
        }
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
    
    @IBAction func HomeworkBtnAct(_ sender: Any) {
        
        ToStdOrSecBtnBottom.constant = 50
        acodumicHeight.constant = 0
        gradientcolours(button: homeworkBtn,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        homeworkBtn.setTitleColor(.white, for:.normal)
        ReportBtn.backgroundColor = .clear
        
        gradientcolours(button: ReportBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        ReportBtn.setTitleColor(.black, for:.normal)
        acodumicYearLbl.isHidden = true
        acidamicYrDropView.isHidden = true
        ReportView.isHidden = true
        ReportView.alpha = 0
        ComposeHomeworkView.isHidden = false
        ComposeHomeworkView.alpha = 1
    }
    
    @IBAction func ReportsBtnAct(_ sender: Any) {
        let screenHeight = UIScreen.main.bounds.height
        //ToStdOrSecBtnBottom.constant = screenHeight - 600
        ToStdOrSecBtnBottom.constant = screenHeight * 0.35  // 35% of screen height
        gradientcolours(button: ReportBtn,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        ReportBtn.setTitleColor(.white, for:.normal)
        homeworkBtn.backgroundColor = .clear
        
        gradientcolours(button: homeworkBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        homeworkBtn.setTitleColor(.black, for:.normal)
        acodumicYearLbl.isHidden = false
        acidamicYrDropView.isHidden = false
        acodumicHeight.constant = 38
        ComposeHomeworkView.isHidden = true
        ComposeHomeworkView.alpha = 0
        ReportView.isHidden = false
        ReportView.alpha = 1
        datePicker.transform = CGAffineTransform(scaleX: 0.90, y: 0.95)
        // Set max date to today
        datePicker.maximumDate = Date()

        // Set min date to 2 months ago
        if let twoMonthsAgo = Calendar.current.date(byAdding: .month, value: -2, to: Date()) {
            datePicker.minimumDate = twoMonthsAgo
        }
        getStandardsAPI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.TV.reloadData()
        }
    }
    
    @IBAction func backAction() {
        dismiss(animated: true)
    }
    
    @IBAction func DateBtnAct(_ sender: Any) {
        
        if calenderHeight.constant == 0 {
            CalendarView.isHidden = false
            calenderHeight.constant = 260
            CalenderViewTodateBtnTop.constant = 25
            dateBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        }else{
            CalendarView.isHidden = true
            calenderHeight.constant = 0
            CalenderViewTodateBtnTop.constant = 0
            dateBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        }
    }
    
    func setcustomDate(attributedLbl: String) {
        let components = attributedLbl.split(separator: " ")
        guard components.count == 2,
              let weekday = components.first,
              let day = components.last else {
            print("Error: Invalid format for attributedLbl. Expected 'EEE d', got: \(attributedLbl)")
            return
        }
        
        // Fonts for different parts
        let weekdayFont = UIFont.systemFont(ofSize: 12)
        let dayFont = UIFont.boldSystemFont(ofSize: 22)
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: "\(weekday)\n", attributes: [
            .font: weekdayFont,
            .foregroundColor: UIColor.gray
        ]))
        
        // Add the day (e.g., "23")
        attributedString.append(NSAttributedString(string: "\(day)", attributes: [
            .font: dayFont,
            .foregroundColor: UIColor.black
        ]))
        
        // Set paragraph style for centered alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        // Assign the attributed string to the label
        customDateLbl.attributedText = attributedString
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
extension SenderSideHomeWorkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeWorkList?.count ?? 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell, for: indexPath) as! NoticeBoardTvcellTableViewCell
        
        cell.cellview.changeHeightAndAnimate(40, 150, 100, 80, top: 5)
        cell.ishomework = true
        cell.delegate = self
        cell.pagecontrollerheight.constant = 26
        cell.pagecontroller.isHidden = false
//        cell.SelectBtn.isHidden = true
        cell.newView.isHidden = true
        let data = homeWorkList?[indexPath.row]
        
        cell.HomeworkSubjectLbl.text = data?.subject_name
        cell.TitleLbl.text = data?.topic ?? ""
        cell.datelbl.text = dateBtn.titleLabel?.text ?? ""
        if let urls = data?.file_path {
            cell.loadImage(urls: urls)
            cell.CVHeight.constant = 120
        }else{
            cell.CVHeight.constant = 0
        }
        cell.dicriptContent.configure(text: data?.content ?? "")
        cell.dicriptContent.onTap = {
            cell.dicriptContent.isExpanded.toggle()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        return cell
    }

    func didTapButton(title: String, content: String, items: [FilePath]) {
        TitleTxtfield.text = title
        DetailsTxtview.text = title
        selectedImgUrl = items
        uploadAttachmentView.imageCollectionview.reloadData()
        ToStdOrSecBtnBottom.constant = 50
        acodumicHeight.constant = 0
        gradientcolours(button: homeworkBtn,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        homeworkBtn.setTitleColor(.white, for:.normal)
        ReportBtn.backgroundColor = .clear
        
        gradientcolours(button: ReportBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        ReportBtn.setTitleColor(.black, for:.normal)
        acodumicYearLbl.isHidden = true
        acidamicYrDropView.isHidden = true
        ReportView.isHidden = true
        ReportView.alpha = 0
        ComposeHomeworkView.isHidden = false
        ComposeHomeworkView.alpha = 1
        DetailsTxtview.textColor = .black
        wordsCountLbl.text = "\(DetailsTxtview.text.count) of 500"
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = homeWorkList?[indexPath.row] else {
            return UITableView.automaticDimension
        }

        let contentWidth = tableView.frame.width - 40
        
        let subjectFont = UIFont.systemFont(ofSize: 22)
        let titleFont = UIFont.boldSystemFont(ofSize: 20)
        let descriptionFont = UIFont.systemFont(ofSize: 20)

        let subjectText = item.subject_name ?? ""
        let titleText = item.topic ?? ""
        let descriptionText = item.content ?? ""

        let subjectHeight = subjectText.boundingHeight(width: contentWidth, font: subjectFont)
        let titleHeight = titleText.boundingHeight(width: contentWidth, font: titleFont)
        let descriptionHeight = descriptionText.boundingHeight(width: contentWidth, font: descriptionFont)

        let hasFiles = item.file_path?.isEmpty == false
        let collectionViewHeight: CGFloat = hasFiles ? 120 : 0

        let totalHeight = subjectHeight + titleHeight + descriptionHeight + collectionViewHeight + 135

        return totalHeight + 35
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
    func GetHomeWorkReport(_ sectionId:String?,_ dates:String?){
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        let date = ConvertDateStringSmart(dates)
        APIService.shared
            .makeApi(url:  ServiceUrl.comm_homework_get_homework_report , parameters: ["section_id":sectionId ?? "","date":date] , type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? ""){ [self] (
                result : Result<HomeworkResponse,
                Error>
            ) in
                
                switch result {
                    
                case.success(let succesmessage) :
                    if succesmessage.status == true {
                        
                        DispatchQueue.main.async { [self] in
                            
                            homeWorkList = succesmessage.data
                            TV.reloadData()
                            if #available(iOS 15.0, *) {
                                hideLottieProgressLoader()
                            }
                        }
                    }else {
                        DispatchQueue.main.async { [self] in
                            homeWorkList = succesmessage.data
                            TV.reloadData()
                            if #available(iOS 15.0, *) {
                                hideLottieProgressLoader()
                            }
                        }
                    }
                case.failure(let error) :
                    
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                        if #available(iOS 15.0, *) {
                            hideLottieProgressLoader()
                        }
                    }
                }
                
            }
    }
    func getStandardsAPI(){
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: ["academic_year_id":"6"], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "") { [self] (result:Result <GetStandardsSuc,Error>) in
            switch result {
            case .success(let successMessage):
                print("successsuccess",successMessage.data)
                
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
 
                        standardDetails = successMessage.data
                        standardDetails?.enumerated().forEach { index, student in
                            standerdList.append(student.name ?? "")
                        }
                        if let sections = standardDetails?.first?.sections{
                            sectionsDetails = sections
                            for j in 0..<sections.count {
                                sectionList.append(sectionsDetails?[j].name ?? "")
                            }
                        }
                        GetHomeWorkReport(standardDetails?.first?.sections?.first?.id, dateBtn.titleLabel?.text ?? "")
                        StandardLbl.text = standardDetails?.first?.name
                        SectionLbl.text = standardDetails?.first?.sections?.first?.name ?? ""
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
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


