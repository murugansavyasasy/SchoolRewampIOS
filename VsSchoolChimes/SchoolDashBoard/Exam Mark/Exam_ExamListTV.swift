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
    
    var onExpand: (() -> Void)?
        let itemHeight: CGFloat = 80
        let itemsCount = 5

        var isExpanded: Bool = false {
            didSet {
                updateCollectionView()
            }
        }

        override func awakeFromNib() {
            super.awakeFromNib()

            setupCollectionView()

            cv.isHidden = true
            collectionViewHeight.constant = 0
        }

        private func setupCollectionView() {
            cv.delegate = self
            cv.dataSource = self

            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 10
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: itemHeight)
            cv.collectionViewLayout = layout
        }

        private func updateCollectionView() {
            cv.isHidden = !isExpanded

            if isExpanded {
                collectionViewHeight.constant = CGFloat(itemsCount) * (itemHeight + 10)
            } else {
                collectionViewHeight.constant = 0
            }

            layoutIfNeeded()
            cv.reloadData()
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func expandAct(_ sender: UIButton) {
        
        onExpand?()
        
    }
    
    
}

extension Exam_ExamListTV: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5  // or dynamic count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YourCollectionCell", for: indexPath)
        return cell
    }
}
