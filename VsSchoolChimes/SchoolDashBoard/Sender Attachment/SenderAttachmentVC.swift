//
//  SenderAttachmentVC.swift
//  VsSchoolChimes
//
//  Created by Lakshmanan on 17/04/25.
//

import UIKit
import DropDown
import AWSCore
import AWSS3
import AVFoundation
import AVKit
import Alamofire


@available(iOS 14.0, *)
class SenderAttachmentVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate,UIDocumentPickerDelegate, DeleteImge {
    
    func deleteImage(index: Int) {
        selectedImages.remove(at: index)
        if fileUrls.count != 0{
            fileUrls.remove(at: index)
        }
    
        selectImgPdfview.imageCollectionview.reloadData()
    }
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var TextviewHeight: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var AddAttachmentsLbl: UILabel!
    @IBOutlet weak var letterscountLbl: UILabel!
    @IBOutlet weak var DescriptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var addphotosheight: NSLayoutConstraint!
    @IBOutlet weak var AssignmenttypeLbl: UILabel!
    @IBOutlet weak var collectionViewHeght: NSLayoutConstraint!
    @IBOutlet weak var assignTitleTxtFld: UITextField!
    @IBOutlet weak var chooseRecipientsBtn: UIButton!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var selectImgPdfview: ImageSelection!
    @IBOutlet weak var AssignmentTypeview: UIView!
    @IBOutlet weak var VideoView: UIView!
    @IBOutlet weak var VideoThumbnailImg: UIImageView!
    @IBOutlet weak var VideoPlayBtn: UIButton!
    @IBOutlet weak var ClickTochooseVideoLbl: UILabel!
    @IBOutlet weak var AddAtachmentStack: UIStackView!
    
    var selectedShow = ""
    var selectedImages: [UIImage] = []
    var getType = "Principal"
    var imageStr : [String] = []
    var currentImageCount = 0
    var schoolListArr = ["Sales","Vss","SSS","SSS2020"]
    var totalImageCount = 0
    var originalImagesArray = [UIImage]()
    var imageUrlArray = NSMutableArray()
    var  getImagePdfType : String!
    var convertedImagesUrlArray = NSMutableArray()
    let photoPickManager = PhotoPickerManager.shared
    let dropDown = DropDown()
    let TypeDropDown = DropDown()
    var datePicker : UIDatePicker!
    var doneButton : UIButton!
    var pdfData: Data?
    let customdate = DateFormatter()
    let formatter = DateFormatter()
    let initialHeight: CGFloat = 60
    let maxHeight: CGFloat = 300
    
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    var playerurl: URL?
    var videoEmbdUrl : String!
    var iframeLink : String!
    var videoSucessId = 0
    var isImage = false
    var selectedImgUrl: [FilePath] = []
    var url : URL?
    var fileUrls = [String]()
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    
    var alert = CustomAlert()
    
    let vimeoAccessToken = "8d74d8bf6b5742d39971cc7d3ffbb51a"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StyleAndTranslater()
        BackBtn.applyBackButton()
        
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
        
        assignTitleTxtFld.addDoneButton()
        contentTextView.addDoneButton()
        contentTextView.delegate = self
        contentTextView.applyRightTxt()
       
        AssignmenttypeLbl.applyRightTxt()
        DescriptionLbl.applyRightTxt()
        letterscountLbl.applyRightTxt()
        titleLbl.applyRightTxt()
        assignTitleTxtFld.applyRightTxt()
        
