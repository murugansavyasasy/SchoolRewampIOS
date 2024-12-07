//
//  GridCVCell.swift
//  CollectionViewGrid
//
//  Created by Shenll-Mac-04 on 05/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class ParentGridCVCell: UICollectionViewCell {
    @IBOutlet weak var CellIcon: UIImageView!
    @IBOutlet weak var CellLabel: UILabel!
    @IBOutlet weak var CellView: UIView!
    @IBOutlet weak var UnreadMessageCountLabel: UILabel!
    
  
    @IBOutlet weak var iconHeight: NSLayoutConstraint!
    @IBOutlet weak var iconWidth: NSLayoutConstraint!
    @IBOutlet weak var cellIconTop1: NSLayoutConstraint!
}

