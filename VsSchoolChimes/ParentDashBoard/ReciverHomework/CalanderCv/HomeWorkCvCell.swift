//
//  HomeWorkCvCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 22/07/25.
//

import UIKit


class HomeWorkCvCell: UICollectionViewCell,SelectedId, UIPopoverPresentationControllerDelegate {
    func selectId(id: String?, edit: Bool?) {
        delegate?.selectId(id:id, edit: edit)
    }
    @IBOutlet weak var homeWorkCompletImg: UIImageView!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var stafNamLbl: UILabel!
    @IBOutlet weak var roundview: UIView!
    @IBOutlet weak var threeDotBtn: UIButton!
    @IBOutlet weak var newImage: UIImageView!
    
    var delegate:SelectedId?
    var edit:Bool?
    var delete:Bool?
    var selectedId:String?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        roundview.layer.cornerRadius = roundview.frame.width/2
        contentView.layer.masksToBounds = true
        applyShadowAndCornerRadius(to: contentView)
        homeWorkCompletImg.isHidden = true
        newImage.isHidden = true
    }
    
    @IBAction func threeDotBtnAction(_ sender: UIButton) {
        
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
        homeWorkCompletImg.isHidden = !(edit || delete)
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        // Ensure the popup style is maintained on iPhone
        return .none
    }
//    
//    func setProgress(to percentage: Double) {
//        let progressEntry = PieChartDataEntry(value: percentage, label: nil)
//        let emptyEntry = PieChartDataEntry(value: 100 - percentage, label: nil)
//        
//        let progressColor = colorForPercentage(percentage)
//        let progressDataSet = PieChartDataSet(entries: [progressEntry, emptyEntry], label: "Hello")
//        progressDataSet.colors = [progressColor, UIColor.lightGray]
//        progressDataSet.drawValuesEnabled = false
//        // Display Percentage in the Center
//        let percentageText = "\(Int(percentage))%"
//        let attributedString = NSAttributedString(
//            string: percentageText,
//            attributes: [
//                .font: UIFont(name: "Poppins-Bold", size: 11), // Change font size
//                .foregroundColor: UIColor.homeWorkClr // Change text color
//            ]
//        )
//        
//    }
    
    func colorForPercentage(_ percentage: Double) -> UIColor {
        switch percentage {
            //        case 0...20:
            //            return UIColor.systemRed.withAlphaComponent(0.8)
            //        case 21...40:
            //            return UIColor.systemOrange.withAlphaComponent(0.8)
            //        case 41...60:
            //            return UIColor.systemYellow.withAlphaComponent(0.8)
            //        case 61...100:
            //            return UIColor.systemGreen.withAlphaComponent(0.8)
        case 1...99:
            return UIColor.homeWorkClr.withAlphaComponent(0.8)
        case 100:
            return UIColor.systemGreen.withAlphaComponent(0.8)
        default:
            return UIColor.lightGray // Default color (0% or invalid input)
        }
    }
}
