//
//  CreatedSlotsTv.swift
//  School Chimes
//
//  Created by Lakshmanan on 21/08/25.
//

import UIKit

class CreatedSlotsTv: UITableViewCell,
                      UICollectionViewDelegate,
                      UICollectionViewDataSource,
                      UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateBtn: UIButton!
    
    private var slots: [Slot] = []
    private weak var parentTableView: UITableView?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        dateBtn.layer.cornerRadius = 8
        
        dateBtn.backgroundColor = .blue.withAlphaComponent(0.1)
        dateBtn.setTitleColor(.blue, for: .normal)
        dateBtn.tintColor = .blue
        
        collectionView.register(UINib(nibName: "SlotCV", bundle: nil),
                                forCellWithReuseIdentifier: "SlotCV")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
        }
    }

    func configure(with slots: [Slot], parentTableView: UITableView) {
        self.slots = slots
        self.parentTableView = parentTableView

        collectionView.reloadData()
        
        // Force layout so contentSize is calculated
        DispatchQueue.main.async {
            self.collectionView.layoutIfNeeded()
            self.updateCollectionHeight()
        }
    }

    private func updateCollectionHeight() {
        let newHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        if collectionViewHeightConstraint.constant != newHeight {
            collectionViewHeightConstraint.constant = newHeight
            parentTableView?.beginUpdates()
            parentTableView?.endUpdates()
        }
    }

    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slots.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SlotCV",
            for: indexPath
        ) as! SlotCV
        let slot = slots[indexPath.item]
        cell.cellView.backgroundColor = .systemGray6
        cell.label.text = "\(slot.slot_from ?? "") - \(slot.slot_to ?? "")"
        return cell
    }

    // MARK: - Layout (2 cells per row)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing: CGFloat = 0
        let totalSpacing = spacing
        let cellWidth = (collectionView.frame.width - totalSpacing) / 2
        let cellHeight: CGFloat = 50
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
