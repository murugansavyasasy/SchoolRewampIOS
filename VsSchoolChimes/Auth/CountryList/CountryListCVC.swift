//
//  CountryListCVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 24/03/25.
//

import UIKit

class CountryListCVC: UICollectionViewCell {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var countryImg: UIImageView!
    private var savedColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

