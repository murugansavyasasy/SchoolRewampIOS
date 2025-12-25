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
    @IBOutlet weak var checkBoxDefaultLbl: LocalizationLabel!
    
    var initialHeight: CGFloat = 60
    var maxHeight: CGFloat = 300
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var selectNotice: SelectNotice?
    var isChecked = false
    var placeholderLabel: UILabel!
    var editQuiz: EditQuiz?
    var Common_request_params: [String:Any] = [:]
    var isReset = false

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
        numberOfQuestionText.placeholder = MenuStringFile.No_of_question.translated()
        titleText.placeholder = MenuStringFile.Title.translated()
        noOfQuestionDefaultLbl.setRequiredText(noOfQuestionDefaultLbl.text ?? "")
        titleDefaultLbl.setRequiredText(MenuStringFile.Title)
        descrptionDefaultLbl.setRequiredText(MenuStringFile.description)
        nextBtn.layer.cornerRadius = 10
        discriptionsTextFild.layer.cornerRadius = 10
        checkBox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(checkboxAct)))
        checkBox.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let edit = editQuiz, edit.isEdit == true {
            titleText.text = edit.title
            discriptionsTextFild.text = edit.description
            numberOfQuestionText.text = String(edit.noOfQuestions ?? 0)
            checkBoxImage.image = UIImage(systemName: (edit.levelFlag ?? false) ? "checkmark.circle.fill" : "circle")
            nextBtn.setTitle("Update", for: .normal)
            placeholderLabel.isHidden = !discriptionsTextFild.text.isEmpty
            noOfQuestionDefaultLbl.alpha = 0.5
            numberOfQuestionText.textColor = .lightGray
            checkBoxImage.tintColor = .systemBlue.withAlphaComponent(0.4)
            checkBoxDefaultLbl.textColor = .lightGray
            checkBox.isUserInteractionEnabled = false
            numberOfQuestionText.isUserInteractionEnabled = false
            
        }else{
            
            if isReset{
                titleText.text = ""
                discriptionsTextFild.text = ""
                numberOfQuestionText.text = ""
                checkBoxImage.image = UIImage(systemName: "circle")
                isReset = false
            }
            nextBtn.setTitle("NEXT", for: .normal)
            placeholderLabel.isHidden = !discriptionsTextFild.text.isEmpty
            checkBox.isUserInteractionEnabled = true
            numberOfQuestionText.isUserInteractionEnabled = true
            noOfQuestionDefaultLbl.alpha = 1
            numberOfQuestionText.textColor = .black
            checkBoxImage.tintColor = .systemBlue
            checkBoxDefaultLbl.textColor = .black
        }
    }

    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text = CommonStringFile.Description.translated()
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
    
    func update_Quiz(){
        
        let param : [String:Any] = [
            "id": editQuiz?.id ?? "",
            "title": titleText.text ?? "",
            "description": discriptionsTextFild.text ?? ""
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.lms_api_quiz_update, parameters: param, type: ApitTypeSringFile.PUT, token: staffDetails?.access_token ?? "") { [weak self] (result: Result<CommonApiSuc,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    if success.status == true{
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success, message: success.message ?? "", on: self) {
                            self.dismiss(animated: true)
                        }
                    }else{
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                    }
                    
                case .failure(let failure):
                    
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
                }
            }
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
        
        if editQuiz != nil{
            CustomAlert().showAlertCancel(title: AlertstringFile.Confirm, message: "Are you sure want to update this Quiz?", actionLbl1: AlertstringFile.Yes, actionLbl2: AlertstringFile.Cancel, on: self) {
                
                self.update_Quiz()
            } onNo: {}

        }else{
            
            let alert = UIAlertController(
                title: AlertstringFile.Alert_title,
                message: "You haven't added questions to this quiz yet. Would you like to add them or do it later?",
                preferredStyle: .alert
            )
            
            let cancelAction = UIAlertAction(title: AlertstringFile.Cancel, style: .cancel) { _ in
                print("Cancel tapped")
            }
            
            let laterAction = UIAlertAction(title: "Later", style: .default) { _ in
                self.AddLater()
            }
            
            let okAction = UIAlertAction(title: "Add Now", style: .default) { _ in
                self.AddNow()
            }
            alert.addAction(cancelAction)
            alert.addAction(laterAction)
            alert.addAction(okAction)
            present(alert, animated: true)
        }
    }
    
    func AddLater(){
        
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
            QuizRequestStringFile.title: trimmedTitle,
            QuizRequestStringFile.description: trimmedDescription,
            QuizRequestStringFile.no_of_question: questionCount,
            QuizRequestStringFile.level: user_inputs.level,
            QuizRequestStringFile.level_flag: isChecked
        ]

        let vc = RecipientVc(nibName: nil, bundle: nil)
        vc.ScreenType = Menu_id.quiz
        vc.Common_request_params = params
        vc.questions = []
        vc.QuestionBankData = []
        vc.isQuiz_open_to_students = false
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
       
    }
    
    func AddNow(){
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

        let params: [String: Any] = [
        QuizRequestStringFile.title: trimmedTitle,
        QuizRequestStringFile.description: trimmedDescription,
        QuizRequestStringFile.no_of_question: questionCount,
        QuizRequestStringFile.level: user_inputs.level,
        QuizRequestStringFile.level_flag: isChecked
    ]
        let vc = CreateQuizQutionVc(nibName: nil, bundle: nil)
        vc.Common_request_params = params
        vc.noOfQuestion = Int(numberOfQuestionText.text ?? "0") ?? 0
        vc.titleString = titleText.text ?? ""
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
