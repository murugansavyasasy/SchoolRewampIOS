//
//  ExamActivitySelectionVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 26/11/25.
//

import UIKit

class ExamActivitySelectionVC: UIViewController {

    @IBOutlet weak var topInfoView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var bottomInfoView: UIView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    
    var selectedRow: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topInfoView.layer.cornerRadius = 10
        topInfoView.backgroundColor = .staffExamColour.withAlphaComponent(0.1)
        topInfoView.layer.borderWidth = 0.3
        topInfoView.layer.borderColor = UIColor.staffExamColour.cgColor
        
        bottomInfoView.layer.cornerRadius = 10
        bottomInfoView.backgroundColor = .systemGray6.withAlphaComponent(0.7)
        bottomInfoView.layer.borderWidth = 0.3
        bottomInfoView.layer.borderColor = UIColor.lightGray.cgColor
        
        continueBtn.layer.cornerRadius = 10
        
        tableview.isScrollEnabled = false
        tableview.register(UINib(nibName: "SubjectsTVCell", bundle: nil),
                           forCellReuseIdentifier: "SubjectsTVCell")
        
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.updateTableHeight()
        }
    }
    
    func updateTableHeight() {
        DispatchQueue.main.async {
            self.tableview.layoutIfNeeded()
            self.tableviewHeight.constant = self.tableview.contentSize.height
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func continueAct(_ sender: Any) {}
    
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension ExamActivitySelectionVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "SubjectsTVCell",
                                                 for: indexPath) as! SubjectsTVCell
        
        cell.isExpand = (selectedRow == indexPath)
        cell.configureExpandState()
        
        // Notify parent VC when child height changes
        cell.onInnerHeightChanged = { [weak self] in
            self?.updateTableHeight()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let previous = selectedRow
        selectedRow = indexPath

        var rows = [indexPath]
        if let prev = previous, prev != indexPath {
            rows.append(prev)
        }

        tableview.reloadRows(at: rows, with: .automatic)

        // 🔥 FINAL FIX — second layout cycle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            self.tableview.beginUpdates()
            self.tableview.endUpdates()
            self.updateTableHeight()
        }
    }

    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
