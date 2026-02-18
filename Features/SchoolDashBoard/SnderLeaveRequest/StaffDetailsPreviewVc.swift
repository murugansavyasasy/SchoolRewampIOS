//
//  StaffDetailsPreviewVc.swift
//  School Chimes
//
//  Created by apple on 16/02/26.
//

import UIKit

class StaffDetailsPreviewVc: UIViewController {

    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var RollLabel: UILabel!
    @IBOutlet weak var staffNameLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tv.register(UINib(nibName: "staffContactTvCell", bundle: nil), forCellReuseIdentifier: "staffContactTvCell")
        tv.dataSource = self
        tv.delegate = self
        
        profileContainerView.layer.cornerRadius = 24 // 48x48
        profileContainerView.clipsToBounds = true
        
        
        
    }

    @IBAction func BackBtnAct(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension StaffDetailsPreviewVc : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "staffContactTvCell", for: indexPath) as? staffContactTvCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        return cell
    }
    
    
}
