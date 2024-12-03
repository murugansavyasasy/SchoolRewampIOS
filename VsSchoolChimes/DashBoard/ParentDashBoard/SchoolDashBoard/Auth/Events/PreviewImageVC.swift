//
//  PreviewImageVC.swift
//  VsSchoolChimes
//
//  Created by admin on 03/12/24.
//

import UIKit

class PreviewImageVC: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var outerView: UIView!
    var img :UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        imgView.image = img
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
    }

    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
