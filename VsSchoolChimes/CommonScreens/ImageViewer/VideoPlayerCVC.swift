import UIKit
import WebKit
import AVFoundation

class VideoPlayerCVC: UICollectionViewCell {

    @IBOutlet weak var videoPlayer: UIView!
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var webView: WKWebView?

    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil
        
        webView?.removeFromSuperview()
        webView = nil
    }

    func configure(with url: URL) {
        let urlString = url.absoluteString.lowercased()
        
        if urlString.contains("vimeo.com") || urlString.contains("youtube.com") {
            // Load in WKWebView
            let config = WKWebViewConfiguration()
            let webView = WKWebView(frame: videoPlayer.bounds, configuration: config)
            webView.translatesAutoresizingMaskIntoConstraints = false
            self.videoPlayer.addSubview(webView)
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: videoPlayer.topAnchor),
                webView.bottomAnchor.constraint(equalTo: videoPlayer.bottomAnchor),
                webView.leadingAnchor.constraint(equalTo: videoPlayer.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: videoPlayer.trailingAnchor)
            ])
            webView.load(URLRequest(url: url))
            self.webView = webView
        } else {
            // Load using AVPlayer
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = videoPlayer.bounds
            playerLayer?.videoGravity = .resizeAspect
            if let layer = playerLayer {
                videoPlayer.layer.addSublayer(layer)
            }
            player?.play()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = videoPlayer.bounds
        webView?.frame = videoPlayer.bounds
    }
}
