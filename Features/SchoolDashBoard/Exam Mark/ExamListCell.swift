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
    var onHeightChange: (() -> Void)?
    var expandedRow: IndexPath?
    var isExpanded = false
    var subjectList: [SubjectExamData] = [] {
           didSet { tableview.reloadData() }
       }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        baseView.layer.cornerRadius = 10
        baseView.layer.shadowColor = UIColor.black.cgColor
        baseView.layer.shadowOpacity = 0.15
        baseView.layer.shadowRadius = 4
        baseView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        sideColourView.layer.cornerRadius = 6
        sideColourView.layer.maskedCorners = [.layerMinXMinYCorner]
        
        selectioView.layer.cornerRadius = 10
        selectioView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        tableview.layer.cornerRadius = 10
        tableview.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        examNameLbl.setFont(style: .body, size: 17)
        examDateLbl.setFont(style: .body, size: 13)
        
        selectionStyle = .none
        tableview.isScrollEnabled = false
        tableview.isHidden = true
        //tableview.separatorStyle = .none
        tableview.estimatedRowHeight = 80
        tableview.rowHeight = UITableView.automaticDimension
        
        tableview.register( UINib(nibName: CellConfingName.Exam_ExamListTV, bundle: nil), forCellReuseIdentifier:CellConfingName.Exam_ExamListTV)
        
        tableview.dataSource = self
        tableview.delegate = self
    }
    
    override func prepareForReuse() {
            super.prepareForReuse()
            isExpanded = false
            expandedRow = nil
            tableview.isHidden = true
            innerTableHeight.constant = 0
            onExpand = nil
            onHeightChange = nil
        }
    
    func configureExpansionState(_ expanded: Bool) {
           isExpanded = expanded

           ArrowBtn.setImage(UIImage(systemName: expanded ? "chevron.up" : "chevron.down"), for: .normal)
           tableview.isHidden = !expanded

           if expanded {
               tableview.reloadData()
               updateInnerHeight()          // synchronous now
           } else {
               expandedRow = nil
               innerTableHeight.constant = 0
           }
       }
    
    func updateInnerHeight() {
        tableview.layoutIfNeeded()
        let newHeight = tableview.contentSize.height
        if innerTableHeight.constant != newHeight {
            innerTableHeight.constant = newHeight
        }
        setNeedsLayout()
        layoutIfNeeded()
        DispatchQueue.main.async { [weak self] in
            self?.onHeightChange?()
        }
    }
    
    @IBAction func expandAct(_ sender: UIButton) {
        onExpand?()
    }
}

extension ExamListCell: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int {
        return subjectList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.Exam_ExamListTV, for: indexPath) as! Exam_ExamListTV

            cell.separatorview.isHidden = indexPath.row == subjectList.count - 1
            cell.subjectNameLbl.text = subjectList[indexPath.row].subject_name
            cell.Activities = subjectList[indexPath.row].activities ?? []
            cell.configureExpansionState(expandedRow == indexPath)

            // INNER EXPAND: toggle just the affected cells directly, then
            // ask the table view to re-measure (no reloadRows, no dequeue).
            cell.onExpand = { [weak self, weak tableView] in
                guard let self = self, let tableView = tableView else { return }

                let old = self.expandedRow
                self.expandedRow = (old == indexPath) ? nil : indexPath

                if let tapped = tableView.cellForRow(at: indexPath) as? Exam_ExamListTV {
                    tapped.configureExpansionState(self.expandedRow == indexPath)
                }
                if let old = old, old != indexPath,
                   let oldCell = tableView.cellForRow(at: old) as? Exam_ExamListTV {
                    oldCell.configureExpansionState(false)
                }

                tableView.performBatchUpdates(nil) { _ in
                    // Only after the batch update settles do we know the
                    // inner table's real contentSize.
                    self.updateInnerHeight()
                }
            }

            return cell
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
