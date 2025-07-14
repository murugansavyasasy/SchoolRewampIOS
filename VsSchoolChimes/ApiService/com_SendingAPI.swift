////
////  common_apiCall.swift
////  School Chimes
////
////  Created by SARANRAJ SHANMUGAM on 05/06/25.
////
//
//import Foundation
//

import UIKit
class  commonApi_forSending {
    var vimeoUploader: VimeoUploader?
    var uploadedURLs: [String] = []
    var array_selectedId : [String] = []
    let alert = CustomAlert()
    let YOUR_VIMEO_TOKEN = "8d74d8bf6b5742d39971cc7d3ffbb51a"
    
    
    
    func SendingAttachmentFlow(
        selectedAcadimicYearId : Int,
        target_type : Int,
        selectedId : [String] ,
        baseURL: String ,
        subjectId : String,
        message: String,
        from viewController: UIViewController,
        Common_request_params: [String: Any]? = nil,
        onComplete : @escaping(Send_AttachmentResponse) -> Void
    ) {
        let selectedType = user_inputs.selectedFileType
        var uploadedFiles: [[String: String]] = []
        var iframeValue = ""
        var fileSizeValue = ""
        let title = AlertstringFile.Confirm_title
        alert.showAlertCancel(
            title: title,
            message: message,
            actionLbl1: AlertstringFile.Yes_Send,
            actionLbl2: AlertstringFile.Cancel,
            on: viewController,
            onOk: { [self] in
                if selectedType == AttachmentTypeString.VIDEO {
                    guard let videoURL = user_inputs.VideoPath else {
                        print("❌ Video path is missing")
                        return
                    }
                    let videoTitle =  Common_request_params?[assignmentResquestStringKey.title] as? String ?? ""
                    let videoDescription = Common_request_params?[assignmentResquestStringKey.description] as? String ?? ""
                    
                    
//                    compressVideo(inputURL: videoURL) { [weak self] compressedURL in
//                        //            guard let self = self, let compressedURL = compressedURL else { return }
//
//                    }
                    startUpload(
                        from: viewController,
                        videoURL: videoURL,
                        title: videoTitle,
                        description: videoDescription
                    ) {
                        videoURLString,
                        iframeHTML,
                        fileSize,
                        finalEmbedUrl in
                        
                        if let videoURLString = videoURLString {
                            uploadedFiles = [["url": finalEmbedUrl ?? "","type": selectedType]]
                            if let iframeHTML = iframeHTML {
                                iframeValue = iframeHTML
                            }
                            if let size = fileSize {
                                fileSizeValue = self
                                    .convertSize(size)//String(size)
                            }
                            
                            self.sendAttachment(
                                from: viewController,
                                with: uploadedFiles,
                                iframe: iframeValue,
                                filesize: fileSizeValue,
                                baseURl: baseURL,
                                array_selectedId: selectedId,
                                target_type: target_type,
                                selectedAcadimicYearId: selectedAcadimicYearId,
                                Common_request_params: Common_request_params,
                                subjectId: subjectId
                            ) { response in
                                print("✅ Upload complete: \(response)")
                                onComplete(response)
                            }
                            
                            
                        } else {
                            print("❌ Video upload failed")
                            // Optionally show alert or retry UI
                        }
                    }
                }else {
                    
                    let file: Any = user_inputs.SelectedUrls
                    uploadAWSMedia(file: file) { [self] in
                        CircularProgressLoader.shared.hide()
                        let uploadedFiles: [[String: String]] = uploadedURLs.compactMap { url in
                            if let url = URL(string: url) {
                                let type = url.pathExtension.lowercased()
                                user_inputs.selectedFileType = type == CommonStringFile.jpg ? CommonStringFile.IMAGE : url.pathExtension.uppercased()
                            }
                            return [
                                CommonStringFile.url: url,
                                CommonStringFile.type: user_inputs.selectedFileType
                            ]
                        }
                        
                        sendAttachment(
                            from: viewController,
                            with: uploadedFiles,
                            iframe: iframeValue,
                            filesize: fileSizeValue,
                            baseURl: baseURL,
                            array_selectedId: selectedId,
                            target_type: target_type,
                            selectedAcadimicYearId: selectedAcadimicYearId,
                            Common_request_params: Common_request_params,
                            subjectId: subjectId
                        ) { response in
                            print("✅ Upload complete: \(response)")
                            onComplete(response)
                        }
                    }
                }
            },
            
            onNo: {
                print("User canceled.")
            }
        )
    }
    
    
    func sendAttachment(
        from viewController: UIViewController,
        with uploadedFiles: [[String: String]],
        iframe: String,
        filesize: String,
        baseURl: String,
        array_selectedId : [String],
        target_type : Int,
        selectedAcadimicYearId : Int,
        Common_request_params: [String: Any]? = nil,
        subjectId: String, onComplete : @escaping(Send_AttachmentResponse) -> Void) {
            
            
            var parameters: [String: Any] = [
                SendAttachmentStringFile.file_path: uploadedFiles,
                SendAttachmentStringFile.iframe: iframe,
                SendAttachmentStringFile.file_size: filesize,
                SendAttachmentStringFile.target_code: array_selectedId,
                SendAttachmentStringFile.target_type: target_type,
                SendAttachmentStringFile.academic_year_id: selectedAcadimicYearId
            ]
            
            // Conditionally add value
            if Menu_id.homeWorkMenuId == Menu_id.staffSelectedMenuId || Menu_id.isAssaignment == Menu_id.staffSelectedMenuId {
                parameters[UploadMessageKeys.subjectId] = subjectId
            }
            
            var finalParams = parameters
            if let common = Common_request_params {
                finalParams.merge(common) { (_, new) in new }
            }
            
            print("📤 Sending parameters Request : \(finalParams)")
            
            APIService.shared.makeApi(
                url: baseURl,
                parameters: finalParams,
                type: ApitTypeSringFile.POST,
                token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
            ) { [] (result: Result<Send_AttachmentResponse, Error>) in
                switch result {
                case .success(let successMessage):
                    onComplete(successMessage)
                    
                case .failure(let error):
                    print("❌ API error: \(error.localizedDescription)")
                    // Optional: Add alert for failure
                    let alert = UIAlertController(
                        title: "Error",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    viewController.present(alert, animated: true)
                }
            }
            
        }
    
    
    
    //Function for video upload
    func startUpload(from viewController: UIViewController,videoURL: URL, title: String, description: String, completion: @escaping (_ videoURLString: String?, _ iframeHTML: String?, _ fileSize: Int?,_ embedUrl: String?) -> Void) {
        print("📂 Selected video URL: \(videoURL)")
        
        CircularProgressLoader.shared.show()
        
        vimeoUploader = VimeoUploader(accessToken: YOUR_VIMEO_TOKEN, presentingViewController: viewController)
//        vimeoUploader?.userProvidedThumbnail = user_inputs.thumbNail
        vimeoUploader?.upload(videoFileURL: videoURL, title: title, description: description, progress: { progress in
            print("📊 Upload progress: \(progress * 100)%")
            CircularProgressLoader.shared.updateProgress(to: progress)
        }, completion: { videoURL, iframeHTML, fileSize, finalEmbedUrl in
            CircularProgressLoader.shared.hide()
            
            if let videoURL = videoURL {
                print("✅ Video uploaded! Watch it at: \(videoURL)")
                if let iframeHTML = iframeHTML {
                    print("💻 Embed HTML: \(iframeHTML)")
                }
                if let size = fileSize {
                    print("📦 File size: \(size) bytes")
                }
                if let emb = finalEmbedUrl {
                    print("📦 File : \(emb)")
                }
                try? FileManager.default.removeItem(at: URL(fileURLWithPath: videoURL))
                
                
                completion(videoURL, iframeHTML, fileSize, finalEmbedUrl)
            } else {
                print("❌ Upload failed!")
                completion(nil, nil, nil,nil)
            }
        })
    }
    
    
    func convertSize(_ sizeInBytes: Int) -> String {
        let kb = 1024.0
        let mb = kb * 1024
        let gb = mb * 1024
        let size = Double(sizeInBytes)
        
        switch size {
        case 0..<kb:
            return String(format: "%.0f B", size)
        case kb..<mb:
            return String(format: "%.2f KB", size / kb)
        case mb..<gb:
            return String(format: "%.2f MB", size / mb)
        default:
            return String(format: "%.2f GB", size / gb)
        }
    }
    
    
    func uploadAWSMedia(file: Any, completion: @escaping () -> Void) {
        var completed = 0
        func updateAndCheckCompletion(total: Int) {
            let progress = (Double(completed) / Double(total)) * 100
            CircularProgressLoader.shared.updateProgress(to: progress)
            if completed == total {
                CircularProgressLoader.shared.hide()
                completion()
            }
        }
        switch file {
            // 🎙️ Case: Audio File from String (URL Path)
        case let files as String:
            guard let audioURL = URL(string: files) else {
                print("❌ Invalid audio URL.")
                return
            }
            let total = 1
            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)
            let today_date = AwsCurrentDateString()
            AWSUploadManager.shared.uploadFileToAWS(
                file: audioURL,
                bucketPath:  "communication" + "/" + (UserDefaultFileManager
                    .get_staff_Details()?.school_id ?? "") + "/" + today_date
                ,
                bucketName: "schoolchimes-communication",
                progressHandler: { progress in
                    CircularProgressLoader.shared.updateProgress(to: progress)
                },
                completion: { url in
                    if let uploadedURL = url {
                        print("✅ Audio uploaded: \(uploadedURL)")
                        user_inputs.voice_link = uploadedURL
                    } else {
                        print("❌ Audio upload failed.")
                    }
                    
                    completed += 1
                    let progress = (Double(completed) / Double(total)) * 100
                    CircularProgressLoader.shared.updateProgress(to: progress)
                    
                    if completed == total {
                        CircularProgressLoader.shared.hide()
                        completion()
                    }
                }
            )
            
            // 🖼️ Case: Array of Images
        case let images as [UIImage]:
            let total = images.count
            guard !images.isEmpty else {
                completion()
                return
            }
            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)
            
            for (index, img) in images.enumerated() {
                AWSUploadManager.shared.uploadFileToAWS(
                    file: img,
                    bucketPath: "uploads/images/",
                    bucketName: "schoolchimes-communication",
                    progressHandler: { progress in
                        // Optional: Update progress per file individually if you want
                    },
                    completion: { [self] url in
                        if let uploadedURL = url {
                            uploadedURLs.append(uploadedURL)
                            
                        } else {
                            print("❌ Failed to upload image \(index)")
                        }
                        
                        completed += 1
                        let progress = (Double(completed) / Double(total)) * 100
                        CircularProgressLoader.shared.updateProgress(to: progress)
                        if completed == total {
                            CircularProgressLoader.shared.hide()
                            // Do something with uploadedURLs if needed
                            completion()
                        }
                    }
                )
            }
            // 🖼️ Case: Array of Images
        case let files as [String]:
            let total = files.count
            guard !files.isEmpty else {
                completion()
                return
            }
            
            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)
            
