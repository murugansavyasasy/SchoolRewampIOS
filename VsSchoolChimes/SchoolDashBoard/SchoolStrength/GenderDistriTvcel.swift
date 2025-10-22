//
//  GenderDistriTvcel.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 14/10/25.
//

import UIKit

class GenderDistriTvcel: UITableViewCell {

    @IBOutlet weak var otherLbl: UILabel!
    @IBOutlet weak var girlsLbl: UILabel!
    @IBOutlet weak var boysLbl: UILabel!
    @IBOutlet weak var boysProgress: UIProgressView!
    var  totalBoys : String?
    var totalGirls : String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        boysProgress.layer.cornerRadius = 8
        boysProgress.clipsToBounds = true
        
        boysProgress.layer.sublayers?.forEach { layer in
            layer.cornerRadius = 8
            layer.masksToBounds = true
        }
        
        
    }
    
    
    func updateGenderLabels(boys:String,girls:String) {
        let boys = Int(boys) ?? 0
        let girls = Int(girls) ?? 0
        let total = boys + girls

        print("total",total)
        guard total > 0 else {
            boysLbl.text = "No Data"
            girlsLbl.text = "No Data"
            return
        }

        let boysPercentage = (Double(boys) / Double(total)) * 100
        let girlsPercentage = (Double(girls) / Double(total)) * 100

        boysLbl.text = "\(boys) Staffs (\(String(format: "%.1f", boysPercentage))%)"
        girlsLbl.text = "\(girls) Students (\(String(format: "%.1f", girlsPercentage))%)"
    }
   
    func updateProgress(absentees: String, total: String) {
        // String → Float convert
        let absentCount = Float(absentees) ?? 0
        let totalCount = Float(total) ?? 1  // avoid divide by zero
        
        let progressValue = absentCount / totalCount
        
        boysProgress.setProgress(progressValue, animated: true)   // 0.0 to 1.0
        
        updateGenderLabels(boys:total,girls:absentees)
    }


    
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
