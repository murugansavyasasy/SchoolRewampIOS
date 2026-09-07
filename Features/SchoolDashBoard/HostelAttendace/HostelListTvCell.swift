//
//  HostelListTvCell.swift
//  School Chimes
//
//  Created by apple on 16/03/26.
//

import UIKit

class HostelListTvCell: UITableViewCell {

    @IBOutlet weak var arrowBtnName: UIButton!
    @IBOutlet weak var HostelID: UILabel!
    @IBOutlet weak var maxCapicityLbl: UILabel!
    @IBOutlet weak var HostelLocationLbl: UILabel!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var instruteName: UILabel!
    @IBOutlet weak var hostelName: UILabel!
    @IBOutlet weak var FullView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        FullView.layer.cornerRadius = 15
        arrowBtnName.layer.cornerRadius = 15
        
    }
    
    func configure(with data: HostelListData) {
           
           hostelName.text = data.name
        HostelID.text = " # \(data.id ?? "")"
           instruteName.text = data.institute_name
           HostelLocationLbl.text = data.address
           maxCapicityLbl.text = "\(data.max_capacity ?? 0)"
        genderBtn.setTitle(data.type?.uppercased(), for: .normal)
        genderBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        
        configureGenderButton(type: data.type ?? "")
        
       }
   
    func configureGenderButton(type: String) {
        
        genderBtn.setTitle(type, for: .normal)
        genderBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        
        genderBtn.layer.cornerRadius = genderBtn.frame.height / 2
        profileBtn.layer.cornerRadius = genderBtn.frame.height / 2
        genderBtn.clipsToBounds = true
        
        switch type.lowercased() {
            
        case "male".translated() , "boys".translated():
            genderBtn.backgroundColor = UIColor(red: 0.85, green: 0.92, blue: 1.0, alpha: 1.0) // light blue
            genderBtn.setTitleColor(UIColor(red: 0.10, green: 0.35, blue: 0.85, alpha: 1.0), for: .normal)
            profileBtn.tintColor = (UIColor(red: 0.10, green: 0.35, blue: 0.85, alpha: 1.0)) // dark blue text
            profileBtn.backgroundColor = UIColor(red: 0.85, green: 0.92, blue: 1.0, alpha: 1.0)
            
        case "female".translated(),"girls".translated():
            genderBtn.backgroundColor = UIColor(red: 1.0, green: 0.88, blue: 0.92, alpha: 1.0) // light
            profileBtn.backgroundColor = UIColor(red: 1.0, green: 0.88, blue: 0.92, alpha: 1.0) // light pink
            genderBtn.setTitleColor(UIColor(red: 0.80, green: 0.20, blue: 0.45, alpha: 1.0), for: .normal) // dark pink text
            profileBtn.tintColor = (UIColor(red: 0.80, green: 0.20, blue: 0.45, alpha: 1.0)) // dark pink text
            
        default:
            genderBtn.backgroundColor = UIColor(red: 0.85, green: 0.92, blue: 1.0, alpha: 1.0) // light blue
            genderBtn.setTitleColor(UIColor(red: 0.10, green: 0.35, blue: 0.85, alpha: 1.0), for: .normal)
            profileBtn.tintColor = (UIColor(red: 0.10, green: 0.35, blue: 0.85, alpha: 1.0)) // dark blue text
            profileBtn.backgroundColor = UIColor(red: 0.85, green: 0.92, blue: 1.0, alpha: 1.0)
        }
    }
}
