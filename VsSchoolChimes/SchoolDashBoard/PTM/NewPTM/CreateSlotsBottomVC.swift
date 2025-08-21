//
//  CreateSlotsBottomVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 20/08/25.
//

import UIKit

class CreateSlotsBottomVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var SlotData: [ValidatedSlotData]? // contains [Slot]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        
        tableView.register(UINib(nibName: "CreatedSlotsTv", bundle: nil), forCellReuseIdentifier: "CreatedSlotsTv")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SlotData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreatedSlotsTv", for: indexPath) as! CreatedSlotsTv
        cell.slots = SlotData?[indexPath.row].slots ?? []
        return cell
    }
}
