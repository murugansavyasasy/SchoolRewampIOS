//
//  parentPTMcell.swift
//  VsSchoolChimes
//
//  Created by MacBook on 20/02/25.
//

import UIKit

class parentPTMcell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        
//        return 5
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! TimeCollectionViewCell
//        cell.timelbl.text = "07 : 00 AM"
////        if indexPath.row == 9{
////            cvHeight.constant = cv.collectionViewLayout.collectionViewContentSize.height
////        }
//        return cell
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: cv.frame.width/3, height: 50)
//    }

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
    var slots : [StudentSlot] = []
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
        
        TitleLbl.setFont(style: .title, size: FontSize.TitleSize)
        StaffNameLbl.setFont(style: .body, size: FontSize.BodySize)
        AvailableslotLbl.setFont(style: .body, size: FontSize.BodySize)
        MeetingTypeBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
//        cv.layer.cornerRadius = 10
//        cv.layer.borderWidth = 0.5
//        cv.layer.borderColor = UIColor.gray.cgColor
        
        
        cv.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
        
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with slots: [StudentSlot], parentTableView: UITableView) {
        self.slots = slots
        self.parentTableView = parentTableView

        cv.reloadData()
        
        // Force layout so contentSize is calculated
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
        cell.closeBtn.isHidden = true
        cell.cellView.backgroundColor = .systemGray6
        cell.label.text = "\(slot.slot_from ?? "") - \(slot.slot_to ?? "")"
        
        cell.configure(slot: slots[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // If this event already has an API-confirmed booking, ignore taps
            if slots.contains(where: { $0.my_booking ?? false }) { return }

            let tapped = slots[indexPath.item]
            // If booked by someone else or disabled by conflict, ignore
            if (tapped.is_booked ?? false) || (tapped.is_conflictDisabled ?? false) { return }

            slotSelected?(indexPath.item)
        }

    // MARK: - Layout (2 cells per row)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spacing: CGFloat = 0
        let totalSpacing = spacing
        let cellWidth = (collectionView.frame.width - totalSpacing) / 2
        let cellHeight: CGFloat = 60
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
