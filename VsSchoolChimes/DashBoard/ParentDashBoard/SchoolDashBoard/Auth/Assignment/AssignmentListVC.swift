//
//  AssignmentListVC.swift
//  VsSchoolChimes
//
//  Created by admin on 21/11/24.
//

import UIKit

class AssignmentListVC: UIViewController {

    @IBOutlet weak var listTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        register()
        // Do any additional setup after loading the view.
    }
    func register(){
        listTable.register(UINib(nibName:"AssignmentListCTVC" , bundle: nil), forCellReuseIdentifier: "AssignmentListCTVC")
    }
}
extension AssignmentListVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: "AssignmentListCTVC", for: indexPath) as! AssignmentListCTVC
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
