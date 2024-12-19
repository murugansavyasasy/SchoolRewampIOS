//
//  LeveHistoryVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit

class LeveHistoryVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
//    LeveHistoryTV
    @IBOutlet weak var historyTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        historyTable.register(UINib(nibName: "LeveHistoryTV", bundle: nil), forCellReuseIdentifier: "LeveHistoryTV")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTable.dequeueReusableCell(withIdentifier: "LeveHistoryTV", for: indexPath) as! LeveHistoryTV
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
