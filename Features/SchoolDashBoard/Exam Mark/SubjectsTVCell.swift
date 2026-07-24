//
//  SubjectsTVCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 26/11/25.
//

protocol SubjectCellDelegate: AnyObject {
    func didUpdateSplit(subjectIndex: Int, splitIndex: Int, split: ActivityData)
}

import UIKit

class SubjectsTVCell: UITableViewCell {
   
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var subjectView: UIView!
    @IBOutlet weak var checkCircleBtn: UIButton!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var expandIconBtn: UIButton!
    @IBOutlet weak var tableview: ContentSizedTableView!
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    
    var isExpanded = false
    var onHeightChange: (() -> Void)?
    var subjectIndex:Int = 0
    var splits: [ActivityData] = []
    var isAI : Bool = false
    weak var delegate: SubjectCellDelegate?
    var selectionHandler: ((Int, Bool) -> Void)?
    var DropdownData : [String]?
    var expandedRubricRows: Set<Int> = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        baseView.layer.cornerRadius = 10
        baseView.layer.shadowColor = UIColor.black.cgColor
        baseView.layer.shadowOpacity = 0.15
        baseView.layer.shadowRadius = 4
        baseView.layer.shadowOffset = CGSize(width: 0, height: 2)
        baseView.layer.borderWidth = 1.5
        baseView.layer.borderColor = UIColor.lightGray.cgColor

        subjectView.layer.cornerRadius = 10
        subjectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        subjectView.layer.borderWidth = 0.2
        subjectView.layer.borderColor = UIColor.clear.cgColor
        
        expandIconBtn.isUserInteractionEnabled = false
        
        tableview.isScrollEnabled = false
        tableview.isHidden = true
        tableviewHeight.constant = 0
        
        tableview.register(UINib(nibName: CellConfingName.ActivitiesTVCell, bundle: nil),forCellReuseIdentifier: CellConfingName.ActivitiesTVCell)
        
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    deinit {
        tableview.removeObserver(self, forKeyPath: "contentSize")
        }
    
    override func observeValue(forKeyPath keyPath: String?,
                                  of object: Any?,
                                  change: [NSKeyValueChangeKey : Any]?,
                                  context: UnsafeMutableRawPointer?) {

           if keyPath == "contentSize" && isExpanded {
               tableviewHeight.constant = tableview.contentSize.height
               onHeightChange?()
           }
       }
    func config(dropDown:[String]?){
        DropdownData = dropDown
        print(DropdownData)
    }
    func notifyParentToUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if let parentTable = self.superview(of: UITableView.self) {
                parentTable.beginUpdates()
                parentTable.endUpdates()
            }
        }
    }
    
    func updateStatusLabel() {
        let selected = splits.filter { $0.isChecked == true }.count
        
        if isAI{
            if selected == 0{
                statusLbl.text = ExamMarkUploadString.Not_started.translated()
                statusLbl.textColor = .darkGray
                subjectView.backgroundColor = .systemBackground
                baseView.layer.borderColor = UIColor.lightGray.cgColor
            }else if selected < splits.count {
                statusLbl.text = String(format: ExamMarkUploadString.Activities_mapped_count.translated(),selected,splits.count)
                statusLbl.textColor = .systemBrown
                subjectView.backgroundColor = .systemYellow.withAlphaComponent(0.05)
                baseView.layer.borderColor = UIColor.systemOrange.cgColor
            }else{
                statusLbl.text = String(format: ExamMarkUploadString.All_activities_mapped.translated(),splits.count)
                statusLbl.textColor = .systemGreen
                subjectView.backgroundColor = .systemGreen.withAlphaComponent(0.05)
                baseView.layer.borderColor = UIColor.systemGreen.cgColor
            }
        }else{
            //statusLbl.text = String(format: ExamMarkUploadString.Activities_selected_count.translated(),selected,splits.count)
        }
        
       // statusLbl.isHidden = !(selected > 0)
    }
    
    func configureExpandState() {
        
            if isExpanded {
                expandIconBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)

                tableview.isHidden = false
                tableview.reloadData()

                DispatchQueue.main.async {
                    self.tableviewHeight.constant = self.tableview.contentSize.height
                    self.onHeightChange?()
                }

            } else {
                expandIconBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)

                tableview.isHidden = true
                tableviewHeight.constant = 0

                onHeightChange?()
            }
        }
}

