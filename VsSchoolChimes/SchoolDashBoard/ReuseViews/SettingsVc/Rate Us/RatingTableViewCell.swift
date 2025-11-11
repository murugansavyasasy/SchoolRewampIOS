//
//  RatingTableViewCell.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 05/11/24.
//

import UIKit

protocol RatingCellDelegate: AnyObject {
    func didTapLaterButton()
}

class RatingTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var ratingSwipView: UIView!
    @IBOutlet weak var HowSatisfiedLbl: UILabel!
    @IBOutlet var groupButtons: [UIButton]!
    @IBOutlet weak var RatingValue: UIButton!

    // MARK: - Variables
    weak var delegate: RatingCellDelegate?
    var RatingDelegate: RatingDelegate?

    private var currentRating: Int = 0

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        HowSatisfiedLbl.setFont(style: .title, size: FontSize.TitleSize)

        RatingValue.setTitleFont(style: .body, size: 18)
        RatingValue.layer.borderWidth = 1
        RatingValue.layer.borderColor = UIColor.orange.cgColor
        RatingValue.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        setupGesture()

        /// ✅ Debugging to ensure buttons connected
        print("groupButtons count:", groupButtons.count)
    }

    /// ✅ Corner radius applied after AutoLayout
    override func layoutSubviews() {
        super.layoutSubviews()
        RatingValue.layer.cornerRadius = RatingValue.frame.height / 2
    }


    // MARK: - IBActions
    @IBAction func later(_ sender: UIButton) {
        if sender.titleLabel?.text == "Maybe later"{
            delegate?.didTapLaterButton()
        }
    }

    @IBAction func rating(_ sender: UIButton) {
        updateRating(sender.tag + 1)
    }
}


// MARK: - Swipe Gesture (Drag to Rate)
extension RatingTableViewCell {

    func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        ratingSwipView.isUserInteractionEnabled = true
        ratingSwipView.addGestureRecognizer(panGesture)
    }

    @objc private func handleSwipeGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: ratingSwipView)
        let widthPerStar = ratingSwipView.frame.width / CGFloat(groupButtons.count)
        let newRating = Int(location.x / widthPerStar) + 1

        if gesture.state == .changed || gesture.state == .ended {
            updateRating(min(max(newRating, 1), 5))
        }
    }
}


// MARK: - UI Update
extension RatingTableViewCell {

    func updateRating(_ value: Int) {
        currentRating = value

        var ratingText = ""
        var ratingColor: UIColor = .systemGray
        ratingColor = .systemOrange
        switch value {
        case 1:
            ratingText = RatingCellStringFile.Bad
        case 2:
            ratingText = RatingCellStringFile.Not_bad
        case 3:
            ratingText = RatingCellStringFile.Better
            
        case 4:
            ratingText = RatingCellStringFile.Nice
        case 5:
            ratingText = RatingCellStringFile.Good
        default:
            break
        }

        RatingValue.setTitle(ratingText, for: .normal)
        RatingValue.tintColor = ratingColor
        RatingValue.layer.borderColor = UIColor.clear.cgColor

        for (index, button) in groupButtons.enumerated() {
            button.tintColor = index < value ? .systemYellow : .systemGray4

            let img = index < value ? ImageName.unnamed : ImageName.unnamed2
            button.setImage(img, for: .normal)
            if index == value - 1 {
                UIView.animate(withDuration: 0.2) {
                    button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                } completion: { _ in
                    button.transform = .identity
                }
            }
        }

        RatingDelegate?.rating(value)
    }
}
