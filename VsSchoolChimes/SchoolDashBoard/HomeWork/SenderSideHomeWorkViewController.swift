//
//  SenderSideHomeWorkViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/15/24.
//

import UIKit
import DropDown


@available(iOS 14.0, *)
class SenderSideHomeWorkViewController: UIViewController, DeleteImge, SelectNotice {
    
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        uploadAttachmentView.imageCollectionview.reloadData()
    }
    
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
    @IBOutlet weak var HeaderLbl: UILabel!
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
   
    var selectedImages: [UIImage] = []
    var url : URL?
    let photoPickManager = PhotoPickerManager.shared
    let Img = ImageName()
    let formatter = DateFormatter()
    let standardDropdown = DropDown()
    let SectionDropdown = DropDown()
    var image = "image/pdf"
    var delegate : HistorySelectDelegate?
    let customdate = DateFormatter()
    let initialHeight: CGFloat = 60
    let maxHeight: CGFloat = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add observers for keyboard notifications
        // Add observers for keyboard events

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
        StyleAndTranslater()
        uploadAttachmentView.imageCollectionview.delegate = self
        uploadAttachmentView.imageCollectionview.dataSource = self
        
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
        
        ComposeHomeworkView.isHidden = false
        ComposeHomeworkView.alpha = 1
        ReportView.isHidden = true
        ReportView.alpha = 0
        
        imageSelection()
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
//        NotificationCenter.default.removeObserver(self)
        
        
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

        //MARK: Label Font Style
        HeaderLbl.setFont(style: .header, size: FontSize.HeaderSize)
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        DetailsLbl.setFont(style: .title, size: FontSize.TitleSize)
        wordsCountLbl.setFont(style: .body, size: FontSize.BodySize)
        uploadattachmentLbl.setFont(style: .title, size: FontSize.TitleSize)
        StandardLbl.setFont(style: .title, size: FontSize.TitleSize)
        SectionLbl.setFont(style: .title, size: FontSize.TitleSize)

        //MARK: Text Field Font Style
        //TitleTxtfield.setFont(style: .body, size: FontSize.BodySize)

        //MARK: Text View Font Style
        //DetailsTxtview.setFont(style: .body, size: FontSize.BodySize)

    }
    
    func showDatepicker(){
        
        // Create a UIDatePicker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        // Use inline display style for iOS 14+
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        // Set maximum date to today
        datePicker.maximumDate = Date()
        // Calculate minimum date (30 days before today)
        let calendar = Calendar.current
        if let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) {
            datePicker.minimumDate = thirtyDaysAgo
        }
        
        // Scale down the entire calendar
        datePicker.transform = CGAffineTransform(scaleX: 0.75, y: 0.65) // Adjust scaling factors
        
        // Set frame and center it in the container view
        datePicker.frame = CalendarView.bounds
        datePicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add the date picker to the container view
        CalendarView.addSubview(datePicker)
        
        // Handle date selection
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        
        formatter.dateFormat = "EEE d MMM yyyy"
        print("Selected date: \(formatter.string(from: sender.date))")
        
        let label = formatter.string(from: sender.date)
        
        //   DateViewheight.constant = 25
        calenderHeight.constant = 0
        CalenderViewTodateBtnTop.constant = 0
        CalendarView.isHidden = true
        dateBtn.isHidden = false
        dateBtn.setTitle(label, for: .normal)
        dateBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        // calenderHeight.constant = 260
        customdate.dateFormat = "EEE d"
        let attributedLbl = customdate.string(from: sender.date)
        setcustomDate(attributedLbl: attributedLbl)
    }
    
    @IBAction func SelectStandard() {
        // Setup dropdown anchor and data source
        standardDropdown.anchorView = StandardView
        standardDropdown.dataSource = ["8th", "9th", "10th", "11th"]
        standardDropdown.bottomOffset = CGPoint(x: 0, y: StandardView.bounds.height)
        
        // Show the dropdown
        standardDropdown.show()
        
        // Handle the selection
        standardDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return } // Safely unwrap self
            
            print("Selected item: \(item) at index: \(index)")
            
            // Update the label inside the standardView
            if let label = self.StandardView.subviews.compactMap({ $0 as? UILabel }).first {
                label.text = item
            }
            
            // Perform additional actions when ID == 1
            
            self.CalendarView.isHidden = true
            self.calenderHeight.constant = 0
            self.CalenderViewTodateBtnTop.constant = 0
            
            //                self.TV.isHidden = false
            //                self.TV.delegate = self
            //                self.TV.dataSource = self
            //                self.TV.reloadData()
            
        }
    }
    
    @IBAction func SelectSection() {
        SectionDropdown.anchorView = SectionView
        SectionDropdown.dataSource = ["A", "B", "C", "D"]
        SectionDropdown.show()
        SectionDropdown.bottomOffset = CGPoint(x: 0, y: SectionView.bounds.height)
        
        SectionDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            print("Selected item: \(item) at index: \(index)")
            
            // Update the label inside the UIView
            if let label = self.SectionView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.text = item
            }
            
            CalendarView.isHidden = true
            calenderHeight.constant = 0
            CalenderViewTodateBtnTop.constant = 0
            self.TV.isHidden = false
            self.TV.delegate = self
            self.TV.dataSource = self
            self.TV.reloadData()
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
            for image in images {
                print("Selected image: \(image)")
                // photoPickManager.uploadAWS(image: image)
            }
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        photoPickManager.pdfUrl = { [weak self] pdfurl in
            guard let self = self else { return }
            selectedImages.removeAll()
            url = pdfurl.absoluteURL
            selectedImages.append(ImageName.pdf!)
            //            url = URL(string:pdfurl)
            //            photoPickManager.uploadPDFFileToAWS(pdfData: pdfData ?? Data())
            uploadAttachmentView.imageCollectionview.reloadData()
        }
        photoPickManager.onCameraImagePicked = { [weak self] images in
            guard let self = self else { return }
            // Handle selected images here
            
            if url != nil{
                selectedImages.removeAll()
                url = nil
            }
            selectedImages.append(images)
            uploadAttachmentView.imageCollectionview.reloadData()
        }
    }
    
    @IBAction func HomeworkBtnAct(_ sender: Any) {
        
        gradientcolours(button: homeworkBtn,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        homeworkBtn.setTitleColor(.white, for:.normal)
        ReportBtn.backgroundColor = .clear
        
        gradientcolours(button: ReportBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        ReportBtn.setTitleColor(.black, for:.normal)
        
        ReportView.isHidden = true
        ReportView.alpha = 0
        ComposeHomeworkView.isHidden = false
        ComposeHomeworkView.alpha = 1
    }
    
    @IBAction func ReportsBtnAct(_ sender: Any) {
        
        gradientcolours(button: ReportBtn,colours: [UIColor.blue.cgColor,UIColor.systemTeal.cgColor])
        ReportBtn.setTitleColor(.white, for:.normal)
        homeworkBtn.backgroundColor = .clear
        
        gradientcolours(button: homeworkBtn,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
        homeworkBtn.setTitleColor(.black, for:.normal)
        
        ComposeHomeworkView.isHidden = true
        ComposeHomeworkView.alpha = 0
        ReportView.isHidden = false
        ReportView.alpha = 1
        showDatepicker()
        
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
        // Split the input string into weekday and day components
        let components = attributedLbl.split(separator: " ")
        guard components.count == 2,
              let weekday = components.first,
              let day = components.last else {
            print("Error: Invalid format for attributedLbl. Expected 'EEE d', got: \(attributedLbl)")
            return
        }
        
        // Fonts for different parts
        let weekdayFont = UIFont.systemFont(ofSize: 12) // Smaller font for weekday
        //let weekdayFont =  UIFont(name: "Poppins-Medium", size: 12)
        //let dayFont =  UIFont(name: "Poppins-Medium", size: 22)
        let dayFont = UIFont.boldSystemFont(ofSize: 22) // Larger font for date ex : 24
        
        // Create an attributed string
        let attributedString = NSMutableAttributedString()
        
        // Add the weekday (e.g., "Mon")
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
    
    @IBAction func RecipentBtnAct(_ sender: Any) {
        
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
            photoPickManager.presentPhotoPicker(from: self, selectionLimit: 5 - selectedImages.count )
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    func openCamera(){
        if selectedImages.count != 5{
            photoPickManager.openCamera(from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    func selectPDF() {
        photoPickManager.pickPDF(from: self)
        
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
        return 1 + selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let cell = uploadAttachmentView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.AttachmentCVCell, for: indexPath) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        }else{
            let cell = uploadAttachmentView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
            cell.delegate = self
            cell.deleteBtn.tag = indexPath.item - 1
            if selectedImages.count > indexPath.item - 1 {
                // Assign the image starting from the second image in the selectedImages array
                cell.imageViews.image = selectedImages[indexPath.item - 1]
            } else {
                cell.imageViews.image = nil
            }
            if selectedImages.count <= 2{
                collectionViewHeight.constant = 120
            }else{
                collectionViewHeight.constant = 220
            }
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
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell, for: indexPath) as! NoticeBoardTvcellTableViewCell
            
            cell.cellview.changeHeightAndAnimate(40, 110, 31, 80, top: 5)
            cell.ishomework = true
            cell.CVHeight.constant = 120
            cell.pagecontrollerheight.constant = 26
            //            cell.datelbl.isHidden = true
            //            cell.pinImage.isHidden = true
            //            cell.Pinview.isHidden = true
            //            cell.collectionview.isHidden = false
            cell.pagecontroller.isHidden = false
            cell.SelectBtn.isHidden = true
            cell.HomeworkSubjectLbl.text = "Tamil"
            cell.TitleLbl.text = "Write Assignment"
            cell.dicriptContent.attributedText = descript(for: "Dear Students, as you prepare to write your assignment, please follow these steps to ensure clarity and quality. Begin by thoroughly understanding the topic and conducting comprehensive research using reliable sources. Create a detailed outline to structure your thoughts and arguments logically. Write a clear and concise introduction that sets the tone and context for your assignment.", expanded: false)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
            cell.delegate = self
            cell.dicriptContent.tag = indexPath.row // Tag the label with the row index
            cell.dicriptContent.isUserInteractionEnabled = true
            cell.dicriptContent.addGestureRecognizer(tapGesture)
            
            return cell
        }
        else if indexPath.row == 1 {
            let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.HomeworkreportTV, for: indexPath) as! HomeworkreportTV
            
            cell.HomeworkTitleLbl.text = "Write Assignment"
            cell.DescriptionLbl.attributedText = descript(for:"Dear Students, as you prepare to write your assignment, please follow these steps to ensure clarity and quality." , expanded: false)
           // cell.DescriptionLbl.text = "Dear Students, as you prepare to write your assignment, please follow these steps to ensure clarity and quality."
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
           // cell.delegate = self
            cell.DescriptionLbl.tag = indexPath.row // Tag the label with the row index
            cell.DescriptionLbl.isUserInteractionEnabled = true
            cell.DescriptionLbl.addGestureRecognizer(tapGesture)
            cell.SubjectLbl.text = "Tamil"
            return cell
        }
        else {
            let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell, for: indexPath) as! NoticeBoardTvcellTableViewCell
            
            cell.cellview.changeHeightAndAnimate(40,0, 31, 80, top: 5)
            cell.ishomework = true
            cell.pagecontrollerheight.constant = 0
            cell.pagecontroller.isHidden = true
            
           // cell.datelbl.isHidden = true
            cell.pinImage.isHidden = true
            cell.Pinview.isHidden = true
            cell.SelectBtn.isHidden = true
            cell.CVHeight.constant = 0
            cell.HomeworkSubjectLbl.text = "Write Assignment"
            cell.TitleLbl.text = "Tamil"
            cell.dicriptContent.attributedText = descript(for: "Dear Students, as you prepare to write your assignment, please follow these steps to ensure clarity and quality. Begin by thoroughly understanding the topic and conducting comprehensive research using reliable sources. Create a detailed outline to structure your thoughts and arguments logically. Write a clear and concise introduction that sets the tone and context for your assignment.", expanded: false)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
            cell.delegate = self
            cell.dicriptContent.tag = indexPath.row // Tag the label with the row index
            cell.dicriptContent.isUserInteractionEnabled = true
            cell.dicriptContent.addGestureRecognizer(tapGesture)
            return cell
        }
    }
    
    @objc func handleSeeMoreTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let indexPath = IndexPath(row: label.tag, section: 0)
        let fullDescription = "Dear Students, as you prepare to write your assignment, please follow these steps to ensure clarity and quality. Begin by thoroughly understanding the topic and conducting comprehensive research using reliable sources. Create a detailed outline to structure your thoughts and arguments logically. Write a clear and concise introduction that sets the tone and context for your assignment."
        
        // Toggle the label between expanded and collapsed states
        let isExpanded = label.numberOfLines == 0
        label.numberOfLines = isExpanded ? 3 : 0
        
        // Update the label text with the appropriate "See more" or "See less" state
        label.attributedText = descript(for: fullDescription, expanded: !isExpanded)
        
        // Animate the cell height change
        TV.beginUpdates()
        TV.endUpdates()
    }
    
    //MARK: TEXT ADD SEE MORE
    func descript(for fullDescription: String, expanded: Bool) -> NSAttributedString {
        // If expanded, show full text with "See less"
        if expanded {
            let fullString = fullDescription + CommonStringFile.seeLess.translated()
            let attributedText = NSMutableAttributedString(string: fullString)
            
            // Set "See less" text to blue and underline it
            let seeLessRange = (fullString as NSString).range(of: "See less")
            attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: seeLessRange)
            
            return attributedText
        } else {
            var fullString = ""
            // Otherwise, truncate and show "See more"
            if fullDescription.count > 120{
                let truncatedDescription = String(fullDescription.prefix(100))
                fullString = truncatedDescription + CommonStringFile.seemore.translated()
            }else{
                fullString = fullDescription
            }
            let attributedText = NSMutableAttributedString(string: fullString)
            
            // Set "See more" text to blue and underline it
            let seeMoreRange = (fullString as NSString).range(of: "See more")
            attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: seeMoreRange)
            return attributedText
        }
    }
    
    func didTapButton(title: String, content: String, items: [String]) {
        delegate?.select(Title: title, Description: content, Images: [], pdf: "")
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
    
    func keyboardDonebtn(){
           let toolbar = UIToolbar()
           toolbar.sizeToFit()
           let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneKeyboard))
           let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
           toolbar.setItems([flexibleSpace, doneButton], animated: false)
        DetailsTxtview.inputAccessoryView = toolbar
        TitleTxtfield.inputAccessoryView = toolbar
          
       }
       @objc func doneKeyboard() {
           view.endEditing(true)  // Dismiss the keyboard
       }
    
    func textViewDidChange(_ textView: UITextView) {
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            let newHeight = min(max(size.height, initialHeight), maxHeight)

            // Update height constraint and scrolling
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
            //contentTxtView.isEditable = false // Optionally disable editing
            return false // Reject the change
        }
    }
    
