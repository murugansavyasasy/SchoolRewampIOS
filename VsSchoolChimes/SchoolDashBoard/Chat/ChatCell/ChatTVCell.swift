//
//  ChatTVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 16/12/24.
//

import UIKit
import SDWebImage
protocol ChatTableViewCellDelegate: AnyObject {
    func didSlideToReply(for message: String ,studentName : String)
}
class ChatTVCell: UITableViewCell {

    @IBOutlet weak var sendByStack: UIStackView!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var imageStack: UIStackView!
    @IBOutlet weak var timeStampLbl: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var answerBubbleView: UIView!
    @IBOutlet weak var myQuestionView: UIStackView!
    @IBOutlet weak var answerView: UIStackView!
    @IBOutlet weak var othersQuestionstack: UIStackView!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var answerLbl: UILabel!
    @IBOutlet weak var anseredOnLbl: UILabel!
    @IBOutlet weak var othersQuestionLbl: UILabel!
    @IBOutlet weak var othersQuestionView: UIView!
       weak var delegate: ChatTableViewCellDelegate?
       private var panGestureRecognizer: UIPanGestureRecognizer!
       private var originalCenter: CGPoint = .zero
    
    var studName : String?
       override func awakeFromNib() {
           super.awakeFromNib()
          // setupGesture()
           bubbleView.layer.cornerRadius = 15
           bubbleView.clipsToBounds = true
           bubbleView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.4)
           answerBubbleView.layer.cornerRadius = 15
           answerBubbleView.clipsToBounds = true
           answerBubbleView.backgroundColor = .systemGray5
           othersQuestionView.layer.cornerRadius = 10
           othersQuestionView.backgroundColor = .systemGray6
           messageLabel.setFont(style: .body, size: FontSize.BodySize)
           timeStampLbl.setFont(style: .body, size: 11)
           othersQuestionLbl.setFont(style: .body, size: 11)
           studentNameLbl.setFont(style: .body, size: 11)
           answerLbl.setFont(style: .body, size: FontSize.BodySize)
           anseredOnLbl.setFont(style: .body, size: 11)
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

    func configure(with message: String, timeStamp: String, isSender: Bool, studentName: String) {
        messageLabel.text = message
        timeStampLbl.text = timeStamp
        self.studName = studentName
        
        // Basic UI styling
        bubbleView.layer.cornerRadius = 15
//        bubbleView.clipsToBounds = true
//        
//        // Update constraints dynamically
//        if isSender {
//            // SENDER (You) -> Align Right
////            bubbleTrailingConstraint.isActive = true
////            bubbleLeadingConstraint.isActive = false
//            
//            bubbleView.backgroundColor = UIColor(named: "parentClr")?.withAlphaComponent(0.2) ?? UIColor.systemBlue.withAlphaComponent(0.2)
//            messageLabel.textColor = .black
//            sendByStack.alignment = .trailing
//        } else {
//            // RECEIVER (Others) -> Align Left
////            bubbleTrailingConstraint.isActive = false
////            bubbleLeadingConstraint.isActive = true
//            
//            bubbleView.backgroundColor = UIColor.systemGray4.withAlphaComponent(0.2)
//            messageLabel.textColor = .black
//            sendByStack.alignment = .leading
//        }
//        
//        layoutIfNeeded() // refresh layout immediately
    }

       
       private func setupGesture() {
//           panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
//           bubbleView.addGestureRecognizer(panGestureRecognizer)
//           bubbleView.isUserInteractionEnabled = true
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
                   delegate?
                       .didSlideToReply(
                        for: messageLabel.text ?? "",
                        studentName: studName ?? ""
                       )
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
