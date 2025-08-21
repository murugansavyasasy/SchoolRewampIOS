//
//  CreateSlotsBottomVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 20/08/25.
//

import UIKit

class CreateSlotsBottomVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var slots : [Slot]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "CreatedSlotsTv", bundle: nil), forCellReuseIdentifier: "CreatedSlotsTv")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        slots?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreatedSlotsTv", for: indexPath) as! CreatedSlotsTv
               
               return cell
    }
    

}
