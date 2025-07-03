//
//  ChatTVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 16/12/24.
//

import UIKit
protocol ChatTableViewCellDelegate: AnyObject {
    func didSlideToReply(for message: String)
}
class ChatTVCell: UITableViewCell {

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
       
       func configure(with message: String, timeStamp: String, isSender: Bool) {
           messageLabel.text = message
           
           if isSender {
               bubbleView.backgroundColor = .gradient1
               bubbleView.layer.shadowOpacity = 2
               bubbleView.layer.shadowColor = UIColor.systemGray3.cgColor
               bubbleView.layer.shadowRadius = 1
               bubbleView.layer.shadowOffset = .init(width: 2.0, height: 2.0)
               bubbleTrailingConstraint.constant = 16
               bubbleLeadingConstraint.constant = 100
           } else {
               bubbleView.backgroundColor = .topBackgroundCLr
               bubbleView.layer.shadowOpacity = 2
               bubbleView.layer.shadowColor = UIColor.systemGray3.cgColor
               bubbleView.layer.shadowRadius = 1
               bubbleView.layer.shadowOffset = .init(width: 2.0, height: 2.0)
               bubbleTrailingConstraint.constant = 100
               bubbleLeadingConstraint.constant = 16
           }
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
