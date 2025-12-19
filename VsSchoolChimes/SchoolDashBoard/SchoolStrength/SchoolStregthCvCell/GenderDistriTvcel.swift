//
//  GenderDistriTvcel.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 14/10/25.
//

import UIKit

class GenderDistriTvcel: UITableViewCell {

    @IBOutlet weak var studentLbl: UILabel!
    @IBOutlet weak var staffLbl: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        progressBar.layer.cornerRadius = 8
        progressBar.clipsToBounds = true
        
        progressBar.layer.sublayers?.forEach { layer in
            layer.cornerRadius = 8
            layer.masksToBounds = true
        }
    }

    func updateProgress(studentCount: String, staffCount: String) {
        guard
            let students = Float(studentCount),
            let staff = Float(staffCount)
        else {
            progressBar.progress = 0
            return
        }

        let total = students + staff
        guard total > 0 else {
            progressBar.progress = 0
            return
        }

        let progress = staff / total
        progressBar.setProgress(progress, animated: true)
    }

    func updateLabels(staffCount: String, studentCount: String) {
        let staff = Int(staffCount) ?? 0
        let students = Int(studentCount) ?? 0
        let total = staff + students

        guard total > 0 else {
            staffLbl.text = "No Data"
            studentLbl.text = "No Data"
            return
        }

        let staffPercentage = (Double(staff) / Double(total)) * 100
        let studentPercentage = (Double(students) / Double(total)) * 100

        staffLbl.text = "\(staff) \("Staffs".translated()) (\(String(format: "%.1f", staffPercentage))%)"
        studentLbl.text = "\(students) \("Students".translated()) (\(String(format: "%.1f", studentPercentage))%)"
    }

}
