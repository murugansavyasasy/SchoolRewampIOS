//
//  CreatedSlotsTv.swift
//  School Chimes
//
//  Created by Lakshmanan on 21/08/25.
//

import UIKit

class CreatedSlotsTv: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    var slots: [Slot] = [] {
        didSet {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            collectionViewHeightConstraint.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
            
            // 👇 Important: Notify UITableView to recalc height
            if let tableView = self.superview as? UITableView {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: "SlotCV", bundle: nil), forCellWithReuseIdentifier: "SlotCV")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
    }

    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlotCV", for: indexPath) as! SlotCV
        let slot = slots[indexPath.item]
        
        // ✅ Show from - to time
        cell.label.text = "\(slot.slot_from ?? "") - \(slot.slot_to ?? "")"
        
        return cell
    }
    
    // MARK: - Layout for 3 per row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
            let itemsPerRow: CGFloat = 2
            let padding: CGFloat = 10
            
            let totalPadding = padding * (itemsPerRow - 1)
            let availableWidth = collectionView.frame.width - totalPadding
            let itemWidth = availableWidth / itemsPerRow
            
            return CGSize(width: itemWidth, height: 50)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
