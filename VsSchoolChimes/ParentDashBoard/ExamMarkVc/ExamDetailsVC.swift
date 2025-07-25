//
//  ExamDetailsVC.swift
//  VsSchoolChimes
//
//  Created by Lakshmanan on 27/03/25.
//

import UIKit

class ExamDetailsVC: UIViewController {
    
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var SegmentController: UISegmentedControl!
    @IBOutlet weak var PresentView: UIView!
    
    let firstChildVC = ExamTmTblVCViewController(nibName: nil, bundle: nil)
    let secondChildVC = ExameMarVC()
    var currentChildVC: UIViewController?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //BackBtn.setTitle("Exam/Test", for: .normal)
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.text = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        NameLbl.text = studentDetails?.name ?? ""
        currentChildVC = firstChildVC
        add(asChildViewController: firstChildVC)
        
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            transition(to: firstChildVC)
        } else {
            transition(to: secondChildVC)
        }
    }
    
    // Add a child view controller
    func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)
        
        // Configure Child View
        viewController.view.frame = PresentView.bounds
        PresentView.addSubview(viewController.view)
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    // Transition between child view controllers with animation
    func transition(to newVC: UIViewController) {
        guard let currentVC = currentChildVC, newVC != currentVC else { return }
        
        // Begin transition
        currentVC.willMove(toParent: nil)
        addChild(newVC)
        newVC.view.frame = PresentView.bounds
        
        // Choose an animation option, for example cross dissolve
        transition(from: currentVC, to: newVC, duration: 0.3, options: [.transitionCrossDissolve], animations: nil) { finished in
            currentVC.removeFromParent()
            newVC.didMove(toParent: self)
            self.currentChildVC = newVC
        }
    }
    
    @IBAction func BackAct(_ sender: Any) {
        
       
                dismiss(animated: true)
     
    }
}
