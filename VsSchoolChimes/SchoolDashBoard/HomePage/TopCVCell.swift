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
        outerView.layer.cornerRadius = 6
        outerView.layer.masksToBounds = false
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 0.08
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 6
        readVieaw.layer.cornerRadius = readVieaw.frame.width/2
    }
    func configure(with item: MenuDetail) {
        if let name = item.id {
            if #available(iOS 14.0, *) {
                let filteredItems = MenuRedirectHandler.shared.Imgitems.filter { $0.id == name }
                let img = UIImage(named: filteredItems.first?.name ?? "")
                iconBtn.setImage(img, for: .normal)
                nameLbl.text = item.name
            }
        }
    }
}
