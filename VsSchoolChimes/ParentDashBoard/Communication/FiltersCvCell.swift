//
//  FiltersCvCell.swift
//  VsSchoolChimes
//
//  Created by Lakshmanan on 22/04/25.
//

import UIKit

class FiltersCvCell: UICollectionViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var FilterLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        cellView.layer.cornerRadius = 12
        cellView.backgroundColor = .systemGray5
        
        FilterLbl.setFont(style: .body, size: FontSize.BodySize)
    }

}
