//
//  certificateReqTVCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 07/08/25.
//

import UIKit

class certificateReqTVCell: UITableViewCell {

    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var fullview: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        requestBtn.layer.cornerRadius = 10
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 5
        fullview.layer.cornerRadius = 10
//        contentView.layer.borderWidth = 1
//        contentView.layer.borderColor = UIColor.lightGray.cgColor
        fullview.backgroundColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
