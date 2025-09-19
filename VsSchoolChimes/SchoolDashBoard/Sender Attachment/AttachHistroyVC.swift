//
//  AttachHistroyVC.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 04/08/25.
//

import UIKit
import DropDown

class AttachHistroyVC: UIViewController, SelectedId {
    func selectId(id: String?, edit: Bool?) {
        if edit ?? false{
            if let selectedEvent = Attachments(withId: id ?? "") {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if #available(iOS 14.0, *) {
                        let vc = SenderAttachmentVC(nibName: nil, bundle: nil)
                        vc.editId = selectedEvent.id
                        vc.Editattachment = selectedEvent
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                }
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.AttachmentDelete(id:id ?? "")
            }
        }
    }

    
    @IBOutlet weak var backBtnName: UIButton!
    @IBOutlet weak var createFileBtn: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var schoolDropDown: UIView!
    var attachmentHeaders: [AttachmentHeaderInfo] = []
    var attachmentFiles: [[FilePath]]?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var attachmentData = [Attachment]()
    var filteredAttachments:[Attachment]?
    var SearchAttachments:[Attachment]?
    var isHeaderExpandedDict: [Int: Bool] = [:]
    var search = true
    var isExpanded: Bool = false
    var selectNotice: EditObjectDelegate?
    var staffdetails = UserDefaultFileManager.get_staff_Details()
    var school_details = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    let dropDown = DropDown()
    var schoolList:[String]?
    let alert = CustomAlert()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createFileBtn.layer.cornerRadius = createFileBtn.frame.height / 2
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
       
        backBtnName
            .configureAsBackButton(
                firstLine: MenuStringFile.selectedMenuName,
                secondLine: staffDetails?.school_name ?? "",
                colour: .white
            )
        
        schoolDropDown.setShadow(cornerRadius: 4)
        if school_details?.count ?? 0 > 1 {
            schoolDropDown.isHidden = false
            if let staffToken = staffdetails?.access_token {
                let matchedSchoolName = school_details?
                    .first(where: { $0.access_token == staffToken })?
                    .school_name

                schoolName.text = matchedSchoolName ?? "School name not found"
            }
            
            schoolList = school_details?.compactMap { $0.school_name }
            self.dropDown.dataSource = self.schoolList ?? []
        }else{
            schoolDropDown.isHidden = true
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(catagoryTapped))
        schoolDropDown.isUserInteractionEnabled = true
        schoolDropDown.addGestureRecognizer(tapGesture)
        localData.editToken = staffdetails?.access_token
        searchBar.searchTextField.addDoneButton()
        searchBar.delegate = self
        searchBar.layer.cornerRadius = 5
        tv.register(
                UINib(nibName: "AttachTvHeader", bundle: nil),
                forHeaderFooterViewReuseIdentifier: "AttachTvHeader"
            )
        tv.register(UINib(nibName: "ContentCell", bundle: nil), forCellReuseIdentifier: "ContentCell")
        
        fetchAttachments()
    }

    @objc func catagoryTapped() {
        print("Category View Tapped")
        dropDown.anchorView = schoolDropDown
        dropDown.show()
        dropDown.bottomOffset = CGPoint(x: 0, y: schoolDropDown.bounds.height)
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            schoolName.text = item
            if let selectedSchool = school_details?.first(where: { $0.school_name == item }) {
             
                localData.editToken = selectedSchool.access_token
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.fetchAttachments()
                }
            }
        }
    }
    func Attachments(withId AttachmentId: String) -> Attachment? {
        return filteredAttachments?.first(where: { $0.id == AttachmentId })
    }
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true)
    }
   
    @IBAction func searchBtnCilck(_ sender: Any) {
        
        search.toggle()
        searchBar.isHidden = search
        
    }
    
    @available(iOS 14.0, *)
    @IBAction func createBtnAct(_ sender: Any) {
        
        let vc = SenderAttachmentVC(nibName: nil, bundle: nil)
         vc.editId = ""
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    private func fetchAttachments() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_attachment_report,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: localData.editToken ?? ""
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
                                
                                sender_info: item.sender_info ?? "", sent_by: item.sent_by, is_unread: item.is_unread ?? false, id: item.id ?? "", headerID: item.header_id, can_edit: item.can_edit ?? false,
                                can_delete: item.can_delete ?? false
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
    
    
    func AttachmentDelete(id: String?) {
        guard let attachmentId = id, !attachmentId.isEmpty else {
            print("Invalid notice ID")
            return
        }
        
        alert.showAlertCancel(
            title: AlertstringFile.Confirm,
            message: AlertstringFile.deletemessage,
            actionLbl1: AlertstringFile.delete,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: {
                APIService.shared.makeApi(
                    url: ServiceUrl.comm_api_attachment_delete,
                    parameters: ["id": attachmentId],
                    type: ApitTypeSringFile.PUT,
                    token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
                ) { [weak self] (result: Result<ResetPasswordSuc, Error>) in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let successResponse):
                            if successResponse.status == true {
                                CustomAlert.showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: successResponse.message ?? "",
                                    on: self
                                ) {
                                    self.removeAttachment(withId: attachmentId)
                                }
                            } else {
                                self.alert.showAlert(
                                    title: AlertstringFile.Failed,
                                    message: successResponse.message ?? "",
                                    on: self
                                )
                            }
                            
                        case .failure(let error):
                            print("Error deleting notice: \(error.localizedDescription)")
                            self.alert.showAlert(title: "Error", message: error.localizedDescription, on: self)
                        }
                    }
                }
            },
            onNo: {
                print("User canceled deletion")
            }
        )
    }
    
    
    
    func removeAttachment(withId attachmentId: String) {
        // Find the index of the section to remove
        if let index = attachmentHeaders.firstIndex(where: { $0.id == attachmentId }) {
            attachmentHeaders.remove(at: index)
            attachmentFiles?.remove(at: index)

            // Optional: Update filtered lists if you’re using search
            filteredAttachments?.removeAll(where: { $0.id == attachmentId })
            SearchAttachments?.removeAll(where: { $0.id == attachmentId })
            
            // Reload tableView section
            tv.beginUpdates()
            tv.deleteSections(IndexSet(integer: index), with: .fade)
            tv.endUpdates()
        }
    }


    
}

extension AttachHistroyVC :  UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
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
                 text: attachmentHeaders[section].description ?? "",
                 isExpanded: attachmentHeaders[section].isExpanded
             )
        
         header
             .edit(
                edit: attachmentHeaders[section].can_edit,
                delete:  attachmentHeaders[section].can_delete,
                selectedId: attachmentHeaders[section].id ?? ""
             )
         
         header.delegate = self
         header.discretpionLbl.onExpandableTap = { [weak self] in
             guard let self = self else { return }

             let newValue = !header.discretpionLbl.isExpanded
             header.discretpionLbl.isExpanded = newValue
             self.attachmentHeaders[section].isExpanded = newValue

//             if self.attachmentHeaders[section].is_unread == true {
//                 self.ReadStatusUpdate(
//                     type: "ATTACHMENT",
//                     detail_id: self.attachmentHeaders[section].id ?? "")
//             }

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath) as? ContentCell else {
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell") as? ContentCell else {
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
                    sender_info:  "", sent_by: item.sent_by,
                    is_unread: item.is_unread ?? false,
                    id: item.id ?? "", headerID: item.header_id,
                    can_edit: item.can_edit ?? false,
                    can_delete: item.can_delete ?? false
                    
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
