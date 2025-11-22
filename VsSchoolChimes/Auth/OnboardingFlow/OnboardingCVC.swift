//
//  OnboardingCVC.swift
//  School Chimes
//
//  Created by Chandhru on 10/11/25.
//

import UIKit

class OnboardingCVC: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupInitialState()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setupInitialState()
    }

    private func setupInitialState() {
        imgView.alpha = 0
        headingLbl.alpha = 0
        descriptionLbl.alpha = 0

        imgView.transform = CGAffineTransform(translationX: 0, y: 20)
        headingLbl.transform = CGAffineTransform(translationX: 0, y: 20)
        descriptionLbl.transform = CGAffineTransform(translationX: 0, y: 20)
    }

    func animateStepByStep() {
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut) {
            self.imgView.alpha = 1
            self.imgView.transform = .identity
        }

        UIView.animate(withDuration: 0.6, delay: 0.2, options: .curveEaseOut) {
            self.headingLbl.alpha = 1
            self.headingLbl.transform = .identity
        }

        UIView.animate(withDuration: 0.6, delay: 0.4, options: .curveEaseOut) {
            self.descriptionLbl.alpha = 1
            self.descriptionLbl.transform = .identity
        }
    }
}
