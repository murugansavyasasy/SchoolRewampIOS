//
//  LSRWProgresCVC.swift
//  School Chimes
//
//  Created by Chandhru on 30/06/25.
//

import UIKit

class LSRWProgresCVC: UICollectionViewCell {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLevel: UILabel!
    @IBOutlet weak var skillNameLbl: UILabel!
    @IBOutlet weak var iconImg: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyShadowAndCornerRadius(to: outerView)
    }
    func configure(with model: SkillModel) {
        skillNameLbl.text = model.title
        progressLevel.text = "\(model.level) - \(model.progress)%"
        progressView.progress = Float(model.progress) / 100.0
        iconImg.setImage( model.icon, for: .normal)
        iconImg.tintColor = .white
        iconImg.layer.cornerRadius = 8
        iconImg.backgroundColor = model.iconColor
    }
}
