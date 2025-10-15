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
import DropDown

@available(iOS 14.0, *)
class MessageFromManagementViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, viewAttachments {
    
    
    func viewAttachment(sender: UIButton) {
        guard let data = SearchData?[sender.tag] else { return }

        let vc = MsgViewVC()
        vc.modalPresentationStyle = .formSheet
        vc.MsgFromManagmentData = data
        vc.file_path = data.file_path
        present(vc, animated: true, completion: nil)

        // Determine message type for ReadStatusUpdate
        var messageType: String?

        switch data.type {
        case "VOICE":
            messageType = "VOICE"
        case "TEXT":
            messageType = "TEXT"
        case "ATTACHMENT":
            messageType = "ATTACHMENT"
        default:
            break
        }

        guard let type = messageType else { return }

        if data.is_archive == true {
            ReadStatusUpdateArchive(type: type, detail_id: data.id ?? "")
        }else{
            ReadStatusUpdate(type: type, detail_id: data.id ?? "")
        }
    }

    
    
    @IBOutlet weak var menuNameLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var FilterCV: UICollectionView!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var schoolDropDown: UIView!
    @IBOutlet weak var schoolName: UILabel!
    
    
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    var school_details = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var messageData: [ManagemantMessageData]?
    var SearchData: [ManagemantMessageData]?
    var dateFormatter = DateFormatter()
    var shouldShowFooter = true
    var shouldShowFooterLabel = false
    var archiveMessage = ""
    var playIndex :Int?
    var readIndex: Int?
    var dropDown = DropDown()
    var searchText = ""
    var selectedSchoolId:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        BackBtn.configureAsBackButton(firstLine: MenuStringFile.selectedMenuName, secondLine: staffDetails?.school_name ?? "")
        menuNameLbl.text = MenuStringFile.selectedMenuName
        menuNameLbl.setFont(style: .header, size: FontSize.HeaderSize)
        BackBtn.applyBackButton()
        NoDataLbl.setFont(style: .title, size: FontSize.HeaderSize)
        
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        SearchBar.isHidden = true
        SearchBar.searchTextField.addDoneButton()
        SearchBar.placeholder = CommonStringFile.Search
        SearchBar.backgroundImage = UIImage()
        SearchBar.delegate = self
        
