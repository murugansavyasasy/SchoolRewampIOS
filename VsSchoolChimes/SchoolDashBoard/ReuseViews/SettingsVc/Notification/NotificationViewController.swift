//
//  NotificationViewController.swift
//  SchoolchimesDemo
//
//  Created by chandhru on 29/10/25.
//

import UIKit

@available(iOS 14.0, *)
class NotificationViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var clearAllBtn: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var noDataImg: UIImageView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    
    // MARK: - Variables
    let MenuRedirect = MenuRedirectHandler.shared
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var tvheadernotidata: [notificationData] = []
    var allNotifications: [notificationData] = [] // For search
    var token: String = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNotification()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        BackBtn.setTitle(MenuTapbar.shared.Notifications, for: .normal)
        
        let Language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
        BackBtn.semanticContentAttribute = Language == "ar" ? .forceRightToLeft : .forceLeftToRight
        BackBtn.contentHorizontalAlignment = Language == "ar" ? .right : .left
        BackBtn.imageView?.applyRTLFlip(Language == "ar")
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        
        searchBar.searchTextField.borderStyle = .none
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.layer.cornerRadius = 8
        searchBar.searchTextField.backgroundColor = .white
        searchBar.layer.cornerRadius = 8
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.isHidden = true
        
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    private func registerCells() {
        let cellNib = UINib(nibName: "NotificationsTvCell", bundle: nil)
        tableview.register(cellNib, forCellReuseIdentifier: "NotificationsTvCell")
        
        let headerNib = UINib(nibName: "NotiTvheader", bundle: nil)
        tableview.register(headerNib, forHeaderFooterViewReuseIdentifier: "NotiTvheader")
    }
    
    // MARK: - Actions
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Clear All
    @IBAction func clearAllMessage(_ sender: UIButton) {
        guard !tvheadernotidata.isEmpty else { return }
        
        let alert = UIAlertController(title: "Clear All Notifications",
                                      message: "Are you sure you want to delete all notifications?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { _ in
            self.clearAllNotifications()
        }))
        self.present(alert, animated: true)
    }
    
    private func clearAllNotifications() {
        let allIds = tvheadernotidata.flatMap { $0.details?.compactMap { $0.id } ?? [] }
        guard !allIds.isEmpty else { return }
        
        clearNotification(id: allIds) { [weak self] _ in
            guard let self = self else { return }
            self.tvheadernotidata.removeAll()
            self.allNotifications.removeAll()
            self.tableview.reloadData()
            
            self.noDataImg.isHidden = false
            self.noDataLbl.isHidden = false
            self.noDataLbl.text = "No notifications found"
            self.searchView.isHidden = true
            self.searchBtn.isHidden = true
            self.searchBar.isHidden = true
        }
    }
    
    // MARK: - Search
    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        
        if sender.isSelected {
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
        } else {
            searchBar.text = ""
            searchBar.resignFirstResponder()
            searchBar.isHidden = true
            tvheadernotidata = allNotifications
            tableview.reloadData()
            noDataImg.isHidden = !tvheadernotidata.isEmpty
            noDataLbl.isHidden = !tvheadernotidata.isEmpty
        }
    }
}

