//
//  MarkAtendenceTV.swift
//  VsSchoolChimes
//
//  Created by admin on 26/12/24.
//

import UIKit

class MarkAtendenceTV: UITableViewCell {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var addmisionLbl: UILabel!
    @IBOutlet weak var rollNoLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var stsBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        uiConfi()
    }
    func uiConfi(){
        // Configure btnView
        btnView.layer.cornerRadius = 10
        btnView.layer.shadowColor = UIColor.black.cgColor
        btnView.layer.shadowOffset = CGSize(width: 0, height: 2)
        btnView.layer.shadowRadius = 5
        btnView.layer.shadowOpacity = 0.3
        
        // Configure stsBtn
        stsBtn.layer.cornerRadius = 10
        stsBtn.layer.shadowColor = UIColor.black.cgColor
        stsBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        stsBtn.layer.shadowRadius = 5
        stsBtn.layer.shadowOpacity = 0.3
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
    }
    @IBAction func attendence(_ sender: UIButton) {
        sender.isSelected.toggle()
        let name = sender.isSelected ? "Absent" : "Present"
        stsBtn.setTitle(name, for: .normal)
        
        // Change btnView background color based on selection
        btnView.backgroundColor = !sender.isSelected ? UIColor.red : Colornames.AprovedClr
        
        // Pop Animation
        UIView.animate(withDuration: 0.1,
                       animations: {
            self.btnView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) // Slightly enlarge
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.btnView.transform = CGAffineTransform.identity // Back to original size
            }
        })
        
    }
}
