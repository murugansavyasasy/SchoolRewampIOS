//
//  SubscriptionView.swift
//  VsSchoolChimes
//
//  Created by admin on 18/12/24.
//

import UIKit

class SubscriptionView: UIView,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var fullView: UIView!
    
  
    @IBOutlet weak var tv: UITableView!
    
    
    var nibName = "SubscriptionView"
    let subscriptionBenefits = [
        "Add attendance with precise GPS-based location tagging.",
        "Enforce attendance within designated zones.",
        "Get real-time location updates for remote employees or field workers.",
        "Ensure high security with biometric verification.","See Punch-In/Out History"
    ]
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
        
//        applyGradientIfNeeded()
        fullView.layer.cornerRadius = Colornames.CORadius10
       
        fullView.layer.borderWidth = 0.5
        fullView.layer.borderColor = UIColor.button.cgColor
        
        
  
      
        fullView.layer.masksToBounds = true
       fullView.layer.shadowColor = UIColor.black.cgColor
       fullView.layer.shadowOpacity = 0.5
        fullView.layer.shadowOffset = CGSize(width: 4, height: 4)
       fullView.layer.shadowRadius = 5
      
        let nib = UINib(nibName: CellConfingName.SubscriptionTVCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier: CellConfingName.SubscriptionTVCell)
        
        tv.dataSource = self
        tv.delegate = self
        
        
    }
    
    

    
  
       // Ensure the gradient is applied immediately as well
 
    
    private func applyGradientIfNeeded() {
        
        let gradientLayer = CAGradientLayer()
       
        
        gradientLayer.colors = [UIColor.blue.cgColor, UIColor.systemTeal.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
        gradientLayer.frame = fullView.bounds
        // Add the gradient to your fullView
        fullView.layer.insertSublayer(gradientLayer, at: 0)

        
        
       
    }
    func commonInit() {
    guard let view = loadViewFromNib() else { return }
    view.frame = self.bounds
    self.addSubview(view)
    }


    func loadViewFromNib() -> UIView? {
    let nib = UINib(nibName: nibName, bundle: nil)
    return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return subscriptionBenefits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.SubscriptionTVCell, for: indexPath) as! SubscriptionTVCell
        cell.itemLbl.text = subscriptionBenefits[indexPath.row]
        
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    
    @IBAction func callBtn(_ sender: Any) {
    }
    
}

