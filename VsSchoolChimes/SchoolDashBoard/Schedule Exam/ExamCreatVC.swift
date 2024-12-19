//
//  ExamCreatVC.swift
//  VsSchoolChimes
//
//  Created by admin on 18/12/24.
//

import UIKit
import DropDown

class ExamCreatVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var setExam: UITextField!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var sectionBtn: UIButton!
    @IBOutlet weak var standerdBtn: UIButton!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var classView: UIView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var contentTxtView: UITextView!
    @IBOutlet weak var contentCount: UILabel!
    @IBOutlet weak var outerTextView: UIView!
    
    var sectionDropdown = DropDown()
    var classDropdown = DropDown()
    var exam: ExamsSchedule?
    var examArray = [
        ExamsSchedule(subjectName: "Commerce", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "Computer_Command sdsfd", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "English", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "Ezee Notes", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "Math_Lab", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "Physics", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "Tamil", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false),
        ExamsSchedule(subjectName: "Chemistry", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "FN", isSelected: false)
    ]
    
    var placeholderLabel: UILabel!
    var isKeyboardVisible = false
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupPlaceholder()
        resetExam()
        keyboardDionebtn()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        guard !isKeyboardVisible else { return } // Prevent unnecessary animations
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            isKeyboardVisible = true
            UIView.animate(withDuration: 0.3) {
                // Move outerView 20 points from the top
                self.outerView.transform = CGAffineTransform(translationX: 0, y: -self.outerView.frame.origin.y - 100)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard isKeyboardVisible else { return } // Ensure this logic runs only if the keyboard is open
        isKeyboardVisible = false
        UIView.animate(withDuration: 0.3) {
            self.outerView.transform = .identity // Reset position
        }
    }
    // MARK: - UI Setup
    func setupUI() {
        contentTxtView.delegate = self
        
        // Styling for views
        [outerView, outerTextView, sectionView, classView].forEach { view in
            view?.layer.cornerRadius = 10
            view?.layer.borderWidth = 0.5
            view?.layer.borderColor = UIColor.black.cgColor
        }
        
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        
        titleLbl.setFont(style: .header, size: FontSize.HeaderSize)
        contentCount.setFont(style: .body, size: FontSize.BodySize)
        sectionBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        standerdBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        setExam.placeholder = "Enter Exam"
        titleLbl.text = "Create Exam"
        contentCount.text = "0 of 500"
    }
    func keyboardDionebtn(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: AlertstringFile.Done, style: .done, target: self, action: #selector(doneKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        setExam.inputAccessoryView = toolbar
        contentTxtView.inputAccessoryView = toolbar
    }
    @objc func doneKeyboard() {
        view.endEditing(true)
    }
    // MARK: - Placeholder Setup
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.EnterTextHere
        placeholderLabel.font = contentTxtView.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8)
        contentTxtView.addSubview(placeholderLabel)
        
        placeholderLabel.isHidden = !contentTxtView.text.isEmpty
    }
    
    // MARK: - TextView Delegate
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        adjustTextViewHeightWithConstraint(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        if updatedText.count <= 500 {
            contentCount.text = "\(updatedText.count) of 500"
            return true
        } else {
            CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            return false
        }
    }
    
    func adjustTextViewHeightWithConstraint(_ textView: UITextView) {
        let sizeThatFits = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        textViewHeightConstraint.constant = max(sizeThatFits.height, 120)
        textView.layoutIfNeeded()
    }
    
    // MARK: - Section and Class DropDowns
    @IBAction func section(_ sender: UIButton) {
        setupDropDown(dropDown: sectionDropdown, dataSource: ["A", "B", "C", "D"], anchorView: sectionView, button: sectionBtn)
    }
    
    @IBAction func classSelection(_ sender: UIButton) {
        setupDropDown(dropDown: classDropdown, dataSource: ["8th", "9th", "10th", "11th", "12th"], anchorView: classView, button: standerdBtn)
    }
    
    func setupDropDown(dropDown: DropDown, dataSource: [String], anchorView: UIView, button: UIButton) {
        dropDown.dataSource = dataSource
        dropDown.anchorView = anchorView
        dropDown.bottomOffset = CGPoint(x: 0, y: anchorView.bounds.height)
        dropDown.direction = .bottom
        dropDown.width = anchorView.bounds.width
        dropDown.show()
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            button.setTitle(item, for: .normal)
        }
    }
    
    // MARK: - Reset Exam
    func resetExam() {
        exam = ExamsSchedule(subjectName: "", subjectSyllabus: "", date: "", mark: "", imageName: "book-pencil", session: "", isSelected: false)
    }

    
    // MARK: - Schedule Exam
    @IBAction func exameSchedule(_ sender: UIButton) {
    
        let vc = ScheduleExamVC()
        vc.modalPresentationStyle = .fullScreen
        vc.examArray = examArray
        present(vc, animated: true)
    }
    
    // MARK: - Back Button
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
