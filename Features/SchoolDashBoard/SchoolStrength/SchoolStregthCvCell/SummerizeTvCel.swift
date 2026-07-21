//
//  SummerizeTvCel.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 14/10/25.
//

import UIKit

class SummerizeTvCel: UITableViewCell {

    @IBOutlet weak var cv: UICollectionView!
    var dispalyArray : [StrengthDisplayModel] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
        cv.register(UINib(nibName: "SchoolStrengthCvcell", bundle: nil), forCellWithReuseIdentifier: "SchoolStrengthCvcell")
        cv.delegate = self
        cv.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
extension SummerizeTvCel : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dispalyArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SchoolStrengthCvcell",
            for: indexPath
        ) as? SchoolStrengthCvcell else {
            return UICollectionViewCell()
        }

        // MARK: - Gradient Background
        if #available(iOS 15.0, *) {
            let gradientSets: [[CGColor]] = [
                [UIColor.orangeee.cgColor, UIColor.white.withAlphaComponent(0.5).cgColor],
                [UIColor.purplee.cgColor, UIColor.white.withAlphaComponent(0.5).cgColor],
                [UIColor.ligthGree.cgColor, UIColor.white.withAlphaComponent(0.5).cgColor],
                [UIColor.systemGreen.cgColor, UIColor.systemMint.cgColor],
                [UIColor.systemIndigo.cgColor, UIColor.systemBlue.cgColor]
            ]
            let gradientColors = gradientSets[indexPath.row % gradientSets.count]
            cell.applyGradient(with: gradientColors)
            cell.fullview.layoutIfNeeded()
        }

        // MARK: - Common Setup
        let item = dispalyArray[indexPath.row]
        cell.roles.text = item.name.translated()
        cell.updateProgress(male: item.boys, female: item.Girl, others: item.others, name: item.name)
        cell.OverAllcountLbl.text = "\(item.Total)"
        
        // MARK: - Role-based Setup
        
            switch item.name {
            case "Staff".translated():
                configureCell(cell, icon: "teachers", tint: .aproved,
                              progressTint: .maleClr, trackTint: .femaleClr,
                              present: item.Total, previous: item.previousYear,girls: item.Girl,boys: item.boys, message: item.message)
                
                cell.girlCount.isHidden = false
                cell.boyCountLbl.textColor = .systemBlue
                cell.girlCount.textColor = .systemPink
                cell.othersCountLbl.textColor = .systemGray
                cell.boyCountLbl.text = "Male".translated() + ":" + String(item.boys)
                cell.girlCount.text = "Female".translated() + ":" + String(item.Girl)
                cell.othersCountLbl.text = "Others".translated() + ":" + String(item.others)
                cell.progress.segment1Color = UIColor(hex: "#3D82ED")
                cell.progress.segment2Color = UIColor(hex: "#FF93C0")
               
            case "Students".translated():
                configureCell(cell, icon: "person.2.fill", tint: .link.withAlphaComponent(0.5),
                              progressTint: .maleClr, trackTint: .femaleClr,
                              present: item.Total, previous: item.previousYear,girls: item.Girl,boys: item.boys,message: item.message)
                
                cell.girlCount.isHidden = false
                cell.boyCountLbl.textColor = .systemBlue
                cell.girlCount.textColor = .femaleClr
                cell.othersCountLbl.textColor = .lightGray
                cell.boyCountLbl.text = "Boys".translated() + ":" + String(item.boys)
                cell.girlCount.text = "Girls".translated() + ":" + String(item.Girl)
                cell.othersCountLbl.text = "Others".translated() + ":" + String(item.others)
                cell.progress.segment1Color = UIColor(hex: "#3D82ED")
                cell.progress.segment2Color = UIColor(hex: "#FF93C0")
               
            case "Total".translated():
                configureCell(cell, icon: "School Needs", tint: .button,
                              progressTint: .aproved.withAlphaComponent(0.7),
                              trackTint: .primery.withAlphaComponent(0.7),
                              present: item.Total, previous: item.previousYear,girls: item.boys,boys: item.Girl,message: item.message)
                
                cell.girlCount.isHidden = true
                cell.boyCountLbl.textColor = .aproved
                cell.othersCountLbl.textColor = .systemBlue
                cell.boyCountLbl.text = "Staffs".translated() + ":" + String(item.boys)
                cell.othersCountLbl.text = "Students".translated() + ":" + String(item.Girl)
                cell.progress.segment1Color = .aproved.withAlphaComponent(0.7)
                cell.progress.segment2Color = UIColor(hex: "#3D82ED")
                
                
                
            default:
                break
            
        }
        return cell
    }

    private func configureCell(
        _ cell: SchoolStrengthCvcell,
        icon: String,
        tint: UIColor,
        progressTint: UIColor,
        trackTint: UIColor,
        present: Int,
        previous: Int,
        girls: Int,
        boys: Int,
        message : String
    ) {
        cell.Icons.image = UIImage(named: icon) ?? UIImage(systemName: icon)
        cell.Icons.tintColor = tint
        cell.progressbar.progressTintColor = progressTint
        cell.progressbar.trackTintColor = trackTint
        
        // MARK: - Year Comparison Logic
        cell.lastYearLbl.text =  message
        cell.arrowImage.isHidden = true
        if message == "" {
            cell.arrowImage.isHidden = false
            if present > previous {
                let diff = present - previous
                let lastYear = "from last year".translated()
                cell.lastYearLbl.text = " +\(diff) \(lastYear)"
                cell.lastYearLbl.textColor = .aproved
                cell.arrowImage.image = UIImage(systemName: "arrow.up.circle.fill")
                cell.arrowImage.tintColor = .aproved
            } else if present == previous {
                cell.lastYearLbl.text = "No change from last year".translated()
                cell.lastYearLbl.textColor = .systemGray
//                cell.arrowImage.image = UIImage(named: "slachImg")
                cell.arrowImage.isHidden = true
                cell.arrowImage.tintColor = .black
            } else {
                let diff = previous - present
                let lastYear = "from last year".translated()
                cell.lastYearLbl.text = " -\(diff) \(lastYear)"
                cell.lastYearLbl.textColor = .red1
                cell.arrowImage.image = UIImage(systemName: "arrow.down.circle.fill")
                cell.arrowImage.tintColor = .red1
            }
            
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 220, height: 150)
    }
    
}
