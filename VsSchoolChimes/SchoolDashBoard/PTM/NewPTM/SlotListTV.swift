//
//  SlotListTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 12/08/25.
//

import UIKit

class SlotListTV: UITableViewCell, SelectedId, UIPopoverPresentationControllerDelegate {
    func selectId(id: String?, edit: Bool?) {
        delegate?.selectId(id: id, edit: edit)
    }
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var StatusBtn: UIButton!
    @IBOutlet weak var optionsBtn: UIButton!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var DurationLbl: UILabel!
    @IBOutlet weak var BookingBaseview: UIView!
    @IBOutlet weak var BookedStatusView: UIView!
    @IBOutlet weak var WaitingLbl: UILabel!
    @IBOutlet weak var bookedByNameLbl: UILabel!
    @IBOutlet weak var bookedByDefLbl: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    
    var showpopup:ShowPopupDelegate?
    var edit:Bool?
    var delete:Bool?
    var delegate:SelectedId?
    var selectedId:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        cellView.layer.cornerRadius = 12
        cellView.layer.borderWidth = 0.5
        cellView.layer.borderColor = UIColor.lightGray.cgColor
        
        StatusBtn.layer.cornerRadius = 15
        StatusBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        TimeLbl.setFont(style: .header, size: FontSize.HeaderSize)
        DurationLbl.setFont(style: .body, size: FontSize.BodySize)
        bookedByNameLbl.setFont(style: .body, size: FontSize.BodySize)
        
        BookingBaseview.layer.cornerRadius = 10
        BookingBaseview.backgroundColor = .systemGray5.withAlphaComponent(0.5)
        
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        
        WaitingLbl.isHidden = true
        
        optionsBtn.transform = CGAffineTransform(rotationAngle: .pi/2)
    }
    
    func edit(edit:Bool,delete:Bool,selectedId:String){
        self.selectedId = selectedId
        self.delete = delete
        self.edit = edit
        optionsBtn.isHidden = !(edit || delete)
    }
    
    @IBAction func optionBtnAct(_ sender: UIButton) {
        
        let popoverContentVC = PopupVC(edit: edit ?? false, delete: delete ?? false, selectedId: selectedId)
        popoverContentVC.delegate = self
        popoverContentVC.ptm = true
        popoverContentVC.preferredContentSize = CGSize(width: 120, height: 60)
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
    
    private func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Ensure the popup style is maintained on iPhone
        return .none
    }
}
