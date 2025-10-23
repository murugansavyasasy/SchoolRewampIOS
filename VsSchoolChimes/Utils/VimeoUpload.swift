////
////  VimeoUpload.swift
////  School Chimes
////
////  Created by Lakshmanan on 02/05/25.
////
//
import Foundation
import UIKit

class VimeoUploader: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    private let accessToken: String
    private weak var presentingViewController: UIViewController?
    
    private var progressHandler: ((_ progress: Double) -> Void)?
    private var completionHandler: ((_ videoURL: String?, _ iframeHTML: String?, _ fileSize: Int?, _ finalEmbedUrl: String?) -> Void)?
    private var uploadTask: URLSessionUploadTask?
    private var uploadURL: URL?
    private var offset: Int = 0
    private var videoFileData: Data?
    private var videoURI: String?
    private var embedHTML: String?
    private var currentFileSize: Int?
    private var finalEmbedUrl: String?
    var thumbnailURL: String?
    init(accessToken: String, presentingViewController: UIViewController? = nil) {
        self.accessToken = accessToken
        self.presentingViewController = presentingViewController
    }
    
    func upload(videoFileURL: URL, title: String, description: String, progress: @escaping (_ progress: Double) -> Void, completion: @escaping (_ videoURL: String?, _ iframeHTML: String?, _ fileSize: Int?, _ finalEmbedUrl: String?) -> Void) {
        self.progressHandler = progress
        self.completionHandler = completion
        
        getVimeoUploadLink(
            videoFileURL: videoFileURL,
            videoTitle: title,
            videoDescription: description
        ) {
            [weak self] uploadURL,
            videoURI,
            iframeHTML,
            finalEmbedUrl  in
            guard let self = self,
                  let uploadURL = uploadURL,
                  let videoURI = videoURI else {
                print("❌ Could not get upload link or video URI")
                DispatchQueue.main.async {
                    completion(nil, nil, nil,nil)
                }
                return
            }
            
            self.finalEmbedUrl = finalEmbedUrl
            self.uploadURL = uploadURL
            self.videoURI = videoURI
            self.embedHTML = iframeHTML
            
            self.getUploadOffset(for: uploadURL) { offset in
                guard let offset = offset else {
                    print("❌ Upload server not ready")
                    DispatchQueue.main.async {
                        completion(nil, nil, nil,nil)
                    }
                    return
                }
                
                self.offset = offset
                self.performUpload(videoFileURL: videoFileURL)
            }
        }
    }
    
    private func performUpload(videoFileURL: URL) {
        guard let uploadURL = uploadURL else { return }
        guard let fileData = try? Data(contentsOf: videoFileURL) else {
            print("❌ Could not read video data")
            completionHandler?(nil, nil, nil,nil)
            return
        }
        
        self.videoFileData = fileData
        let fileSize = fileData.count
        self.currentFileSize = fileSize
        
        let uploadData = fileData.subdata(in: offset..<fileSize)
        
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "PATCH"
        request.setValue("application/offset+octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("\(offset)", forHTTPHeaderField: "Upload-Offset")
        request.setValue("1.0.0", forHTTPHeaderField: "Tus-Resumable")
        request.setValue("\(uploadData.count)", forHTTPHeaderField: "Content-Length")
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        print("🚀 Uploading from offset \(offset)... \(uploadData.count) bytes of \(fileSize)")
        uploadTask = session.uploadTask(with: request, from: uploadData)
        uploadTask?.resume()
    }
    
    // MARK: - URLSession Delegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        DispatchQueue.main.async {
            self.progressHandler?(progress)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("❌ Upload error: \(error.localizedDescription)")
            completionHandler?(nil, nil, currentFileSize,nil)
            return
        }
        
        guard let response = task.response as? HTTPURLResponse else {
            print("❌ No HTTP response")
            completionHandler?(nil, nil, currentFileSize,nil)
            return
        }
        
        print("📦 Response code: \(response.statusCode)")
        
        if response.statusCode == 204, let videoURI = self.videoURI {
            let videoID = videoURI.components(separatedBy: "/").last ?? ""
            let videoURL = "https://vimeo.com/\(videoID)"
            self.completionHandler?(
                videoURL,
                embedHTML,
                currentFileSize,
                finalEmbedUrl
            )
            print("✅ Upload complete: \(videoURL)")
            // self.showSuccessAlert(videoURL: videoURL)
        } else {
            print("❌ Unexpected response code: \(response.statusCode)")
            completionHandler?(nil, nil, currentFileSize,nil)
        }
    }
    
    // MARK: - Vimeo API Helpers
    
    private func getVimeoUploadLink(
        videoFileURL: URL,
        videoTitle: String,
        videoDescription: String,
        completion: @escaping (URL?, String?, String?,String?) -> Void
    ) {
        guard let fileSize = try? FileManager.default.attributesOfItem(atPath: videoFileURL.path)[.size] as? Int else {
            print("❌ Could not get file size")
            completion(nil, nil, nil,nil)
            return
        }
        
        var request = URLRequest(url: URL(string: "https://api.vimeo.com/me/videos")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.vimeo.*+json;version=3.4", forHTTPHeaderField: "Accept")
        
        let body: [String: Any] = [
            "upload": [
                "approach": "tus",
                "size": fileSize
            ],
            "name": videoTitle,
            "description": videoDescription
            
        ]
        
        print("video body " , body)
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("videooo upload",request)
        URLSession.shared.dataTask(with: request) {
            data,
            response,
            error in
            guard let data = data else {
                print("❌ Upload link request error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil, nil, nil,nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let upload = json["upload"] as? [String: Any],
               let uploadLink = upload["upload_link"] as? String,
               let uri = json["uri"] as? String,
               let url = URL(string: uploadLink){
                
                let embedHTML = (json["embed"] as? [String: Any])?["html"] as? String
                
                let finalUrl = json["player_embed_url"] as? String
                print("✅ Got upload URL: \(uploadLink)")
                print("✅ Got embed HTML: \(embedHTML ?? "N/A")")
                print("✅ Got video URI: \(uri)")
                print("✅ embeddddddddembeddddddddembedddddddd \(finalUrl)")
                
                
                completion(url, uri, embedHTML,finalUrl)
                
                //                if let imageData =  user_inputs.thumbNail?.jpegData(
                //                    compressionQuality: 0.8
                //                ) {
                //                    self.uploadThumbnailToVimeo(videoUri: "1097481073", imageData: imageData, accessToken: self.accessToken)
                //
                //                }
                print("videoUpload json: \(json)")
            } else {
                print("❌ Failed to parse upload link: \(String(data: data, encoding: .utf8) ?? "No data")")
                completion(nil, nil, nil,nil)
            }
        }.resume()
    }
    
    
    //    func uploadThumbnailToVimeo(videoUri: String, imageData: Data, accessToken: String) {
    //           let thumbURL = URL(string: "https://api.vimeo.com\(videoUri)/pictures")!
    //           var request = URLRequest(url: thumbURL)
    //           request.httpMethod = "POST"
    //           request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    //           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //           request.httpBody = try? JSONSerialization.data(withJSONObject: ["active": true])
    //
    //           URLSession.shared.dataTask(with: request) { data, _, error in
    //               if let error = error {
    //                   print("Error creating thumbnail: \(error)")
    //                   return
    //               }
    //               guard let data = data,
    //                     let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
    //                     let link = json["link"] as? String else {
    //                   print("❌ Failed to parse thumbnail upload link")
    //                   return
    //               }
    //
    //               print("🖼 Thumbnail upload URL: \(link)")
    //
    //               var uploadRequest = URLRequest(url: URL(string: link)!)
    //               uploadRequest.httpMethod = "PUT"
    //               uploadRequest.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
    //               uploadRequest.httpBody = imageData
    //
    //               URLSession.shared.dataTask(with: uploadRequest) { _, _, error in
    //                   if let error = error {
    //                       print("Error uploading thumbnail image: \(error)")
    //                       return
    //                   }
    //                   print("✅ Thumbnail uploaded")
    //                   self.fetchVimeoVideoDetails(videoUri: videoUri, accessToken: accessToken)
    //               }.resume()
    //           }.resume()
    //       }
    //
    //       func fetchVimeoVideoDetails(videoUri: String, accessToken: String) {
    //           let url = URL(string: "https://api.vimeo.com\(videoUri)?fields=pictures.sizes.link")!
    //           var request = URLRequest(url: url)
    //           request.httpMethod = "GET"
    //           request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    //
    //           URLSession.shared.dataTask(with: request) { data, _, error in
    //               if let error = error {
    //                   print("Error fetching video details: \(error)")
    //                   return
    //               }
    //               guard let data = data,
    //                     let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
    //                     let pictures = json["pictures"] as? [String: Any],
    //                     let sizes = pictures["sizes"] as? [[String: Any]],
    //                     let last = sizes.last,
    //                     let publicThumb = last["link"] as? String else {
    //                   print("❌ Failed to fetch public thumbnail")
    //                   return
    //               }
    //
    //               self.thumbnailURL = publicThumb
    //               print("🌍 Public Thumbnail URL: \(publicThumb)")
    //
    //               DispatchQueue.main.async {
    ////                   self.thumbnailLabel.text = "Thumbnail URL:\n\(publicThumb)"
    //               }
    //           }.resume()
    //       }
    
    private func getUploadOffset(for uploadURL: URL, completion: @escaping (Int?) -> Void) {
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "HEAD"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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
    
}


