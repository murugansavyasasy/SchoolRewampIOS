//
//  FileAttachmentTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/21/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class FileAttachmentTableViewCell: UITableViewCell {

    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var contentFilePathLbl: UILabel!
    var indexPath: IndexPath?

    var deleteAction: ((IndexPath) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    @IBAction func vardeleteActionIndexPathVoid(_ sender: UIButton) {
        
        if let indexPath = indexPath {
            deleteAction?(indexPath)
        }
    }
}
