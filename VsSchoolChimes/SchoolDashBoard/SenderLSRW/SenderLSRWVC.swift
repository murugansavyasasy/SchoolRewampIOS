//
//  SenderLSRWVC.swift
//  School Chimes
//
//  Created by Chandhru on 30/06/25.
//

import UIKit

class SenderLSRWVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var viewTaskView: UIView!
    @IBOutlet weak var submissionView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Skills Data
    let skillsArray: [SkillModel] = [
        SkillModel(title: "Listening", level: "Level 3", progress: 75, icon: UIImage(systemName: "headphones")!, iconColor: UIColor.systemRed),
        SkillModel(title: "Speaking", level: "Level 2", progress: 60, icon: UIImage(systemName: "mic.fill")!, iconColor: UIColor.systemTeal),
        SkillModel(title: "Reading", level: "Level 4", progress: 85, icon: UIImage(systemName: "book.fill")!, iconColor: UIColor.systemGreen),
        SkillModel(title: "Writing", level: "Level 3", progress: 70, icon: UIImage(systemName: "pencil.tip.crop.circle")!, iconColor: UIColor.systemPink)
    ]

    // MARK: - Activities Data
    let activitiesArray: [ActivityModel] = [
        ActivityModel(title: "Pronunciation Practice", subtitle: "Completed 2 hours ago", icon: UIImage(systemName: "target")!, iconColor: UIColor.systemPurple),
        ActivityModel(title: "Story Reading Challenge", subtitle: "Completed yesterday", icon: UIImage(systemName: "book")!, iconColor: UIColor.systemIndigo),
        ActivityModel(title: "Weekly Quiz Champion", subtitle: "Completed 3 days ago", icon: UIImage(systemName: "trophy")!, iconColor: UIColor.systemPurple)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(UINib(nibName: "LSRWProgresCVC", bundle: nil), forCellWithReuseIdentifier: "LSRWProgresCVC")
        collectionView.register(UINib(nibName: "RecentLSRWCVC", bundle: nil), forCellWithReuseIdentifier: "RecentLSRWCVC")
    }

    // MARK: - CollectionView DataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? skillsArray.count : activitiesArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LSRWProgresCVC", for: indexPath) as! LSRWProgresCVC
            let model = skillsArray[indexPath.item]
//            cell.configure(with: model)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentLSRWCVC", for: indexPath) as! RecentLSRWCVC
            let model = activitiesArray[indexPath.item]
//            cell.configure(with: model)
            return cell
        }
    }

    // MARK: - Layout (Optional)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: (collectionView.frame.width / 2) - 16, height: 100) // Example for Skill Card
        } else {
            return CGSize(width: collectionView.frame.width - 32, height: 60) // Example for Activity Row
        }
    }
}

// MARK: - Skill Model
struct SkillModel {
    let title: String
    let level: String
    let progress: Int // percentage
    let icon: UIImage
    let iconColor: UIColor
}

// MARK: - Activity Model
struct ActivityModel {
    let title: String
    let subtitle: String
    let icon: UIImage
    let iconColor: UIColor
}
