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
    var image:[String] = []
    var currentIntdex = 0
    var tourKey:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        imageView.image = UIImage(named: image[currentIntdex])
        nextBtn.layer.cornerRadius = nextBtn.frame.height/2
        skipBtn.layer.cornerRadius = skipBtn.frame.height/2
        previousBtn.layer.cornerRadius = previousBtn.frame.height/2
    }
    @IBAction func skip(_ sender: UIButton) {
            if let tourKey = tourKey{
                UserDefaults.standard.set(true, forKey: tourKey)
            }
            dismiss(animated: true)
    }
    @IBAction func next(_ sender: UIButton) {
        if image.count > 0 && currentIntdex != image.count - 1 {
            currentIntdex += 1
            imageView.image = UIImage(named: image[currentIntdex])
        }else if currentIntdex <= image.count - 1{
            
            if let tourKey = tourKey{
                UserDefaults.standard.set(true, forKey: tourKey)
            }
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
