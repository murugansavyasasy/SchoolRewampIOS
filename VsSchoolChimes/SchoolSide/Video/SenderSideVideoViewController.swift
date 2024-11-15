//
//  SenderSideVideoViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/14/24.
//

import UIKit
import Photos
import Alamofire


enum UploadResult {
case success(String)
case failure(Error)
}
class SenderSideVideoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var selectVideoView: RectangularDashedView!
    @IBOutlet weak var secStudBtn: UIButton!
    @IBOutlet weak var stdSecBtn: UIButton!
    @IBOutlet weak var groupBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var uploadVideoTitleLbl: UILabel!
    @IBOutlet weak var changeVideoBtn: UIButton!
    @IBOutlet weak var chooseVdoLbl: UILabel!
    @IBOutlet weak var descTxtFld: UITextField!
    @IBOutlet weak var titleTxtFld: UITextField!
    
    @IBOutlet weak var staffSideOverAllView: UIView!
    var authToken = "8d74d8bf6b5742d39971cc7d3ffbb51a"
    var videoEmbdUrl : String!
    var iframeLink : String!
    var videoSucessId = 0
    var getType = "Principal"

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        stdSecBtn.setTitle("Standard or section".translated(), for: .normal)
        secStudBtn.setTitle("Section or student".translated(), for: .normal)
        groupBtn.setTitle("Groups".translated(), for: .normal)
        
        
        uploadVideoTitleLbl.text = "Upload Video".translated()
        titleTxtFld.text = "Enter Video Title".translated()
        descTxtFld.placeholder = "Enter Video Description".translated()
        
        
        let selectedAlertGesture = UITapGestureRecognizer(target: self, action: #selector(pickVideoFromGallery))
        selectVideoView.addGestureRecognizer(selectedAlertGesture)
        
        
        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backAction))
        backView.addGestureRecognizer(backGesture)
        
        
        
        
       
        staffSideOverAllView.isHidden = true
       
        
        if getType == "Principal" || getType == "Group" {
            sendBtn.isHidden = false
          
            staffSideOverAllView.isHidden = true
          
        }else {
            sendBtn.isHidden = true
           
            staffSideOverAllView.isHidden = false
           
            
        }
        
        
        
    }


    
    
    @IBAction func backAction() {
        dismiss(animated: true)
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
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let videoURL = info[.mediaURL] as? URL {
                print("Selected video URL: \(videoURL)")
                uploadVideo(authToken: authToken, videoFilePath: videoURL)
                
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
        
        //MARK: This method is called when the user cancels the picker
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }

    
   
    
    
    
    
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
        "name": titleTxtFld.text,
        "description": descTxtFld.text
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



}
