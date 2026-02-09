////
////  AWSS3Manager.swift
////  VsSchoolChimes
////  Created by chandhru on 12/04/24.
//

import UIKit
import AWSS3
import AWSCore

// MARK: - Upload Task Delegate
class UploadTaskDelegate: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    var progressHandler: ((Double) -> Void)?

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        DispatchQueue.main.async {
            self.progressHandler?(progress * 100)
        }
    }
}

// MARK: - AWS Upload Manager
class AWSUploadManager {
    
    static let shared = AWSUploadManager()
    
    static var iSprofile = false
    
    private init() {}
    
    func uploadFileToAWS(
        file: Any,
        progressHandler: ((Double) -> Void)? = nil,
        completion: @escaping (String?) -> Void
    ) {
        var fileURL: URL?
        var contentType = ""
        var fileName = ""
        
        switch file {
        case let image as UIImage:
            contentType = "image/jpeg"
            fileName = UUID().uuidString + ".jpg"
            
            fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            guard let data = image.jpegData(compressionQuality: 0.9) else {
                completion(nil)
                return
            }
            try? data.write(to: fileURL!)
        case let data as Data:
            contentType = "application/octet-stream"
            fileName = UUID().uuidString + ".bin"
            
            fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try? data.write(to: fileURL!)
        case let url as URL:
            guard FileManager.default.fileExists(atPath: url.path) else {
                completion(nil)
                return
            }
            if   Menu_id.staffSelectedMenuId == Menu_id.lsrw{
                if isAudioFile(url: url) {
                    let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                    fileName = "\(timestamp).wav"
                    contentType = "audio/wav"
                    fileURL = url
                }else {
                    let time = Int(Date().timeIntervalSince1970)
                    fileName = "file_\(time).\(url.pathExtension)"
                    contentType = getContentType(from: fileName)
                    fileURL = url
                }
            }else{
                if isAudioFile(url: url) {
                    let timestamp = Int(Date().timeIntervalSince1970)
                    fileName = "original_\(timestamp).\(url.pathExtension)"
                    contentType = "audio/\(url.pathExtension)"
                    fileURL = url
                }else {
                    let time = Int(Date().timeIntervalSince1970)
                    fileName = "file_\(time).\(url.pathExtension)"
                    contentType = getContentType(from: fileName)
                    fileURL = url
                }
            }
            
        default:
            completion(nil)
            return
        }
        
        guard let finalURL = fileURL else {
            completion(nil)
            return
        }
        
        let BucketDetails = getBucketDetails()
        
        AWSPreSignedURL.shared.fetchPresignedURL(
            bucket: BucketDetails.BucketName,
            fileName: fileName,     // MUST send string
            bucketPath: BucketDetails.Path,
            fileType: contentType
        ) { result in
            switch result {
            case .success(let respons):
                guard let presignedURL = respons.data?.presignedUrl,
                      let uploadURL = URL(string: presignedURL) else {
                    completion(nil)
                    return
                }
                
                guard let fileData = try? Data(contentsOf: finalURL) else {
                    completion(nil)
                    return
                }
                
                var request = URLRequest(url: uploadURL)
                request.httpMethod = "PUT"
                request.setValue(contentType, forHTTPHeaderField: "Content-Type")
                
                let delegate = UploadTaskDelegate()
                delegate.progressHandler = progressHandler
                
                let session = URLSession(
                    configuration: .default,
                    delegate: delegate,
                    delegateQueue: nil
                )
                
                let uploadTask = session.uploadTask(with: request, from: fileData) { _, response, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Upload error: \(error.localizedDescription)")
                            completion(nil)
                            return
                        }
                        
                        if let httpResponse = response as? HTTPURLResponse,
                           httpResponse.statusCode == 200 {
                            
                            self.deleteIfRecordedAudioFile(at: finalURL)
                            completion(respons.data?.fileUrl ?? presignedURL)
                        } else {
                            print("Upload failed with status → \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                            completion(nil)
                        }
                    }
                }
                
                uploadTask.resume()
                
            case .failure(let error):
                print("Failed presigned URL: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    func isAudioFile(url: URL) -> Bool {
        let audioExtensions = ["m4a", "mp3", "wav", "aac", "flac", "amr", "ogg"]
        return audioExtensions.contains(url.pathExtension.lowercased())
    }
    private func getContentType(from filename: String) -> String {
        let ext = (filename as NSString).pathExtension.lowercased()
        
        switch ext {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "pdf": return "application/pdf"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "txt": return "text/plain"
        case "ppt": return "application/vnd.ms-powerpoint"
        case "pptx": return "application/vnd.openxmlformats-officedocument.presentationml.presentation"
        case "xls": return "application/vnd.ms-excel"
        case "xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "mp3", "m4a", "wav":
            return "audio/mp4"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        default: return "application/octet-stream"
        }
    }

    func deleteIfRecordedAudioFile(at url: URL) {
        let fileName = url.lastPathComponent
        let isRecordedFile =
            fileName == "RecordedAudio.m4a" ||
            fileName.hasPrefix("RecordedAudio_") && fileName.hasSuffix(".m4a")
        
        guard isRecordedFile else {
            return
        }
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
                print("✅ Deleted -> \(fileName)")
            } catch {
                print("❌ Failed to delete -> \(error.localizedDescription)")
            }
        } else {
            print("⚠️ File does not exist -> \(url.path)")
        }
    }
    
