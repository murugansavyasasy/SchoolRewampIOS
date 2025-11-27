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
    private init() {}
    
    func uploadFileToAWS(
        file: Any,
        bucketPath: String,
        bucketName: String,
        progressHandler: ((Double) -> Void)? = nil,
        completion: @escaping (String?) -> Void
    ) {
        var fileURL: URL?
        var contentType = ""
        var fileName = ""
        
        switch file {
            
        // ---------------- IMAGE ----------------
        case let image as UIImage:
            contentType = "image/jpeg"
            fileName = UUID().uuidString + ".jpg"
            
            fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            guard let data = image.jpegData(compressionQuality: 0.9) else {
                completion(nil)
                return
            }
            try? data.write(to: fileURL!)
            
        // ---------------- RAW DATA ----------------
        case let data as Data:
            contentType = "application/octet-stream"
            fileName = UUID().uuidString + ".bin"
            
            fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try? data.write(to: fileURL!)
            
        // ---------------- FILE URL ----------------
        case let url as URL:
            guard FileManager.default.fileExists(atPath: url.path) else {
                completion(nil)
                return
            }
            
            // AUDIO → ALWAYS WAV
            if isAudioFile(url: url) {
                let time = Int(Date().timeIntervalSince1970)
                fileName = "audio_\(time).wav"
                contentType = "audio/wav"
                fileURL = url   // Upload original audio file
            }
            else {
                // Non-audio files
                let time = Int(Date().timeIntervalSince1970)
                fileName = "file_\(time).\(url.pathExtension)"
                contentType = getContentType(from: fileName)
                fileURL = url
            }
            
        default:
            completion(nil)
            return
        }
        
        guard let finalURL = fileURL else {
            completion(nil)
            return
        }
        
        // ---------------- FETCH PRESIGNED URL ----------------
        AWSPreSignedURL.shared.fetchPresignedURL(
            bucket: bucketName,
            fileName: fileName,     // MUST send string
            bucketPath: bucketPath,
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
            return "audio/wav"
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
        
        var components = URLComponents(string: "https://api.schoolchimes.com/nodejs/api/MergedApi/get-s3-presigned-url")!
        components.queryItems = [
            URLQueryItem(name: "bucket", value: bucket),
            URLQueryItem(name: "fileName", value: fileBaseName),
            URLQueryItem(name: "bucketPath", value: bucketPath),
            URLQueryItem(name: "fileType", value: fileType)
        ]
        
        guard let url = components.url else {
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
