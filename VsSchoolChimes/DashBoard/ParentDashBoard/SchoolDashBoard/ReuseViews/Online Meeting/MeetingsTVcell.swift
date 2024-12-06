//
//  MeetingsTVcell.swift
//  VsSchoolChimes
//
//  Created by Admin on 05/12/24.
//

import UIKit

protocol ReminderCellDelegate: AnyObject {
    func didTapCreateReminder(at indexPath: IndexPath)
}

class MeetingsTVcell: UITableViewCell {

    @IBOutlet weak var cellview: UIView!
    
    @IBOutlet weak var contentview: UIView!
    
    @IBOutlet weak var DateTimeLbl: UILabel!
    
    @IBOutlet weak var TitleLbl: UILabel!
    
    @IBOutlet weak var DescriptLbl: UILabel!
    
    @IBOutlet weak var reminder: UIImageView!
    @IBOutlet weak var LinkLbl: UILabel!
    @IBOutlet weak var MeetingTypeLbl: UILabel!
    
    weak var delegate: ReminderCellDelegate?
    var indexPath: IndexPath!
    
    private var gradientLayer: CAGradientLayer?
    private var gradientColors: [CGColor] = []

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellview.layer.cornerRadius = 7
        cellview.layer.masksToBounds = true
        cellview.layer.shadowColor = UIColor.black.cgColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSize(width: 4, height: 4)
        cellview.layer.shadowRadius = 3
        
        DateTimeLbl.setFont(style: .body, size: FontSize.BodySize)
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        DescriptLbl.setFont(style: .title, size: FontSize.TitleSize)
        MeetingTypeLbl.setFont(style: .body, size: FontSize.BodySize)
        LinkLbl.setFont(style: .body, size: FontSize.BodySize)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AlarmAct))
        reminder.addGestureRecognizer(tap)
        reminder.isUserInteractionEnabled = true
        
       // setupPopUpButton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func setupPopUpButton() {
//            // Rounded corners
//        alarmBtn.layer.cornerRadius = 10
//        alarmBtn.setTitle("", for: .normal)
//
//            // Shadow to make it look raised
//        alarmBtn.layer.shadowColor = UIColor.black.cgColor
//        alarmBtn.layer.shadowOffset = CGSize(width: 0, height: 5) // Adjust offset for "pop-up" effect
//        alarmBtn.layer.shadowOpacity = 0.3 // Adjust opacity
//        alarmBtn.layer.shadowRadius = 10 // Blur radius
//
//            // Optional: Border for emphasis
//        alarmBtn.layer.borderColor = UIColor.gray.cgColor
//        alarmBtn.layer.borderWidth = 1.0
//
//            // Background color
////        alarmBtn.backgroundColor = UIColor.systemBlue
////        alarmBtn.setTitleColor(.white, for: .normal)
//        }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        DispatchQueue.main.async {
//                  self.applyGradientIfNeeded()
//              }
//       // applyGradientIfNeeded()
//    }
//
//    func setGradientColors(_ colors: [CGColor]) {
//        // Store the colors so we can use them in layoutSubviews
//        gradientColors = colors
//        applyGradientIfNeeded() // Ensure the gradient is applied immediately as well
//    }
//
//    private func applyGradientIfNeeded() {
//        // Check if we already have the same gradient applied
//        guard gradientColors.isEmpty == false else { return }
//        
//        // Remove existing gradient layers if any
//        contentview.layer.sublayers?.removeAll { $0 is CAGradientLayer }
//        
//        // Create and configure the gradient layer
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = gradientColors
//        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
//        gradientLayer.frame = contentview.bounds
//        gradientLayer.cornerRadius = contentview.layer.cornerRadius
//
//        // Insert the gradient layer into the cell's view hierarchy
//        contentview.layer.insertSublayer(gradientLayer, at: 0)
//    }
    
    @IBAction func AlarmAct(_ sender: Any) {
        
        delegate?.didTapCreateReminder(at: indexPath)
    }
}
