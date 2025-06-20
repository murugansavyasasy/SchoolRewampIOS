//
//  LeveCreateVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit
@available(iOS 14.0, *)
class LeveCreateVC: UIViewController,UITextViewDelegate, DeleteImge, Datepicker{
    func date(date: String) {
        
        dateFormatter.dateFormat = dateFormat1
        if let selectedDate = dateFormatter.date(from: date) {
            if dateSelection {
                // Set From Date
                FromDateLbl.setFormattedDate(from: selectedDate)

                // Check if To Date is set and valid
                if let toText = ToDateLbl.text?.replacingOccurrences(of: "\n", with: " ") {
                    let labelFormatter = DateFormatter()
                    labelFormatter.dateFormat = "d EEE, MMM yyyy" // Matches formatted label

                    if let toDate = labelFormatter.date(from: toText) {
                        if selectedDate > toDate {
                            // Auto-adjust To Date if From Date is later
                            ToDateLbl.setFormattedDate(from: selectedDate)
                        }
                    }
                }

            } else {
                // Set To Date
                ToDateLbl.setFormattedDate(from: selectedDate)
            }
        } else {
            print("Error: Invalid date format or nil value")
        }

    }
    
    @IBOutlet weak var ToDateLbl: UILabel!
    @IBOutlet weak var FromDateLbl: UILabel!
    @IBOutlet weak var TodateTop: UIView!
    @IBOutlet weak var FromDateTop: UIView!
    @IBOutlet weak var ToDateView: UIView!
    @IBOutlet weak var FromDateView: UIView!
    @IBOutlet weak var dayCount: UILabel!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var ReasonLbl: UILabel!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var ToLbl: UILabel!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var contentCount: UILabel!
    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var costomView: ImageSelection!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var SubmitBtn: UIButton!
    
   
    let dateFormatter = DateFormatter()
    var placeholderLabel: UILabel!
    var dateSelection = false
    let photoPickManager = PhotoPickerManager.shared
    var selectedImages: [UIImage] = []
    var url : URL?
    var dateFormat1 = "dd MMM yyyy"
    var isKeyboardVisible = false
    var childDetails = UserDefaultFileManager.get_child_Details()
    let alert = CustomAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiConfic()
        setInitialDate()
        contentTxtView.delegate = self
        contentTxtView.addDoneButton()
       
        imageSelection()
        setupPlaceholder()
        
        let DateGesture = UITapGestureRecognizer(target: self, action: #selector(datepicker))
        FromDateView.addGestureRecognizer(DateGesture)
        
        let ToDateGesture = UITapGestureRecognizer(target: self, action: #selector(toDate))
        ToDateView.addGestureRecognizer(ToDateGesture)
       
        costomView.imageCollectionview.delegate = self
        costomView.imageCollectionview.dataSource = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    func uiConfic(){
        
        FromDateView.layer.cornerRadius = 8
        ToDateView.layer.cornerRadius = 8
        FromDateTop.layer.cornerRadius = 8
        TodateTop.layer.cornerRadius = 8
        FromDateTop.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        TodateTop.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        
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
        
        contentTxtView.layer.cornerRadius = 10
        contentTxtView.layer.borderWidth = 0.5
        contentTxtView.layer.borderColor = UIColor.black.cgColor
        
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        
        ReasonLbl.setRequiredText("Reason")
        ToLbl.setFont(style:.title, size: FontSize.TitleSize)
        //ToLbl.text = CommonStringFile.To.translated()
        headerTitle.setFont(style:.title, size: FontSize.TitleSize)
        headerTitle.text = CommonStringFile.CreateLeaveRequest.translated()
        fromLbl.setFont(style:.title, size: FontSize.TitleSize)
        fromLbl.text = CommonStringFile.From.translated()
        dayCount.setFont(style:.header, size: FontSize.BodySize)
        contentCount.setFont(style: .body, size: FontSize.BodySize)

    }
    
    func imageSelection(){
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            // handle camera image
            selectedImages.append(image)
            costomView.imageCollectionview.reloadData()
        }

        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            selectedImages.append(contentsOf: images)
            if url != nil{
                selectedImages.removeAll()
                url = nil
            }
            costomView.imageCollectionview.reloadData()
        }

        PhotoPickerManager.shared.onPdfPicked = { [self] data in
            // handle picked PDF
            selectedImages.removeAll()
            url = data.absoluteURL
            selectedImages.append(ImageName.pdf!)
            costomView.imageCollectionview.reloadData()
        }
    }
    
