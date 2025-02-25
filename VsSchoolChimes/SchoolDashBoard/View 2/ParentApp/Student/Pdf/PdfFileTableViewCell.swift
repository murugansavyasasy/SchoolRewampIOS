//
//  PdfFileTableViewCell.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 12/06/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class PdfFileTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var NewLbl: UILabel!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var DateLbl: UILabel!
    @IBOutlet weak var SubjectLbl: UILabel!
    
    @IBOutlet weak var DiscriptionLabel: UILabel!
    @IBOutlet weak var DownloadButton: UIButton!
    @IBOutlet weak var ViewFileButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NewLbl.layer.cornerRadius = 5
        NewLbl.clipsToBounds = true
        DownloadButton.layer.cornerRadius = 5
        DownloadButton.clipsToBounds = true
        ViewFileButton.layer.cornerRadius = 5
        ViewFileButton.clipsToBounds = true
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
