//
//  MessageFromManagementViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/17/24.
//

import UIKit
import DropDown

// MARK: - Protocols
protocol ReadUpdatesManagement: AnyObject {
    func readStatusManagement(attachment: ManagemantMessageData)
}

protocol ViewAttachments: AnyObject {
    func viewAttachment(sender: UIButton)
    func dismiss( _: Bool)
}

// MARK: - MessageFromManagementViewController
@available(iOS 14.0, *)
class MessageFromManagementViewController: UIViewController {
    
    // MARK: - IBOutlets
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
    
    // MARK: - Properties
    private var popoverOverlayView: UIView?
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    var school_details = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    private var messageData: [ManagemantMessageData] = []
    private var filteredData: [ManagemantMessageData] = []
    private let dateFormatter = DateFormatter()
    
    private var shouldShowFooter = true
    private var shouldShowFooterLabel = false
    private var archiveMessage = ""
    private var playIndex: Int?
    
    private let dropDown = DropDown()
    private var searchText = ""
    private var selectedSchoolId: String?
    var Pushnotification_msgId : String?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupSearchBar()
        setupSchoolDropDown()
        fetchMessages()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        menuNameLbl.text = MenuStringFile.selectedMenuName
        menuNameLbl.setFont(style: .header, size: FontSize.HeaderSize)
        BackBtn.applyBackButton()
        NoDataLbl.setFont(style: .title, size: FontSize.HeaderSize)
        
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        FilterCV.isHidden = true
        updateNoDataUI(isEmpty: true)
    }
    
    private func setupTableView() {
        tv.register(UINib(nibName: "MsgTvCell", bundle: nil),
                   forCellReuseIdentifier: "MsgTvCell")
        tv.register(UINib(nibName: CellConfingName.MessageFromManagementTableViewCell, bundle: nil),
                   forCellReuseIdentifier: CellConfingName.MessageFromManagementTableViewCell)
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 100
    }
    
    private func setupSearchBar() {
        SearchBar.isHidden = true
        SearchBar.searchTextField.addDoneButton()
        SearchBar.placeholder = CommonStringFile.Search
        SearchBar.backgroundImage = UIImage()
        SearchBar.delegate = self
    }
    
    private func setupSchoolDropDown() {
        schoolDropDown.setShadow(cornerRadius: 4)
        schoolDropDown.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(showSchoolDropDown))
        )
        schoolDropDown.isUserInteractionEnabled = true
        schoolDropDown.isHidden = !hasMultipleSchools()
    }
    
    // MARK: - Business Logic
    private func hasMultipleSchools() -> Bool {
        guard let details = school_details, details.count > 1 else { return false }
        
        switch details.first?.priority_level {
        case PriorityType.is_principal,
             PriorityType.is_grouphead,
             PriorityType.is_admin:
            return true
        default:
            return false
        }
    }
    
    private func filterMessages() {
        filteredData = messageData.filter { message in
            let matchesSchool = selectedSchoolId == nil || message.school_id == selectedSchoolId
            let matchesSearch = searchText.isEmpty || matchesSearchQuery(message)
            return matchesSchool && matchesSearch
        }
        
//        print("filteredDatafilteredData",filteredData.)
        updateNoDataUI(isEmpty: filteredData.isEmpty)
        tv.reloadData()
    }
    
    private func matchesSearchQuery(_ message: ManagemantMessageData) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let searchableFields = [
            dateFormatter.convertDate(message.date ?? ""),
            message.title,
            message.description,
            message.content,
            message.sender_info,
            message.sent_by
        ].compactMap { $0?.lowercased() }
        
        return searchableFields.contains { $0.contains(query) }
    }
    
    private func updateNoDataUI(isEmpty: Bool) {
        NoDataImage.isHidden = !isEmpty
        NoDataLbl.isHidden = !isEmpty
        if isEmpty {
            NoDataLbl.text = CommonStringFile.No_data_found
        }
    }
    
    // MARK: - API Calls
    private func fetchMessages() {
        let token = staffDetails?.access_token ?? ""
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_msg_from_management_get_messages_staff,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: token
        ) { [weak self] (result: Result<MessageFromManagementResp, Error>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let response):
                    self.messageData = response.data ?? []
                    self.filteredData = self.messageData
                    
                    if self.filteredData.isEmpty{
                        
                        self.searchBtn.isHidden = true
                        self.NoDataImage.isHidden = false
                        self.NoDataLbl.isHidden = false
                        self.schoolDropDown.isHidden = true
                    }else{
                        
                        self.searchBtn.isHidden = false
                        self.NoDataImage.isHidden = true
                        self.NoDataLbl.isHidden = true
                        self.schoolDropDown.isHidden = !self.hasMultipleSchools()
                        
                        if self.Pushnotification_msgId != ""{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.scrollToClickedMessage()
                            }

                        }
                    }
                    
                    self.NoDataLbl.text = response.message
                    
                case .failure(let error):
                    self.NoDataLbl.text = error.localizedDescription
                    self.searchBtn.isHidden = true
                    self.schoolDropDown.isHidden = true
                    self.NoDataImage.isHidden = false
                    self.NoDataLbl.isHidden = false
                }
                
                self.tv.reloadData()
            }
        }
    }
    
    private func scrollToClickedMessage() {
        guard let id = Pushnotification_msgId,
              let index = filteredData.firstIndex(where: { $0.header_id == id }) else {
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
    private func fetchArchivedMessages() {
        
        SearchBar.searchTextField.text = ""
        searchText = ""
        let token = staffDetails?.access_token ?? ""
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_msg_from_management_get_messages_staff_archive,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: token
        ) { [weak self] (result: Result<MessageFromManagementResp, Error>) in
           
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                switch result{
                case .success(let response):
                    self.messageData.append(contentsOf: response.data ?? [])
                    let hidden = self.messageData.isEmpty
                    self.searchBtn.isHidden = hidden
                    
                    if self.messageData.isEmpty{
                        self.SearchBar.isHidden = true
                        self.schoolDropDown.isHidden = true
                        self.shouldShowFooterLabel = false
                    }else{
                        self.schoolDropDown.isHidden = !self.hasMultipleSchools()
                        self.shouldShowFooterLabel = !(response.status ?? false)
                    }
                    
                    self.filterMessages()
                    self.NoDataLbl.text = response.message ?? ""
                    self.archiveMessage = response.message ?? ""
                    
                case .failure(let error):
                    let hidden = self.messageData.isEmpty
                    self.searchBtn.isHidden = hidden
                    self.filterMessages()
                    self.shouldShowFooterLabel = true
                    self.archiveMessage = error.localizedDescription
                }
                self.shouldShowFooter = false
                self.tv.reloadData()
            }
        }
    }
    
    private func updateReadStatus(type: String, detailId: String, isArchived: Bool) {
        let url = isArchived ?
            ServiceUrl.comm_communication_read_status_update_archive :
            ServiceUrl.comm_communication_read_status_update
        
        let parameters = [
            ReadStatusUpdateStringFile.type: type,
            ReadStatusUpdateStringFile.detail_id: detailId
        ]
        
        APIService.shared.makeApi(
            url: url,
            parameters: parameters,
            type: ApitTypeSringFile.POST,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<ReadStatusResponse, Error>) in
            self?.handleReadStatusResponse(result, detailId: detailId)
        }
    }
    
    // MARK: - Response Handlers
    private func handleMessagesResponse(_ result: Result<MessageFromManagementResp, Error>) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.messageData = response.data ?? []
                self.filteredData = self.messageData
                self.updateNoDataUI(isEmpty: self.messageData.isEmpty)
                if self.messageData.isEmpty {
                    self.NoDataLbl.text = response.message
                    self.searchBtn.isHidden = true
                }
                
            case .failure(let error):
                self.updateNoDataUI(isEmpty: true)
                self.NoDataLbl.text = error.localizedDescription
                self.searchBtn.isHidden = true
            }
            
            self.tv.reloadData()
        }
    }
    
    private func handleArchivedMessagesResponse(_ result: Result<MessageFromManagementResp, Error>) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.status == true {
                    self.messageData.append(contentsOf: response.data ?? [])
                    self.shouldShowFooterLabel = false
                    self.SearchBar.searchTextField.text = ""
                    self.searchText = ""
                    self.filterMessages()
                    self.shouldShowFooter = false
                } else {
                    self.handleEmptyArchive(message: response.message ?? "")
                    self.searchBtn.isHidden = true
                }
                
            case .failure(let error):
                self.handleEmptyArchive(message: error.localizedDescription)
                self.searchBtn.isHidden = true
            }
            
           
            self.tv.reloadData()
        }
    }
    
    private func handleEmptyArchive(message: String) {
        if messageData.isEmpty {
            updateNoDataUI(isEmpty: true)
            NoDataLbl.text = message
        } else {
            archiveMessage = message
            shouldShowFooterLabel = true
        }
    }
    
    private func handleReadStatusResponse(_ result: Result<ReadStatusResponse, Error>, detailId: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if case .success(let response) = result, response.status == true {
                self.updateMessageReadStatus(detailId: detailId)
            }
        }
    }
    
    private func updateMessageReadStatus(detailId: String) {
        for (index, message) in filteredData.enumerated() where message.id == detailId {
            filteredData[index].is_unread = false
            messageData[index].is_unread = false
        }
        tv.reloadData()
    }
    
    // MARK: - Helper Methods
    private func shortName(from name: String) -> String {
        let trimmed = name.replacingOccurrences(of: " ", with: "")
        guard let first = trimmed.first, let last = trimmed.last else { return "" }
        return "\(first)\(last)".uppercased()
    }
    
    private func formattedDateStatus(from dateString: String) -> String {
        return dateFormatter.convertDate(dateString) ?? ""
    }
    
    // MARK: - Actions
    @IBAction private func backAct() {
        dismiss(animated: true)
    }
    
    @IBAction private func searchBtnAct(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        let imageName = sender.isSelected ?
            "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
        
        SearchBar.isHidden = !sender.isSelected
        
        if sender.isSelected {
            SearchBar.becomeFirstResponder()
        } else {
            SearchBar.resignFirstResponder()
            SearchBar.searchTextField.text = ""
            searchText = ""
            filterMessages()
        }
    }
    
    @objc private func showSchoolDropDown() {
        guard let details = school_details else { return }
        
        let schoolNames = ["All"] + details.compactMap { $0.school_name }
        
        dropDown.dataSource = schoolNames
        dropDown.anchorView = schoolDropDown
        dropDown.bottomOffset = CGPoint(x: 0, y: schoolDropDown.bounds.height)
        
        dropDown.selectionAction = { [weak self] (index, item) in
            
            self?.SearchBar.searchTextField.text = ""
            self?.searchText = ""
            self?.handleSchoolSelection(index: index, item: item, schoolDetails: details)
        }
        
        dropDown.show()
    }
    
    private func handleSchoolSelection(index: Int, item: String, schoolDetails: [StaffDetails]) {
        schoolName.text = item
        selectedSchoolId = index == 0 ? nil : schoolDetails[index - 1].school_id
        filterMessages()
    }
    
    @objc private func seeArchivedMessagesTapped(_ sender: UIButton) {
        fetchArchivedMessages()
    }
}

