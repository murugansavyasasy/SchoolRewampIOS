//
//  NotiTvheader.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 12/08/25.
//

import UIKit

class NotiTvheader: UITableViewHeaderFooterView {

    @IBOutlet weak var clearAllBtn: UIButton!
    @IBOutlet weak var MenuImage: UIImageView!
    @IBOutlet weak var menuNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        clearAllBtn.layer.cornerRadius = clearAllBtn.frame.height/2
    }
}
