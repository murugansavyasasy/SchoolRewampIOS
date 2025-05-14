//
//  AttachmentCvCollectionViewCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 05/05/25.
//

import UIKit
import WebKit
import AVKit

class AttachmentCvCollectionViewCell: UICollectionViewCell {
    enum Constants {
        static let padding: CGFloat = 8
        static let font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    }
   
    @IBOutlet weak var webOuterView: UIView!
    @IBOutlet weak var webview: WKWebView!

    @IBOutlet weak var sentBy: UILabel!
    @IBOutlet weak var timeAndDate: UILabel!
    @IBOutlet weak var discreptionLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    private var currentlyPlayingIndexPath: IndexPath?
  

    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    private var videoURL: URL?
    

    private var isMuted = true
       private var isPlaying = false

    private let playButton: UIButton = UIButton(type: .system)
       private let muteButton = UIButton()

       
       var onPlayPressed: ((AttachmentCvCollectionViewCell) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.layer.cornerRadius = 12 // Set your desired radius
        webview.clipsToBounds = true
        webview.layer.borderWidth = 0.5
        webview.layer.borderColor = UIColor.black.cgColor
        
        
    }
    
    
    
   

       override func prepareForReuse() {
           super.prepareForReuse()
           player?.pause()
           playerLayer?.removeFromSuperlayer()
           player = nil
           playerLayer = nil
           isPlaying = false
           isMuted = true
           playButton.isHidden = false
           updatePlayButtonIcon()
       }

    

      
       override func layoutSubviews() {
           super.layoutSubviews()
           playerLayer?.frame = webOuterView.bounds
       }

   
   


       private func setupMuteButton() {
           muteButton.translatesAutoresizingMaskIntoConstraints = false
           muteButton.tintColor = .white
           muteButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
           muteButton.layer.cornerRadius = 18
           muteButton.clipsToBounds = true
           muteButton.addTarget(self, action: #selector(muteButtonTapped), for: .touchUpInside)

           webOuterView.addSubview(muteButton)

           NSLayoutConstraint.activate([
               muteButton.bottomAnchor.constraint(equalTo: webOuterView.bottomAnchor, constant: -10),
               muteButton.trailingAnchor.constraint(equalTo: webOuterView.trailingAnchor, constant: -10),
               muteButton.widthAnchor.constraint(equalToConstant: 36),
               muteButton.heightAnchor.constraint(equalToConstant: 36)
           ])

           updateMuteButtonIcon()
       }

       @objc private func muteButtonTapped() {
           guard let player = player else { return }
           isMuted.toggle()
           player.isMuted = isMuted
           updateMuteButtonIcon()
       }

       private func updateMuteButtonIcon() {
           let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
           let imageName = isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"
           let image = UIImage(systemName: imageName, withConfiguration: config)
           muteButton.setImage(image, for: .normal)
       }


        func configureVideo(with url: URL) {
            setupPlayButton()
            setupMuteButton()
            if player == nil {
                player = AVPlayer(url: url)
                player?.actionAtItemEnd = .pause

                playerLayer = AVPlayerLayer(player: player)
                playerLayer?.frame = webOuterView.bounds
                playerLayer?.videoGravity = .resizeAspectFill

                if let playerLayer = playerLayer {
                    webOuterView.layer.insertSublayer(playerLayer, at: 0)
                }

                // Observer for video end
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(videoDidEnd),
                                                       name: .AVPlayerItemDidPlayToEndTime,
                                                       object: player?.currentItem)
            }

            updatePlayButtonIcon()
        }

        @objc private func playButtonTapped() {
            guard let player = player else { return }

            if isPlaying {
                player.pause()
                isPlaying = false
            } else {
                onPlayPressed?(self) // Pause other videos
                player.play()
                isPlaying = true
            }

            updatePlayButtonIcon()
        }

        @objc private func videoDidEnd() {
            player?.seek(to: .zero)
            player?.pause()
            isPlaying = false
            updatePlayButtonIcon()
        }

        private func setupPlayButton() {
            if playButton.superview == nil {
                playButton.translatesAutoresizingMaskIntoConstraints = false
                playButton.tintColor = .white
                playButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                playButton.layer.cornerRadius = 25
                playButton.clipsToBounds = true
                playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)

                webOuterView.addSubview(playButton)

                NSLayoutConstraint.activate([
                    playButton.centerXAnchor.constraint(equalTo: webOuterView.centerXAnchor),
                    playButton.centerYAnchor.constraint(equalTo: webOuterView.centerYAnchor),
                    playButton.widthAnchor.constraint(equalToConstant: 50),
                    playButton.heightAnchor.constraint(equalToConstant: 50)
                ])
            }
        }

        private func updatePlayButtonIcon() {
            let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
            let imageName = isPlaying ? "pause.circle.fill" : "play.circle.fill"
            let image = UIImage(systemName: imageName, withConfiguration: config)
            playButton.setImage(image, for: .normal)
        }

        func pauseIfNeeded() {
            if isPlaying {
                player?.pause()
                isPlaying = false
                updatePlayButtonIcon()
            }
        }
    
    
    func loadVimeoVideo(iframe: String) {
        let htmlString = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>body, html { margin: 0; padding: 0; }</style>
        </head>
        <body>
        \(iframe)
        </body>
        </html>
        """
        webview.loadHTMLString(htmlString, baseURL: nil)
    }

}
