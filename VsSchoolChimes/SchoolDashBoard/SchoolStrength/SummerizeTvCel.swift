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
        cv.reloadData()
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
        cell.OverAllcountLbl.text = "\(item.count)"
        cell.roles.text = item.name
        cell.updateProgress(absentees: String(item.Girl), total: String(item.count))

        // MARK: - Role-based Setup
        switch item.name {
        case "Staff":
            configureCell(cell, icon: "teachers", tint: .aproved,
                          maleLabel: "Male", femaleLabel: "Female",
                          progressTint: .maleClr, trackTint: .femaleClr,
                          present: item.count, previous: item.previousYear)

        case "Students":
            configureCell(cell, icon: "person.2.fill", tint: .link.withAlphaComponent(0.5),
                          maleLabel: "Boys", femaleLabel: "Girls",
                          progressTint: .maleClr, trackTint: .femaleClr,
                          present: item.count, previous: item.previousYear)

        case "Total":
            configureCell(cell, icon: "School Needs", tint: .button,
                          maleLabel: "Staffs", femaleLabel: "Students",
                          progressTint: .aproved.withAlphaComponent(0.7),
                          trackTint: .primery.withAlphaComponent(0.7),
                          present: item.count, previous: item.previousYear)

        default:
            break
        }

        return cell
    }

    private func configureCell(
        _ cell: SchoolStrengthCvcell,
        icon: String,
        tint: UIColor,
        maleLabel: String,
        femaleLabel: String,
        progressTint: UIColor,
        trackTint: UIColor,
        present: Int,
        previous: Int
    ) {
        cell.Icons.image = UIImage(named: icon) ?? UIImage(systemName: icon)
        cell.Icons.tintColor = tint
        cell.progressbar.progressTintColor = progressTint
        cell.progressbar.trackTintColor = trackTint

        cell.girlCount.text = "\(femaleLabel): \(present)"
        cell.boyCountLbl.text = "\(maleLabel): \(abs(present - previous))"

        // MARK: - Year Comparison Logic
        if present > previous {
            let diff = present - previous
            cell.lastYearLbl.text = " +\(diff) from last year"
            cell.lastYearLbl.textColor = .aproved
            cell.arrowImage.image = UIImage(systemName: "arrow.up.circle.fill")
            cell.arrowImage.tintColor = .aproved
        } else if present == previous {
            cell.lastYearLbl.text = " No change from last year"
            cell.lastYearLbl.textColor = .systemGray
            cell.arrowImage.image = UIImage(named: "slachImg")
            cell.arrowImage.tintColor = .black
        } else {
            let diff = previous - present
            cell.lastYearLbl.text = " -\(diff) from last year"
            cell.lastYearLbl.textColor = .red1
            cell.arrowImage.image = UIImage(systemName: "arrow.down.circle.fill")
            cell.arrowImage.tintColor = .red1
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 190, height: 150)
    }
    
}
