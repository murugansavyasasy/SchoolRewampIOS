//
//  NewPlayQuizVC.swift
//  School Chimes
//
//  Created by Chandhru on 17/12/25.
//

import UIKit

class NewPlayQuizVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var btnStack: UIStackView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var priviousBtn: UIButton!
    @IBOutlet weak var questionTable: UITableView!
    @IBOutlet weak var outerView: UIView!
    
    // MARK: - Data Source (Mock)
    var qustList: [QstDetail] = []
    // MARK: - State
    var questionIndex: Int = 0
    var currentQuestion: QstDetail?
    var selectedOptionIndex: Int?
    var selectedQuizId : String?
    var answers: [String: String] = [:]
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        nextBtn.layer.cornerRadius = nextBtn.frame.height/2
        priviousBtn.layer.cornerRadius = priviousBtn.frame.height/2
        setupTable()
    }
    
    // MARK: - Setup
    private func setupTable() {
        questionTable.register(UINib(nibName: "QuestionTVC", bundle: nil), forCellReuseIdentifier: "QuestionTVC")
        questionTable.register(UINib(nibName: "OptionTVC", bundle: nil), forCellReuseIdentifier: "OptionTVC")
        questionTable.register(UINib(nibName: "NodataTVC", bundle: nil), forCellReuseIdentifier: "NodataTVC")
        priviousBtn.setTitle("PREVIOUS_QUESTION".translated(), for: .normal)
        questionTable.delegate = self
        questionTable.dataSource = self
        questionTable.separatorStyle = .none
        questionTable.estimatedRowHeight = 100
        questionTable.rowHeight = UITableView.automaticDimension
        questionIndex = 0
        Get_QuizQuestion()
    }
    
    // MARK: - Button Actions
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func previousTapped(_ sender: UIButton) {
        guard questionIndex > 0 else { return }
        questionIndex -= 1
        updateCurrentQuestion()
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        if questionIndex == qustList.count - 1 {
            showSubmitConfirmation()
            return
        }
        questionIndex += 1
        updateCurrentQuestion()
    }
    func updateNextButtonTitle() {
        if questionIndex == qustList.count - 1 {
            nextBtn.setTitle("Submit".translated(), for: .normal)
        } else {
            nextBtn.setTitle("NEXT_QUESTION".translated(), for: .normal)
        }
    }
    func showSubmitConfirmation() {
        let alert = UIAlertController(
            title: "SUBMIT_QUIZ".translated(),
            message: "SUBMIT_QUIZ_CONFIRMATION".translated(),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel".translated(), style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Submit".translated(), style: .destructive) { [weak self] _ in
            
            self?.submitQuiz()
        })
        
        present(alert, animated: true)
    }
    
    func submitQuiz() {
        APIService.shared
            .makeApi(url: ServiceUrl.quiz_submit, parameters: [QuizKeys.id : selectedQuizId ?? "","answers":answers], type: ApitTypeSringFile.PUT, token: UserDefaultFileManager.get_child_Details()?.access_token ?? "", isBaseUrl: true) { [weak self] (
                result: Result<CommonApiSuc,
                Error>
            ) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let successResponse):
                        if successResponse.status == true {
                            self.dismiss(animated: true)
                        }else{
                            
                            
                        }
                    case .failure(let error):
                        print("Error fetching notices: \(error.localizedDescription)")
                    }
                }
            }
    }
    
    
    // MARK: - Update Question
    private func updateCurrentQuestion() {
        currentQuestion = qustList[questionIndex]
        selectedOptionIndex = nil
        updateNextButtonTitle()
        questionTable.reloadData()
    }
    func Get_QuizQuestion() {
        APIService.shared
            .makeApi(url: ServiceUrl.quiz_get_questions, parameters: [QuizKeys.id : selectedQuizId ?? "" ], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_child_Details()?.access_token ?? "", isBaseUrl: true) { [weak self] (
                result: Result<QuizQuestionSuc,
                Error>
            ) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let successResponse):
                        self.qustList = successResponse.data ?? []
                        if !self.qustList.isEmpty {
                            self.questionIndex = 0
                            self.currentQuestion = self.qustList[0]
                            self.updateNextButtonTitle()
                            self.priviousBtn.isHidden = true
                        }
                        self.btnStack.isHidden = self.qustList.isEmpty
                        self.questionTable.reloadData()
                    case .failure(let error):
                        print("Error fetching notices: \(error.localizedDescription)")
                    }
                }
            }
    }
}

// MARK: - UITableView Delegate & DataSource
extension NewPlayQuizVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let question = currentQuestion else { return 1 }
        return (question.options?.count ?? 0) + 1 // +1 for question cell
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let question = currentQuestion else {
            return tableView.dequeueReusableCell(withIdentifier: "NodataTVC", for: indexPath)
        }
        
        // Question Cell
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionTVC", for: indexPath) as! QuestionTVC
            cell.qstLbl.text = question.question
            cell.qstCountLbl.text = "\("Question".translated())\(questionIndex + 1)/\(qustList.count)"
            cell.markLbl.text = "\("MARK".translated() )/ \(question.mark ?? "")"
            
            if let files = question.q_file_path, !files.isEmpty {
                cell.conficList(filePath: files)
                cell.imgView.isHidden = false
                cell.pageController.isHidden = false
                cell.pageController.numberOfPages = files.count
            } else {
                cell.imgView.isHidden = true
                cell.pageController.isHidden = true
            }
            return cell
        }
        
        // Option Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionTVC", for: indexPath) as! OptionTVC
        let optionIndex = indexPath.row - 1
        let option = question.options?[optionIndex]
        let chooseOption = optionLetter(for: optionIndex)
        if optionIndex == selectedOptionIndex {
            cell.optionBtn.setTitle("", for: .normal)
            cell.optionBtn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            cell.optionBtn.setTitle(chooseOption, for: .normal)
            cell.optionBtn.setImage(nil, for: .normal)
        }
        
        if let img = URL(string: option?.image ?? ""){
            cell.ansImg.isHidden = false
            cell.ansImg.kf.setImage(with:img ,placeholder: UIImage(named: "ImagePdf"))
        }else{
            cell.ansImg.isHidden = true
        }
        
        cell.ansLbl.text = option?.value
        UIView.animate(withDuration: 0.2) {
            if optionIndex == self.selectedOptionIndex{
                cell.optionView.layer.borderColor = UIColor.systemBlue.cgColor
                cell.optionView.layer.borderWidth = 2
                cell.optionView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
            } else {
                cell.optionView.layer.borderColor = UIColor.systemGray4.cgColor
                cell.optionView.layer.borderWidth = 1
                cell.optionView.backgroundColor = .clear
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row > 0 else { return }
        
        let optionIndex = indexPath.row - 1
        let previousSelected = selectedOptionIndex
        selectedOptionIndex = optionIndex
        if let questionId = currentQuestion?.id {
            answers[questionId] = currentQuestion?.options?[optionIndex].option
        }
        var indexPathsToReload: [IndexPath] = [indexPath]
        if let previous = previousSelected, previous != optionIndex {
            indexPathsToReload.append(IndexPath(row: previous + 1, section: 0))
        }
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }

}

struct Question {
    let text: String
    let options: [String]
    let correctOptionIndex: Int
}
