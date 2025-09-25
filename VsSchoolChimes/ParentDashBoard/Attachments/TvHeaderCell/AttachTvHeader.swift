//
//  AttachTvHeader.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 31/07/25.
//

import UIKit

class AttachTvHeader: UITableViewHeaderFooterView, SelectedId, UIPopoverPresentationControllerDelegate {
    func selectId(id: String?, edit: Bool?) {
        delegate?.selectId(id:id, edit: edit)
    }


    @IBOutlet weak var editAndDeleteBtnName: UIButton!
    @IBOutlet weak var fullView: UIView!
    
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var discretpionLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    var delegate:SelectedId?
    var edit:Bool?
    var delete:Bool?
    var selectedId:String?
    override func awakeFromNib() {
            super.awakeFromNib()
           
//        roundView.isHidden = true
        roundView.layer.cornerRadius = roundView.frame.width/2
        }
    
    
    @IBAction func EditAndDeletBtn(_ sender: UIButton) {
        
        let popoverContentVC = PopupVC(edit: self.edit ?? false, delete: self.delete ?? false, selectedId: selectedId)
        popoverContentVC.delegate = self
        popoverContentVC.view.backgroundColor = .white
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
    func edit(edit:Bool,delete:Bool,selectedId:String){
        self.selectedId = selectedId
        self.delete = delete
        self.edit = edit
        editAndDeleteBtnName.isHidden = !(edit || delete)
    }
    func configure(with item: AttachmentHeaderInfo) {
        
//        discretpionLbl.text = item.description
        titleLbl.text =  item.title
        let displayText = formattedDateStatus(from: item.date ?? "")
        dateLbl.text = "🗓️ " + displayText
        roundView.isHidden = !item.is_unread
        
       }
}
