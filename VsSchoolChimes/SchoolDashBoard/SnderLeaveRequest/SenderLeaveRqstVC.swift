//
//  SenderLeaveRqstVC.swift
//  VsSchoolChimes
//
//  Created by admin on 24/12/24.
//

import UIKit

class SenderLeaveRqstVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var leaveRequestTable: UITableView!
    var leaveResuest = [LeaveRequest(fromDate: "12 Sep 24", toDate: "13 Sep 24", status: "Pending", reson: "I hope this message finds you well. I am feeling unwell and will not be able to attend work on [mention date(s)]. I will keep you updated on my condition and inform you of my return to work.", isExpanded: false),LeaveRequest(fromDate: "11 Oct 24", toDate: "12 Oct 24", status: "Aproved", reson: "I hope this message finds you well. I am feeling unwell and will not be able to attend work on [mention date(s)]. I will keep you updated on my condition and inform you of my return to work.", isExpanded: false),LeaveRequest(fromDate: "08 Nov 24", toDate: "10 Nov 24", status: "Pending", reson: "I hope this message finds you well. I am feeling unwell and will not be able to attend work on [mention date(s)]. I will keep you updated on my condition and inform you of my return to work.", isExpanded: false),LeaveRequest(fromDate: "12 Dec 24", toDate: "13 Dec 24", status: "Rejected", reson: "I hope this message finds you well. I am feeling unwell and will not be able to attend work on [mention date(s)]. I will keep you updated on my condition and inform you of my return to work.", isExpanded: false)]
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.setFont(style: .header, size: FontSize.HeaderSize)
        leaveRequestTable.register(UINib(nibName: "SenderLeaveTV", bundle: nil), forCellReuseIdentifier: "SenderLeaveTV")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaveResuest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaveRequestTable.dequeueReusableCell(withIdentifier: "SenderLeaveTV", for: indexPath) as! SenderLeaveTV
        cell.fromDate.text = leaveResuest[indexPath.row].fromDate
        cell.toDate.text = leaveResuest[indexPath.row].toDate
        cell.resonLbl.text = leaveResuest[indexPath.row].reson
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
