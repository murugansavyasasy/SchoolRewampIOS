//
//  SubmissionTVC.swift
//  School Chimes
//
//  Created by Chandhru on 09/06/25.
//

import UIKit
import AVFoundation
import AVKit

class SubmissionTVC: UITableViewCell, AVPlayerViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
    
    
    @IBOutlet weak var sumisionCollectionView: UICollectionView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var assignmentTitle: UILabel!
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var timeLeft: UILabel!
    var FilesUrl:[FilePath]?
    var player: AVPlayer?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Style outer view (rounded card style)
        outerView.layer.cornerRadius = 10
        outerView.layer.borderWidth = 1
        outerView.layer.borderColor = UIColor.systemGray5.cgColor
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 0.05
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 4
        outerView.layer.masksToBounds = false
        sumisionCollectionView.delegate = self
        sumisionCollectionView.dataSource = self
        // Fonts
        assignmentTitle.setFont(style: .body, size: FontSize.TitleSize)
        subjectName.setFont(style: .body, size: FontSize.BodySize)
        date.setFont(style: .body, size: FontSize.BodySize)
        descriptionLbl.setFont(style: .body, size: FontSize.BodySize)
        timeLeft.setFont(style: .body, size: FontSize.BodySize)
        sumisionCollectionView.register(UINib(nibName: CellConfingName.ImagePdfCvCell, bundle:nil), forCellWithReuseIdentifier: CellConfingName.ImagePdfCvCell)
        
    }
}
extension SubmissionTVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return FilesUrl?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = sumisionCollectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ImagePdfCvCell, for: indexPath) as! ImagePdfCvCell
        
        if let img = FilesUrl?[indexPath.row] {
            let fileURL = URL(fileURLWithPath: img.url ?? "")
            let iconName = getFileIconName(for: fileURL)
            if iconName != "image" {
                if img.type?.uppercased() == "VIDEO"{
                    cell.webView.isHidden = true
                    cell.imageView.isHidden = false
                    loadVimeoThumbnail(from: img.url ?? "", accessToken: YOUR_VIMEO_TOKEN) { image in
                        if let thumbnailImage = image {
                            cell.imageView.image = thumbnailImage
                        }
                    }
                    let iconImage = UIImage(named: "video (1)")
                    cell.IndicaterImageView.image = iconImage
                }else{
                    if let pdfURL = URL(string: img.url ?? ""){
                        let request = URLRequest(url: pdfURL)
                        cell.webView.load(request)
                        cell.webView.isHidden = false
                        cell.webView.isUserInteractionEnabled = false  // ✅ Add this
                        cell.webView.scrollView.isScrollEnabled = false // ✅ Optional
                        cell.imageView.isHidden = true
                        
                    } else {
                        cell.webView.isHidden = true
                        cell.imageView.isHidden = false
                    }
                    let iconImage = UIImage(named: iconName)
                    cell.IndicaterImageView.image = iconImage
                }
            } else {
                cell.webView.isHidden = true
                cell.imageView.isHidden = false
                cell.imageView.sd_setImage(with: URL(string: img.url ?? ""), placeholderImage: ImageName.placeholder)
                let iconImage = UIImage(named: iconName)
                cell.IndicaterImageView.image = iconImage
            }
            
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt")
        guard let file = FilesUrl?[indexPath.row], let urlString = file.url, let url = URL(string: urlString) else { return }
                let fileExtension = url.pathExtension.lowercased()
        
                let vc = getCurrentViewController()
        if file.type?.uppercased() == "VIDEO"{
            playVimeoVideo(from: file.url ?? "")
        }else{
            let vcc = ImageShowVc(nibName: nil, bundle: nil)
            vcc.imageURL = FilesUrl?.filter({ img in
                img.type?.uppercased() == CommonStringFile.IMAGE
            }) ?? []
            var homeworkDocs = FilesUrl ?? []
            let filePath = homeworkDocs[indexPath.row]
            homeworkDocs.remove(at: indexPath.row)
            homeworkDocs.insert(filePath, at: 0)
            vcc.FileURL =  homeworkDocs
            vcc.pdfUrl = FilesUrl?[indexPath.row].url
            vcc.scrollIndex = indexPath
            vcc.type = FilesUrl?[indexPath.row].type?.uppercased() != CommonStringFile.IMAGE ? 0 : 2
            vcc.modalPresentationStyle = .fullScreen
            vc?.present(vcc, animated: true)
        }
               
    }
    func playVimeoVideo(from url: String) {
        if let videoID = extractVimeoID(from: url) {
            let vc = getCurrentViewController()
            fetchVimeoVideoFiles(videoID: videoID, accessToken: YOUR_VIMEO_TOKEN) { urls in
                if let firstURLString = urls.first,
                   let videoURL = URL(string: firstURLString) {
                    
                    DispatchQueue.main.async {
                        let player = AVPlayer(url: videoURL)
                        self.player = player
                        
                        let playerViewController = AVPlayerViewController()
                        playerViewController.player = player
                        playerViewController.delegate = self
                        playerViewController.presentationController?.delegate = self
                        
                        vc?.present(playerViewController, animated: true) {
                            player.play()
                        }
                    }
                } else {
                    print("No video URLs found or error")
                }
            }
        } else {
            print("Invalid Vimeo URL")
        }
    }
    func getCurrentViewController() -> UIViewController? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first?.rootViewController?.topMostViewController()
    }
}
