//
//  GridCVCell.swift
//  CollectionViewGrid
//
//  Created by Shenll-Mac-04 on 05/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class GridCVCell: UICollectionViewCell {
    @IBOutlet weak var CellIcon: UIImageView!
    @IBOutlet weak var CellLabel: UILabel!
    @IBOutlet weak var CellView: UIView!
    
    @IBOutlet weak var iconHeight: NSLayoutConstraint!
    
    @IBOutlet weak var countView: UIViewX!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    @IBOutlet weak var cellIconTopCnstraints: NSLayoutConstraint!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        countView.isHidden = true
        countLbl.isHidden  = true
        
        
    }
}

