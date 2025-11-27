//
//  SubjectsTVCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 26/11/25.
//

import UIKit

class SubjectsTVCell: UITableViewCell {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var subjectView: UIView!
    @IBOutlet weak var checkCircleBtn: UIButton!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var expandIconBtn: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    
    var isExpand = false
    var onInnerHeightChanged: (() -> Void)?
    
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
    }
    
    func updateInnerHeight() {
        DispatchQueue.main.async {
            self.tableview.layoutIfNeeded()
            self.tableviewHeight.constant = self.tableview.contentSize.height
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
    
    func configureExpandState() {

        if isExpand {
            
            tableview.isHidden = false
            tableview.reloadData()

            updateInnerHeight()
            notifyParentToUpdate()

        } else {
            
            tableview.isHidden = true
            tableviewHeight.constant = 0
            notifyParentToUpdate()
        }
    }

}

extension SubjectsTVCell: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivitiesTVCell",
                                                 for: indexPath) as! ActivitiesTVCell
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        // Handle inner selection if needed
    }
}
