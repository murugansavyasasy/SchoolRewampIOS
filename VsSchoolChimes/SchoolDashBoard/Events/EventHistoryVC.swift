//
//  EventHistoryVC.swift
//  VsSchoolChimes
//
//  Created by admin on 04/12/24.
//

import UIKit

@available(iOS 14.0, *)
class EventHistoryVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
    @IBOutlet weak var historyTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTable.register(UINib(nibName: CellConfingName.NoticeBoardTvcellTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell)
        
        historyTable.delegate = self
        historyTable.dataSource = self
        historyTable.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell, for: indexPath) as! NoticeBoardTvcellTableViewCell
        cell.issenderEvent = true
        print("Hello world")
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
