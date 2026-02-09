//
//  CaterogyCvCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 19/02/25.
//  Copyright © 2025 Gayathri. All rights reserved.
//

import UIKit


class CaterogyCvCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
       
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func configure(with category: Categorys, selected: Bool) {
           titleLabel.text = category.category_name
           iconImageView.sd_setImage(
            with: URL(string: category.category_image ?? ""),
               placeholderImage: UIImage(systemName: "photo")
           )
//        containerView.setShadow()
        containerView.layer.cornerRadius = 10
           if selected {
               titleLabel.textColor = UIColor.systemBlue
               containerView.setShadow(shadowColor: UIColor(hex: "377DF4"), shadowOpacity: 0.6, shadowOffset: CGSize(width: 0, height: 4), shadowRadius: 8)
               containerView.layer.borderColor = UIColor(hex: "377DF4").cgColor
               containerView.layer.borderWidth = 2
           } else {
               containerView.setShadow(shadowOpacity: 0)
               containerView.layer.borderColor = UIColor.clear.cgColor
               containerView.layer.borderWidth = 0
               titleLabel.textColor = UIColor.darkGray
           }
      }
   }
