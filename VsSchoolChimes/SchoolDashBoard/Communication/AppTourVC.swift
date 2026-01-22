//
//  AppTourVC.swift
//  School Chimes
//
//  Created by Chandhru on 21/01/26.
//

import UIKit

class AppTourVC: UIViewController {

    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var image = ["communicationInfo","ptmCalender"]
    var currentIntdex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    @IBAction func skip(_ sender: UIButton) {
        if image.count > 0 && currentIntdex != image.count - 1 {
            currentIntdex += 1
            imageView.image = UIImage(named: image[currentIntdex])
        }else if currentIntdex <= image.count - 1{
            dismiss(animated: true)
        }
    }
    @IBAction func next(_ sender: UIButton) {
        if image.count > 0 && currentIntdex != image.count - 1 {
            currentIntdex += 1
            imageView.image = UIImage(named: image[currentIntdex])
        }else if currentIntdex <= image.count - 1{
            dismiss(animated: true)
        }
    }
    @IBAction func previous(_ sender: UIButton) {
        if image.count > 0 && currentIntdex != 0{
            currentIntdex -= 1
            imageView.image = UIImage(named:image[currentIntdex])
        }
        
    }
}
