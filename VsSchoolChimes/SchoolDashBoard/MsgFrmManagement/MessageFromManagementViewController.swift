//
//  MessageFromManagementViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/17/24.
//

protocol ReadUpadesManagemant{
    func readStatusManagement(attachment:ManagemantMessageData)
}

import UIKit

@available(iOS 14.0, *)
class MessageFromManagementViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, viewAttachments {
    func viewAttachment(sender: UIButton) {
        
        let vc = MsgViewVC()
        vc.modalPresentationStyle = .formSheet
        if let data = SearchData?[sender.tag]{
            vc.MsgFromManagmentData = data
        }
        
        vc.file_path = SearchData?[sender.tag].file_path
      present(vc, animated: true, completion: nil)
        
        
       
        
        if SearchData?[sender.tag].type == "VOICE"{
            ReadStatusUpdate(
                type: "MGMT_MSG_VOICE",
                detail_id: SearchData?[sender.tag].header_id ?? ""
            )
        }else if SearchData?[sender.tag].type == "TEXT"{
            
            ReadStatusUpdate(
                type: "MGMT_MSG_TEXT",
                detail_id: SearchData?[sender.tag].header_id ?? ""
            )
        }else if SearchData?[sender.tag].type == "ATTACHMENT"{
            
            ReadStatusUpdate(
                type: "MGMT_MSG_ATTACHMENT",
                detail_id: SearchData?[sender.tag].header_id ?? ""
            )
        }
        
        
    }

    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var FilterCV: UICollectionView!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    var messageData: [ManagemantMessageData]?
    var SearchData: [ManagemantMessageData]?
    var dateFormatter = DateFormatter()
    var shouldShowFooter = true
    var playIndex :Int?
    var readIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: staffDetails?.school_name ?? "")
        BackBtn.applyBackButton()
        NoDataLbl.setFont(style: .title, size: FontSize.HeaderSize)
        
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        SearchBar.searchTextField.addDoneButton()
        SearchBar.delegate = self
        
        FilterCV.isHidden = true
        SearchBar.isHidden = true
        NoDataLbl.isHidden = true
        NoDataImage.isHidden = true
        
        Cell_Registration()
       
        
        tv.register(UINib(nibName: CellConfingName.MessageFromManagementTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.MessageFromManagementTableViewCell)
        tv.dataSource = self
        tv.delegate = self
        
        Get_messages()
    }
    

    
    func Cell_Registration() {

        tv.register(UINib(nibName: "MsgTvCell", bundle: nil), forCellReuseIdentifier: "MsgTvCell")
    }
    
    //MARK: Get Message Data Api call
    
    func Get_messages() {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_msg_from_management_get_messages_staff, parameters: [:], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") {[self] (result: Result<MessageFromManagementResp,Error>) in
            
            switch result{
                
            case .success(let success):
                DispatchQueue.main.async { [self] in
                    
                    messageData = success.data
                    SearchData = messageData
                    
                    NoDataLbl.text = success.message
                    NoDataImage.isHidden = !(messageData?.isEmpty ?? false)
                    NoDataLbl.isHidden = !(messageData?.isEmpty ?? false)
                    SearchBar.isHidden = (messageData?.isEmpty ?? false)
                    tv.reloadData()
                }
                
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    
                    NoDataImage.isHidden = false
                    NoDataLbl.isHidden = false
                    SearchBar.isHidden = true
                    NoDataLbl.text = error.localizedDescription
                    tv.reloadData()
                }
            }
        }
    }
    
    func get_messages_archive() {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_msg_from_management_get_messages_staff_archive, parameters: [:], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") {[self] (result: Result<MessageFromManagementResp,Error>) in
            
            switch result{
                
            case .success(let success):
                DispatchQueue.main.async { [self] in
                    
                    messageData?.append(contentsOf: success.data ?? [])
                    SearchData = messageData
                    
                    NoDataLbl.text = success.message
                    NoDataImage.isHidden = !(messageData?.isEmpty ?? false)
                    NoDataLbl.isHidden = !(messageData?.isEmpty ?? false)
                    SearchBar.isHidden = (messageData?.isEmpty ?? false)
                    tv.reloadData()
                }
                
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    
                    NoDataImage.isHidden = !(messageData?.isEmpty ?? false)
                    NoDataLbl.isHidden = !(messageData?.isEmpty ?? false)
                    SearchBar.isHidden = (messageData?.isEmpty ?? false)
                    NoDataLbl.text = error.localizedDescription
                }
            }
        }
    }
    
    func ReadStatusUpdate(type: String,detail_id: String) {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: staffDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
            
            switch result {
                
                
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        
                        SearchData = SearchData?.map { message in
                            
                            var updated = message
                            if message.id == detail_id{
                                updated.is_unread = false
                            }
                            return updated
                        }
                        
                        tv.reloadData()
                    }
                    
                }else {
                    
                    DispatchQueue.main.async {
                        
                        print(SuccessMessage.message)
                    }
                }
                
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    func ReadStatusUpdateArchive(type: String,detail_id: String){
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update_archive, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: staffDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
            
            switch result {
                
                
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        SearchData = SearchData?.map { message in
                            
                            var updated = message
                            if message.id == detail_id{
                                updated.is_unread = false
                            }
                            return updated
                        }
                        
                        tv.reloadData()
                    }
                    
                }else {
                    
                    DispatchQueue.main.async {
                        
                        print(SuccessMessage.message)
                    }
                }
                
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func backAct() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MsgTvCell") as? MsgTvCell else {
            return UITableViewCell()
        }
        
        let displayText = formattedDateStatus(
            from: SearchData?[indexPath.row].date ?? ""
        )
        cell.senderNamelbl.text = SearchData?[indexPath.row].sent_by ?? ""
        cell.timeAndDateLbl.text = (displayText) + ("  " + (SearchData?[indexPath.row].time ?? ""))
        cell.viewBtn.tag = indexPath.row
        cell.descrptionLb.isHidden = SearchData?[indexPath.row].description == "" ? true : false
        cell.delegate = self
        cell.alphbetLbl.text = shortName(
            from: SearchData?[indexPath.row].sent_by ?? ""
        )
        cell.titleLbl.text = SearchData?[indexPath.row].title ?? ""
        cell.readView.isHidden = SearchData?[indexPath.row].is_unread ?? false ? false : true
        cell.rollBtn
            .setTitle(
                SearchData?[indexPath.row].role?.capitalized,
                for: .normal
            )
        return cell
        
    }
    
    
    func shortName(from name: String) -> String {
        // remove spaces
        let trimmed = name.replacingOccurrences(of: " ", with: "")
        
        guard let first = trimmed.first, let last = trimmed.last else {
            return ""
        }
        
        return "\(first)\(last)".uppercased()
    }

    
    func addBlurEffect() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.tag = 999
        view.addSubview(blurView)
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
   
    
    
}

