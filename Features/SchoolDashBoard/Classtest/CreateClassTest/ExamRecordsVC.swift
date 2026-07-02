//
//  ExamRecordsVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 01/07/26.
//

import UIKit

class ExamRecordsVC: UIViewController {
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var examNameLbl: UILabel!
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var class_test_details: StaffSection?
    var test_subjects: [StaffSubject] = []
    var viewModel : CreateTestViewModel?
    private var expandedIndexPath: IndexPath?
    var ExamNameString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        examNameLbl.text = ExamNameString
        test_subjects = class_test_details?.subjects ?? []
        tv.register(UINib(nibName: "SubjectDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "SubjectDetailsTableViewCell")
        tv.delegate = self
        tv.dataSource = self
        
        if !test_subjects.isEmpty{
            expandedIndexPath = IndexPath(row: 0, section: 0)
        }
    }
    
    func delete_activity_api(class_test_subject_id:String) {
        
        let param : [String:Any] =
        [
            "class_test_subject_id" : class_test_subject_id
        ]
        
        APIService.shared.makeApi(
            url: ServiceUrl.exam_api_exam_test_delete_class_test_subject,
            parameters: param,
            type: ApitTypeSringFile.PUT,
            token: staffDetails?.access_token ?? "",
            isBaseUrl: true
        ) { [weak self] (result: Result<CommonApiSuc, Error>) in
            
            DispatchQueue.main.async {[weak self] in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success.translated(), message: success.message ?? "", on: self) {
                            
                        }
                    }else {
                        
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed.translated(), message: success.message ?? "", on: self) {
                            
                        }
                    }
                    
                case .failure(let failure):
                   
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed.translated(), message: failure.localizedDescription, on: self) {
                        
                    }
                }
            }
        }
    }

    
    @IBAction func enterMarks(_ sender: UIButton) {
        MenuStringFile.selectedMenuName = "View & Enter Marks"
        fetchMarksAndNavigate()
    }
    
    
    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    func fetchMarksAndNavigate() {
        showActivityLoader()
        viewModel?.getMarkDetails(completion: { [weak self] result in
                
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.hideActivityLoader()
                    
                    switch result {
                    case .success(let records):
                        self.navigateToEnterMark(with: records)
                        
                    case .failure(let error):
                        print("❌ Error:", error.localizedDescription)
                    }
                }
            }
        )
    }
    
    func navigateToEnterMark(with records: [StudentMark]) {
        let vc = EnterMarkVC()
        vc.studentRecords = records
        vc.viewModel = viewModel
        vc.allStudents = records
        vc.uploadTest = true
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
}

extension ExamRecordsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return test_subjects.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SubjectDetailsTableViewCell",
            for: indexPath
        ) as? SubjectDetailsTableViewCell else {
            return UITableViewCell()
        }
        
        let subject = test_subjects[indexPath.row]
        let isExpanded = (expandedIndexPath == indexPath)
        
        cell.configureReport(with: subject, isExpanded: isExpanded)
        
        cell.onToggleExpand = { [weak self] in
            guard let self = self else { return }
            
            let previousExpanded = self.expandedIndexPath
            
            if self.expandedIndexPath == indexPath {
                self.expandedIndexPath = nil
            } else {
                self.expandedIndexPath = indexPath
            }
            
            var rowsToReload = [indexPath]
            
            if let previousExpanded,
               previousExpanded != indexPath {
                rowsToReload.append(previousExpanded)
            }
            
            self.tv.reloadRows(at: rowsToReload, with: .fade)
            
            if self.expandedIndexPath == indexPath {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    self.tv.scrollToRow(at: indexPath, at: .none, animated: true)
                }
            }
        }
        
        cell.onRemoveTest = { [weak self] index, class_test_subject_id, section in
            self?.delete_activity_api(class_test_subject_id: class_test_subject_id)
        }
        
        return cell
    }
}
