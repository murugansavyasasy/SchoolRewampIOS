//
//  SlotListVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 12/08/25.
//

import UIKit

class SlotListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tv.register(UINib(nibName: "MeetingDetailTV", bundle: nil), forCellReuseIdentifier: "MeetingDetailTV")
        tv.delegate = self
        tv.dataSource = self
    }

    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "MeetingDetailTV", for: indexPath) as! MeetingDetailTV
        
        return cell
    }
    
}
