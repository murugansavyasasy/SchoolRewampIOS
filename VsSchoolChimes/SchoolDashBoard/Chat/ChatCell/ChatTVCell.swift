//
//  ChatTVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 16/12/24.
//

import UIKit
import SDWebImage
protocol ChatTableViewCellDelegate: AnyObject {
    func didSlideToReply(for message: String)
}
class ChatTVCell: UITableViewCell {

    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var sendByStack: UIStackView!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var imageStack: UIStackView!
    @IBOutlet weak var timeStampLbl: UILabel!
    @IBOutlet weak var bubbleView: UIView!
       @IBOutlet weak var messageLabel: UILabel!
       
       @IBOutlet weak var bubbleLeadingConstraint: NSLayoutConstraint!
       @IBOutlet weak var bubbleTrailingConstraint: NSLayoutConstraint!
       
       weak var delegate: ChatTableViewCellDelegate?
       private var panGestureRecognizer: UIPanGestureRecognizer!
       private var originalCenter: CGPoint = .zero
       
       override func awakeFromNib() {
           super.awakeFromNib()
           setupGesture()
           bubbleView.layer.cornerRadius = 15
           bubbleView.clipsToBounds = true
       }
       
    
    func imageConficure(with urlString: String?) {
        if let urlString = urlString {
            imageview
                .sd_setImage(
                    with: URL(string: urlString),
                    placeholderImage: UIImage(systemName: "photo")
                )
        }
    }
    func configure(with message: String, timeStamp: String, isSender: Bool) {
        messageLabel.text = message
        timeStampLbl.text = timeStamp

        let totalLength = message.count + timeStamp.count

        // Optional: adjust based on total character count
        var leadingConstant: CGFloat = 130
        let trailingConstant: CGFloat = 16

        if totalLength <= 20 {
            leadingConstant = 200
        } else if totalLength <= 40 {
            leadingConstant = 150
        } else {
            leadingConstant = 100
        }

        if isSender {
//            cell.StatusBtn.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
            bubbleView.backgroundColor = .parentClr.withAlphaComponent(0.2)
            bubbleTrailingConstraint.constant = trailingConstant
            bubbleLeadingConstraint.constant = leadingConstant
        } else {
            bubbleView.backgroundColor = .systemGray4.withAlphaComponent(0.2)
            bubbleTrailingConstraint.constant = leadingConstant
            bubbleLeadingConstraint.constant = trailingConstant
        }

        // Common shadow styling
//        bubbleView.layer.shadowOpacity = 2
//        bubbleView.layer.shadowColor = UIColor.systemGray3.cgColor
//        bubbleView.layer.shadowRadius = 1
//        bubbleView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)

        // Only receiver (e.g. staff) allows swipe gesture
        panGestureRecognizer.isEnabled = !isSender
    }

       
       private func setupGesture() {
           panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
           bubbleView.addGestureRecognizer(panGestureRecognizer)
           bubbleView.isUserInteractionEnabled = true
       }
       
       @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
           let translation = gesture.translation(in: self.contentView)
           
           switch gesture.state {
           case .began:
               originalCenter = bubbleView.center
           case .changed:
               if translation.x > 0 { // Swiping to the right
                   bubbleView.center = CGPoint(x: originalCenter.x + translation.x, y: originalCenter.y)
               }
           case .ended:
               if translation.x > 100 { // Trigger reply when swiped enough
                   UIView.animate(withDuration: 0.2) {
                       self.bubbleView.center = self.originalCenter
                   }
                   delegate?.didSlideToReply(for: messageLabel.text ?? "")
               } else { // Revert if not enough swiped
                   UIView.animate(withDuration: 0.2) {
                       self.bubbleView.center = self.originalCenter
                   }
               }
           default:
               break
           }
       }
   }
