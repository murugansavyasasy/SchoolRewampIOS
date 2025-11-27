//
//  ExamListVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 24/11/25.
//

import UIKit

class ExamListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var bottomSlectInfoLbl: UILabel!
    
    
    var expandedRow: IndexPath? = nil
    var selectedRow: IndexPath? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        continueBtn.layer.cornerRadius = 10

        tv.register(UINib(nibName: "ExamListHeader", bundle: nil),
                    forHeaderFooterViewReuseIdentifier: "ExamListHeader")
        tv.register(UINib(nibName: "ExamListCell", bundle: nil),
                    forCellReuseIdentifier: "ExamListCell")

        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
    }
    
    
    @IBAction func continueAct(_ sender: Any) {
        
        let vc = ExamImgUploadVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 5 }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ExamListCell",
            for: indexPath
        ) as! ExamListCell

        let isSelected = (selectedRow == indexPath)
        cell.sideColourView.backgroundColor = isSelected ? .staffExamColour : .clear
        cell.selectioView.backgroundColor = isSelected ? .staffExamColour.withAlphaComponent(0.05) : .clear
        cell.checkCircleBtn.setImage(
            UIImage(systemName: isSelected ? "inset.filled.circle" : "circle"),
            for: .normal
        )
        
        cell.examNameLbl.textColor = isSelected ? .staffExamColour : .black

        cell.configureExpansionState(expandedRow == indexPath)

        // OUTER expand
        cell.onExpand = { [weak self] in
            guard let self = self else { return }

            let old = self.expandedRow
            self.expandedRow = (old == indexPath) ? nil : indexPath

            var reload: [IndexPath] = [indexPath]
            if let old = old, old != indexPath { reload.append(old) }

            self.tv.beginUpdates()
            self.tv.reloadRows(at: reload, with: .automatic)
            self.tv.endUpdates()
        }

        // INNER height change → refresh outer row
        cell.onInnerHeightChanged = { [weak self] in
            guard let self = self else { return }
            self.tv.beginUpdates()
            self.tv.endUpdates()
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let previousSelected = selectedRow        // save old selection
        selectedRow = indexPath                   // update to new selection

        continueBtn.isUserInteractionEnabled = true
        continueBtn.backgroundColor = .staffExamColour
        bottomSlectInfoLbl.isHidden = true

        // Build the list of rows to reload
        var rowsToReload: [IndexPath] = [indexPath]

        if let previous = previousSelected, previous != indexPath {
            rowsToReload.append(previous)
        }

        tableView.reloadRows(at: rowsToReload, with: .automatic)
    }


    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

