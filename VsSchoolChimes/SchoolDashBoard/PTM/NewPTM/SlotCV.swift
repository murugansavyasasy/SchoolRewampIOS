//
//  SlotCV.swift
//  School Chimes
//
//  Created by Lakshmanan on 18/08/25.
//

import UIKit

class SlotCV: UICollectionViewCell {

    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        cellView.layer.cornerRadius = 10
        cellView.backgroundColor = .systemGray4
        label.setFont(style: .body, size: FontSize.BodySize)
    }

}
