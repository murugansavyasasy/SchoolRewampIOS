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
   
    var LeaveHistoryData: [LeaveInfo]?
    var childDetails = UserDefaultFileManager.get_child_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fromLbl.setFont(style:.title, size: FontSize.TitleSize)
        toLbl.setFont(style:.title, size: FontSize.TitleSize)
        statusLbl.setFont(style:.title, size: FontSize.TitleSize)
        headerTitle.setFont(style:.body, size: FontSize.BodySize)
        NodataLbl.setFont(style:.title, size: FontSize.HeaderSize)
        NodataLbl.text = CommonStringFile.No_data_found
        
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
        
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_leave_req_list, parameters: [LeaveRequestStringFile.member_type:"STUDENT"], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") {[weak self] (result:Result<LeaveInfoResponse,Error>) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else {return}
                
                if #available(iOS 15.0, *) {
                    self.hideLottieProgressLoader()
                }
                
                switch result{
                    
                case .success(let success):
                    
                    self.LeaveHistoryData = success.data
                    let Hidden = self.LeaveHistoryData?.isEmpty ?? false
                    self.EmptyView.isHidden = !Hidden
                    self.NodataImage.isHidden = !Hidden
                    self.NodataLbl.isHidden = !Hidden
                    self.TopInfoView.isHidden = Hidden
                    self.historyTable.reloadData()
                    
                case .failure(let error):
                    
                    self.NodataLbl.text = error.localizedDescription
                    self.EmptyView.isHidden = false
                    self.NodataImage.isHidden = false
                    self.NodataLbl.isHidden = false
                    self.TopInfoView.isHidden = true
                    print("Error: ",error.localizedDescription)
                }
            }}
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
        
        cell.fromDateLbl.text = convertDate(leaveData.leave_from, toFormat: DateFormatString.StandardFormat)
        cell.toDateLbl.text = convertDate(leaveData.leave_to, toFormat: DateFormatString.StandardFormat)
        cell.StatusLbl.text = leaveData.status
        cell.ReasonLbl.text = leaveData.reason
        cell.StatusLbl.textColor = .white
        
        // Status-based customization
        if leaveData.status == "Approved" {
            cell.statusBtn.backgroundColor = Colornames.AprovedClr
            cell.satusImg.image = ImageName.check
            cell.edit.isHidden = true
            cell.editHeight.constant = 0
            cell.UpdatedonDefLbl.isHidden = false
            cell.UpdatedOnColon.isHidden = false
            cell.UpdatedonLbl.isHidden = false
        } else if leaveData.status == "Rejected" {
            cell.statusBtn.backgroundColor = .red
            cell.satusImg.image = UIImage(systemName: "multiply.circle.fill")
            cell.satusImg.tintColor = .white
            cell.UpdatedonDefLbl.isHidden = false
            cell.UpdatedOnColon.isHidden = false
            cell.UpdatedonLbl.isHidden = false
        } else {
            cell.StatusLbl.text = "In review"
            cell.StatusLbl.textColor = .white
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
