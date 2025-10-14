//
//  WhatsNewCVC.swift
//  School Chimes
//
//  Created by Chandhru on 14/10/25.
//

import UIKit
import AVKit
import AVFoundation

class WhatsNewCVC: UICollectionViewCell {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var tittleLbl: TopAlignedLabel!
    @IBOutlet weak var imgView: UIImageView!

    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    private var videoURL: URL?

    override func awakeFromNib() {
        super.awakeFromNib()
        imgView.layer.cornerRadius = 8
        imgView.clipsToBounds = true
        videoView.layer.cornerRadius = 8
        videoView.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stopVideo()
    }

    func configure(with item: UpdateItem) {
        // Title + Description
        let titleText = (item.name ?? "") + "\n\n"
        let descriptionText = item.description ?? ""
        let attributedString = NSMutableAttributedString()
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 17),
            .foregroundColor: UIColor.label
        ]
        attributedString.append(NSAttributedString(string: titleText, attributes: titleAttributes))
        let descriptionAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel
        ]
        attributedString.append(NSAttributedString(string: descriptionText, attributes: descriptionAttributes))
        tittleLbl.attributedText = attributedString
        tittleLbl.numberOfLines = 0

        // Video or Image
        if let link = item.video_link, !link.isEmpty, let url = URL(string: link) {
            videoURL = url
            imgView.isHidden = true
            videoView.isHidden = false
            setupPlayerIfNeeded()
        } else {
            imgView.kf.setImage(with: URL(string: item.downloadable_image ?? ""))
            imgView.isHidden = false
            videoView.isHidden = true
            videoURL = nil
            stopVideo()
        }
    }

    private func setupPlayerIfNeeded() {
        guard player == nil, let url = videoURL else { return }
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        if let layer = playerLayer {
            videoView.layer.addSublayer(layer)
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loopVideo),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    }

    @objc private func loopVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = videoView.bounds
    }

    // MARK: - Public control methods
    func playVideo() {
        if player == nil {
            setupPlayerIfNeeded()
        }
        player?.play()
    }

    func stopVideo() {
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        player = nil
        NotificationCenter.default.removeObserver(self,
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: nil)
    }
}

// Top-aligned UILabel
class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let textRect = super.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        super.drawText(in: CGRect(x: rect.origin.x,
                                  y: rect.origin.y,
                                  width: textRect.width,
                                  height: textRect.height))
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        textRect.origin.y = bounds.origin.y
        return textRect
    }
}
