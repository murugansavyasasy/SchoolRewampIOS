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

    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
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
        tittleLbl.text = nil
        descriptionTxt.text = nil
        imgView.image = nil
    }

    func configure(with item: UpdateItem) {
        // Title + Description
        tittleLbl.text = item.name ?? ""
        descriptionTxt.text = item.description ?? ""
        let size = CGSize(width: descriptionTxt.frame.width, height: .infinity)
        let estimatedSize = descriptionTxt.sizeThatFits(size)
        descriptionHeight.constant = estimatedSize.height
        if let link = item.video_link,
           !link.isEmpty,
           let url = URL(string: link) {
            videoURL = url
            imgView.isHidden = true
            videoView.isHidden = false
            setupPlayerIfNeeded()
        } else {
            if let imgURL = URL(string: item.downloadable_image ?? "") {
                imgView.kf.setImage(with: imgURL)
            } else {
                imgView.image = nil
            }
            imgView.isHidden = false
            videoView.isHidden = true
            videoURL = nil
            stopVideo()
        }
    }

    private func setupPlayerIfNeeded() {
        guard player == nil, let url = videoURL else { return }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        
        if let layer = playerLayer {
            videoView.layer.addSublayer(layer)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loopVideo),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
    }

    @objc private func loopVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = videoView.bounds
        
        // 👇 Update text view height on layout change (e.g. rotation)
        let size = CGSize(width: descriptionTxt.frame.width, height: .infinity)
        let estimatedSize = descriptionTxt.sizeThatFits(size)
        descriptionHeight.constant = estimatedSize.height
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

// MARK: - Top-aligned UILabel
class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let textRect = super.textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        super.drawText(in: CGRect(x: rect.origin.x,
                                  y: rect.origin.y,
                                  width: textRect.width,
                                  height: textRect.height))
    }

    override func textRect(forBounds bounds: CGRect,
                           limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        textRect.origin.y = bounds.origin.y
        return textRect
    }
}
