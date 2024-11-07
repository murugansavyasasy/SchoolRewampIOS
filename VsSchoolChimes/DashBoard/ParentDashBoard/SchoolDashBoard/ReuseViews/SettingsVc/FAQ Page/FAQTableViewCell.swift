//
//  FAQTableViewCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 05/11/24.
//

import UIKit

class FAQTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        textField.isHidden = true
        //stackview.isHidden = true
        
        textField.text = "Write here!"
        textField.textColor = UIColor.lightGray
        textField.isScrollEnabled = false
        textField.delegate = self
        
        //cellView.layer.cornerRadius = 15
        cellView.layer.cornerRadius = 10
        //cellview.layer.masksToBounds = true
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellView.layer.shadowRadius = 3
        cellView.layer.masksToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.black
            }
    }
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textField.text.isEmpty {
            textField.text = "Write here!"
            textField.textColor = UIColor.lightGray
        }
    }
}
