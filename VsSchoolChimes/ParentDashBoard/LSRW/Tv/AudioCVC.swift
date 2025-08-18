//
//  AudioCVC.swift
//  School Chimes
//
//  Created by Chandhru on 18/08/25.
//

import UIKit

@available(iOS 15.0, *)
class AudioCVC: UICollectionViewCell {
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var waveView: AudioMessageView!
    @IBOutlet weak var playerView: UIView!
    var audioURL: URL? {
        didSet {
            guard let url = audioURL else { return }
            // Check if it's a remote URL (http or https)
            if url.isFileURL {
                do {
                    try audioManager.setupPlayer(with: url)
                    waveView.audioURL = url
                } catch {
                    print("❌ Failed to set up audio player:", error)
                }
            } else {
                // Remote URL - download it first
                downloadAndPrepareAudio(from: url)
            }
            
        }
    }
    
    private let audioManager = AudioManager()
    override func awakeFromNib() {
        super.awakeFromNib()
        playerView.setShadow(cornerRadius: 10)
    }
    
    private func downloadAndPrepareAudio(from remoteURL: URL) {
        let session = URLSession.shared
        let task = session.downloadTask(with: remoteURL) { [weak self] (tempURL, response, error) in
            guard let self = self else { return }
            if let tempURL = tempURL {
                do {
                    try self.audioManager.setupPlayer(with: tempURL)
                    DispatchQueue.main.async {
                        self.waveView.audioURL = tempURL
                    }
                } catch {
                    print("Failed to setup player: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.showErrorAlert(message: "Failed to load audio file")
                    }
                }
            } else {
                print("Download error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.showErrorAlert(message: "Audio download failed.")
                }
            }
        }
        task.resume()
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        waveView.isPlaying.toggle()
        playBtn.isSelected = waveView.isPlaying
        playBtn.setImage(UIImage(named: waveView.isPlaying ? "pause-button" : "play-button"), for: .normal)
        if waveView.isPlaying {
            waveView.startPlaybackAnimation()
        } else {
            waveView.stopPlaybackAnimation()
        }
    }
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Audio Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        getCurrentViewController()?.present(alert, animated: true)
    }
    
    private func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController?
            .topMostViewController()
    }
}
