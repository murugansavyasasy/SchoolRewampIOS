//
//  ExamDetailsVC.swift
//  VsSchoolChimes
//
//  Created by Lakshmanan on 27/03/25.
//
protocol Searchable: AnyObject {
    func childViewController(_ child: UIViewController, didUpdateDataIsEmpty isEmpty: Bool)
}

import UIKit

class ExamDetailsVC: UIViewController, Searchable {

    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var SegmentController: UISegmentedControl!
    @IBOutlet weak var PresentView: UIView!
    @IBOutlet weak var TimeTableBtn: UIButton!
    @IBOutlet weak var MarksBtn: UISegmentedControl!
    @IBOutlet weak var ExamMarksBtn: UIButton!
    @IBOutlet weak var ExamLbl: UILabel!
    @IBOutlet weak var searchBtn: UIButton!

    // MARK: - Child VC Instances (created ONCE)
    lazy var firstChildVC: ExamTmTblVCViewController = {
        let vc = ExamTmTblVCViewController()
        vc.delegate = self
        return vc
    }()

    lazy var secondChildVC: ExameMarVC = {
        let vc = ExameMarVC()
        vc.delegate = self
        return vc
    }()

    private var currentChildVC: UIViewController?

    var studentDetails = UserDefaultFileManager.get_child_Details()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadInitialChild()
    }

    // MARK: - UI Setup
    func setupUI() {
        ExamLbl.configureAsBackTitle(
            firstLine: studentDetails?.name ?? "",
            secondLine: "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        )

        TimeTableBtn.setTitle(ExamStringFile.examTimetable.translated(), for: .normal)
        ExamMarksBtn.setTitle(ExamStringFile.examMarks.translated(), for: .normal)

        NameLbl.text = studentDetails?.name ?? ""
        StandardLbl.text = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"

        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)

        addUnderline(to: TimeTableBtn, unselectedButton: ExamMarksBtn)
    }

    func loadInitialChild() {
        /// Load first VC only ONCE
        currentChildVC = firstChildVC
        addChild(firstChildVC)
        firstChildVC.view.frame = PresentView.bounds
        PresentView.addSubview(firstChildVC.view)
        firstChildVC.didMove(toParent: self)
    }

    // MARK: - Underline Handling
    func addUnderline(to selectedButton: UIButton, unselectedButton: UIButton) {
        // Remove old underline
        [selectedButton, unselectedButton].forEach {
            $0.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
            $0.tintColor = .black
        }

        // Add new underline
        let underline = UIView()
        underline.tag = 999
        underline.backgroundColor = .backGroundClr
        underline.translatesAutoresizingMaskIntoConstraints = false
        selectedButton.addSubview(underline)

        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 2),
            underline.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: selectedButton.trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: selectedButton.bottomAnchor)
        ])

        selectedButton.tintColor = .backGroundClr
    }

    // MARK: - SEARCH
    @IBAction func SearchIconAct(_ sender: Any) {
        if let tableVC = currentChildVC as? ExamTmTblVCViewController {
            tableVC.searchBar.isHidden.toggle()
        } else if let marksVC = currentChildVC as? ExameMarVC {
            marksVC.searchBar.isHidden.toggle()
        }
    }

    // MARK: - Segmented Control Action
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            switchToChild(firstChildVC)
        default:
            switchToChild(secondChildVC)
        }
    }

    @IBAction func TimetableBtnAct(_ sender: Any) {
        addUnderline(to: TimeTableBtn, unselectedButton: ExamMarksBtn)
        switchToChild(firstChildVC)
    }

    @IBAction func ExamMarkBtnAct(_ sender: Any) {
        addUnderline(to: ExamMarksBtn, unselectedButton: TimeTableBtn)
        switchToChild(secondChildVC)
    }

    // MARK: - Memory-Safe Transition
    func switchToChild(_ newVC: UIViewController) {
        guard newVC !== currentChildVC else { return }

        let oldVC = currentChildVC
        currentChildVC = newVC

        oldVC?.willMove(toParent: nil)
        addChild(newVC)

        newVC.view.frame = PresentView.bounds

        // Smooth transition
        transition(
            from: oldVC!,
            to: newVC,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil
        ) { _ in
            oldVC?.removeFromParent()
            newVC.didMove(toParent: self)
        }

        // Update empty state
        if let vc = newVC as? ExamTmTblVCViewController {
            childViewController(vc, didUpdateDataIsEmpty: vc.newExam?.isEmpty ?? true)
        } else if let vc = newVC as? ExameMarVC {
            childViewController(vc, didUpdateDataIsEmpty: vc.examList?.isEmpty ?? true)
        }
    }

    // MARK: - Delegate method
    func childViewController(_ child: UIViewController, didUpdateDataIsEmpty isEmpty: Bool) {
        searchBtn.isHidden = isEmpty
    }

    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
}


