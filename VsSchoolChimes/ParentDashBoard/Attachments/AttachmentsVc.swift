//
//  AttachmentsVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 28/07/25.
//

import UIKit


class AttachmentsVc: UIViewController {
    
    @IBOutlet weak var noRecordStack: UIStackView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var MenuNameLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    
    var attachmentHeaders: [AttachmentHeaderInfo] = []
    var attachmentFiles: [[FilePath]]?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var attachmentData = [Attachment]()
    var filteredAttachments:[Attachment]?
    var SearchAttachments:[Attachment]?
    var isHeaderExpandedDict: [Int: Bool] = [:]
    var search = true
    var isExpanded: Bool = false
    var clickedMessageId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TitleLbl.configureAsBackTitle(firstLine: studentDetails?.name ?? "", secondLine: "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")")
        MenuNameLbl.text = MenuStringFile.selectedMenuName
        searchBar.searchTextField.addDoneButton()
        searchBar.delegate = self
        searchBar.placeholder = CommonStringFile.Search
        searchBar.backgroundImage = UIImage()
        tv.register(
            UINib(nibName: CellConfingName.AttachTvHeader, bundle: nil),
            forHeaderFooterViewReuseIdentifier: CellConfingName.AttachTvHeader
        )
        tv.register(UINib(nibName: CellConfingName.ContentCell, bundle: nil), forCellReuseIdentifier: CellConfingName.ContentCell)
        
        fetchAttachments()
    }
    
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @IBAction func searchBtnCilck(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        searchBar.isHidden = !sender.isSelected
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        searchBtn.setImage(UIImage(systemName: icon), for: .normal)
        if sender.isSelected {
            searchBar.becomeFirstResponder()
        }else{
            searchBar.searchTextField.text = ""
//            filteredAttachments = attachmentHeaders
            tv.reloadData()
            view.endEditing(true)
        }
    }
    
    private func fetchAttachments() {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_communication_attachment_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token:studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<AttachmentsResponse, Error>) in
            
            guard let self = self else { return }
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self.hideActivityLoader()
                }
                
                switch result {
                case .success(let response):
                    if response.status == true {
                        //                        self.hideView(ishide: true)
                        
                        self.noRecordStack.isHidden = true
                        self.noDataLabel.isHidden = true
                        self.tv.isHidden = false
                        self.searchBtn.isHidden = false
                        self.attachmentData = response.data ?? []
                        self.filteredAttachments = response.data
                        self.SearchAttachments = response.data
                        
                        // Separate headers and file_paths
                        self.attachmentHeaders = []
                        self.attachmentFiles = []
                        
                        for item in self.attachmentData {
                            let header = AttachmentHeaderInfo(
                                title: item.title ?? "",
                                description: item.description ?? "",
                                date: item.date ?? "",
                                time: item.time ?? "",
                                sender_info: item.sender_info ?? "", sent_by: item.sent_by, is_unread: item.is_unread ?? false, id: item.id ?? "", headerID: item.header_id ,can_edit: false,can_delete: false
                                
                            )
                            self.attachmentHeaders.append(header)
                            self.attachmentFiles?.append(item.file_path ?? [])
                        }
                        self.tv.delegate = self
                        self.tv.dataSource = self
                        if self.clickedMessageId != ""{
                            self.loadDataAndScrollIfNeeded()
                        }
                        self.tv.reloadData()
                    } else {
                        
                        self.noRecordStack.isHidden = false
                        self.noDataLabel.isHidden = false
                        self.noDataLabel.text = response.message ?? ""
                        self.tv.isHidden = true
                        self.searchBtn.isHidden = true
                    }
                    
                case .failure(_):
                    ""
                }
            }
        }
    }
    
    
    func ReadStatusUpdate(type: String,detail_id: String){
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
            
            switch result {
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    DispatchQueue.main.async { [self] in
                        attachmentHeaders = attachmentHeaders.map { attachment in
                            var updated = attachment
                            if attachment.id == detail_id {
                                updated.is_unread = false
                            }
                            return updated
                        }
                        
                        tv.reloadData()
                    }
                }
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
}

