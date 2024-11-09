//
//  CountryVc.swift
//  VsSchoolChimes
//
//  Created by admin on 25/10/24.
//

import UIKit

@available(iOS 14.0, *)
class CountryVc: UIViewController {

    
    @IBOutlet weak var ClickArrowImg: UIImageView!
    @IBOutlet weak var fullview: UIView!
    
    
    @IBOutlet weak var checkBoxView: CheckBox!
    @IBOutlet weak var Canada: UIButton!
    @IBOutlet weak var Singapore: UIButton!
    @IBOutlet weak var China: UIButton!
    @IBOutlet weak var Usa: UIButton!
    @IBOutlet weak var thailand: UIButton!
    @IBOutlet weak var indiabutton: UIButton!
   
    var CountryCheck = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        checkBoxView.isChecked = false
        fullview.backgroundColor = Colornames.countryClr
        view.backgroundColor = Colornames.countryClr
        
        
        
        
        ClickArrowImg.layer.cornerRadius = ClickArrowImg.frame.width/2
        ClickArrowImg.clipsToBounds = true
        
       
        indiabutton.layer.cornerRadius = indiabutton.frame.width/2
        Usa.layer.cornerRadius = Usa.frame.width/2
        Singapore.layer.cornerRadius = Singapore.frame.width/2
     
        
        thailand.transform = CGAffineTransform(rotationAngle: .pi / 4) // Rotate 45 degrees
        thailand.titleLabel?.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        thailand.layer.cornerRadius = 20
        
        China.transform = CGAffineTransform(rotationAngle: .pi / 4) // Rotate 45 degrees
        China.titleLabel?.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        China.layer.cornerRadius = 20
        
        Canada.transform = CGAffineTransform(rotationAngle: .pi / 4) // Rotate 45 degrees
        Canada.titleLabel?.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        Canada.layer.cornerRadius = 20
        
        
        let tap  = UITapGestureRecognizer(target: self, action:#selector(GotToNextVc))
        ClickArrowImg.isUserInteractionEnabled = true
        ClickArrowImg.addGestureRecognizer(tap)
        
    
        
        
        
    }


    
    @IBAction  func GotToNextVc(){
        
        
        
        var term : String = "1"
        
        let userDefault = UserDefaults.standard
        userDefault.set(term, forKey: DefaultsKeys.countryId)
      
       
        let vc = LoginVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
        
    }
   

}