// MARK: - UITableViewDataSource
@available(iOS 14.0, *)
extension MessageFromManagementViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MsgTvCell", for: indexPath) as? MsgTvCell else {
            return UITableViewCell()
        }
        
        let message = filteredData[indexPath.row]
        configureCell(cell, with: message, at: indexPath.row)
        return cell
    }
    
    private func configureCell(_ cell: MsgTvCell, with message: ManagemantMessageData, at index: Int) {
        let displayText = formattedDateStatus(from: message.date ?? "")
        
        cell.senderNamelbl.text = message.sent_by
        cell.timeAndDateLbl.text = "\(displayText)  \(message.time ?? "")"
        cell.titleLbl.text = message.title
        cell.descrptionLb.text = message.description
        cell.descrptionLb.isHidden = message.description?.isEmpty ?? true
        cell.alphbetLbl.text = shortName(from: message.sent_by ?? "")
        cell.readView.isHidden = !(message.is_unread ?? false)
        cell.rollBtn.setTitle(message.role?.capitalized, for: .normal)
        cell.viewBtn.tag = index
        cell.delegate = self
    }
}

// MARK: - UITableViewDelegate
@available(iOS 14.0, *)
extension MessageFromManagementViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        
        if shouldShowFooter {
            addArchiveButton(to: footerView)
        } else if shouldShowFooterLabel {
            addArchiveLabel(to: footerView)
        }
        
        return footerView
    }
    
    private func addArchiveButton(to view: UIView) {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let attributedTitle = NSAttributedString(
            string: "See Archived Messages",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.systemBlue,
                .font: UIFont.systemFont(ofSize: 16, weight: .medium)
            ]
        )
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(seeArchivedMessagesTapped(_:)), for: .touchUpInside)
        
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
    }
    
    private func addArchiveLabel(to view: UIView) {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = archiveMessage
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (shouldShowFooter || shouldShowFooterLabel) ? UITableView.automaticDimension : 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: - UISearchBarDelegate
@available(iOS 14.0, *)
extension MessageFromManagementViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        filterMessages()
    }
}

