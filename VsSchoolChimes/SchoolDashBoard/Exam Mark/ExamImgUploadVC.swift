//
//  ExamImgUploadVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 25/11/25.
//

import UIKit
import VisionKit
import Photos

@available(iOS 14.0, *)
class ExamImgUploadVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var AIview: UIView!
    @IBOutlet weak var manualView: UIView!
    @IBOutlet weak var AiInstructionView: UIView!
    @IBOutlet weak var uploadView: DashedView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var popupBaseVIew: UIView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var ContinueManuallyBtn: UIButton!
    @IBOutlet weak var ContinuewithUploadBtn: UIButton!
    @IBOutlet weak var uploadIconImage: UIImageView!
    @IBOutlet weak var documentIcon: UIImageView!
    @IBOutlet weak var pickedFilenameLbl: UILabel!
    @IBOutlet weak var PopupAlertTitleLbl: UILabel!
    @IBOutlet weak var popupAlertDescriptionLbl: UILabel!
    @IBOutlet weak var uploadMarkSheetLbl: UILabel!
    @IBOutlet weak var uploadImageForAIDescLbl: UILabel!
    @IBOutlet weak var AiPowerdUploadLbl: UILabel!
    @IBOutlet weak var AutoDetectionLbl: UILabel!
    @IBOutlet weak var autoDetectBtn: UIButton!
    @IBOutlet weak var studentNamesAndRollnoLbl: UILabel!
    @IBOutlet weak var subjectColoumsAndMarksLbl: UILabel!
    @IBOutlet weak var tableStructureAndLayoutLbl: UILabel!
    @IBOutlet weak var fileTypesAndSizeLimitLbl: UILabel!
    @IBOutlet weak var manualEntryLbl: UILabel!
    @IBOutlet weak var SkipUploadLbl: UILabel!
    @IBOutlet weak var pencilIcon: UIImageView!
    @IBOutlet weak var imgiconBaseView: UIView!
    
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var attachments: [AttachmentItem] = []
    var SubjectList : [SubjectExamData] = []
    var is_aiViewCliked : Bool = false
    var SelectedExam : StaffExamData?
    private var selectedImageData: Data?
    private var selectedImage: UIImage?
    
    var selectedColumns: [String] = []
    var reviewFlags : [ReviewFlag] = []
    var convertedRecords: [ConvertedStudentRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLbl.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName,secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        
        AIview.layer.cornerRadius = 10
        manualView.layer.cornerRadius = 10
        AiInstructionView.layer.cornerRadius = 10
        uploadView.layer.cornerRadius = 10
        ContinuewithUploadBtn.layer.cornerRadius = 10
        
        AIview.layer.borderWidth = 2
        manualView.layer.borderWidth = 2
        AiInstructionView.layer.borderWidth = 0.5
        
        AIview.layer.borderColor = UIColor.systemGray5.cgColor
        manualView.layer.borderColor = UIColor.systemGray5.cgColor
        AiInstructionView.layer.borderColor = UIColor.staffExamColour.withAlphaComponent(0.7).cgColor
        
        AiInstructionView.backgroundColor = .staffExamColour.withAlphaComponent(0.05)
        documentIcon.tintColor = .darkGray
        
        imgiconBaseView.layer.cornerRadius = imgiconBaseView.frame.height / 2
        imgiconBaseView.backgroundColor = .systemGray6
        
        pencilIcon.layer.cornerRadius = documentIcon.frame.height / 2
        pencilIcon.backgroundColor = .systemGray6
        pencilIcon.tintColor = .darkGray
        
        AiInstructionView.isHidden = true
        uploadView.isHidden = true
        separatorView.isHidden = true
        ContinuewithUploadBtn.isHidden = true
        
        setFont()
        Translate()
        
        AIview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AiTap)))
        manualView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ManualTap)))
        uploadView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UploadTap)))
        
        popupBaseVIew.backgroundColor = .black.withAlphaComponent(0.5)
        popupBaseVIew.isHidden = true
        popupView.layer.cornerRadius = 10
        
        cancelBtn.layer.cornerRadius = 10
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor.backGroundClr.cgColor
        ContinueManuallyBtn.layer.cornerRadius = 10
        
        AIview.isHidden = !(SelectedExam?.ai_mark_entry ?? false)
        uploadImageForAIDescLbl.isHidden = !(SelectedExam?.ai_mark_entry ?? false)
    }
    
    func setFont() {
        
        uploadMarkSheetLbl.setFont(style: .title, size: FontSize.TitleSize)
        uploadImageForAIDescLbl.setFont(style: .body, size: FontSize.BodySize)
        AiPowerdUploadLbl.setFont(style: .header, size: FontSize.HeaderSize)
        AutoDetectionLbl.setFont(style: .body, size: FontSize.BodySize)
        pickedFilenameLbl.setFont(style: .title, size: FontSize.TitleSize)
        fileTypesAndSizeLimitLbl.setFont(style: .body, size: FontSize.TitleSize)
        manualEntryLbl.setFont(style: .header, size: FontSize.HeaderSize)
        SkipUploadLbl.setFont(style: .body, size: FontSize.BodySize)
        autoDetectBtn.setTitleFont(style: .secondary, size: FontSize.TitleSize)
    }
    
    func Translate(){
        
        PopupAlertTitleLbl.text = ExamMarkUploadString.Continue_to_Manual_Entry.translated()
        popupAlertDescriptionLbl.text = ExamMarkUploadString.Youll_enter_student_marks_manually.translated()
        uploadMarkSheetLbl.text = ExamMarkUploadString.Upload_Mark_Sheet.translated()
        uploadImageForAIDescLbl.text = ExamMarkUploadString.Upload_an_image_for_AI_processing.translated()
        AiPowerdUploadLbl.text = ExamMarkUploadString.AI_Powered_Upload.translated()
        AutoDetectionLbl.text = ExamMarkUploadString.Upload_image_for_automatic_detection.translated()
        setAttributedText(Text:  ExamMarkUploadString.Student_names_and_roll_numbers.translated(), label: studentNamesAndRollnoLbl)
        setAttributedText(Text:  ExamMarkUploadString.Subject_columns_and_marks.translated(), label: subjectColoumsAndMarksLbl)
        setAttributedText(Text:  ExamMarkUploadString.Table_structure_and_layout.translated(), label: tableStructureAndLayoutLbl)
        pickedFilenameLbl.text = ExamMarkUploadString.Click_to_upload.translated()
        fileTypesAndSizeLimitLbl.text = ExamMarkUploadString.PNG_JPG_up_to_10MB.translated()
        manualEntryLbl.text = ExamMarkUploadString.Manual_Entry.translated()
        SkipUploadLbl.text = ExamMarkUploadString.Skip_upload_and_enter_marks_manually.translated()
        
        cancelBtn.setTitle(CommonStringFile.Cancel.translated(), for: .normal)
        ContinueManuallyBtn.setTitle(ExamMarkUploadString.Yes_Continue_Manually.translated(), for: .normal)
        autoDetectBtn.setTitle(ExamMarkUploadString.AI_will_automatically_detect.translated(), for: .normal)
        ContinuewithUploadBtn.setTitle(ExamMarkUploadString.Continue_with_Upload.translated(), for: .normal)
    }
    
    func setAttributedText(Text:String, label:UILabel){
        
        let bulletPoint = "• "
        let text = Text
        
        let fullText =  bulletPoint + text
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttributes([.foregroundColor : UIColor.staffExamColour, .font : UIFont.systemFont(ofSize: 13, weight: .semibold)], range: NSRange(location: 0, length: bulletPoint.count))
        
        attributedString.addAttributes([.foregroundColor: UIColor.darkGray, .font: UIFont(name: "Poppins-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13)], range: NSRange(location: bulletPoint.count, length: text.count))
        
        label.attributedText = attributedString
    }
   
    @IBAction func AiTap(){
        
        AIview.layer.borderColor = UIColor.staffExamColour.cgColor
        manualView.layer.borderColor = UIColor.systemGray5.cgColor
        is_aiViewCliked = true
        AiInstructionView.isHidden = false
        uploadView.isHidden = false
        separatorView.isHidden = false
        documentIcon.tintColor = .white
        imgiconBaseView.backgroundColor = .staffExamColour
    }
    
    @IBAction func ManualTap(){
        
        manualView.layer.borderColor = UIColor.staffExamColour.cgColor
        AIview.layer.borderColor = UIColor.systemGray5.cgColor
        is_aiViewCliked = false
        AiInstructionView.isHidden = true
        uploadView.isHidden = true
        separatorView.isHidden = true
        ContinuewithUploadBtn.isHidden = true
        imgiconBaseView.backgroundColor = .systemGray6
        documentIcon.tintColor = .darkGray
        selectedImage = nil
        selectedImageData = nil
        pickedFilenameLbl.text = ExamMarkUploadString.Click_to_upload.translated()
        showPopup()
    }
    
    @IBAction func UploadTap(){
        
        let alertController = UIAlertController(title: AlertstringFile.Select.translated(), message: AlertstringFile.Chooseanoption.translated(), preferredStyle: .actionSheet)
        
        // Camera option
        let cameraAction = UIAlertAction(title: CommonStringFile.Camera.translated(), style: .default) { [self] _ in
           openCamera()
        }
        alertController.addAction(cameraAction)
        
        // Gallery option
        let galleryAction = UIAlertAction(title: CommonStringFile.Photos.translated(), style: .default) { [self] _ in
           openImagePicker()
        }
        alertController.addAction(galleryAction)
        
        alertController.addAction(UIAlertAction(title: AlertstringFile.Cancel.translated(), style: .cancel))

        self.present(alertController, animated: true, completion: nil)
    }
    
    private func openImagePicker() {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            present(picker, animated: true)
        }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = false
        present(picker, animated: true)
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)

        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            selectedImageData = image.jpegData(compressionQuality: 0.9)
        }

        var selectedImageName = ""

        if let asset = info[.phAsset] as? PHAsset {
            let resources = PHAssetResource.assetResources(for: asset)
            selectedImageName = resources.first?.originalFilename ?? ""
        } else {
            // Camera images do NOT have PHAsset
            selectedImageName = "camera_image.jpg"
        }

        pickedFilenameLbl.text = selectedImageName
        ContinuewithUploadBtn.isHidden = false
    }

    @IBAction func popupCancelAct(_ sender: Any) {
        
        hidePopup()
        manualView.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    @IBAction func ContinueManuallyAct(_ sender: Any) {
        hidePopup()
        let vc = ExamActivitySelectionVC()
        vc.ExamID = SelectedExam?.id ?? ""
        vc.isAIFlow = false
        vc.SelectedExam = SelectedExam
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    @IBAction func continueWithUploadAct(_ sender: Any) {
        
        uploadImageForAI()
//        let vc = ExamActivitySelectionVC()
//        vc.ExamID = examId ?? ""
//        vc.isAIFlow = true
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
        
    }
    
    func uploadImageForAI(){
        
      showActivityLoader()
        
        guard let image = selectedImage else { return }
        
        APIService.shared.uploadImageApi(url: ServiceUrl.ocr_api_upload_marks, image: image){ [weak self] (result: Result<MarksAIresponse, Error>) in
            
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        
                        guard let data = success.data,
                            let records = data.records
                        else {
                            print("Invalid API data")
                            return
                        }

                        var reviewFlags = data.review_flags ?? []

                        let converted = self.convertRecordsWithReviews(
                            records: records,
                            reviewFlags: reviewFlags
                        )

                        print("Converted:", converted)
                        print("reviewFlags:", reviewFlags)
                        print("selected_columns:", data.table_structure?.selected_columns ?? [])

                        self.selectedColumns = data.table_structure?.selected_columns ?? []
                        self.convertedRecords = converted
                        

                        let vc = ExamActivitySelectionVC()
                        vc.ExamID = self.SelectedExam?.id ?? ""
                        vc.isAIFlow = true
                        vc.selectedColoumns = self.selectedColumns
                        vc.convertedRecords = self.convertedRecords
                        vc.SelectedExam = self.SelectedExam
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                       
                    }else{
                        
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self) { }
                    }
                    
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self) { }
                    print("failure",failure.localizedDescription)
                }
                
                self.hideActivityLoader()
            }
            
        }
    }
    
    // Key format: "studentId|field"
    func buildReviewLookup(
        reviewFlags: [ReviewFlag]
    ) -> [String: ReviewFlag] {

        var dict: [String: ReviewFlag] = [:]

        for flag in reviewFlags {
            let key = "\(flag.student_id ?? "")|\(flag.field ?? "")"
            dict[key] = flag
        }

        return dict
    }

    
    func convertRecordsWithReviews(
        records: [DynamicRecord],
        reviewFlags: [ReviewFlag]
    ) -> [ConvertedStudentRecord] {

        // Build lookup: "studentId|field" → ReviewFlag
        let reviewLookup: [String: ReviewFlag] =
            Dictionary(uniqueKeysWithValues: reviewFlags.map {
                ("\($0.student_id ?? "")|\($0.field ?? "")", $0)
            })

        // Static (non-mark) keys
        let staticKeys: Set<String> = [
            "S.no",
            "Reg No",
            "Student Name",
            "Student ID"
        ]

        return records.map { record in

            let studentId = record.values["Student ID"]?.stringValue ?? ""
            let sNo = record.values["S.no"]?.stringValue ?? ""
            let regNo = record.values["Reg No"]?.stringValue ?? ""
            let studentName = record.values["Student Name"]?.stringValue ?? ""

            let marks: [RecordItem] = record.values
                .filter { !staticKeys.contains($0.key) }
                .map { key, value in

                    let review = reviewLookup["\(studentId)|\(key)"]

                    return RecordItem(
                        name: key,
                        value: value.stringValue,
                        isReview: review != nil,
                        reason: review?.reason
                    )
                }

            return ConvertedStudentRecord(
                studentId: studentId,
                sNo: sNo,
                regNo: regNo,
                studentName: studentName,
                marks: marks
            )
        }
    }


    
    func loadSubjectList(for examId: String,completion: @escaping (Bool)->Void) {
        SubjectList.removeAll()
        let param:[String:Any] = ["exam_id": examId]

        APIService.shared.makeApi(
            url: ServiceUrl.exam_get_subject_wise_activities,
            parameters: param,
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<SubjectWiseExamResponse, Error>) in

            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.SubjectList = response.data ?? []
                    completion(true)
                case .failure(let error):
                    print("Error loading subjects: \(error)")
                    completion(false)
                }
            }
        }
    }
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func showPopup() {
        popupBaseVIew.alpha = 0
        popupBaseVIew.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.popupBaseVIew.alpha = 1
        }
    }

    func hidePopup() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popupBaseVIew.alpha = 0
        }) { _ in
            self.popupBaseVIew.isHidden = true
        }
    }
    
}

@available(iOS 14.0, *)
extension ExamImgUploadVC: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                      didFinishWith scan: VNDocumentCameraScan) {
        
        var scannedImages: [UIImage] = []
        
        for i in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: i)
            scannedImages.append(image)
        }

        // handle scannedImages here

        controller.dismiss(animated: true)
    }

    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                      didFailWithError error: Error) {
        controller.dismiss(animated: true)
        print("Document scan failed: \(error.localizedDescription)")
    }
}



class DashedView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        addDashBorder()
    }

    private func addDashBorder() {
        layer.sublayers?
            .filter { $0.name == "dashedBorder" }
            .forEach { $0.removeFromSuperlayer() }

        let dash = CAShapeLayer()
        dash.name = "dashedBorder"
        dash.strokeColor = UIColor.gray.cgColor
        dash.lineDashPattern = [4, 2]
        dash.frame = bounds
        dash.fillColor = nil
        dash.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.addSublayer(dash)
    }
}
