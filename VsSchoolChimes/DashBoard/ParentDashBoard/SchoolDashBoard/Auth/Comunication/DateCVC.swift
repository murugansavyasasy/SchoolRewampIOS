//
//  DateCVC.swift
//  VsSchoolChimes
//
//  Created by admin on 18/11/24.
//

import UIKit

class DateCVC: UICollectionViewCell {
    @IBOutlet weak var dateDelet: UIButton!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dateView: UIView!
    var delegate : reloadDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        dateView.layer.cornerRadius = 8
        dateView.layer.shadowColor = UIColor.black.cgColor
        dateView.layer.shadowOffset = CGSize(width: 0, height: 2)
        dateView.layer.shadowRadius = 5
        dateView.layer.shadowOpacity = 0.3
    }
    @IBAction func deleteBtn(_ sender: UIButton) {
        
        delegate?.deleteDelegate(index: sender.tag)
    }
}
