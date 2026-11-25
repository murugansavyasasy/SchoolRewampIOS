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
        
        let alert = UIAlertController(title: title.translated(), message: message.translated(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".translated(), style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    func showAlertCancel(title: String, message: String, actionLbl1: String, actionLbl2: String, on viewController: UIViewController, onOk: @escaping () -> Void, onNo: @escaping () -> Void) {
        let alert = UIAlertController(title: title.translated(), message: message.translated(), preferredStyle: .alert)
        
        // OK button
        let okAction = UIAlertAction(title: actionLbl1.translated(), style: .default) { _ in
            onOk()
        }
        alert.addAction(okAction)
        
        // No button
        let noAction = UIAlertAction(title: actionLbl2.translated(), style: .cancel) { _ in
            onNo()
        }
        alert.addAction(noAction)
        
        // Present the alert
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    /// Confirmation alert that carries an opt-in toggle below the message.
    /// The warning text appears at the bottom of the popup while the toggle is on. The confirm
    /// button stays available whether the toggle is on or off.
    /// - Parameter onOk: receives the toggle state (`true` when the user enabled it).
    func showAlertCancelWithToggle(
        title: String,
        message: String,
        toggleText: String,
        warningText: String,
        actionLbl1: String,
        actionLbl2: String,
        on viewController: UIViewController,
        onOk: @escaping (Bool) -> Void,
        onNo: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title.translated(), message: message.translated(), preferredStyle: .alert)
        
        let contentVC = ToggleConsentViewController(
            toggleText: toggleText.translated(),
            warningText: warningText.translated()
        )
        alert.setValue(contentVC, forKey: "contentViewController")
        
        let okAction = UIAlertAction(title: actionLbl1.translated(), style: .default) { _ in
            onOk(contentVC.isToggleOn)
        }
        alert.addAction(okAction)

        let noAction = UIAlertAction(title: actionLbl2.translated(), style: .cancel) { _ in
            onNo()
        }
        alert.addAction(noAction)

        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func showAlertWithOkAction(title: String, message: String, on viewController: UIViewController, okAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title.translated(), message: message.translated(), preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK".translated(), style: .default) { _ in
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

/// Content shown inside `CustomAlert.showAlertCancelWithToggle`: a consent switch with a warning
/// that slides in underneath it once the switch is turned on.
private final class ToggleConsentViewController: UIViewController {

    private let toggleText: String
    private let warningText: String
    private let defaultWidth: CGFloat = 250
    /// Side inset that lines the toggle row up with the alert's own title and message labels
    private let horizontalInset: CGFloat = 24
    
    private let stackView = UIStackView()
    private let warningLabel = UILabel()
    private let toggle = UISwitch()

    /// Current state of the consent switch.
    var isToggleOn: Bool { toggle.isOn }

    init(toggleText: String, warningText: String) {
        self.toggleText = toggleText
        self.warningText = warningText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toggleLabel = UILabel()
        toggleLabel.text = toggleText
        toggleLabel.numberOfLines = 0
        toggleLabel.font = .systemFont(ofSize: 13)
        toggleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        toggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        toggle.setContentCompressionResistancePriority(.required, for: .horizontal)
        toggle.addTarget(self, action: #selector(toggleChanged(_:)), for: .valueChanged)
        
        let toggleRow = UIStackView(arrangedSubviews: [toggleLabel, toggle])
        toggleRow.axis = .horizontal
        toggleRow.alignment = .center
        toggleRow.spacing = 8
        
        warningLabel.text = warningText
        warningLabel.numberOfLines = 0
        warningLabel.font = .systemFont(ofSize: 12)
        warningLabel.textColor = .systemRed
        warningLabel.isHidden = true
        warningLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(toggleRow)
        stackView.addArrangedSubview(warningLabel)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalInset),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalInset)
        ])
        
        updatePreferredContentSize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreferredContentSize()
    }
    
    @objc private func toggleChanged(_ sender: UISwitch) {
        warningLabel.isHidden = !sender.isOn
        UIView.animate(withDuration: 0.2) {
            self.updatePreferredContentSize()
            self.view.layoutIfNeeded()
        }
    }
    
    private func updatePreferredContentSize() {
        let width = view.bounds.width > 0 ? view.bounds.width : defaultWidth
        let height = stackView.systemLayoutSizeFitting(
            CGSize(width: max(width - (horizontalInset * 2), 0), height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        
        // Guard against the layout pass that setting this value triggers
        guard abs(preferredContentSize.height - height) > 0.5 else { return }
        preferredContentSize = CGSize(width: width, height: height)
    }
}
