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
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.isHidden = true
        webView.layer.cornerRadius = 8
        webView.clipsToBounds = true
        webView.scrollView.isScrollEnabled = true
        return webView
    }()
    
    lazy var titleLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var descriptionLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var dateLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var timeLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var senderInfoLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        [imageView, webView, titleLbl, descriptionLbl, dateLbl, timeLbl, senderInfoLbl].forEach {
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 180),
            
            webView.topAnchor.constraint(equalTo: contentView.topAnchor),
            webView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            webView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            webView.heightAnchor.constraint(equalToConstant: 180),
            
            titleLbl.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.padding),
            titleLbl.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            descriptionLbl.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: Constants.padding),
            descriptionLbl.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            descriptionLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            dateLbl.topAnchor.constraint(equalTo: descriptionLbl.bottomAnchor, constant: Constants.padding),
            dateLbl.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            dateLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            timeLbl.topAnchor.constraint(equalTo: dateLbl.bottomAnchor, constant: Constants.padding),
            timeLbl.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            timeLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
            senderInfoLbl.topAnchor.constraint(equalTo: timeLbl.bottomAnchor, constant: Constants.padding),
            senderInfoLbl.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            senderInfoLbl.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            senderInfoLbl.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with type: String, urlString: String) {
        // Reset both views
        imageView.isHidden = true
        webView.isHidden = true
        
        guard let url = URL(string: urlString) else { return }
        
        if type.lowercased() == "image" {
            imageView.isHidden = false
            loadImage(from: url)
        } else if type.lowercased() == "DOCUMENT" {
            webView.isHidden = false
            webView.load(URLRequest(url: url))
        }
    }
    
    private func loadImage(from url: URL) {
        // A basic example using URLSession (you can use SDWebImage or Kingfisher instead)
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
