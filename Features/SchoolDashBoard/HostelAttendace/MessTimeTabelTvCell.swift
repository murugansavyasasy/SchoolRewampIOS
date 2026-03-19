//
//  MessTimeTabelTvCell.swift
//  School Chimes
//
//  Created by apple on 05/03/26.
//

import UIKit

class MessTimeTabelTvCell: UITableViewCell {

    @IBOutlet weak var dinnerDotView: UIView!
    @IBOutlet weak var breakDotView: UIView!
    @IBOutlet weak var lunchDotView: UIView!
    @IBOutlet weak var breakFirstDotView: UIView!
    @IBOutlet weak var fullview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dinnerDotView.layer.cornerRadius = 15
        breakDotView.layer.cornerRadius = 15
        lunchDotView.layer.cornerRadius = 15
        breakFirstDotView.layer.cornerRadius = 15
        fullview.layer.borderWidth = 0.5
        fullview.layer.borderColor = UIColor.lightGray.cgColor
        fullview.layer.cornerRadius = 10
    }

}
