//
//  CustomParentTableViewCell.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 08/06/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class CustomParentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var locationTop: NSLayoutConstraint!
    @IBOutlet weak var SchoolNameRegional: UILabel!
    @IBOutlet  var StudentNameLabel: UILabel!
    @IBOutlet  var StudentClassLabel: UILabel!
    @IBOutlet  var StudentRollNoLabel: UILabel!
    @IBOutlet  var SchoolLogoImage: UIImageView!
    @IBOutlet  var SchoolNameLabel: UILabel!
    @IBOutlet  var SchoolLocationLabel: UILabel!
    @IBOutlet  var MessageReadUnreadLabel: UILabel!
    @IBOutlet  var MessageAlertImage: UIImageView!
    @IBOutlet  var cellbgImage: UIImageView!
    @IBOutlet  var cellView1: UIView!
    @IBOutlet  var cellView2: UIView!
    @IBOutlet  var noteView: UIView!
    
    @IBOutlet weak var CellView: UIView!
    @IBOutlet weak var FloatRollNoLabel: UILabel!
    @IBOutlet weak var FlaotClassLabel: UILabel!
    @IBOutlet weak var FloatLabel: UILabel!
     @IBOutlet weak var noteLabel: UILabel!
     @IBOutlet weak var noteInfoLabel: UILabel!
    
        @IBOutlet  var noteViewHeight: NSLayoutConstraint!
     @IBOutlet  var cellViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    // MARK: Language Selection
    
 
}
