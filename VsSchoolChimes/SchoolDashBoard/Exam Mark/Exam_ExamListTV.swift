//
//  Exam_ExamListTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 24/11/25.
//

import UIKit

class Exam_ExamListTV: UITableViewCell {

    
    @IBOutlet weak var ArrowBtn: UIButton!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var activitiesLbl: UILabel!
    
    var onExpand: (() -> Void)?
        var isExpanded: Bool = false {
            didSet {
                activitiesLbl.isHidden = false
                updateCollectionView()
            }
        }
    
    var items = ["Math", "English", "Computer Science", "GK"]


        override func awakeFromNib() {
            super.awakeFromNib()

            setupCollectionView()

            cv.isHidden = true
            activitiesLbl.isHidden = true
            collectionViewHeight.constant = 0
        }

    private func setupCollectionView() {
        cv.register(UINib(nibName: "ExamActivitiesCV", bundle: nil), forCellWithReuseIdentifier: "ExamActivitiesCV")
        cv.delegate = self
        cv.dataSource = self
    }

    private func updateCollectionView() {
            cv.isHidden = !isExpanded

            if isExpanded {
                // Height = (rows * itemHeight) + spacing
                let totalHeight =
                    CGFloat(items.count) * (40)   // 10 = line spacing
                collectionViewHeight.constant = totalHeight
            } else {
                collectionViewHeight.constant = 0
            }

            layoutIfNeeded()
            cv.reloadData()
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    @IBAction func expandAct(_ sender: UIButton) {
        
        onExpand?()
        
    }
    
    
}

extension Exam_ExamListTV: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count  // or dynamic count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExamActivitiesCV", for: indexPath) as! ExamActivitiesCV
        cell.nameLbl.text = items[indexPath.item]
        return cell
    }
}


extension Exam_ExamListTV: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.bounds.width, height: 40)
    }

}

