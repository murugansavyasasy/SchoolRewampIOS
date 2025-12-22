//
//  QuizListTvCell.swift
//  VsSchoolChimes
//
//  Created by Admin on 07/02/25.
//

import UIKit
protocol addQuestionAndSubmitedListDelegate {
    
    func addQuestionAndSubmitedList(index : Int)
    func submitedList(index : Int)
}
class QuizListTvCell: UITableViewCell, SelectedId, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var addQuestionBtnName: UIButton!
    @IBOutlet weak var submittedListBtnName: UIButton!
    @IBOutlet weak var postedByLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var discretiponsLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var EndTimeLbl: UILabel!
    @IBOutlet weak var strtTimeLbl: UILabel!
    @IBOutlet weak var exameDateLbl: UILabel!
    @IBOutlet weak var DeafultimageView: UIImageView!
    @IBOutlet weak var CellView: UIView!
    @IBOutlet weak var PlayBtn: UIButton!
    @IBOutlet weak var LevelView: UIView!
    @IBOutlet weak var levelLbl: UILabel!
    @IBOutlet weak var optionsBtn: UIButton!
    
    var delegate : addQuestionAndSubmitedListDelegate?
    var edit:Bool?
    var delete:Bool?
    var PopupDelegate:SelectedId?
    var selectedId:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CellView.layer.cornerRadius = 10
        DeafultimageView.layer.cornerRadius = 10
        addQuestionBtnName.layer.cornerRadius = 10
        submittedListBtnName.layer.cornerRadius = 10
        LevelView.layer.cornerRadius = 15
        LevelView.layer.maskedCorners = [.layerMaxXMaxYCorner]
        LevelView.clipsToBounds = true
        LevelView.layer.masksToBounds = true
        CellView.clipsToBounds = true
        
        optionsBtn.transform = CGAffineTransform(rotationAngle: .pi/2)
    }

    @IBAction func addQestBtn(_ sender: UIButton) {
        delegate?.addQuestionAndSubmitedList(index: sender.tag)
    }
    
    @IBAction func submitedList(_ sender: UIButton) {
        delegate?.submitedList(index: sender.tag)
    }
    
    @IBAction func optionsBtnAct(_ sender: UIButton) {
    
        let popoverContentVC = PopupVC(edit: edit ?? false, delete: delete ?? false, selectedId: selectedId)
        popoverContentVC.delegate = self
        popoverContentVC.preferredContentSize = CGSize(width: 120, height: 80)
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
    
    func selectId(id: String?, edit: Bool?) {
        PopupDelegate?.selectId(id: id, edit: edit)
    }
    
    func edit(edit:Bool,delete:Bool,selectedId:String){
        self.selectedId = selectedId
        self.delete = delete
        self.edit = edit
        optionsBtn.isHidden = !(edit || delete)
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
