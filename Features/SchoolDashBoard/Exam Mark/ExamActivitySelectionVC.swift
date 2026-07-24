//
//  ExamActivitySelectionVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 26/11/25.
//

import UIKit

class ExamActivitySelectionVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var topInfoView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var bottomInfoView: UIView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    @IBOutlet weak var examNAmeLBl: UILabel!
    @IBOutlet weak var examDateLbl: UILabel!
    @IBOutlet weak var topInfoLbl: UILabel!
    @IBOutlet weak var bottomInfoLbl: UILabel!
    
    var expandedIndex: IndexPath?
    var didInitialHeightSet = false
    var SubjectList : [SubjectExamData] = []
    var isAIFlow: Bool = false
    var ExamID = ""
    var section_Id = ""
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    var selectedSplits: [SelectedSplit] = []
    var selectedColoumns:[String] = []
    var convertedRecords:[ConvertedStudentRecord] = []
    var SelectedExam : StaffExamData?
    var academicYearId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLbl.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName,secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        
        setFont()
        
        topInfoView.layer.cornerRadius = 10
        topInfoView.backgroundColor = .staffExamColour.withAlphaComponent(0.1)
        topInfoView.layer.borderWidth = 0.3
        topInfoView.layer.borderColor = UIColor.staffExamColour.cgColor
        
        if isAIFlow{
            topInfoLbl.text = ExamMarkUploadString.Click_the_radio_button_next_to_each_activity.translated()
            bottomInfoLbl.text = ExamMarkUploadString.Tip_Unmapped_activities_can_be_filled_later.translated()
            continueBtn.setTitle(ExamMarkUploadString.Continue_to_Review.translated(), for: .normal)
        }else{
            topInfoLbl.text = ExamMarkUploadString.Choose_the_activities_where_you_would_like_to_enter_marks_manually.translated()
            bottomInfoLbl.text = ExamMarkUploadString.Please_select_at_least_one_activity_to_continue.translated()
            continueBtn.setTitle(ExamMarkUploadString.Continue_to_Entry.translated(), for: .normal)
        }
        
        bottomInfoView.layer.cornerRadius = 10
        bottomInfoView.backgroundColor = .systemGray6.withAlphaComponent(0.7)
        bottomInfoView.layer.borderWidth = 0.3
        bottomInfoView.layer.borderColor = UIColor.lightGray.cgColor
        
        continueBtn.layer.cornerRadius = 10
        
        examNAmeLBl.text = SelectedExam?.name
        examDateLbl.text = monthYear(from: SelectedExam?.date ?? "")
        
        tableview.isScrollEnabled = false
        tableview.register(UINib(nibName: CellConfingName.SubjectsTVCell, bundle: nil),forCellReuseIdentifier: CellConfingName.SubjectsTVCell)
        
        tableview.delegate = self
        tableview.dataSource = self
        
        Get_exam_activities_Api(for: ExamID)
    }
    
    func setFont(){
        
        examNAmeLBl.setFont(style: .header, size: FontSize.HeaderSize)
        examDateLbl.setFont(style: .title, size: FontSize.TitleSize)
        topInfoLbl.setFont(style: .body, size: FontSize.TitleSize)
        bottomInfoLbl.setFont(style: .body, size: FontSize.TitleSize)
        continueBtn.setTitleFont(style: .body, size: FontSize.TitleSize)
    }
    
    func monthYear(from dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMMM yyyy"
        outputFormatter.locale = Locale(identifier: "en_US")

        guard let date = inputFormatter.date(from: dateString) else {
            return nil
        }

        return outputFormatter.string(from: date)
    }

    
    func Get_exam_activities_Api(for examId: String) {
        SubjectList.removeAll()
        let param:[String:Any] = ["exam_id": examId,/*"section_id": section_Id*/]

        APIService.shared.makeApi(
            url: ServiceUrl.exam_get_subject_wise_activities,
            parameters: param,
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? "", isBaseUrl: true
        ) { [weak self] (result: Result<SubjectWiseExamResponse, Error>) in

            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.SubjectList = [
                        
                        SubjectExamData(
                            subject_id: "1",
                            institute_subject_id: "103066",
                            subject_name: "ENGLISH",
                            activities: [

                                // Activity with rubrics
                                ActivityData(
                                    activity_id: "1",
                                    activity_name: "Notebook",
                                    max_mark: "100",
                                    rubrics: [
                                        RubricData(
                                            rubric_id: "1",
                                            rubric_name: "Presentation",
                                            max_mark: "100",
                                            isChecked: false,
                                            selectedAIOption: nil
                                        ),
                                        RubricData(
                                            rubric_id: "2",
                                            rubric_name: "Content",
                                            max_mark: "100",
                                            isChecked: false,
                                            selectedAIOption: nil
                                        )
                                    ],
                                    isChecked: false,
                                    selectedAIOption: nil
                                ),

                                // Activity without rubrics
                                ActivityData(
                                    activity_id: "2",
                                    activity_name: "Submission",
                                    max_mark: "100",
                                    rubrics: [],
                                    isChecked: false,
                                    selectedAIOption: nil
                                )
                            ]
                        ),

                        SubjectExamData(
                            subject_id: "2",
                            institute_subject_id: "103114",
                            subject_name: "TAMIL",
                            activities: [

                                // Activity without rubrics
                                ActivityData(
                                    activity_id: "3",
                                    activity_name: "Notebook",
                                    max_mark: "100",
                                    rubrics: [],
                                    isChecked: false,
                                    selectedAIOption: nil
                                ),

                                // Activity with rubrics
                                ActivityData(
                                    activity_id: "4",
                                    activity_name: "Submission",
                                    max_mark: "100",
                                    rubrics: [
                                        RubricData(
                                            rubric_id: "7",
                                            rubric_name: "Time Management",
                                            max_mark: "100",
                                            isChecked: false,
                                            selectedAIOption: nil
                                        ),
                                        RubricData(
                                            rubric_id: "8",
                                            rubric_name: "Accuracy",
                                            max_mark: "100",
                                            isChecked: false,
                                            selectedAIOption: nil
                                        )
                                    ],
                                    isChecked: false,
                                    selectedAIOption: nil
                                )
                            ]
                        )
                    ]//response.data ?? []
                    self.tableview.reloadData()
                    
                    if !(response.status ?? false) {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: response.message ?? "", on: self) {}
                    }
                   
                case .failure(let error):
                    print("Error loading subjects: \(error)")
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: error.localizedDescription, on: self) {}
                }
            }
        }
    }
    
    private func updateMainHeight() {
        DispatchQueue.main.async {
            self.tableview.beginUpdates()
            self.tableview.endUpdates()
            self.tableview.layoutIfNeeded()
            self.tableviewHeight.constant = self.tableview.contentSize.height
        }
    }

    
    @IBAction func continueAct(_ sender: Any) {
        
        if let payload = buildPayload() {
            print(payload)
            print(convertedRecords)
            let vc = EnterMarkVC()
            vc.payload = payload
            vc.aiRecords = convertedRecords
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        } else {
            let message = isAIFlow ? ExamMarkUploadString.Please_Map_atleast_one_activity_to_continue.translated() : ExamMarkUploadString.Please_select_atleast_one_activity_to_continue.translated()
            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Missing_Information, message: message, on: self)
        }
    }
    
