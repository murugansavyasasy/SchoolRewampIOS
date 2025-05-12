//
//  ImageCell.swift
//  PinterestLayoutExample
//
//  Created by Foltányi Kolos on 2020. 02. 18..
//  Copyright © 2020. Foltányi Kolos. All rights reserved.
//

import UIKit
import WebKit

class ImageCell: UICollectionViewCell {
    
    enum Constants {
        static let padding: CGFloat = 8
        static let font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    }

    // MARK: - UI Components
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isHidden = true
        webView.layer.cornerRadius = 8
        webView.clipsToBounds = true
        webView.scrollView.isScrollEnabled = true
        return webView
    }()
    
    private lazy var titleLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timeLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var senderInfoLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Constraints
    private var mediaHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup Layout
    
    private func setup() {
        
        contentView.addSubview(imageView)
        contentView.addSubview(webView)
        contentView.addSubview(titleLbl)
        contentView.addSubview(descriptionLbl)
        contentView.addSubview(dateLbl)
        contentView.addSubview(timeLbl)
        contentView.addSubview(senderInfoLbl)
        
        // Media (Image/WebView) Constraints
        mediaHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 180)
        mediaHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            webView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            webView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            webView.heightAnchor.constraint(equalTo: imageView.heightAnchor),
            
            titleLbl.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.padding),
            titleLbl.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.padding),
            titleLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Constants.padding),
            
            descriptionLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: Constants.padding),
            descriptionLbl.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.padding),
            descriptionLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Constants.padding),
            
            dateLbl.topAnchor.constraint(equalTo: descriptionLbl.bottomAnchor, constant: Constants.padding),
            dateLbl.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.padding),
            dateLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Constants.padding),
            
            timeLbl.topAnchor.constraint(equalTo: dateLbl.bottomAnchor, constant: Constants.padding),
            timeLbl.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.padding),
            timeLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Constants.padding),
            
            senderInfoLbl.topAnchor.constraint(equalTo: timeLbl.bottomAnchor, constant: Constants.padding),
            senderInfoLbl.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constants.padding),
            senderInfoLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Constants.padding),
            senderInfoLbl.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.padding)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with attachment: Attachment) {
        // Reset views
        imageView.isHidden = true
        webView.isHidden = true
        imageView.image = nil
        webView.load(URLRequest(url: URL(string: "about:blank")!))
        
        // Set text labels
        titleLbl.text = attachment.title
        descriptionLbl.text = attachment.description
        dateLbl.text = attachment.date
        timeLbl.text = attachment.time
        senderInfoLbl.text = attachment.sender_info
        
        guard let urlString = attachment.file_path?.first?.path,
              let url = URL(string: urlString) else {
            return
        }
        
        switch attachment.type?.uppercased() {
        case "DOCUMENT":
            webView.isHidden = false
            webView.load(URLRequest(url: url))
        default:
            imageView.isHidden = false
            loadImage(from: url)
        }
    }
    
    private func loadImage(from url: URL) {
        // A basic example using URLSession (you can use SDWebImage or Kingfisher instead)
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
                // Update media height constraint based on image aspect ratio
                if let image = self.imageView.image {
                    let aspectRatio = image.size.height / image.size.width
                    let width = self.contentView.frame.width
                    self.mediaHeightConstraint?.constant = width * aspectRatio
                }
            }
        }.resume()
    }
}
