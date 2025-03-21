//
//  SenderLeaveRqstVC.swift
//  VsSchoolChimes
//
//  Created by admin on 24/12/24.
//

import UIKit
protocol ConfirmDelegate{
    func confirm(index:Int,status:String,AlertMsg: String)
}
class SenderLeaveRqstVC: UIViewController, ConfirmDelegate {
    func confirm(index: Int, status: String, AlertMsg: String) {
        print(index)
        let alert = CustomAlert()
        alert.showAlertCancel(title: "",
                              message: AlertstringFile.ConfirmLeave + AlertMsg + AlertstringFile.LeaveRequest ,
                              actionLbl1: AlertstringFile.Confirm,
                              actionLbl2: AlertstringFile.Cancel,
                              on: self) { [self] in
            filterStudent?[index].status = status
            filterStudent?[index].isExpanded = true
            leaveRequestTable.reloadData()
        } onNo: {
            print("User canceled the action")
        }
        
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var leaveRequestTable: UITableView!
    var leaveResuest = [LeaveRequest(fromDate: "12 Sep 24", toDate: "13 Sep 24", status: "Pending", reson: "I hope this message finds you well. I am feeling unwell and will not be able to attend work on [mention date(s)]. I will keep you updated on my condition and inform you of my return to work.", isExpanded: false),LeaveRequest(fromDate: "11 Oct 24", toDate: "12 Oct 24", status: "Aproved", reson: "I hope this message finds you well. I am feeling unwell and will not be able to attend work on [mention date(s)]. I will keep you updated on my condition and inform you of my return to work.", isExpanded: false),LeaveRequest(fromDate: "08 Nov 24", toDate: "10 Nov 24", status: "Pending", reson: "I hope this message finds you well. I am feeling unwell and will not be able to attend work on [mention date(s)]. I will keep you updated on my condition and inform you of my return to work.", isExpanded: false),LeaveRequest(fromDate: "12 Dec 24", toDate: "13 Dec 24", status: "Rejected", reson: "I hope this message finds you well. I am feeling unwell and will not be able to attend work on [mention date(s)]. I will keep you updated on my condition and inform you of my return to work.", isExpanded: false)]
    var filterStudent: [LeaveRequest]?
    override func viewDidLoad() {
        super.viewDidLoad()
        BackBtn.applyBackButton()
        filterStudent = leaveResuest
        BackBtn.setTitle(MenuStringFile.LeaveRequests.translated(), for: .normal)
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.applyRightTxt()
        leaveRequestTable.register(UINib(nibName: CellConfingName.SenderLeaveTV, bundle: nil), forCellReuseIdentifier: CellConfingName.SenderLeaveTV)
        if #available(iOS 14.0, *) {
            searchBar.addDoneButton()
            searchBar.delegate = self
        }
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }

    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension SenderLeaveRqstVC : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterStudent?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaveRequestTable.dequeueReusableCell(withIdentifier: CellConfingName.SenderLeaveTV, for: indexPath) as! SenderLeaveTV
        cell.fromDate.text = filterStudent?[indexPath.row].fromDate
        cell.toDate.text = filterStudent?[indexPath.row].toDate
        cell.resonLbl.text = filterStudent?[indexPath.row].reson
        cell.delegate = self
        cell.aproveBtn.tag = indexPath.row
        cell.rejectBtn.tag = indexPath.row
        cell.statusLbl.isHidden = !filterStudent![indexPath.row].isExpanded
        cell.statusLbl.text = filterStudent?[indexPath.row].status
        cell.statusLbl.textColor = filterStudent?[indexPath.row].status == "Approved" ? .aproved : .red
        if filterStudent![indexPath.row].isExpanded{
            cell.aproved.isHidden = true
            cell.reject.isHidden = true
            cell.height.constant = 0
        }else{
            cell.aproved.isHidden = false
            cell.reject.isHidden = false
            cell.height.constant = 40
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

@available(iOS 14.0, *)
extension SenderLeaveRqstVC: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // Reset to full data when the search text is cleared
            filterStudent = leaveResuest
        } else {
            // Filter data based on the search text
            filterStudent = leaveResuest.filter { student in
                student.fromDate!.lowercased().contains(searchText.lowercased())
            }
        }
        leaveRequestTable.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
