//
//  CreateQuizQutionVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 19/08/25.
//

import UIKit
extension CreateQuizQutionVc: QuestionCellDelegate {
    func addAnotherCell(at indexPath: IndexPath) {
        questions.insert(
            QuestionModel(chapter: "", marks: "", optionA: "", optionB: "", optionC: "", optionD: "", question: ""),
            at: indexPath.row + 1
        )
        tv.reloadData()
    }

    
    func updateQuestion(at indexPath: IndexPath, model: QuestionModel) {
        questions[indexPath.row] = model
    }
    func removeCell(at indexPath: IndexPath) {
           guard questions.count > 1 else { return } // keep at least one cell
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
        cell.indexPath = indexPath
        cell.delegate = self
        let isLastCell = (indexPath.row == questions.count - 1)
        cell.configureCell(isLast: isLastCell)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    @IBOutlet weak var tv: UITableView!
    var questions: [QuestionModel] = [QuestionModel(chapter: "", marks: "", optionA: "", optionB: "", optionC: "", optionD: "", question: "")]
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        tv.register(UINib(nibName: "QuistionTvTableViewCell", bundle: nil),
                forCellReuseIdentifier: "QuistionTvTableViewCell")
        tv.dataSource = self
        tv.delegate = self
        tv.reloadData()
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

    
    
    
     func addQuestion() {
         

//         APIService.shared.makeApi(
//             url: ServiceUrl.recipient_get_standards,
//             parameters: ["quiz_id": "questions" : [] ,],
//             type: ApitTypeSringFile.POST,
//             token: staffDetails?.access_token ?? ""
//         ) { [weak self] (result: Result<GetStandardsSuc, Error>) in
//             guard let self = self else { return }
//             DispatchQueue.main.async {
//                 switch result {
//                 case .success(let res):
//                     guard res.status == true else {
////                         self.handleNoData(message: res.message ?? "No data")
//                         return
//                     }
//
////                     self.standardDetails = res.data
////                     self.standerdList = res.data?.compactMap { $0.name } ?? []
////
////                     if let first = res.data?.first {
////                         self.sectionsDetails = first.sections
////                         self.sectionList = first.sections?.compactMap { $0.name } ?? []
////                         self.sectionId = first.sections?.first?.id
////                         self.StandardLbl.text = first.name
////                         self.SectionLbl.text = first.sections?.first?.name
////                         self.GetHomeWorkReport(self.sectionId, self.dateLbl.text ?? "")
////                     }
////
////                     self.dropDownStack.isHidden = false
////                     self.searchBar.isHidden = true
////                     self.nodataFoundLbl.isHidden = true
////                     self.noDataFound.isHidden = true
//                 case .failure(let err):
////                     self.handleNoData(message: err.localizedDescription)
//                 }
//             }
//         }
        
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

