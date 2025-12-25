//
//  MarkReviewCVC.swift
//  School Chimes
//
//  Created by Chandhru on 25/12/25.
//

import UIKit

class MarkReviewCVC: UICollectionViewCell {

    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var listTable: UITableView!

    private var subjectIndex = 0
    private var headerTitle = ""
    private var maxMarks = 100
    weak var parentVC: MarkReviewVC?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTable()
    }
    
    private func setupTable() {
        listTable.register(UINib(nibName: "MarkReviewTVC", bundle: nil),
                          forCellReuseIdentifier: "MarkReviewTVC")
        listTable.dataSource = self
        listTable.delegate = self
        listTable.separatorStyle = .singleLine
        
        // Subject tables CAN scroll
        listTable.isScrollEnabled = true
        listTable.showsVerticalScrollIndicator = true
        listTable.bounces = true
    }
    
    func configure(subjectIndex: Int, headerTitle: String, maxMarks: Int, parentVC: MarkReviewVC) {
        self.subjectIndex = subjectIndex
        self.headerTitle = headerTitle
        self.maxMarks = maxMarks
        self.parentVC = parentVC
        
        headerLbl.text = "\(headerTitle)\nMax: \(maxMarks)"
        headerLbl.numberOfLines = 0
        headerLbl.textAlignment = .center
        headerLbl.font = UIFont.boldSystemFont(ofSize: 14)
        
        listTable.reloadData()
    }
}

// MARK: - TableView DataSource & Delegate

extension MarkReviewCVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parentVC?.students.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarkReviewTVC",
                                                 for: indexPath) as! MarkReviewTVC
        
        let markValue = parentVC?.getMark(row: indexPath.row, column: subjectIndex) ?? ""
        
        cell.configure(mark: markValue,
                      rowIndex: indexPath.row,
                      columnIndex: subjectIndex,
                      parentVC: parentVC)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // Sync scroll between subject columns only
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        parentVC?.syncVerticalScroll(from: scrollView, offset: scrollView.contentOffset)
    }
}
