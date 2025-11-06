//
//  ReportsQuizVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 24/08/25.
//

import UIKit

class ReportsQuizVc: UIViewController, SelectNotice, addQuestionAndSubmitedListDelegate {
    
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
//        backLbl.configureAsBackTitle(
//            firstLine: MenuStringFile.selectedMenuName,
//            secondLine: staffDetails?.school_name ?? ""
//        )
//        
//        headerView.layer.cornerRadius = 20
//        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//        academicDropView.layer.cornerRadius = 10
//        academicDropView.layer.borderWidth = 1
//        academicDropView.layer.borderColor = UIColor.white.cgColor
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
            parameters: ["type": "2"],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
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
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
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
        cell.titleLbl.text = quiz.title
        cell.discretiponsLbl.text = quiz.description
        cell.exameDateLbl.text = formattedDateStatus(
            from: quiz.sent_time ?? "",
            isTimeNeeded: true)
        cell.subjectLbl.text = quiz.subject
        cell.postedByLbl.text = "Posted By: \(quiz.sent_by ?? "")"
        
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
                ($0.subject ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        updateNoDataState()
        tv.reloadData()
    }
}