    @IBAction func SubmitAct(_ sender: Any) {
        
        if contentTxtView.text != ""{
            
           ApplyLeave()
        }else{
            alert.showAlert(title: "", message: AlertstringFile.Enter_reason, on: self)
        }
    }
    
    
    //MARK: Leave Request API call
    
    func ApplyLeave(){
        
        let LeaveFrom = ConvertDateStringSmart(FromDateLbl.text)
        let LeaveTo = ConvertDateStringSmart(ToDateLbl.text)
        
        let param: [String:Any] = [LeaveRequestStringFile.leave_from: LeaveFrom, LeaveRequestStringFile.leave_to:LeaveTo,LeaveRequestStringFile.reason:contentTxtView.text ?? ""]
        
        alert.showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.Are_you_sure_you_want_to_submit_leave_request, actionLbl1: AlertstringFile.Yes_Send, actionLbl2: AlertstringFile.Cancel, on: self,
                              
            onOk: {
                  
            APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_apply, parameters: param, type: ApitTypeSringFile.POST, token: self.childDetails?.access_token ?? "") {[self] (result: Result<CommonApiSuc,Error>) in
                
                switch result{
                    
                case .success(let success):
                    
                    DispatchQueue.main.async {[self] in
                        
                        let title = success.status==true ? AlertstringFile.Success : AlertstringFile.Failed
                        
                        CustomAlert.showAlertWithOkAction(title: title, message: success.message ?? "", on: self) {
                            
                            self.dismiss(animated: true)
                        }
                    }
                    
                case .failure(let error):
                    
                    DispatchQueue.main.async {[self] in
                        
                        CustomAlert.showAlertWithOkAction(title: "Error", message:error.localizedDescription, on: self) {
                            
                            self.dismiss(animated: true)
                        }
                    }
                }
            }
            
        }, onNo: {
            
            print("user Canceled Action")
        }
        )
    }
    
    
    
    
    //MARK: BUTTON TITLE CURRENT TIME
    func setInitialDate() {
        
        let currentDate = Date() // Current date and time
        
        dateFormatter.dateFormat = dateFormat1
        let date = dateFormatter.string(from: currentDate)
        
        FromDateLbl.setFormattedDate(from: currentDate)
        ToDateLbl.setFormattedDate(from: currentDate)
        
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

    
   
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.Reason.translated()
        contentTxtView.applyRightTxt()
        contentCount.applyRightTxt()

        // Placeholder styling
        placeholderLabel.font = contentTxtView.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        contentTxtView.applyRightTxt(with: placeholderLabel)

        contentTxtView.addSubview(placeholderLabel)
    }

    
    @IBAction func datepicker(_ sender: Any) {
         dateSelection = true
         let vc = DatePickerVC(nibName: nil, bundle: nil)
         vc.dateSelection = 2
         vc.delegate = self
         vc.modalPresentationStyle = .overCurrentContext
         vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
         self.present(vc, animated: false)
         
    }
    
    @IBAction func toDate(_ sender: Any) {
        dateSelection = false
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self

        // Extract and parse from FromDateLbl
        if let fromDateString = FromDateLbl.text {
            let components = fromDateString.components(separatedBy: "\n")
            if components.count == 2,
               let day = components.first,
               let rest = components.last {
                let fullDateString = "\(day) \(rest)" // e.g., "18 Wed, Jun 2025"

                let formatter = DateFormatter()
                formatter.dateFormat = "d EEE, MMM yyyy"
                if let fromDate = formatter.date(from: fullDateString) {
                    vc.minimumDate = fromDate
                }
            }
        }

        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }

    func updateDayCountLabel(startDateStr: String, endDateStr: String, dayCount: UILabel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let startDate = dateFormatter.date(from: startDateStr),
              let endDate = dateFormatter.date(from: endDateStr) else {
            dayCount.text = "Invalid date"
            return
        }

        let calendar = Calendar.current
        if let days = calendar.dateComponents([.day], from: startDate, to: endDate).day {
            let totalDays = days + 1  // Include the end date
            dayCount.text = (dayCount.text ?? "") + " \(totalDays) Day" + (totalDays > 1 ? "s" : "")
        } else {
            dayCount.text = "Error calculating"
        }
    }
}

