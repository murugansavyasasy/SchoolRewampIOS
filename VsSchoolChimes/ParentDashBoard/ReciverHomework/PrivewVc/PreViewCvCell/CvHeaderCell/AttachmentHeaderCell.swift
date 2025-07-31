//
//  AttachmentHeaderCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 29/07/25.
//

import UIKit
protocol AttachmentHeaderViewDelegate: AnyObject {
    func didTapSeeMore(in header: AttachmentHeaderCell,section : Int)
}

class AttachmentHeaderCell: UICollectionReusableView {
        
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var discreptionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    private var fullText: String = ""
     private var isExpanded = false
     weak var delegate: AttachmentHeaderViewDelegate?
    var selectedSection : Int = 0

    
    override func awakeFromNib() {
            super.awakeFromNib()
            setupGesture()
            discreptionLbl.isUserInteractionEnabled = true
        roundView.isHidden = true
        roundView.layer.cornerRadius = roundView.frame.width/2
        }

        func configure(title: String, description: String, isExpanded: Bool, date: String) {
            titleLbl.text =  title
            fullText = description
            self.isExpanded = isExpanded
            
            let displayText = formattedDateStatus(from: date)
            dateLbl.text = "🗓️" + displayText

            updateDescription()
        }

        private func setupGesture() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapDescription))
            discreptionLbl.addGestureRecognizer(tap)
        }

        @objc private func didTapDescription() {
            isExpanded.toggle()
            delegate?.didTapSeeMore(in: self, section: selectedSection)
        }


    func updateDescription() {
           
           let textToShow: String
           if isExpanded {
               textToShow = fullText + " See Less"
               discreptionLbl.numberOfLines = 0
           } else {
               textToShow = truncatedText(for: fullText) + "... See More"
               discreptionLbl.numberOfLines = 3
           }
           
           let attributedText = NSMutableAttributedString(string: textToShow)
           let actionText = isExpanded ? "See Less" : "See More"
           let range = (textToShow as NSString).range(of: actionText)
           
           attributedText.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: range)
           attributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 14), range: range)
           discreptionLbl.attributedText = attributedText
       }
    private func truncatedText(for text: String) -> String {
         let words = text.split(separator: " ")
         var truncated = ""
         let label = UILabel()
         label.font = discreptionLbl.font
         label.numberOfLines = 3
         label.lineBreakMode = .byTruncatingTail
         
         for word in words {
             let temp = truncated + " " + word
             label.text = temp
             let maxSize = CGSize(width: discreptionLbl.bounds.width, height: CGFloat.greatestFiniteMagnitude)
             let size = label.sizeThatFits(maxSize)
             if size.height > discreptionLbl.font.lineHeight * 3 {
                 break
             }
             truncated = temp
         }
         
         return truncated.trimmingCharacters(in: .whitespaces)
     }

    
    
       
    }
