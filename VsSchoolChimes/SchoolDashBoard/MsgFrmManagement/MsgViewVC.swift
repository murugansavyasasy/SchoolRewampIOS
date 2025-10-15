//
//  MsgViewVC.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 02/09/25.
//

import UIKit
import AVFoundation

class MsgViewVC: UIViewController,UIScrollViewDelegate {
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var postedOn: UILabel!
    @IBOutlet weak var postedByLbl: UILabel!
    @IBOutlet weak var pageControls: UIPageControl!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var reminingLbl: UILabel!
    @IBOutlet weak var totalduraionLbl: UILabel!
    @IBOutlet weak var AudioFullView: UIView!
    @IBOutlet weak var outerView: UIView!
    
    @IBOutlet weak var reasonImgView: UIImageView!
    @IBOutlet weak var reasonDfltLbl: UILabel!
    @IBOutlet weak var voiceTitle: UILabel!
    @IBOutlet weak var reasonLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    var player: AVPlayer?
       var playerItem: AVPlayerItem?
       var timer: Timer?

       @IBOutlet weak var playButton: UIButton!
       @IBOutlet weak var slider: UISlider!
    var file_path: [FilePath]?
    var MsgFromManagmentData = ManagemantMessageData()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        cv.isHidden = file_path?.count == 0
        AudioFullView.isHidden = file_path?.count != 0
        pageControls.isHidden = file_path?.count == 1 || file_path?.count == 0
        
        pageControls.numberOfPages = file_path?.count ?? 0
        pageControls.currentPage = 0
        outerView.layer.cornerRadius = 15
        cv.register(
                UINib(nibName: "MsgVoiceCvCell", bundle: nil),
                forCellWithReuseIdentifier: "MsgVoiceCvCell"
            )
        cv.delegate = self
        cv.dataSource = self
       
        
        if MsgFromManagmentData.content  != ""{
            
            setupAudio()
        }
        reasonLbl.isHidden = MsgFromManagmentData.description?.isEmpty ?? true
        reasonDfltLbl.isHidden = reasonLbl.isHidden
        reasonImgView.isHidden = reasonLbl.isHidden
        postedByLbl.text = ("Posted By:") + (MsgFromManagmentData.sent_by ?? "")
        titleLbl.text = MsgFromManagmentData.title?.capitalized
        reasonLbl.text = MsgFromManagmentData.description?.capitalized
        voiceTitle.text = MsgFromManagmentData.title
        postedOn.text = formattedDateStatus(from: MsgFromManagmentData.date ?? "" ) + " " +  (
            MsgFromManagmentData.time ?? "" )
        if MsgFromManagmentData.is_emergency ?? false{
            typeLbl.text = "Emergency Voice"
        }else{
            typeLbl.text = "Voice"
        }
    }

    @IBAction func backBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    func setupAudio() {
        guard let url = URL(string: MsgFromManagmentData.content ?? "") else {
            return
        }

           playerItem = AVPlayerItem(url: url)
           player = AVPlayer(playerItem: playerItem)

           // Observe when playback finishes
           NotificationCenter.default.addObserver(self,
                                                  selector: #selector(playerDidFinishPlaying),
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: playerItem)

           // Load total duration
           playerItem?.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
               DispatchQueue.main.async {
                   if let duration = self.playerItem?.asset.duration {
                       let seconds = CMTimeGetSeconds(duration)
                       if seconds.isFinite {
                           self.slider.minimumValue = 0
                           self.slider.maximumValue = Float(seconds)
                           self.totalduraionLbl.text = self.formatTime(seconds)
                           self.reminingLbl.text = self.formatTime(seconds) // initially remaining = total
                       }
                   }
               }
           }
       }

       @IBAction func playTapped(_ sender: UIButton) {
           guard let player = player else { return }

           if player.timeControlStatus == .playing {
               player.pause()
               timer?.invalidate()
               playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
           } else {
               player.play()
               startTimer()
               playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
           }
       }

       func startTimer() {
           timer?.invalidate()
           timer = Timer.scheduledTimer(timeInterval: 0.5,
                                        target: self,
                                        selector: #selector(updateSlider),
                                        userInfo: nil,
                                        repeats: true)
       }

       @objc func updateSlider() {
           guard let currentTime = player?.currentTime(),
                 let duration = playerItem?.duration else { return }

           let currentSeconds = CMTimeGetSeconds(currentTime)
           let totalSeconds = CMTimeGetSeconds(duration)

           if currentSeconds.isFinite, totalSeconds.isFinite {
               slider.value = Float(currentSeconds)

               // update labels
               reminingLbl.text = formatTime(totalSeconds - currentSeconds)
               totalduraionLbl.text = formatTime(totalSeconds)
           }
       }

       @IBAction func sliderValueChanged(_ sender: UISlider) {
           let seekTime = CMTime(seconds: Double(sender.value), preferredTimescale: 600)
           player?.seek(to: seekTime)
           if player?.timeControlStatus != .playing {
               player?.play()
               startTimer()
               playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
           }
       }

       @objc func playerDidFinishPlaying() {
           timer?.invalidate()
           slider.value = 0
           reminingLbl.text = formatTime(0)
           playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
       }

       // MARK: - Helper
       func formatTime(_ seconds: Double) -> String {
           let mins = Int(seconds) / 60
           let secs = Int(seconds) % 60
           return String(format: "%02d:%02d", mins, secs)
       }
}

extension MsgViewVC :  UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return file_path?.count ?? 0
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MsgVoiceCvCell", for: indexPath) as? MsgVoiceCvCell else {
            return UICollectionViewCell()
        }
        
        if let url = URL(string: file_path?[indexPath.row].url ?? "") {
                    let request = URLRequest(url: url)
            cell.webView.load(request)
                }
      
        
        
        let urlString = file_path?[indexPath.row].url ?? ""
        if let url = URL(string: urlString) {
            let ext = url.pathExtension.lowercased()
            if ["png", "jpg", "jpeg", "webp"].contains(ext) {
               
                let imageUrl = urlString

                let htmlString = """
                <html>
                <head>
                <style>
                body { margin:0; padding:0; background:#000; }
                img { max-width:100%; height:auto; display:block; margin:auto; }
                </style>
                </head>
                <body>
                <img src="\(imageUrl)">
                </body>
                </html>
                """
                cell.webView.isUserInteractionEnabled = false
                cell.webView.loadHTMLString(htmlString, baseURL: nil)
            } else {
                cell.webView.isUserInteractionEnabled = true
                cell.webView
                    .load(
                        URLRequest(url: URL(string:file_path?[indexPath.row].url ?? "")!)
                    )
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let file = file_path?[indexPath.row], let urlString = file.url, let url = URL(string: urlString) else { return }
       
        
       
           
            let imageVC = ImageShowVc(nibName: nil, bundle: nil)
            imageVC.fileURL = file_path ?? []
//            imageVC.subjectName = backBtn.title(for: .normal) ?? ""
            imageVC.pdfUrl = urlString
            imageVC.scrollIndex = indexPath
            imageVC.index = indexPath.row
//            imageVC.type = isImage ? 2 : 0
            imageVC.modalPresentationStyle = .fullScreen
            present(imageVC, animated: true)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.layer.frame.width, height: 180)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
           let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControls.currentPage = Int(pageIndex)
       }
}
