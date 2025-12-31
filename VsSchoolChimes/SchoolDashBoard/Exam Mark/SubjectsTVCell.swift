//
//  SubjectsTVCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 26/11/25.
//

protocol SubjectCellDelegate: AnyObject {
    func didUpdateSplit(subjectIndex: Int, splitIndex: Int, split: SplitDetail)
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
    var splits: [SplitDetail] = []
    var isAI : Bool = false
    weak var delegate: SubjectCellDelegate?
    var selectionHandler: ((Int, Bool) -> Void)?
    
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
        
        tableview.register(UINib(nibName: "ActivitiesTVCell", bundle: nil),forCellReuseIdentifier: "ActivitiesTVCell")
        
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
                statusLbl.text = "Not started"
                statusLbl.textColor = .darkGray
                subjectView.backgroundColor = .systemBackground
                baseView.layer.borderColor = UIColor.lightGray.cgColor
            }else if selected < splits.count {
                statusLbl.text = "\(selected) of \(splits.count) activities mapped"
                statusLbl.textColor = .systemBrown
                subjectView.backgroundColor = .systemYellow.withAlphaComponent(0.05)
                baseView.layer.borderColor = UIColor.systemOrange.cgColor
            }else{
                statusLbl.text = "All \(splits.count) activities mapped"
                statusLbl.textColor = .systemGreen
                subjectView.backgroundColor = .systemGreen.withAlphaComponent(0.05)
                baseView.layer.borderColor = UIColor.systemGreen.cgColor
            }
        }else{
            statusLbl.text = "\(selected) of \(splits.count) activities selected"
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivitiesTVCell", for: indexPath) as! ActivitiesTVCell
        
        cell.configure(subjectIndex: subjectIndex, splitIndex: indexPath.row, split: splits[indexPath.row], isAi: isAI)
        cell.delegate = self
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAI{
            
        }else{
            
        }
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

        tableview.reloadRows(
            at: [IndexPath(row: splitIndex, section: 0)],
            with: .none
        )
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

        tableview.reloadRows(
            at: [IndexPath(row: splitIndex, section: 0)],
            with: .none
        )
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
