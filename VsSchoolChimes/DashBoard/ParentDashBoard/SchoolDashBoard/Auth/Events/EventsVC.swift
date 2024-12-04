//
//  EventsVC.swift
//  VsSchoolChimes
//
//  Created by admin on 02/12/24.
//

import UIKit
import AWSCore
import AWSS3

protocol DeleteImge{
    func deleteImage(index:Int)
}
@available(iOS 14.0, *)
class EventsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UITextViewDelegate ,UIDocumentPickerDelegate, DeleteImge{
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        costomView.imageCollectionview.reloadData()
    }
    
    
    @IBOutlet weak var eventTxt: UITextField!
    @IBOutlet weak var EventTtleLbl: UILabel!
    @IBOutlet weak var placeTxt: UITextField!
    @IBOutlet weak var subTitleLbl: UILabel!
    @IBOutlet weak var placeLbl: UILabel!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var costomView: ImageSelection!
    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var pickerDateLbl: UILabel!
    
    @IBOutlet weak var contentCount: UILabel!
    @IBOutlet weak var eventDeatail: UILabel!
    @IBOutlet weak var addPhotoLbl: UILabel!
    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var calanderBtn: UIButton!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    var placeholderLabel: UILabel!
    var activeButton: UIButton?
    var timePicker: UIDatePicker!
    var datePicker: UIDatePicker!
    var doneButton: UIButton!
    var doneButton2: UIButton!
    var time = "Jan\n15"
    var dateSelection = false
    
    let photoPickManager = PhotoPickerManager.shared
    var selectedImages: [UIImage] = []
    var convertedImagesUrlArray = NSMutableArray()
    
    var imageUrlArray = NSMutableArray()
    var pdfData : Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTimePicker()
        setupdatePicker()
        setInitialButtonTitles()
        registerCell()
        setupPlaceholder()
        
        photoPickManager.onImagePicked = { [weak self] images in
            guard let self = self else { return }
            // Handle selected images here
            
            selectedImages.append(contentsOf: images)
            for image in images {
                print("Selected image: \(image)")
               // photoPickManager.uploadAWS(image: image)
            }
            costomView.imageCollectionview.reloadData()
        }
        
        
    }
    //MARK: BUTTON TITLE CURRANT TIME
    func setInitialButtonTitles() {
        let dateFormatter = DateFormatter()
        let timeFormatter = DateFormatter()
        let dateOnlyFormatter = DateFormatter()
        
        // Set the date format (e.g., "Tue 3 Dec 2024")
        dateFormatter.dateFormat = "EEE d MMM yyyy"
        dateOnlyFormatter.dateFormat = "EEE d"
        
        // Set the time format (e.g., "4:30 PM")
        timeFormatter.timeStyle = .short
        
        // Get the current date and time
        let currentDate = Date() // Current date and time
        let nextHourTime = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate
        
        // Format the date and time
        let formattedDate = dateFormatter.string(from: currentDate)   // "Tue 3 Dec 2024"
        let formattedTime = timeFormatter.string(from: nextHourTime)  // "4:30 PM"
        let dateOnly = dateOnlyFormatter.string(from: nextHourTime)   // "Tue 3"
        
        // Set the formatted time to the time button
        timeBtn.setTitle(formattedTime, for: .normal)
        
        // Set the date and time to the date button
        dateSet(formattedDate, dateOnly)
    }

    
    func registerCell(){
        costomView.imageCollectionview.delegate = self
        costomView.imageCollectionview.dataSource = self
        contentTxtView.delegate = self
        contentTxtView.layer.cornerRadius = 10
        contentTxtView.layer.borderWidth = 0.5
        contentTxtView.layer.borderColor = UIColor.black.cgColor
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        subTitleLbl.setFont(style:.title, size: FontSize.TitleSize)
        EventTtleLbl.setFont(style:.body, size: FontSize.BodySize)
        headerLbl.setFont(style:.header, size: FontSize.HeaderSize)
        eventDeatail.setFont(style:.body, size: FontSize.BodySize)
        addPhotoLbl.setFont(style:.body, size: FontSize.BodySize)
        timeBtn.setTitleFont(style: .body, size: 12)
        dateBtn.setTitleFont(style: .body, size: 12)
        pickerDateLbl.setFont(style:.body, size: FontSize.BodySize)
        placeLbl.setFont(style:.body, size: FontSize.BodySize)
        placeLbl.text = "Venue".translated()
        addPhotoLbl.text = "Add Photos".translated()
        eventDeatail.text = "Event Details".translated()
        EventTtleLbl.text = "Event Title".translated()
        headerLbl.text = "Create Event".translated()
        // Assuming setFont(style:size:) sets the desired UIFont
        
        
    }
    func dateSet( _ Date: String, _ splitdate: String) {
        print(Date)
        
        dateBtn.setTitle(Date, for: .normal)
        let janFont = pickerDateLbl.font ?? UIFont.systemFont(ofSize: 17) // Default fallback
        let dayFont = placeLbl.font ?? UIFont.systemFont(ofSize: 14)      // Default fallback
        
        // Split the date into parts
        let components = splitdate.split(separator: " ")
        let weekday = components[0] // "Tue"
        let day = components.count > 1 ? components[1] : "" // "3" or "12"
        
        // Create the attributed string with a newline
        let attributedText = NSMutableAttributedString(string: "\(weekday)\n\(day)")
        
        // Define the range for "Tue" (weekday)
        let dayRange = NSRange(location: 0, length: weekday.count)
        
        // Define the range for the day number (e.g., "3" or "12")
        let dayNumberRange = NSRange(location: weekday.count + 1, length: day.count)
        
        // Apply the font to "Tue"
        attributedText.addAttribute(.font, value: janFont, range: dayRange)
        
        // Apply the font to the day number (e.g., "3" or "12")
        attributedText.addAttribute(.font, value: dayFont, range: dayNumberRange)
        
        // Set the paragraph style to center align
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedText.length))
        
        // Set the attributed text to the label
        pickerDateLbl.attributedText = attributedText
        pickerDateLbl.numberOfLines = 0 // Allow multiple lines
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty // Toggle visibility
        adjustTextViewHeightWithConstraint(textView)
        let sentenceCount = countSentences(in: textView.text)
        contentCount.text = "\(sentenceCount) of 30"

    }
    // Helper function to count sentences
    func countSentences(in text: String) -> Int {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let sentences = trimmedText.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        return sentences.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }.count
    }
    func adjustTextViewHeightWithConstraint(_ textView: UITextView) {
        // Calculate the size needed for the text
        if textView.text.isEmpty {
               // Set default height to 60
               textViewHeightConstraint.constant = 60
           } else {
               // Calculate the size needed for the text
               let sizeThatFits = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
               textViewHeightConstraint.constant = sizeThatFits.height
           }
        textView.layoutIfNeeded() // Refresh the layout
    }
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Enter your text here..."
        placeholderLabel.font = contentTxtView.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8) // Adjust padding
        contentTxtView.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !contentTxtView.text.isEmpty // Hide if text exists
    }
    
    @IBAction func datepicker(_ sender: UIButton) {
        showTimePicker(for: sender, date: true)
        dateSelection = true
    }
    @IBAction func Timepicker(_ sender: UIButton) {
        showTimePicker(for: sender, date: false)
        dateSelection = false
    }
    
    @IBAction func chooseSchool(_ sender: UIButton) {
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let cell = costomView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: "AttachmentCVCell", for: indexPath) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        }else{
            let cell = costomView.imageCollectionview.dequeueReusableCell(withReuseIdentifier: "ImageCvCell", for: indexPath) as! ImageCvCell
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
        
        let width = (costomView.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
            //
            // Camera option
            let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { [self] _ in
    //
//                openCamera()
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

                // Safe unwrapping of imgView before assigning
                vc.img = selectedImages[indexPath.item - 1]
//                if let imgView = vc.imgView {
//                    imgView.image = selectedImages[indexPath.item - 1]
//                    
//                } else {
//                    print("imgView is nil")
//                }
//                
                present(vc, animated: true)
            }
        }
    }
    
    func selectImages() {
            photoPickManager.presentPhotoPicker(from: self, selectionLimit: 5)
        print(photoPickManager.imageStr)


           }
    func selectPDF() {



            print("SELECT PDF")

            



            

            let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)

            documentPicker.delegate = self

            self.present(documentPicker, animated: true, completion: nil)

            

        }

        

