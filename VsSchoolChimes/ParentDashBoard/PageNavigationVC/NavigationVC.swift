//
//  NavigationVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit
protocol EditObject{
    func edit(edit:editLeave?)
}
@available(iOS 14.0, *)

class NavigationVC: UIViewController, EditObject {
    func edit(edit: editLeave?) {
        SegmentControl.selectedSegmentIndex = 0
        displaySegment(index: SegmentControl.selectedSegmentIndex, edit:edit)
    }
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var presentView: UIView! //
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var SegmentControl: UISegmentedControl!
    
    var currentChildVC: UIViewController?
    var childDetails = UserDefaultFileManager.get_child_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiConficration()
        backBtn.applyBackButton()
        displaySegment(index: SegmentControl.selectedSegmentIndex, edit: nil)
       
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    
    func uiConficration(){
        NameLbl.text = childDetails?.name
        StandardLbl.text = (childDetails?.standard_name ?? "") + " - " + (childDetails?.section_name ?? "")
        backBtn.setTitle(MenuStringFile.selectedMenuName, for: .normal)
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
    }
    
    @IBAction func SegmentAct(_ sender: Any) {
        displaySegment(index: SegmentControl.selectedSegmentIndex, edit: nil)
    }
    
    func displaySegment(index: Int,edit:editLeave?) {
        // Remove current child VC if exists
        if let current = currentChildVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        var newVC: UIViewController

        if index == 0 {
            newVC = LeveCreateVC(nibName: nil, bundle: nil)
        } else {
            newVC = LeveHistoryVC(nibName: nil, bundle: nil)
            if let vc = newVC as? LeveHistoryVC{
                vc.delegate = self
            }
            
            
        }
        if let edit = edit {
            if let vc = newVC as? LeveCreateVC{
                vc.leave = edit
            }
        }

        // Add new child VC
        addChild(newVC)
        newVC.view.frame = presentView.bounds
        newVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentView.addSubview(newVC.view)
        newVC.didMove(toParent: self)

        // Update reference
        currentChildVC = newVC
    }

    
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }

}
struct editLeave{
    let id :String?
    var fromDate:String
    var toDate:String
    var reson:String
}
