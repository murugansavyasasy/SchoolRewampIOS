//
//  VideoPlayerVC.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 08/11/24.
//

import UIKit
import AVFoundation
import Photos
import AVKit

class VideoPlayerVC: UIViewController {
    @IBOutlet weak var paybtn: UIButton!
    
    @IBOutlet weak var DownloadImg: UIImageView!
    @IBOutlet weak var playerview: UIView!
    var phasset: PHAsset?
    //var player: AVPlayer!
    var srlstring: String?
    var url: URL?
    var index : Int?
    var avPlayerLayer: AVPlayerLayer?
    var shareDelegate : shareDelegate?
    var playerViewController: AVPlayerViewController?
    var videoURL: URL? // Receive the URL
       var player: AVPlayer?
       var playerLayer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        print("Entered Video player")
       // setupVideoPlayer(with: url!)
        setupPlayer(with: url!)
       // setupPlayer(url: URL(string: "https://www.w3schools.com/tags/mov_bbb.mp4"))
    }
    
    
    @IBAction func backAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
//    override func viewDidLayoutSubviews() {
//          super.viewDidLayoutSubviews()
//          avPlayerLayer?.frame = playerview.bounds
//      }
//    
//    func setupPlayer(url: URL?) {
//        guard let url = url else {
//                print("URL is nil")
//                return
//            }
//            
//            player = AVPlayer(url: url)
//            avPlayerLayer = AVPlayerLayer(player: player)
//            avPlayerLayer?.videoGravity = .resizeAspect
//            if let avPlayerLayer = avPlayerLayer {
//                avPlayerLayer.frame = playerview.bounds
//                playerview.layer.addSublayer(avPlayerLayer)
//            }
//            player.play()
//    }
//    
    
    //     override func layoutSubviews() {
    //         super.layoutSubviews()
    //         avPlayerLayer?.frame = playerview.bounds
    //     }
//    private func setupPlayPauseButton() {
//        paybtn.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
//        paybtn.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
//        paybtn.tintColor = .red
//        paybtn.translatesAutoresizingMaskIntoConstraints = false
//        playerview.addSubview(paybtn)
//        
//        NSLayoutConstraint.activate([
//            paybtn.centerXAnchor.constraint(equalTo: playerview.centerXAnchor),
//            paybtn.centerYAnchor.constraint(equalTo: playerview.centerYAnchor),
//            paybtn.widthAnchor.constraint(equalToConstant: 50),
//            paybtn.heightAnchor.constraint(equalToConstant: 50)
//        ])
//    }
//    // IBAction for play/pause button
//    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
//        if player.isPlaying {
//            player.pause()
//            paybtn.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
//        } else {
//            player.play()
//            paybtn.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
//        }
//    }
//    
//    @IBAction func back(_ sender: Any) {
//        dismiss(animated: true)
//       
//    }
//    
//    func setupVideoPlayer(with url: URL) {
//           player = AVPlayer(url: url)
//           playerLayer = AVPlayerLayer(player: player)
//           playerLayer?.frame = playerview.bounds
//           playerLayer?.videoGravity = .resizeAspectFill
//           playerview.layer.addSublayer(playerLayer!)
//           player?.play()
//       }
    func setupPlayer(with url: URL) {
            player = AVPlayer(url: url)
            
            // Create AVPlayerViewController
            playerViewController = AVPlayerViewController()
            playerViewController?.player = player
            playerViewController?.showsPlaybackControls = true // Enable default controls
            
            // Add AVPlayerViewController as a child
            addChild(playerViewController!)
        playerViewController!.view.frame = playerview.bounds
            playerViewController!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerview.addSubview(playerViewController!.view)
            playerViewController!.didMove(toParent: self)

            // Auto-play the video
            player?.play()
        }
       
       override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           playerLayer?.frame = playerview.bounds // Ensure it resizes correctly
       }
    
}
extension AVPlayer {
    var isPlaying: Bool {
        return self.rate != 0 && self.error == nil
    }
}