// MARK: - ViewAttachments
@available(iOS 14.0, *)
extension MessageFromManagementViewController: ViewAttachments {
    func dismiss(_: Bool) {
        removePopoverOverlay()
    }
    
    
    func viewAttachment(sender: UIButton) {
        guard sender.tag < filteredData.count else { return }
        let message = filteredData[sender.tag]
        
        presentPopover(with: message)
        updateReadStatusIfNeeded(for: message)
    }
    
    private func presentPopover(with message: ManagemantMessageData) {
        let popoverVC = MsgViewVC()
        popoverVC.modalPresentationStyle = .popover
        popoverVC.MsgFromManagmentData = message
        popoverVC.file_path = message.file_path
        popoverVC.delegate = self
        
        popoverVC.loadViewIfNeeded()
        popoverVC.view.layoutIfNeeded()
        
        let scrollContentHeight = popoverVC.scrollView.contentSize.height
        let paddingX: CGFloat = 20
        let width = view.frame.width - (paddingX * 2)
        let height = min(scrollContentHeight, view.frame.height)
        
        popoverVC.preferredContentSize = CGSize(width: width, height: height)
        
        let originX = (view.frame.width - width) / 2
        let originY = (view.frame.height - height) / 2
        let sourceRect = CGRect(x: originX, y: originY, width: width, height: height)
        
        addPopoverOverlay()
        
        if let popover = popoverVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.backgroundColor = .white
            popover.sourceRect = sourceRect
            popover.permittedArrowDirections = []
            popover.delegate = self
        }
        