            for (index, url) in files.enumerated() {
                guard let PdfURL = URL(string: url) else {
                    print("❌ Invalid audio URL.")
                    return
                }
                AWSUploadManager.shared.uploadFileToAWS(
                    file: PdfURL,
                    bucketPath: "uploads/Documents/",
                    bucketName: "schoolchimes-communication",
                    progressHandler: { progress in
                        // Optional: Update progress per file individually if you want
                    },
                    completion: { [self] url in
                        if let uploadedURL = url {
                            uploadedURLs.append(uploadedURL)
                            
                        } else {
                            print("❌ Failed to upload image \(index)")
                        }
                        
                        completed += 1
                        let progress = (Double(completed) / Double(total)) * 100
                        CircularProgressLoader.shared.updateProgress(to: progress)
                        
                        if completed == total {
                            CircularProgressLoader.shared.hide()
                            // Do something with uploadedURLs if needed
                            completion()
                        }
                    }
                )
            }
        case let attachments as [AttachmentItem]:
            let uploadableItems = attachments.filter { $0.image != nil || $0.imageURL != nil }
            let total = uploadableItems.count
            guard total > 0 else {
                completion()
                return
            }
            
            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)
            
            for item in uploadableItems {
                if let image = item.image {
                    // 🖼️ Upload local image
                    AWSUploadManager.shared.uploadFileToAWS(
                        file: image,
                        bucketPath: "uploads/images/",
                        bucketName: "schoolchimes-communication",
                        progressHandler: nil,
                        completion: { url in
                            if let uploadedURL = url {
                                self.uploadedURLs.append(uploadedURL)
                            }
                            completed += 1
                            updateAndCheckCompletion(total: total)
                        }
                    )
                } else if let fileURLStr = item.imageURL {
                    if fileURLStr.lowercased().starts(with: "http") {
                        self.uploadedURLs.append(fileURLStr)
                        completed += 1
                        updateAndCheckCompletion(total: total)
                    } else if let fileURL = URL(string: fileURLStr) {
                        let path = item.fileType.lowercased() != CommonStringFile.IMAGE ? "uploads/Documents/" : "uploads/images/"
                        
                        AWSUploadManager.shared.uploadFileToAWS(
                            file: fileURL,
                            bucketPath: path,
                            bucketName: "schoolchimes-communication",
                            progressHandler: nil,
                            completion: { url in
                                if let uploadedURL = url {
                                    self.uploadedURLs.append(uploadedURL)
                                }
                                completed += 1
                                updateAndCheckCompletion(total: total)
                            }
                        )
                    } else {
                        print("❌ Invalid fileURL: \(fileURLStr)")
                        completed += 1
                        updateAndCheckCompletion(total: total)
                    }
                }
            }
        default:
            print("❌ Unsupported file type")
            return
        }
    }
    
    
    
}
