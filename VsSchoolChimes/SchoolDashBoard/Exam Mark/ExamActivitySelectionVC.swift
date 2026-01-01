//
//  ExamActivitySelectionVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 26/11/25.
//

import UIKit

class ExamActivitySelectionVC: UIViewController {

    @IBOutlet weak var topInfoView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var bottomInfoView: UIView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    
    var expandedIndex: IndexPath?
    var didInitialHeightSet = false
    var SubjectList : [SubjectExamData] = []
    var isAIFlow: Bool = false
    var ExamID = ""
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    var selectedSplits: [SelectedSplit] = []
    var selectedColoumns:[String] = []
    var convertedRecords:[ConvertedStudentRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topInfoView.layer.cornerRadius = 10
        topInfoView.backgroundColor = .staffExamColour.withAlphaComponent(0.1)
        topInfoView.layer.borderWidth = 0.3
        topInfoView.layer.borderColor = UIColor.staffExamColour.cgColor
        
        bottomInfoView.layer.cornerRadius = 10
        bottomInfoView.backgroundColor = .systemGray6.withAlphaComponent(0.7)
        bottomInfoView.layer.borderWidth = 0.3
        bottomInfoView.layer.borderColor = UIColor.lightGray.cgColor
        
        continueBtn.layer.cornerRadius = 10
        
        tableview.isScrollEnabled = false
        tableview.register(UINib(nibName: "SubjectsTVCell", bundle: nil),
                           forCellReuseIdentifier: "SubjectsTVCell")
        
        tableview.delegate = self
        tableview.dataSource = self
        
        Get_exam_activities_Api(for: ExamID)
    }
    

    func Get_exam_activities_Api(for examId: String) {
        SubjectList.removeAll()
        let param:[String:Any] = ["exam_id": examId]

        APIService.shared.makeApi(
            url: ServiceUrl.exam_get_subject_wise_activities,
            parameters: param,
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<SubjectWiseExamResponse, Error>) in

            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.SubjectList = response.data ?? []
                    self.tableview.reloadData()
                   
                case .failure(let error):
                    print("Error loading subjects: \(error)")
                }
            }
        }
    }
    
    private func updateMainHeight() {
           DispatchQueue.main.async {
               self.tableview.layoutIfNeeded()
               self.tableviewHeight.constant = self.tableview.contentSize.height
           }
       }
    
    @IBAction func continueAct(_ sender: Any) {
        let vc = MarkReviewVC()
        vc.payload = buildPayload()
        vc.aiRecords = convertedRecords
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func buildPayload() -> [String: Any] {

        let selectedActivities = SubjectList.compactMap { subject -> [String: Any]? in
            let selected = subject.splitup_details?.filter { $0.isChecked == true } ?? []
            guard !selected.isEmpty else { return nil }

            return [
                "subject_id": subject.subject_id ?? "",
                "subject_name": subject.subject_name ?? "",
                "activities": selected.map {
                    var dict: [String: Any] = ["activity_id": $0.id ?? "", "activity_name": $0.name ?? "", "max_mark": $0.max_mark ?? ""]
                    if isAIFlow == true {
                        dict["ai_option"] = $0.selectedAIOption ?? ""
                    }
                    return dict
                }
            ]
        }

        return [
            "class_id": SubjectList.first?.class_id ?? "",
            "section_id": SubjectList.first?.section_id ?? "",
            "exam_id": ExamID,
            "selected_activities": selectedActivities
        ]
    }

    
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension ExamActivitySelectionVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SubjectList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectsTVCell", for: indexPath) as! SubjectsTVCell

        let data = SubjectList[indexPath.row]

            cell.subjectIndex = indexPath.row
            cell.isAI = isAIFlow
            cell.DropdownData = selectedColoumns
            cell.delegate = self
            cell.isExpanded = (expandedIndex == indexPath)
            cell.splits = data.splitup_details ?? []
            cell.updateStatusLabel()
            cell.configureExpandState()

            cell.onHeightChange = { [weak self] in
                self?.updateMainHeight()
            }

            return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let previous = expandedIndex

        if previous == indexPath {
            expandedIndex = nil
        } else {
            expandedIndex = indexPath
        }

        var rows = [indexPath]
        if let previous = previous, previous != indexPath {
            rows.append(previous)
        }

        tableView.reloadRows(at: rows, with: .automatic)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.updateMainHeight()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateMainHeight()
        }
    }
}


extension ExamActivitySelectionVC: SubjectCellDelegate {
        func didUpdateSplit(subjectIndex: Int, splitIndex: Int, split: SplitDetail) {
            SubjectList[subjectIndex].splitup_details?[splitIndex] = split
        }
    }

