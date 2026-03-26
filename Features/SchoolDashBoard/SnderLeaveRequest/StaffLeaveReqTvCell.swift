
//
//  StaffLeaveReqTvCell 2.swift
//  School Chimes
//
//  Created by apple on 10/03/26.
//


import UIKit

protocol approvalAndReject: AnyObject {
    func StaffUpdate(index: IndexPath)
    func StaffRejectUpdate(index: IndexPath)
}
class StaffLeaveReqTvCell: UITableViewCell,UIPopoverPresentationControllerDelegate, SelectedId {
    func selectId(id: String?, edit: Bool?) {
        EditLeave?.selectId(id:id, edit: edit)
    }
    @IBOutlet weak var threeDotBtnName: UIButton!
    @IBOutlet weak var leaveTypeLbl: UILabel!
    @IBOutlet weak var viewDetailsLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var aproveBtn: UIButton!
    @IBOutlet weak var reasonDefaultLbl: UILabel!
    @IBOutlet weak var leaveReasonLbl: UILabel!
    @IBOutlet weak var EnddateLbl: UILabel!
    @IBOutlet weak var staringDateLbl: UILabel!
    @IBOutlet weak var NoOfDaysLbl: UILabel!
    @IBOutlet weak var priorityLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var StatusView: UIView!
    @IBOutlet weak var NameAroundView: UIView!
    @IBOutlet weak var RejectBtnName: UIButton!
    var indexPath: IndexPath?
    weak var delegate: EditDeleteDelegate?
    var EditLeave:SelectedId?
    var edit:Bool?
    var delete:Bool?
    var selectedId:String?
    weak var ApprovalAndReject : approvalAndReject?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async{
            self.UiUpdate()
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()

        aproveBtn.isHidden = false
        RejectBtnName.isHidden = false
        StatusView.isHidden = true
        StatusView.backgroundColor = .clear
        statusLbl.textColor = .black
    }
    func UiUpdate(){
        RejectBtnName.layer.borderWidth = 1
        RejectBtnName.layer.borderColor = UIColor.red1.cgColor
        profileContainerView.layer.cornerRadius = 24 // 48x48
        profileContainerView.clipsToBounds = true
        fullView.cornerRadius(10)
        fullView.layer.borderWidth = 0.5
        fullView.layer.borderColor = UIColor.lightGray.cgColor
        StatusView.backgroundColor = UIColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1.0) // Light Blue
        StatusView.layer.cornerRadius = 10
    }
    
    @IBAction func threeDotBtnName(_ sender: UIButton) {
        
        let popoverContentVC = PopupVC(edit: self.edit ?? false, delete: self.delete ?? false, selectedId: selectedId)
        popoverContentVC.view.backgroundColor = .white
        popoverContentVC.delegate = self
        popoverContentVC.preferredContentSize = CGSize(width: 120, height: 70)
        popoverContentVC.modalPresentationStyle = .popover
        if let popoverController = popoverContentVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .right
            popoverController.delegate = self
        }
        
        // For iPhones: Present as a pop-up instead of full-screen
        if UIDevice.current.userInterfaceIdiom == .phone {
            popoverContentVC.modalPresentationStyle = .overFullScreen
            popoverContentVC.view.backgroundColor = UIColor(white: 0, alpha: 0.3) // Optional dim effect
        }
        if let topVC = getCurrentViewController() {
            topVC.present(popoverContentVC, animated: true, completion: nil)
        }
        
    }
    
    
    func edit(edit:Bool,delete:Bool,selectedId:String){
        self.selectedId = selectedId
        self.delete = delete
        self.edit = edit
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Ensure the popup style is maintained on iPhone
        return .none
    }
    func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
    }
    @IBAction func ApproveBtnAct(_ sender: UIButton) {
        if let indexPath = indexPath {
            ApprovalAndReject?.StaffUpdate(index: indexPath)
        }
    }
    
    @IBAction func RejectBtnAct(_ sender: UIButton) {
        if let indexPath = indexPath {
            ApprovalAndReject?.StaffRejectUpdate(index: indexPath)// use as needed
            }
    }
}
