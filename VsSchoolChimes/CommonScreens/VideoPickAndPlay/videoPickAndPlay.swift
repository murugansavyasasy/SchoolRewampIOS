//
//  videoPickAndPlay.swift
//  School Chimes
//
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
            print("Photo Library is not available")
            return
        }

        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.allowsEditing = true
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
//        let closeBtn = UIImageView(image: UIImage(systemName: "xmark.circle.fill"))
//        closeBtn.tintColor = .systemRed
//        closeBtn.translatesAutoresizingMaskIntoConstraints = false
//        closeBtn.isUserInteractionEnabled = true
//        container.addSubview(closeBtn)
//
//        NSLayoutConstraint.activate([
//            closeBtn.topAnchor.constraint(equalTo: container.topAnchor, constant: -14),
//            closeBtn.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 8),
//            closeBtn.widthAnchor.constraint(equalToConstant: 30),
//            closeBtn.heightAnchor.constraint(equalToConstant: 30)
//        ])
//
//        closeBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeVideo)))
    }

    func stopVideo() {
        player?.pause()
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
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
            let image = UIImage(cgImage: cgImage)
            delegate?.videoPickerManager(didGenerateThumbnail: image)
        } catch {
            print("Error generating thumbnail: \(error)")
        }
    }
}

extension VideoPickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let videoURL = info[.mediaURL] as? URL {
            delegate?.videoPickerManager(didPickVideo: videoURL)
            generateThumbnail(from: videoURL)
            user_inputs.selectedFileType = AttachmentTypeString.VIDEO
        }
    }
}
