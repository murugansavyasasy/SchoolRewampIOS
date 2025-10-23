//
//  StaffChatTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 09/10/25.
//

import UIKit

class StaffChatTV: UITableViewCell, SelectedId, UIPopoverPresentationControllerDelegate {
    
    func selectId(id: String?, edit: Bool?) {
        delegate?.selectId(id: id, edit: edit)
    }
    
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var QuestionLbl: UILabel!
    @IBOutlet weak var questionDateLbl: UILabel!
    @IBOutlet weak var replyTypeLbl: UILabel!
    @IBOutlet weak var answerLbl: UILabel!
    @IBOutlet weak var answerDateLbl: UILabel!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var answerView: UIView!
    @IBOutlet weak var optionBtn: UIButton!
    
    var showpopup:ShowPopupDelegate?
    var edit:Bool?
    var delete:Bool?
    var delegate:SelectedId?
    var selectedId:String?
    var is_change_answer:Bool?
    var is_blocked:Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        optionBtn.transform = CGAffineTransform(rotationAngle: .pi/2)
        questionView.layer.cornerRadius = 10
        answerView.layer.cornerRadius = 10
        
        studentNameLbl.setFont(style: .body, size: FontSize.BodySize)
        QuestionLbl.setFont(style: .body, size: FontSize.BodySize)
        questionDateLbl.setFont(style: .body, size: 11)
        replyTypeLbl.setFont(style: .body, size: 11)
        answerLbl.setFont(style: .body, size: FontSize.BodySize)
        answerDateLbl.setFont(style: .body, size: 11)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func edit(edit:Bool,delete:Bool,selectedId:String,isChangeAnswer:Bool,isBlock:Bool){
        self.selectedId = selectedId
        self.delete = delete
        self.edit = edit
        self.is_change_answer = isChangeAnswer
        self.is_blocked = isBlock
        optionBtn.isHidden = !(edit || delete)
    }
    
    @IBAction func optionBtnAct(_ sender: UIButton) {
        
        let popoverContentVC = PopupVC(edit: edit ?? false, delete: delete ?? false, selectedId: selectedId)
        popoverContentVC.delegate = self
        popoverContentVC.ptm = false
        popoverContentVC.Chat = true
        popoverContentVC.reply_Btn_title = is_change_answer ?? false ? "Update answer" : "Answer"
        popoverContentVC.Block_Btn_title = is_blocked ?? false ? "Unblock" : "Block"
        let width = is_change_answer ?? false ? 180 : 120
        popoverContentVC.preferredContentSize = CGSize(width: width, height: 60)
        popoverContentVC.modalPresentationStyle = .popover
        if let popoverController = popoverContentVC.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .up
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
