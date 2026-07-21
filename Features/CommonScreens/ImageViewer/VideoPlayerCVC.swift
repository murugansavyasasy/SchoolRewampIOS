import UIKit
import WebKit
import AVFoundation
import AVKit

class VideoPlayerCVC: UICollectionViewCell {

    @IBOutlet weak var videoPlayer: UIView!

    @IBOutlet weak var AlertLbl: UILabel!
    private var player: AVPlayer?
    private var playerViewController: AVPlayerViewController?
    private var webView: WKWebView?
    private var activityIndicator: UIActivityIndicatorView?
    override func prepareForReuse() {
        super.prepareForReuse()
        
        player?.pause()
        player = nil
        
        playerViewController?.view.removeFromSuperview()
        playerViewController = nil
        
        webView?.navigationDelegate = nil
        webView?.removeFromSuperview()
        webView = nil
        
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
    }

    func configure(with url: URL, parentVC: UIViewController,dateAndTimeForVideo:String) {
        showActivityIndicator()
        
        print("dateAndTimeForVideodateAndTimeForVideo",dateAndTimeForVideo)
        let urlString = url.absoluteString.lowercased()
        
        if urlString.contains("youtube.com") || urlString.contains("vimeo.com") {
            
            if TimeAccessManager.shared.canAllowFlow(dateAndTime: dateAndTimeForVideo) {
                let config = WKWebViewConfiguration()
                let webView = WKWebView(frame: videoPlayer.bounds, configuration: config)
                webView.navigationDelegate = self
                webView.translatesAutoresizingMaskIntoConstraints = false
                self.videoPlayer.addSubview(webView)
                NSLayoutConstraint.activate([
                    webView.topAnchor.constraint(equalTo: videoPlayer.topAnchor),
                    webView.bottomAnchor.constraint(equalTo: videoPlayer.bottomAnchor),
                    webView.leadingAnchor.constraint(equalTo: videoPlayer.leadingAnchor),
                    webView.trailingAnchor.constraint(equalTo: videoPlayer.trailingAnchor)
                ])
                self.AlertLbl.isHidden = true
                webView.load(URLRequest(url: url))
                self.webView = webView
                self.webView?.isHidden = false
            } else {
                self.hideActivityIndicator()
                self.AlertLbl.isHidden = false
                self.AlertLbl.text = CommonStringFile.You_can_access_this_after_30_minutes
                webView?.isHidden = true
            }

          
        } else {
            let asset = AVURLAsset(url: url)
            asset.loadValuesAsynchronously(forKeys: ["playable"]) { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    let playerItem = AVPlayerItem(asset: asset)
                    self.player = AVPlayer(playerItem: playerItem)
                    let playerVC = AVPlayerViewController()
                    playerVC.player = self.player
                    playerVC.showsPlaybackControls = true

                    playerVC.view.frame = self.videoPlayer.bounds
                    playerVC.view.translatesAutoresizingMaskIntoConstraints = false
                    self.videoPlayer.addSubview(playerVC.view)
                    NSLayoutConstraint.activate([
                        playerVC.view.topAnchor.constraint(equalTo: self.videoPlayer.topAnchor),
                        playerVC.view.bottomAnchor.constraint(equalTo: self.videoPlayer.bottomAnchor),
                        playerVC.view.leadingAnchor.constraint(equalTo: self.videoPlayer.leadingAnchor),
                        playerVC.view.trailingAnchor.constraint(equalTo: self.videoPlayer.trailingAnchor)
                    ])

                    parentVC.addChild(playerVC)
                    playerVC.didMove(toParent: parentVC)

                    self.playerViewController = playerVC
                    self.player?.play()
                }
            }
        }
    }

    private func showActivityIndicator() {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = videoPlayer.center
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        videoPlayer.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: videoPlayer.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: videoPlayer.centerYAnchor)
        ])
        activityIndicator = indicator
    }

    private func hideActivityIndicator() {
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerViewController?.view.frame = videoPlayer.bounds
        webView?.frame = videoPlayer.bounds
    }
}

extension VideoPlayerCVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideActivityIndicator()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideActivityIndicator()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideActivityIndicator()
    }
}
