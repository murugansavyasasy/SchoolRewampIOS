//
//  AttachmentsVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 28/07/25.
//

import UIKit


class AttachmentsVc: UIViewController {
    

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tv: UITableView!
   
    var attachmentHeaders: [AttachmentHeaderInfo] = []
    var attachmentFiles: [[FilePath]]?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    
    var attachmentData = [Attachment]()
    var filteredAttachments:[Attachment]?
    var SearchAttachments:[Attachment]?
//    var isHeaderExpanded: Bool = false
    var isHeaderExpandedDict: [Int: Bool] = [:]
    var search = true
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        searchBar.layer.cornerRadius = 5
        tv.register(
                UINib(nibName: "AttachTvHeader", bundle: nil),
                forHeaderFooterViewReuseIdentifier: "AttachTvHeader"
            )
        tv.register(UINib(nibName: "ContentCell", bundle: nil), forCellReuseIdentifier: "ContentCell")
        
//        tableView.register(UINib(nibName: "CustomFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "CustomFooterView")
//        
        
        fetchAttachments()
    }


    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true)
    }
   
    @IBAction func searchBtnCilck(_ sender: Any) {
        
        search.toggle()
        searchBar.isHidden = search
        
    }
    
    private func fetchAttachments() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
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
                    self.hideLottieProgressLoader()
                }
                
                switch result {
                case .success(let response):
                    if response.status == true {
                        //                        self.hideView(ishide: true)
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
                                sender_info: item.sender_info ?? "", is_unread: item.is_unread ?? false, id: item.id ?? ""
                            )
                            self.attachmentHeaders.append(header)
                            self.attachmentFiles?.append(item.file_path ?? [])
                        }
                        self.tv.delegate = self
                        self.tv.dataSource = self
                        self.tv.reloadData()
                    } else {
                        //                        self.hideView(ishide: false)
                        //                        self.NodataLbl.text = response.message
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

    
     func tableView(_ tableView: UITableView,
                                viewForHeaderInSection section: Int) -> UIView? {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AttachTvHeader") as? AttachTvHeader else { return nil }
            header.configure(with: attachmentHeaders[section])
        
         header.discretpionLbl
             .setupExpandable(
                text: attachmentHeaders[section].description ?? ""
             )
         
        
             header.roundView.isHidden = !attachmentHeaders[section].is_unread
         
         header.discretpionLbl.onExpandableTap = { [weak self] in
                 header.discretpionLbl.isExpanded.toggle()
             if self?.attachmentHeaders[section].is_unread == true{
                 self?.ReadStatusUpdate(
                           type: "ATTACHMENT",
                           detail_id: self?.attachmentHeaders[section].id ?? ""
                       )
                   }
                 tableView.beginUpdates()
                 tableView.endUpdates()
             }
         
            return header
        }

      func tableView(_ tableView: UITableView,
                                heightForHeaderInSection section: Int) -> CGFloat {
            return UITableView.automaticDimension
        }

         func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath) as? ContentCell else {
                return UITableViewCell()
            }
             cell
                 .configure(
                    with: attachmentFiles?[indexPath.section],
                    sendBy: ("Posted By : ") + (
                        attachmentHeaders[indexPath.section].sender_info ?? ""
                    )
                 )
            return cell
        }

      func tableView(_ tableView: UITableView,
                                heightForRowAt indexPath: IndexPath) -> CGFloat {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell") as? ContentCell else {
                return 100
            }
          cell
              .configure(
                with: attachmentFiles?[indexPath.section],
                sendBy: ("Posted By : ") + (
                    attachmentHeaders[indexPath.section].sender_info ?? ""
                )
              )
          return cell.collectionContentHeight() + 60
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
                    sender_info: item.sender_info ?? "",
                    is_unread: item.is_unread ?? false,
                    id: item.id ?? ""
                )
                self.attachmentHeaders.append(header)
                self.attachmentFiles?.append(item.file_path ?? [])
            }
        }


        self.tv.reloadData()
    }

}
struct AttachmentHeaderInfo {
    let title: String?
    let description: String?
    let date: String?
    let time: String?
    let sender_info: String?
    var is_unread: Bool
    let id: String?
}
