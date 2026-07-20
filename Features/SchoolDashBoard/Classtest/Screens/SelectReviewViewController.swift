import UIKit

public final class SelectReviewViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var createButton: UIButton!
    @IBOutlet public weak var backButton: UIButton!
    
    // MARK: - Properties
    public var viewModel: CreateTestViewModel?
    
     var staffDetails = UserDefaultFileManager.get_staff_Details()
    
//    private var configuredSubjects: [SubjectExamConfig] {
//        return viewModel?.examConfigurations.filter { !$0.tests.isEmpty } ?? []
//    }
    private var configuredSubjects: [SubjectExamConfig] {
        guard let viewModel = viewModel else { return [] }
        var result: [SubjectExamConfig] = []
        for config in viewModel.examConfigurations {
            let filledTests = config.tests.filter {
                !$0.activity_name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            if !filledTests.isEmpty {
                var copy = config
                copy.tests = filledTests
                result.append(copy)
            }
        }
        return result
    }
    private var totalTestsCount: Int {
        return configuredSubjects.reduce(0) { $0 + $1.tests.count }
    }
    private let alert = CustomAlert()
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateButtonsState()
    }
    
    private func setupUI() {
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.text = viewModel?.exameName
        // Style Buttons
        createButton.layer.cornerRadius = 16
        createButton.layer.masksToBounds = true
        
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)

        // Add checkmark image to create button
        if let checkImage = UIImage(systemName: "checkmark.circle",withConfiguration: config) {
            createButton.setImage(checkImage, for: .normal)
            createButton.tintColor = .white
        }
        
       
        backButton.setTitle("back".translated(), for: .normal)
        backButton.layer.cornerRadius = 16
        backButton.layer.borderWidth = 1.0
        backButton.layer.borderColor = UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0).cgColor // #E2E8F0
        backButton.layer.masksToBounds = true
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 180
        tableView.rowHeight = UITableView.automaticDimension
        
        // Register Cell
        tableView.register(
            UINib(nibName: "ReviewSubjectTableViewCell", bundle: nil),
            forCellReuseIdentifier: "ReviewSubjectTableViewCell"
        )
    }
    
    private func updateButtonsState() {
        let total = totalTestsCount
        let title = total == 1 ? "  Create  Test" : "  Create  Test"
        createButton.setTitle("Create Test".translated(), for: .normal)
//        createButton.setTitle(title, for: .normal)
        
        let activeColor = UIColor.primery
        let disabledColor = UIColor.primery.withAlphaComponent(0.5)
        
        let hasTests = total > 0
        createButton.isEnabled = hasTests
        createButton.backgroundColor = hasTests ? activeColor : disabledColor
    }
    
    // MARK: - IBActions
    @IBAction @objc public func backButtonTapped(_ sender: UIButton) {
        _ = viewModel?.previousStep()
    }
    
    @IBAction @objc public func createButtonTapped(_ sender: UIButton) {
      
        let title = AlertstringFile.Confirm_title
        alert.showAlertCancel(
            title: title,
            message: "Are sure want to create the Activity?".translated(),
            actionLbl1: AlertstringFile.Yes_Send,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: { [self] in
                createTest()
            },
            onNo: {
                print("User canceled.")
            }
        )
    }
    
    
    private func createTest(){
        let params = getConfigurationsRequest()
        APIService.shared.PtmApi(url: ServiceUrl.exam_create_class_test, parameters: params, token: staffDetails?.access_token ?? "", isBaseUrl: true) { [weak self] (result: Result<SlotValidationResponse,Error>) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else {return}
                
                switch result {
                case .success(let succesmessage):
                    
                    if succesmessage.status == true {
                        DispatchQueue.main.async { [self] in
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: succesmessage.message ?? "",
                                    on: self
                                ) {
                                   // self.viewModel?.previousStep()
                                    self.parent?.dismiss(animated: true)
                                }
                        }
                    }else {
                        DispatchQueue.main.async {
                            self.alert
                                .showAlert(
                                    title: AlertstringFile.Oops,
                                    message: succesmessage.message ?? "" ,
                                    on: self)
                        }
                    }
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: "Error".translated(), message: "Something went Wrong".translated(), on: self)
                    print("Error: ",failure.localizedDescription)
                }
            }
        }
    }
    
    private func getConfigurationsRequest() -> [[String: Any]] {

        guard let viewModel = viewModel else { return [] }

        var request: [[String: Any]] = []

        for config in configuredSubjects {

            for test in config.tests {

                let maxVal = Int(test.maxMarks.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 100
                let minVal = Int(test.minMarks.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 35

                var formattedDate = test.testDate

                let inputFormatter = DateFormatter()
                inputFormatter.dateFormat = "dd/MM/yyyy"

                if let date = inputFormatter.date(from: test.testDate) {
                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "dd-MM-yyyy"
                    formattedDate = outputFormatter.string(from: date)
                }

                let dict: [String: Any] = [
                    "exam_name": viewModel.exameName,
                    "activity_name" : test.activity_name,
                    "section_id": config.sectionId,
                    "subject_id": config.subjectId,
                    "date": formattedDate,
                    "session": test.session,
                    "max_mark": maxVal,
                    "min_mark": minVal,
                    "syllabus": test.syllabus
                ]

                request.append(dict)
            }
        }

        return request
    }
    
   
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension SelectReviewViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configuredSubjects.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReviewSubjectTableViewCell",
            for: indexPath
        ) as? ReviewSubjectTableViewCell else {
            return UITableViewCell()
        }
        
        let config = configuredSubjects[indexPath.row]
        cell.configure(with: config)
       
        // Remove test callback
        cell.onRemoveTestTapped = { [weak self] testIdx in
//            self?.viewModel?.removeTest(at: testIdx, from: config.subjectId, sectionId: config.sectionId)
//            self?.tableView.reloadData()
//            self?.updateButtonsState()
            guard let self = self else { return }
                    self.viewModel?.removeTest(at: testIdx, from: config.subjectId, sectionId: config.sectionId)
                    self.tableView.reloadData()
                    self.updateButtonsState()
                    
                    if self.totalTestsCount == 0 {
                        _ = self.viewModel?.previousStep()
                    }
        }
        
        return cell
    }
}
