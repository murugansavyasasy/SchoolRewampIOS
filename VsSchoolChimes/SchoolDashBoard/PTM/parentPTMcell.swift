//
//  parentPTMcell.swift
//  VsSchoolChimes
//
//  Created by MacBook on 20/02/25.
//

import UIKit

class parentPTMcell: UITableViewCell,
                     UICollectionViewDelegate,
                     UICollectionViewDataSource,
                     UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var AvailableslotLbl: UILabel!
    @IBOutlet weak var clockImgview: UIImageView!
    @IBOutlet weak var MeetingTypeBtn: UIButton!
    @IBOutlet weak var StaffNameLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var Stackview: UIStackView!
    @IBOutlet weak var Cellview: UIView!

    var identifier = "TimeCollectionViewCell"
    var slots: [StudentSlot] = []
    var slotSelected: ((Int) -> Void)?
    private weak var parentTableView: UITableView?

    override func awakeFromNib() {
        super.awakeFromNib()

        Cellview.layer.cornerRadius = 10
        Cellview.layer.shadowColor = UIColor.black.cgColor
        Cellview.layer.shadowOpacity = 0.1
        Cellview.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        Cellview.layer.shadowRadius = 0.5
        Cellview.layer.masksToBounds = false
        Cellview.layer.borderWidth = 0.5
        Cellview.layer.borderColor = UIColor.systemGray4.cgColor

        cv.register(UINib(nibName: "SlotCV", bundle: nil),
                    forCellWithReuseIdentifier: "SlotCV")

        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = false
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
        }
    }

    func configure(with slots: [StudentSlot], parentTableView: UITableView) {
        self.slots = slots
        self.parentTableView = parentTableView
        cv.reloadData()
        DispatchQueue.main.async {
            self.cv.layoutIfNeeded()
            self.updateCollectionHeight()
        }
    }

    private func updateCollectionHeight() {
        let newHeight = cv.collectionViewLayout.collectionViewContentSize.height
        if cvHeight.constant != newHeight {
            cvHeight.constant = newHeight
            parentTableView?.beginUpdates()
            parentTableView?.endUpdates()
        }
    }

    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slots.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlotCV",
                                                      for: indexPath) as! SlotCV
        cell.closeBtn.isHidden = true
        cell.configure(slot: slots[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if slots.contains(where: { $0.my_booking ?? false }) { return }
        let tapped = slots[indexPath.item]
        if (tapped.is_booked ?? false) || (tapped.is_conflictDisabled ?? false) { return }
        slotSelected?(indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 2
        return CGSize(width: cellWidth, height: 60)
    }
}
