//
//  scetionCvcell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 16/09/25.
//

import UIKit

class scetionCvcell: UICollectionViewCell {

    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var absentFullview: UIView!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var absentCountLbl: UILabel!
    @IBOutlet weak var standardLbl: UILabel!
    @IBOutlet weak var sectionLbl: UILabel!
    
//    override var isSelected: Bool {
//        didSet {
//            if isSelected {
//                fullview.backgroundColor = .primery
//                fullview.layer.cornerRadius = 10
//               absentFullview.layer.cornerRadius = 5
//                standardLbl.textColor = .white
//                sectionLbl.textAlignment = .center
//                standardLbl.textAlignment = .center
//                absentCountLbl.textAlignment = .center
//                progress.isHidden = false
//                updateProgress(absentees: "", total: "")
//                sectionLbl.textColor = .white
//                absentCountLbl.textColor = .primery
//                absentFullview.backgroundColor = .attendence
//            } else {
//                
//                fullview.backgroundColor = .systemGray6
//                fullview.layer.cornerRadius = 10
//                progress.isHidden = true
//                sectionLbl.textAlignment = .left
//                standardLbl.textAlignment = .left
//                absentCountLbl.textAlignment = .left
//                standardLbl.textColor = .black
//                sectionLbl.textColor = .black
//                absentCountLbl.textColor = .black
//                absentFullview.backgroundColor = .clear
//            }
//        }
//    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func updateProgress(absentees: String, total: String) {
        // String → Float convert
        let absentCount = Float(absentees) ?? 0
        let totalCount = Float(total) ?? 1  // avoid divide by zero
        
        let progressValue = absentCount / totalCount
        
        progress.setProgress(progressValue, animated: true)   // 0.0 to 1.0 range
        
        
        // Optional: progress color change
//        progress.progressTintColor = 
//        progress.trackTintColor = .systemGreen
    }

}
