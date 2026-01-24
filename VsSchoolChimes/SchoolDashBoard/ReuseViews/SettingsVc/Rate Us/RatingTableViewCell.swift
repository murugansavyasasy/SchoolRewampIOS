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
    weak var RatingDelegate: RatingDelegate?
    var categorySections: [CategoriesSection]?
    private var currentRating = 0

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        RatingValue.setTitleFont(style: .body, size: 14)
        RatingValue.layer.borderWidth = 1
        RatingValue.layer.borderColor = UIColor.orange.cgColor
        RatingValue.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        setupGesture()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        RatingValue.layer.cornerRadius = RatingValue.frame.height / 2
    }

    // MARK: - IBActions
    @IBAction func later(_ sender: UIButton) {
        let title = sender.titleLabel?.text?.lowercased() ?? ""
        if title.contains("later") {
            delegate?.didTapLaterButton()
        }
    }

    @IBAction func rating(_ sender: UIButton) {
        updateRating(sender.tag + 1)
    }
}


// MARK: - Gesture Handling
extension RatingTableViewCell {

    func setupGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        ratingSwipView.isUserInteractionEnabled = true
        ratingSwipView.addGestureRecognizer(panGesture)
    }

    @objc private func handleSwipeGesture(_ gesture: UIPanGestureRecognizer) {

        let width = ratingSwipView.frame.width
        guard width > 0 else { return }

        let location = gesture.location(in: ratingSwipView)
        let widthPerStar = width / CGFloat(groupButtons.count)

        var newRating = Int(location.x / widthPerStar) + 1
        newRating = min(max(newRating, 1), 5)

        if gesture.state == .changed || gesture.state == .ended {
            updateRating(newRating)
        }
    }
}


// MARK: - UI Update
extension RatingTableViewCell {

    func updateRating(_ value: Int) {
//        let filtered = categorySections?.filter { $0.rating == value }
        guard value != currentRating else { return }   // avoid extra animation refresh
        currentRating = value

        // Text
        let ratingText: Int?
        switch value {
        case 1: ratingText = 0
        case 2: ratingText = 1
        case 3: ratingText = 2
        case 4: ratingText = 3
        case 5: ratingText = 4
        default: ratingText = 0
        }
        
        // Update label/button
        RatingValue.setTitle(categorySections?[ratingText ?? 0].value ?? "", for: .normal)
        HowSatisfiedLbl.text = categorySections?[ratingText ?? 0].name ?? ""
        RatingValue.tintColor = .systemOrange
        RatingValue.layer.borderColor = UIColor.clear.cgColor
        // Stars
        for (index, button) in groupButtons.enumerated() {

            let isSelected = index < value
            let img = isSelected ? ImageName.unnamed : ImageName.unnamed2

            button.setImage(img, for: .normal)
            button.tintColor = isSelected ? .systemYellow : .systemGray3

            if index == value - 1 {
                button.transform = .identity
                UIView.animate(withDuration: 0.15,
                               delay: 0,
                               options: [.curveEaseOut],
                               animations: {
                    button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }, completion: { _ in
                    button.transform = .identity
                })
            }
        }

        // Notify parent
        RatingDelegate?.rating(value)
    }
}
