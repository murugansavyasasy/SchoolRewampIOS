//
//  QuizSubmissionVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 10/09/25.
//

import UIKit

class QuizSubmissionVc: UIViewController, UISearchBarDelegate,call {
    func callMobileNumber(indexPath: Int) {
        let vc = QuizCompletedVc()
        vc.selected_QuizId = QuizStudentRepo[indexPath].id ?? ""
        vc.selected_StudentId  = QuizStudentRepo[indexPath].student_id ?? ""
        vc.Selected_Standards = QuizStudentRepo[indexPath].standard ?? ""
        vc.Selected_Sections = QuizStudentRepo[indexPath].section ?? ""
        vc.Selected_StudentName = QuizStudentRepo[indexPath].student_name ?? ""
        vc.Token = staffDetails?.access_token ?? ""
        vc.completed_date = QuizStudentRepo[indexPath].submitted_on ?? ""
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    @IBOutlet weak var discreptionsLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var pendingBtn: UIButton!
    @IBOutlet weak var allSubmissionBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var QuizDetailsView: UIView!
    @IBOutlet weak var DescriptionBaseview: UIView!
    @IBOutlet weak var StudentListBaseview: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var tvHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var quizNmaeLbl: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    
    var senderQuizlist = senderQuizListData()
    var QuizStudentRepo : [QuizStudentReportData] = []
    var FilteredQuizStudentRepo : [QuizStudentReportData] = []
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quizNmaeLbl.configureAsBackTitle(firstLine: MenuStringFile.Quiz_Submission_List,secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        discreptionsLbl.text = senderQuizlist.description
        titleLbl.text = senderQuizlist.title
        subjectLbl.text = senderQuizlist.subject
        QuizDetailsView.layer.cornerRadius = 10
        DescriptionBaseview.layer.cornerRadius = 10
        StudentListBaseview.layer.cornerRadius = 10
        NoDataImage.isHidden = true
        NoDataLbl.isHidden = true
        searchBar.isHidden = true
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.searchTextField.addDoneButton()
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        tv.isScrollEnabled = false
        tv.register(UINib(nibName: CellConfingName.ClassTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.ClassTableViewCell)
        tv.delegate = self
        tv.dataSource = self
        getSubmissionList(QuizId : senderQuizlist.id ?? "")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateTableHeight() {
        tv.layoutIfNeeded()
        tvHeight.constant = tv.contentSize.height
    }
    
    @IBAction func backAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func searchBtnAct(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected{
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
            searchBtn.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        }else{
            searchBar.isHidden = true
            view.endEditing(true)
            searchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            searchBar.searchTextField.text = ""
            NoDataLbl.isHidden = true
            NoDataImage.isHidden = true
            FilteredQuizStudentRepo = QuizStudentRepo
            tv.reloadData()
            
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercasedText = trimmedText.lowercased()
        if lowercasedText.isEmpty {
            FilteredQuizStudentRepo = QuizStudentRepo
        } else {
            FilteredQuizStudentRepo = QuizStudentRepo.filter { student in
                let name = (student.student_name ?? "").lowercased()
                let standard = (student.standard ?? "").lowercased()
                let section = (student.section ?? "").lowercased()
                let standardSection = "\(standard)-\(section)"
                return name.contains(lowercasedText) || standardSection.contains(lowercasedText)}
        }
        if FilteredQuizStudentRepo.isEmpty{
            NoDataImage.isHidden = false
            NoDataLbl.isHidden = false
            NoDataLbl.text = AlertstringFile.No_Data_Found
        }else{
            NoDataImage.isHidden = true
            NoDataLbl.isHidden = true
        }
        tv.reloadData()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame =
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        let keyboardHeight = keyboardFrame.height
        var contentInset = mainScrollView.contentInset
        contentInset.bottom = keyboardHeight + 50 // small padding
        mainScrollView.contentInset = contentInset
        mainScrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25) {
            self.mainScrollView.contentInset = .zero
            self.mainScrollView.scrollIndicatorInsets = .zero
        }
    }
}


extension QuizSubmissionVc: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilteredQuizStudentRepo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tv.dequeueReusableCell(
            withIdentifier: CellConfingName.ClassTableViewCell,
            for: indexPath
        ) as? QuizSubmisionTvCell else{
            return UITableViewCell()
        }
        let student = FilteredQuizStudentRepo[indexPath.row]
        cell.nameLbl.text = student.student_name
        cell.classLbl.text = (student.standard ?? "") + "-" + (student.section ?? "")
        cell.SubmittedOnBtn.isHidden = true
        if student.gender == "male"{
            cell.profileImage.image = UIImage(named: "Male_icon")
        }else if student.gender == "female"{
            cell.profileImage.image = UIImage(named: "Female_icon")
        }else{
            cell.profileImage.image = UIImage(systemName: "person.fill")
        }
        if student.is_submit ?? false{
            cell.StatusBtn.backgroundColor = .systemGreen
            cell.StatusBtn.setTitle(MenuStringFile.Submitted.translated() + " >>", for: .normal)
            //            let submittedOn = student.submitted_on?.convertToTargetDateFormat()
            //            cell.SubmittedOnBtn.setTitle("Submitted On:\n\(submittedOn ?? "")", for: .normal)
            cell.StatusBtn.tag = indexPath.row
            cell.delegate = self
            cell.StatusBtn.isUserInteractionEnabled = true
        }else{
            cell.StatusBtn.backgroundColor = .pending
            cell.StatusBtn.setTitle(MenuStringFile.Pending.translated(), for: .normal)
            cell.StatusBtn.isUserInteractionEnabled = false
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateTableHeight()
        }
    }
    func getSubmissionList(QuizId : String){
        APIService.shared
            .makeApi(url: ServiceUrl.quiz_submission_list, parameters: [QuizKeys.id : QuizId], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "", isBaseUrl: false) { [weak self] (
                result: Result<QuizStudentReportSuc,
                Error>
            ) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let successResponse):
                        self.QuizStudentRepo = successResponse.data ?? []
                        self.FilteredQuizStudentRepo = self.QuizStudentRepo
                        self.tv.reloadData()
                        self.updateTableHeight()
                        
                    case .failure(let error):
                        print("Error fetching notices: \(error.localizedDescription)")
                    }
                }
            }
    }
}
