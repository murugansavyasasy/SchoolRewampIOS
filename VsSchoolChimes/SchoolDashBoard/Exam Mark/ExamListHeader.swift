//
//  ExamListHeader.swift
//  School Chimes
//
//  Created by Lakshmanan on 24/11/25.
//

import UIKit

class ExamListHeader: UITableViewHeaderFooterView {

    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var SideColourView : UIView!

       var onTap: (() -> Void)?

       @IBAction func expandButtonTapped(_ sender: UIButton) {
           onTap?()
       }

    override func awakeFromNib() {
            super.awakeFromNib()

            setupCard()
        }
    
    private func setupCard() {
        baseView.backgroundColor = .white
        contentView.backgroundColor = .white

            baseView.layer.cornerRadius = 16
            baseView.layer.masksToBounds = false

            baseView.layer.shadowColor = UIColor.black.cgColor
            baseView.layer.shadowOpacity = 0.12
            baseView.layer.shadowOffset = CGSize(width: 0, height: 3)
            baseView.layer.shadowRadius = 6

        }
}
