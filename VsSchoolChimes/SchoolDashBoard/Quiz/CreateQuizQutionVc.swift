//
//  CreateQuizQutionVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 19/08/25.
//

import UIKit
extension CreateQuizQutionVc: QuestionCellDelegate {
    func addAnotherCell(at indexPath: IndexPath) {
            questions.insert(QuizQuestiondata(), at: indexPath.row + 1)
            tv.reloadData()
        }
        
        func updateQuestion(at indexPath: IndexPath, model: QuizQuestiondata) {
            questions[indexPath.row] = model
            
            print("questionsquestions",questions,model.question)
        }
        
        func removeCell(at indexPath: IndexPath) {
            guard questions.count > 1 else { return }
            questions.remove(at: indexPath.row)
            tv.reloadData()
        }
    
    func addAttachment(at indexPath: IndexPath, file: FilePaths) {
           // append the file into question model
        if questions[indexPath.row].file_path == nil {
            questions[indexPath.row].file_path = []
           }
//           questions[indexPath.row].filePath?.append(file)
           
           print("📎 Attachment added to question at index \(indexPath.row): \(file.fileName)")
       }
}
class CreateQuizQutionVc: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return questions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "QuistionTvTableViewCell", for: indexPath) as? QuistionTvTableViewCell else {
            return UITableViewCell()
        }
        cell.layoutIfNeeded()
       
        let model = questions[indexPath.row]
           let isLastCell = (indexPath.row == questions.count - 1)
           
           cell.indexPath = indexPath
           cell.delegate = self
        cell
            .configureCell(
                with: model,
                isLast: isLastCell,
                numberofQuestion: noOfQuestion,
                totalQuestion : questions.count
            )
        
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    @IBOutlet weak var tv: UITableView!
//    var questions: [QuestionModel] = [QuestionModel(chapter: "", marks: "", optionA: "", optionB: "", optionC: "", optionD: "", question: "")]
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    var id  : String?
    var questions: [QuizQuestiondata] = [QuizQuestiondata()]
    var noOfQuestion: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        tv.register(UINib(nibName: "QuistionTvTableViewCell", bundle: nil),
                forCellReuseIdentifier: "QuistionTvTableViewCell")
        tv.dataSource = self
        tv.delegate = self
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
                    
                    CustomAlert
                        .showAlertWithOkAction(
                            title: AlertstringFile.Success,
                            message: res.message ?? "",
                            on: self
                        ) {
                           
                            
                        }
                    
                case .failure:
                    ""
                }
            }
        }
    }
  
    func buildQuizParams() -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        var dictArray: [[String: Any]] = []
        
       

        for q in questions {
            let dict: [String: Any] = [
                "ques_no": q.ques_no ?? "",
                "chapter": q.chapter ,
                "question": q.question ,
                "a_option": q.a_option ,
                "b_option": q.b_option ,
                "c_option": q.c_option ,
                "d_option": q.d_option ,
                "answer": q.answer ?? "",
                "mark": q.mark ?? 0,
                "iframe": "",
                "file_size": "",
                "thumbnail": "",
                "file_path": (q.file_path?.isEmpty ?? true)
                    ? []  // 👈 file_path nil or empty → []
                    : q.file_path!.map { ["url": $0.url, "type": $0.type] }
            ]
            dictArray.append(dict)
        }

        
        let params: [String: Any] = [
            "quiz_id": id ?? "",
            "questions": dictArray,
            "max_mark": 6,
            "ok_flag": false,
            "update_question_bank": []
        ]
        
        return params
    }

    
    @IBAction func addQuestionBtn(_ sender: Any) {
    }
    
    @IBAction func BackBtn(_ sender: Any) {
        dismiss(animated: true)
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

