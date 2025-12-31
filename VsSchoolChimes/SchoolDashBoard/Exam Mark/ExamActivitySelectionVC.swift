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
    
    var expandedIndex: IndexPath?
    var didInitialHeightSet = false

    var SubjectList : [SubjectExamData] = []
    var come_from_AI: Bool = false
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
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
//            self.updateMainHeight()
//        }
//    }


    
    private func updateMainHeight() {
           DispatchQueue.main.async {
               self.tableview.layoutIfNeeded()
               self.tableviewHeight.constant = self.tableview.contentSize.height
           }
       }
    
    @IBAction func continueAct(_ sender: Any) {
        let vc = MarkReviewVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension ExamActivitySelectionVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return SubjectList.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SubjectsTVCell",
            for: indexPath
        ) as! SubjectsTVCell

        let data = SubjectList[indexPath.row]
        
        cell.isExpanded = (expandedIndex == indexPath)
        cell.configureExpandState()
        cell.cellConfig(come_from_AI: come_from_AI, Subject_modal: data)
//        cell.subjectLbl.text = data.subject_name
        cell.onHeightChange = { [weak self] in
            guard let self = self else { return }
            self.tableview.beginUpdates()
            self.tableview.endUpdates()
            self.updateMainHeight()
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let previous = expandedIndex

        if previous == indexPath {
            expandedIndex = nil
        } else {
            expandedIndex = indexPath
        }

        var rows = [indexPath]
        if let previous = previous, previous != indexPath {
            rows.append(previous)
        }

        tableView.reloadRows(at: rows, with: .automatic)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.updateMainHeight()
        }
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateMainHeight()
        }
    }
}
