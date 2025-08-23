//
//  SlotListVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 12/08/25.
//

import UIKit

class SlotListVC: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    
    var slotData: SlotEventDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tv.register(UINib(nibName: "MeetingDataTV", bundle: nil), forCellReuseIdentifier: "MeetingDataTV")
        tv.register(UINib(nibName: "SlotListTV", bundle: nil), forCellReuseIdentifier: "SlotListTV")
        tv.delegate = self
        tv.dataSource = self
    }

    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
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
            cell.JoinBtn.isHidden = slotData?.event_mode == "Online" ? false : true
            cell.TimeLbl.text = (slotData?.start_time ?? "") + " - " + (slotData?.end_time ?? "")
            
            return cell
        }else {
                let cell = tv.dequeueReusableCell(withIdentifier: "SlotListTV", for: indexPath) as! SlotListTV
            
            let slot = slotData?.slots?[indexPath.row]
            
            
            if slot?.is_booked == 1 {
                cell.StatusBtn.backgroundColor = .green.withAlphaComponent(0.1)
                cell.StatusBtn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
                cell.StatusBtn.setTitleColor(.aproved, for: .normal)
                cell.StatusBtn.tintColor = .aproved
                cell.BookedStatusView.isHidden = false
                cell.WaitingLbl.isHidden = true
                cell.BookingBaseview.backgroundColor = .systemGreen.withAlphaComponent(0.05)
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
            
            if slot?.is_cancelled == 1 {
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
    
    
}