//    @objc func keyboardWillShow(notification: Notification) {
//        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
//        
//        // Calculate new position considering the dynamic height
//        let availableSpace = self.view.frame.height - keyboardFrame.height
//        let textViewBottom = outerView.frame.origin.y + outerView.frame.height
//        
//        if textViewBottom > availableSpace {
//            let overlap = textViewBottom - availableSpace - 200 // Add some padding
//            UIView.animate(withDuration: 0.3) {
//                self.outerView.transform = CGAffineTransform(translationX: 0, y: -overlap)
//            }
//        }
////        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
////            UIView.animate(withDuration: 0.3) {
////                // Move outerView 20 points from the top
////                self.outerView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height + 400)
////            }
////        }
//    }
//    
//    // Reset view when keyboard hides
//    @objc func keyboardWillHide(notification: Notification) {
//        UIView.animate(withDuration: 0.3) {
//            self.outerView.transform = .identity
//        }
//    }
    
    
    @objc func keyboardWillShow(notification: Notification) {

            guard let userInfo = notification.userInfo,

                  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,

                  let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }



            // Calculate the available space after keyboard shows

            let keyboardHeight = keyboardFrame.height

            let safeAreaBottom = self.view.safeAreaInsets.bottom

            let adjustedKeyboardHeight = keyboardHeight - safeAreaBottom



            // Get the bottom position of the outerView

            let textViewBottom = outerView.frame.origin.y + outerView.frame.height



            // Calculate the overlap

            let overlap = textViewBottom - (self.view.frame.height - adjustedKeyboardHeight)



            if overlap > 0 {

                UIView.animate(withDuration: animationDuration) {

                    self.outerView.transform = CGAffineTransform(translationX: 0, y: -overlap - 16) // Add padding

                }

            }

        }



        @objc func keyboardWillHide(notification: Notification) {

            guard let userInfo = notification.userInfo,

                  let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }



            // Reset the outerView position

            UIView.animate(withDuration: animationDuration) {

                self.outerView.transform = .identity

            }

        }



//        deinit {
//
//            // Remove observers when the view controller is deinitialized
//
//            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//
//            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//
//        }
}
