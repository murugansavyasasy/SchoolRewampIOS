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
    @IBOutlet weak var RoundView: UIView!
    @IBOutlet weak var NewTv: UITableView!
    
    var subject_marks: [SubjectMark]?
    var assessments: [Assessment]?
    var groups: [Groups]?
    var exameMarks: [ExamData]?
    var examId: String?
    var ArrayCount: Int?
    var ExamMarkTvCell = "ExamMarkTvCell"
    var TotalMarkTvCell = "TotalMarkTvCell"
    var ExamTitle:String?

    var studentDetails = UserDefaultFileManager.get_child_Details()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackBtn.configureAsBackButton(firstLine: studentDetails?.name ?? "", secondLine: "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")")
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        
        NewTv.showsVerticalScrollIndicator = false
        NewTv.showsHorizontalScrollIndicator = false
        
        RoundView.layer.cornerRadius = RoundView.frame.width / 2

        StandardLbl.text = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        NameLbl.text = studentDetails?.name ?? ""

        tv.register(UINib(nibName: CellConfingName.SettingHeaderView, bundle: nil), forHeaderFooterViewReuseIdentifier: CellConfingName.SettingHeaderView)
        tv.register(UINib(nibName: CellConfingName.ExammarkFooterView, bundle: nil), forHeaderFooterViewReuseIdentifier: CellConfingName.ExammarkFooterView)
        tv.register(UINib(nibName: CellConfingName.ExamMarkTV, bundle: nil), forCellReuseIdentifier: CellConfingName.ExamMarkTV)
        NewTv.register(UINib(nibName: ExamMarkTvCell, bundle: nil), forCellReuseIdentifier: ExamMarkTvCell)
        NewTv.register(UINib(nibName: TotalMarkTvCell, bundle: nil), forCellReuseIdentifier: TotalMarkTvCell)
        NewTv.register(UINib(nibName:CellConfingName.SettingHeaderView,bundle:nil),forHeaderFooterViewReuseIdentifier: CellConfingName.SettingHeaderView)

