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
    //@IBOutlet weak var clockImgview: UIImageView!
    @IBOutlet weak var MeetingTypeBtn: UIButton!
    @IBOutlet weak var StaffNameLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var Stackview: UIStackView!
    @IBOutlet weak var Cellview: UIView!
    @IBOutlet weak var initialBtn: UIButton!
    @IBOutlet weak var subjectLbl: UILabel!
    
    
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
        Cellview.layer.borderWidth = 1
        Cellview.layer.borderColor = UIColor.systemGray4.cgColor
        
        initialBtn.layer.cornerRadius = initialBtn.frame.width / 2
        MeetingTypeBtn.layer.cornerRadius = 8
        
        TitleLbl.setFont(style: .title, size: 15)
        StaffNameLbl.setFont(style: .body, size: FontSize.TitleSize)
        subjectLbl.setFont(style: .body, size: FontSize.BodySize)
        AvailableslotLbl.setFont(style: .body, size: FontSize.BodySize)
        MeetingTypeBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        initialBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        
        AvailableslotLbl.text = "Select Meeting Slot".translated()

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
    
    override func layoutSubviews() {
            super.layoutSubviews()
            applyGradientToButton()
            applyGradientToButton2()
        }
    
    private func applyGradientToButton() {
           // Remove old gradients
        MeetingTypeBtn.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }

           let gradient = CAGradientLayer()
           gradient.colors = [
               UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1).cgColor, // #667eea
               UIColor(red: 0.46, green: 0.29, blue: 0.64, alpha: 1).cgColor // #764ba2
           ]
           gradient.startPoint = CGPoint(x: 0, y: 0)   // top-left
           gradient.endPoint = CGPoint(x: 1, y: 1)     // bottom-right (135°)
           gradient.frame = MeetingTypeBtn.bounds
           gradient.cornerRadius = MeetingTypeBtn.layer.cornerRadius

        MeetingTypeBtn.layer.insertSublayer(gradient, at: 0)
       }
    
    private func applyGradientToButton2() {
           // Remove old gradients
        initialBtn.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }

           let gradient = CAGradientLayer()
           gradient.colors = [
               UIColor(red: 0.4, green: 0.49, blue: 0.92, alpha: 1).cgColor, // #667eea
               UIColor(red: 0.46, green: 0.29, blue: 0.64, alpha: 1).cgColor // #764ba2
           ]
           gradient.startPoint = CGPoint(x: 0, y: 0)   // top-left
           gradient.endPoint = CGPoint(x: 1, y: 1)     // bottom-right (135°)
           gradient.frame = initialBtn.bounds
           gradient.cornerRadius = initialBtn.layer.cornerRadius

        initialBtn.layer.insertSublayer(gradient, at: 0)
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
