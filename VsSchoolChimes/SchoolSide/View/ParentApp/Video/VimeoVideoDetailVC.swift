//
//  VimeoVideoDetailVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 27/05/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import PlayerKit
import WebKit

class VimeoVideoDetailVC: UIViewController,UIWebViewDelegate {
   
    
    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var downloadLbl: UILabel!
    @IBOutlet weak var gifImg: UIImageView!
    @IBOutlet weak var progressCountLbl: UILabel!
    
    @IBOutlet weak var progressShowView: UIView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var videoDownloadView: UIView!
    @IBOutlet weak var webKitView: WKWebView!
    var strVideoUrl = String()
    var videoId = String()
    let player = RegularPlayer()
    var hud : MBProgressHUD = MBProgressHUD()
    var bsaeUrl = "https://api.vimeo.com/videos/"
    var progressBarTimer: Timer!
    var isRunning = false
    
    var vimeoToken = "Bearer 8d74d8bf6b5742d39971cc7d3ffbb51a"
    var getVideoPath : String!
    var downloadVideoID : String!
    var getDownloadShowID : Int!
    override func viewDidLoad(){
        
        super.viewDidLoad()
        //
        
        
        
        progressView.isHidden = true
      
        progressShowView.isHidden = true

        progressCountLbl.isHidden = true
        
        gifImg.isHidden = true
        
        print("ManageVideo")
        print("Video4",downloadVideoID)
        print("getDownloadShowID",getDownloadShowID)
        
        videoPlayer()
        videoDownloadView.isHidden = true
        downloadLbl.isHidden = true
        
        if getDownloadShowID == 1 {
            videoDownloadView.isHidden = false
            downloadLbl.isHidden = false
            fullView.isHidden = true
        }else{
            videoDownloadView.isHidden = true
            downloadLbl.isHidden = true
            fullView.isHidden = true
        }
        let downloadGesture = UITapGestureRecognizer(target: self, action: #selector(getVideoDownload))
        videoDownloadView.addGestureRecognizer(downloadGesture)
                    
      
      
      
        
        
    }
    
    func videoPlayer(){
        let videoid = videoId.components(separatedBy:"/")
        print("videoid",videoid)
        if let yourVimeoLink = URL(string: "https://player.vimeo.com/video/\(videoid[0])")  {
            print("yourVimeoLink",yourVimeoLink)
            self.showLoading()
            self.webKitView.backgroundColor = UIColor.black
            self.webKitView.isOpaque = false
            webKitView.contentMode = UIView.ContentMode.scaleToFill
            webKitView.load(URLRequest(url:yourVimeoLink))
            webKitView.contentMode = UIView.ContentMode.scaleToFill
            
//
            
           
        }
    }
    
    
    func videoPlayer2(){
        let player = RegularPlayer()
        
        view.addSubview(player.view) // RegularPlayer conforms to `ProvidesView`, so we can add its view
        if let yourVimeoLink = URL(string: "https://player.vimeo.com/video/423522889")  {
            player.set(AVURLAsset(url: yourVimeoLink))
            player.volume = 1
            player.play()
        }
    }
    
    func videoPlayer1(){
        
        if let yourVimeoLink = URL(string: strVideoUrl)  {
            self.showLoading()
            let videoid = videoId.components(separatedBy:"/")
            let width = String(describing: self.webKitView.frame.size.width)
            let height = String(describing: self.webKitView.frame.size.height)
            print(height)
            webKitView.backgroundColor = UIColor.clear
            let embedHTML = "<iframe src=\"https://player.vimeo.com/video/\(videoid[0])?title=0&amp;byline=1&amp;playsinline=1&amp;portrait=1&amp;badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=177030\" frameborder=\"0\" width=\"350\" height=\"600\" allow=\"autoplay; fullscreen\" allowfullscreen></iframe>"
            webKitView.loadHTMLString(embedHTML as String, baseURL:yourVimeoLink )
            webKitView.contentMode = UIView.ContentMode.scaleToFill
            
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.hideLoading()
    }
    
    func showLoading() -> Void {
        //  self.view.window?.userInteractionEnabled = false
        hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.animationType = MBProgressHUDAnimationFade
        hud.labelText = "Loading"
        
    }
    
    func hideLoading() -> Void{
        
        hud.hide(true)
    }
    
    @IBAction func actionBack(_ sender: UIButton){
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBackVimeoVideo"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
//
    
    @objc func getVideoDownload () {
       
        btnStart()
           
        let urlString = bsaeUrl +  downloadVideoID
        

        print("Download\(urlString)")
           guard let url = URL(string: urlString) else {
               print("Invalid URL")
               return
           }

           // Set up the URL request
           var request = URLRequest(url: url)
           request.httpMethod = "GET"

          
        request.setValue(vimeoToken, forHTTPHeaderField: "Authorization")

           // Initialize a URLSession
           let session = URLSession.shared

           // Start the data task
        let task = session.dataTask(with: request) { [self] data, response, error in
               // Handle the response
               if let error = error {
                   print("Error:", error.localizedDescription)
                   return
               }

               guard let httpResponse = response as? HTTPURLResponse,
                     (200...299).contains(httpResponse.statusCode) else {
                   print("Server error")
                   return
               }

               if let data = data {
                   print("GetDAATa",data)
                   do {
                       // Parse the JSON data
                       let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                       print("jsonObject",jsonObject)
//                       jsonData = jsonObject
                       // Access the "download" node
                       if let downloadArray = jsonObject?["download"] as? [[String: Any]], let firstDownload = downloadArray.first {
                           print("Download node: \(firstDownload)")
                           
                           // Access individual values in the download node
                           if let link = firstDownload["link"] as? String {
                               print("Download link: \(link)")
                               
                               if let url = URL(string: link) {
                                   downloadVideo(from: url) { savedURL in
                                       if let savedURL = savedURL {
                                           
                                           
                                         
                                           
                                           
                                           
                                           
                                           
                                           print("Downloaded video saved at: \(savedURL)")
                                           getVideoPath = savedURL.absoluteString
                                           
                                           
                                           // Use the saved URL as needed
                                       } else {
                                           print("Failed to download video.")
                                       }
                                   }
                               }
                               
                               
                           }
                           
                           if let size = firstDownload["size"] as? Int {
                               print("Size: \(size) bytes")
                           }
                       }
                   } catch {
                       print("Error parsing JSON: \(error)")
                   }
               }
           }

           // Start the request
           task.resume()
   }
   
    
    
    
    
    func btnStart() {
                
                if(isRunning){
                    progressBarTimer.invalidate()
                }
                else{
                progressView.progress = 0.0
                self.progressBarTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
              
                }
                isRunning = !isRunning
            }

        @objc func updateProgressView(){
               progressView.progress += 0.1
            progressView.isHidden = false
          
            progressShowView.isHidden = false
            fullView.isHidden = false
            progressCountLbl.isHidden = false
            gifImg.isHidden = false
            
            var number = Int(progressView.progress*100)
            progressCountLbl.text = "Downloading" + " " + String(number) + " % "
            print("pr1234567", progressView.progress*100)
            print("getVideoPath", getVideoPath)
            if progressView.progress*100 == 100 {
                progressShowView.isHidden = true
                
                
                progressCountLbl.isHidden = true
                gifImg.isHidden = true
                
                
                _ = SweetAlert().showAlert("", subTitle: getVideoPath, style: .none, buttonTitle: "Ok", buttonColor: .black){
                    (okClick) in
                    if okClick{
                        self.dismiss(animated: true)
                    }else{
                        
                    }
                }
            }


            print("progressView progressView", progressView.progress)
               progressView.setProgress(progressView.progress, animated: true)
               if(progressView.progress == 1.0)
               {
                   
                   print(" progressView progressView 34444444", progressView.progress)
                   progressBarTimer.invalidate()
                   isRunning = false
                   
    
               }
           }
    
    
    
    
    func downloadVideo(from url: URL, completion: @escaping (URL?) -> Void) {
        let session = URLSession(configuration: .default)
        let downloadTask = session.downloadTask(with: url) { (tempLocalUrl, response, error) in
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let tempLocalUrl = tempLocalUrl else {
                print("Temporary file URL is nil.")
                completion(nil)
                return
            }
            
            do {
                // Get the destination path
                let fileManager = FileManager.default
                let documentsDirectory = try fileManager.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
                )
                let savedURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
                
                // Move downloaded file to the destination path
                if fileManager.fileExists(atPath: savedURL.path) {
                    try fileManager.removeItem(at: savedURL)
                }
                try fileManager.moveItem(at: tempLocalUrl, to: savedURL)
                
                print("File saved to: \(savedURL)")
                
                // Open the saved file in Safari
                DispatchQueue.main.async {
                    completion(savedURL)
                    if UIApplication.shared.canOpenURL(savedURL) {
                        UIApplication.shared.open(savedURL, options: [:], completionHandler: nil)
                    } else {
                        print("Unable to open the file in Safari.")
                    }
                }
                
                
                var urlConvert = savedURL.absoluteString
                let refreshAlert = UIAlertController(title: "Alert Title", message: urlConvert, preferredStyle: .alert)

                   // Add the "Ok" action
                   refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                       // Perform any action you need here
                       print("Ok button tapped")
                   }))

                   // Present the alert
                   if let topController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                       topController.present(refreshAlert, animated: true, completion: nil)
                   }
                
                
               
            
                
                
                completion(savedURL)
            } catch {
                print("File error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        
        downloadTask.resume()
    }
    
    @IBAction func downloadAction(_ sender: UIButton) {
       
    }
    
}
