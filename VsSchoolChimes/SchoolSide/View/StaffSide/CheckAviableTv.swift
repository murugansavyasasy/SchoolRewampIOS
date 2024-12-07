//
//  CheckAviableTv.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 24/08/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class CheckAviableTv: UITableViewCell {

    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var timeLbl: UILabel!
    
    var indexPath: IndexPath?
       
       // Add a closure to handle the delete action
       var deleteAction: ((IndexPath) -> Void)?
       
       @IBAction func deleteButtonTapped(_ sender: UIButton) {
           if let indexPath = indexPath {
               deleteAction?(indexPath)
           }
       }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        statusLbl.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
