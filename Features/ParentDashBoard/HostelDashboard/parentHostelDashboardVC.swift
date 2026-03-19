//
//  parentHostelDashboardVC.swift
//  School Chimes
//
//  Created by apple on 11/03/26.
//

import UIKit

class parentHostelDashboardVC: UIViewController {
   
    

    @IBOutlet weak var hostelInformationTv: UITableView!
    @IBOutlet weak var monthlyStaticTv: UITableView!
    @IBOutlet weak var studentDataFullView: UIView!
    
    @IBOutlet weak var hostelInformationFullview: UIView!
    @IBOutlet weak var monthlyStatisFullView: UIView!
    @IBOutlet weak var outpassTv: UITableView!
    @IBOutlet weak var outpassFullview: UIView!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var monthStatusFullView: UIView!
    @IBOutlet weak var attendaceStatusFullView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentDataFullView.layer.cornerRadius = 10
        monthStatusFullView.layer.cornerRadius = 10
        attendaceStatusFullView.layer.cornerRadius = 10
        profileContainerView.layer.cornerRadius = 24 // 48x48
        profileContainerView.clipsToBounds = true
        studentDataFullView.layer.cornerRadius = 15
        hostelInformationFullview.layer.cornerRadius = 15
        monthlyStatisFullView.layer.cornerRadius = 15
        outpassFullview.layer.cornerRadius = 15
        outpassTv.register(outpasssRequestTvcell.self)
        monthlyStaticTv.register(dailyAttendaceDateTvCell.self)
        hostelInformationTv.register(HostelInformationTvcell.self)
        outpassTv.delegate = self
        outpassTv.dataSource = self
        monthlyStaticTv.dataSource = self
        monthlyStaticTv.delegate = self
        hostelInformationTv.dataSource = self
        hostelInformationTv.delegate = self
        
        
       
    }

    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
  
    @IBAction func NewRequestBtnAct(_ sender: UIButton) {
    }
}

extension parentHostelDashboardVC : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView{
        case outpassTv:
            return 3
        case monthlyStaticTv:
            return 30
        case hostelInformationTv:
            return 5
        default:
            return 0
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
        switch tableView{
        case outpassTv:
            guard let cell = outpassTv.dequeueReusableCell(withIdentifier: "outpasssRequestTvcell", for: indexPath) as? outpasssRequestTvcell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell
            
        case monthlyStaticTv:
            guard let cell = monthlyStaticTv.dequeueReusableCell(withIdentifier: "dailyAttendaceDateTvCell", for: indexPath) as? dailyAttendaceDateTvCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell
            
        case hostelInformationTv:
            guard let cell = hostelInformationTv.dequeueReusableCell(withIdentifier: "HostelInformationTvcell", for: indexPath) as? HostelInformationTvcell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
}
