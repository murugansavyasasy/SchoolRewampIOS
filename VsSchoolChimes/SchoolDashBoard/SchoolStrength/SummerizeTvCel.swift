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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SchoolStrengthCvcell", for: indexPath) as? SchoolStrengthCvcell else {
            return UICollectionViewCell()
        }
        if #available(iOS 15.0, *) {
            let gradientSets: [[CGColor]] = [
                [
                    UIColor.purplee.cgColor,
                    UIColor.white.withAlphaComponent(0.5).cgColor
                ],
                [
                    UIColor.ligthGree.cgColor,
                    UIColor.white.withAlphaComponent(0.5).cgColor
                ],
                [UIColor.orangeee.cgColor, UIColor.white.withAlphaComponent(0.5).cgColor],
                [UIColor.systemGreen.cgColor, UIColor.systemMint.cgColor],
                [UIColor.systemIndigo.cgColor, UIColor.systemBlue.cgColor]
            ]
            let gradientColors = gradientSets[indexPath.row % gradientSets.count]
            cell.applyGradient(with: gradientColors)
            cell.fullview.layoutIfNeeded()
        }
        
        cell.OverAllcountLbl.text = "\(dispalyArray[indexPath.row].count)"
        cell.roles.text = dispalyArray[indexPath.row].name
        cell.girlCount.text =  "girls " +  String(dispalyArray[indexPath.row].Girl)
        cell.boyCountLbl.text =  "Boys " +  String(
              dispalyArray[indexPath.row].count - dispalyArray[indexPath.row].Girl
        )
        
        if dispalyArray[indexPath.row].name == "Staff"{
            cell.Icons.image = UIImage(named: "teachers")
            cell.Icons.tintColor = .aproved
        }else if dispalyArray[indexPath.row].name == "Students"{
            cell.Icons.image = UIImage(
                systemName: "person.2.fill")
            cell.Icons.tintColor = .link.withAlphaComponent(0.5)
        }else if dispalyArray[indexPath.row].name == "Total"{
            cell.Icons.image = UIImage(named: "School Needs")
            cell.Icons.tintColor = .button
        }
        
        
        cell
            .updateProgress(
                absentees: String(dispalyArray[indexPath.row].Girl),
                total: String(dispalyArray[indexPath.row].count)
            )
        

        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 190, height: 150)
    }
    
}
