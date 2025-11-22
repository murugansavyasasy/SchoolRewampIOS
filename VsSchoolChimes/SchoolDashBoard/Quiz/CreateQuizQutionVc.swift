//
//  CreateQuizQutionVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 19/08/25.
//

import UIKit
extension CreateQuizQutionVc: QuestionCellDelegate {
    
    func checkboxAction(id: String, isSelected: Bool) {
            if isSelected {
                selectedQuestionIds.insert(id)
            } else {
                selectedQuestionIds.remove(id)
            }
           updateSelectAllButtonState()
        }
    
    func addAnotherCell(at indexPath: IndexPath) {
        
        if let errorMessage = validateQuestions() {
            CustomAlert.showAlertWithOkAction(title: "Missing Information", message: errorMessage, on: self)
            return
        }
        
        questions.insert(QuizQuestiondata(), at: indexPath.row + 1)
        tv.reloadData()
        self.QuestionNoLbl.text = "Question Limit: " + String(self.questions.count) + "/" + String(self.noOfQuestion)
    }
        
    func updateQuestion(at indexPath: IndexPath, model: QuizQuestiondata) {
        var existing = questions[indexPath.row]

        if let existingId = existing.id {
            existing.id = existingId
        }

        if let existingQuizId = existing.quiz_id {
            existing.quiz_id = existingQuizId
        }
        
        if let newAnswer = model.answer, !newAnswer.isEmpty {
            existing.answer = newAnswer
        }

        if let newText = model.correct_answer_text, !newText.isEmpty {
            existing.correct_answer_text = newText
        }
        existing.chapter = model.chapter
        existing.question = model.question
        existing.a_option = model.a_option
        existing.b_option = model.b_option
        existing.c_option = model.c_option
        existing.d_option = model.d_option
        existing.mark = model.mark
        existing.file_path = model.file_path
        questions[indexPath.row] = existing
    }
        
        func removeCell(at indexPath: IndexPath) {
            guard questions.count > 1 else { return }
            questions.remove(at: indexPath.row)
            tv.reloadData()
            self.QuestionNoLbl.text = "Question Limit: " + String(self.questions.count) + "/" + String(self.noOfQuestion)
        }
    
    func addAttachment(at indexPath: IndexPath, file: FilePaths) {
           // append the file into question model
        if questions[indexPath.row].file_path == nil {
            questions[indexPath.row].file_path = []
           }
       }
}

class CreateQuizQutionVc: UIViewController {
   
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var popupBGview: UIView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var ImportQuestionBtn: UIButton!
    @IBOutlet weak var QuestionBankTv: UITableView!
    @IBOutlet weak var CancelBtn: UIButton!
    @IBOutlet weak var sendQuizBtn: UIButton!
    @IBOutlet weak var QuestionNoLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    
    
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    var id  : String?
    var questions: [QuizQuestiondata] = [QuizQuestiondata()]
    var noOfQuestion: Int = 0
    var subject_Id : String?
    var QuestionBankData: [QuestionItem] = []
    var selectedQuestionIds: Set<String> = []
    var titleString = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupBGview.isHidden = true
        popupView.layer.cornerRadius = 10
        popupView.layer.shadowColor = UIColor.black.cgColor
        popupView.layer.shadowOpacity = 0.3
        popupView.layer.shadowOffset = CGSize(width: 2, height: 2)
        popupView.layer.shadowRadius = 3
        
        ImportQuestionBtn.layer.cornerRadius = 10
        CancelBtn.layer.cornerRadius = 10
        sendQuizBtn.layer.cornerRadius = 10
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        TitleLbl.text = titleString
        
        tv.register(UINib(nibName: "QuistionTvTableViewCell", bundle: nil),
                forCellReuseIdentifier: "QuistionTvTableViewCell")
        tv.dataSource = self
        tv.delegate = self
        
        QuestionBankTv.register(UINib(nibName: "QuistionTvTableViewCell", bundle: nil),
                forCellReuseIdentifier: "QuistionTvTableViewCell")
        QuestionBankTv.dataSource = self
        QuestionBankTv.delegate = self
        
