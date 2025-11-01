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

    
    @IBOutlet weak var schoolDropDownFullview: UIView!
    @IBOutlet weak var backBtnName: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var noDataImg: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var schoolDropDown: UIView!
    @IBOutlet weak var menuNameLbl: UILabel!
    
    
   
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
    var Scholldetails = UserDefaultFileManager.getUserDetails()
    let transitionDelegate = TransitioningDelegate()
    var filterSchoolId: String? = "All"
    override func viewDidLoad() {
        super.viewDidLoad()
        localData.editToken = ""
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    
        menuNameLbl.setFont(style: .header, size: FontSize.HeaderSize)
        schoolDropDown.setShadow(cornerRadius: 4)
        
        if checkMutipleSchool() {
            menuNameLbl.text = MenuStringFile.selectedMenuName
        } else {
            let schoolName = UserDefaultFileManager.get_staff_Details()?.school_name ?? ""
            menuNameLbl.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName, secondLine: schoolName)
        }
        
        if staffdetails?.priority_level == PriorityType.is_staff {
            schoolDropDownFullview.isHidden = true
        }else{
            if school_details?.count ?? 0 > 1 {
                
                schoolDropDownFullview.isHidden = false
                let matchedSchoolName = school_details?
                    .first?
                    .school_name
                schoolName.text = "All"
                
                schoolList = school_details?.compactMap { $0.school_name }
                schoolList?.insert("All", at: 0)
                self.dropDown.dataSource = self.schoolList ?? []
            }else{
                schoolDropDownFullview.isHidden = true
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(catagoryTapped))
        schoolDropDown.isUserInteractionEnabled = true
        schoolDropDown.addGestureRecognizer(tapGesture)
        
        searchBar.isHidden = true
        searchBar.searchTextField.addDoneButton()
        searchBar.searchTextField.borderStyle = .none
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.layer.cornerRadius = 8
        searchBar.searchTextField.backgroundColor = .systemGray5
        searchBar.layer.cornerRadius = 8
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.placeholder =  CommonStringFile.Search
        searchBar.delegate = self
        
        tv.delegate = self
        tv.dataSource = self
        tv.register(
                UINib(nibName: "AttachTvHeader", bundle: nil),
                forHeaderFooterViewReuseIdentifier: "AttachTvHeader"
            )
        tv.register(UINib(nibName: "ContentCell", bundle: nil), forCellReuseIdentifier: "ContentCell")
        
        tv.estimatedRowHeight = 100
        tv.rowHeight = UITableView.automaticDimension

//        fetchAttachments()
    }

    
    func checkMutipleSchool() -> Bool {
        let staffCount = Scholldetails?.user_details?.staff_details?.count ?? 0
        if staffCount > 1 {
            switch Scholldetails?.user_details?.staff_details?.first?.priority_level {
            case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                return true
            default:
                return false
            }
        }
        return false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        if staffdetails?.priority_level == PriorityType.is_staff {
            localData.editToken = staffdetails?.access_token ?? ""
            
        }else{
            let enteredSchoolName = schoolName.text ?? "" // உன் compare செய்யும் school name
            if let matchedStaff = school_details?.first(
                where: {
                    ($0.school_name)?.caseInsensitiveCompare(
                        enteredSchoolName
                    ) == .orderedSame
                }),
               let accessToken = matchedStaff.access_token {
                print("Matched access token: \(accessToken)")
                localData.editToken = accessToken
            } else {
                print("No matching school name found.")
            }
        }
        fetchAttachments()
    }
    @objc func catagoryTapped() {
        print("Category View Tapped")
        dropDown.anchorView = schoolDropDown
        dropDown.show()
        dropDown.bottomOffset = CGPoint(x: 0, y: schoolDropDown.bounds.height)
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            schoolName.text = item
            if item == "All"{
                filterSchoolId = "All"
                filterUsingSchoolId("All")
                
            }else{
                if let selectedSchool = school_details?.first(where: { $0.school_name == item }) {
                    filterSchoolId = selectedSchool.school_id ?? ""
                    filterUsingSchoolId(selectedSchool.school_id ?? "")
                    
                }
            }
        }
    }
    
    func filterUsingSchoolId(_ schoolId: String) {
        if schoolId == "All" {
            filteredAttachments = attachmentData
        } else {
            filteredAttachments = attachmentData.filter { $0.school_id == schoolId }
        }
        tv.reloadData()
    }
    func Attachments(withId AttachmentId: String) -> Attachment? {
        return filteredAttachments?.first(where: { $0.id == AttachmentId })
    }
    @IBAction func back(_ sender: Any) {
        
        dismiss(animated: true)
    }
   
    @IBAction func searchBtnCilck(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected{
            filterUsingSchoolId(filterSchoolId ?? "")
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
            sender.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        }else{
            
            searchBar.isHidden = true
            noDataLabel.isHidden = true
            noDataImg.isHidden = true
            searchBar.resignFirstResponder()
            sender.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            searchBar.searchTextField.text = ""
            filterUsingSchoolId(filterSchoolId ?? "")
           
            
        }
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
            showActivityLoader()
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_attachment_report,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: staffdetails?.access_token ?? ""
        ) { [weak self] (result: Result<AttachmentsResponse, Error>) in
            
            guard let self = self else { return }
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self.hideActivityLoader()
                }
                
                switch result {
                case .success(let response):
                        self.attachmentData = response.data ?? []
                        self.filteredAttachments = response.data
                        self.SearchAttachments = response.data
                    self.noDataLabel.isHidden = !(response.data?.isEmpty ?? false)
                    self.noDataImg.isHidden = !(response.data?.isEmpty ?? false)
                        self.tv.reloadData()
                    
                case .failure(_):
                    self.noDataLabel.text = "Something went wrong"
                    self.noDataLabel.isHidden = false
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
                    token: self.staffdetails?.access_token ?? ""
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
        guard let index = filteredAttachments?.firstIndex(where: { $0.id == attachmentId }) else {
            return
        }
        
        // Update data sources
        filteredAttachments?.remove(at: index)
        attachmentData.removeAll(where: { $0.id == attachmentId })
        SearchAttachments?.removeAll(where: { $0.id == attachmentId })
        
        // Animate row deletion
        tv.beginUpdates()
        tv.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        tv.endUpdates()
        
        // Handle empty state after deletion
        let isEmpty = filteredAttachments?.isEmpty ?? true
        if isEmpty {
            noDataLabel.isHidden = false
            noDataImg.isHidden = false
            noDataLabel.text = "There are no attachments posted yet."
        } else {
            noDataLabel.isHidden = true
            noDataImg.isHidden = true
        }
    }
}

