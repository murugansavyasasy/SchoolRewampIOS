//
//  CreateSlotsBottomVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 20/08/25.
//

import UIKit

class CreateSlotsBottomVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createMeetingBtn: UIButton!
    
    var slotData: [ValidatedSlotData] = [] // contains [Slot]
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        createMeetingBtn.layer.cornerRadius = 10
        
        tableView.register(UINib(nibName: "CreatedSlotsTv", bundle: nil), forCellReuseIdentifier: "CreatedSlotsTv")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func backAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    //MARK: Api Call Function
    
    func Create_meeting_api(){
        
        var param = [[String: Any]]()
        param.reserveCapacity(slotData.count) // small perf boost

        for data in slotData {
            // Pre-map nested arrays first
            let stdSecDetails: [[String: Any]] = (data.std_sec_details ?? []).map { detail in
                [
                    PTMRequestStringFile.class_id: detail.class_id ?? "",
                    PTMRequestStringFile.section_id: detail.section_id ?? ""
                ]
            }

            let slotsArray: [[String: Any]] = (data.slots ?? []).compactMap { slot in
                if slot.slot_availablity == "Available" {
                    return [
                        PTMRequestStringFile.from_time: slot.slot_from ?? "",
                        PTMRequestStringFile.to_time: slot.slot_to ?? ""
                    ]
                }
                return nil
            }

            // Skip if slotsArray is empty
                guard !slotsArray.isEmpty else { continue }

            // Build the main dictionary
            let dict: [String: Any] = [
                PTMRequestStringFile.date: data.date ?? "",
                PTMRequestStringFile.event_name: data.event_name ?? "",
                PTMRequestStringFile.from_time: data.from_time ?? "",
                PTMRequestStringFile.to_time: data.to_time ?? "",
                PTMRequestStringFile.duration: data.duration ?? 0,
                PTMRequestStringFile.break_time: data.break_time ?? 0,
                PTMRequestStringFile.event_link: "",
                PTMRequestStringFile.meeting_mode: data.meeting_mode ?? "",
                PTMRequestStringFile.std_sec_details: stdSecDetails,
                PTMRequestStringFile.slots: slotsArray
            ]

            param.append(dict)
        }

        if param.isEmpty{
            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: "There is no available slots", on: self)
        }else {
            
            APIService.shared.PtmApi(url: ServiceUrl.ptm_api_ptm_schedule_create_slots, parameters: param, token: staffDetails?.access_token ?? "", isBaseUrl: true) { [weak self] (result:Result<CommonApiSuc,Error>) in
                
                guard let self = self else{return}
                
                DispatchQueue.main.async {
                    
                    switch result {
                    case .success(let success):
                        if success.status == true {
                            if user_inputs.clearTempData(){
                                let parms = [ "mobile_number": UserDefaultFileManager.get_staff_Details()?.mobile_no ?? "",
                                              "activity": "SEND_PTM",
                                              "user_type": 2,
                                              "menu_id": Menu_id.staffSelectedMenuId] as [String : Any]
                                self.paketApiCall(params:parms)
                            }
                            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success, message: success.message ?? "", on: self,okAction: {
                                self.presentingViewController?.presentingViewController?.dismiss(animated: true)
                            })
                        }else {
                            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                        }
                    case .failure(let failure):
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
                    }
                }
                
            }
            
        }
        
//        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_create_slots, parameters: [:], type: ApitTypeSringFile.POST, token: staffDetails?.access_token ?? "") { [weak self] (result:Result<CommonApiSuc , Error>) in
//            
//            guard let self = self else{return}
//            
//            DispatchQueue.main.async {
//                
//                switch result {
//                case .success(let success):
//                    if success.status == true {
//                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success, message: success.message ?? "", on: self,okAction: {
//                            self.presentingViewController?.presentingViewController?.dismiss(animated: true)
//                        })
//                    }else {
//                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
//                    }
//                case .failure(let failure):
//                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
//                }
//            }
//        }
    }
    
    
    @IBAction func createMeetingBtnAct(_ sender: Any) {
        CustomAlert().showAlertCancel(title: AlertstringFile.Confirm, message: AlertstringFile.Are_you_sure_want_to_create_this_PTM_meeting, actionLbl1: AlertstringFile.Yes, actionLbl2: AlertstringFile.No, on: self) {
            self.Create_meeting_api()
        } onNo: {
            
        }
    }
    
    func paketApiCall(params:[String:Any]){
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_pauket_add_points,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: true
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {

                guard let self = self else { return }

                switch result {
                case .success(let response):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(response.message, duration: 2.0, position: .bottom)
                    }
                case .failure(let error):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(error.localizedDescription, duration: 2.0, position: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return slotData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreatedSlotsTv", for: indexPath) as? CreatedSlotsTv else {
            return UITableViewCell()
        }
        cell.dateBtn.setTitle(slotData[indexPath.row].date?.convertToTargetDateFormat(), for: .normal)
        cell.configure(with: slotData[indexPath.row].slots ?? [], parentTableView: tableView)
        
        cell.onSlotRemoved = { [weak self, weak cell] removedIndex in
            guard let self = self,
                  let cell = cell,
                  let currentIndexPath = tableView.indexPath(for: cell) else { return }

            self.slotData[currentIndexPath.row].slots?.remove(at: removedIndex)

            if let slots = self.slotData[currentIndexPath.row].slots, slots.isEmpty {
                    // If no slots left, remove the entire row
                    self.slotData.remove(at: currentIndexPath.row)
                    self.tableView.deleteRows(at: [currentIndexPath], with: .automatic)
                } else {
                    // Otherwise, just reload that row
                    self.tableView.reloadRows(at: [currentIndexPath], with: .automatic)
                }
            
            // Reload just that row to reflect height change
            self.tableView.reloadRows(at: [currentIndexPath], with: .automatic)
            
            if slotData.count == 0{
                self.dismiss(animated: true)
            }
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


struct RequestSlot: Codable {
    var from_time: String
    var to_time: String
}

struct RequestStdSecDetail: Codable {
    var class_id: String
    var section_id: String
}

struct RequestBodyItem: Codable {
    var date: String
    var event_name: String
    var from_time: String
    var to_time: String
    var duration: Int
    var break_time: Int
    var event_link: String
    var meeting_mode: String
    var std_sec_details: [RequestStdSecDetail]
    var slots: [RequestSlot]
}