//    func buildPayload() -> [String: Any]? {
//
//        let selectedActivities = SubjectList.compactMap { subject -> [String: Any]? in
//            let selected = subject.activities?.filter { $0.isChecked ?? false} ?? []
//            guard !selected.isEmpty else { return nil }
//
//            return [
//                "subject_id": subject.subject_id ?? "",
//                "subject_name": subject.subject_name ?? "",
//                "activities": selected.map {
//                    var dict: [String: Any] = [
//                        "activity_id": $0.activity_id ?? "",
//                        "activity_name": $0.activity_name ?? "",
//                        "max_mark": $0.max_mark ?? ""
//                    ]
//                    if isAIFlow {
//                        dict["ai_option"] = $0.selectedAIOption ?? ""
//                    }
//                    return dict
//                }
//            ]
//        }
//
//        guard !selectedActivities.isEmpty else {
//            return nil
//        }
//
//        return [
////            "class_id": SubjectList.first?.class_id ?? "",
////            "section_id": SubjectList.first?.section_id ?? "",
//            "exam_id": ExamID,
//            "academic_year_id": String(academicYearId ?? 0),
//            "selected_activities": selectedActivities
//        ]
//    }
    
    func buildPayload() -> [String: Any]? {

        let selectedSubjects = SubjectList.compactMap { subject -> [String: Any]? in

            let selectedActivities = subject.activities?.compactMap { activity -> [String: Any]? in

                let hasRubrics = !(activity.rubrics?.isEmpty ?? true)

                let selectedRubrics = activity.rubrics?
                    .filter { isAIFlow ? ($0.selectedAIOption != nil) : ($0.isChecked == true) }
                    .map { rubric -> [String: Any] in

                        let dict: [String: Any] = [
                            "id": rubric.rubric_id ?? "",
                            "selected_name": isAIFlow
                                ? (rubric.selectedAIOption ?? rubric.rubric_name ?? "")
                                : (rubric.rubric_name ?? "")
                        ]

                        return dict
                    } ?? []

                let shouldIncludeActivity: Bool
                if hasRubrics {
                    shouldIncludeActivity = !selectedRubrics.isEmpty
                } else if isAIFlow {
                    shouldIncludeActivity = activity.selectedAIOption != nil
                } else {
                    shouldIncludeActivity = activity.isChecked == true
                }

                guard shouldIncludeActivity else { return nil }
                
                let activitySelectedName = (isAIFlow && !hasRubrics)
                    ? (activity.selectedAIOption ?? "")
                    : (activity.activity_name ?? "")
                
                let dict: [String: Any] = [
                    "id": activity.activity_id ?? "",
                    "selected_name": activitySelectedName,
                    "rubrics": selectedRubrics
                ]
                
                return dict

            } ?? []

            guard !selectedActivities.isEmpty else { return nil }

            return [
                "subject_id": subject.subject_id ?? "",
                "activities": selectedActivities
            ]
        }

        guard !selectedSubjects.isEmpty else {
            return nil
        }

        return [
            "exam_id": ExamID,
            "section_id": section_Id,
            "academic_year_id": String(academicYearId ?? 0),
            "selected_activities": selectedSubjects
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

        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.SubjectsTVCell, for: indexPath) as! SubjectsTVCell

        let data = SubjectList[indexPath.row]

        cell.subjectLbl.text = data.subject_name
            cell.subjectIndex = indexPath.row
            cell.isAI = isAIFlow
        cell.config(dropDown:selectedColoumns)
            cell.delegate = self
            cell.isExpanded = (expandedIndex == indexPath)
            cell.splits = data.activities ?? []
            cell.updateStatusLabel()
            cell.statusLbl.text = "• \(data.activities?.count ?? 0) Activities"
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
        func didUpdateSplit(subjectIndex: Int, splitIndex: Int, split: ActivityData) {
            SubjectList[subjectIndex].activities?[splitIndex] = split
        }
    }