        schoolDropDown.setShadow(cornerRadius: 4)
        schoolDropDown.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SchoolDropDownAct)))
        schoolDropDown.isUserInteractionEnabled = true
        
       if checkMutipleSchool() {
            
           schoolDropDown.isHidden = false
       }else{
           schoolDropDown.isHidden = true
           
       }
        
        FilterCV.isHidden = true
        NoDataLbl.isHidden = true
        NoDataImage.isHidden = true
        
        Cell_Registration()
        
        tv.register(UINib(nibName: CellConfingName.MessageFromManagementTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.MessageFromManagementTableViewCell)
        tv.dataSource = self
        tv.delegate = self
        
        Get_messages()
    }
    
    func checkMutipleSchool() -> Bool{
        
        if school_details?.count ?? 0 > 1 {
            
            switch school_details?.first?.priority_level{
                
            case PriorityType.is_principal,PriorityType.is_grouphead, PriorityType.is_admin :
                
                return true
                
            default:
                return false
            }
        }
        
        return false
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
                    tv.reloadData()
                }
                
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    
                    NoDataImage.isHidden = false
                    NoDataLbl.isHidden = false
                    NoDataLbl.text = error.localizedDescription
                    tv.reloadData()
                }
            }
        }
    }
    
    func get_messages_archive() {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_msg_from_management_get_messages_staff_archive, parameters: [:], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") {[weak self] (result: Result<MessageFromManagementResp,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                switch result{
                    
                case .success(let success):
                    
                    if success.status == true {
                        self.messageData?.append(contentsOf: success.data ?? [])
                        self.SearchData = self.messageData
                        self.NoDataLbl.text = success.message
                        self.shouldShowFooterLabel = false
                        self.filterMessages()
                    }else {
                        
                        if self.messageData?.count == 0{
                            
                            self.NoDataImage.isHidden = false
                            self.NoDataLbl.isHidden = false
                            self.NoDataLbl.text = success.message
                        }else{
                            self.archiveMessage = success.message ?? ""
                            self.shouldShowFooterLabel = true
                        }
                       
                    }
                    
                    
                case .failure(let error):
                    
                    if self.messageData?.count == 0{
                        
                        self.NoDataImage.isHidden = false
                        self.NoDataLbl.isHidden = false
                        self.shouldShowFooterLabel = false
                        self.NoDataLbl.text = error.localizedDescription
                    }else{
                        self.archiveMessage = error.localizedDescription
                        self.shouldShowFooterLabel = true
                    }
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
    
    @IBAction func SchoolDropDownAct() {
        guard let schoolDetails = school_details else { return }

        let schoolNames = ["All"] + schoolDetails.compactMap { $0.school_name }

        dropDown.dataSource = schoolNames
        dropDown.anchorView = schoolDropDown
        dropDown.bottomOffset = CGPoint(x: 0, y: schoolDropDown.bounds.height)
        dropDown.show()
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            
            self.schoolName.text = item
            
            if index == 0 {
                self.selectedSchoolId = nil
            } else {
                self.selectedSchoolId = schoolDetails[index - 1].school_id
            }
            
            self.filterMessages()
        }
    }

    
    @IBAction func backAct() {
        dismiss(animated: true)
    }
    
    @IBAction func searchBtnAct(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected{
            SearchBar.isHidden = false
            SearchBar.becomeFirstResponder()
            sender.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        }else{
            SearchBar.isHidden = true
            SearchBar.resignFirstResponder()
            sender.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            SearchBar.searchTextField.text = ""
            searchText = ""
            filterMessages()
        }
    }
    
    func filterMessages() {
        
        guard let allMessages = messageData else {
            SearchData = []
            updateNoDataUI()
            return
        }
        
        SearchData = allMessages.filter { message in
            var matchesSchool = true
            var matchesSearch = true
            
            //School filter
            if let schoolId = selectedSchoolId, schoolId != "All", !schoolId.isEmpty {
                matchesSchool = (message.school_id == schoolId)
            }
            
            //Search filter
            if !searchText.isEmpty {
                let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let dateString = dateFormatter.convertDate(message.date ?? "")?.lowercased()
                
                matchesSearch =
                dateString?.contains(query) == true ||
                message.title?.lowercased().contains(query) == true ||
                message.description?.lowercased().contains(query) == true ||
                message.content?.lowercased().contains(query) == true ||
                message.sender_info?.lowercased().contains(query) == true ||
                message.sent_by?.lowercased().contains(query) == true
            }
            
            return matchesSchool && matchesSearch
        }
        
        updateNoDataUI()
        tv.reloadData()
        
    }
    
    func updateNoDataUI() {
        let isEmpty = (SearchData?.isEmpty ?? true)
        NoDataImage.isHidden = !isEmpty
        NoDataLbl.isHidden = !isEmpty
        NoDataLbl.text = CommonStringFile.No_data_found
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
        
        cell.descrptionLb.text = SearchData?[indexPath.row].description ?? ""
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        // Create a footer view
        let footerView = UIView()
        footerView.backgroundColor = .clear
        
        if shouldShowFooter {
           
            // Create a button instead of a label
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.titleLabel?.textAlignment = .right
            // Create underlined attributed text
            let title = "See Archived Messages"
            let attributedTitle = NSAttributedString(
                string: title,
                attributes: [
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.systemFont(ofSize: 16, weight: .medium)
                ]
            )
            button.setAttributedTitle(attributedTitle, for: .normal)
            
            // Add target action
            button.addTarget(self, action: #selector(seeArchivedMessagesTapped(_:)), for: .touchUpInside)
            
            // Add and constrain
            footerView.addSubview(button)
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(greaterThanOrEqualTo: footerView.leadingAnchor, constant: 16),
                button.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
                button.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 8),
                button.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -8)
            ])
            
        }else if shouldShowFooterLabel{
            
            let label = UILabel()
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = archiveMessage
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textColor = .black
            label.textAlignment = .center
            label.numberOfLines = 0
            
            footerView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
                label.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 20),
                label.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -20),
                label.centerXAnchor.constraint(equalTo: footerView.centerXAnchor)
            ])
        }
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return shouldShowFooter ? 44 : 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    @objc private func seeArchivedMessagesTapped(_ sender: UIButton) {
        print("Archived messages tapped!")

        get_messages_archive()
        
        shouldShowFooter = false
    }
    
    
}

@available(iOS 14.0, *)
extension MessageFromManagementViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchText = searchText
        filterMessages()
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
