//
//  LeveHistoryVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit
import DropDown

class LeveHistoryVC: UIViewController{

    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var monthWish: UIView!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var toLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var historyTable: UITableView!
    
    var EditDropdown = DropDown()
    var LeaveHistoryData: [LeaveInfo]?
    var childDetails = UserDefaultFileManager.get_child_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fromLbl.setFont(style:.body, size: FontSize.BodySize)
        toLbl.setFont(style:.body, size: FontSize.BodySize)
        statusLbl.setFont(style:.body, size: FontSize.BodySize)
        headerTitle.setFont(style:.body, size: FontSize.BodySize)
        
        historyTable.register(UINib(nibName: CellConfingName.LeveHistoryTV, bundle: nil), forCellReuseIdentifier: CellConfingName.LeveHistoryTV)
        
        historyTable.delegate = self
        historyTable.dataSource = self
        
        GetLeaveReqHistory()
    }
    
    
    //MARK: Leave Request History Api call
    
    func GetLeaveReqHistory() {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_list, parameters: [LeaveRequestStringFile.member_type:"STUDENT"], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") {[self] (result:Result<LeaveInfoResponse,Error>) in
            
            switch result{
                
            case .success(let success):
                DispatchQueue.main.async {[self] in
                    
                    LeaveHistoryData = success.data
                    
                    historyTable.reloadData()
                }
               
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print("Error: ",error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func monthWishFilter(_ sender: UIButton) {

        let dateFormatter = DateFormatter()
           dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Change locale if needed
        let monthNames = dateFormatter.monthSymbols ?? [] // This returns ["January", "February", ..., "December"]

           // Add "All" as the first option
//           monthNames.insert("All", at: 0)
           
           EditDropdown.dataSource = monthNames // Use updated list with "All"
           
           EditDropdown.anchorView = monthWish
           EditDropdown.bottomOffset = CGPoint(x: 0, y: monthWish.bounds.height)
           EditDropdown.direction = .bottom
           EditDropdown.width = monthWish.bounds.width
           EditDropdown.show()
           
           EditDropdown.selectionAction = { [self] (index: Int, item: String) in
               self.monthBtn.setTitle(item, for: .normal)
               
//               if item == "All" {
//                   // Show all data if "All" is selected
//                   filterData = leaveResuest
//               } else {
                   // Filter leaveResuest by the selected month
                   let selectedMonth = index // Adjust index because "All" is now the first item
//               }
               
               historyTable.reloadData()
           }
    }
//    func filterByMonth(selectedMonth: Int) -> [LeaveRequest] {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd MMM yy" // Match date format to your data
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Adjust timezone if needed
//
//        return leaveResuest.filter { request in
//            guard let fromDateText = request.fromDate,
//                  let toDateText = request.toDate else {
//                return false
//            }
//
//            guard let fromDate = dateFormatter.date(from: fromDateText),
//                  let toDate = dateFormatter.date(from: toDateText) else {
//                print("Date parsing failed for: \(fromDateText), \(toDateText)")
//                return false
//            }
//            
//            let calendar = Calendar.current
//            var currentDate = fromDate
//            
//            while currentDate <= toDate {
//                let currentMonth = calendar.component(.month, from: currentDate)
//                if currentMonth == selectedMonth {
//                    return true // Match found
//                }
//                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
//            }
//            
//            return false // No match found
//        }
//    }

    
   
//    func delete(index: Int, UpdateDetails: LeaveRequest,Updated:Bool) {
//        if !Updated{
//            leaveResuest.remove(at: index)
//            historyTable.reloadData()
//        }else{
//            navigatedelegate?.navigate(index: 0, leaveRequest: UpdateDetails)
//        }
//    }

}

extension LeveHistoryVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LeaveHistoryData?.count ?? 0
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTable.dequeueReusableCell(withIdentifier: CellConfingName.LeveHistoryTV, for: indexPath) as! LeveHistoryTV

        guard let leaveData = LeaveHistoryData?[indexPath.row] else { return cell }

        // Configure cell labels and views
        cell.fromDateLbl.text = leaveData.leave_from
        cell.toDateLbl.text = leaveData.leave_to
        cell.aproveLbl.text = leaveData.status
        
        // Status-based customization
        if leaveData.status == "Approved" {
            cell.statusBtn.backgroundColor = Colornames.AprovedClr
            cell.satusImg.image = ImageName.check
            cell.aproveLbl.textColor = .white
            cell.edit.isHidden = true
            cell.editHeight.constant = 0
        } else if leaveData.status == "Rejected" {
            cell.statusBtn.backgroundColor = .red
            cell.satusImg.image = UIImage(systemName: "multiply.circle.fill")
            cell.aproveLbl.textColor = .white
            cell.satusImg.tintColor = .white
        } else {
            cell.aproveLbl.textColor = .white
            cell.satusImg.tintColor = .white
            cell.statusBtn.backgroundColor = Colornames.pendingClr
            cell.satusImg.image = ImageName.Pending
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