// MARK: - TableView Delegate / DataSource
@available(iOS 14.0, *)
extension NotificationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tvheadernotidata.count
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        guard tvheadernotidata.indices.contains(section),
              let name = tvheadernotidata[section].menu_id,
              !tvheadernotidata.isEmpty else {
            return nil
        }
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "NotiTvheader") as? NotiTvheader else {
            return nil
        }
        
        let filteredItems = MenuRedirectHandler.shared.Imgitems.filter { $0.id == name }
        header.MenuImage.image = UIImage(named: filteredItems.first?.name ?? "")
        header.menuNameLbl.text = tvheadernotidata[section].menu_name
        return header
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return tvheadernotidata[section].details?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsTvCell", for: indexPath) as? NotificationsTvCell else {
            return UITableViewCell()
        }
        
        let detail = tvheadernotidata[indexPath.section].details?[indexPath.row]
        cell.sentbyLbl.text = detail?.name ?? ""
        cell.messageLbl.text = detail?.message ?? ""
        cell.typeLbl.text = detail?.type ?? ""
        cell.dateLbl.text = detail?.sent_on?.convertToTargetDateFormat() ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleMenuNavigation(indexPath: indexPath)
    }
    
    // MARK: Swipe to Delete
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            
            let alert = UIAlertController(title: "Delete Notification",
                                          message: "Are you sure you want to delete this notification?",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                self.handleDelete(at: indexPath)
                completionHandler(true)
            })
            self.present(alert, animated: true)
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    // MARK: Delete Logic
    private func handleDelete(at indexPath: IndexPath) {
        guard let deleteId = tvheadernotidata[indexPath.section].details?[indexPath.row].id else { return }
        
        clearNotification(id: [deleteId]) { [weak self] _ in
            guard let self = self else { return }
            self.tvheadernotidata[indexPath.section].details?.remove(at: indexPath.row)
            
            if self.tvheadernotidata[indexPath.section].details?.isEmpty == true {
                self.tvheadernotidata.remove(at: indexPath.section)
                self.tableview.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            } else {
                self.tableview.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    // MARK: Navigation Handling
    private func handleMenuNavigation(indexPath: IndexPath) {
        let menuItem = tvheadernotidata[indexPath.section].details?[indexPath.row].menu_id
        if let menuName = tvheadernotidata.first(where: { $0.menu_id == menuItem })?.menu_name {
            MenuStringFile.selectedMenuName = menuName
        }
        
        switch menuItem {
        case 2:  MenuRedirect.receiverAssignmentNavigate(from: self)
        case 4:  MenuRedirect.receiverAttendancereport(from: self)
        case 5:  MenuRedirect.receiverCertificateRequest(from: self)
        case 6:  MenuRedirect.receiverclassTimeTable(from: self)
        case 7:  MenuRedirect.receiverCommunicationNavigate(from: self)
        case 9:  MenuRedirect.receiverEvent(from: self)
        case 10: MenuRedirect.resiverExamMark(from: self)
        case 12: MenuRedirect.receiverFeeDetails(from: self)
        case 15: MenuRedirect.receiverHomework(from: self)
        case 16: MenuRedirect.receiverchat(from: self)
        case 20: MenuRedirect.receiverLsrwNavigate(from: self)
        case 23: MenuRedirect.receiverNoticeBoardNavigate(from: self)
        case 24: MenuRedirect.receiverOnlineNavigate(from: self)
        case 25: MenuRedirect.receiverFeeDetails(from: self)
        case 26: MenuRedirect.receiverPtmNavigate(from: self)
        case 27: MenuRedirect.QuizExam(from: self)
        case 28: MenuRedirect.LeaveRquest(from: self)
        case 36: MenuRedirect.senderImportantInfoNavigate(from: self)
        case 39:
            MenuRedirect.receiverAttachment(
                from: self,
                notificationId: tvheadernotidata[indexPath.section].details?[indexPath.row].header_id ?? ""
            )
        case 40: MenuRedirect.receiverPauckt(from: self)
        default: break
        }
    }
    
    // MARK: API Calls
    func getNotification() {
        if #available(iOS 15.0, *) { showActivityLoader() }
        
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_notifications,
            parameters: ["device_type": "Iphone"],
            type: ApitTypeSringFile.GET,
            token: token
        ) { [weak self] (result: Result<notificationSuc, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) { self?.hideActivityLoader() }
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.tvheadernotidata = response.data ?? []
                    self.allNotifications = self.tvheadernotidata
                    self.tableview.reloadData()
                    
                    let isEmpty = self.tvheadernotidata.isEmpty
                    self.noDataImg.isHidden = !isEmpty
                    self.noDataLbl.isHidden = !isEmpty
                    self.noDataLbl.text = response.message ?? ""
                    self.searchView.isHidden = isEmpty
                    self.searchBtn.isHidden = isEmpty
                    
                case .failure(let error):
                    self.noDataImg.isHidden = false
                    self.noDataLbl.isHidden = false
                    self.noDataLbl.text = error.localizedDescription
                    self.searchView.isHidden = true
                    self.searchBtn.isHidden = true
                }
            }
        }
    }
    
    func clearNotification(id: [String], onComplete: @escaping (Bool) -> Void) {
        if #available(iOS 15.0, *) { showActivityLoader() }
        
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_delete_notification,
            parameters: ["id": id],
            type: ApitTypeSringFile.PUT,
            token: token
        ) { [weak self] (result: Result<notificationSuc, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) { self?.hideActivityLoader() }
                
                switch result {
                case .success(let response):
                    print(response.status == true ? "✅ Notifications deleted" : "⚠️ Delete failed")
                case .failure(let error):
                    print("❌ API Delete Error: \(error.localizedDescription)")
                }
                onComplete(true)
            }
        }
    }
}

// MARK: - SearchBar Delegate
@available(iOS 14.0, *)
extension NotificationViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            tvheadernotidata = allNotifications
            tableview.reloadData()
            return
        }
        
        tvheadernotidata = allNotifications.compactMap { section in
            let filteredDetails = section.details?.filter {
                $0.message?.localizedCaseInsensitiveContains(searchText) ?? false ||
                $0.name?.localizedCaseInsensitiveContains(searchText) ?? false
            }
            guard let filtered = filteredDetails, !filtered.isEmpty else { return nil }
            var updated = section
            updated.details = filtered
            return updated
        }
        
        noDataImg.isHidden = !tvheadernotidata.isEmpty
        noDataLbl.isHidden = !tvheadernotidata.isEmpty
        noDataLbl.text = "Search Data not Found"
        tableview.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