    func getBucketDetails() -> (BucketName: String, Path: String) {
        
        let today_date = AwsCurrentDateString()
        let school_id = UserDefaultFileManager.get_staff_Details()?.school_id ?? ""
        
        var Bucket = ""
        var Path = ""
      
        switch Menu_id.staffSelectedMenuId {
            
        case Menu_id.communicationMenuId:
            Bucket = BucketName.schoolchimes_communication
            Path = "\(Awsmenu.voice)/\("original")/\(today_date)"
        case Menu_id.quiz:
            Bucket = BucketName.schoolchimes_activities
            Path = "\(Awsmenu.marksheets)/\(school_id)/\(today_date)"
        case Menu_id.AttachmentMenuId:
            Bucket = BucketName.schoolchimes_communication
            Path = "\(Awsmenu.files)/\(school_id)/\(today_date)"
            
        case Menu_id.noticeboardMenuId:
            Bucket = BucketName.schoolchimes_activities
            Path = "\(Awsmenu.noticeboard)/\(school_id)/\(today_date)"
            
        case Menu_id.homeWorkMenuId:
            Bucket = BucketName.schoolchimes_activities
            Path = "\(Awsmenu.homework)/\(school_id)/\(today_date)"
            
        case Menu_id.isAssaignment:
            Bucket = BucketName.schoolchimes_activities
            Path = "\(Awsmenu.assignment)/\(school_id)/\(today_date)"
            
        case Menu_id.lsrw:
            Bucket = BucketName.schoolchimes_activities
            Path = "\(Awsmenu.skills)/\(school_id)/\(today_date)"
            
        case Menu_id.event:
            Bucket = BucketName.schoolchimes_activities
            Path = "\(Awsmenu.events)/\(school_id)/\(today_date)"
            
        case Menu_id.Upload_Marks:
            Bucket = BucketName.schoolchimes_activities
            Path = "\(Awsmenu.marksheets)/\(school_id)/\(today_date)"
        case -1:
            if AWSUploadManager.iSprofile{
                Bucket = BucketName.schoolchimes_studentphotos
            }else{
                Bucket = BucketName.schoolchimes_schooldocs
            }
            
            Path = "\(school_id)/\(today_date)"
            
        default:
            break
        }
        
        return (Bucket, Path)
    }


}

// MARK: - AWS Presigned URL Fetcher
class AWSPreSignedURL {
    static let shared = AWSPreSignedURL()
    private init() {}
    
    func fetchPresignedURL(
        bucket: String,
        fileName: String,
        bucketPath: String,
        fileType: String,
        completion: @escaping (Result<AwsResps, Error>) -> Void
    ) {
        let fileBaseName = (fileName as NSString).lastPathComponent
        print("fname \(fileBaseName)")
      
        let baseURL = UserDefaultFileManager.get_globalSelection()?.presigned_cred_base_url ?? ""
        let fullURL = baseURL + "get-s3-presigned-url"
        var components = URLComponents(string: fullURL)
        components?.queryItems = [
            URLQueryItem(name: "bucket", value: bucket),
            URLQueryItem(name: "fileName", value: fileBaseName),
            URLQueryItem(name: "bucketPath", value: bucketPath),
            URLQueryItem(name: "fileType", value: fileType)
        ]
        
        guard let url = components?.url else {
            completion(.failure(NSError(domain: "", code: 400,
                                        userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "Empty response"])))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(AwsResps.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    
    func deleteFileFromS3(withURL urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }
        guard let key = url.pathComponents.dropFirst().joined(separator: "/").removingPercentEncoding else {
            print("❌ Could not extract key from URL")
            return
        }
        
        let s3 = AWSS3.default()
        let deleteObjectRequest = AWSS3DeleteObjectRequest()!
        deleteObjectRequest.bucket = "schoolchimes-communication"
        deleteObjectRequest.key = key
        
        s3.deleteObject(deleteObjectRequest).continueWith { (task) -> Any? in
            if let error = task.error {
                print("❌ Failed to delete: \(error.localizedDescription)")
            } else {
                print("🗑️ File deleted successfully from S3: \(key)")
            }
            return nil
        }
    }
    
}


//MARK: Sample Aws Url Links

/*
 https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/voice/7044/01-12-2025/audio_1764565674.wav

 https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/files/7044/01-12-2025/D9A58808-726D-4C62-9915-374310C81170.jpj  https://schoolchimes-activities.s3.ap-south-1.amazonaws.com/homework/7044/01-12-2025/8D059096-2149-44B8-9E25-03342241A568.jpg  https://schoolchimes-activities.s3.ap-south-1.amazonaws.com/noticeboard/7044/01-12-2025/BCCF9B7C-34CD-4947-9D99-061606B7B703.jpg  https://schoolchimes-activities.s3.ap-south-1.amazonaws.com/assignment/7044/01-12-2025/8199229E-D095-4501-9076-9400EC2A903A.jpg  https://schoolchimes-activities.s3.ap-south-1.amazonaws.com/skills/7044/01-12-2025/audio_1764566311.wav  https://schoolchimes-activities.s3.ap-south-1.amazonaws.com/events/7044/01-12-2025/1B8E8F7B-A566-4DF6-9DB4-C71F725F58CE.jpg
  https://schoolchimes-activities.s3.ap-south-1.amazonaws.com/events/7044/01-12-2025/C88E8321-FECD-46C0-B7A7-146A2AF5A0ED.jpg
 */
