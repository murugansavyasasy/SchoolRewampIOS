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
    @IBOutlet weak var EmptyView: UIView!
    @IBOutlet weak var NodataLbl: UILabel!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var TopInfoView: UIView!
    var EditDropdown = DropDown()
    var LeaveHistoryData: [LeaveInfo]?
    var childDetails = UserDefaultFileManager.get_child_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fromLbl.setFont(style:.title, size: FontSize.TitleSize)
        toLbl.setFont(style:.title, size: FontSize.TitleSize)
        statusLbl.setFont(style:.title, size: FontSize.TitleSize)
        headerTitle.setFont(style:.body, size: FontSize.BodySize)
        NodataLbl.setFont(style:.title, size: FontSize.HeaderSize)
        
        TopInfoView.isHidden = true
        EmptyView.isHidden = true
        NodataImage.isHidden = true
        NodataLbl.isHidden = true
        
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
                    
                    NodataLbl.text = success.message
                    EmptyView.isHidden = !(LeaveHistoryData?.isEmpty ?? false)
                    NodataImage.isHidden = !(LeaveHistoryData?.isEmpty ?? false)
                    NodataLbl.isHidden = !(LeaveHistoryData?.isEmpty ?? false)
                    TopInfoView.isHidden = (LeaveHistoryData?.isEmpty ?? false)
                    
                    historyTable.reloadData()
                }
               
            case .failure(let error):
                
                DispatchQueue.main.async {[self] in
                    NodataLbl.text = error.localizedDescription
                    EmptyView.isHidden = false
                    NodataImage.isHidden = false
                    NodataLbl.isHidden = false
                    TopInfoView.isHidden = true
                    print("Error: ",error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func monthWishFilter(_ sender: UIButton) {

        let dateFormatter = DateFormatter()
           dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Change locale if needed
        let monthNames = dateFormatter.monthSymbols ?? [] // This returns ["January", "February", ..., "December"]
           
           EditDropdown.dataSource = monthNames // Use updated list with "All"
           
           EditDropdown.anchorView = monthWish
           EditDropdown.bottomOffset = CGPoint(x: 0, y: monthWish.bounds.height)
           EditDropdown.direction = .bottom
           EditDropdown.width = monthWish.bounds.width
           EditDropdown.show()
           
           EditDropdown.selectionAction = { [self] (index: Int, item: String) in
               self.monthBtn.setTitle(item, for: .normal)
               
                   let selectedMonth = index // Adjust index because "All" is now the first item
               
               historyTable.reloadData()
           }
    }

}

extension LeveHistoryVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LeaveHistoryData?.count ?? 0
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTable.dequeueReusableCell(withIdentifier: CellConfingName.LeveHistoryTV, for: indexPath) as! LeveHistoryTV

        guard let leaveData = LeaveHistoryData?[indexPath.row] else { return cell }

        // Configure cell labels and views
       
        cell.fromDateLbl.text = convertDate(leaveData.leave_from, toFormat: "dd MMM yyyy")
        cell.toDateLbl.text = convertDate(leaveData.leave_to, toFormat: "dd MMM yyyy")
        cell.StatusLbl.text = leaveData.status
        cell.ReasonLbl.text = leaveData.reason
        
        // Status-based customization
        if leaveData.status == "Approved" {
            cell.statusBtn.backgroundColor = Colornames.AprovedClr
            cell.satusImg.image = ImageName.check
            cell.StatusLbl.textColor = .white
            cell.edit.isHidden = true
            cell.editHeight.constant = 0
            cell.UpdatedonDefLbl.isHidden = false
            cell.UpdatedOnColon.isHidden = false
            cell.UpdatedonLbl.isHidden = false
        } else if leaveData.status == "Rejected" {
            cell.statusBtn.backgroundColor = .red
            cell.satusImg.image = UIImage(systemName: "multiply.circle.fill")
            cell.StatusLbl.textColor = .white
            cell.satusImg.tintColor = .white
            cell.UpdatedonDefLbl.isHidden = false
            cell.UpdatedOnColon.isHidden = false
            cell.UpdatedonLbl.isHidden = false
        } else {
            cell.StatusLbl.text = "In review"
            cell.StatusLbl.textColor = .white
            cell.satusImg.tintColor = .white
            cell.statusBtn.backgroundColor = Colornames.pendingClr
            cell.satusImg.image = ImageName.Pending
            cell.UpdatedonDefLbl.isHidden = true
            cell.UpdatedOnColon.isHidden = true
            cell.UpdatedonLbl.isHidden = true
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
