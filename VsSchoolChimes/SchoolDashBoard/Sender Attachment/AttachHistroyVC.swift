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
    @IBOutlet weak var createFileBtn: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        localData.editToken = ""
        createFileBtn.layer.cornerRadius = createFileBtn.frame.height / 2
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
        if school_details?.count ?? 0 > 1 {
            schoolDropDownFullview.isHidden = false
                let matchedSchoolName = school_details?
                    .first?
                    .school_name
                schoolName.text = matchedSchoolName ?? "School name not found"
            
            schoolList = school_details?.compactMap { $0.school_name }
            self.dropDown.dataSource = self.schoolList ?? []
        }else{
            schoolDropDownFullview.isHidden = true
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(catagoryTapped))
        schoolDropDown.isUserInteractionEnabled = true
        schoolDropDown.addGestureRecognizer(tapGesture)
//        localData.editToken = staffdetails?.access_token
        searchBar.searchTextField.addDoneButton()
        searchBar.delegate = self
        searchBar.layer.cornerRadius = 5
        searchBar.backgroundImage = UIImage()
        
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
            showActivityLoader()
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
                    self.hideActivityLoader()
                }
                
                switch result {
                case .success(let response):
                    if response.status == true {
                        //                        self.hideView(ishide: true)
                        self.attachmentData = response.data ?? []
                        self.filteredAttachments = response.data
                        self.SearchAttachments = response.data
                        
                        self.tv.isHidden = false
                        self.noDataLabel.isHidden = true
                        self.tv.reloadData()
        
                    } else {
//                                                self.hideView(ishide: false)
                        self.noDataLabel.text = response.message
                        self.tv.isHidden = true
                        self.noDataLabel.isHidden = false
                    }
                    
                case .failure(_):
            
                    self.noDataLabel.text = "Something went wrong"
                    self.tv.isHidden = true
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
                    token: localData.editToken ?? ""
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
        // Find the index of the row to remove
        if let index = filteredAttachments?.firstIndex(where: { $0.id == attachmentId }) {
            
            // Remove the item from arrays
            filteredAttachments?.remove(at: index)
            attachmentData.removeAll(where: { $0.id == attachmentId })
            SearchAttachments?.removeAll(where: { $0.id == attachmentId })
            
            // If no data left
            if filteredAttachments?.isEmpty ?? true {
                noDataLabel.isHidden = false
                noDataLabel.text = "There are no attachments posted yet."
                tv.isHidden = true
            } else {
                noDataLabel.isHidden = true
                tv.isHidden = false
            }
            
            // Animate row deletion properly
            tv.beginUpdates()
            tv.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            tv.endUpdates()
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
