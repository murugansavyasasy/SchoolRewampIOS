//
//  AddSuccessTVC.swift
//  rewardDesign
//
//  Created by admin on 19/02/25.
//

import UIKit

class AddSuccessTVC: UITableViewCell {

    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var coupenCode: UITextField!
    @IBOutlet weak var copyView: UIView!
     var borderLayer: CAShapeLayer?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupDashedBorder()
        contentLbl.text = "Let the staff scan the QR code or \n use the coupon code to claim the offer"
    }
    private func setupDashedBorder() {
            // Create border layer
            let border = CAShapeLayer()
            border.strokeColor = UIColor.systemGreen.cgColor
            border.lineDashPattern = [5, 5]
            border.fillColor = nil
            border.lineWidth = 1
            
            // Add to view
            copyView.layer.addSublayer(border)
            borderLayer = border
            
            // Round corners of the view itself
            copyView.layer.cornerRadius = 4
            copyView.layer.masksToBounds = true
            
            // Update border frame
            updateBorderLayer()
        }
        
        private func updateBorderLayer() {
            borderLayer?.frame = copyView.bounds
            borderLayer?.path = UIBezierPath(roundedRect: copyView.bounds, cornerRadius: 8).cgPath
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            updateBorderLayer()
        }

    @IBAction func copyCode(_ sender: UIButton) {
        guard let text = coupenCode.text, !text.isEmpty else { return }
        
        // Copy to clipboard
        UIPasteboard.general.string = text
        
        // Update button image with animation
        UIView.transition(with: sender, duration: 0.2, options: .transitionCrossDissolve) {
            sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
        }
        
        // Reset button image after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.transition(with: sender, duration: 0.2, options: .transitionCrossDissolve) {
                sender.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
            }
        }    }
}
