//
//  SubmitLsrwViewController.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/20/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import DropDown
import PhotosUI
import Alamofire
import AVFoundation
import ObjectMapper
import KRProgressHUD

class SubmitLsrwViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIDocumentPickerDelegate, PHPickerViewControllerDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate,UITextViewDelegate {
    
    @IBOutlet weak var addAttachHeadingLbl: UILabel!
    @IBOutlet weak var restrictionTv: UITableView!
    @IBOutlet weak var restrictionView: UIView!
    @IBOutlet weak var playVoiceHeight: NSLayoutConstraint!
    @IBOutlet weak var voiceOverAllHeight: NSLayoutConstraint!
    @IBOutlet weak var addAttachTop: NSLayoutConstraint!
    @IBOutlet weak var PlayVocieButton: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var submitView: UIView!
    @IBOutlet weak var overallTimeLbl: UILabel!
    @IBOutlet weak var uploadFileImg: UIImageView!
    @IBOutlet weak var uploadFileLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var voicePlayView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var imgPdfPathShowView: UIView!
    @IBOutlet weak var overAllTextView: UIView!
    @IBOutlet weak var Slider: UISlider!
    @IBOutlet weak var voiceeTapView: UIView!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var recordlbl: UILabel!
    @IBOutlet weak var voiceOverAllVie: UIView!
    @IBOutlet weak var contentTextViw: UITextView!
    @IBOutlet weak var voiceRecordBtn: UIButton!
    @IBOutlet weak var changeImgView: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var imgPathLbl: UILabel!
    @IBOutlet weak var imageOverAllView: UIView!
    @IBOutlet weak var dropDownView: UIViewX!
    @IBOutlet weak var dropDownTextLbl: UILabel!
    @IBOutlet weak var agreeView: UIView!
    
    var items = ["Text", "Voice", "Image","Pdf","Video"]
    var rowId = "FileAttachmentTableViewCell"
    var currentImageCount = 0
    var originalImagesArray = [UIImage]()
    var imageUrlArray = NSMutableArray()
    var  getImagePdfType : String!
    var convertedImagesUrlArray = NSMutableArray()
    var pdfData : Data? = nil
    var selectedImages: [UIImage] = []
    var authToken = "8d74d8bf6b5742d39971cc7d3ffbb51a"
    var videoEmbdUrl : String!
    var iframeLink : String!
    var videoSucessId = 0
    var time : Float64 = 0;
    var settings         = [String : Int]()
    var imageStr : [String] = []
    var totalImageCount = 0
    var onImagesPicked: (([UIImage]) -> Void)?
    var aswImg : [String] = []
    var aswPdf : [String] = []
    var aswVoice : [String] = []
    var onPdfPicked: ((Data) -> Void)?
    var onImagePicked: (([UIImage]) -> Void)?
    var pathArr : [String] = []
    var overAllPathArr : [String] = []
    var overAllFileArr : [String] = []
    var typeArr : [String] = []
    var fileArr : [String] = []
    var urlData: URL?
    var TotaldurationFormat = String()
    var MaxMinutes = Int()
    var MaxSeconds = Int()
    var durationString = String()
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var meterTimer:Timer!
    var audioRecorder    : AVAudioRecorder!
    var strPlayStatus : NSString = ""
    var dropDown  = DropDown()
    var imagePicker = UIImagePickerController()
    var AudioPlayUrl : String!
    var Audiopath  : URL!
    var timer = Timer()
    var timeLabelForPlayVoice : String!
    var audioPlayer : AVAudioPlayer!
    var isAudioRecordingGranted: Bool!
    var isRecording = false
    var isPlaying = false
    var url: URL!
    var studentId = String()
    var skillId : String!
    var cameraSelect : Int!
    var restrictionData : [RestrictionResponse] = []
    var imageLimit : Int!
    var restrictionRowNib = "RestrictionTableViewCell"
    var strTextViewPlaceholder = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        let userDefaults = UserDefaults.standard
       
        studentId = userDefaults.string(forKey: DefaultsKeys.chilId)!
        
