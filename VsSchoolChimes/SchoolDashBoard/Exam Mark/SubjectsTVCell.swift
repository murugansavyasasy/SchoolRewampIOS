//
//  SubjectsTVCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 26/11/25.
//
struct activity {
    var name: String
    var value: Int
}



import UIKit

class SubjectsTVCell: UITableViewCell, checkExamlists {

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
    var activitiesCount = 2
    
    let samples: [activity] = [
        activity(name: "Alpha", value: 0),
        activity(name: "Beta", value: 0),
        activity(name: "Gamma", value: 0),
        activity(name: "Delta", value: 0)
    ]
    var  splitup_details_data: [SplitDetail]?
    var come_from_AI : Bool = false
    var selectedSplitupIDs: [String] = []

    func checkExamlist(isChecked: Bool, index: Int,come_from_AI : Bool) {
        guard let id = splitup_details_data?[index].id else { return }
        splitup_details_data?[index].isChecked = isChecked
        if isChecked {
            // ADD ID
            if !selectedSplitupIDs.contains(id) {
                selectedSplitupIDs.append(id)
            }
        } else {
            // REMOVE ID
            selectedSplitupIDs.removeAll { $0 == id }
        }
        print("Selected IDs: \(selectedSplitupIDs)")
        let total = splitup_details_data?.count ?? 0
        let selected = selectedSplitupIDs.count
        let remaining = total - selected
        statusLbl.text = "\(remaining) of \(total) activities mapped"

    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        baseView.layer.cornerRadius = 10
        baseView.layer.shadowColor = UIColor.black.cgColor
        baseView.layer.shadowOpacity = 0.15
        baseView.layer.shadowRadius = 4
        baseView.layer.shadowOffset = CGSize(width: 0, height: 2)

        subjectView.layer.cornerRadius = 10
        subjectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        subjectView.layer.borderWidth = 0.2
        subjectView.layer.borderColor = UIColor.clear.cgColor
        
        expandIconBtn.isUserInteractionEnabled = false
        
        tableview.isScrollEnabled = false
        tableview.isHidden = true
        tableviewHeight.constant = 0
        
        tableview.register(UINib(nibName: "ActivitiesTVCell", bundle: nil),
                           forCellReuseIdentifier: "ActivitiesTVCell")
        
        tableview.delegate = self
        tableview.dataSource = self
        
        tableview.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    deinit {
        tableview.removeObserver(self, forKeyPath: "contentSize")
        }
    
//    func updateInnerHeight() {
//        DispatchQueue.main.async {
//            self.tableview.layoutIfNeeded()
//            self.tableviewHeight.constant = self.tableview.contentSize.height
//        }
//    }
    
    override func observeValue(forKeyPath keyPath: String?,
                                  of object: Any?,
                                  change: [NSKeyValueChangeKey : Any]?,
                                  context: UnsafeMutableRawPointer?) {

           if keyPath == "contentSize" && isExpanded {
               tableviewHeight.constant = tableview.contentSize.height
               onHeightChange?()
           }
       }

    func notifyParentToUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if let parentTable = self.superview(of: UITableView.self) {
                parentTable.beginUpdates()
                parentTable.endUpdates()
            }
        }
    }
    
    func cellConfig(come_from_AI : Bool,Subject_modal : SubjectExamData){
        subjectLbl.text = Subject_modal.subject_name
        self.come_from_AI = come_from_AI
        splitup_details_data = Subject_modal.splitup_details
        tableview.reloadData()
    }
    
    
//    func configureExpandState() {
//
//        if isExpand {
//            
//            tableview.isHidden = false
//            tableview.reloadData()
//
//            updateInnerHeight()
//            notifyParentToUpdate()
//
//        } else {
//            
//            tableview.isHidden = true
//            tableviewHeight.constant = 0
//            notifyParentToUpdate()
//        }
//    }
    
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
        return splitup_details_data?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivitiesTVCell", for: indexPath) as! ActivitiesTVCell
        if let data = splitup_details_data?[indexPath.row]{
            cell.cellConfig(come_from_AI: come_from_AI, actitvityDetails: data)
        }
        let isChecked = splitup_details_data?[indexPath.row].isChecked ?? false

        cell.CheckBoxBtnName.isSelected = isChecked
        cell.updateCheckboxUI(isChecked: isChecked)
        cell.CheckBoxBtnName.tag = indexPath.row
        cell.delegate = self
        return cell
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
