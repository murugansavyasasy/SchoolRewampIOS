//
//  VideoPlayerVC.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 08/11/24.
//

import UIKit
import AVFoundation
import Photos

class VideoPlayerVC: UIViewController {
    @IBOutlet weak var paybtn: UIButton!
    
    @IBOutlet weak var playerview: UIView!
    var phasset: PHAsset?
    var player: AVPlayer!
    var srlstring: String?
    var url: URL?
    var index : Int?
    var avPlayerLayer: AVPlayerLayer?
    var shareDelegate : shareDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer(url: URL(string: "https://www.w3schools.com/tags/mov_bbb.mp4"))
    }
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          avPlayerLayer?.frame = playerview.bounds
      }
    
    func setupPlayer(url: URL?) {
        guard let url = url else {
                print("URL is nil")
                return
            }
            
            player = AVPlayer(url: url)
            avPlayerLayer = AVPlayerLayer(player: player)
            avPlayerLayer?.videoGravity = .resizeAspect
            if let avPlayerLayer = avPlayerLayer {
                avPlayerLayer.frame = playerview.bounds
                playerview.layer.addSublayer(avPlayerLayer)
            }
            player.play()
    }
    
    
    //     override func layoutSubviews() {
    //         super.layoutSubviews()
    //         avPlayerLayer?.frame = playerview.bounds
    //     }
    private func setupPlayPauseButton() {
        paybtn.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        paybtn.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        paybtn.tintColor = .red
        paybtn.translatesAutoresizingMaskIntoConstraints = false
        playerview.addSubview(paybtn)
        
        NSLayoutConstraint.activate([
            paybtn.centerXAnchor.constraint(equalTo: playerview.centerXAnchor),
            paybtn.centerYAnchor.constraint(equalTo: playerview.centerYAnchor),
            paybtn.widthAnchor.constraint(equalToConstant: 50),
            paybtn.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    // IBAction for play/pause button
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        if player.isPlaying {
            player.pause()
            paybtn.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        } else {
            player.play()
            paybtn.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
       
    }
    
}
extension AVPlayer {
    var isPlaying: Bool {
        return self.rate != 0 && self.error == nil
    }
}
