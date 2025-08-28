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
            
        }else{
            
        }
        print(id)
    }
    

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    
    var slotData: SlotEventDetail?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backBtn.configureAsBackButton(firstLine: "PTM", secondLine: staffDetails?.school_name ?? "",colour: .black)
        tv.register(UINib(nibName: "MeetingDataTV", bundle: nil), forCellReuseIdentifier: "MeetingDataTV")
        tv.register(UINib(nibName: "SlotListTV", bundle: nil), forCellReuseIdentifier: "SlotListTV")
        tv.delegate = self
        tv.dataSource = self
    }
    
    //MARK: API call functions
    
    func Cancel_and_Reopen_Slot_api(indexpath:IndexPath){
        
        var slot = slotData?.slots?[indexpath.row]
        let param : [String:Any] = ["slot_id":slot?.slot_id ?? ""]
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_cancel_and_reopen_slot, parameters: param, type: ApitTypeSringFile.PUT, token: staffDetails?.access_token ?? "") { [weak self] (result:Result<CommonApiSuc,Error>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    if success.status == true {
                        slot?.is_cancelled_by_staff = true
                        self.tv.reloadRows(at: [indexpath], with: .automatic)
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
            let cell = tv.dequeueReusableCell(withIdentifier: "MeetingDataTV", for: indexPath) as! MeetingDataTV
            
            cell.dateLbl.text = slotData?.date
            cell.meetingNameLbl.text = slotData?.event_name
            cell.durationLbl.text = String(slotData?.meeting_duration ?? 0) + " minutes"
            cell.modeLbl.text = slotData?.event_mode
            cell.JoinBtn.isHidden = slotData?.event_mode == "Virtual" ? false : true
            cell.TimeLbl.text = (slotData?.start_time ?? "") + " - " + (slotData?.end_time ?? "")
            
            return cell
        }else {
                let cell = tv.dequeueReusableCell(withIdentifier: "SlotListTV", for: indexPath) as! SlotListTV
            
            let slot = slotData?.slots?[indexPath.row]
            
            cell.TimeLbl.text = (slot?.from_time ?? "") + " - " + (slot?.to_time ?? "")
            cell.DurationLbl.text = "Duration - " + String(slot?.meeting_duration ?? 0) + " minutes"
            cell.bookedByNameLbl.text = slot?.booked_by
            cell.edit(edit:true,delete:true,selectedId:slot?.slot_id ?? "")
            cell.delegate = self
            if slot?.is_booked == true {
                cell.StatusBtn.backgroundColor = .green.withAlphaComponent(0.1)
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
            }
            
            if slot?.is_cancelled == true {
                cell.StatusBtn.backgroundColor = .systemRed.withAlphaComponent(0.1)
                cell.StatusBtn.setImage(UIImage(systemName: "x.circle"), for: .normal)
                cell.StatusBtn.setTitle("Cancelled", for: .normal)
                cell.StatusBtn.setTitleColor(.red, for: .normal)
                cell.StatusBtn.tintColor = .red
                cell.BookedStatusView.isHidden = false
                cell.WaitingLbl.isHidden = true
                cell.BookingBaseview.backgroundColor = .systemGray6.withAlphaComponent(0.8)
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
}
