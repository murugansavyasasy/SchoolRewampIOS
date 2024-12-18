//
//  SenderSideVideoViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 11/14/24.
//

import UIKit
import Photos
import Alamofire
import AVKit
import AVFoundation


enum UploadResult {
    case success(String)
    case failure(Error)
}
class SenderSideVideoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
    @IBOutlet weak var chooseVideoLabel: UILabel!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var HeaderLabel: UILabel!
    
    @IBOutlet weak var BaseView: UIView!
    
    @IBOutlet weak var selectVideoView: RectangularDashedView!
    
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var PlayerHeight: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var uploadVideoTitleLbl: UILabel!
    @IBOutlet weak var changeVideoBtn: UIButton!
    @IBOutlet weak var chooseVideoBtn: UIButton!
    @IBOutlet weak var descTxtView: UITextView!
    @IBOutlet weak var titleTxtFld: UITextField!
    
    @IBOutlet weak var VideoPlayer: UIView!
    
    @IBOutlet weak var ThumnailImage: UIImageView!
    var authToken = "8d74d8bf6b5742d39971cc7d3ffbb51a"
    var videoEmbdUrl : String!
    var iframeLink : String!
    var videoSucessId = 0
    
    
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    var playerurl: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chooseVideoBtn.isHidden = true
        StyleAndTranslater()
        descTxtView.delegate = self
        let PlayGesture = UITapGestureRecognizer(target: self, action: #selector(ChooseVideoBtnAct))
        VideoPlayer.addGestureRecognizer(PlayGesture)
    }
    
    func StyleAndTranslater(){
        
        BaseView.layer.cornerRadius = 10
        VideoPlayer.layer.cornerRadius = 10
        descTxtView.layer.cornerRadius = Colornames.CORadius10
        descTxtView.layer.borderWidth = 0.8
        descTxtView.layer.borderColor = UIColor.black.cgColor
        changeVideoBtn.layer.cornerRadius = Colornames.CORadius10
        sendBtn.layer.cornerRadius = Colornames.CORadius10
        chooseVideoBtn.layer.cornerRadius = Colornames.CORadius10
        
        //MARK: Translate
        HeaderLabel.text = MenuTapbar.Video
        uploadVideoTitleLbl.text = textFieldStringFile.Upload_Video
        chooseVideoLabel.text = textFieldStringFile.Click_To_Choose_video
        titleTxtFld.placeholder = textFieldStringFile.Enter_Video_Title
        descTxtView.text = TexviewStringFile.Enter_video_Description
        descTxtView.textColor = .lightGray
        changeVideoBtn.setTitle("Change Video".translated(), for: .normal)
        chooseVideoBtn.setTitle("Choose Video".translated(), for: .normal)
        sendBtn.setTitle("Send".translated(), for: .normal)
        
        //MARK: Font Style
        
        HeaderLabel.setFont(style: .header, size: FontSize.HeaderSize)
        chooseVideoLabel.setFont(style: .title, size: FontSize.TitleSize)
        uploadVideoTitleLbl.setFont(style: .header, size: 17)
        changeVideoBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        chooseVideoBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        sendBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
    }
    
    //MARK: function to play video
    @objc func playVideo() {
        playBtn.isHidden = true
        ThumnailImage.isHidden = true
        
        if let playerurl = playerurl {
            player = AVPlayer(url: playerurl)
            print("playerurl: \(playerurl)")
            
            playerViewController = AVPlayerViewController()
            playerViewController?.player = player
            playerViewController?.showsPlaybackControls = true
            
            self.addChild(playerViewController!)
            playerViewController?.view.frame = VideoPlayer.bounds
            self.VideoPlayer.addSubview(playerViewController!.view)
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
            
            ThumnailImage.isHidden = false
            ThumnailImage.layer.cornerRadius = 10
            ThumnailImage.image = UIImage(cgImage: cgImage)
            chooseVideoLabel.isHidden = true
            playBtn.isHidden = false
            playBtn.setImage(UIImage(named: "play-button"), for: .normal)
            
        } catch {
            print("Error generating thumbnail: \(error)")
            
        }
    }
    
    
    @IBAction func ChooseVideoBtnAct(_ sender: Any) {
        if playerurl == nil{
            pickVideoFromGallery()
        }
    }
    
    @IBAction func backAction() {
        dismiss(animated: true)
    }
    
    
    @IBAction func PlayBtnAct(_ sender: Any) {
        if playBtn.currentImage == ImageName.playbutton{
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
        
        let vc = SelectRecipientVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
            if playerurl != nil{
                stopCurrentVideo()
                playerurl = nil
            }
            playerurl = videoURL
            print("Selected video URL: \(videoURL)")
            generateThumbnail(from: playerurl!)
            
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
            "description": descTxtView.text
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

extension SenderSideVideoViewController : UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if descTxtView.text == TexviewStringFile.Enter_video_Description{
            descTxtView.text = ""
            descTxtView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descTxtView.text.isEmpty{
            descTxtView.text = TexviewStringFile.Enter_video_Description
            descTxtView.textColor = .lightGray
        }
    }
}
