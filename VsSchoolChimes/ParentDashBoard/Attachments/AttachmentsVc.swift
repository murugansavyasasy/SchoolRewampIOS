//
//  AttachmentsVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 28/07/25.
//

import UIKit

class AttachmentsVc: UIViewController, Datepicker {
    
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var MenuNameLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var noDataImage: UIImageView!
    @IBOutlet weak var UnreadBtn: UIButton!
    @IBOutlet weak var ReadBtn: UIButton!
    @IBOutlet weak var AllBtn: UIButton!
    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var toDateView: UIView!
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var filterImage: UIImageView!
    @IBOutlet weak var searchStack: UIStackView!
    @IBOutlet weak var filterStack: UIStackView!
    @IBOutlet weak var clearBtn: UIButton!
    
    
    var attachmentFiles: [[FilePath]]?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var attachmentData = [Attachment]()
    var filteredAttachments:[Attachment]?
    var isHeaderExpandedDict: [Int: Bool] = [:]
    var search = true
    var isExpanded: Bool = false
    var clickedMessageId: String?
    var shouldShowFooter = true
    var shouldShowFooterLabel = false
    var ArchiveMessage = ""
    let transitionDelegate = TransitioningDelegate()
    let ATTACHMENT = "ATTACHMENT"
    var isFromDate = false
    var selectedReadStatus: ReadStatus = .all
    var fromDate: Date?
    var toDate: Date?
    var currentSearchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TitleLbl.configureAsBackTitle(firstLine: studentDetails?.name ?? "", secondLine: "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")")
        MenuNameLbl.text = MenuStringFile.selectedMenuName
        SetupUI()
        clearBtn.isHidden = true
        filterStack.isHidden = true
        searchStack.isHidden = true
        searchBar.searchTextField.addDoneButton()
        searchBar.delegate = self
        searchBar.placeholder = CommonStringFile.Search
        searchBar.backgroundImage = UIImage()
        noDataImage.isHidden = true
        noDataLabel.isHidden = true
        tv.register(
            UINib(nibName: CellConfingName.AttachTvHeader, bundle: nil),
            forHeaderFooterViewReuseIdentifier: CellConfingName.AttachTvHeader
        )
        tv.register(UINib(nibName: CellConfingName.ContentCell, bundle: nil), forCellReuseIdentifier: CellConfingName.ContentCell)
        
        tv.delegate = self
        tv.dataSource = self
        
        fetchAttachments()
        
        fromDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectFromDate)))
        toDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectToDate)))
        filterImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShowFilters)))
        filterImage.isUserInteractionEnabled = true
    }
    
    func SetupUI(){
        ReadBtn.layer.cornerRadius = 12
        UnreadBtn.layer.cornerRadius = 12
        AllBtn.layer.cornerRadius = 12
        
        AllBtn.backgroundColor = .systemGreen.withAlphaComponent(0.4)
        
        ReadBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        UnreadBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        AllBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        applyShadowAndCornerRadius(to: fromDateView, cornerRadius: 6)
        applyShadowAndCornerRadius(to: toDateView, cornerRadius: 6)
        toDateLbl.setFont(style: .title, size: FontSize.BodySize)
        fromDateLbl.setFont(style: .title, size: FontSize.BodySize)
        fromDateLbl.textColor = .darkGray
        toDateLbl.textColor = .darkGray
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func searchBtnCilck(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected{
            searchStack.isHidden = false
            //searchBar.becomeFirstResponder()
            sender.setImage(ImageName.magnifyingglass_circle_fill, for: .normal)
        }else{
            searchStack.isHidden = true
            filterStack.isHidden = true
            clearBtn.isHidden = true
            searchBar.resignFirstResponder()
            sender.setImage(ImageName.magnifyingglass, for: .normal)
            noDataImage.isHidden = true
            noDataLabel.isHidden = true
            tv.isScrollEnabled = true
            searchBar.searchTextField.text = ""
            updateFilterButtons(selected: AllBtn)
            selectedReadStatus = .all
            fromDate = nil
            toDate = nil
            fromDateLbl.text = "--From date--"
            toDateLbl.text = "--To date--"
            fromDateLbl.textColor = .darkGray
            toDateLbl.textColor = .darkGray
            filteredAttachments = attachmentData
            tv.reloadData()
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
            token:studentDetails?.access_token ?? "", isBaseUrl: false
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
                    let isEmpty = self.filteredAttachments?.isEmpty ?? false
                    self.searchBtn.isHidden = isEmpty
                    self.noDataImage.isHidden = !isEmpty
                    self.noDataLabel.isHidden = !isEmpty
                    self.tv.isScrollEnabled = !isEmpty
                    self.noDataLabel.text = response.message
                    self.tv.reloadData()
                    
                    if !isEmpty{
                        if self.clickedMessageId != ""{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.scrollToClickedMessage()
                            }}
                    }
                    
                case .failure(let error):
                    self.searchBtn.isHidden = true
                    self.noDataImage.isHidden = false
                    self.noDataLabel.isHidden = false
                    self.tv.isScrollEnabled = false
                    self.noDataLabel.text = error.localizedDescription
                }
            }
        }
    }
    
    private func scrollToClickedMessage() {
        guard let id = clickedMessageId,
              let index = filteredAttachments?.firstIndex(where: { $0.header_id == id }) else {
            return
        }
        let indexPath = IndexPath(row: index, section: 0)
        // Scroll to that cell smoothly
        tv.scrollToRow(at: indexPath, at: .middle, animated: true)
        // Optionally highlight the cell for 1 second
        if let cell = tv.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.3, animations: {
                cell.contentView.backgroundColor = UIColor.lightGray
                    .withAlphaComponent(0.3)
            }) { _ in
                UIView.animate(withDuration: 0.5, delay: 1.0, options: []) {
                    cell.contentView.backgroundColor = .white
                }
            }
        }
    }
    
    private func fetchAttachments_Archive() {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_communication_attachment_list_archive,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token:studentDetails?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<AttachmentsResponse, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self.hideActivityLoader()
                }
                switch result {
                case .success(let response):
                    if response.status == true {
                        self.attachmentData.append(contentsOf: response.data ?? [])
                        self.filteredAttachments = self.attachmentData
                        self.applyFilters()
                        let isEmpty = self.filteredAttachments?.isEmpty ?? false
                        self.searchBtn.isHidden = isEmpty
                        self.noDataImage.isHidden = !isEmpty
                        self.noDataLabel.isHidden = !isEmpty
                        self.tv.isScrollEnabled = !isEmpty
                        self.noDataLabel.text = response.message
                      //  self.tv.reloadData()
                        
                    } else {
                        
                        let isEmpty = self.filteredAttachments?.isEmpty ?? false
                        self.tv.isScrollEnabled = !isEmpty
                        if isEmpty{
                            self.searchBtn.isHidden = isEmpty
                            self.noDataImage.isHidden = !isEmpty
                            self.noDataLabel.isHidden = !isEmpty
                            self.noDataLabel.text = response.message
                        }else{
                            self.ArchiveMessage = response.message ?? ""
                            self.shouldShowFooterLabel = true
                        }
                        self.tv.reloadData()
                    }
                    
                case .failure(let error):
                    let isEmpty = self.filteredAttachments?.isEmpty ?? false
                    
                    if isEmpty{
                        self.searchBtn.isHidden = isEmpty
                        self.noDataImage.isHidden = !isEmpty
                        self.noDataLabel.isHidden = !isEmpty
                        self.noDataLabel.text = error.localizedDescription
                    }else{
                        self.ArchiveMessage = error.localizedDescription
                        self.shouldShowFooterLabel = true
                    }
                    self.tv.reloadData()
                }
            }
        }
    }
    
    func ReadStatusUpdate(type: String, detail_id: String,Endurl: String) {
        APIService.shared.makeApi(
            url: Endurl,
            parameters: [
                ReadStatusUpdateStringFile.type: type,
                ReadStatusUpdateStringFile.detail_id: detail_id
            ],
            type: ApitTypeSringFile.POST,
            token: studentDetails?.access_token ?? "", isBaseUrl: true
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
    
    //MARK: Filter Buttons Actions
    
    @IBAction func ShowFilters(){
        filterStack.isHidden.toggle()
        if filterStack.isHidden {
            clearBtn.isHidden = true
        }else{
            clearBtn.isHidden = !(fromDate != nil || toDate != nil)
        }
    }
    
    private lazy var apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"   // API: 05-01-2026 09:55 AM
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private lazy var pickerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"          // Picker: 05 Jan 2026
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    @IBAction func SelectFromDate(){
        isFromDate = true
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.date = fromDateLbl.text
//        if let maxDate = To_date{
//            vc.maximumDate = maxDate
//        }else{
//            vc.maximumDate = Date()
//        }
        vc.maximumDate = Date()
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func SelectToDate(){
        isFromDate = false
        let vc = DatePickerVC(nibName: nil, bundle: nil)
         vc.dateSelection = 2
          vc.date = toDateLbl.text
          vc.maximumDate = Date()
//        if let minDate = from_date{
//            vc.minimumDate = minDate
//        }
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    func date(date: String) {
        if isFromDate {
            fromDateLbl.text = date
            fromDateLbl.textColor = .black
            fromDate = pickerDateFormatter.date(from: date)
        } else {
            toDateLbl.text = date
            toDateLbl.textColor = .black
            toDate = pickerDateFormatter.date(from: date)
        }
        clearBtn.isHidden = false
        applyFilters()
    }
    
    @IBAction func allAction(_ sender: Any) {
        updateFilterButtons(selected: AllBtn)
        selectedReadStatus = .all
        applyFilters()
    }
    
    @IBAction func readAction(_ sender: Any) {
        updateFilterButtons(selected: ReadBtn)
        selectedReadStatus = .read
        applyFilters()
    }
    
    @IBAction func unreadAction(_ sender: Any) {
        updateFilterButtons(selected: UnreadBtn)
        selectedReadStatus = .unread
        applyFilters()
    }
    
    func updateFilterButtons(selected button: UIButton) {
        [AllBtn, ReadBtn, UnreadBtn].forEach { btn in
            btn?.backgroundColor = (btn == button) ? .systemGreen.withAlphaComponent(0.4) : .white
        }
    }
    
    
    @IBAction func clearBtnAct(_ sender: Any) {
        
        fromDate = nil
        toDate = nil
        fromDateLbl.text = "--From date--"
        toDateLbl.text = "--To date--"
        fromDateLbl.textColor = .darkGray
        toDateLbl.textColor = .darkGray
        applyFilters()
        clearBtn.isHidden = true
    }
    
}

extension AttachmentsVc :  UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAttachments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ContentCell, for: indexPath) as? ContentCell else {
            return UITableViewCell()
        }
        let displayText = filteredAttachments?[indexPath.row].date?.convertToTargetDateFormat() ?? ""//formattedDateStatus(from: filteredAttachments?[indexPath.row].date ?? "")
        cell
            .configureCell(
                with: filteredAttachments?[indexPath.row].file_path ?? [],
                title: filteredAttachments?[indexPath.row].title ?? "",
                description: filteredAttachments?[indexPath.row].description ?? "",
                date: MenuStringFile.posted_on + displayText,
                sendBy:  MenuStringFile.Posted_By + (filteredAttachments?[indexPath.row].sent_by ?? ""),
                isunread: filteredAttachments?[indexPath.row].is_unread ?? false,
                parentTableView: tv
            )
        
        cell.editAndDeleteBtnName.tag = indexPath.row
        cell.edit(
            edit: filteredAttachments?[indexPath.row].can_edit ?? false,
            delete:  filteredAttachments?[indexPath.row].can_delete ?? false,
            selectedId: filteredAttachments?[indexPath.row].id ?? "")
        cell.descriptionLbl
            .setupExpandable(
                text: filteredAttachments?[indexPath.row].description ?? ""
            )
        cell.descriptionLbl.onExpandableTap = {
            let newValue = !cell.descriptionLbl.isExpanded
            cell.descriptionLbl.isExpanded = newValue
            self.filteredAttachments?[indexPath.row].isExpanded = newValue
            
            if self.filteredAttachments?[indexPath.row].is_unread == true {
                if self.filteredAttachments?[indexPath.row].is_archive == true{
                    self.ReadStatusUpdate(
                        type: self.ATTACHMENT,
                        detail_id: self.filteredAttachments?[indexPath.row].id ?? "",
                        Endurl:ServiceUrl.comm_communication_read_status_update_archive
                    )
                }else{
                    self.ReadStatusUpdate(
                        type: self.ATTACHMENT,
                        detail_id: self.filteredAttachments?[indexPath.row].id
                        ?? "",
                        Endurl: ServiceUrl.comm_communication_read_status_update
                    )
                }
                
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        //        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
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
            
        }else if shouldShowFooterLabel {
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = ArchiveMessage
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textColor = .black
            label.textAlignment = .center
            label.numberOfLines = 0
            
            footerView.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
                label.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 15),
                label.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -15),
                label.centerXAnchor.constraint(equalTo: footerView.centerXAnchor)
            ])
        }
        
        return footerView
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard let attach = filteredAttachments?[indexPath.row],
              let cell = tableView.cellForRow(at: indexPath) else { return }
        
        if attach.is_unread == true {
            if attach.is_archive == true{
                self.ReadStatusUpdate(
                    type: ATTACHMENT,
                    detail_id: attach.id ?? "",
                    Endurl:ServiceUrl.comm_communication_read_status_update_archive)
            }else{
                self.ReadStatusUpdate(
                    type: ATTACHMENT,
                    detail_id: attach.id
                    ?? "",
                    Endurl: ServiceUrl.comm_communication_read_status_update)
            }
        }
        
        let cellFrameInSuperview = tableView.convert(cell.frame, to: view)
        let detailVC = PrivewVc()
        detailVC.attachmetList = attach.file_path
        detailVC.selectedDate = attach.date
        detailVC.titleString = attach.title
        detailVC.descriptionString = attach.description
        detailVC.postedBy = attach.sent_by
        detailVC.subject_name = MenuStringFile.selectedMenuName.translated()
        detailVC.modalPresentationStyle = .custom
        transitionDelegate.originFrame = cellFrameInSuperview
        detailVC.transitioningDelegate = transitionDelegate
        present(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (shouldShowFooter || shouldShowFooterLabel) ? UITableView.automaticDimension : 0.01
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    @objc private func seeArchivedMessagesTapped(_ sender: UIButton) {
        searchBar.text = ""
        fetchAttachments_Archive()
        shouldShowFooter = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchText = searchText
        applyFilters()
    }
    
    private func applyFilters() {
        filteredAttachments = attachmentData.filter { item in
            
            // MARK: - Text Filter
            let textMatch: Bool = {
                guard !currentSearchText.isEmpty else { return true }
                let text = currentSearchText.lowercased()
                return (item.title?.lowercased().contains(text) ?? false) ||
                       (item.description?.lowercased().contains(text) ?? false)
            }()
            
            // MARK: - Read / Unread Filter
            let readMatch: Bool = {
                switch selectedReadStatus {
                case .all:
                    return true
                case .read:
                    return item.is_unread == false
                case .unread:
                    return item.is_unread == true
                }
            }()
            
            // MARK: - Date Filter
            let dateMatch: Bool = {
                guard let apiDateString = item.date,
                      let apiDateTime = apiDateFormatter.date(from: apiDateString)
                else { return true }

                let calendar = Calendar.current
                let itemDay = calendar.startOfDay(for: apiDateTime)

                if let from = fromDate,
                   itemDay < calendar.startOfDay(for: from) {
                    return false
                }

                if let to = toDate,
                   itemDay > calendar.startOfDay(for: to) {
                    return false
                }

                return true
            }()
            
            return textMatch && readMatch && dateMatch
        }
        
        reloadTableView()
    }

private func reloadTableView() {
    UIView.performWithoutAnimation {
        tv.reloadData()
        tv.layoutIfNeeded()
    }
    
    let isEmpty = filteredAttachments?.isEmpty ?? true
    noDataLabel.isHidden = !isEmpty
    noDataImage.isHidden = !isEmpty
    tv.isScrollEnabled = !isEmpty
    noDataLabel.text = "No Attachment Found"
}

    
//    private func applyFilters() {
//        if currentSearchText.isEmpty {
//            self.filteredAttachments = self.attachmentData
//        } else {
//            self.filteredAttachments = self.attachmentData.filter { item in
//                let titleMatch = item.title?.lowercased().contains(searchText.lowercased()) ?? false
//                let descriptionMatch = item.description?.lowercased().contains(searchText.lowercased()) ?? false
//                return titleMatch || descriptionMatch
//            }
//        }
//        
//        UIView.performWithoutAnimation {
//            self.tv.reloadData()
//            self.tv.layoutIfNeeded()
//        }
//        
//        if self.filteredAttachments?.isEmpty ?? true {
//            self.noDataLabel.isHidden = false
//            self.noDataImage.isHidden = false
//            self.tv.isScrollEnabled = false
//            self.noDataLabel.text = "No Attachment Found"
//        } else {
//            self.noDataLabel.isHidden = true
//            self.noDataImage.isHidden = true
//            self.tv.isScrollEnabled = true
//            
//        }
//    }
}