@available(iOS 14.0, *)
extension LeveCreateVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
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
            if selectedImages.count == 0{
                collectionViewHeght.constant = 100
            }
            return cell
        }else{
            let cell = costomView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImageCvCell, for: indexPath) as! ImageCvCell
            cell.delegate = self
            cell.deleteBtn.tag = indexPath.item - 1
            if selectedImages.count > indexPath.item - 1 {
                cell.imageViews.image = selectedImages[indexPath.item - 1]
            } else {
                cell.imageViews.image = nil
            }
             if selectedImages.count <= 3{
                collectionViewHeght.constant = 100
            }else{
                collectionViewHeght.constant = 220
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (costomView.imageCollectionview.frame.width - 30) / 4 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: width, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            
            
            
            //            addItemView.isHidden = false
            
            let alertController = UIAlertController(title: AlertstringFile.Select, message: AlertstringFile.Chooseanoption, preferredStyle: .actionSheet)
            //
            // Camera option
            let cameraAction = UIAlertAction(title: AlertstringFile.Camera, style: .default) { [self] _ in
                openCamera()
            }
            alertController.addAction(cameraAction)
            
            // Gallery option
            let galleryAction = UIAlertAction(title: AlertstringFile.Gallery, style: .default) { [self] _ in
                //
                selectImages()
                //
            }
            alertController.addAction(galleryAction)
            
            //             PDF option
            let pdfAction = UIAlertAction(title: AlertstringFile.PDF, style: .default) { [self] _ in
                
                selectPDF()
            }
            alertController.addAction(pdfAction)
            
            // Cancel action
            let cancelAction = UIAlertAction(title: AlertstringFile.Cancel, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            // Present the alert
            self.present(alertController, animated: true, completion: nil)
            
            //            animateIn()
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
    }
    
    func selectImages() {
        if selectedImages.count != 5{
            PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: 5 - selectedImages.count), from: self)
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }

    }
    func openCamera(){
        if selectedImages.count != 5{
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
    
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        costomView.imageCollectionview.reloadData()
    }
}

@available(iOS 14.0, *)
extension LeveCreateVC: UITextViewDelegate,UITextFieldDelegate {
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard !isKeyboardVisible else { return } // Prevent unnecessary animations
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            isKeyboardVisible = true
            UIView.animate(withDuration: 0.3) {
                // Move outerView 20 points from the top
                self.outerView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height + 200)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard isKeyboardVisible else { return } // Ensure this logic runs only if the keyboard is open
        isKeyboardVisible = false
        UIView.animate(withDuration: 0.3) {
            self.outerView.transform = .identity // Reset position
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustTextViewHeightWithConstraint(textView)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Calculate the new length of the text
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        if updatedText.count <= 500 {
            placeholderLabel.isHidden = updatedText.count == 0 ? false : true
            contentCount.text = "\(updatedText.count) of 500" // Update the character count label
            return true // Allow the change
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            //            contentTxtView.isEditable = false // Optionally disable editing
            return false // Reject the change
        }
    }
    func adjustTextViewHeightWithConstraint(_ textView: UITextView) {
        // Calculate the size needed for the text
        if textView.text.isEmpty {
            // Set default height to 60
            textViewHeightConstraint.constant = 100
        } else {
            // Calculate the size needed for the text
            let sizeThatFits = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            if sizeThatFits.height > 80{
                textViewHeightConstraint.constant = sizeThatFits.height
            }
        }
        textView.layoutIfNeeded() // Refresh the layout
    }
}

extension UILabel {
    func setFormattedDate(from date: Date) {
        let calendar = Calendar.current
        let dayNumber = calendar.component(.day, from: date)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM yyyy" // e.g., "Wed, Jun 2025"
        let dayText = dateFormatter.string(from: date)

        let fullString = "\(dayNumber)\n\(dayText)"
        let attributedText = NSMutableAttributedString(string: fullString)

        // Day number style: Poppins-SemiBold
        if let boldFont = UIFont(name: "Poppins-SemiBold", size: 15) {
            let dayNumberRange = (fullString as NSString).range(of: "\(dayNumber)")
            attributedText.addAttributes([
                .font: boldFont,
                .foregroundColor: UIColor.label
            ], range: dayNumberRange)
        }

        // Date text style: Poppins-Medium
        if let mediumFont = UIFont(name: "Poppins-Medium", size: 10) {
            let dayTextRange = (fullString as NSString).range(of: dayText)
            attributedText.addAttributes([
                .font: mediumFont,
                .foregroundColor: UIColor.secondaryLabel
            ], range: dayTextRange)
        }

        self.attributedText = attributedText
        self.numberOfLines = 0
        self.textAlignment = .center
    }
}
