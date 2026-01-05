//
//  ReportsQuizVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 24/08/25.
//

protocol ReportsQuizDelegate: AnyObject {
    
    func didSelectQuizForEdit(quiz: EditQuiz)
}

import UIKit

class ReportsQuizVc: UIViewController, SelectNotice, addQuestionAndSubmitedListDelegate, SelectedId {
    
    // MARK: - Outlets
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var noDataImg: UIImageView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    
    // MARK: - Properties
    var get_QuizDetails: [senderQuizListData] = []
    var filteredData: [senderQuizListData] = []
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let images = ["Quiz1", "Quiz2", "Quiz3"]
    var selectNotice: SelectNotice?
    let alert = CustomAlert()
    weak var delegate: ReportsQuizDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerCells()
        Get_Quiz()
    }
    
    // MARK: - Setup
    private func setupUI() {
        searchView.delegate = self
        searchView.isHidden = true
        noDataImg.isHidden = true
        noDataLbl.isHidden = true
        searchView.placeholder = CommonStringFile.Search.translated()
        searchView.applyRightTxt()
        searchView.backgroundImage = UIImage()
        searchView.barTintColor = .clear
        searchView.backgroundColor = .clear
        searchView.searchTextField.addDoneButton()
    }
    
    private func registerCells() {
        let nib = UINib(nibName: CellConfingName.SenderQuizListTvCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier: CellConfingName.SenderQuizListTvCell)
        tv.dataSource = self
        tv.delegate = self
    }
    
    // MARK: - API Call
    func Get_Quiz() {
        APIService.shared.makeApi(
            url: ServiceUrl.quiz_report,
            parameters: [QuizKeys.type: "2"],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<senderQuizListSuc, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let successResponse):
                    self.get_QuizDetails = successResponse.data ?? []
                    self.filteredData = self.get_QuizDetails
                    self.updateNoDataState()
                    self.tv.reloadData()
                case .failure(let error):
                    print("Error fetching quiz reports: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func backBtnAct(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        //        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        //        searchBtn.setImage(UIImage(systemName: icon), for: .normal)
        searchView.isHidden = !sender.isSelected
        if sender.isSelected {
            searchView.becomeFirstResponder()
        } else {
            view.endEditing(true)
            searchView.text = ""
            filteredData = get_QuizDetails
            updateNoDataState()
            tv.reloadData()
        }
    }
    
    // MARK: - Delegate Implementations
    func addQuestionAndSubmitedList(index: Int) {
        let quiz = get_QuizDetails[index]
        let vc = CreateQuizQutionVc(nibName: nil, bundle: nil)
        vc.noOfQuestion = quiz.no_of_questions ?? 0
        vc.id = quiz.id
        vc.titleString = quiz.title ?? ""
        vc.subject_Id = quiz.subject_id
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func submitedList(index: Int) {
        let vc = QuizSubmissionVc(nibName: nil, bundle: nil)
        vc.senderQuizlist = get_QuizDetails[index]
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func didTapButton(title: String, content: String, items: [FilePath], editId: String) {
        // Optional delegate callback
    }
    
    // MARK: - Helpers
    private func updateNoDataState() {
        let isEmpty = filteredData.isEmpty
        noDataImg.isHidden = !isEmpty
        noDataLbl.isHidden = !isEmpty
        noDataLbl.text = isEmpty ? CommonStringFile.No_data_found : ""
    }
        
    func selectId(id: String?, edit: Bool?) {
        
        if edit == true {
            update_Quiz_Api(id: id ?? "")
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.alert.showAlertCancel(
                    title: AlertstringFile.Confirm,
                    message: "Are you sure want to delete this Quiz?",
                    actionLbl1: AlertstringFile.Yes,
                    actionLbl2: AlertstringFile.No,
                    on: self
                ) {
                    self.delete_Quiz_Api(id: id ?? "")
                } onNo: {}
            }
        }
    }

    
    func update_Quiz_Api(id: String){
        
        guard let Quiz: senderQuizListData = filteredData.first(where: {$0.id == id}) else {return}
        
        let editQuiz = EditQuiz(
            id: Quiz.id ?? "",
            title: Quiz.title,
            description: Quiz.description,
            noOfQuestions: Quiz.no_of_questions,
            levelFlag: Quiz.level_flag,
            isEdit: true
        )
        
        delegate?.didSelectQuizForEdit(quiz: editQuiz)
    }
    
    func delete_Quiz_Api(id :String){
        
        let param : [String:Any] = ["id":id]
        APIService.shared.makeApi(url: ServiceUrl.lms_api_quiz_delete, parameters: param, type: ApitTypeSringFile.PUT, token: staffDetails?.access_token ?? "", isBaseUrl: true) { [weak self] (result: Result<CommonApiSuc,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    
                    if success.status == true{
                        
                        if let index = self.filteredData.firstIndex(where: {$0.id == id}),
                           let mainIndex = self.get_QuizDetails.firstIndex(where: {$0.id == id}){
                            
                            self.filteredData.remove(at: index)
                            self.get_QuizDetails.remove(at: mainIndex)
                            
                            DispatchQueue.main.async {
                                self.tv.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                            }
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
    
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ReportsQuizVc: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.SenderQuizListTvCell,
            for: indexPath
        ) as? QuizListTvCell else {
            return UITableViewCell()
        }
        let quiz = filteredData[indexPath.row]
        cell.delegate = self
        cell.addQuestionBtnName.tag = indexPath.row
        cell.submittedListBtnName.tag = indexPath.row
        let imageName = images[indexPath.row % images.count]
        cell.DeafultimageView.image = UIImage(named: imageName)
        cell.PlayBtn.isHidden = true
        cell.pendingView.isHidden = quiz.open_to_student ?? false
        cell.titleLbl.text = quiz.title
        cell.discretiponsLbl.text = quiz.description
        cell.exameDateLbl.text = MenuStringFile.Sent_at.translated() + formattedDateStatus(
            from: quiz.sent_time ?? "",
            isTimeNeeded: true)
        cell.subjectLbl.text = quiz.subject
        cell.postedByLbl.text = MenuStringFile.Posted_By.translated() + "\(quiz.sent_by ?? "")"
        cell.levelLbl.text = MenuStringFile.Level.translated() + String(quiz.level ?? 0)
        cell.optionsBtn.isHidden = (quiz.can_edit == false && quiz.can_delete == false)
        cell.edit(edit: quiz.can_edit ?? false, delete: quiz.can_delete ?? false, selectedId: quiz.id ?? "")
        cell.PopupDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UISearchBarDelegate
extension ReportsQuizVc: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredData = get_QuizDetails
        } else {
            filteredData = get_QuizDetails.filter {
                ($0.title ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.subject ?? "").localizedCaseInsensitiveContains(searchText)}}
        updateNoDataState()
        tv.reloadData()
    }
}


struct EditQuiz{
    let id : String
    let title : String?
    let description: String?
    let noOfQuestions: Int?
    let levelFlag: Bool?
    let isEdit: Bool?
}