        let typeGesture = UITapGestureRecognizer(target: self, action: #selector(typeDropdown))
        AssignmentTypeview.addGestureRecognizer(typeGesture)
        
        let PlayGesture = UITapGestureRecognizer(target: self, action: #selector(ChooseVideoBtnAct))
        VideoView.addGestureRecognizer(PlayGesture)
        
        selectImgPdfview.imageCollectionview.delegate = self
        selectImgPdfview.imageCollectionview.dataSource = self
        
        imageSelection()
    }
    
    func imageSelection(){
        
        PhotoPickerManager.shared.onCameraImagePicked = { [self] image in
            if url != nil{
                selectedImages.removeAll()
                fileUrls.removeAll()
                url = nil
            }
            selectedImages.append(image)
            selectImgPdfview.imageCollectionview.reloadData()
        }
        
        PhotoPickerManager.shared.onImagesPicked = { [self] images in
            if url != nil{
                selectedImages.removeAll()
                url = nil
                fileUrls.removeAll()
            }
            selectedImages.append(contentsOf: images)
            selectImgPdfview.imageCollectionview.reloadData()
        }

        PhotoPickerManager.shared.onFilePicked = { [self] data in
            url = data.absoluteURL
            
            if let ulr = url?.absoluteString{
                fileUrls.append(ulr)
            }
            
            selectedImages.append(ImageName.pdf!)
            selectImgPdfview.imageCollectionview.reloadData()
        }
        
    }
    
    func getExtension(from filePath: String) -> String? {
     return URL(string: filePath)?.pathExtension.lowercased()
    }
     
    override func viewDidLayoutSubviews() {
        
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self)
    }
    
    func  StyleAndTranslater(){
        
        TextviewHeight.constant = initialHeight
        
        //MARK: UI Update
        AddAtachmentStack.isHidden = true
        VideoView.isHidden = true
        selectImgPdfview.isHidden = true
    
        VideoView.layer.cornerRadius = 10
        AssignmentTypeview.layer.cornerRadius = 10
        selectImgPdfview.layer.cornerRadius = 10
        contentTextView.layer.cornerRadius = 10
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.gray.cgColor
        chooseRecipientsBtn.backgroundColor = .button
        chooseRecipientsBtn.layer.cornerRadius = 10
        AssignmentTypeview.layer.borderWidth = 1
        AssignmentTypeview.layer.borderColor = UIColor.lightGray.cgColor
        AssignmentTypeview.backgroundColor = .white
        contentTextView.text = CommonStringFile.Description.translated()
        contentTextView.textColor = .lightGray
        
        //MARK: Button Font Style
        chooseRecipientsBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        BackBtn.setTitleFont(style: .primary, size: FontSize.TitleSize)
       
        //MARK: Label Font Style
        AddAttachmentsLbl.setFont(style: .title, size: FontSize.TitleSize)
        letterscountLbl.setFont(style: .body, size: FontSize.BodySize)
        DescriptionLbl.setFont(style: .title, size: FontSize.TitleSize)
        titleLbl.setFont(style: .title, size: FontSize.TitleSize)
        AssignmenttypeLbl.setFont(style: .title, size: FontSize.TitleSize)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        self.dismiss(animated: true, completion: nil)
        let selectedDate = sender.date
        print("Selected Date: \(selectedDate)")
    }
    
    @IBAction func backVc() {
        
        dismiss(animated: true)
    }
    
