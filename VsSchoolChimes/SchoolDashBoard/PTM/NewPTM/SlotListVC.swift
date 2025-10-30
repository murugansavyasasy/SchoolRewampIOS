//
//  SlotListVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 12/08/25.
//

import UIKit

class SlotListVC: UIViewController, UITableViewDataSource, UITableViewDelegate, SelectedId{
    func selectId(id: String?, edit: Bool?) {
        if edit ?? false{
            Cancel_and_Reopen_Slot_api(SlotId: id ?? "")
        }else{
            cancel_and_close_slot_Api(SlotId: id ?? "")
        }
    }
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var nameLbl: UILabel!
    
    var slotData: SlotEventDetail?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var MeetingStatus = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLbl.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName, secondLine: staffDetails?.school_name ?? "")
        tv.register(UINib(nibName: CellConfingName.MeetingDataTV, bundle: nil), forCellReuseIdentifier: CellConfingName.MeetingDataTV)
        tv.register(UINib(nibName: CellConfingName.SlotListTV, bundle: nil), forCellReuseIdentifier: CellConfingName.SlotListTV)
        tv.delegate = self
        tv.dataSource = self
    }
    
    //MARK: API call functions
    
    func Cancel_and_Reopen_Slot_api(SlotId:String){
        
        //var slot = slotData?.slots?[indexpath.row]
        let param : [String:Any] = ["slot_id":SlotId]
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_cancel_and_reopen_slot, parameters: param, type: ApitTypeSringFile.PUT, token: staffDetails?.access_token ?? "") { [weak self] (result:Result<CommonApiSuc,Error>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    if success.status == true {
                        if let index = self.slotData?.slots?.firstIndex(where: { $0.slot_id == SlotId }) {
                            self.slotData?.slots?[index].is_booked = false
                            self.slotData?.slots?[index].is_cancelled = false
                            self.slotData?.slots?[index].is_cancelled_by_staff = false
                            // self.slotData?.slots?[index].is_booked = false
                            self.tv.reloadData()
                        }

//                        slot?.is_cancelled_by_staff = true
//                        self.tv.reloadRows(at: [indexpath], with: .automatic)
                    }else {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                    }
                case .failure(let failure):
                    print("Error: ",failure.localizedDescription)
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
                }
                
            }
        }
    }
    
    func cancel_and_close_slot_Api(SlotId:String){
        let slot_id = [SlotId]
        let param : [String:Any] = ["slot_ids":slot_id]
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_cancel_and_close_slot, parameters: param, type: ApitTypeSringFile.PUT, token: staffDetails?.access_token ?? "") { [weak self] (result:Result<CommonApiSuc,Error>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    if success.status == true {
                        if let index = self.slotData?.slots?.firstIndex(where: { $0.slot_id == SlotId }) {
                            self.slotData?.slots?[index].is_booked = false
                            self.slotData?.slots?[index].is_cancelled_by_staff = true
                            self.slotData?.slots?[index].is_cancelled = true
                            // self.slotData?.slots?[index].is_booked = false
                            self.tv.reloadData()
                        }

//                        slot?.is_cancelled_by_staff = true
//                        self.tv.reloadRows(at: [indexpath], with: .automatic)
                    }else {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                    }
                case .failure(let failure):
                    print("Error: ",failure.localizedDescription)
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
                }
                
            }
            
        }
    }
    

    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1{
            let headerView = UIView()
            headerView.backgroundColor = .clear  // Customize color
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.setFont(style: .title, size: FontSize.TitleSize)
            label.textColor = .darkGray
            label.text = "Meeting Slots"
            headerView.addSubview(label)
            
            NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5)])
            
            return headerView
        }else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : slotData?.slots?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.MeetingDataTV, for: indexPath) as! MeetingDataTV
            
            cell.dateLbl.text = slotData?.date
            cell.meetingNameLbl.text = slotData?.event_name
            cell.durationLbl.text = String(slotData?.meeting_duration ?? 0) + " " + PTMString.minutes
            cell.modeLbl.text = slotData?.event_mode
            cell.JoinBtn.isHidden = slotData?.event_mode == "Virtual" ? false : true
            cell.TimeLbl.text = (slotData?.start_time ?? "") + " - " + (slotData?.end_time ?? "")
            
            return cell
        }else {
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.SlotListTV, for: indexPath) as! SlotListTV
            
            let slot = slotData?.slots?[indexPath.row]
            
            cell.TimeLbl.text = (slot?.from_time ?? "") + " - " + (slot?.to_time ?? "")
            cell.DurationLbl.text = PTMString.duration + " - " + String(slot?.meeting_duration ?? 0) +  " " + PTMString.minutes
            cell.bookedByNameLbl.text = slot?.booked_by
            
            let imageUrl = URL(string: slot?.profile_url ?? "")
            cell.profileImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "interactProfile"))
            
            if slot?.can_cancel == true{
                
                if slot?.is_cancelled ?? false{
                    cell.edit(edit:true,delete:false,selectedId:slot?.slot_id ?? "")
                }else {
                    cell.edit(edit:false,delete:true,selectedId:slot?.slot_id ?? "")
                }
                
                if MeetingStatus == PTMString.completedMeetings{
                    cell.optionsBtn.isHidden = true
                }
                
                if MeetingStatus == PTMString.todayMeetings{
                    cell.optionsBtn.isHidden = isCurrentTimeLater(than: slot?.from_time ?? "")
                }
                
                cell.delegate = self
                
            }else {
                cell.optionsBtn.isHidden = true
            }
            
            
            if slot?.is_booked == true {
                cell.StatusBtn.backgroundColor = .green.withAlphaComponent(0.1)
                let title = (MeetingStatus == PTMString.completedMeetings) ? "Completed" : "Booked"
                cell.StatusBtn.setTitle(title, for: .normal)
                cell.StatusBtn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
                cell.StatusBtn.setTitleColor(.aproved, for: .normal)
                cell.StatusBtn.tintColor = .aproved
                cell.BookedStatusView.isHidden = false
                cell.WaitingLbl.isHidden = true
                cell.BookingBaseview.backgroundColor = .systemGreen.withAlphaComponent(0.1)
            }else {
                cell.StatusBtn.backgroundColor = .systemBlue.withAlphaComponent(0.075)
                cell.StatusBtn.setImage(UIImage(systemName: "exclamationmark.circle"), for: .normal)
                cell.StatusBtn.setTitle("Available", for: .normal)
                cell.StatusBtn.setTitleColor(.black, for: .normal)
                cell.StatusBtn.tintColor = .systemBlue
                cell.BookedStatusView.isHidden = true
                cell.WaitingLbl.isHidden = false
                cell.WaitingLbl.textColor = .systemBlue
                cell.BookingBaseview.backgroundColor = .systemBlue.withAlphaComponent(0.1)
                cell.WaitingLbl.text = "Waiting for Booking"
            }
            
            if slot?.status == "Expired" {
                
              //  cell.optionsBtn.isHidden = true
                cell.StatusBtn.backgroundColor = .systemGray5.withAlphaComponent(1)
                cell.StatusBtn.setImage(UIImage(systemName: "exclamationmark.circle"), for: .normal)
                cell.StatusBtn.setTitle("Expired", for: .normal)
                cell.StatusBtn.setTitleColor(.black, for: .normal)
                cell.StatusBtn.tintColor = .black
//                cell.BookedStatusView.isHidden = false
//                cell.WaitingLbl.isHidden = true
//                cell.BookingBaseview.backgroundColor = .systemGray6.withAlphaComponent(0.8)
//                cell.bookedByDefLbl.text = "Cancelled by:"
                cell.BookedStatusView.isHidden = true
                cell.WaitingLbl.isHidden = false
                cell.WaitingLbl.textColor = .black
                cell.BookingBaseview.backgroundColor = .systemGray5.withAlphaComponent(1)
                cell.WaitingLbl.text = "Slot Expired"
            }
            
            if slot?.is_cancelled_by_staff == true {
                cell.StatusBtn.backgroundColor = .systemRed.withAlphaComponent(0.1)
                cell.StatusBtn.setImage(UIImage(systemName: "x.circle"), for: .normal)
                cell.StatusBtn.setTitle("Cancelled", for: .normal)
                cell.StatusBtn.setTitleColor(.red, for: .normal)
                cell.StatusBtn.tintColor = .red
//                cell.BookedStatusView.isHidden = false
//                cell.WaitingLbl.isHidden = true
//                cell.BookingBaseview.backgroundColor = .systemGray6.withAlphaComponent(0.8)
//                cell.bookedByDefLbl.text = "Cancelled by:"
                cell.BookedStatusView.isHidden = true
                cell.WaitingLbl.isHidden = false
                cell.WaitingLbl.textColor = .systemRed
                cell.BookingBaseview.backgroundColor = .systemRed.withAlphaComponent(0.1)
                cell.WaitingLbl.text = "Slot Cancelled"
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.01 : 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return  0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func isCurrentTimeLater(than timeString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let givenDate = formatter.date(from: timeString) else {
            return false // invalid input
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Extract hour and minute from given time
        let components = calendar.dateComponents([.hour, .minute], from: givenDate)
        
        guard let givenTimeToday = calendar.date(bySettingHour: components.hour!,
                                                 minute: components.minute!,
                                                 second: 0,
                                                 of: now) else {
            return false
        }
        
        return now > givenTimeToday
    }
}
