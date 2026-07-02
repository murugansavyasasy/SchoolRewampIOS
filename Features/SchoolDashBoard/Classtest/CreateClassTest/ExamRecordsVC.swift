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
    var class_test_details: [StaffClassTest]?
    var test_subjects: [StaffSubject] = [
        StaffSubject(
            subject_id: "MAT101",
            subject_name: "Mathematics",
            activities: [
                StaffActivity(
                    class_test_subject_id: "CT001",
                    exam_date: "2026-07-10",
                    status: "Completed",
                    session: "FN",
                    activity_name: "Unit Test 1",
                    max_mark: "50",
                    min_mark: "18",
                    syllabus: "Algebra and Geometry"
                ),
                StaffActivity(
                    class_test_subject_id: "CT002",
                    exam_date: "2026-08-05",
                    status: "Scheduled",
                    session: "AN",
                    activity_name: "Mid Term",
                    max_mark: "100",
                    min_mark: "35",
                    syllabus: "Chapters 1-5"
                )
            ]
        ),
        
        StaffSubject(
            subject_id: "SCI102",
            subject_name: "Science",
            activities: [
                StaffActivity(
                    class_test_subject_id: "CT003",
                    exam_date: "2026-07-15",
                    status: "Completed",
                    session: "AN",
                    activity_name: "Physics Quiz",
                    max_mark: "25",
                    min_mark: "10",
                    syllabus: "Motion and Force"
                ),
                StaffActivity(
                    class_test_subject_id: "CT004",
                    exam_date: "2026-08-12",
                    status: "Scheduled",
                    session: "FN",
                    activity_name: "Chemistry Test",
                    max_mark: "50",
                    min_mark: "18",
                    syllabus: "Acids, Bases and Salts"
                ),
                StaffActivity(
                    class_test_subject_id: "CT005",
                    exam_date: "2026-09-01",
                    status: "Draft",
                    session: "AN",
                    activity_name: "Biology Assessment",
                    max_mark: "75",
                    min_mark: "28",
                    syllabus: "Human Digestive System"
                )
            ]
        ),
        
        StaffSubject(
            subject_id: "ENG103",
            subject_name: "English",
            activities: [
                StaffActivity(
                    class_test_subject_id: "CT006",
                    exam_date: "2026-07-20",
                    status: "Scheduled",
                    session: "AN",
                    activity_name: "Grammar Test",
                    max_mark: "30",
                    min_mark: "12",
                    syllabus: "Tenses and Voice"
                )
            ]
        )
    ]
    
    private var expandedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tv.register(UINib(nibName: "SubjectDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "SubjectDetailsTableViewCell")
        
        tv.delegate = self
        tv.dataSource = self
        
//        if !test_subjects.isEmpty {
//                expandedIndexPath = IndexPath(row: 0, section: 0)
//            }
    }
    
    
    func get_exam_records_api() {
        
        APIService.shared.makeApi(
            url: ServiceUrl.exam_class_test_details,
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? "",
            isBaseUrl: true
        ) { [weak self] (result: Result<StaffClassTestResponse, Error>) in
            
            DispatchQueue.main.async {[weak self] in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        class_test_details = success.data
                        tv.reloadData()
                    }
                    
                case .failure(let failure):
                    print("")
                }
            }
        }
    }



    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
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
