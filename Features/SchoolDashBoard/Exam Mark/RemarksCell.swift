//
//  RemarksCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 04/09/26.
//

import UIKit

class RemarksCell: UICollectionViewCell {
    @IBOutlet weak var textBaseView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var dropDownBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textBaseView.layer.cornerRadius = 8
        textBaseView.layer.borderColor = UIColor.lightGray.cgColor
        textBaseView.layer.borderWidth = 0.5
    }

    @IBAction func dropDownBtn(_ sender: Any) {
    }
}
