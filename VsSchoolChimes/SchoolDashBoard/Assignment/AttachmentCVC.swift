//
//  AttachmentCVC.swift
//  School Chimes
//
//  Created by Chandhru on 08/08/25.
//

import UIKit

class AttachmentCVC: UICollectionViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imageNameLbl: UILabel!
    @IBOutlet weak var imgIconBtn: UIButton!
    @IBOutlet weak var imageTypeSizeLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    var delegate:DeleteImge?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgIconBtn.layer.cornerRadius = 8
        outerView.layer.cornerRadius = 8
        outerView.layer.borderWidth = 0.3
        outerView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        outerView.backgroundColor = UIColor.systemGray6
        deleteBtn.layer.cornerRadius = deleteBtn.frame.width/2
        deleteBtn.layer.borderWidth = 1
        deleteBtn.layer.borderColor = UIColor.red.cgColor
    }
    @IBAction func deleteImg(_ sender: UIButton) {
        delegate?.deleteImage(index: sender.tag)
    }
}