extension AttachHistroyVC :  UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
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
        cell.delegate = self
        cell.descriptionLbl
            .setupExpandable(
                text: filteredAttachments?[indexPath.row].description ?? ""
            )
        cell.descriptionLbl.onExpandableTap = {
            cell.descriptionLbl.isExpanded.toggle()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard let attach = filteredAttachments?[indexPath.row],
              let cell = tableView.cellForRow(at: indexPath) else { return }
        
        let cellFrameInSuperview = tableView.convert(cell.frame, to: view)
        
        let detailVC = PrivewVc()
        detailVC.attachmetList = attach.file_path
        detailVC.selectedDate = attach.date
        detailVC.titleString = attach.title
        detailVC.descriptionString = attach.description
        detailVC.postedBy = attach.sent_by
        detailVC.params = [
            "id": attach.id ?? "",
            "target_type" : attach.target_type ?? ""
        ]
        detailVC.EndUrl = ServiceUrl.attachment_target_details
        detailVC.subject_name = MenuStringFile.selectedMenuName.translated()
        detailVC.modalPresentationStyle = .custom
        transitionDelegate.originFrame = cellFrameInSuperview
        detailVC.transitioningDelegate = transitionDelegate
        
        present(detailVC, animated: true)
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterAttachments(with: searchText)
    }
    
    
    private func filterAttachments(with searchText: String) {
        let lowerSearch = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let selectedSchoolId = filterSchoolId ?? "All"
        
        // Step 1: Start from full data
        var results = attachmentData
        
        // Step 2: Apply school filter
        if selectedSchoolId != "All" {
            results = results.filter { $0.school_id == selectedSchoolId }
        }
        
        // Step 3: Apply text search if needed
        if !lowerSearch.isEmpty {
            results = results.filter { item in
                let titleMatch = item.title?.lowercased().contains(lowerSearch) ?? false
                let descriptionMatch = item.description?.lowercased().contains(lowerSearch) ?? false
                return titleMatch || descriptionMatch
            }
        }
        
        // Step 4: Update filtered data
        filteredAttachments = results
        
        // Step 5: Reload table safely without animation
        UIView.performWithoutAnimation {
            tv.reloadData()
            tv.layoutIfNeeded()
        }
        
        // Step 6: Empty state handling
        let isEmpty = filteredAttachments?.isEmpty ?? true
        noDataLabel.isHidden = !isEmpty
        noDataImg.isHidden = !isEmpty
        noDataLabel.text = isEmpty ? "No Attachment Found" : ""
    }



}



