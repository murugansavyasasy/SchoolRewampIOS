//
//  OutpassVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 02/08/25.
//

import UIKit

class OutpassVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var ReasonLbl: UILabel!
    @IBOutlet weak var ApprovedByLbl: UILabel!
    @IBOutlet weak var NoOfDaysLbl: UILabel!
    @IBOutlet weak var ToDateLbl: UILabel!
    @IBOutlet weak var FromDateLbl: UILabel!
    @IBOutlet weak var AppliedOnLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var ImageBaseView: UIView!
    @IBOutlet weak var BottomDarkView: UIView!
    @IBOutlet weak var ReasonView: UIView!
    @IBOutlet weak var BottomLightView: UIView!
    @IBOutlet weak var outpassBaseView: UIView!
    @IBOutlet weak var outpassView: UIView!
    
    @IBOutlet weak var ReasonSubview: UIView!
    @IBOutlet weak var ImageView: UIImageView!
    var leaveInfo: LeaveInfo?
    override func viewDidLoad() {
        super.viewDidLoad()

        if let Leave = leaveInfo{
            NameLbl.text = leaveInfo?.student_name
            StandardLbl.text = (Leave.class_name ?? "") + " - " + (Leave.section_name ?? "")
            AppliedOnLbl.text = Leave.applied_on?.convertToTargetDateFormat()
            FromDateLbl.text = Leave.leave_from?.convertToTargetDateFormat()
            ToDateLbl.text = Leave.leave_to?.convertToTargetDateFormat()
            NoOfDaysLbl.text = (Leave.no_of_days ?? "") + " Days"
            ReasonLbl.text = Leave.reason ?? ""
            ApprovedByLbl.text = Leave.approved_by
        }
        
        let imageUrl = URL(string: UserDefaultFileManager.get_child_Details()?.profile ?? "")
        ImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(systemName: "Default_profile"))
        ImageView.layer.cornerRadius = ImageView.frame.height / 2
        
        [outpassBaseView, outpassView].forEach {
            $0?.layer.cornerRadius = 10
            $0?.clipsToBounds = true
        }
        
        ImageBaseView.layer.cornerRadius = 60
        ImageBaseView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        ImageBaseView.layer.masksToBounds = true
        
        BottomDarkView.layer.cornerRadius = 20
        BottomDarkView.layer.maskedCorners = [.layerMaxXMinYCorner]
        BottomDarkView.layer.masksToBounds = true
        
        BottomLightView.layer.cornerRadius = 20
        BottomLightView.layer.maskedCorners = [.layerMinXMinYCorner]
        BottomLightView.layer.masksToBounds = true
        
        ReasonView.layer.cornerRadius = 8
        ReasonSubview.layer.cornerRadius = 8
    }
    

    @IBAction func closeBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
}
