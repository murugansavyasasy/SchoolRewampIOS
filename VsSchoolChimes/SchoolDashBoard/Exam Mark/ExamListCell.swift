//
//  ExamListCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 25/11/25.
//

import UIKit

class ExamListCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var sideColourView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var ArrowBtn: UIButton!
    @IBOutlet weak var innerTableHeight: NSLayoutConstraint!
    @IBOutlet weak var checkCircleBtn: UIButton!
    @IBOutlet weak var selectioView: UIView!
    @IBOutlet weak var examNameLbl: UILabel!
    @IBOutlet weak var examDateLbl: UILabel!
    

    var onExpand: (() -> Void)?
    var onInnerHeightChanged: (() -> Void)?
    var expandedRow: IndexPath?
    var isExpanded = false
    var subjectList: [SubjectExamData] = []

    override func awakeFromNib() {
        super.awakeFromNib()

        baseView.layer.cornerRadius = 10
        baseView.layer.shadowColor = UIColor.black.cgColor
        baseView.layer.shadowOpacity = 0.15
        baseView.layer.shadowRadius = 4
        baseView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        sideColourView.layer.cornerRadius = 10
        sideColourView.layer.maskedCorners = [.layerMinXMinYCorner]
        
        selectioView.layer.cornerRadius = 10
        selectioView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        examNameLbl.setFont(style: .body, size: 17)
        examNameLbl.setFont(style: .body, size: 13)
        
        selectionStyle = .none
        tableview.isScrollEnabled = false
        tableview.isHidden = true
        //tableview.separatorStyle = .none
        tableview.estimatedRowHeight = 80
        tableview.rowHeight = UITableView.automaticDimension

        tableview.register(
            UINib(nibName: "Exam_ExamListTV", bundle: nil),
            forCellReuseIdentifier: "Exam_ExamListTV"
        )

        tableview.dataSource = self
        tableview.delegate = self

        innerTableHeight.constant = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isExpanded = false
        expandedRow = nil
        tableview.isHidden = true
        innerTableHeight.constant = 0
    }

    func configureExpansionState(_ expanded: Bool) {
        isExpanded = expanded
        ArrowBtn.setImage(UIImage(systemName: expanded ? "chevron.up" : "chevron.down"),for: .normal)

        if expanded {
            tableview.isHidden = false
            tableview.reloadData()
            tableview.layoutIfNeeded()

            DispatchQueue.main.async {
                self.tableview.layoutIfNeeded()
                let height = self.tableview.contentSize.height
                if height > 0 {
                    self.innerTableHeight.constant = height
                    // 🔑 Force parent table to recalc row height
                    if let parentTable = self.superview as? UITableView {
                        parentTable.beginUpdates()
                        parentTable.endUpdates()
                    }
                }
            }

        } else {
            tableview.isHidden = true
            innerTableHeight.constant = 0
            expandedRow = nil
        }
    }

    @IBAction func expandAct(_ sender: UIButton) {
        onExpand?()
    }

    func updateInnerHeight(animated: Bool) {
        DispatchQueue.main.async {
            self.tableview.layoutIfNeeded()
            let height = self.tableview.contentSize.height

            if height > 0 {
                self.innerTableHeight.constant = height

                if animated {
                    UIView.animate(withDuration: 0.25) {
                        self.layoutIfNeeded()
                    }
                } else {
                    self.layoutIfNeeded()
                }

                self.onInnerHeightChanged?()
            }
        }
    }
}

extension ExamListCell: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return subjectList.count
    }

    func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Exam_ExamListTV",for: indexPath) as! Exam_ExamListTV

        cell.subjectNameLbl.text = subjectList[indexPath.row].subject_name
        
        cell.Activities = subjectList[indexPath.row].splitup_details ?? []
        
        cell.configureExpansionState(expandedRow == indexPath, animated: false)

        // INNER EXPAND
        cell.onExpand = { [weak self, weak tableView] in
            guard let self = self, let tableView = tableView else { return }

            let old = self.expandedRow
            self.expandedRow = (old == indexPath) ? nil : indexPath

            var reload = [indexPath]
            if let old = old, old != indexPath { reload.append(old) }

            tableView.reloadRows(at: reload, with: .automatic)

            DispatchQueue.main.async {
                self.tableview.layoutIfNeeded()
                self.innerTableHeight.constant = self.tableview.contentSize.height
                self.onInnerHeightChanged?()
            }
        }

        // INNER CONTENT HEIGHT CHANGE
        cell.onHeightChanged = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableview.layoutIfNeeded()
                self.innerTableHeight.constant = self.tableview.contentSize.height
                self.onInnerHeightChanged?()
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