        contentTextViw.delegate = self
        addBtn.backgroundColor = .lightGray
        voiceOverAllVie.isHidden = true
        imgPdfPathShowView.isHidden = true
        imageOverAllView.isHidden = true
        dropDownView.isHidden = false
        overAllTextView.isHidden = false
        contentTextViw.isHidden = false
        timerLbl.text = "00:00"
        addBtn.setTitle("Add Content", for: .normal)
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backVc))
        backView.addGestureRecognizer(backGesture)
        
        let strImageLimit : NSString = UserDefaults.standard.object(forKey: IMAGE_COUNT) as! NSString
        imageLimit = strImageLimit.integerValue
        print("imageLimit",imageLimit)
        addAttachHeadingLbl.isHidden = true
        
        
        let agreeGesture = UITapGestureRecognizer(target: self, action: #selector(pickVideoFromGallery))
     agreeView.addGestureRecognizer(agreeGesture)
        
        
        tv.register(UINib(nibName: rowId, bundle: nil), forCellReuseIdentifier: rowId)
        
        restrictionTv.register(UINib(nibName: restrictionRowNib, bundle: nil), forCellReuseIdentifier: restrictionRowNib)

        let selectMonth = UITapGestureRecognizer(target: self, action: #selector(selectMonthViewClick))
        dropDownView.addGestureRecognizer(selectMonth)
        
        pdfData?.removeAll()
        pathArr.removeAll()
        fileArr.removeAll()
        overAllPathArr.removeAll()
        addAttachTop.constant = -100
        
        check_record_permission()
        
        strTextViewPlaceholder = "Content"
        
        let imgGesture = UITapGestureRecognizer(target: self, action: #selector(selectImages))
        changeImgView.addGestureRecognizer(imgGesture)
        
        restrictionTv.isHidden = true
        restrictionView.isHidden = true
      
        
        
    }

    @IBAction func backVc() {
        dismiss(animated: true)
    }
    

    
//    MARK: Drop Down
    @IBAction func selectMonthViewClick(){
        
        cameraSelect = 0
        let myArray = items
        
        dropDown.dataSource = myArray//4
        dropDown.anchorView = dropDownView //5
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        
        dropDown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropDown.show() //7
        
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
          
            
            dropDownTextLbl.text = item
            
           
            
            if item == "Text" {
                addBtn.backgroundColor = .lightGray
                overAllTextView.isHidden = false
                contentTextViw.isHidden = false
                voiceOverAllVie.isHidden = true
                imgPdfPathShowView.isHidden = true
                imageOverAllView.isHidden = true
                addAttachTop.constant = -100
                addBtn.setTitle("Add Content", for: .normal)

            } else if item == "Image" {
                addBtn.backgroundColor = .lightGray

                overAllTextView.isHidden = true
                contentTextViw.isHidden = true
                voiceOverAllVie.isHidden = true
                imgPdfPathShowView.isHidden = true
                uploadFileLbl.text = "Upload Image"
                imageOverAllView.isHidden = false
                addBtn.setTitle("Add File Attachments", for: .normal)
                addAttachTop.constant = -150
                uploadFileImg.image = UIImage(named: "ImageIcon")
                changeImgView.isHidden = false
                
                
            } else if item == "Pdf" {
                addBtn.backgroundColor = .lightGray

                overAllTextView.isHidden = true
                contentTextViw.isHidden = true
                voiceOverAllVie.isHidden = true
                uploadFileLbl.text = "Browse File"
                imgPdfPathShowView.isHidden = true
                imageOverAllView.isHidden = false
                addAttachTop.constant = -180
                addBtn.setTitle("Add File Attachments", for: .normal)
                uploadFileImg.image = UIImage(named: "pdfImage")
                changeImgView.isHidden = false

                
            } else if item == "Voice" {
                addBtn.backgroundColor = .lightGray

                playVoiceHeight.constant = 0
                voiceOverAllHeight.constant = 100
                overAllTextView.isHidden = true
                contentTextViw.isHidden = true
                voiceOverAllVie.isHidden = false
                imgPdfPathShowView.isHidden = true
                imageOverAllView.isHidden = true
                addAttachTop.constant = 30
                voicePlayView.isHidden = true
                addBtn.setTitle("Add File Attachments", for: .normal)
                
            } else if item == "Video" {
                addBtn.backgroundColor = .lightGray

                overAllTextView.isHidden = true
                contentTextViw.isHidden = true
                voiceOverAllVie.isHidden = true
                imgPdfPathShowView.isHidden = true
//                imageOverAllView.isHidden = true
                uploadFileLbl.text = "Upload Video"
                addAttachTop.constant = -150
                addBtn.setTitle("Add File Attachments", for: .normal)
                uploadFileImg.image = UIImage(named: "p23")
                changeImgView.isHidden = false
                imageOverAllView.isHidden = false

                
                
            }
            
           
        }
        
        
    }

    @IBAction func addFileAttachmentBtnAction(_ sender: UIButton) {
        if addBtn.backgroundColor != .lightGray {
            
          
            addAttachHeadingLbl.isHidden = false
            if dropDownTextLbl.text == "Text" {
                pathArr.append(contentTextViw.text)
                print("pathArrpathArr",pathArr.count)
                contentTextViw.text = ""
                addBtn.backgroundColor = .lightGray
                fileArr.append("")
                typeArr.append("TEXT")
               
                tv.delegate = self
                tv.dataSource = self
                tv.reloadData()
                submitView.backgroundColor = UIColor(named: "serach_color")
                
            }else  if dropDownTextLbl.text == "Image" {
                //            pathArr.removeAll()
                pathArr.append(contentsOf: aswImg)
                overAllPathArr.append(contentsOf: pathArr)
               
              
                    typeArr.append("IMAGE")
               
                
                fileArr.append("ImageIcon")
                overAllFileArr.append(contentsOf: typeArr)
                aswImg.removeAll()
                tv.delegate = self
                tv.dataSource = self
                tv.reloadData()
                addBtn.backgroundColor = .lightGray
                submitView.backgroundColor = UIColor(named: "serach_color")

            }else  if dropDownTextLbl.text == "Pdf" {
                
               
                pathArr.append(contentsOf: aswPdf)
                overAllPathArr.append(contentsOf: pathArr)
                
                fileArr.append("pdfImage")
                typeArr.append("PDF")
                aswImg.removeAll()
                tv.delegate = self
                tv.dataSource = self
                addBtn.backgroundColor = .lightGray
                tv.reloadData()
                submitView.backgroundColor = UIColor(named: "serach_color")

                
            }else  if dropDownTextLbl.text == "Voice" {
//                pathArr.append(contentTextViw.text)
                pathArr.append(contentsOf: aswVoice)
                addBtn.backgroundColor = .lightGray
              
                typeArr.append("VOICE")
                
                tv.delegate = self
                tv.dataSource = self
                tv.reloadData()
                submitView.backgroundColor = UIColor(named: "serach_color")

            }else  if dropDownTextLbl.text == "Video" {
              
                
                pathArr.append(contentsOf: aswImg)
                overAllPathArr.append(contentsOf: pathArr)
                
                fileArr.append("p23")
                addBtn.backgroundColor = .lightGray
                typeArr.append("VIDEO")
                aswImg.removeAll()
                tv.delegate = self
                tv.dataSource = self
                tv.reloadData()
                submitView.backgroundColor = UIColor(named: "serach_color")

                
            }
            
        }else{
           
            
            print("Backgroud light")
        }
       

    }
    
    
    @IBAction func voiceRecordBtnAction(_ sender: UIButton) {
        
        recodeVc()
        
    }
    
    func deleteSelectdItem(at indexPath: IndexPath) {
        print("indexPath",indexPath.row)
        guard indexPath.row < pathArr.count else { return }
           
           // Remove the time slot at the given row
           pathArr.remove(at: indexPath.row)
        typeArr.remove(at: indexPath.row)
           // Perform batch updates to delete the row from the table view
           tv.performBatchUpdates({
               tv.deleteRows(at: [indexPath], with: .automatic)
           }, completion: nil)
        }
//
    func textViewDidChange(_ textView: UITextView) {
          print("Text changed to: \(textView.text ?? "")")
        if textView.text.count > 0 {
                // Change the button color to blue when text exists
            addBtn.backgroundColor = UIColor(named: "AddContent")
            } else {
                // Change the button color to gray when no text exists
                addBtn.backgroundColor = .lightGray
            }
         
      }
    
    
    func selectPDF() {
        
        print("SELECT PDF")
        
        
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], in: .import)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt urls: URL) {
        
        let fileurl: URL = urls as URL
        let filename = urls.lastPathComponent
        let fileextension = urls.pathExtension
        print("URL: \(fileurl)", "NAME: \(filename)", "EXTENSION: \(fileextension)")
        
        
        let imageData = NSData(contentsOf: urls)
        
        
        
        
        do {
            pdfData = try Data(contentsOf: urls, options: NSData.ReadingOptions())
            
            
            if pdfData!.count > 0 {
                    // Change the button color to blue when text exists
               
                      addBtn.backgroundColor = UIColor(named: "AddContent")

                } else {
                    // Change the button color to gray when no text exists
                    self.addBtn.backgroundColor = .lightGray
                }
            uploadPDFFileToAWS(pdfData: pdfData!)
            
        } catch {
            print("set PDF filer error : ", error)
            
        }
        
        
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func openCamera() {
        
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
           
            cameraSelect = 1
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true // Allows editing of the captured image
            present(imagePicker, animated: true, completion: nil)
        } else {
            // Camera is not available, show an alert
            let alert = UIAlertController(title: "Camera Not Available", message: "This device has no camera.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
    }
    func ImagePickerGallery() {
        
        
        var config = PHPickerConfiguration()
                  config.selectionLimit = imageLimit // Limit selection to 5 images
                  config.filter = .images    // Only allow images
                  let picker = PHPickerViewController(configuration: config)
                  picker.delegate = self
     
                  present(picker, animated: true, completion: nil)
                  
    }
    
    
    @IBAction func selectImages() {
        
        
        if dropDownTextLbl.text == "Image" {
   
            let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
                self.ImagePickerGallery()
            }))
            
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera()
            }))
            
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            
            
        }else if dropDownTextLbl.text == "Pdf"{
            selectPDF()
        }else if dropDownTextLbl.text == "Video"{
            restrictionTv.isHidden = false
            restrictionView.isHidden = false
            
            restrictionList()
            
            
        }
       }
    
    
    func uploadPDFFileToAWS(pdfData : Data){
        let S3BucketName = DefaultsKeys.bucketNameIndia
        let CognitoPoolID = DefaultsKeys.CognitoPoolID
        let Region = AWSRegionType.APSouth1
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".pdf")
        
        let ext = imageName as String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let  currentDate =   dateFormatter.string(from: Date())
        
        
        let fileName = imageNameWithoutExtension
        let fileType = ".pdf"
        
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
        
        do {
            try pdfData.write(to: imageURL)
        }
        catch {}
        
        print(imageURL)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest?.body = imageURL
        uploadRequest?.key =  currentDate +  "/" + "File_" + ext
        uploadRequest?.bucket = S3BucketName
        
        uploadRequest?.contentType = "application/pdf"
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { [self] (task) -> AnyObject? in
            
            if let error = task.error {
                print("Upload failed : (\(error))")
                
                
            }
            
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                    aswPdf.removeAll()
                    aswPdf.append(absoluteString)
               
                    
                    let imageDict = NSMutableDictionary()
                    imageDict["FileName"] = absoluteString
                    self.imageUrlArray.add(imageDict)
                  
                    DispatchQueue.main.async {
                        addBtn.backgroundColor = UIColor(named: "AddContent")
                        self.convertedImagesUrlArray = self.imageUrlArray
                    }
                  
                }
            }
            else {
                
                
                print("Unexpected empty result.")
            }
            return nil
        }
    }
    
    func presentPhotoPicker(from viewController: UIViewController, selectionLimit: Int = 1) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = selectionLimit
        configuration.filter = .images // Only images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        viewController.present(picker, animated: true, completion: nil)
    }

    // Delegate method to handle selected items
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        var images = [UIImage]()
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    if let image = object as? UIImage {
                        images.append(image)
                        
                        if images.count > 0 {
                                // Change the button color to blue when text exists
                            DispatchQueue.main.async {
                                self?.addBtn.backgroundColor = UIColor(named: "AddContent")
                            }
                            } else {
                                // Change the button color to gray when no text exists
                                self!.addBtn.backgroundColor = .lightGray
                            }
                        KRProgressHUD.show()
                        self!.uploadAWS(image:image)
                    }
                    
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.onImagePicked?(images)
        }
    }
    
    func uploadAWS(image : UIImage){
    
        aswImg.removeAll()
        let S3BucketName =  DefaultsKeys.bucketNameIndia
           
        let CognitoPoolID = DefaultsKeys.CognitoPoolID
        let Region = AWSRegionType.APSouth1
        
        let currentTimeStamp = NSString.init(format: "%ld",Date() as CVarArg)
        let imageNameWithoutExtension = NSString.init(format: "vc_%@",currentTimeStamp)
        let imageName = NSString.init(format: "%@%@",imageNameWithoutExtension, ".png")
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let  currentDate =   dateFormatter.string(from: Date())
        
        let ext = imageName as String
        
        let fileName = imageNameWithoutExtension
        let fileType = ".jpg"
        
        let imageURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ext)
        let data = image.jpegData(compressionQuality: 0.9)
        do {
            try data?.write(to: imageURL)
        }
        catch {}
        
        print(imageURL)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = imageURL
        uploadRequest?.key =   currentDate +  "/" + "File_" + ext
        uploadRequest?.bucket = S3BucketName
        
        if getImagePdfType == "Image" {
            uploadRequest?.contentType = "image/png"
        } else{
            uploadRequest?.contentType = "image/png"
        }
      
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(uploadRequest!).continueWith { [self] (task) -> AnyObject? in
            
            if let error = task.error {
                print("Upload failed : (\(error))")
            }
            var imageFilePath = NSMutableArray()
            if task.result != nil {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent((uploadRequest?.bucket!)!).appendingPathComponent((uploadRequest?.key!)!)
                if let absoluteString = publicURL?.absoluteString {
                    print("Uploaded to:\(absoluteString)")
                   
                  
                    aswImg.append(absoluteString)
                    
                    print("aswImg",aswImg.count)
                  
                    
                    let imageDicthome = NSMutableDictionary()
                    imageDicthome["path"] = absoluteString
                    imageDicthome["type"] = "IMAGE"
                    let imageDict = NSMutableDictionary()
                    var emptyDictionary = [String: String]()
                    
                    imageFilePath.add(imageDicthome)
                    
                    KRProgressHUD.dismiss()
                    DispatchQueue.main.async {
                        
                        addBtn.backgroundColor = UIColor(named: "AddContent")
                        
                    }
                    self.currentImageCount = self.currentImageCount + 1
                    if self.currentImageCount < self.totalImageCount{
                        DispatchQueue.main.async {
                            self.getImageURL(images: self.originalImagesArray)
                       
                        }
                    }else{
                        self.convertedImagesUrlArray = self.imageUrlArray
                        
                        
                    }
                }
            }
            
            return nil
        }
       
    }
    func getImageURL(images : [UIImage]){
        
        
        
        self.originalImagesArray = images
        self.totalImageCount = images.count
        if currentImageCount < images.count{
            self.uploadAWS(image: images[currentImageCount])
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        contentTextViw.resignFirstResponder() // Dismiss keyboard
           return true
       }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
           if text == "\n" { // Detect 'Return' key press
               contentTextViw.resignFirstResponder() // Dismiss keyboard
               return false
           }
           return true
       }
    
    @IBAction   func pickVideoFromGallery() {
        restrictionView.isHidden = true
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.mediaTypes = ["public.movie"] // Only show videos
                imagePickerController.allowsEditing = true // Optional: allows users to edit video
                
                present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Photo library not available.")
            }
        }
        
        // MARK: This method is called when the user has picked a video
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
//
        if cameraSelect == 1 {
                        let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage

            picker.dismiss(animated: true, completion: nil)
            self.addBtn.backgroundColor = UIColor(named: "AddContent")

            self.uploadAWS(image:chosenImage)

        }else {
            if let videoURL = info[.mediaURL] as? URL {
                print("Selected video URL: \(videoURL)")
                uploadVideo(authToken: authToken, videoFilePath: videoURL)
                
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
    }
        
        //MARK: This method is called when the user cancels the picker
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }

    
    func getFileSize(at url: URL) -> UInt64? {
    do {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
            return fileSize
        }
    } catch {
        print("Error: \(error)")
    }
    return nil
    }

    func createVimeoUploadURL(authToken: String, videoFilePath: URL, completion: @escaping (UploadResult) -> Void) {

    guard let fileSize = getFileSize(at: videoFilePath) else {
        completion(.failure(NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get file size"])))
        return
    }

    let headers: HTTPHeaders = [
        "Authorization": "Bearer \(authToken)",
        "Content-Type": "application/json",
        "Accept": "application/vnd.vimeo.*+json;version=3.4"
    ]
        let userDefaults = UserDefaults.standard
        var getDownload =  userDefaults.value(forKey: DefaultsKeys.allowVideoDownload)
    let parameters: [String: Any] = [
        "upload": [
            "approach": "tus",
            "size": "\(fileSize)"
        ],
        "privacy":[
            "view":"unlisted",
            "download": getDownload
        ],
        "name": "TestTitle",
        "description": "descTxtFld.text"
    ]

    AF.request("https://api.vimeo.com/me/videos", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
        .responseJSON { [self] response in
            switch response.result {
            case .success(let value):
                print("Vimeo API Response: \(value)") // Print the full JSON
                if let json = value as? [String: Any],
                   let upload = json["upload"] as? [String: Any],
                   let uploadLink = upload["upload_link"] as? String {
                    
                    let embedUrl = json["player_embed_url"] as! String
                    
                    let embed = json["embed"]! as AnyObject
//                    iframeLink = embed["html"]  as! String
                    videoEmbdUrl = embedUrl as! String
                    print("videoEmbdUrl",videoEmbdUrl)
                    aswImg.append(videoEmbdUrl)
                    videoSucessId = 1
                    addBtn.backgroundColor = UIColor(named: "AddContent")

                    
                    VideoStatus()
                    completion(.success(uploadLink))
                    
                    
                } else {
                    completion(.failure(NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Upload link not found"])))
                    
                    videoSucessId = 0
                    VideoStatus()
                }
            case .failure(let error):
                completion(.failure(error))
                
                
                videoSucessId = 0
                VideoStatus()
            }
        }
    }

    func uploadVideoToVimeo(uploadLink: String, videoFilePath: URL, authToken: String, chunkSize: Int = 5 * 1024 * 1024, completion: @escaping (UploadResult) -> Void) {
    guard let fileHandle = try? FileHandle(forReadingFrom: videoFilePath) else {
        completion(.failure(NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to read video file"])))
        return
    }
   
    var offset: Int = 0
    let fileSize = fileHandle.seekToEndOfFile()
    fileHandle.seek(toFileOffset: 0)

    print("fileHandleBefore",fileHandle)
    func uploadNextChunk() {
        let chunkData = fileHandle.readData(ofLength: chunkSize)
        
        if chunkData.isEmpty {
            fileHandle.closeFile()
            completion(.success(("")))
            return
        }
        
        var request = URLRequest(url: URL(string: uploadLink)!)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/offset+octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("\(offset)", forHTTPHeaderField: "Upload-Offset")
        request.setValue("1.0.0", forHTTPHeaderField: "Tus-Resumable")
        request.httpBody = chunkData
        
        let uploadTask = URLSession.shared.uploadTask(with: request, from: chunkData) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    offset += chunkSize
                    uploadNextChunk()
                } else if httpResponse.statusCode == 412 {
                    // Handle 412 error (precondition failed), retry or get correct offset from server
                    if let rangeHeader = httpResponse.value(forHTTPHeaderField: "Upload-Offset"), let serverOffset = Int(rangeHeader) {
                        offset = serverOffset
                        uploadNextChunk()
                    } else {
                        let error = NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload chunk: Precondition Failed"])
                        completion(.failure(error))
                    }
                } else {
                    let error = NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload chunk, status code: \(httpResponse.statusCode)"])
                    completion(.failure(error))
                }
            }
        }
        
        uploadTask.resume()
    }

    uploadNextChunk()
    }

        
        func VideoStatus(){
            
            if videoSucessId == 0 {
                

            }else{
                
            }
            
        }
    func uploadVideo(authToken: String, videoFilePath: URL) {
    createVimeoUploadURL(authToken: authToken, videoFilePath: videoFilePath) { [self] result in
        switch result {
        case .success(let uploadLink):
            uploadVideoToVimeo(uploadLink: uploadLink, videoFilePath: videoFilePath, authToken: authToken) { [self] result in
                switch result {
                case .success:
                    print("Video uploaded successfully!")
                   
                    addBtn.backgroundColor = UIColor(named: "AddContent")
                case .failure(let error):
                    print("Failed to upload video: \(error)")
   
                   
                    let refreshAlert = UIAlertController(title: "", message: "Failed to upload video", preferredStyle: UIAlertController.Style.alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                        
                        
                        
                    }))
                    
                    
                    present(refreshAlert, animated: true, completion: nil)
                   
                }
                
                
            }
        case .failure(let error):
            print("Failed to create upload URL: \(error)")
   
           
            let refreshAlert = UIAlertController(title: "", message: "Failed to upload video", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
            }))
            
            
            present(refreshAlert, animated: true, completion: nil)
            
            
        }
    }
    }

   
    func Awws3Voice(URLPath : URL) {
        
        if let remoteUrl = URL(string: URLPath.absoluteString) {
            let task = URLSession.shared.downloadTask(with: remoteUrl) { localUrl, response, error in
                if let error = error {
                    print("Error downloading file: \(error.localizedDescription)")
                    return
                }
                
                guard let localUrl = localUrl else {
                    print("No local file URL available.")
                    return
                }
                
                // Log the local URL
                print("Local file URL: \(localUrl)")
                
                // Upload the downloaded file to S3
                AWSS3TransferUtility.default().uploadFile(
                    localUrl,
                    bucket: DefaultsKeys.bucketNameIndia,
                    key: URLPath.absoluteString,
                    contentType: "audio/mpeg",
                    expression: nil
                ) { [self] task, error in
                    if let error = error {
                        print("Error uploading file: \(error.localizedDescription)")
                    } else {
                        print("task",task)
                        let s3Url = "https://\(DefaultsKeys.bucketNameIndia).s3.amazonaws.com/\(URLPath.absoluteString)"
                        
                              print("File successfully uploaded to S3. URL: \(s3Url)")
                        DispatchQueue.main.async {
                            self.addBtn.backgroundColor = UIColor(named: "AddContent")
                        }
                        aswVoice.append(s3Url)
                      
                       
                        print("File successfully uploaded to S3.")
                    }
                }
            }
            task.resume()
        }
       
        
    }

    @IBAction func takeReadingSkill() {
        let vc = LSRWTakingSkillViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated:   true)
    }

    @IBAction func AttachmentRedirect(ges : LsrwListShowGesture) {
        
        
        let vc = LSRWTakingSkillViewController(nibName: nil, bundle: nil)
        vc.skillId = ges.getSkillId
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    
    
    @IBAction func submitAct() {
        
        
        var imageAryy : [AttachmentData] = []
        
        
        let attachModal = AttachmentData()
       
        for path in pathArr {
            attachModal.content = path
            print("pathArr",path)

        }
        
        for path in typeArr {
            attachModal.type = path
            print("typeArr",path)

        }
        
        
        
        var attachments: [AttachmentData] = []

        // Ensure pathArr and typeArr are of the same length
        guard pathArr.count == typeArr.count else {
            print("Error: pathArr and typeArr must have the same number of elements")
            return
        }
        
        
        for (index, path) in pathArr.enumerated() {
            let attachModal = AttachmentData()
            attachModal.content = path
            attachModal.type = typeArr[index]
            attachments.append(attachModal)
        }

        for attachment in attachments {
            print("Content: \(attachment.content ?? ""), Type: \(attachment.type ?? "")")
        }
        print("attacattachmentsl",attachments)
        
        let submitModal = SubmitResponseForSkillModal()
        submitModal.StudentID = studentId
        submitModal.SkillId = skillId
        submitModal.attachment = attachments
        
        
        print("submitModal",submitModal)
        var  submitModalStr = submitModal.toJSONString()
        print("submitModalStr",submitModalStr)
      
        
        SubmitSkillStudentRequest.call_request(param: submitModalStr!) {
            
            [self] (res) in
            
            let submitModalResp : [SubmitResponse] = Mapper<SubmitResponse>().mapArray(JSONString: res)!
            
            if  DefaultsKeys.failedErrorCode != 500 {
                if submitModalResp[0].Status == 1 {
                    
                    let alert = UIAlertController(title: "Alert",
                                                  message: submitModalResp[0].Message,
                                                  preferredStyle: .alert)
                    
                    // Add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        dismiss(animated: true)
                    }))
                    
                    // Present the alert
                    self.present(alert, animated: true, completion: nil)
                    
                    //
                    
                }
                
                
            }
        }
        
    }
    
    
    
