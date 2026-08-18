//
//  ParentClassTestVc.swift
//  School Chimes
//
//  Created by apple on 30/06/26.
//

import UIKit

class ParentClassTestVc: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var nodataImg: UIImageView!
    @IBOutlet weak var nodataLbl: UILabel!
    
    let studentDetails = UserDefaultFileManager.get_child_Details()
    private var classTests: [ClassTest] = []
    private var filteredClassTests: [ClassTest] = []
    private let stateTracker = ClassTestsStateTracker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = studentDetails?.name ?? ""
        let stanard = (studentDetails?.standard_name ?? "") + " - " + (studentDetails?.section_name ?? "")
        studentNameLbl.configureAsBackTitle(firstLine: name, secondLine: stanard)
        
        nodataImg.isHidden = true
        nodataLbl.isHidden = true
        
        searchBtn.isHidden = true
        searchbar.isHidden = true
        searchbar.delegate = self
        searchbar.searchTextField.addDoneButton()
        searchbar.placeholder = CommonStringFile.Search.translated()
        searchbar.backgroundImage = UIImage()
        
        setupTableView()
        get_class_tests_Api()
        
//        let analysisButton = AnalysisButton()
//
//        view.addSubview(analysisButton)
//
//        NSLayoutConstraint.activate([
//            analysisButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            analysisButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
//        ])
//
//        analysisButton.addTarget(self,
//                                 action: #selector(openAnalysis),
//                                 for: .touchUpInside)
    }
   
    
    @IBAction func analisesBtn(_ sender: AnalysisButton) {
        
        let examVC = selectExamVc()
        examVC.loginType = 2
        examVC.modalPresentationStyle = .fullScreen
        present(examVC, animated: true)
        
    }
    @IBAction func Backbtn(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
    
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 244/255, green: 247/255, blue: 252/255, alpha: 1.0)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 20, right: 0)
        
        // Register Cell
        let cellNib = UINib(nibName: "ExamCardTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "ExamCardTableViewCell")
        
        // Enable Auto Dimension for dynamic heights
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 180
        
    }
    
    func get_class_tests_Api() {
        showActivityLoader()
        APIService.shared.makeApi(
            url: ServiceUrl.exam_class_test_details_for_student,
            type: ApitTypeSringFile.GET,
            token: studentDetails?.access_token ?? "",
            isBaseUrl: false
        ) {[weak self] (result:Result<ClassTestResponse, Error>) in
            
            DispatchQueue.main.async {[weak self] in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let success):
                    
                    self.classTests = success.data ?? []
                    self.filteredClassTests = self.classTests
                    nodataImg.isHidden = !(success.data?.isEmpty == true)
                    nodataLbl.isHidden = !(success.data?.isEmpty == true)
                    searchBtn.isHidden = (success.data?.isEmpty == true)
                    
                    nodataLbl.text = success.message
                    self.tableView.reloadData()
                    hideActivityLoader()
                case .failure(let failure):
                    self.classTests = []
                    self.filteredClassTests = self.classTests
                    nodataImg.isHidden = false
                    nodataLbl.isHidden = false
                    searchBtn.isHidden = true
                    nodataLbl.text = failure.localizedDescription
                    self.tableView.reloadData()
                    hideActivityLoader()
                }
            }
            
        }
    }
    
    @IBAction func searchBtnAct(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected{
            searchbar.isHidden = false
            searchbar.becomeFirstResponder()
            searchBtn.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        }else{
            searchbar.isHidden = true
            view.endEditing(true)
            searchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            searchbar.searchTextField.text = ""
            searchbar.text = ""
            filteredClassTests = classTests
            nodataImg.isHidden = true
            nodataLbl.isHidden = true
            tableView.reloadData()
        }
    }
    
    // MARK: - UITableViewDataSource
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredClassTests.count
    }
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExamCardTableViewCell", for: indexPath) as? ExamCardTableViewCell else {
            return UITableViewCell()
        }
        configureCell(cell, at: indexPath)
        return cell
    }
    
    private func configureCell(_ cell: ExamCardTableViewCell, at indexPath: IndexPath) {
        let exam = filteredClassTests[indexPath.row]
        let isExpanded = stateTracker.isExamExpanded(exam.classTestId ?? "")
        
        cell.configure(with: exam, isExpanded: isExpanded, stateTracker: stateTracker, onToggle: { [weak self] in
            guard let self = self else { return }
            self.stateTracker.toggleExam(exam.classTestId ?? "")
            
            // Auto-expand all child subjects if the exam is expanded
            if self.stateTracker.isExamExpanded(exam.classTestId ?? "") {
                for subject in exam.subjects {
                    if !self.stateTracker.isSubjectExpanded(examId: exam.classTestId ?? "", subjectId: subject.subjectId ?? "") {
                        self.stateTracker.toggleSubject(examId: exam.classTestId ?? "", subjectId: subject.subjectId ?? "")
                    }
                }
            }
            
            // Reconfigure the cell in-place with the proper callbacks intact
            self.configureCell(cell, at: indexPath)
            
            // Force cell layout refresh before performBatchUpdates
            cell.contentView.layoutIfNeeded()
            
            // Animate row height change smoothly
            self.tableView.performBatchUpdates(nil, completion: nil)
        }, onSubjectToggle: { [weak self] in
            guard let self = self else { return }
            // Reconfigure the cell in-place with the proper callbacks intact
            self.configureCell(cell, at: indexPath)
            // Force cell layout refresh before performBatchUpdates
            cell.contentView.layoutIfNeeded()
            // Animate row height change smoothly
            self.tableView.performBatchUpdates(nil, completion: nil)
        })
        
        cell.onViewMarks = { [weak self] in
            guard let self = self else { return }
            let marksVC = MarksDetailsViewController(nibName: "MarksDetailsViewController", bundle: nil)
            marksVC.classTestId = Int(exam.classTestId ?? "0")
            
            if let nav = self.navigationController {
                nav.pushViewController(marksVC, animated: true)
            } else {
                marksVC.modalPresentationStyle = .fullScreen
                self.present(marksVC, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let exam = filteredClassTests[indexPath.row]
        stateTracker.toggleExam(exam.classTestId ?? "")
        
        // Auto-expand all child subjects if the exam is expanded
        if stateTracker.isExamExpanded(exam.classTestId ?? "") {
            for subject in exam.subjects {
                if !stateTracker.isSubjectExpanded(examId: exam.classTestId ?? "", subjectId: subject.subjectId ?? "") {
                    stateTracker.toggleSubject(examId: exam.classTestId ?? "", subjectId: subject.subjectId ?? "")
                }
            }
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? ExamCardTableViewCell {
            configureCell(cell, at: indexPath)
            cell.contentView.layoutIfNeeded()
            tableView.performBatchUpdates(nil, completion: nil)
        }
    }
    
}

extension ParentClassTestVc : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else {
            
            filteredClassTests = classTests
            tableView.reloadData()
            return
        }


        filteredClassTests = classTests.filter { exam in

            // Search exam name
            if exam.examName?.localizedCaseInsensitiveContains(text) == true {
                return true
            }

            // Search subjects
            if exam.subjects.contains(where: {
                $0.subjectName?.localizedCaseInsensitiveContains(text) == true
            }) {
                return true
            }

            // Search activities
            if exam.subjects.contains(where: { subject in
                subject.activities.contains(where: {
                    $0.activityName?.localizedCaseInsensitiveContains(text) == true
                })
            }) {
                return true
            }

            return false
        }

        nodataImg.isHidden = !filteredClassTests.isEmpty
        nodataLbl.isHidden = !filteredClassTests.isEmpty
        nodataLbl.text = "No result found"
        tableView.reloadData()
    }

}


extension UIView {
    static func loadFromNib() -> Self {
        let bundle = Bundle(for: self)
        let nibName = String(describing: self)
        guard let view = bundle.loadNibNamed(nibName, owner: nil, options: nil)?.first as? Self else {
            fatalError("Could not load view with nib name \(nibName)")
        }
        return view
    }
}


final class AnalysisButton: UIButton {

    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let viewLabel = UILabel()
    private let titleLabelView = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {

        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .primery
        layer.cornerRadius = 28

        layer.borderWidth = 1
        layer.borderColor = UIColor.systemBlue.cgColor

        layer.shadowColor = UIColor.systemBlue.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 4)

        // Icon Circle
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        iconContainer.layer.cornerRadius = 20
        addSubview(iconContainer)

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill")
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconImageView)

        // VIEW Label
        viewLabel.translatesAutoresizingMaskIntoConstraints = false
        viewLabel.text = "VIEW"
        viewLabel.font = .systemFont(ofSize: 9, weight: .semibold)
        viewLabel.textColor = .white
        addSubview(viewLabel)

        // Title
        titleLabelView.translatesAutoresizingMaskIntoConstraints = false
        titleLabelView.text = "Mark Analysis"
        titleLabelView.font = .systemFont(ofSize: 13, weight: .bold)
        titleLabelView.textColor = .white
        addSubview(titleLabelView)

        NSLayoutConstraint.activate([

            heightAnchor.constraint(equalToConstant: 54),
            widthAnchor.constraint(equalToConstant: 185),

            iconContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            iconContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            viewLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            viewLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),

            titleLabelView.leadingAnchor.constraint(equalTo: viewLabel.leadingAnchor),
            titleLabelView.topAnchor.constraint(equalTo: viewLabel.bottomAnchor, constant: 2)
        ])
    }

    @objc private func touchDown() {

        UIView.animate(withDuration: 0.15) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func touchUp() {
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 5) {

            self.transform = .identity
        }
    }
}
