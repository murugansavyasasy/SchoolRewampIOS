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
    }

}
