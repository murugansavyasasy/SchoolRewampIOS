//
//  shareAndDownloadVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 26/06/25.
//

import UIKit


class shareAndDownloadVc: UIViewController {
    
  
    var dowloadUrl:String?
    var typeVideo = false
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func downloadBtnAction(_ sender: UIButton) {
        
        if typeVideo{
            
        }else{
            guard let fileURL = dowloadUrl, let filename = getFileName(from: fileURL) else {
                print("❌ Invalid file URL or file name")
                sender.isEnabled = true
                return
            }
            
            let downloader = FileDownloader()
            downloader.downloadFile(
                from: fileURL,
                folderName: "SchoolChimesDownloads",
                fileName: filename
            ) { result in
                DispatchQueue.main.async { [self] in
                    sender.isEnabled = true
                    switch result {
                    case .success(let filePath):
                        CustomAlert.showAlertWithOkAction(
                            title:"",
                            message: "\(filename) Downloaded successfully ✅",
                            on: self)
                        
                        //                    let awsImageUrl = dowloadUrl
                        //                    CustomAlert
                        //                        .showImageAlert(
                        //                            from: awsImageUrl ?? "",
                        //                            message: "\(filename) Downloaded successfully ✅",
                        //                            in: self
                        //                        )
                        
                    case .failure(let error):
                        CustomAlert.showAlertWithOkAction(
                            title:"",
                            message: "\(filename) Download Failed ❌",
                            on: self)
                    }
                }
            }
        }
    }
    func getFileName(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        return url.lastPathComponent
    }
    
    
    @IBAction func shareBtnAction(_ sender: UIButton) {
     
        if typeVideo{
            
            let embedURL = dowloadUrl ?? ""
            if let videoID = extractVimeoVideoID(from: embedURL) {
                print("🎯 Video ID = \(videoID)")
                
                getVideoDetailsFromID(videoID:videoID , accessToken: "8d74d8bf6b5742d39971cc7d3ffbb51a")
            }
            
        }else{
           
            let fileUrl = dowloadUrl
            downloadShareAndDeleteFile(
                from: fileUrl ?? "",
                viewController: self
            )
            
        }
        
    
    }
    
    func extractVimeoVideoID(from embedURL: String) -> String? {
        // Example: https://player.vimeo.com/video/1096892846?h=abc123
        if let url = URL(string: embedURL),
           let id = url.pathComponents.first(where: { $0.allSatisfy({ $0.isNumber }) }) {
            return id
        }
        return nil
    }

    
    func getVideoDetailsFromID(videoID: String, accessToken: String) {
        let url = URL(string: "https://api.vimeo.com/videos/\(videoID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) {
            data,
            _,
            error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("❌ Failed to parse response")
                return
            }
            
            print("✅ Video Details: \(json)")
            
            if let files = json["download"] as? [[String: Any]] {
                for file in files {
                    if let link = file["link"] as? String {
                        print("🎥 Download link: \(link)")
                        // You can use this URL to download or share
                        self.downloadAndShareVideo(
                            from: link,
                            viewController: self
                        )
                    }
                }
            }
        }.resume()
    }

    
    func downloadAndShareVideo(from urlString: String, viewController: UIViewController) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.downloadTask(with: url) { tempURL, _, error in
            guard let tempURL = tempURL else {
                print("❌ Download failed:", error?.localizedDescription ?? "Unknown")
                return
            }

            let fileName = url.lastPathComponent
            let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let finalURL = documentsDir.appendingPathComponent(fileName)

            do {
                if FileManager.default.fileExists(atPath: finalURL.path) {
                    try FileManager.default.removeItem(at: finalURL)
                }
                try FileManager.default.moveItem(at: tempURL, to: finalURL)

                DispatchQueue.main.async {
                    let activityVC = UIActivityViewController(activityItems: [finalURL], applicationActivities: nil)
                    viewController.present(activityVC, animated: true)
                }

            } catch {
                print("❌ File error:", error.localizedDescription)
            }

        }.resume()
    }

    func downloadShareAndDeleteFile(from urlString: String, viewController: UIViewController) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL, error == nil else {
                print("❌ Download failed:", error?.localizedDescription ?? "Unknown error")
                return
            }

            // Get file name from response or fallback to lastPathComponent
            let fileName = response?.suggestedFilename ?? url.lastPathComponent
            let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let finalURL = documentsDir.appendingPathComponent(fileName)

            do {
                if FileManager.default.fileExists(atPath: finalURL.path) {
                    try FileManager.default.removeItem(at: finalURL)
                }
                try FileManager.default.moveItem(at: tempURL, to: finalURL)

                DispatchQueue.main.async {
                    let activityVC = UIActivityViewController(activityItems: [finalURL], applicationActivities: nil)

                    activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
                        do {
                            if FileManager.default.fileExists(atPath: finalURL.path) {
                                try FileManager.default.removeItem(at: finalURL)
                                print("🧹 File deleted after sharing.")
                            }
                        } catch {
                            print("⚠️ Could not delete file: \(error.localizedDescription)")
                        }
                    }

                    // iPad support
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = viewController.view
                        popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                                    y: viewController.view.bounds.midY,
                                                    width: 0, height: 0)
                    }

                    viewController.present(activityVC, animated: true)
                }

            } catch {
                print("❌ File move error:", error.localizedDescription)
            }

        }.resume()
    }


    

    }
   

   