extension SubjectsTVCell: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return splits.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ActivitiesTVCell, for: indexPath) as! ActivitiesTVCell
        
        cell.configure(subjectIndex: subjectIndex, splitIndex: indexPath.row, split: splits[indexPath.row], isAi: isAI, items: DropdownData ?? [],isRubricsExpanded: expandedRubricRows.contains(indexPath.row))
        cell.delegate = self
        
        cell.onHeightChanged = { [weak self] in
            guard let self = self else { return }

            self.tableview.beginUpdates()
            self.tableview.endUpdates()

            DispatchQueue.main.async {
                self.tableviewHeight.constant = self.tableview.contentSize.height
                self.onHeightChange?()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAI{
            
        }else{
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension SubjectsTVCell: ActivityCellDelegate {

    func didUpdateAISplit(
        subjectIndex: Int,
        splitIndex: Int,
        isChecked: Bool,
        aiOption: String?
    ) {
        splits[splitIndex].isChecked = isChecked
        splits[splitIndex].selectedAIOption = aiOption

        updateStatusLabel()

        delegate?.didUpdateSplit(
            subjectIndex: subjectIndex,
            splitIndex: splitIndex,
            split: splits[splitIndex]
        )

        tableview.beginUpdates()
        tableview.reloadRows(at: [IndexPath(row: splitIndex, section: 0)], with: .automatic)
        tableview.endUpdates()

        
        DispatchQueue.main.async {
            self.tableview.layoutIfNeeded()
            self.tableviewHeight.constant = self.tableview.contentSize.height
            self.onHeightChange?()
        }

    }

    func didToggleSplit(
        subjectIndex: Int,
        splitIndex: Int,
        isChecked: Bool
    ) {
        splits[splitIndex].isChecked = isChecked
        splits[splitIndex].selectedAIOption = nil

        updateStatusLabel()

        delegate?.didUpdateSplit(
            subjectIndex: subjectIndex,
            splitIndex: splitIndex,
            split: splits[splitIndex]
        )

        tableview.reloadRows(at: [IndexPath(row: splitIndex, section: 0)], with: .none)
    }
    
    func didToggleActivityWithRubrics(
        subjectIndex: Int,
        splitIndex: Int,
        rubrics: [RubricData],
        isChecked: Bool
    ) {

        splits[splitIndex].isChecked = isChecked
        splits[splitIndex].rubrics = rubrics

        delegate?.didUpdateSplit(
            subjectIndex: subjectIndex,
            splitIndex: splitIndex,
            split: splits[splitIndex]
        )

        tableview.reloadRows(at: [IndexPath(row: splitIndex, section: 0)], with: .none)
    }
    
    func didToggleRubric(subjectIndex: Int, splitIndex: Int, rubricIndex: Int, isChecked: Bool) {
        
        splits[splitIndex].rubrics?[rubricIndex].isChecked = isChecked
        
        let hasSelectedRubric = splits[splitIndex].rubrics?.contains { $0.isChecked == true } ?? false
        
        splits[splitIndex].isChecked = hasSelectedRubric
        
        delegate?.didUpdateSplit(subjectIndex: subjectIndex, splitIndex: splitIndex, split: splits[splitIndex])
    }
    
    // SubjectsTVCell
    func didToggleRubricsExpansion(splitIndex: Int, expanded: Bool) {
        if expanded { expandedRubricRows.insert(splitIndex) }
        else { expandedRubricRows.remove(splitIndex) }
    }
    
    func didUpdateAIRubric(
        subjectIndex: Int,
        splitIndex: Int,
        rubricIndex: Int,
        isChecked: Bool,
        aiOption: String?
    ) {
        guard splitIndex < splits.count,
              var rubrics = splits[splitIndex].rubrics,
              rubricIndex < rubrics.count else { return }

        rubrics[rubricIndex].isChecked = isChecked
        rubrics[rubricIndex].selectedAIOption = aiOption
        splits[splitIndex].rubrics = rubrics

        // An activity with rubrics only counts as "mapped" once every rubric is mapped
        let allMapped = rubrics.allSatisfy { $0.selectedAIOption != nil }
        splits[splitIndex].isChecked = allMapped

        updateStatusLabel()

        delegate?.didUpdateSplit(
            subjectIndex: subjectIndex,
            splitIndex: splitIndex,
            split: splits[splitIndex]
        )

        tableview.reloadRows(at: [IndexPath(row: splitIndex, section: 0)], with: .none)

        DispatchQueue.main.async {
            self.tableview.layoutIfNeeded()
            self.tableviewHeight.constant = self.tableview.contentSize.height
            self.onHeightChange?()
        }
    }
}



class ContentSizedTableView: UITableView {
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
