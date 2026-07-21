//
//  outpasssRequestTvcell.swift
//  School Chimes
//
//  Created by apple on 18/03/26.
//

import UIKit

class outpasssRequestTvcell: UITableViewCell {

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var Fullview: UIView!
    @IBOutlet weak var RequesteOnLbl: UILabel!
    @IBOutlet weak var outPassDate: UILabel!
    @IBOutlet weak var ReasonLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        Fullview.layer.cornerRadius = 10
        statusView.layer.cornerRadius = 10
        Fullview.layer.borderWidth = 0.5
        Fullview.layer.borderColor = UIColor.lightGray.cgColor
    }

    
}
