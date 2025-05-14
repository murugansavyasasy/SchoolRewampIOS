//
//  AttachmentVCViewController.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 05/05/25.
//

import UIKit

class AttachmentVCViewController: UIViewController {

    private enum Constants {
        static let imageCellID = "AttachmentCvCollectionViewCell"
        static let bannerID = "BannerView"
        static let mockLabels = [
            "This is a nice house, but it must be expensive",
            "Wow, very nice design. It must have been hard to build this.dhgfgawifgiuawgifgauwgfuguygugiugwrfgisagfiugaisugfiugiugugiugiufgiagiffgaiugfgafgagsfgyuagygyugugauguagfuasuguaufauug vekjbvjefbvjhsbjghjesfbvjjv hjjhvhjvdjvjsjhvhjahjejvbajvhjbvdhjbvjbbjscbj wjbvjfjvjfvjbjabjbaebvjhhvjvbjhvbjbv jebejb jebjvbjabvjbs jv ",
            "I want to live in this, but I can't afford a flat.",
            "This looks stupid",
            "This one is also very modern looking.",
            "What a great design",
        ]
    }
    
  

    @IBOutlet weak var collectionView: UICollectionView!
 
    @IBOutlet weak var pinterestLayout: PinterestLayout!
   

    @IBOutlet weak var titleLabel: UILabel!
    
    var houseImages: [UIImage?] = []
    var houseLabels: [String] = []
    var attachmentData:[Attachment]?
    var filteredAttachments:[Attachment]?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchAttachments()
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func setupCollectionView() {
            if let layout = collectionView.collectionViewLayout as? PinterestLayout {
                layout.delegate = self
            }

            collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "AttachmentCvCollectionViewCell", bundle: nil), forCellWithReuseIdentifier:"AttachmentCvCollectionViewCell")
        }
}


