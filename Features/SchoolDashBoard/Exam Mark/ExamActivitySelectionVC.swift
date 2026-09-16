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
    var coscholasticList : [coscholastic] = []
    var isAIFlow: Bool = false
    var ExamID = ""
    var section_Id = ""
    let staffDetails = UserDefaultFileManager.get_staff_Details()
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
        coscholasticList.removeAll()
        let param:[String:Any] = ["exam_id": examId,"section_id": section_Id]

        APIService.shared.makeApi(
            url: ServiceUrl.new_exam_get_subject_activities,
            parameters: param,
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<SubjectWiseExamResponse, Error>) in

            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.SubjectList = response.data?.first?.subjects ?? []
                    self.coscholasticList = response.data?.first?.co_scholastic ?? []
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
        
        let coScholasticIds = coscholasticList.filter{ $0.isChecked == true}.map {
           [
            "id": $0.id ?? "",
            "name": $0.name ?? ""
           ]
        }


        guard !selectedSubjects.isEmpty || !coScholasticIds.isEmpty  else {
            return nil
        }
        
        return [
            "exam_id": ExamID,
            "section_id": section_Id,
            "academic_year_id": String(academicYearId ?? 0),
            "selected_activities": selectedSubjects,
            "co_scholastic_ids" : coScholasticIds
        ]
    }

    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension ExamActivitySelectionVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Subjects" : "Coscholastic"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? SubjectList.count : coscholasticList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.SubjectsTVCell, for: indexPath) as! SubjectsTVCell
            
            let data = SubjectList[indexPath.row]
            
            cell.expandIconBtn.isHidden = false
            cell.checkCircleBtn.isHidden = true
            
            cell.subjectLbl.text = data.subject_name
            cell.subjectIndex = indexPath.row
            cell.isAI = isAIFlow
            cell.config(dropDown:selectedColoumns)
            cell.delegate = self
            cell.isExpanded = (expandedIndex == indexPath)
            cell.splits = data.activities ?? []
            cell.updateStatusLabel()
            cell.statusLbl.isHidden = false
            //cell.statusLbl.text = "• \(data.activities?.count ?? 0) Activities"
            cell.configureExpandState()
            cell.onHeightChange = { [weak self] in
                self?.updateMainHeight()
            }
            
            return cell
        }else {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CellConfingName.SubjectsTVCell,
                for: indexPath
            ) as! SubjectsTVCell
            
            let data = coscholasticList[indexPath.row]
            
            cell.expandIconBtn.isHidden = true
            cell.tableview.isHidden = true
            cell.tableviewHeight.constant = 0
            cell.separatorLineView.isHidden = true
            cell.isExpanded = false
            cell.splits = []
            
            cell.subjectLbl.text = data.name
            
            cell.checkCircleBtn.isHidden = false
            
            
            if data.isChecked == true {
                cell.checkCircleBtn.setImage(
                    UIImage(systemName: "checkmark.circle.fill"),
                    for: .normal
                )
                cell.checkCircleBtn.tintColor = .staffExamColour
                cell.statusLbl.textColor = .systemGreen
                cell.subjectView.backgroundColor = .systemGreen.withAlphaComponent(0.05)
                cell.baseView.layer.borderColor = UIColor.systemGreen.cgColor
                
                if isAIFlow {
                    cell.statusLbl.isHidden = false
                    cell.statusLbl.text = "Mapped to: \(data.selectedAIOption ?? "")"
                }else {
                    cell.statusLbl.isHidden = true
                }
                
            }else {
                cell.checkCircleBtn.setImage(
                    UIImage(systemName: "circle"),
                    for: .normal
                )
                cell.checkCircleBtn.tintColor = .lightGray
                cell.statusLbl.textColor = .darkGray
                cell.subjectView.backgroundColor = .systemBackground
                cell.baseView.layer.borderColor = UIColor.lightGray.cgColor
                cell.statusLbl.isHidden = true
            }
            
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
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
        }else {
            

            if isAIFlow {
                
                guard let cell = tableView.cellForRow(
                    at: indexPath
                ) as? SubjectsTVCell else {
                    return
                }

                let currentValue =
                    coscholasticList[indexPath.row].selectedAIOption

                cell.showDropdown(
                    items: selectedColoumns,
                    selectedValue: currentValue
                ) { [weak self] selectedItem in

                    guard let self = self else {
                        return
                    }

                    self.coscholasticList[indexPath.row].selectedAIOption =
                        selectedItem

                    self.coscholasticList[indexPath.row].isChecked = true

                    print(
                        "Coscholastic \(indexPath.row): \(selectedItem)"
                    )
                    tableView.reloadRows(
                        at: [indexPath],
                        with: .automatic
                    )
                }

            } else {

                let currentValue =
                    coscholasticList[indexPath.row].isChecked ?? false

                coscholasticList[indexPath.row].isChecked =
                    !currentValue

                tableView.reloadRows(
                    at: [indexPath],
                    with: .automatic
                )
            }
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