//        tv.delegate = self
//        tv.dataSource = self
        
        NewTv.delegate = self
        NewTv.dataSource = self

        markListApi(exam_id: examId ?? "")
    }

    override func viewDidLayoutSubviews() {
       view.applyGradient(colors: [Colornames.gradientBlue, Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5), endPoint: CGPoint(x: 0, y: 0.5))
    }

    func markListApi(exam_id: String) {
        APIService.shared.makeApi(
            url: ServiceUrl.exam_api_exam_view_marks,
            parameters: ["exam_id": exam_id],
            type: ApitTypeSringFile.GET,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<ExamMarksResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.exameMarks = response.data
                    self?.subject_marks = response.data?.first?.subject_marks
                    self?.assessments = response.data?.first?.assessments
                    self?.groups = response.data?.first?.groups
                    self?.NewTv.reloadData()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
                return nil
            }
        
        let headerView = UIView()
        headerView.backgroundColor = .clear  // Customize color

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFont(style: .title, size: FontSize.TitleSize)
        label.textColor = .label
        label.text = section == 1 ? "Subjects & Marks" : "Other Activities"
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5)])

        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
         
        case 0:
            return 1
        case 1:
            return subject_marks?.count ?? 0
        case 2:
            return groups?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
            
        case 0:
            let cell = NewTv.dequeueReusableCell(withIdentifier: "TotalMarkTvCell", for: indexPath) as! TotalMarkTvCell
            
            cell.ExamTitleLbl.text = ExamTitle
            return cell
            
        case 1:
            
            let cell = NewTv.dequeueReusableCell(withIdentifier: ExamMarkTvCell, for: indexPath) as! ExamMarkTvCell
            cell.headerLbl.isHidden = true
            let data = subject_marks?[indexPath.row]
            let mark = ("\(data?.mark_obtained ?? "") / \(data?.max_mark ?? "")")
            cell.subjectLbl.text = mark//data?.name
            cell.SubjectMarkBtn.setTitle(data?.name, for: .normal)
            if data?.split?.count ?? 0 > 1{
                cell.configure(data: data?.split ?? [])
            }
            let Percentage = data?.percentage?.replacingOccurrences(of: "%", with: "") ?? ""
            cell.updateButtonColour(for: Double(Percentage) ?? 0)
            return cell
            
        case 2:
            
            let cell = NewTv.dequeueReusableCell(withIdentifier: ExamMarkTvCell, for: indexPath) as! ExamMarkTvCell
            cell.headerLbl.isHidden = true//!(indexPath.row == 0)
            let data = groups?[indexPath.row]
            cell.subjectLbl.text = data?.mark
            cell.SubjectMarkBtn.setTitle(data?.name, for: .normal)
            if data?.subgroups?.count ?? 0 > 1{
                cell.configureGroup(data: data?.subgroups ?? [])
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNormalMagnitude : 40 // Or your desired height
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    

//    func numberOfSections(in tableView: UITableView) -> Int {
//        var count = 0
//        if let subjectMarks = subject_marks, !subjectMarks.isEmpty {
//            count += 1
//        }
//        if let groupItems = groups, !groupItems.isEmpty {
//            count += 1
//        }
//        ArrayCount = count
//        return count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if ArrayCount == 2 {
//            return section == 0 ? subject_marks?.count ?? 0 : groups?.count ?? 0
//        } else if subject_marks != nil {
//            return subject_marks?.count ?? 0
//        } else {
//            return groups?.count ?? 0
//        }
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellConfingName.SettingHeaderView) as! SettingHeaderView
//        if ArrayCount == 2 {
//            cell.headerLabel.text = section == 0 ? "Subject Marks" : "Group Evaluation"
//        } else if subject_marks != nil {
//            cell.headerLabel.text = "Subject Marks"
//        } else {
//            cell.headerLabel.text = "Group Evaluation"
//        }
//        cell.headerLabel.setFont(style: .title, size: FontSize.TitleSize)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 44
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ExamMarkTV, for: indexPath) as! ExamMarkTV
//        cell.progessBar.progress = 0.0
//        cell.MarksStackview.isHidden = true
//
//        if (ArrayCount == 2 && indexPath.section == 0) || (ArrayCount == 1 && subject_marks != nil) {
//            let mark = subject_marks?[indexPath.row]
//            cell.SubjectLbl.text = mark?.name
//            cell.MarkLbl.text = "\(mark?.mark_obtained ?? "0") / \(mark?.max_mark ?? "0")"
//            if let obtained = Float(mark?.mark_obtained ?? "0"),
//               let total = Float(mark?.max_mark ?? "0"),
//               total > 0 {
//                cell.progessBar.progress = obtained / total
//            }
//        } else {
//            let group = groups?[indexPath.row]
//            cell.SubjectLbl.text = group?.name
//            cell.MarkLbl.text = group?.mark
//        }
//
//        if #available(iOS 15.0, *) {
//            cell.progessBar.progressTintColor = .systemMint
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        guard section == (ArrayCount ?? 1) - 1 else { return nil }
//
//        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellConfingName.ExammarkFooterView) as! ExammarkFooterView
//        cell.footerview.layer.cornerRadius = 10
//        cell.TotalLbl.setFont(style: .title, size: FontSize.TitleSize)
//        cell.TotalMarkLbl.setFont(style: .title, size: FontSize.TitleSize)
//        cell.RankLbl.setFont(style: .title, size: FontSize.TitleSize)
//        cell.RankNumLbl.setFont(style: .title, size: FontSize.TitleSize)
//
//        if let assessments = assessments {
//            for item in assessments {
//                let key = item.name ?? ""
//                let value = item.value ?? ""
//
//                switch key {
//                case "Total":
//                    cell.TotalLbl.text = "Total"
//                    cell.TotalMarkLbl.text = value
//                    let parts = value.components(separatedBy: "/")
//                    if parts.count == 2,
//                       let obtained = Double(parts[0].trimmingCharacters(in: .whitespaces)),
//                       let total = Double(parts[1].trimmingCharacters(in: .whitespaces)),
//                       total != 0 {
//                        cell.TotalProgressBar.progress = Float(obtained / total)
//                    }
//                case "Rank":
//                    cell.RankLbl.text = "Rank : \(value)"
//                    cell.RankNumLbl.text = value
//                    cell.medalImagView.isHidden = value == "NA"
//                    cell.RankNumLbl.isHidden = value == "NA"
//                default:
//                    break
//                }
//            }
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return section == (ArrayCount ?? 1) - 1 ? 130 : 0.01
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) as? ExamMarkTV else { return }
//
//        let shouldExpand = cell.MarksStackview.isHidden
//        cell.MarksStackview.isHidden = !shouldExpand
//        cell.ArrowImageview.image = UIImage(named: shouldExpand ? "arrow_up" : "arrow_down")
//
//        // Clear previous stack items
//        cell.MarksStackview.arrangedSubviews.forEach { $0.removeFromSuperview() }
//
//        let isSubjectSection = (ArrayCount == 2 && indexPath.section == 0) || (ArrayCount == 1 && subject_marks != nil)
//        let isGroupSection = !isSubjectSection
//
//        if isSubjectSection {
//            guard let splits = subject_marks?[indexPath.row].split else { return }
//
//            for item in splits {
//                let label = UILabel()
//                label.text = "\(item.name ?? "") - \(item.mark_obtained ?? "") / \(item.max_mark ?? "")"
//                label.textColor = .darkGray
//                label.setFont(style: .body, size: FontSize.BodySize)
//                cell.MarksStackview.addArrangedSubview(label)
//            }
//
//            cell.stackHeight.constant = shouldExpand ? CGFloat(splits.count * 25) : 0
//        } else if isGroupSection {
//            guard let subgroups = groups?[indexPath.row].subgroups else { return }
//
//            for item in subgroups {
//                let label = UILabel()
//                label.text = "\(item.name ?? "") - \(item.mark ?? "")"
//                label.textColor = .darkGray
//                label.setFont(style: .body, size: FontSize.BodySize)
//                cell.MarksStackview.addArrangedSubview(label)
//            }
//
//            cell.stackHeight.constant = shouldExpand ? CGFloat(subgroups.count * 25) : 0
//        }
//
//        tableView.beginUpdates()
//        tableView.endUpdates()
//    }
}


import UIKit

class CircularProgressView: UIView {

    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: bounds.width / 2.5,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 3 * CGFloat.pi / 2,
                                        clockwise: true)

        // Track Layer
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 8
        layer.addSublayer(trackLayer)

        // Progress Layer
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 8
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = .round
        layer.addSublayer(progressLayer)
    }

    /// Public method to set progress
    func setProgress(to progress: CGFloat) {
        progressLayer.strokeEnd = progress
    }
}
