//
//  ExamRecordsVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 01/07/26.
//

import UIKit

class ExamRecordsVC: UIViewController {
    
    @IBOutlet weak var tv: UITableView!
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var class_test_details: StaffSection?
    var test_subjects: [StaffSubject] = []
    var viewModel : CreateTestViewModel?
    private var expandedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        test_subjects = class_test_details?.subjects ?? []
        tv.register(UINib(nibName: "SubjectDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "SubjectDetailsTableViewCell")
        tv.delegate = self
        tv.dataSource = self
        
    }
    
    @IBAction func enterMarks(_ sender: UIButton) {
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
        
        return cell
    }
}
