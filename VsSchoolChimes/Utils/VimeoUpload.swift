////
////  VimeoUpload.swift
////  VsSchoolChimes
////
////  Created by Apple on 11/12/24.
////
//
//import Foundation
//



//func uploadVideo(authToken: String, videoFilePath: URL) {
//    createVimeoUploadURL(authToken: authToken, videoFilePath: videoFilePath) { [self] result in
//        switch result {
//        case .success(let uploadLink):
//            uploadVideoToVimeo(uploadLink: uploadLink, videoFilePath: videoFilePath, authToken: authToken) { [self] result in
//                switch result {
//                case .success:
//                    print("Video uploaded successfully!")
//                    KRProgressHUD.dismiss()
////                        uploadfileNameLabel.text? = "Selected Video File : 1"
//                    self.progressShowView.isHidden = true
//                case .failure(let error):
//                    print("Failed to upload video: \(error)")
//                    KRProgressHUD.dismiss()
//                    let refreshAlert = UIAlertController(title: "", message: "Failed to upload video", preferredStyle: UIAlertController.Style.alert)
//                    
//                    refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
//                 
////                            uploadfileNameLabel.text = "Upload Files"
//                        self.progressShowView.isHidden = true
//                    }))
//                    
//                
//                present(refreshAlert, animated: true, completion: nil)
//                    
//                    
////                        KRProgressHUD.dismiss()
//                }
//            }
//        case .failure(let error):
//            print("Failed to create upload URL: \(error)")
//            KRProgressHUD.dismiss()
//            let refreshAlert = UIAlertController(title: "", message: "Failed to upload video", preferredStyle: UIAlertController.Style.alert)
//            
//            refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
////                    uploadfileNameLabel.text = "Upload Files"
//                self.progressShowView.isHidden = true
//            }))
//            
//        
//        present(refreshAlert, animated: true, completion: nil)
//            
//            
//        }
//    }
//}
//
//
//func uploadVideoToVimeo(uploadLink: String, videoFilePath: URL, authToken: String, chunkSize: Int = 5 * 1024 * 1024, completion: @escaping (UploadResult) -> Void) {
//    guard let fileHandle = try? FileHandle(forReadingFrom: videoFilePath) else {
//        completion(.failure(NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to read video file"])))
//        return
//    }
//    print("fileHandleBefore",fileHandle)
//    var offset: Int = 0
//    let fileSize = fileHandle.seekToEndOfFile()
//    fileHandle.seek(toFileOffset: 0)
//    
//    print("fileHandleBefore",fileHandle)
//    func uploadNextChunk() {
//        let chunkData = fileHandle.readData(ofLength: chunkSize)
//        
//        if chunkData.isEmpty {
//            fileHandle.closeFile()
//            completion(.success(("")))
//            return
//        }
//        
//        var request = URLRequest(url: URL(string: uploadLink)!)
//        request.httpMethod = "PATCH"
//        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/offset+octet-stream", forHTTPHeaderField: "Content-Type")
//        request.setValue("\(offset)", forHTTPHeaderField: "Upload-Offset")
//        request.setValue("1.0.0", forHTTPHeaderField: "Tus-Resumable")
//        request.httpBody = chunkData
//        
//        let uploadTask = URLSession.shared.uploadTask(with: request, from: chunkData) { (data, response, error) in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            if let httpResponse = response as? HTTPURLResponse {
//                if httpResponse.statusCode == 204 {
//                    offset += chunkSize
//                    uploadNextChunk()
//                } else if httpResponse.statusCode == 412 {
//                    // Handle 412 error (precondition failed), retry or get correct offset from server
//                    if let rangeHeader = httpResponse.value(forHTTPHeaderField: "Upload-Offset"), let serverOffset = Int(rangeHeader) {
//                        offset = serverOffset
//                        uploadNextChunk()
//                    } else {
//                        let error = NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload chunk: Precondition Failed"])
//                        completion(.failure(error))
//                    }
//                } else {
//                    let error = NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload chunk, status code: \(httpResponse.statusCode)"])
//                    completion(.failure(error))
//                }
//            }
//        }
//        
//        uploadTask.resume()
//    }
//    
//    uploadNextChunk()
//}
//
//func createVimeoUploadURL(authToken: String, videoFilePath: URL, completion: @escaping (UploadResult) -> Void) {
//    btnStart()
////        KRProgressHUD.show(withMessage: "Uploading Video....")
//    
////        KRProgressHUD.show()
//    guard let fileSize = getFileSize(at: videoFilePath) else {
//        completion(.failure(NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get file size"])))
//        return
//    }
//    
//    let headers: HTTPHeaders = [
//        "Authorization": "Bearer \(authToken)",
//        "Content-Type": "application/json",
//        "Accept": "application/vnd.vimeo.*+json;version=3.4"
//    ]
//    
//    let parameters: [String: Any] = [
//        "upload": [
//            "approach": "tus",
//            "size": "\(fileSize)" // Use the actual video file size
//        ],
//    "name": eventNameTextField.text, // Replace with actual video name
//    "description": eventTitleTextField.text // Replace with actual video description
//    ]
//    
//    AF.request("https://api.vimeo.com/me/videos", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//       .responseJSON { [self] response in
//            switch response.result {
//            case .success(let value):
//                print("Vimeo API Response: \(value)") // Print the full JSON
//                if let json = value as? [String: Any],
//                   let upload = json["upload"] as? [String: Any],
//                   let uploadLink = upload["upload_link"] as? String {
//                    
//                    let embedUrl = json["player_embed_url"] as! String
//                    
//                    let embed = json["embed"]! as AnyObject
////                        IFrameLink = embed["html"]  as! String
//                    getVimeoUploadUrl = embedUrl as! String
//                    print("videe = embedUrl",videe)
////                        print("IFrameLink",IFrameLink)
//                    completion(.success(uploadLink))
//                } else {
//                    completion(.failure(NSError(domain: "com.vimeo", code: -1, userInfo: [NSLocalizedDescriptionKey: "Upload link not found"])))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//}
//func getFileSize(at url: URL) -> UInt64? {
//    do {
//        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
//        if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
//            return fileSize
//        }
//    } catch {
//        print("Error: \(error)")
//    }
//    return nil
//}
//
//
//enum UploadResult {
//    case success(String)
//    case failure(Error)
//}
//
//
//func btnStart() {
//            
//            if(isRunning){
//                progressBarTimer.invalidate()
//            }
//            else{
//            progressView.progress = 0.0
//            self.progressBarTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(EventsWishesAppearedViewController.updateProgressView), userInfo: nil, repeats: true)
//          
//            }
//            isRunning = !isRunning
//        }
//
//    @objc func updateProgressView(){
//           progressView.progress += 0.1
//        progressView.isHidden = false
//      
//        progressShowView.isHidden = false
//
//        progressCountLbl.isHidden = false
//        gifImg.isHidden = false
//        
//        var number = Int(progressView.progress*100)
//        progressCountLbl.text = String(number) + " % "
//        print("pr1234567", progressView.progress*100)
//        if progressView.progress*100 == 100 {
//            progressShowView.isHidden = true
//            
//
//            progressCountLbl.isHidden = true
//            gifImg.isHidden = true
//        }
//        let gifURL = UIImage.gif(name: "video_uploaded")
//                  // Use SDWebImage to load and display the GIF image
//        gifImg.image = gifURL
////            self.gifImg.image = UIImage.gif(name: "video_uploaded")
//
//        print("progressView progressView", progressView.progress)
//           progressView.setProgress(progressView.progress, animated: true)
//           if(progressView.progress == 1.0)
//           {
//               
//               print(" progressView progressView 34444444", progressView.progress)
//               progressBarTimer.invalidate()
//               isRunning = false
//               
////               btn.setTitle("Start", for: .normal)
//           }
//       }
//
//
//
//
