//
//  TopCVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class TopCVCell: UICollectionViewCell {
    @IBOutlet weak var readVieaw: UIView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var iconBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        outerView.setShadow(cornerRadius: 4)
        readVieaw.layer.cornerRadius = readVieaw.frame.width/2
    }
    func configure(with item: DashboardMenu) {
        iconBtn.setImage(UIImage(named: "Homework"), for: .normal)
        nameLbl.text = item.title
    }
}
