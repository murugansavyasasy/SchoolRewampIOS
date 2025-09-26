//
//  ExamDetailsVC.swift
//  VsSchoolChimes
//
//  Created by Lakshmanan on 27/03/25.
//
protocol Searchable: AnyObject {
    func updateSearchResults(for query: String)
}

import UIKit

class ExamDetailsVC: UIViewController {
    
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var SegmentController: UISegmentedControl!
    @IBOutlet weak var PresentView: UIView!
    @IBOutlet weak var TimeTableBtn: UIButton!
    @IBOutlet weak var MarksBtn: UISegmentedControl!
    @IBOutlet weak var ExamMarksBtn: UIButton!
    @IBOutlet weak var ExamLbl: UILabel!
    
    
    let firstChildVC = ExamTmTblVCViewController(nibName: nil, bundle: nil)
    let secondChildVC = ExameMarVC()
    var currentChildVC: UIViewController?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        ExamLbl.configureAsBackTitle(firstLine: studentDetails?.name ?? "", secondLine: "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")")
        
        TimeTableBtn.setTitle(ExamStringFile.examTimetable, for: .normal)
        ExamMarksBtn.setTitle(ExamStringFile.examMarks, for: .normal)
        TimeTableBtn.setTitleFont(style: .body, size: FontSize.TitleSize)
        ExamMarksBtn.setTitleFont(style: .body, size: FontSize.HeaderSize)
        
        addUnderline(to: TimeTableBtn, unselectedButton: ExamMarksBtn)
        
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.text = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        NameLbl.text = studentDetails?.name ?? ""
        currentChildVC = firstChildVC
        add(asChildViewController: firstChildVC)
        
    }
    
    
    func addUnderline(to selectedButton: UIButton, unselectedButton: UIButton) {
        // Remove underline from both buttons
        [selectedButton, unselectedButton].forEach { button in
            button.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
            button.tintColor = .black
        }
        
        // Add underline to the selected button
        selectedButton.tintColor = .systemBlue
        let underline = UIView()
        underline.tag = 999
        underline.backgroundColor = .systemBlue
        underline.translatesAutoresizingMaskIntoConstraints = false
        selectedButton.addSubview(underline)
        
        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 2),
            underline.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: selectedButton.trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: selectedButton.bottomAnchor)
        ])
    }
    
    @IBAction func SearchIconAct(_ sender: Any) {
        
        if let childA = currentChildVC as? ExamTmTblVCViewController {
            childA.searchBar.isHidden.toggle()
        }
        else if let childB = currentChildVC as? ExameMarVC {
            childB.searchBar.isHidden.toggle()
        }
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
    
    @IBAction func TimetableBtnAct(_ sender: Any) {
        
        addUnderline(to: TimeTableBtn, unselectedButton: ExamMarksBtn)
        transition(to: firstChildVC)
    }
    @IBAction func ExamMarkBtnAct(_ sender: Any) {
        
        addUnderline(to: ExamMarksBtn, unselectedButton: TimeTableBtn)
        transition(to: secondChildVC)
    }
    
}

extension ExamDetailsVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}
