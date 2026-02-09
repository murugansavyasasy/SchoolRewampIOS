//
//  LSRWReportTVC.swift
//  School Chimes
//
//  Created by Chandhru on 22/08/25.
//

import UIKit


class LSRWReportTVC: UITableViewCell {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Dummy Data
    var weeklyReports:[PerformanceReport]?
    var topPerformers:[TopReport]?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PerformenceReportCVC", bundle: nil),forCellWithReuseIdentifier: "PerformenceReportCVC")
        outerView.setShadow()
    }
    func confic(weeklyReports:[PerformanceReport],topPerformers:[TopReport]){
        self.weeklyReports = weeklyReports
        self.topPerformers = topPerformers
        collectionView.reloadData()
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension LSRWReportTVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PerformenceReportCVC", for: indexPath) as? PerformenceReportCVC else {
            return UICollectionViewCell()
        }
        
        if indexPath.item == 0 {
            cell.config(title: "Weekly Report", weeklyReport: weeklyReports, topPerformance: nil)
        } else {
            cell.config(title: "Top Performance", weeklyReport: nil, topPerformance: topPerformers)
        }
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.backgroundColor = UIColor.white
        return cell
    }
    // Size
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let newWidth = collectionView.frame.width
        return CGSize(width: newWidth - 30, height: 250)
    }

}
