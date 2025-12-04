//
//  MeetingDetailTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 12/08/25.
//

import UIKit

class MeetingDetailTV: UITableViewCell, SelectedId, UIPopoverPresentationControllerDelegate {
    func selectId(id: String?, edit: Bool?) {
        delegate?.selectId(id: id, edit: edit)
    }

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var MeetingNameLbl: UILabel!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var countBtn: UIButton!
    @IBOutlet weak var optionsBtn: UIButton!
    @IBOutlet weak var modeLbl: UILabel!
    @IBOutlet weak var datebaseView: UIView!
    @IBOutlet weak var timebaseView: UIView!
    @IBOutlet weak var imageStack: UIStackView!
    
    var showpopup:ShowPopupDelegate?
    var edit:Bool?
    var delete:Bool?
    var delegate:SelectedId?
    var selectedId:String?

    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.layer.cornerRadius = 15
        cellView.layer.borderWidth = 1
        cellView.layer.borderColor = UIColor.systemGray4.cgColor
        
        datebaseView.layer.cornerRadius = 15
        timebaseView.layer.cornerRadius = 15
        joinBtn.layer.cornerRadius = 15
        optionsBtn.layer.cornerRadius = optionsBtn.frame.width / 2
        
        optionsBtn.backgroundColor = .systemGray6
        datebaseView.backgroundColor = .systemGray6
        timebaseView.backgroundColor = .systemGray6
        
        dateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        timeBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        joinBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        countBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        MeetingNameLbl.setFont(style: .title, size: 17)
        modeLbl.setFont(style: .body, size: FontSize.BodySize)
        
        joinBtn.setTitle(PTMString.No_Slot_Booked_yet.translated(), for: .normal)
        
        img1.layer.cornerRadius = img1.frame.width / 2
        img2.layer.cornerRadius = img1.frame.width / 2
        img3.layer.cornerRadius = img1.frame.width / 2
        countBtn.layer.cornerRadius = img1.frame.width / 2
        
        edit = true
        delete = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cellView.clipsToBounds = true
        
        DispatchQueue.main.async {
            
            self.cellView.applyVerticalGradient(
                topColor: UIColor(
                    red: 184/255,
                    green: 201/255,
                    blue: 234/255,
                    alpha: 1
                ),
                bottomColor: UIColor(
                    red: 211/255,
                    green: 224/255,
                    blue: 245/255,
                    alpha: 1
                ) // darker bottom
            )
        }
        
//        cellView.applyVerticalGradient(
//            topColor: UIColor(red: 244/255, green: 227/255, blue: 202/255, alpha: 1), // #F4E3CA
//            bottomColor: UIColor(red: 250/255, green: 237/255, blue: 224/255, alpha: 1) // lighter
//        )
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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


import UIKit

//extension UIView {
//    func applyVerticalGradient(topColor: UIColor, bottomColor: UIColor) {
//        // Remove any existing gradient layer
//        layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
//        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // top
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // bottom
//        gradientLayer.frame = bounds
//        gradientLayer.cornerRadius = layer.cornerRadius
//        
//        layer.insertSublayer(gradientLayer, at: 0)
//    }
//}

extension UIView {
    private static let gradientLayerName = "CustomGradientLayer"

    func applyVerticalGradient(topColor: UIColor, bottomColor: UIColor) {
        // Check if gradient already exists
        if let existing = layer.sublayers?.first(where: { $0.name == UIView.gradientLayerName }) as? CAGradientLayer {
            existing.colors = [topColor.cgColor, bottomColor.cgColor]
            existing.frame = bounds
            return
        }

        let gradientLayer = CAGradientLayer()
        gradientLayer.name = UIView.gradientLayerName
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius

        layer.insertSublayer(gradientLayer, at: 0)
    }

    func updateGradientFrame() {
        if let gradientLayer = layer.sublayers?.first(where: { $0.name == UIView.gradientLayerName }) as? CAGradientLayer {
            gradientLayer.frame = bounds
        }
    }
}

// MARK: - TopMost VC helper
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
}
