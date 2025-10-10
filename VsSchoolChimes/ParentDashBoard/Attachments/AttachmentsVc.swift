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
                        
                    
                        if self.clickedMessageId != ""{
                            self.loadDataAndScrollIfNeeded()
                        }
                        self.tv.delegate = self
                        self.tv.dataSource = self
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
    
    
    func ReadStatusUpdate(type: String, detail_id: String) {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_communication_read_status_update,
            parameters: [
                ReadStatusUpdateStringFile.type: type,
                ReadStatusUpdateStringFile.detail_id: detail_id
            ],
            type: ApitTypeSringFile.POST,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<ReadStatusResponse, Error>) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let successMessage):
                if successMessage.status == true {
                    DispatchQueue.main.async {
                        // ✅ Safely unwrap the optional array
                        self.filteredAttachments = self.filteredAttachments?.map { attachment in
                            var updated = attachment
                            if attachment.id == detail_id {
                                updated.is_unread = false
                            }
                            return updated
                        }
                        self.tv.reloadData()
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
    
  
    
    func scrollToHeaderMessageId(_ messageId: String) {
        // 1. Find section index where header.id == messageId
        
        
        if let targetSection = filteredAttachments?.firstIndex(
            where: { "\($0.id ?? "")" == messageId
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
    
//    func tableView(_ tableView: UITableView,
//                   viewForHeaderInSection section: Int) -> UIView? {
//        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellConfingName.AttachTvHeader) as? AttachTvHeader else { return nil }
//        
//        header.configure(with: attachmentHeaders[section])
//        
//        header.discretpionLbl
//            .setupExpandable(
//                text: attachmentHeaders[section].description ?? "",
//                isExpanded: attachmentHeaders[section].isExpanded)
//        
//        
//        header.discretpionLbl.onExpandableTap = { [weak self] in
//            guard let self = self else { return }
//            
//            let newValue = !header.discretpionLbl.isExpanded
//            header.discretpionLbl.isExpanded = newValue
//            self.attachmentHeaders[section].isExpanded = newValue
//            
//                         if self.attachmentHeaders[section].is_unread == true {
//                             self.ReadStatusUpdate(
//                                 type: "ATTACHMENT",
//                                 detail_id: self.attachmentHeaders[section].id ?? "")
//                         }
//            
//            tableView.beginUpdates()
//            tableView.endUpdates()
//        }
//        
//        header.layoutIfNeeded()
//        
//        return header
//    }
//    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAttachments?.count ?? 0
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath) as? ContentCell else {
            return UITableViewCell()
        }
        let displayText = formattedDateStatus(from: filteredAttachments?[indexPath.row].date ?? "")
        cell
            .configureCell(
                with: filteredAttachments?[indexPath.row].file_path ?? [],
                title: filteredAttachments?[indexPath.row].title ?? "",
                description: filteredAttachments?[indexPath.row].description ?? "",
                date: "Posted on : " + displayText,
                sendBy:  "Posted by :  " + (filteredAttachments?[indexPath.row].sent_by ?? ""),
                isunread: filteredAttachments?[indexPath.row].is_unread ?? false,
                parentTableView: tv
            )
        
        cell.editAndDeleteBtnName.tag = indexPath.row
        cell
            .edit(
                edit: filteredAttachments?[indexPath.row].can_edit ?? false,
                delete:  filteredAttachments?[indexPath.row].can_delete ?? false,
                selectedId: filteredAttachments?[indexPath.row].id ?? ""
                   )
//        cell.delegate = self
        cell.descriptionLbl
            .setupExpandable(
                text: filteredAttachments?[indexPath.row].description ?? ""
            )
        cell.descriptionLbl.onExpandableTap = {
//            cell.descriptionLbl.isExpanded.toggle()
            
            let newValue = !cell.descriptionLbl.isExpanded
            cell.descriptionLbl.isExpanded = newValue
            self.filteredAttachments?[indexPath.row].isExpanded = newValue
            
                         if self.filteredAttachments?[indexPath.row].is_unread == true {
                             self.ReadStatusUpdate(
                                 type: "ATTACHMENT",
                                 detail_id: self.filteredAttachments?[indexPath.row].id ?? "")
                         }
            tableView.beginUpdates()
            tableView.endUpdates()
        }
//        cell.layoutIfNeeded()
        return cell
    }
    

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterAttachments(with: searchText)
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
        
        UIView.performWithoutAnimation {
            self.tv.reloadData()
            self.tv.layoutIfNeeded()
        }

        
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

