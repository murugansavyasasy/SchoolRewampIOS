//
//  MarkListVC.swift
//  School Chimes
//
//  Created by Chandhru on 12/07/25.
//

import UIKit

class MarkListVC: UIViewController {
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    var subject_marks: [SubjectMark]?
    var assessments: [Assessment]?
    var groups: [Groups]?
    var exameMarks: [ExamData]?
    var examId:String?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.text = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        NameLbl.text = studentDetails?.name ?? ""
        tv.register(UINib(nibName: CellConfingName.SettingHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: CellConfingName.SettingHeaderView)
        tv.register(UINib(nibName: CellConfingName.ExammarkFooterView, bundle: nil), forHeaderFooterViewReuseIdentifier: CellConfingName.ExammarkFooterView)
        tv.register(UINib(nibName: CellConfingName.ExamMarkTV, bundle: nil), forCellReuseIdentifier: CellConfingName.ExamMarkTV)
        tv.delegate = self
        tv.dataSource = self
        markListApi(exam_id:examId ?? "")
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    func markListApi(exam_id: String) {
        APIService.shared.makeApi(
            url: ServiceUrl.exam_api_exam_view_marks,
            parameters: ["exam_id": exam_id],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<ExamMarksResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.exameMarks = response.data
                    self?.subject_marks = response.data?.first?.subject_marks
                    self?.assessments = response.data?.first?.assessments
                    self?.groups = response.data?.first?.groups
                    self?.tv.reloadData()
                case .failure(let error):
                    print("API Error:", error)
                }
            }
        }
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

// MARK: - TableView
extension MarkListVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellConfingName.SettingHeaderView) as! SettingHeaderView
        cell.headerLabel.text = section == 0 ? "Subject Marks" : "Group Evaluation"
        cell.headerLabel.setFont(style: .title, size: FontSize.TitleSize)
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return exameMarks?.count ?? 0 - 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? subject_marks?.count ?? 0 : groups?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ExamMarkTV, for: indexPath) as! ExamMarkTV

        if indexPath.section == 0 {
            let mark = subject_marks?[indexPath.row]
            cell.SubjectLbl.text = mark?.name
            cell.MarkLbl.text = "\(mark?.mark_obtained ?? "0") / \(mark?.max_mark ?? "0")"

            if let obtained = Float(mark?.mark_obtained ?? "0"),
               let total = Float(mark?.max_mark ?? "0"),
               total > 0 {
                let progress = obtained / total
                cell.progessBar.progress = progress
                if #available(iOS 15.0, *) {
                    cell.progessBar.progressTintColor = .systemMint
                }
            } else {
                cell.progessBar.progress = 0.0
            }
        } else {
            let group = groups?[indexPath.row]
            cell.SubjectLbl.text = group?.name
            cell.MarkLbl.text = group?.mark
            cell.progessBar.progress = 0.0 // update if percentage logic is required
            if #available(iOS 15.0, *) {
                cell.progessBar.progressTintColor = .systemMint
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == (exameMarks?.count ?? 1) - 1 else { return nil } // Show only for the last section

        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellConfingName.ExammarkFooterView) as! ExammarkFooterView
        cell.footerview.layer.cornerRadius = 10
        cell.TotalLbl.setFont(style: .title, size: FontSize.TitleSize)
        cell.TotalMarkLbl.setFont(style: .title, size: FontSize.TitleSize)
        cell.RankLbl.setFont(style: .title, size: FontSize.TitleSize)
        cell.RankNumLbl.setFont(style: .title, size: FontSize.TitleSize)
        // ✅ Safely unwrap assessments array
         if let assessments = assessments {
             for item in assessments {
                 let key = item.name ?? ""
                 let value = item.value ?? ""
                 switch key {
                 case "Total":
                     cell.TotalLbl.text = "Total"
                     cell.TotalMarkLbl.text = value
                     let parts = value.components(separatedBy: "/")

                     if parts.count == 2 {
                         let obtainedStr = parts[0].trimmingCharacters(in: .whitespaces)
                         let maxStr = parts[1].trimmingCharacters(in: .whitespaces)

                         // Step 2: Convert to Double
                         if let obtained = Double(obtainedStr), let total = Double(maxStr), total != 0 {
                             let percentage = (obtained / total)
                             cell.TotalProgressBar.progress = Float(percentage)
                         }
                     }

                 case "Rank":
                     cell.RankLbl.text = "Rank : \(value)"
                     cell.RankNumLbl.text = value
                     cell.medalImagView.isHidden = value == "NA"
                     cell.RankNumLbl.isHidden = value == "NA"
                 default:
                     break
                 }
             }
         }
        return cell
    }


    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == (exameMarks?.count ?? 1) - 1 ? 130 : 0.01
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section != (exameMarks?.count ?? 1) - 1 ? 0.01 : 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ExamMarkTV {
            // Toggle arrow icon
              let shouldExpand = cell.MarksStackview.isHidden
              cell.MarksStackview.isHidden = !shouldExpand
            
              cell.ArrowImageview.image = UIImage(named: shouldExpand ? "arrow_up" : "arrow_down")

              if indexPath.section == 0 {
                  guard let splits = subject_marks?[indexPath.row].split else { return }

                  // Clear existing arranged subviews to avoid duplicates
                  cell.MarksStackview.arrangedSubviews.forEach { $0.removeFromSuperview() }

                  // Add new labels based on the split array
                  for (index, item) in splits.enumerated() {
                      let label = UILabel()
                      label.text = "\(splits[index].name ?? "") - \(splits[index].mark_obtained ?? "") /  \(splits[index].max_mark ?? "")"
                      label.textColor = .darkGray
                      label.setFont(style: .body, size: FontSize.BodySize)
                      cell.MarksStackview.addArrangedSubview(label)
                      
                  }
                  cell.stackHeight.constant = CGFloat(!shouldExpand ? 0 : splits.count * 25)
              }
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}
