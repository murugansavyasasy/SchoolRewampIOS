//
//  SenderQuizVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 18/08/25.
//

import UIKit

class SenderQuizVc: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var noOfQuestionDefaultLbl: UILabel!
    @IBOutlet weak var descrptionDefaultLbl: UILabel!
    @IBOutlet weak var titleDefaultLbl: UILabel!
    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var numberOfQuestionText: UITextField!
    @IBOutlet weak var discriptionsTextFild: UITextView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkBox: UIView!
    @IBOutlet weak var checkBoxImage: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!

    var initialHeight: CGFloat = 60
    var maxHeight: CGFloat = 300
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var selectNotice: SelectNotice?
    var isChecked = false
    var placeholderLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        fullView.layer.cornerRadius = 10
        titleText.delegate = self
        discriptionsTextFild.delegate = self
        titleText.addDoneButton()
        discriptionsTextFild.addDoneButton()
        numberOfQuestionText.addDoneButton()
        numberOfQuestionText.keyboardType = .numberPad
        setupPlaceholder()
        
        noOfQuestionDefaultLbl.setRequiredText(noOfQuestionDefaultLbl.text?.translated() ?? "")
        titleDefaultLbl.setRequiredText(MenuStringFile.Title)
        descrptionDefaultLbl.setRequiredText(MenuStringFile.description)
        
        nextBtn.layer.cornerRadius = 10
        discriptionsTextFild.layer.cornerRadius = 10
        
        checkBox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkboxAct)))
        checkBox.isUserInteractionEnabled = true
    }

    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.Description
        placeholderLabel.font = discriptionsTextFild.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8)
        discriptionsTextFild.applyRightTxt()
        discriptionsTextFild.applyRightTxt(with: placeholderLabel)
        discriptionsTextFild.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !discriptionsTextFild.text.isEmpty
    }

    @IBAction func backBtnAct(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func viewHistory(_ sender: UIButton) {
        let vc = ReportsQuizVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    @IBAction func checkboxAct() {
        isChecked.toggle()
        checkBoxImage.image = UIImage(
            systemName: isChecked ? "checkmark.circle.fill" : "circle"
        )
    }

    func textViewDidChange(_ textView: UITextView) {
        let size = textView.contentSize
        if size.height > initialHeight {
            textViewHeightConstraint.constant = min(size.height, maxHeight)
        }
        placeholderLabel.isHidden = !textView.text.isEmpty
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func createQuizBtnAct(_ sender: UIButton) {
        let trimmedTitle = titleText.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedDescription = discriptionsTextFild.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedQuestionCount = numberOfQuestionText.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !trimmedTitle.isEmpty,
              !trimmedDescription.isEmpty,
              let questionCount = Int(trimmedQuestionCount), questionCount > 0
        else {
            CustomAlert().showAlert(
                title: AlertstringFile.Alert_title,
                message: AlertstringFile.Please_fill,
                on: self
            )
            return
        }

        print("Title: \(trimmedTitle), Description: \(trimmedDescription), Count: \(questionCount)")

        let params: [String: Any] = [
            "title": trimmedTitle,
            "description": trimmedDescription,
            "no_of_question": questionCount,
            "level": user_inputs.level,
            "level_flag": isChecked
        ]

        let vc = RecipientVc(nibName: nil, bundle: nil)
        vc.ScreenType = Menu_id.quiz
        vc.Common_request_params = params
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