        present(popoverVC, animated: true)
    }
    
    private func updateReadStatusIfNeeded(for message: ManagemantMessageData) {
        guard let type = message.type, let id = message.id else { return }
        updateReadStatus(type: type, detailId: id, isArchived: message.is_archive ?? false)
    }
}

// MARK: - TextExpandCellDelegate
@available(iOS 14.0, *)
extension MessageFromManagementViewController: TextExpandCellDelegate {
    
    func didTapExpand(in cell: TextHistoryTVCell) {
        guard let indexPath = tv.indexPath(for: cell) else { return }
        guard indexPath.row < filteredData.count else { return }
        
        var message = filteredData[indexPath.row]
        message.isExpand = !(message.isExpand ?? false)
        filteredData[indexPath.row] = message
        
        if message.is_unread == true, let type = message.type, let id = message.id {
            updateReadStatus(type: type, detailId: id, isArchived: message.is_archive ?? false)
            filteredData[indexPath.row].is_unread = false
            cell.NewImageView.isHidden = true
        }
        
        tv.performBatchUpdates({
            tv.reloadRows(at: [indexPath], with: .automatic)
        }, completion: nil)
    }
}

// MARK: - ReadUpadesManagemant
@available(iOS 14.0, *)
extension MessageFromManagementViewController: ReadUpdatesManagement {
    
    func readStatusManagement(attachment: ManagemantMessageData) {
        guard let type = attachment.type, let id = attachment.id else { return }
        updateReadStatus(type: type, detailId: id, isArchived: attachment.is_archive ?? false)
    }
}

// MARK: - ReloadDelegate
@available(iOS 14.0, *)
extension MessageFromManagementViewController: reloadDelegate {
    
    func deleteDelegate(index: Int) {
        // Implementation for delete if needed
    }
    
    func reload(index: Int) {
        guard index < filteredData.count else { return }
        
        if let currentIndex = playIndex, currentIndex != index {
            let previousIndexPath = IndexPath(row: currentIndex, section: 0)
            if let previousCell = tv.cellForRow(at: previousIndexPath) as? HistoryTC {
                previousCell.updatePlayState(isPlaying: false, url: nil)
            }
        }
        
        playIndex = (playIndex == index) ? nil : index
        var message = filteredData[index]
        
        if message.is_unread == true, let type = message.type, let id = message.id {
            updateReadStatus(type: type, detailId: id, isArchived: message.is_archive ?? false)
            message.is_unread = false
            filteredData[index] = message
        }
        
        tv.reloadData()
    }
}
@available(iOS 14.0, *)
extension MessageFromManagementViewController {
    
    private func addPopoverOverlay() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        let overlay = UIView(frame: window.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.alpha = 0

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopoverOverlay))
        overlay.addGestureRecognizer(tapGesture)

        window.addSubview(overlay)
        popoverOverlayView = overlay

        UIView.animate(withDuration: 0.2) {
            overlay.alpha = 1
        }
    }

    @objc private func dismissPopoverOverlay() {
        removePopoverOverlay()
        dismiss(animated: true)
    }

    private func removePopoverOverlay() {
        guard let overlay = popoverOverlayView else { return }

        UIView.animate(withDuration: 0.2, animations: {
            overlay.alpha = 0
        }, completion: { _ in
            overlay.removeFromSuperview()
            self.popoverOverlayView = nil
        })
    }
}

@available(iOS 14.0, *)
extension MessageFromManagementViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        removePopoverOverlay()
    }
}