        addQuestion(id:id ?? "" )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        tv.contentInset.bottom = keyboardHeight
        tv.scrollIndicatorInsets.bottom = keyboardHeight
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        tv.contentInset.bottom = 0
        tv.scrollIndicatorInsets.bottom = 0
    }

    
    
    @IBAction func btnAct(_ sender: UIButton) {
        
        if let errorMessage = validateQuestions() {
            CustomAlert.showAlertWithOkAction(title: "Missing Information".translated(), message: errorMessage, on: self)
            return
        }
        
        submitQuestions()
    }
    
    func addQuestion(id :String) {
        
        APIService.shared.makeApi(
            url: ServiceUrl.quiz_questions_report,
            parameters: ["id": id ],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<QuizaddQuestionSuc, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.status == true, let data = res.data, !data.isEmpty {
                        self.questions = data   // use API data
                    } else {
                        self.questions = [QuizQuestiondata()] // fallback to one empty
                    }
                    self.QuestionNoLbl.text = "Question Limit: " + String(self.questions.count) + "/" + String(self.noOfQuestion)
                    self.tv.reloadData()
                case .failure:
                    DispatchQueue.main.async {
                        self.questions = [QuizQuestiondata()] // fallback
                        self.tv.reloadData()
                    }
                }
            }
        }
    }
    
    func submitQuestions() {
        let params = buildQuizParams()
        APIService.shared.makeApi(
            url: ServiceUrl.quiz_add_question,
            parameters:params,
            type: ApitTypeSringFile.POST,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<QuizaddQuestionSuc, Error>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let res):
                    
                    if res.status == true{
                        
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success, message: res.message ?? "", on: self) {
                            self.dismiss(animated: true)
                        }
                    }else {
                        
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: res.message ?? "", on: self)
                    }
                    
                case .failure(let error):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
                }
            }
        }
    }
    
    func buildQuizParams() -> [String: Any] {
        // 1. Convert all QuizQuestiondata → questions
        let dictArray: [[String: Any]] = questions.map { q in
            [
                "ques_no": q.id ?? "",  // use id if available, else ""
                "chapter": q.chapter,
                "question": q.question,
                "a_option": q.a_option,
                "b_option": q.b_option,
                "c_option": q.c_option,
                "d_option": q.d_option,
                "answer": q.answer ?? "",
                "mark": q.mark ?? 0,
                "iframe": "",
                "file_size": "",
                "thumbnail": "",
                "file_path": (q.file_path?.isEmpty ?? true)
                    ? []
                    : q.file_path!.map { ["url": $0.url, "type": $0.type] }
            ]
        }
        
        // 2. Lookup QuestionBankData by id
        let questionBankLookup: [String: QuestionItem] = Dictionary(
            uniqueKeysWithValues: QuestionBankData.compactMap { item in
                guard let id = item.id else { return nil }
                return (id, item)
            }
        )
        
        // 3. Only imported questions (id present in QuestionBankData)
        let importedQuestions = questions.filter { q in
            if let qid = q.id {
                return questionBankLookup[qid] != nil
            }
            return false
        }
        
        // 4. Map imported questions → update_question_bank
        let updateArray: [[String: Any]] = importedQuestions.compactMap { q in
            guard let qid = q.id, let bankItem = questionBankLookup[qid] else { return nil }
            return [
                "ques_no": qid,                        // use bank id
                "subject_id": bankItem.subject_id ?? "",
                "chapter": q.chapter,
                "question": q.question,
                "a_option": q.a_option,
                "b_option": q.b_option,
                "c_option": q.c_option,
                "d_option": q.d_option,
                "answer": q.answer ?? "",
                "mark": q.mark ?? 0
            ]
        }
        
        // 5. Calculate total marks
        let totalMarks = questions.compactMap { $0.mark }.reduce(0, +)
        
        // 6. Build final params
        return [
            "quiz_id": id ?? "",
            "questions": dictArray,
            "max_mark": totalMarks,
            "ok_flag": false,
            "update_question_bank": updateArray
        ]
    }
    
    func get_QuestionBank_Api(){
        
        APIService.shared.makeApi(url: ServiceUrl.lms_api_quiz_pick_from_qbank, parameters: ["subject_id": subject_Id ?? ""], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [weak self] (result:Result<QuestionsResponse,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        self.QuestionBankData = success.data ?? []
                        self.popupBGview.isHidden = false
                        self.updateSelectAllButtonState()
                        self.selectedQuestionIds = Set(self.questions.compactMap { $0.id })
                        self.QuestionBankTv.reloadData()
                        
                    }else {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                    }
                   
                    
                case .failure(let failure):
                    
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
                }
            }
            
        }
    }

    func validateQuestions() -> String? {
        for (i, q) in questions.enumerated() {
            if q.chapter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Please fill the Chapter for Question \(i + 1)."
            }
            if q.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || q.question == "Enter Question here"{
                return "Please fill the Question text for Question \(i + 1)."
            }
            if q.a_option.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || q.a_option == "Enter Option A"{
                return "Please provide Option A for Question \(i + 1)."
            }
            if q.b_option.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || q.b_option == "Enter Option B"{
                return "Please provide Option B for Question \(i + 1)."
            }
            if q.c_option.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || q.c_option == "Enter Option C"{
                return "Please provide Option C for Question \(i + 1)."
            }
            if q.d_option.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || q.d_option == "Enter Option D"{
                return "Please provide Option D for Question \(i + 1)."
            }
            if q.answer == nil || q.answer == "Select correct answer" {
                return "Please select the correct answer for Question \(i + 1)."
            }
            if q.correct_answer_text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                return "Please select the correct answer text for Question \(i + 1)."
            }
            if q.mark == nil || q.mark == 0 {
                return "Please assign marks for Question \(i + 1)."
            }
        }
        return nil // ✅ all good
    }

    
    @IBAction func ImportquestionAct(_ sender: Any) {
        
        get_QuestionBank_Api()
    }
    
    @IBAction func BackBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    @IBAction func AddImportQuestionAct(_ sender: Any) {
        // ✅ First check if nothing is selected
        if selectedQuestionIds.isEmpty {
            CustomAlert.showAlertWithOkAction(
                title: "No Selection",
                message: "You didn’t select any questions from the Question Bank.",
                on: self
            )
            return
        }

        // ✅ Then check the limit
        if selectedQuestionIds.count > noOfQuestion {
            CustomAlert.showAlertWithOkAction(
                title: "Limit Reached",
                message: "You exceed the maximum number of questions (\(noOfQuestion)).",
                on: self
            )
            return
        }

        // 1. Remove questions that are no longer selected
        questions.removeAll { quizQ in
            guard let id = quizQ.id else { return false }
            return !selectedQuestionIds.contains(id)
        }

        // 2. Add new ones that were selected but not yet in `questions`
        for id in selectedQuestionIds {
            if !questions.contains(where: { $0.id == id }),
               let bankItem = QuestionBankData.first(where: { $0.id == id }) {

                let answerIndex = Int(bankItem.answer ?? "")
                var correctText: String? = nil
                if let idx = answerIndex {
                    switch idx {
                    case 1: correctText = bankItem.a_option
                    case 2: correctText = bankItem.b_option
                    case 3: correctText = bankItem.c_option
                    case 4: correctText = bankItem.d_option
                    default: break
                    }
                }

                let newQuizQ = QuizQuestiondata(
                    id: bankItem.id,
                    quiz_id: nil,
                    chapter: bankItem.chapter ?? "",
                    question: bankItem.question ?? "",
                    answer: bankItem.answer,
                    a_option: bankItem.a_option ?? "",
                    b_option: bankItem.b_option ?? "",
                    c_option: bankItem.c_option ?? "",
                    d_option: bankItem.d_option ?? "",
                    mark: bankItem.mark,
                    correct_answer_text: correctText
                )
                questions.append(newQuizQ)
            }
        }

        // 3. Refresh main table
        tv.reloadData()

        // 4. Dismiss popup
        popupBGview.isHidden = true

        QuestionNoLbl.text = "Question Limit: \(questions.count)/\(noOfQuestion)"
    }


    @IBAction func cancelAct(_ sender: Any) {
        
            selectedQuestionIds = Set(questions.compactMap { $0.id }) // reset to actual imported
            popupBGview.isHidden = true
            QuestionBankTv.reloadData()
            QuestionNoLbl.text = "Question Limit: \(questions.count)/\(noOfQuestion)"
    }
    
    @IBAction func selectAllAct(_ sender: Any) {
        let shouldSelectAll = selectedQuestionIds.count != QuestionBankData.count
        
        if shouldSelectAll {
            // Check limit
            if questions.count + QuestionBankData.count > noOfQuestion {
                CustomAlert.showAlertWithOkAction(
                    title: "Limit Reached",
                    message: "You cannot select all because it exceeds the maximum number of questions (\(noOfQuestion)).",
                    on: self
                )
                return
            }
            selectedQuestionIds = Set(QuestionBankData.compactMap { $0.id })
            selectAllBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            selectedQuestionIds.removeAll()
            selectAllBtn.setImage(UIImage(systemName: "square"), for: .normal)
        }
        
        QuestionBankTv.reloadData()
        QuestionNoLbl.text = "Question Limit: \(questions.count + selectedQuestionIds.count)/\(noOfQuestion)"
        updateSelectAllButtonState()
    }

    private func updateSelectAllButtonState() {
        let total = QuestionBankData.count
        let selected = selectedQuestionIds.count
        
        if selected == total && total > 0 {
            selectAllBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            selectAllBtn.setImage(UIImage(systemName: "square"), for: .normal)
        }
        
        QuestionNoLbl.text = "Question Limit: \(questions.count + selected)/\(noOfQuestion)"
    }

    
}

