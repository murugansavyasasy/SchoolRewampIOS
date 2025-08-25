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
        }
        
        func removeCell(at indexPath: IndexPath) {
            guard questions.count > 1 else { return }
            questions.remove(at: indexPath.row)
            tv.reloadData()
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
           cell.configureCell(with: model, isLast: isLastCell)
        
        
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
                             self.questions = [QuizQuestiondata()] // fallback
                             self.tv.reloadData()
                         }
                     }
                 }
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

