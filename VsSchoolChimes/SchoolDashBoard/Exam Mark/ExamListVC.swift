//
//  ExamListVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 24/11/25.
//

import UIKit

class ExamListVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var bottomSlectInfoLbl: UILabel!
    @IBOutlet weak var classNameLbl: UILabel!
    @IBOutlet weak var SelectExamDefLbl: UILabel!
    
    var standard : ClassDisplayItem?
    var expandedRow: IndexPath? = nil
    var selectedRow: IndexPath? = nil
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var ExamList : [StaffExamData] = []
    var SubjectList : [SubjectExamData] = []
    var examIds : String?
    var apiCalledForIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        classNameLbl.text = standard?.displayName
        classNameLbl.setFont(style: .title, size: FontSize.TitleSize)
        SelectExamDefLbl.setFont(style: .body, size: FontSize.BodySize)
        SelectExamDefLbl.textColor = .black.withAlphaComponent(0.7)
        
        bottomSlectInfoLbl.setFont(style: .body, size: FontSize.BodySize)
        bottomSlectInfoLbl.alpha = 0.7
        
        continueBtn.alpha = 0.7
        continueBtn.layer.cornerRadius = 10
        continueBtn.isUserInteractionEnabled = false

        tv.register(UINib(nibName: "ExamListHeader", bundle: nil),
                    forHeaderFooterViewReuseIdentifier: "ExamListHeader")
        tv.register(UINib(nibName: "ExamListCell", bundle: nil),
                    forCellReuseIdentifier: "ExamListCell")

        tv.delegate = self
        tv.dataSource = self
        
        Get_staffwise_exam_Api()
    }
    
    func Get_staffwise_exam_Api() {
        
        let param:[String:Any] = ["section_id": standard?.sectionId ?? ""]
        APIService.shared.makeApi(url: ServiceUrl.exam_api_exam_get_staff_wise_exam, parameters: param, type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [weak self] (result: Result<StaffExamListResponse, Error>) in
            
            guard let self = self else{return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    
                    self.ExamList = success.data ?? []
                    self.tv.reloadData()
                    
                case .failure(let failure):
                    ""
                }
            }
        }
    }
    
    func loadSubjectList(for examId: String, reloadIndex: IndexPath) {
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

                    // Reload only the expanded row
                    self.tv.beginUpdates()
                    self.tv.reloadRows(at: [reloadIndex], with: .automatic)
                    self.tv.endUpdates()

                case .failure(let error):
                    print("Error loading subjects: \(error)")
                }
            }
        }
    }

    
    @available(iOS 14.0, *)
    @IBAction func continueAct(_ sender: Any) {
        
        let vc = ExamImgUploadVC()
        vc.examId = examIds
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
}

extension ExamListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ExamList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ExamListCell", for: indexPath) as! ExamListCell
        
        let exam = ExamList[indexPath.row]
        
        cell.examNameLbl.text = exam.name
        cell.examDateLbl.text = exam.date

        let isSelected = (selectedRow == indexPath)
        
        if isSelected{
            cell.sideColourView.backgroundColor = .staffExamColour
            cell.selectioView.backgroundColor = .staffExamColour.withAlphaComponent(0.05)
            cell.checkCircleBtn.setImage(UIImage(systemName: "inset.filled.circle"),for: .normal)
            cell.checkCircleBtn.tintColor = .staffExamColour
            cell.examNameLbl.textColor = .staffExamColour
        }else{
            cell.sideColourView.backgroundColor = .clear
            cell.selectioView.backgroundColor = .clear
            cell.checkCircleBtn.setImage(UIImage(systemName: "circle"),for: .normal)
            cell.checkCircleBtn.tintColor = .lightGray
            cell.examNameLbl.textColor = .black
        }

            let isExpanded = (expandedRow == indexPath)
            
            if isExpanded {
                cell.subjectList = self.SubjectList       // <----- ⭐ PLACE IT HERE
                //cell.tableview.reloadData()
            }
        
        cell.configureExpansionState(isExpanded)


        // OUTER expand
        cell.onExpand = { [weak self] in
            guard let self = self else { return }

            let old = self.expandedRow
            self.expandedRow = (old == indexPath) ? nil : indexPath

            // Call API only when expanding (not collapsing)
            if self.expandedRow == indexPath {
                let examId = self.ExamList[indexPath.row].id ?? ""
                self.loadSubjectList(for: examId, reloadIndex: indexPath)
                examIds = examId
            }

            var reload: [IndexPath] = [indexPath]
            if let old = old, old != indexPath { reload.append(old) }

            self.tv.reloadRows(at: reload, with: .automatic)
        }

        // INNER height change → refresh outer row
        cell.onInnerHeightChanged = { [weak self] in
            guard let self = self else { return }
            self.tv.beginUpdates()
            self.tv.endUpdates()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let previousSelected = selectedRow        // save old selection
        selectedRow = indexPath                   // update to new selection
        examIds = ExamList[indexPath.row].id
        continueBtn.isUserInteractionEnabled = true
        continueBtn.alpha = 1
        bottomSlectInfoLbl.isHidden = true

        var rowsToReload: [IndexPath] = [indexPath]

        if let previous = previousSelected, previous != indexPath {
            rowsToReload.append(previous)
        }

        tableView.reloadRows(at: rowsToReload, with: .automatic)
    }

    func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