    @IBAction func chooseRecipientsAction(_ sender: UIButton) {
        
        if assignTitleTxtFld.text != ""  && contentTextView.text != ""{
            user_inputs.title = assignTitleTxtFld.text ?? ""
            user_inputs.description = contentTextView.text ?? ""
            user_inputs.selectedImg = selectedImages
            user_inputs.docUrl = fileUrls
            
            if isStaff(){
                let vc = SchoolListVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                vc.screen_type = Menu_id.AttachmentMenuId
                present(vc, animated: true)
            } else{
                let vc = RecipientVc(nibName: nil, bundle: nil)
                vc.ScreenType = Menu_id.AttachmentMenuId
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
            
        } else{
            
            alert
                .showAlert(
                    title: "",
                    message: AlertstringFile.enter_title_description,
                    on: self)
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
    
    @IBAction  func typeDropdown (){
        TypeDropDown.dataSource = ["IMAGE", "DOCUMENT","VIDEO"]
        self.view.layoutIfNeeded()
        TypeDropDown.width = AssignmentTypeview.bounds.width
        TypeDropDown.bottomOffset = CGPoint(x: 0, y: AssignmentTypeview.bounds.height - 220)
        
        TypeDropDown.direction = .bottom
        TypeDropDown.show()
        TypeDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            // Update the label inside the UIView
            if item == "VIDEO"{
                
                self!.isImage = false
//                self!.collectionViewHeght.constant = 0
//                self!.addphotosheight.constant = 0
                self!.VideoView.isHidden = false
                self!.AddAtachmentStack.isHidden = false
                self!.selectImgPdfview.isHidden = true
                self!.AddAttachmentsLbl.text = "Add Video".translated()
                user_inputs.selectedFileType = "VIDEO"
                self!.fileUrls.removeAll()
                self!.selectedImages.removeAll()
                
            }
            else if item == "DOCUMENT"{
                
                self!.isImage = false
                self!.VideoView.isHidden = true
                self!.AddAtachmentStack.isHidden = false
                self!.selectImgPdfview.isHidden = false
//                self!.collectionViewHeght.constant = 120
//                self!.addphotosheight.constant = 20
                self!.AddAttachmentsLbl.text = CommonStringFile.AddPdf.translated()
                user_inputs.selectedFileType = "DOCUMENT"
                self!.selectedImages.removeAll()
                self!.selectImgPdfview.imageCollectionview.reloadData()
            }
            else{
                
                self!.isImage = true
                self!.VideoView.isHidden = true
                self!.AddAtachmentStack.isHidden = false
                self!.selectImgPdfview.isHidden = false
//                self!.collectionViewHeght.constant = 120
//                self!.addphotosheight.constant = 20
                self!.AddAttachmentsLbl.text = CommonStringFile.AddPhotos.translated()
                user_inputs.selectedFileType = "IMAGE"
                self!.fileUrls.removeAll()
                self!.selectImgPdfview.imageCollectionview.reloadData()
            }
            
            if let label = self?.AssignmentTypeview.subviews.first(where: { $0 is UILabel }) as? UILabel {
                self!.AssignmenttypeLbl.text = item
            }
        }
    }
    
    
    // MARK: File Attachments Actions
    func selectImages() {
        if selectedImages.count <= 5{
            PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: 5 - selectedImages.count - selectedImgUrl.count), from: self)
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    func openCamera(){
        
        let count = selectedImages.count - selectedImgUrl.count
        if count <= 5{
            PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    func selectPDF() {
        let count = 5 - fileUrls.count
        
        if count <= 5{
            PhotoPickerManager.shared.limiSelection = count
            PhotoPickerManager.shared.presentPicker(ofType: .file, from: self)
           
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    /*func selectImages() {
        if selectedImages.count != 5{
            PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: 5 - selectedImages.count), from: self)
            
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }
    
    func selectPdf() {
        PhotoPickerManager.shared.presentPicker(ofType: .pdf, from: self)
    }
    
    // MARK: Handle Select Camera,Pdf,Image
    @IBAction func openCamera() {
        if selectedImages.count != 5{
            PhotoPickerManager.shared.presentPicker(ofType: .camera, from: self)
        }else{
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            
        }
    }*/
    
    @objc func playVideo() {
        VideoPlayBtn.isHidden = true
        VideoThumbnailImg.isHidden = true
        
        if let playerurl = playerurl {
            player = AVPlayer(url: playerurl)
            print("playerurl: \(playerurl)")
            
            playerViewController = AVPlayerViewController()
            playerViewController?.player = player
            playerViewController?.showsPlaybackControls = true
            
            self.addChild(playerViewController!)
            playerViewController?.view.frame = VideoView.bounds
            self.VideoView.addSubview(playerViewController!.view)
            playerViewController?.didMove(toParent: self)
            playerViewController?.view.layer.cornerRadius = 10
            playerViewController?.view.clipsToBounds = true
            player?.play()
        }
    }
    
    
    //MARK: Function to generate thumbnail from the video URL
    func generateThumbnail(from videoURL: URL){
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            
            VideoThumbnailImg.isHidden = false
            VideoThumbnailImg.layer.cornerRadius = 10
            VideoThumbnailImg.image = UIImage(cgImage: cgImage)
            ClickTochooseVideoLbl.isHidden = true
            VideoPlayBtn.isHidden = false
            VideoPlayBtn.setImage(UIImage(named: "play-button"), for: .normal)
            
        } catch {
            print("Error generating thumbnail: \(error)")
            
        }
    }
    
    
    @IBAction func ChooseVideoBtnAct(_ sender: Any) {
        if playerurl == nil{
            pickVideoFromGallery()
        }
    }
    
    
    
    @IBAction func PlayBtnAct(_ sender: Any) {
        if VideoPlayBtn.currentImage == ImageName.playbutton{
            playVideo()
        }
        else{
            pickVideoFromGallery()
        }
    }
    
    
    @IBAction func ChangeVideoBtnAct(_ sender: Any) {
        
        if playerurl == nil {
            let alert = CustomAlert()
            alert.showAlert(title: "Video", message: AlertstringFile.Please_choose_video, on: self)
        }
        else{
            
            pickVideoFromGallery()
        }
    }
    
    func stopCurrentVideo() {
        player?.pause()
        player = nil
        playerViewController?.view.removeFromSuperview()
        playerViewController = nil
    }
    
    
    @IBAction func SendBtnAct(_ sender: Any) {
         
    }
    
    // MARK: This method is pick Video From Gallery
    @IBAction   func pickVideoFromGallery() {
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
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let videoURL = info[.mediaURL] as? URL {
//            if playerurl != nil{
//                stopCurrentVideo()
//                playerurl = nil
//            }
//            
//         
//            playerurl = videoURL
//            print("Selected video URL: \(videoURL)")
//            generateThumbnail(from: playerurl!)
//        }
//        
//        picker.dismiss(animated: true, completion: nil)
//    }
    
    //MARK: This method is called when the user cancels the picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Upoload to vimeo using url session
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           picker.dismiss(animated: true)

           if let videoURL = info[.mediaURL] as? URL {
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                   self.uploadVideoToVimeo(videoFileURL: videoURL)
               }
           }
       }

       func uploadVideoToVimeo(videoFileURL: URL) {
           getVimeoUploadLink(videoFileURL: videoFileURL) { uploadURL in
               guard let uploadURL = uploadURL else {
                   print("❌ Could not get upload link")
                   return
               }

               self.checkUploadOffset(uploadURL: uploadURL) { offset in
                   guard let offset = offset else {
                       print("❌ Upload server not ready")
                       return
                   }

                   self.uploadVideoUsingTUS(videoFileURL: videoFileURL, uploadURL: uploadURL, offset: offset) { success in
                       if success {
                           print("✅ Upload complete")
                           self.showSuccessAlert()
                       } else {
                           print("❌ Upload failed")
                       }
                   }
               }
           }
       }

       func getVimeoUploadLink(videoFileURL: URL, completion: @escaping (URL?) -> Void) {
           let fileSize = (try? FileManager.default.attributesOfItem(atPath: videoFileURL.path)[.size] as? Int) ?? 0

           var request = URLRequest(url: URL(string: "https://api.vimeo.com/me/videos")!)
           request.httpMethod = "POST"
           request.setValue("Bearer \(vimeoAccessToken)", forHTTPHeaderField: "Authorization")
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           request.setValue("application/vnd.vimeo.*+json;version=3.4", forHTTPHeaderField: "Accept")

           let body: [String: Any] = [
               "upload": [
                   "approach": "tus",
                   "size": fileSize
               ]
           ]

           request.httpBody = try? JSONSerialization.data(withJSONObject: body)

           URLSession.shared.dataTask(with: request) { data, response, error in
               guard let data = data else {
                   print("❌ Upload link request error: \(error?.localizedDescription ?? "Unknown")")
                   completion(nil)
                   return
               }

               if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let upload = json["upload"] as? [String: Any],
                  let uploadLink = upload["upload_link"] as? String,
                  let url = URL(string: uploadLink) {
                   print("✅ Got upload URL: \(uploadLink)")
                   completion(url)
               } else {
                   print("❌ Failed to parse upload link")
                   completion(nil)
               }
           }.resume()
       }

       func checkUploadOffset(uploadURL: URL, completion: @escaping (Int?) -> Void) {
           var request = URLRequest(url: uploadURL)
           request.httpMethod = "HEAD"
           request.setValue("Bearer \(vimeoAccessToken)", forHTTPHeaderField: "Authorization")
           request.setValue("1.0.0", forHTTPHeaderField: "Tus-Resumable")

           URLSession.shared.dataTask(with: request) { _, response, error in
               if let httpResponse = response as? HTTPURLResponse {
                   let offsetHeader = httpResponse.allHeaderFields["Upload-Offset"] as? String ?? "0"
                   let offset = Int(offsetHeader) ?? 0
                   print("👀 HEAD response: \(httpResponse.statusCode), offset: \(offset)")
                   completion(offset)
               } else {
                   print("❌ HEAD failed: \(error?.localizedDescription ?? "No response")")
                   completion(nil)
               }
           }.resume()
       }

       func uploadVideoUsingTUS(videoFileURL: URL, uploadURL: URL, offset: Int = 0, completion: @escaping (Bool) -> Void) {
           guard let fileData = try? Data(contentsOf: videoFileURL) else {
               print("❌ Could not read video data")
               completion(false)
               return
           }

           let fileSize = fileData.count
           let uploadData = fileData.subdata(in: offset..<fileSize)

           var request = URLRequest(url: uploadURL)
           request.httpMethod = "PATCH"
           request.setValue("application/offset+octet-stream", forHTTPHeaderField: "Content-Type")
           request.setValue("\(offset)", forHTTPHeaderField: "Upload-Offset")
           request.setValue("1.0.0", forHTTPHeaderField: "Tus-Resumable")
           request.setValue("\(uploadData.count)", forHTTPHeaderField: "Content-Length")

           let config = URLSessionConfiguration.default
           config.timeoutIntervalForRequest = 300
           config.timeoutIntervalForResource = 300

           let session = URLSession(configuration: config)

           print("🚀 Uploading from offset \(offset)... Data size: \(uploadData.count) bytes")

           let task = session.uploadTask(with: request, from: uploadData) { [self] data, response, error in
               if let error = error {
                   print("❌ Upload error: \(error.localizedDescription)")
                   completion(false)
                   return
               }

               if let httpResponse = response as? HTTPURLResponse {
                   print("📦 Response code: \(httpResponse.statusCode)")
                   if httpResponse.statusCode == 204 {
                       completion(true)
                   } else {
                       print("❌ Unexpected response code")
                       completion(false)
                   }
               } else {
                   print("❌ No HTTP response")
                   completion(false)
               }
           }

           task.resume()
       }

       func showSuccessAlert() {
           DispatchQueue.main.async {
               let alert = UIAlertController(title: "✅ Success", message: "Your video has been uploaded to Vimeo!", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               self.present(alert, animated: true)
           }
       }
    
    
    
    //---------------------------------------------------------------------------
    
    //MARK: This method is Vimeo Upload
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
        
        let parameters: [String: Any] = [
            "upload": [
                "approach": "tus",
                "size": "\(fileSize)"
            ],
            "name": assignTitleTxtFld.text ?? "",
            "description": contentTextView.text ?? ""
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
                        iframeLink = embed["html"]  as! String
                        videoEmbdUrl = embedUrl as! String
                        
                        videoSucessId = 1
                        
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
                        
                        
                    case .failure(let error):
                        print("Failed to upload video: \(error)")
                        
                        let refreshAlert = UIAlertController(title: "", message: AlertstringFile.Failed_to_upload_video, preferredStyle: UIAlertController.Style.alert)
                        
                        refreshAlert.addAction(UIAlertAction(title: AlertstringFile.OK, style: .default, handler: { [self] (action: UIAlertAction!) in
                            
                        }))
                        
                        present(refreshAlert, animated: true, completion: nil)
                        
                    }
                    
                }
            case .failure(let error):
                
                print("Failed to create upload URL: \(error)")
                
                let refreshAlert = UIAlertController(title: "", message: AlertstringFile.Failed_to_upload_video, preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: AlertstringFile.OK, style: .default, handler: { [self] (action: UIAlertAction!) in
                }))

                present(refreshAlert, animated: true, completion: nil)
            }
        }
    }
}


@available(iOS 14.0, *)
extension SenderAttachmentVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + selectedImages.count + selectedImgUrl.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            let cell = selectImgPdfview.imageCollectionview.dequeueReusableCell(withReuseIdentifier: "AttachmentCVCell", for: indexPath) as! AttachmentCVCell
            cell.layer.cornerRadius = 20
            return cell
        }else{
//            let cell = selectImgPdfview.imageCollectionview.dequeueReusableCell(withReuseIdentifier: "ImageCvCell", for: indexPath) as! ImageCvCell
//            cell.delegate = self
//            cell.deleteBtn.tag = indexPath.item - 1
//            if selectedImages.count > indexPath.item - 1 {
//                // Assign the image starting from the second image in the selectedImages array
//                cell.imageViews.image = selectedImages[indexPath.item - 1]
//            } else {
//                cell.imageViews.image = nil
//            }
//            if selectedImages.count <= 2{
//                collectionViewHeght.constant = 120
//            }else{
//                collectionViewHeght.constant = 220
//            }
//            return cell
            
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
            collectionViewHeght.constant = totalItems <= 2 ? 120 : 220

            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (selectImgPdfview.imageCollectionview.frame.width - 30) / 3 // Subtract spacing from total width, then divide by 3
        
        return CGSize(width: 100, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let alertController = UIAlertController(title: "Select".translated(), message: "Choose an option".translated(), preferredStyle: .actionSheet)
            
            if isImage{
                // Camera option
                let cameraAction = UIAlertAction(title: "Camera".translated(), style: .default) { [self] _ in
                    
                    openCamera()
                }
                alertController.addAction(cameraAction)
                
                // Gallery option
                let galleryAction = UIAlertAction(title: "Gallery".translated(), style: .default) { [self] _ in
                    
                    selectImages()
                }
                alertController.addAction(galleryAction)
                
            } else {
                
                let pdfAction = UIAlertAction(title: "PDF".translated(), style: .default) { [self] _ in
                    
                    selectPDF()
                }
                alertController.addAction(pdfAction)
            }
           
            
            // Cancel action
            let cancelAction = UIAlertAction(title: "Cancel".translated(), style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            // Present the alert
            self.present(alertController, animated: true, completion: nil)
        }else{
            
            if selectedImages.count > indexPath.item - 1 {
                let vc = PreviewImageVC(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                
                if fileUrls.count != 0{
                    if let url = URL(string: fileUrls[indexPath.item - 1]){
                        vc.selectedFileURL = url
                    }
                }
                
                // Safe unwrapping of imgView before assigning
                vc.img = selectedImages[indexPath.item - 1]
                vc.type = user_inputs.selectedFileType
                present(vc, animated: true)
            }
        }
    }
    
}

@available(iOS 14.0, *)
extension SenderAttachmentVC : UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTextView.text == CommonStringFile.Description.translated() {
            
            contentTextView.text = ""
            contentTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if contentTextView.text == "" {
            
            contentTextView.text = CommonStringFile.Description
            contentTextView.textColor = .lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Current text in the UITextView
        let currentText = textView.text ?? ""
        
        // Compute the new text length
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if newText.count <= 500 {
            letterscountLbl.text = "\(newText.count) of 500" // Update the character count label
            return true // Allow the change
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            //contentTxtView.isEditable = false // Optionally disable editing
            return false // Reject the change
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            // Adjust the scroll view content inset
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight+30, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
            
            // Ensure the UITextView is visible
            scrollToView(contentTextView)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // Reset the scroll view content inset
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    // UITextViewDelegate Method: Adjust the height of the UITextView dynamically
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.contentSize
        
        // Check if the content exceeds the initial height
        if size.height > initialHeight {
            // Update the height constraint based on content size
            let newHeight = min(size.height, maxHeight) // Cap the height to maxTextViewHeight
            TextviewHeight.constant = newHeight
            // Execute function when text exceeds boundary
            executeFunctionWhenTextExceeds()
        }
        
        // Animate the change for smoother UI
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        // Scroll to make the UITextView visible
        scrollToView(textView)
    }
    
    // Helper Method: Scroll to a specific view inside the UIScrollView
    func scrollToView(_ view: UIView) {
        // Calculate the frame of the view relative to the UIScrollView
        let rect = view.convert(view.bounds, to: scrollView)
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    // The function you want to execute when the text exceeds the boundary
    func executeFunctionWhenTextExceeds() {
        // Your custom logic here, e.g., log a message, trigger an event, etc.
        print("TextView content has exceeded the initial height.")
    }
    
}
