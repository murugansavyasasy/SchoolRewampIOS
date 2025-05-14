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

    private var isMuted = true
      private let muteButton = UIButton(type: .system)

    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
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
       }

       func configureVideo(with url: URL) {
           setupMuteButton()
           guard player == nil else { return }

           player = AVPlayer(url: url)
           player?.isMuted = true
           isMuted = true
           updateMuteButtonIcon()

           playerLayer = AVPlayerLayer(player: player)
           playerLayer?.frame = webOuterView.bounds
           playerLayer?.videoGravity = .resizeAspectFill

           if let layer = playerLayer {
               webOuterView.layer.insertSublayer(layer, at: 0)
           }

           player?.play()
       }

       override func layoutSubviews() {
           super.layoutSubviews()
           playerLayer?.frame = webOuterView.bounds
       }

       // MARK: - Mute Button Setup

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
               muteButton.centerXAnchor.constraint(equalTo: webOuterView.centerXAnchor),
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
