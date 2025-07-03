//
//  LsrwListShowTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by Chandhru on 30/06/25.
//

import UIKit

class TestTVC: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var outerView: UIView!
    var selectedIndex: IndexPath?
    var test: TestQuestion? {
        didSet {
            questionLbl.text = test?.question
            tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tableHeight.constant = self.tableView.contentSize.height
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.register(UINib(nibName: "LSRWTvCell", bundle: nil), forCellReuseIdentifier: "LSRWTvCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
    }
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return test?.options.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LSRWTvCell", for: indexPath) as? LSRWTvCell else {
            return UITableViewCell()
        }
        cell.optionLbl.text = test?.options[indexPath.row]
        if selectedIndex == indexPath {
            cell.selectIcon.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        } else {
            cell.selectIcon.setImage(UIImage(systemName: "circle"), for: .normal)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
