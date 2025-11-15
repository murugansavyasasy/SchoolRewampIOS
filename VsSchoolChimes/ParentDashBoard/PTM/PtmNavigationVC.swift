//
//  PtmNavigationVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 28/09/25.
//

import UIKit

class PtmNavigationVC: UIViewController {

    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var StudentNameLbl: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var yourMeetingBtn: UIButton!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var scheduleMeetingBtn: UIButton!
    
    let firstChildVC = PtmParentVC(nibName: nil, bundle: nil)
    let secondChildVC = PtmHistoryVC()
    var currentChildVC: UIViewController?
    var childDetails = UserDefaultFileManager.get_child_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let name = childDetails?.name ?? ""
        let standard = (childDetails?.standard_name ?? "") + " - " + (childDetails?.section_name ?? "")
        StudentNameLbl.configureAsBackTitle(firstLine: name, secondLine: standard)
        
        searchBtn.isHidden = true
        
        scheduleMeetingBtn.setTitle("Book PTM Slots", for: .normal)
        yourMeetingBtn.setTitle(PTMString.yourMeetings, for: .normal)
        
        scheduleMeetingBtn.setTitleFont(style: .body, size: FontSize.HeaderSize)
        yourMeetingBtn.setTitleFont(style: .body, size: FontSize.HeaderSize)
        
        scheduleMeetingBtn.layer.cornerRadius = 12
        scheduleMeetingBtn.backgroundColor = .white
        yourMeetingBtn.layer.cornerRadius = 12
        // Do any additional setup after loading the view.
        currentChildVC = firstChildVC
        add(asChildViewController: firstChildVC)
    }
    
    
    @IBAction func scheduleMeetingAct(_ sender: Any) {
        scheduleMeetingBtn.backgroundColor = .white
        yourMeetingBtn.backgroundColor = .clear
        searchBtn.isHidden = true
        firstChildVC.Reload()
        transition(to: firstChildVC)
//        removeChildVc()
//        getSlotsApi()
    }
    @IBAction func yourMeetingAct(_ sender: Any) {
        scheduleMeetingBtn.backgroundColor = .clear
        yourMeetingBtn.backgroundColor = .white
        searchBtn.isHidden = false
        
        transition(to: secondChildVC)
       // addChildVc()
    }
    
    func childViewController(_ child: UIViewController, didUpdateDataIsEmpty isEmpty: Bool) {
        searchBtn.isHidden = isEmpty
    }
    
    @IBAction func backAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func searchBtnAct(_ sender: UIButton) {
        
        if let child = currentChildVC as? PtmHistoryVC {
            sender.isSelected.toggle()
            let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
            searchBtn.setImage(UIImage(systemName: icon), for: .normal)
            child.searchBtnAct(selected: sender.isSelected)
        }
    }

    func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        addChild(viewController)
        
        // Configure Child View
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)
        
        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }
    
    // Transition between child view controllers with animation
    func transition(to newVC: UIViewController) {
        guard let currentVC = currentChildVC, newVC != currentVC else { return }
        
        // Begin transition
        currentVC.willMove(toParent: nil)
        addChild(newVC)
        newVC.view.frame = containerView.bounds
        
        // Choose an animation option, for example cross dissolve
        transition(from: currentVC, to: newVC, duration: 0.3, options: [.transitionCrossDissolve], animations: nil) { finished in
            currentVC.removeFromParent()
            newVC.didMove(toParent: self)
            self.currentChildVC = newVC
        }
    }
}