extension CreateQuizQutionVc: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tv{
            return questions.count
        }else{
            return QuestionBankData.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tv {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuistionTvTableViewCell", for: indexPath) as? QuistionTvTableViewCell else {
                return UITableViewCell()
            }
            cell.layoutIfNeeded()
            
            let model = questions[indexPath.row]
            let isLastCell = (indexPath.row == questions.count - 1)
            
            cell.indexPath = indexPath
            cell.delegate = self
            cell.configureCell(
                with: model,
                isLast: isLastCell,
                numberofQuestion: noOfQuestion,
                totalQuestion : questions.count
            )
            return cell
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuistionTvTableViewCell", for: indexPath) as? QuistionTvTableViewCell else {
                return UITableViewCell()
            }
            
            cell.layoutIfNeeded()
            
            let model = QuestionBankData[indexPath.row]
            cell.indexPath = indexPath
            cell.questionId = model.id
            cell.delegate = self

            // ✅ Use selectedQuestionIds instead of questions
            let isChecked = selectedQuestionIds.contains(model.id ?? "")
            cell.configureQuestionBankCell(with: model, isChecked: isChecked)

            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

struct QuestionModel {
    var chapter: String
    var marks: String
    var optionA: String
    var optionB: String
    var optionC: String
    var optionD: String
    var question: String
}

