
//  videoPickAndPlay.swift
//  School Chimes
//  Created by SARANRAJ SHANMUGAM on 30/05/25.
import UIKit
import AVFoundation
import AVKit
import PhotosUI
import UniformTypeIdentifiers

protocol VideoPickerManagerDelegate: AnyObject {
    func videoPickerManager(didPickVideo url: URL)
    func videoPickerManagerDidCloseVideo()
}

class VideoPickerManager: NSObject {
    weak var delegate: VideoPickerManagerDelegate?
    weak var presenter: UIViewController?
    private var player: AVPlayer?
    private var playerVC: AVPlayerViewController?

    init(presenter: UIViewController, delegate: VideoPickerManagerDelegate) {
        self.presenter = presenter
        self.delegate = delegate
    }

    // MARK: - Pick Video
    func pickVideo() {
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration()
            config.filter = .videos
            config.selectionLimit = 1
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            presenter?.present(picker, animated: true)
        } else {
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                print("❌ Photo Library is not available")
                return
            }
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.movie"]
            picker.allowsEditing = false
            presenter?.present(picker, animated: true)
        }
    }

    func playVideo(from url: URL, in container: UIView) {
        stopVideo()

        player = AVPlayer(url: url)
        playerVC = AVPlayerViewController()
        playerVC?.player = player
        playerVC?.showsPlaybackControls = true

        guard let playerVC = playerVC, let presenter = presenter else {
            print("❌ Failed to initialize player or presenter")
            return
        }

        presenter.addChild(playerVC)
        playerVC.view.frame = container.bounds
        playerVC.view.clipsToBounds = true
        container.addSubview(playerVC.view)
        playerVC.didMove(toParent: presenter)

        // Ensure controls are visible and layout is updated
        playerVC.view.setNeedsLayout()
        playerVC.view.layoutIfNeeded()
        playerVC.view.becomeFirstResponder()

        
        // --- Custom Play Button ---
        let playButton = UIButton(type: .custom)
        let playConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let playImage = UIImage(systemName: "play.fill", withConfiguration: playConfig)
        playButton.setImage(playImage, for: .normal)
        playButton.tintColor = .white
        playButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(playButton)

        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 64),
            playButton.heightAnchor.constraint(equalToConstant: 64)
        ])
        // --- Close Button ---
        let closeButton = UIButton(type: .custom)
        let closeConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let closeImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: closeConfig)
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = .red
        closeButton.backgroundColor = .white
        closeButton.layer.cornerRadius = 15
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(closeButton)

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: container.topAnchor, constant: -5),
            closeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 5),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])

        closeButton.addTarget(self, action: #selector(closeVideo), for: .touchUpInside)
        // Center the play button
        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 50),
            playButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Add action to play the video
        if #available(iOS 14.0, *) {
            playButton.addAction(UIAction { [weak self] _ in
                guard let self = self else { return }
                self.player?.play()
                playButton.isHidden = true // Hide the button once playback starts
            }, for: .touchUpInside)
        }

        // Seek to start and pause
        player?.seek(to: .zero) { [weak self] _ in
            guard let self = self else { return }
            self.player?.pause()
            // Force controls to appear
            DispatchQueue.main.async {
                self.playerVC?.showsPlaybackControls = true
            }
        }
    }
    @objc private func closeVideo() {
        stopVideo()
        delegate?.videoPickerManagerDidCloseVideo()
    }

    func stopVideo() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil

        playerVC?.willMove(toParent: nil)
        playerVC?.view.removeFromSuperview()
        playerVC?.removeFromParent()
        playerVC = nil

        delegate?.videoPickerManagerDidCloseVideo()
    }

    private func compressVideo(inputURL: URL, completion: @escaping (URL?) -> Void) {
        let originalSize = fileSizeInMB(for: inputURL)
        print("📦 Original size: \(String(format: "%.2f", originalSize)) MB")

        if originalSize > 100 {
            DispatchQueue.main.async {
                self.alert(message: "Please select a video smaller than 100 MB.")
            }
            completion(nil)
            return
        }

        let avAsset = AVURLAsset(url: inputURL)
        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality) else {
            print("❌ Export session error")
            completion(nil)
            return
        }

        let compressedURL = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
        exportSession.outputURL = compressedURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true

        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    let size = self.fileSizeInMB(for: compressedURL)
                    print("✅ Compressed: \(compressedURL.lastPathComponent) | Size: \(String(format: "%.2f", size)) MB")
                    completion(compressedURL)
                case .failed:
                    print("❌ Compress failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                default:
                    completion(nil)
                }
            }
        }
    }

    private func fileSizeInMB(for url: URL) -> Double {
        let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey])
        return resourceValues?.fileSize.map { Double($0) / (1024 * 1024) } ?? 0.0
    }

    private func alert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "⚠️", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.presenter?.present(alert, animated: true)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate for iOS 13 and below
extension VideoPickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let videoURL = info[.mediaURL] as? URL else { return }

//        compressVideo(inputURL: videoURL) { [weak self] compressedURL in
//            guard let self = self, let compressedURL = compressedURL else { return }

            DispatchQueue.main.async {
                self.delegate?.videoPickerManager(didPickVideo: videoURL)
            }
//        }
    }
}

// MARK: - PHPickerViewControllerDelegate for iOS 14+
@available(iOS 14, *)
extension VideoPickerManager: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider,
              itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) else {
            delegate?.videoPickerManagerDidCloseVideo()
            return
        }

        itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
            guard let self = self, let url = url else {
                print("❌ Couldn't load file")
                return
            }

            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
            do {
                try FileManager.default.copyItem(at: url, to: tempURL)
            } catch {
                print("❌ File copy error: \(error)")
                return
            }

//            self.compressVideo(inputURL: tempURL) { compressedURL in
//                guard let compressedURL = compressedURL else { return }
                DispatchQueue.main.async {
                    self.delegate?.videoPickerManager(didPickVideo: tempURL)
                }
//            }
        }
    }
}
