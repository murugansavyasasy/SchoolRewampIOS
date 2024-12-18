
//  FAQTableViewCell.swift
//  SchoolchimesDemo
//
//  Created by Admin on 05/11/24.
//

import UIKit

class FAQTableViewCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var QuestionLabel: UILabel!
    @IBOutlet weak var stackview: UIStackView!
    @IBOutlet weak var textview: UITextView!
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        textview.isHidden = true
        textview.text = CommonStringFile.EnterTextHere
        textview.textColor = UIColor.lightGray
        textview.isScrollEnabled = false
        textview.delegate = self
        cellView.layer.cornerRadius = Colornames.CORadius10
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellView.layer.shadowRadius = 3
        cellView.layer.masksToBounds = false
        
        QuestionLabel.setFont(style: .title, size: FontSize.TitleSize)
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
            textview.text = CommonStringFile.EnterTextHere
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