extension AttachmentsVc :  UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return attachmentHeaders.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func scrollToHeaderMessageId(_ messageId: String) {
        // 1. Find section index where header.id == messageId
        
        
        if let targetSection = attachmentHeaders.firstIndex(
            where: { "\($0.headerID ?? "")" == messageId
            }) {
            
            // 2. Scroll after layout is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tv.scrollToRow(
                    at: IndexPath(row: 0, section: targetSection),
                    at: .middle,
                    animated: true
                )
            }
        } else {
            print("⚠️ Message ID \(messageId) not found in attachmentHeaders")
        }
    }
    
    func loadDataAndScrollIfNeeded() {
        // API Call → update attachmentHeaders → reloadData
        tv.reloadData()
        
        if let messageId = clickedMessageId,
           !messageId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            scrollToHeaderMessageId(messageId)
            clickedMessageId = nil
        }
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellConfingName.AttachTvHeader) as? AttachTvHeader else { return nil }
        
        header.configure(with: attachmentHeaders[section])
        
        header.discretpionLbl
            .setupExpandable(
                text: attachmentHeaders[section].description ?? "",
                isExpanded: attachmentHeaders[section].isExpanded)
        
        
        header.discretpionLbl.onExpandableTap = { [weak self] in
            guard let self = self else { return }
            
            let newValue = !header.discretpionLbl.isExpanded
            header.discretpionLbl.isExpanded = newValue
            self.attachmentHeaders[section].isExpanded = newValue
            
                         if self.attachmentHeaders[section].is_unread == true {
                             self.ReadStatusUpdate(
                                 type: "ATTACHMENT",
                                 detail_id: self.attachmentHeaders[section].id ?? "")
                         }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        
        header.layoutIfNeeded()
        
        return header
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ContentCell, for: indexPath) as? ContentCell else {
            return UITableViewCell()
        }
        cell
            .configure(
                with: attachmentFiles?[indexPath.section],
                sendBy: ("Posted By : ") + (
                    attachmentHeaders[indexPath.section].sent_by ?? ""
                )
            )
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ContentCell) as? ContentCell else {
            return 100
        }
        cell
            .configure(
                with: attachmentFiles?[indexPath.section],
                sendBy: ("Posted By : ") + (
                    attachmentHeaders[indexPath.section].sent_by ?? ""
                )
            )
        return cell.collectionContentHeight() + 60
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterAttachments(with: searchText)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            // Called when keyboard is dismissed
            print("Keyboard dismissed for search bar")
            // Do your custom actions here
        }
    
    private func filterAttachments(with searchText: String) {
        if searchText.isEmpty {
            self.filteredAttachments = self.attachmentData
        } else {
            self.filteredAttachments = self.attachmentData.filter { item in
                let titleMatch = item.title?.lowercased().contains(searchText.lowercased()) ?? false
                let descriptionMatch = item.description?.lowercased().contains(searchText.lowercased()) ?? false
                return titleMatch || descriptionMatch
            }
        }
        
        // Rebuild header & file list
        self.attachmentHeaders = []
        self.attachmentFiles = []
        
        if let attachments = self.filteredAttachments {
            for item in attachments {
                let header = AttachmentHeaderInfo(
                    title: item.title ?? "",
                    description: item.description ?? "",
                    date: item.date ?? "",
                    time: item.time ?? "",
                    sender_info: item.sender_info ?? "", sent_by: item.sent_by,
                    is_unread: item.is_unread ?? false,
                    id: item.id ?? "", headerID: item.header_id,
                    can_edit: false,can_delete: false
                )
                self.attachmentHeaders.append(header)
                self.attachmentFiles?.append(item.file_path ?? [])
            }
        }
        
        self.tv.reloadData()
        
        if self.filteredAttachments?.isEmpty ?? true {
            self.noDataLabel.isHidden = false
            self.noDataLabel.text = "No Attachment Found"
            self.tv.isHidden = true
        } else {
            self.noDataLabel.isHidden = true
            self.tv.isHidden = false
        }
    }
}
struct AttachmentHeaderInfo {
    let title: String?
    let description: String?
    let date: String?
    let time: String?
    let sender_info: String?
    let sent_by: String?
    var is_unread: Bool
    let id: String?
    let headerID: String?
    let can_edit: Bool
    let can_delete: Bool
    var isExpanded: Bool = false
}
