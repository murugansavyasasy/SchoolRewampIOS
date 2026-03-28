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
           genderBtn.setTitle(data.type, for: .normal)
        
//        switch data.type?.lowercased() {
//
//        case "male":
//            genderBtn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
//            genderBtn.setTitleColor(.systemBlue, for: .normal)
//
//        case "female":
//            genderBtn.backgroundColor = UIColor.systemPink.withAlphaComponent(0.15)
//            genderBtn.setTitleColor(.systemPink, for: .normal)
//
//        default:
//            genderBtn.backgroundColor = .lightGray
//        }
           
       }
   
 
}
