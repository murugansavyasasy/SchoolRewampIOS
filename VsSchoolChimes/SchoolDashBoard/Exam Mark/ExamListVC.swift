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
    var expandedSections: Set<Int> = []
    var expandedSection: Int? = nil
    var expandedRows: Set<IndexPath> = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        continueBtn.layer.cornerRadius = 10
        
        tv.register(UINib(nibName: "ExamListHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "ExamListHeader")
        
        tv.register(UINib(nibName: "Exam_ExamListTV", bundle: nil), forCellReuseIdentifier: "Exam_ExamListTV")
        
        tv.delegate = self
        tv.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ExamListHeader") as! ExamListHeader
        header.baseView.layer.cornerRadius = 10
        header.baseView.layer.shadowColor = UIColor.black.cgColor
        header.baseView.layer.shadowOpacity = 0.15
        header.baseView.layer.shadowRadius = 4
        header.baseView.layer.shadowOffset = CGSize(width: 0, height: 2)
        header.SideColourView.layer.cornerRadius = 10
        header.SideColourView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]

        header.onTap = { [weak self] in
            guard let self = self else { return }

            if self.expandedSection == section {
                // collapse this section
                self.expandedSection = nil
                tableView.reloadSections([section], with: .automatic)
            } else {
                // expand new section, collapse old
                let previous = self.expandedSection
                self.expandedSection = section

                var toReload: [Int] = [section]
                if let previous {
                    toReload.append(previous)
                }

                tableView.reloadSections(IndexSet(toReload), with: .automatic)
            }
        }

        return header
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSection == section ? 3 : 0
    }
    
    func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(
                withIdentifier: "Exam_ExamListTV",
                for: indexPath
            ) as! Exam_ExamListTV

            cell.isExpanded = expandedRows.contains(indexPath)

            // Row button tap
            cell.onExpand = { [weak self] in
                guard let self = self else { return }

                if self.expandedRows.contains(indexPath) {
                    self.expandedRows.remove(indexPath)
                } else {
                    self.expandedRows.insert(indexPath)
                }

                tableView.reloadRows(at: [indexPath], with: .automatic)
            }

            return cell
        }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
