
//  videoPickAndPlay.swift
//  School Chimes
//  Created by SARANRAJ SHANMUGAM on 30/05/25.
import UIKit
import AVFoundation
import AVKit
import MobileCoreServices

protocol VideoPickerManagerDelegate: AnyObject {
    func videoPickerManager(didPickVideo url: URL)
    func videoPickerManager(didGenerateThumbnail image: UIImage)
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

    func pickVideo() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("❌ Photo Library is not available")
            return
        }

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.allowsEditing = false // ✅ Prevent memory overhead
        presenter?.present(picker, animated: true)
    }

    func playVideo(from url: URL, in container: UIView) {
        stopVideo()

        player = AVPlayer(url: url)
        playerVC = AVPlayerViewController()
        playerVC?.player = player
        playerVC?.showsPlaybackControls = true

        guard let playerVC = playerVC, let presenter = presenter else { return }

        presenter.addChild(playerVC)
        playerVC.view.frame = container.bounds
        container.addSubview(playerVC.view)
        playerVC.didMove(toParent: presenter)
        playerVC.view.layer.cornerRadius = 10
        playerVC.view.clipsToBounds = true

        player?.play()

        // Add Close Button
        let closeBtn = UIImageView(image: UIImage(systemName: "xmark.circle.fill"))
        closeBtn.tintColor = .systemRed
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.isUserInteractionEnabled = true
        container.addSubview(closeBtn)

        NSLayoutConstraint.activate([
            closeBtn.topAnchor.constraint(equalTo: container.topAnchor, constant: -14),
            closeBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 8),
            closeBtn.widthAnchor.constraint(equalToConstant: 30),
            closeBtn.heightAnchor.constraint(equalToConstant: 30)
        ])

        closeBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeVideo)))
    }

    func stopVideo() {
        player?.pause()
        player?.replaceCurrentItem(with: nil) // ✅ Avoid AVPlayer memory retention
        player = nil

        playerVC?.view.removeFromSuperview()
        playerVC?.removeFromParent()
        playerVC = nil
    }

    @objc private func closeVideo() {
        stopVideo()
        delegate?.videoPickerManagerDidCloseVideo()
    }

    func closeVideoPlayback() {
        closeVideo()
    }

    private func generateThumbnail(from url: URL) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 600), actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            imageGenerator.cancelAllCGImageGeneration() // ✅ Release memory after use
            delegate?.videoPickerManager(didGenerateThumbnail: image)
        } catch {
            print("❌ Error generating thumbnail: \(error)")
        }
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
            print("❌ Failed to create export session")
            completion(nil)
            return
        }

        let compressedURL = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".mp4")
        exportSession.outputURL = compressedURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                let compressedSize = self.fileSizeInMB(for: compressedURL)
                print("✅ Compression successful: \(compressedURL.lastPathComponent) | Size: \(String(format: "%.2f", compressedSize)) MB")
                completion(compressedURL)
            case .failed:
                print("❌ Compression failed: \(String(describing: exportSession.error))")
                completion(nil)
            case .cancelled:
                print("⚠️ Compression cancelled")
                completion(nil)
            default:
                print("ℹ️ Compression status: \(exportSession.status.rawValue)")
                completion(nil)
            }
        }
    }

    private func fileSizeInMB(for url: URL) -> Double {
        let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey])
        if let fileSize = resourceValues?.fileSize {
            return Double(fileSize) / (1024 * 1024)
        }
        return 0.0
    }

    private func alert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "⚠️", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.presenter?.present(alert, animated: true)
        }
    }
}

extension VideoPickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let videoURL = info[.mediaURL] as? URL else { return }

        // 🔄 Delay to prevent lag in UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Show loader if you have one
//            CircularProgressLoader.shared.show(message: "Compressing...")

            self.compressVideo(inputURL: videoURL) { [weak self] compressedURL in
                DispatchQueue.main.async {
                    CircularProgressLoader.shared.hide()
                }

                guard let self = self, let compressedURL = compressedURL else { return }

                DispatchQueue.main.async {
                    self.delegate?.videoPickerManager(didPickVideo: compressedURL)
                    self.generateThumbnail(from: compressedURL)
                    user_inputs.selectedFileType = AttachmentTypeString.VIDEO
                }
            }
        }
    }

}
