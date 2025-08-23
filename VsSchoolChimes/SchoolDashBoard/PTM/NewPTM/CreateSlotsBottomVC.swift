//
//  CreateSlotsBottomVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 20/08/25.
//

import UIKit

class CreateSlotsBottomVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var slotData: [ValidatedSlotData] = [] // contains [Slot]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        tableView.register(UINib(nibName: "CreatedSlotsTv", bundle: nil), forCellReuseIdentifier: "CreatedSlotsTv")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slotData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreatedSlotsTv", for: indexPath) as? CreatedSlotsTv else {
            return UITableViewCell()
        }
        cell.dateBtn.setTitle(slotData[indexPath.row].date?.convertToTargetDateFormat(), for: .normal)
        cell.configure(with: slotData[indexPath.row].slots ?? [], parentTableView: tableView)
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
