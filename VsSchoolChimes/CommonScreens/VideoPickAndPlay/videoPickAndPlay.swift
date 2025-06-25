
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

    // MARK: - Play Video

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
        player?.replaceCurrentItem(with: nil)
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

    // MARK: - Compression & Thumbnail

    private func generateThumbnail(from url: URL) {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 600), actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            imageGenerator.cancelAllCGImageGeneration()
            delegate?.videoPickerManager(didGenerateThumbnail: image)
        } catch {
            print("❌ Thumbnail error: \(error)")
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
            print("❌ Export session error")
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

// MARK: - UIImagePickerControllerDelegate for iOS 13 and below

extension VideoPickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        guard let videoURL = info[.mediaURL] as? URL else { return }

        compressVideo(inputURL: videoURL) { [weak self] compressedURL in
            guard let self = self, let compressedURL = compressedURL else { return }

            DispatchQueue.main.async {
                self.delegate?.videoPickerManager(didPickVideo: compressedURL)
                self.generateThumbnail(from: compressedURL)
                user_inputs.selectedFileType = AttachmentTypeString.VIDEO
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate for iOS 14+

@available(iOS 14, *)
extension VideoPickerManager: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider,
              itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) else {
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

            self.compressVideo(inputURL: tempURL) { compressedURL in
                guard let compressedURL = compressedURL else { return }
                DispatchQueue.main.async {
                    self.delegate?.videoPickerManager(didPickVideo: compressedURL)
                    self.generateThumbnail(from: compressedURL)
                    user_inputs.selectedFileType = AttachmentTypeString.VIDEO
                }
            }
        }
    }
}
