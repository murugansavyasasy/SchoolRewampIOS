//
//  GalleryPickerVcViewController.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 22/05/25.
//

import UIKit

class GalleryPickerVcViewController: UIViewController {
    var onOptionSelected: ((String) -> Void)?
    override func viewDidLoad() {
            super.viewDidLoad()
//            setupButtons()
//            view.backgroundColor = UIColor.white
//            view.layer.cornerRadius = 12
        }

//        func setupButtons() {
//            let stackView = UIStackView()
//            stackView.axis = .vertical
//            stackView.spacing = 12
//            stackView.alignment = .leading
//
//            // Define icons and labels
//            let options: [(icon: String, title: String)] = [
//                ("camera.fill", "Camera"),
//                ("photo.fill.on.rectangle.fill", "Photo"),
//                ("mic.fill", "Voice"),
//                ("video.fill", "Video"),
//                ("doc.fill", "Document")
//            ]
//
//            for (iconName, title) in options {
//                let button = UIButton(type: .system)
//                button.setTitle("  \(title)", for: .normal)
//                button.setTitleColor(.black, for: .normal)
//                button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//
//                if let icon = UIImage(systemName: iconName) {
//                    button.setImage(icon, for: .normal)
//                    button.imageView?.tintColor = .systemBlue
//                }
//
//                button.contentHorizontalAlignment = .leading
//                button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
//                button.tag = stackView.arrangedSubviews.count
//
//                stackView.addArrangedSubview(button)
//            }
//
//            stackView.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(stackView)
//
//            NSLayoutConstraint.activate([
//                stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
//                stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
//                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
//            ])
//        }

        @objc func optionTapped(_ sender: UIButton) {
            let titles = ["Camera", "Photo", "Voice", "Video", "Document"]
            let selectedOption = titles[sender.tag]
            dismiss(animated: true) {
                self.onOptionSelected?(selectedOption)
            }
        }
    }
