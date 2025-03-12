//
//  ViewAssignmentTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 01/05/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class ViewAssignmentTVCell: UITableViewCell {
    @IBOutlet weak var contentLabel : UILabel!
    @IBOutlet weak var imgView : UIView!
    @IBOutlet weak var contenImageView : UIImageView!
    @IBOutlet weak var saveImage : UIButton!
    @IBOutlet weak var PDFImageIcon: UIImageView!
    @IBOutlet weak var PDFImageIconwidth: NSLayoutConstraint!
    @IBOutlet weak var textView: UIView!
    
    @IBOutlet weak var textDetailTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