//        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt urls: URL) {
//
//            let fileurl: URL = urls as URL
//
//            let filename = urls.lastPathComponent
//
//            let fileextension = urls.pathExtension
//
//            print("URL: \(fileurl)", "NAME: \(filename)", "EXTENSION: \(fileextension)")
//            let imageData = NSData(contentsOf: urls)
//            
//
//            do {
//
//                pdfData = try Data(contentsOf: urls, options: NSData.ReadingOptions())
//
//                uploadPDFFileToAWS(pdfData: pdfData!)
//
//                
//
//            } catch {
//
//                print("set PDF filer error : ", error)
//
//                
//
//            }
//
//               
//
//            
//
//        }
    

//    func uploadPDFFileToAWS(pdfData : Data){
//
//            let S3BucketName = AwsCredentials.bucketNameIndia
//
//            let CognitoPoolID = AwsCredentials.CognitoPoolID
//
//            let Region = AWSRegionType.APSouth1
//
//            let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
//
//            let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
//
//            let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".pdf")
//
//            
//
//            let ext = imageName as String
//
//            
//
//            let dateFormatter = DateFormatter()
//
//            dateFormatter.dateFormat = "dd-MM-yyyy"
//
//            
//
//            let  currentDate =   dateFormatter.string(from: Date())
//
//            
//
//            
//
//            let fileName = imageNameWithoutExtension
//
//            let fileType = ".pdf"
//
//            
//
//            let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
//
//            
//
//            do {
//
//                try pdfData.write(to: imageURL)
//
//            }
//
//            catch {}
//
//            
//
//            print(imageURL)
//
//            
//
//            let uploadRequest = AWSS3TransferManagerUploadRequest()
//
//            uploadRequest?.body = imageURL
//
//            uploadRequest?.key =  currentDate +  "/" + "File_" + ext
//
//            uploadRequest?.bucket = S3BucketName
//
//            
//
//            uploadRequest?.contentType = "application/pdf"
//
//            
//
//            
//
//            let transferManager = AWSS3TransferManager.default()
//
//            transferManager.upload(uploadRequest!).continueWith { [self] (task) -> AnyObject? in
//
//                
//
//                if let error = task.error {
//
//                    print("Upload failed : (\(error))")
//
//                    
//
//                  
//
//                }
//
//                
//
//                if task.result != nil {
//
//                    let url = AWSS3.default().configuration.endpoint.url
//
//                    let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
//
//                    if let absoluteString = publicURL?.absoluteString {
//
//                        print("Uploaded to:\(absoluteString)")
//
//                      
//
//                        let imageDict = NSMutableDictionary()
//
//                        imageDict["FileName"] = absoluteString
//
//                        self.imageUrlArray.add(imageDict)
//
//                        self.convertedImagesUrlArray = self.imageUrlArray
//
//                        
//
//                        
//
//                        
//
//                        
//
//                     
//
//                    }
//
//                }
//
//                else {
//
//                    
//
//                  
//
//                    print("Unexpected empty result.")
//
//                }
//
//                return nil
//
//            }
//
//        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {

            controller.dismiss(animated: true, completion: nil)

        }
    func setupdatePicker() {
        // Initialize the date picker
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
        datePicker.backgroundColor = .white
        datePicker.isHidden = true // Initially hidden
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
    
    func setupTimePicker() {
        // Initialize the time picker
        timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
        }
        timePicker.backgroundColor = .white
        timePicker.isHidden = true // Initially hidden
        self.view.addSubview(timePicker)
        
        // Initialize and configure Done button
        doneButton2 = UIButton(type: .system)
        doneButton2.setTitle("Done", for: .normal)
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
        let selectedTime = timePicker.date // Selected time from timePicker
        
        let formattedTime = timeFormatter.string(from: selectedTime)
        timeBtn.setTitle(formattedTime, for: .normal)
        
        // Hide the picker and Done button after selection
        timePicker.isHidden = true
        doneButton2.isHidden = true
        activeButton = nil
    }
    
    @objc func doneButtonTapped() {
        let dateFormatter = DateFormatter()
        let dateOnlyFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE d MMM yyyy"
        // Set the date-only format (e.g., "Tue 3")
        dateOnlyFormatter.dateFormat = "EEE d"
        // Get the selected date and time
        let selectedDate = datePicker.date
        let formattedDate = dateFormatter.string(from: selectedDate)
        let dateOnly = dateOnlyFormatter.string(from: selectedDate)   // "Tue 3"
        
        // Pass the formatted values to the dateSet method
        dateSet(formattedDate, dateOnly)
        datePicker.isHidden = true
        timePicker.isHidden = true
        doneButton.isHidden = true
        activeButton = nil
    }
    
    func showTimePicker(for button: UIButton, date: Bool) {
        activeButton = button // Track which button is being updated
        
        // Position the time picker or date picker below the button
        let buttonFrame = button.convert(button.bounds, to: self.view)
        
        if date {
            // Show the date picker
            datePicker.isHidden = false
            doneButton.isHidden = false
            
            // Set the frame for the datePicker and make sure it’s within bounds
            let pickerYPosition = buttonFrame.maxY + 10
            datePicker.frame = CGRect(x: (self.view.frame.width - 300) / 2, y: pickerYPosition, width: 300, height: 300)
            
            // Set appearance for datePicker
            datePicker.backgroundColor = .white
            datePicker.layer.shadowColor = UIColor.black.cgColor
            datePicker.layer.shadowOffset = CGSize(width: 0, height: 2)
            datePicker.layer.shadowRadius = 5
            datePicker.layer.shadowOpacity = 0.3
            datePicker.layer.cornerRadius = 20
            
            // Position the Done button at the bottom-right of the picker
            doneButton.frame = CGRect(x: timePicker.frame.maxX - 80, y: pickerYPosition + datePicker.frame.height - 40, width: 70, height: 30)
            
            // Add datePicker to the view (ensure it’s in the view hierarchy)
            self.view.addSubview(datePicker)
            self.view.addSubview(doneButton)
        } else {
            // Show the time picker
            timePicker.isHidden = false
            doneButton2.isHidden = false
            
            // Set the frame for the timePicker
            let pickerYPosition = buttonFrame.maxY + 10
            timePicker.frame = CGRect(x: (self.view.frame.width - 250) / 2, y: pickerYPosition, width: 250, height: 200)
            
            // Set appearance for timePicker
            timePicker.backgroundColor = .white
            timePicker.layer.shadowColor = UIColor.black.cgColor
            timePicker.layer.shadowOffset = CGSize(width: 0, height: 2)
            timePicker.layer.shadowRadius = 5
            timePicker.layer.shadowOpacity = 0.3
            timePicker.layer.cornerRadius = 20
            
            // Position the Done button at the bottom-right of the picker
            doneButton2.frame = CGRect(x: timePicker.frame.maxX - 80, y: pickerYPosition + timePicker.frame.height - 40, width: 70, height: 30)
            
            // Add timePicker to the view (ensure it’s in the view hierarchy)
            self.view.addSubview(timePicker)
            self.view.addSubview(doneButton2)
        }
    }

}

