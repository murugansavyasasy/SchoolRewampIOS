//
//  ExamListTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 25/07/25.
//

import UIKit

class ExamListTV: UITableViewCell {

    @IBOutlet weak var viewDeatils: UIButton!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var totalMarksLbl: UILabel!
    @IBOutlet weak var DateBtn: UIButton!
    @IBOutlet weak var TimeBtn: UIButton!
 
    @IBOutlet weak var reminder: UIImageView!
    
    var indexPath: IndexPath!
    weak var delegate: ReminderCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.cornerRadius = 10
//        cellView.backgroundColor = .systemIndigo.withAlphaComponent(0.2)
       cellView.layer.cornerRadius = 12
       cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.08
        cellView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cellView.layer.shadowRadius = 8
       cellView.layer.masksToBounds = false
        SubjectLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        DateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        TimeBtn.setTitleFont(style: .body, size: FontSize.BodySize)
     
        viewDeatils.layer.cornerRadius = 10
       
//        let tap = UITapGestureRecognizer(target: self, action: #selector(AlarmAct))
//        reminder.addGestureRecognizer(tap)
//        reminder.isUserInteractionEnabled = true
    }

   
    
    @IBAction func AlarmAct(_ sender: Any) {
        
        delegate?.didTapCreateReminder(at: indexPath)
    }
    
}
