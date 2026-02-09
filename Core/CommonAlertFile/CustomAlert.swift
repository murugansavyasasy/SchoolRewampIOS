//
//  CustomAlert.swift
//  VsSchoolChimes
//
//  Created by admin on 25/10/24.
//

import Foundation
import UIKit
import WebKit

class CustomAlert{
    
    func showAlert(title: String, message: String, on viewController: UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    func showAlertCancel(title: String, message: String, actionLbl1: String, actionLbl2: String, on viewController: UIViewController, onOk: @escaping () -> Void, onNo: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OK button
        let okAction = UIAlertAction(title: actionLbl1, style: .default) { _ in
            onOk()
        }
        alert.addAction(okAction)
        
        // No button
        let noAction = UIAlertAction(title: actionLbl2, style: .cancel) { _ in
            onNo()
        }
        alert.addAction(noAction)
        
        // Present the alert
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    static func showAlertWithOkAction(title: String, message: String, on viewController: UIViewController, okAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK", style: .default) { _ in
            okAction?() // Executes the closure if provided
        }
        
        alert.addAction(okButton)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    static func showImageAlert(
        from imageUrl: String,
        message: String ,
        in viewController: UIViewController
    ) {
        guard let url = URL(string: imageUrl) else { return }
        
        let alert = UIAlertController(title: "Downloaded Image", message: message, preferredStyle: .alert)
        
        let imageVC = UIViewController()
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 🔽 SDWebImage: Load image from URL
        imageView.sd_setImage(with: url, placeholderImage: UIImage(systemName: "photo"))
        
        imageVC.view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageVC.view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageVC.view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageVC.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageVC.view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        imageVC.preferredContentSize = CGSize(width: 250, height: 200)
        alert.setValue(imageVC, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
    
    
    @available(iOS 14.0, *)
    static func showMediaAlert(
        for media: MediaPickerManager.PickedMedia,
        in viewController: UIViewController,
        onSend: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: "Preview", message: "Do you want to send this media?", preferredStyle: .alert)
        
        let contentVC = UIViewController()
        contentVC.view.translatesAutoresizingMaskIntoConstraints = false
        let height: CGFloat = 300
        
        switch media.type {
        case .image(let image):
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = image
            
            contentVC.view.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: contentVC.view.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: contentVC.view.bottomAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentVC.view.trailingAnchor),
                imageView.heightAnchor.constraint(equalToConstant: height)
            ])
            
        case .document(let url):
            let webView = WKWebView()
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.load(URLRequest(url: url))
            
            contentVC.view.addSubview(webView)
            
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: contentVC.view.topAnchor),
                webView.bottomAnchor.constraint(equalTo: contentVC.view.bottomAnchor),
                webView.leadingAnchor.constraint(equalTo: contentVC.view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: contentVC.view.trailingAnchor),
                webView.heightAnchor.constraint(equalToConstant: height)
            ])
        }
        
        contentVC.preferredContentSize = CGSize(width: 250, height: height)
        alert.setValue(contentVC, forKey: "contentViewController")
        
        // Add Cancel and Send actions
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { _ in
            onSend()
        }))
        
        viewController.present(alert, animated: true)
    }
}
