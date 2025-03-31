//
//  RecipientCVcell.swift
//  VsSchoolChimes
//
//  Created by admin on 31/03/25.
//

import UIKit
protocol CustomCollectionViewCellDelegate: AnyObject {
    func didTapButtonInCell(at indexPath: IndexPath, button: UIButton)
}

class RecipientCVcell: UICollectionViewCell {

    @IBOutlet weak var btnName: UIButton!
    var delegate: CustomCollectionViewCellDelegate?
    var indexPath: IndexPath?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        
        
        btnName.layer.cornerRadius = 10
        btnName.layer.shadowColor = UIColor.black.cgColor
        btnName.layer.shadowOffset = CGSize(width: 1, height: 1)
        btnName.layer.shadowOpacity = 0.5
        btnName.layer.shadowRadius = 4
        btnName.backgroundColor = .white
        btnName.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    
    @objc func buttonTapped() {
           // Call delegate method when the button is tapped
        
               
        
        if let indexPath = indexPath {
                    delegate?.didTapButtonInCell(at: indexPath, button: btnName)
                }
       }

       // Set index path for the cell
       func configureCell(indexPath: IndexPath) {
           self.indexPath = indexPath
       }
}
