//
//  FAQTableViewCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 05/11/24.
//

import UIKit

class FAQTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        textview.isHidden = true
        //stackview.isHidden = true
        
        textview.text = "Write here!"
        textview.textColor = UIColor.lightGray
        textview.isScrollEnabled = false
        textview.delegate = self
        
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
        if textview.text.isEmpty {
            textview.text = "Write here!"
            textview.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
            // Notify the tableView to adjust the cell height
            guard let tableView = self.superview as? UITableView else { return }
            
            // Disable animations for smoother resizing
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
}
