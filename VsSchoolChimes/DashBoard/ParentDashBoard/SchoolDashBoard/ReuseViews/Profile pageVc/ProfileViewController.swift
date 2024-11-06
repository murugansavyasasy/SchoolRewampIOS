//
//  ProfileViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 30/10/24.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var imgview: UIImageView!
    @IBOutlet weak var contactDetails: UIView!
    @IBOutlet weak var standardView: UIView!
    @IBOutlet weak var personalview: UIView!
    @IBOutlet weak var AboutstudentView: UIView!
    
    @IBOutlet weak var hostelimg: UIImageView!
    @IBOutlet weak var locationimg: UIImageView!
    @IBOutlet weak var bloodimg: UIImageView!
    @IBOutlet weak var familyDetailsView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imgview.layer.cornerRadius = 50//imgview.frame.width/2
        personalview.layer.cornerRadius = 15
        standardView.layer.cornerRadius = 15
        contactDetails.layer.cornerRadius = 15
        AboutstudentView.layer.cornerRadius = 15
        familyDetailsView.layer.cornerRadius = 15
        
        bloodimg.layer.cornerRadius = 10
        locationimg.layer.cornerRadius = 10
        hostelimg.layer.cornerRadius = 10
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
