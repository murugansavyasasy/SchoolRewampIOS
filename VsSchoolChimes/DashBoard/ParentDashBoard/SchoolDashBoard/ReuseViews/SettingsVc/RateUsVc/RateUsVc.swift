//
//  RateUsVc.swift
//  VsSchoolChimes
//
//  Created by admin on 28/10/24.
//

import UIKit

class RateUsVc: UIViewController {

    
  
    @IBOutlet weak var backView: UIView!
    
       override func viewDidLoad() {
           super.viewDidLoad()
           
           
           let backs = UITapGestureRecognizer(target: self, action: #selector(backClik))
           backView.addGestureRecognizer(backs)
          
       }
       
      
    @IBAction func backClik(){
        
        dismiss(animated: true)
        
    }
}