//    MARK: Audio
    
    func check_record_permission()

        {

            switch AVAudioSession.sharedInstance().recordPermission {

            case AVAudioSession.RecordPermission.granted:

                isAudioRecordingGranted = true

                break

            case AVAudioSession.RecordPermission.denied:

                isAudioRecordingGranted = false

                break

            case AVAudioSession.RecordPermission.undetermined:

                AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in

                    if allowed {

                        self.isAudioRecordingGranted = true

                    } else {

                        self.isAudioRecordingGranted = false

                    }

                })

                break

            default:

                break

            }

        }
    
        func startSlider() {

            Slider.value = 0

            Slider.maximumValue = 10

            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] (timer) in

                print("Slider at: \(self?.Slider.value)")

                guard self?.Slider.isTracking == false else { return }

                self?.updateSlider(to: self!.Slider.value + 0.1)

            }

        }


        @objc private func updateSlider(to value: Float) {

            Slider.value = value

        }


        @IBAction func recodeVc(){

            
            addAttachTop.constant = -80
            voicePlayView.isHidden = true
            self.addBtn.backgroundColor = .lightGray
            aswVoice.removeAll()

            if(isRecording)

            {

                finishAudioRecording(success: true)

                self.voiceRecordBtn.setImage(UIImage(named:"VocieRecord"), for: UIControl.State.normal)

                isRecording = false

          
            }

            else

            {

                if isAudioRecordingGranted == false{

                    //                check_record_permission()

                    let alert = UIAlertController(title: "Error", message: "Please allow microphone usage from settings", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Open settings", style: .default, handler: { action in

                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)

                    }))

                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                    present(alert, animated: true, completion: nil)

                    

                }else{

                    setup_recorder()

                    audioRecorder.record()

                    meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)

                    self.voiceRecordBtn.setImage(UIImage(named:"VoiceRecordSelect"), for: UIControl.State.normal)


                    isRecording = true

                }

                
            }

            

        }

        

        func getDocumentsDirectory() -> URL

        {

            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

            let documentsDirectory = paths[0]

            print("asds",paths)

            return documentsDirectory

        }

        

        func getFileUrl() -> URL

        {

            let filename = "myRecording.m4a"

            

            let filePath = getDocumentsDirectory().appendingPathComponent(filename)

            

            print("filee",filePath)

            
            var myurl = filePath

            
            var urlString: String = myurl.absoluteString


            url = filePath

            overallTimeLbl.text = ""

            Audiopath = filePath

            AudioPlayUrl = filePath.absoluteString

            return filePath

        }

        
        func setup_recorder()

        {

            if isAudioRecordingGranted

            {

                let session = AVAudioSession.sharedInstance()

                do

                {

                    try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)

                    try session.setActive(true)

                    let settings = [

                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),

                        AVSampleRateKey: 44100,

                        AVNumberOfChannelsKey: 2,

                        AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue

                    ]

                    audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)

                    audioRecorder.delegate = self

                    audioRecorder.isMeteringEnabled = true

                    audioRecorder.record(forDuration: 180.00)// record for 3 minutes

                    

                    audioRecorder.prepareToRecord()

                }

                catch let error {

                    display_alert(msg_title: "Error", msg_desc: error.localizedDescription, action_title: "OK")

                }

            }

            else

            {

                display_alert(msg_title: "Error", msg_desc: "Don't have access to use your microphone.", action_title: "OK")

            }

        }

        

        func display_alert(msg_title : String , msg_desc : String ,action_title : String)

        {

            let ac = UIAlertController(title: msg_title, message: msg_desc, preferredStyle: .alert)

            ac.addAction(UIAlertAction(title: action_title, style: .default)

                         {

                (result : UIAlertAction) -> Void in

                _ = self.navigationController?.popViewController(animated: true)

            })

            present(ac, animated: true)

        }

        func finishAudioRecording(success: Bool)

        {

            if success

                

            {

                audioRecorder.stop()

                audioRecorder = nil

                meterTimer.invalidate()

                playVoiceHeight.constant = 110

                voicePlayView.isHidden = false
                addAttachTop.constant = 40
             
                addBtn.isHidden = false

               

                Awws3Voice(URLPath:  Audiopath)

                self.voiceRecordBtn.setImage(UIImage(named:"VocieRecord"), for: UIControl.State.normal)

         

                if  overallTimeLbl.text == "00:00" + " / " + "00:00"{

                    

                    

                    let refreshAlert = UIAlertController(title: "", message: "Voice file is Empty ", preferredStyle: UIAlertController.Style.alert)

                    

                    refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in

                        

                    }))

                    present(refreshAlert, animated: true, completion: nil)


                }

                

                

                else{


                    overallTimeLbl.isHidden = false

                    if timeLabelForPlayVoice == ""  || timeLabelForPlayVoice == nil {
                        
                        overallTimeLbl.text = "00:00" + " / " +  "00:00"
                    }

                    else{

                        overallTimeLbl.text = "00:00" + " / " + timeLabelForPlayVoice

                    }

                }
 

            }

            

            else

            

            {

                display_alert(msg_title: "Error", msg_desc: "Recording failed.", action_title: "OK")

                

            }

        }

        
        func prepare_play()

        {

            do

            {

                audioPlayer = try AVAudioPlayer(contentsOf: getFileUrl())

                audioPlayer.delegate = self

                audioPlayer.prepareToPlay()

            }

            catch{

                print("Error")

            }

        }

        @objc func updateAudioMeter(timer: Timer)

        {

            if audioRecorder.isRecording

            {

                let hr = Int((audioRecorder.currentTime / 60) / 60)

                let min = Int(audioRecorder.currentTime / 60)

                let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))

                let totalTimeString = String(format: "%02d:%02d", min, sec)

                let time  = String(format: "%02d",sec)

                print("klllllllfedsaz",time,sec)

                timeLabelForPlayVoice = totalTimeString

                timerLbl.text = totalTimeString + " / " + "03:00"
                audioRecorder.updateMeters()

            }

        }

        func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {

            return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)

        }


        func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)

        {

            if !flag

            {
                finishAudioRecording(success: false)
            }

        }
 
    
    func directoryURL() -> NSURL? {

            

            let fileManager = FileManager.default

            let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)

            let documentDirectory = urls[0] as NSURL

            let soundURL = documentDirectory.appendingPathComponent("sample.mp4")

            

            return soundURL as NSURL?

        }

        

        func startRecording() {

            let audioSession = AVAudioSession.sharedInstance()

            do{

                audioRecorder = try AVAudioRecorder(url: self.directoryURL()! as URL, settings: settings)

                urlData = audioRecorder.url

                audioRecorder.delegate = self

                audioRecorder.prepareToRecord()

                

            }catch{

                finishRecording(success: false)

            }

            do{

                try audioSession.setActive(true)

                audioRecorder.record()

            }catch{

            }

        }

        func finishRecording(success: Bool) {

            audioRecorder.stop()

            if success {

                audioRecorder = nil

               

            } else {

                audioRecorder = nil

            }

        }

        
        func funcStopRecording(){

   
            self.voiceRecordBtn.setImage(UIImage(named:"VocieRecord"), for: UIControl.State.normal)

            self.finishRecording(success: true)


            if(UIDevice.current.userInterfaceIdiom == .pad){

               

                self.overallTimeLbl.text = TotaldurationFormat

            }else{


                self.overallTimeLbl.text = TotaldurationFormat

            }

            
        }


        //MARK: Play Audio BUTTON ACTION

        @IBAction func actionPlayVoiceMessage(_ sender: UIButton){

            audioRecorder = nil

            var urls = URL(string: AudioPlayUrl)

            playerItem = AVPlayerItem(url: urls!)

            player = AVPlayer(playerItem: playerItem!)

            if self.player!.currentItem?.status == .readyToPlay{

            }

            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)),

                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,

                                                   object: player!.currentItem)

            if(PlayVocieButton.isSelected)

            {

                PlayVocieButton.isSelected = false

                let seconds1 : Int64 = Int64(Slider.value)

                let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)

                player!.seek(to: targetTime)

                strPlayStatus = "PlayIcon"

                player?.pause()

                PlayVocieButton.setImage(UIImage(named: "PlayIcon"), for: .normal)

            }else{

                PlayVocieButton.isSelected = true

                let seconds1 : Int64 = Int64(Slider.value)

                let targetTime : CMTime = CMTimeMake(value: seconds1, timescale: 1)

                player!.seek(to: targetTime)

                strPlayStatus = "play"

                player?.volume = 1

                player?.play()

                PlayVocieButton.setImage(UIImage(named: "PauseIcon"), for: .normal)

                print("enddddd")

            }

            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateSlidersss), userInfo: nil, repeats: true)

        }

        
        @objc func updateSlidersss(){

            if self.player!.currentItem?.status == .readyToPlay {

                

                time = CMTimeGetSeconds(self.player!.currentTime())

            }

            let duration : CMTime = playerItem!.asset.duration

            let seconds : Float64 = CMTimeGetSeconds(duration)

            Slider.maximumValue = Float(seconds)

            Slider.minimumValue = 0.0

            Slider.value = Float(time)

            

            if(time > 0){

                let minutes = Int(time) / 60 % 60

                let secondss = Int(time) % 60

                

                let durationFormat = String(format:"%02i:%02i", minutes, secondss)

                overallTimeLbl.text = durationFormat + " / " + timeLabelForPlayVoice

            }

            if(time == seconds){

                timer.invalidate()

                PlayVocieButton.isSelected = false

                Slider.value = 0.0

            }

        }

        @objc func playerDidFinishPlaying(sender: Notification) {

            timer.invalidate()

            Slider.value = 0.0

            player?.pause()

            PlayVocieButton.isSelected = false

            playerItem?.seek(to: CMTime.zero)
            PlayVocieButton.setImage(UIImage(named: "PlayIcon"), for: .normal)

        }
    
    
    func restrictionList() {
        
        RestrictionRequest.call_request(param: ""){ [self]
            
            (res) in
    
            let restrictionResp : [RestrictionResponse] =
            Mapper<RestrictionResponse>().mapArray(JSONString: res)!
            
            restrictionData = restrictionResp
            restrictionTv.delegate = self
            restrictionTv.dataSource = self
            restrictionTv.reloadData()
            
        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        print("false")

        if contentTextViw.text == "" {
            contentTextViw.text = strTextViewPlaceholder
            contentTextViw.textColor = UIColor.black
           
        }
         
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {

       
        if contentTextViw.text == strTextViewPlaceholder{
            contentTextViw.text = ""
            contentTextViw.textColor = UIColor.black
            contentTextViw.font = .boldSystemFont(ofSize: 14)

        }
        
    }
    
    @objc func didPressDoneButton(button: UIButton) {
        if( contentTextViw.text == "" ||  contentTextViw.text!.count == 0 || ( contentTextViw.text!.trimmingCharacters(in: .whitespaces).count) == 0){
            contentTextViw.text = strTextViewPlaceholder
            contentTextViw.textColor = UIColor.black
        }
        contentTextViw.resignFirstResponder()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setupTextViewAccessoryView()
        
        if(contentTextViw.text == strTextViewPlaceholder)
        {
            contentTextViw.text = ""
            contentTextViw.textColor = UIColor.black
            contentTextViw.font = .boldSystemFont(ofSize: 14)
        }
        
        return true
        
    }
    
    func setupTextViewAccessoryView() {
        let toolBar: UIToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        let flexsibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(didPressDoneButton))
        doneButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        toolBar.items = [flexsibleSpace, doneButton]
        contentTextViw.inputAccessoryView = toolBar
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("pathArrcount",pathArr.count)
        if tableView == restrictionTv {
            return restrictionData.count
        }else{
            return pathArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == restrictionTv {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: restrictionRowNib, for: indexPath) as! RestrictionTableViewCell
            
            let restriction : RestrictionResponse = restrictionData[indexPath.row]
            cell.contentLbl.text = restriction.Content
            cell.selectionStyle = .none
         
            return cell
           
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: rowId, for: indexPath) as! FileAttachmentTableViewCell
            
            cell.contentFilePathLbl.text = pathArr[indexPath.row]
            
            //     img   cell.contentFilePathLbl.text = fileArr[indexPath.row]
            cell.selectionStyle = .none
            
            
            let currentType = typeArr[indexPath.row]
            print("CellcurrentType",currentType)
            
            // Update the cell's image based on type
            switch currentType {
            case "IMAGE":
                cell.img.image = UIImage(named: "ImageIcon")
            case "TEXT":
                cell.img.image = UIImage(named: "TextIcon")
            case "VIDEO":
                cell.img.image = UIImage(named: "p23")
            case "PDF":
                cell.img.image = UIImage(named: "pdfImage")
            case "VOICE":
                cell.img.image = UIImage(named: "p1")
            default:
                cell.img.image = nil // Fallback image or nil
            }
            
            cell.indexPath = indexPath
            
            // Set the delete action closure
            cell.deleteAction = { [weak self] indexPath in
                self?.deleteSelectdItem(at: indexPath)
            }
            
            
            let closeGesture = UITapGestureRecognizer(target: self, action: #selector(selectMonthViewClick))
            dropDownView.addGestureRecognizer(closeGesture)
            
            
            if submitView.backgroundColor != .lightGray {
                
                let submitGesture = UITapGestureRecognizer(target: self, action: #selector(submitAct))
                submitView.addGestureRecognizer(submitGesture)
                
            }
            
            
            return  cell
        }
        
//
    }
    
      func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          UITableView.automaticDimension
      }
      
   
    
}


struct  FileAttach {
    
    
    let pathLbl: String!
    let img: String!
    
}
   
