//
//  OutpassRequestsVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 27/03/26.
//

import UIKit

class OutpassRequestsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var NodataLbl: UILabel!
    
    var outpassRequestList : [OutPassRequest]?
    var FilteroutpassRequestList : [OutPassRequest]?
    var Hosteldetails: [HostelDetailsData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.searchTextField.addDoneButton()
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.searchTextField.backgroundColor = .systemGray5
        searchBar.layer.cornerRadius = 8
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.delegate = self
        searchBar.isHidden = true
        
        tv.register(outpassRequestTVcell.self)
        tv.delegate = self
        tv.dataSource = self
        
        FilteroutpassRequestList = outpassRequestList
        tv.reloadData()
      
        NodataImage.isHidden = true
        NodataLbl.isHidden = true
    }

    
    @IBAction func searchBtnAct(_ sender: UIButton) {
        
        searchBar.becomeFirstResponder()
        sender.isSelected.toggle()
        if sender.isSelected{
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
            sender.setImage(ImageName.magnifyingglass_circle_fill, for: .normal)
        }else{
            searchBar.isHidden = true
            NodataImage.isHidden = true
            NodataLbl.isHidden = true
            searchBar.resignFirstResponder()
            sender.setImage(ImageName.magnifyingglass, for: .normal)
            searchBar.searchTextField.text = ""
            FilteroutpassRequestList = outpassRequestList
            tv.reloadData()
        }
    }
    
    @IBAction func backBtnAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilteroutpassRequestList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "outpassRequestTVcell", for: indexPath) as! outpassRequestTVcell
        
        let data = FilteroutpassRequestList?[indexPath.row]
        cell.reasonLbl.text = data?.reason
        cell.RequestTimeLbl.text = "Requested : \(data?.request_time ?? "")"
        let input = data?.fromdate_todate ?? ""
        let output = formatFromToDate(input)
        cell.outPassTimeLbl.text = output
        cell.statusLbl.text = data?.status
        
        if data?.status?.lowercased() == "pending"{
            cell.statusView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            cell.statusLbl.textColor = .systemOrange
            cell.viewMoreStack.isHidden = true
           
        }else if data?.status?.lowercased() == "approved"{
            cell.statusView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            cell.statusLbl.textColor = .systemGreen
            cell.viewMoreStack.isHidden = false
        }else{
            cell.statusView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            cell.statusLbl.textColor = .systemRed
            cell.viewMoreStack.isHidden = true
        }
        
        cell.onViewDetails = { [weak self]  in
            guard let self = self else { return }
            
            let data  = self.FilteroutpassRequestList![indexPath.row]
            
            let gatePassData = GatePass(
                action_by: data.action_by,
                admission_no: Hosteldetails?.first?.admission_no ?? "",
                reason: data.reason,
                profile: "",
                floor_no: Hosteldetails?.first?.floor_no,
                room_no: Hosteldetails?.first?.room_no,
                fromdate_todate: data.fromdate_todate,
                request_time: data.request_time,
                status: data.status
            )
            
            let vc = yearAndMonthCalenderVc()
            vc.GatepassData = gatePassData
            vc.isGatePass = true
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    

    func formatFromToDate(_ input: String) -> String {
        
        let parts = input.components(separatedBy: " - ")
        guard parts.count == 2 else { return input }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy hh:mm a"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd, yyyy hh:mm a"
        
        let fromDate = inputFormatter.date(from: parts[0])
        let toDate = inputFormatter.date(from: parts[1])
        
        let fromString = fromDate != nil ? outputFormatter.string(from: fromDate!) : parts[0]
        let toString = toDate != nil ? outputFormatter.string(from: toDate!) : parts[1]
        
        return "\(fromString) - \(toString)"
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            FilteroutpassRequestList = outpassRequestList
        } else {
            FilteroutpassRequestList = outpassRequestList?.filter { outpass in
                
                (outpass.fromdate_todate ?? "").lowercased().contains(searchText.lowercased()) ||
            (outpass.request_time ?? "").lowercased().contains(searchText.lowercased()) ||
                (outpass.reason ?? "").lowercased().contains(searchText.lowercased()) ||
                (outpass.status ?? "").lowercased().contains(searchText.lowercased())
            }
        }
        
        if FilteroutpassRequestList?.isEmpty == true {
            NodataImage.isHidden = false
            NodataLbl.isHidden = false
        }else{
            NodataImage.isHidden = true
            NodataLbl.isHidden = true
        }
        
        tv.reloadData()
    }
}
