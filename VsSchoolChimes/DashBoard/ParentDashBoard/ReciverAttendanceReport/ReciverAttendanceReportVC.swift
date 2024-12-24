//
//  ReciverAttendanceReportVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 19/12/24.
//

import UIKit

class ReciverAttendanceReportVC: UIViewController {

    @IBOutlet weak var TV: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var HeaderLbl: UILabel!
    let date = 11
    let day = ["Monday","Tuesday","Wednesday","Thursday","Friday"]
    let present = [true,true,false,true,false]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: CellConfingName.ReciverAttendReportTV, bundle: nil)
        TV.register(nib, forCellReuseIdentifier: CellConfingName.ReciverAttendReportTV)
        
        TV.delegate = self
        TV.dataSource = self
    }


    @IBAction func BackBtnAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
}

extension ReciverAttendanceReportVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TV.dequeueReusableCell(withIdentifier: CellConfingName.ReciverAttendReportTV, for: indexPath) as! ReciverAttendReportTV
        
        cell.DateLbl.text = String (date + indexPath.row)
        cell.dayLbl.text = day[indexPath.row]
        
        cell.statusLbl.textColor = .white
        if present[indexPath.row] == true {
            
            cell.Cellview.layer.borderWidth = 1
            cell.Cellview.layer.borderColor = UIColor.green.cgColor
            cell.statusLbl.text = "Present"
            cell.StatusView.backgroundColor = .systemGreen
        }else{
            cell.Cellview.layer.borderWidth = 1
            cell.Cellview.layer.borderColor = UIColor.red.cgColor
            cell.statusLbl.text = "Absent"
            cell.StatusView.backgroundColor = .systemRed
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
}
