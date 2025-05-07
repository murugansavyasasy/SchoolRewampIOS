//
//  ImageCell.swift
//  PinterestLayoutExample
//
//  Created by Foltányi Kolos on 2020. 02. 18..
//  Copyright © 2020. Foltányi Kolos. All rights reserved.
//

import UIKit

import UIKit

class ImageCell: UICollectionViewCell {
    
    enum Constants {
        static let padding: CGFloat = 8
        static let font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var titleLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.numberOfLines = 0
        return label
    }()
    
    lazy var descriptionLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.numberOfLines = 0
        return label
    }()
    
    lazy var dateLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .darkGray
        return label
    }()
    
    lazy var timeLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .darkGray
        return label
    }()
    
    lazy var senderInfoLbl: UILabel = {
        let label = UILabel()
        label.font = Constants.font
        label.textColor = .blue
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        [imageView, titleLbl, descriptionLbl, dateLbl, timeLbl, senderInfoLbl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            
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
}