extension AttachmentVCViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let attachment = filteredAttachments?[indexPath.item] else { return 0 }
        let width = (collectionView.bounds.width / 2) - 16

        let titleFont = UIFont.boldSystemFont(ofSize: 14)
        let descFont = UIFont.systemFont(ofSize: 12)

        let titleHeight = attachment.title?.heights(withConstrainedWidth: width, font: titleFont) ?? 0
        let descHeight = attachment.description?.heights(withConstrainedWidth: width, font: descFont) ?? 0
        let dateAndtime = attachment.date?.heights(
            withConstrainedWidth: width,
            font: descFont
        ) ?? 0
        let spacing: CGFloat = 8 + 8 + 8

        switch attachment.file_path?.first?.type {
        case "IMAGE":
            if let urlString = attachment.file_path?.first?.path,
               let url = URL(string: urlString),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                let ratio = (image.size.height * width) / image.size.width
                return dateAndtime + titleHeight + descHeight + 270 + spacing
            } else {
                return titleHeight + descHeight + 200 + spacing
            }

        case "VIDEO":
            return  titleHeight + descHeight + 270 + spacing
        case "DOCUMENT":
            return   300 + spacing
        default:
            return titleHeight + descHeight + 80 + spacing
        }
    }


    func extractDimensions(from iframe: String) -> (width: String, height: String)? {
        guard let widthMatch = iframe.range(of: #"width=\"(\d+)\""#, options: .regularExpression),
              let heightMatch = iframe.range(of: #"height=\"(\d+)\""#, options: .regularExpression) else {
            return nil
        }

        let width = String(iframe[widthMatch]).replacingOccurrences(of: #"width=""#, with: "").replacingOccurrences(of: "\"", with: "")
        let height = String(iframe[heightMatch]).replacingOccurrences(of: #"height=""#, with: "").replacingOccurrences(of: "\"", with: "")

        print(width,width)
        return (width, height)
    }
    

}

extension AttachmentVCViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredAttachments?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.imageCellID, for: indexPath) as! AttachmentCvCollectionViewCell
        guard let data = filteredAttachments?[indexPath.row] else {
            return UICollectionViewCell()
        }

        cell.TitleLbl.text = data.title
        cell.timeAndDate.text = (data.date ?? "") + " - " + (data.time ?? "")
        cell.sentBy.text = data.sender_info
        cell.discreptionLbl.text = data.description

        switch data.file_path?.first?.type {
        case "IMAGE":
            cell.imageView.isHidden = false
            cell.webOuterView.isHidden = true
            cell.webview.isHidden = true
            cell.imageView.sd_setImage(with: URL(string: data.file_path?.first?.path ?? ""), placeholderImage: ImageName.placeholder)

        case "VIDEO":
            cell.imageView.isHidden = true
            cell.webOuterView.isHidden = false
            cell.webview.isHidden = true
            cell.sentBy.isHidden = true
    
//            cell.webOuterView.contentMode = .scaleAspectFill
            cell.webOuterView.clipsToBounds = true
            cell.webOuterView.layer.cornerRadius = 10
            
//            if let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
//                  cell.configureVideo(with: url)
//              }
            
            fetchMP4VideoURL(videoURI: "https://vimeo.com/1083863418", accessToken: "8d74d8bf6b5742d39971cc7d3ffbb51a") { mp4URL in
             if let mp4URL = mp4URL {
             print("🎥 MP4 video URL: \(mp4URL)")
             // Now you can play it using AVPlayer or show in your view
             } else {
             print("❌ Failed to get MP4 URL.")
             }
            }
        case "DOCUMENT":
            cell.imageView.isHidden = true
            cell.webOuterView.isHidden = false
            cell.webview.isHidden = false
            if let docUrl = data.file_path?.first?.path, let url = URL(string: docUrl) {
                cell.webview.load(URLRequest(url: url))
            }
            cell.sentBy.isHidden = true

        default:
            cell.imageView.isHidden = true
            cell.webOuterView.isHidden = true
        }

        return cell
    }

    
    
    
    
    func fetchMP4VideoURL(videoURI: String, accessToken: String, completion: @escaping (String?) -> Void) {
     let url = URL(string: "https://api.vimeo.com\(videoURI)")! // e.g. /videos/12345678
     var request = URLRequest(url: url)
     request.httpMethod = "GET"
     request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
     request.setValue("application/vnd.vimeo.*+json;version=3.4", forHTTPHeaderField: "Accept")
     
     URLSession.shared.dataTask(with: request) { data, response, error in
     guard let data = data else {
     print("❌ Error fetching video info: \(error?.localizedDescription ?? "Unknown error")")
     completion(nil)
     return
     }
     
     do {
     if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
     let files = (json["download"] as? [[String: Any]]) ?? (json["files"] as? [[String: Any]]) {
     
     for file in files {
     if let quality = file["quality"] as? String,
     let link = file["link"] as? String,
     quality == "source" || quality == "hd" || link.hasSuffix(".mp4") {
     print("✅ Found MP4 URL: \(link)")
     completion(link)
     return
     }
     }
     
     print("❌ No .mp4 file found in files array.")
     completion(nil)
     } else {
     print("❌ Unexpected JSON structure: \(String(data: data, encoding: .utf8) ?? "")")
     completion(nil)
     }
     } catch {
     print("❌ JSON parsing error: \(error.localizedDescription)")
     completion(nil)
     }
     }.resume()
    }

    private func fetchAttachments() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_communication_attachment_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token:studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<AttachmentsResponse, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self?.hideLottieProgressLoader()
                }
                
                switch result {
                case .success(let response):
                    self?.attachmentData = response.data
                    self?.filteredAttachments = response.data
                    self?.collectionView.delegate = self
                    self?.collectionView.dataSource = self
                    self?.collectionView.reloadData()
                   
                case .failure(let error):
                    print("Error fetching attachments:", error.localizedDescription)
                }
            }
        }
    }
     
   

    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y + scrollView.contentInset.top
//        
//        let dy = offsetY > 0 ? -offsetY : 0
////        titleLabel.transform = CGAffineTransform(translationX: 0, y: dy)
//    }
    
    
    
}



extension String {
    func heights(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
        return ceil(boundingBox.height)
    }
}
