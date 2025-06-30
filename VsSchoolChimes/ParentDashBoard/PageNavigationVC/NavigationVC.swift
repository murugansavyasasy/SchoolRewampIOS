//
//  NavigationVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit

@available(iOS 14.0, *)
class NavigationVC: UIViewController {
  
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
        displaySegment(index: SegmentControl.selectedSegmentIndex)
       
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    
    func uiConficration(){
        NameLbl.text = childDetails?.name
        StandardLbl.text = (childDetails?.standard_name ?? "") + " - " + (childDetails?.section_name ?? "")
        backBtn.setTitle(MenuStringFile.LeaveRequest, for: .normal)
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
    }
    
    @IBAction func SegmentAct(_ sender: Any) {
        
        displaySegment(index: SegmentControl.selectedSegmentIndex)
    }
    
    func displaySegment(index: Int) {
        // Remove current child VC if exists
        if let current = currentChildVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        // Instantiate the new child VC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var newVC: UIViewController

        if index == 0 {
            newVC = LeveCreateVC(nibName: nil, bundle: nil)
        } else {
            newVC = LeveHistoryVC(nibName: nil, bundle: nil)
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
