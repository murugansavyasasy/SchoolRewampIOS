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
    @IBOutlet weak var subjectNameLbl: UILabel!
    @IBOutlet weak var separatorview: UIView!
    @IBOutlet weak var subjectView: UIView!
    
    var onHeightChanged: (() -> Void)?
    var onExpand: (() -> Void)?
    private var isExpanded: Bool = false
    var Activities : [ActivityData] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        subjectNameLbl.setFont(style: .body, size: 17)
        activitiesLbl.setFont(style: .body, size: FontSize.TitleSize)
        activitiesLbl.text = ExamMarkUploadString.Activities.translated()
        
        cv.register(UINib(nibName: CellConfingName.ExamActivitiesCV, bundle: nil),forCellWithReuseIdentifier: CellConfingName.ExamActivitiesCV)
        
        subjectView.backgroundColor = .systemGray6.withAlphaComponent(0.3)
        
        let layout = LeftAlignedFlowLayout()
        layout.minimumInteritemSpacing = 0 // Customize spacing between items
        layout.minimumLineSpacing = 0 // Customize line spacing
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cv.collectionViewLayout = layout
        
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = false
        
        cv.isHidden = true
        activitiesLbl.isHidden = true
        collectionViewHeight.constant = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        configureExpansionState(false, animated: false)
    }
    
    // ⭐ FINAL FIXED VERSION
    func configureExpansionState(_ expanded: Bool, animated: Bool = true) {
        isExpanded = expanded
        ArrowBtn.setImage(UIImage(systemName: expanded ? "chevron.down" : "chevron.forward"),
                          for: .normal)
        
        activitiesLbl.isHidden = !expanded
        cv.isHidden = !expanded
        
        if expanded {
            
            cv.reloadData()
            cv.layoutIfNeeded()       // 1st pass
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.cv.layoutIfNeeded()    // 2nd pass
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.cv.layoutIfNeeded()   // FINAL 3rd pass (needed for flow layout)
                    
                    let height = self.cv.collectionViewLayout.collectionViewContentSize.height
                    print("FINAL CV HEIGHT =", height)
                    
                    if height > 0 {
                        self.collectionViewHeight.constant = height
                    }
                    
                    // ⭐ Critical: expand container cell, not only this cell
                    if animated {
                        UIView.animate(withDuration: 0.25) {
                            self.contentView.layoutIfNeeded()
                            self.superview?.layoutIfNeeded()
                            self.superview?.superview?.layoutIfNeeded()
                        }
                    } else {
                        self.contentView.layoutIfNeeded()
                        self.superview?.layoutIfNeeded()
                        self.superview?.superview?.layoutIfNeeded()
                    }
                    
                    self.onHeightChanged?()
                    
                    if let parentTable = self.superview as? UITableView {
                        parentTable.beginUpdates()
                        parentTable.endUpdates()
                    }
                    
                }
            }
            
        } else {
            collectionViewHeight.constant = 0
            
            if animated {
                UIView.animate(withDuration: 0.25) {
                    self.contentView.layoutIfNeeded()
                    self.superview?.layoutIfNeeded()
                    self.superview?.superview?.layoutIfNeeded()
                }
            } else {
                self.contentView.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
                self.superview?.superview?.layoutIfNeeded()
            }
            
            onHeightChanged?()
        }
    }
    
    @IBAction func expandAct(_ sender: UIButton) {
        onExpand?()
    }
}

extension Exam_ExamListTV: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Activities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.ExamActivitiesCV,for: indexPath) as! ExamActivitiesCV
        
        cell.nameLbl.text = Activities[indexPath.item].activity_name
        return cell
    }
}

extension Exam_ExamListTV: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let text = Activities[indexPath.item].activity_name ?? ""  // your data source
        
        let font = UIFont.systemFont(ofSize: 17)
        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
        let horizontalPadding: CGFloat = 30
        
        let label = UILabel()
        label.font = font
        label.text = text
        label.sizeToFit()
        
        let width = label.frame.width + 40
        
        let finalWidth = textWidth + horizontalPadding
        
        return CGSize(width: width, height: 50)
    }
    
}