@available(iOS 14.0, *)
extension MessageFromManagementViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty{
            SearchData = messageData
        }else {
            SearchData = messageData?.filter{ message in
                let date = dateFormatter.convertDate(message.date ?? "")?.lowercased()
                return date?.contains(searchText.lowercased()) ?? false ||
                message.title?.lowercased().contains(searchText.lowercased()) ?? false ||
                message.description?.lowercased().contains(searchText.lowercased()) ?? false ||
                message.content?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        
        NoDataImage.isHidden = !(SearchData?.isEmpty ?? false)
        NoDataLbl.isHidden = !(SearchData?.isEmpty ?? false)
        NoDataLbl.text = CommonStringFile.No_data_found
        tv.reloadData()
    }
}

@available(iOS 14.0, *)
extension MessageFromManagementViewController: TextExpandCellDelegate, ReadUpadesManagemant, reloadDelegate {
    func deleteDelegate(index: Int) {
        
    }
    
    
    func didTapExpand(in cell: TextHistoryTVCell) {
        guard let indexPath = tv.indexPath(for: cell) else { return }
        guard var message = SearchData?[indexPath.row] else { return }

        // Toggle state
        message.isExpand = !(message.isExpand ?? false)
        SearchData?[indexPath.row] = message

        // API Call (on first view)
        if message.is_unread == true {
            if message.is_archive == true {
                ReadStatusUpdateArchive(type: message.type ?? "", detail_id: message.id ?? "")
            } else {
                ReadStatusUpdate(type: message.type ?? "", detail_id: message.id ?? "")
            }
            SearchData?[indexPath.row].is_unread = false
            cell.NewImageView.isHidden = true
        }

        // Reload cell for layout changes
        tv.beginUpdates()
        tv.reloadRows(at: [indexPath], with: .automatic)
        tv.endUpdates()
    }
    
    func readStatusManagement(attachment: ManagemantMessageData) {
        
        if attachment.is_archive == true {
            ReadStatusUpdateArchive(type: attachment.type ?? "", detail_id: attachment.id ?? "")
        } else {
            ReadStatusUpdate(type: attachment.type ?? "", detail_id: attachment.id ?? "")
        }
    }
    
    func reload(index: Int) {
        
            if let currentIndex = playIndex, currentIndex != index {
                let previousIndexPath = IndexPath(row: currentIndex, section: 0)
                if let previousCell = tv.cellForRow(at: previousIndexPath) as? HistoryTC {
                    previousCell.updatePlayState(isPlaying: false, url: nil)
                }
            }
            
        playIndex = (playIndex == index) ? nil : index
        var currentmessage: ManagemantMessageData?
        

        currentmessage = SearchData?[index]
        
        if currentmessage?.is_unread == true {
            
            if currentmessage?.is_archive ?? false {
                ReadStatusUpdateArchive(type: currentmessage?.type ?? "", detail_id: currentmessage?.id ?? "")
            }else {
                
                ReadStatusUpdate(type: currentmessage?.type ?? "", detail_id: currentmessage?.id ?? "")
            }
            
            currentmessage?.is_unread = false
            
            if let PlayingMessage = currentmessage{
                SearchData?[index] = PlayingMessage
            }
        }
        
            tv.reloadData()
    }
}
