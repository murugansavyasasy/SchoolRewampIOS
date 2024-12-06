//
//  AssignmentImageDetailVC.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 01/05/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class AssignmentImageDetailVC: UIViewController {
    @IBOutlet weak var contenImageView : UIImageView!
    var imageUrl = String()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        contenImageView.contentMode = .scaleToFill
        DispatchQueue.main.async {
            self.contenImageView.sd_setImage(with: NSURL(string: self.imageUrl) as! URL, placeholderImage: UIImage(named: "placeHolder.png"), options: SDWebImageOptions.refreshCached)
        }
    }
    
    @IBAction func actionBack(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
}
