//
//  CustomParentDashboardVC.swift
//  School Chimes
//
//  Created by Chandhru on 01/08/25.
//

import UIKit

protocol backNavigation {
    func back(logout:Bool)
}

@available(iOS 14.0, *)
class CustomParentDashboardVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SideMenuDelegate {
    func didTapProfileImage(from imageView: UIImageView?) {
        guard let tappedImageView = imageView else { return }
        
        let cellFrameInSuperview = tappedImageView.convert(tappedImageView.bounds, to: nil)
        
        let vc = PreviewImageVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = transitionDelegate
        transitionDelegate.originFrame = cellFrameInSuperview
        vc.type = "IMAGE"
        vc.selectedFileURL = URL(string: childDetails?.profile ?? "")
        
        present(vc, animated: true)
    }

    
    
    // MARK: - SideMenuDelegate
    func meunu(viewController: UIViewController?) {
        hideSideMenu()
        if let vc = viewController {
            if vc is SettingsViewController || vc is UpdateProfileVC || vc is HelpVc {
                navigationController?.pushViewController(vc, animated: true)
            } else if vc is LogoutViewController {
                let userDefaults = UserDefaults.standard
                userDefaults.set(true, forKey: "Logout")
                let vc = LogoutViewController(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: false)
            }else if vc is CustomDashboard {
                hideSideMenu()
            }else{
                delegate?.back(logout: false)
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var headerView: HeaderWaveView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var pagecontroller: UIPageControl!
    @IBOutlet weak var recentActiveMenuCollection: UICollectionView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var MenuCollection: UICollectionView!
    let transitionDelegate = TransitioningDelegate()
    // MARK: - Properties
    var recentMenuItems: [MenuDetail]?
    var menu_details: [MenuDetail] = []
    var filteredMenu: [MenuDetail] = []
    var filteredRecentMenu: [MenuDetail] = []
    var refreshCount = false
    var childDetailscount = UserDefaultFileManager.getUserDetails()?.user_details?.child_details
    var childDetails = UserDefaultFileManager.get_child_Details()
    
    let MenuRedirect = MenuRedirectHandler.shared
    var sideMenu: SideMenuVC?
    var dimmedView: UIView?
    var delegate: backNavigation?
    var comeFormNotification : Bool = false
    var messageId : String?
    var menuId : String?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
            
            // Register cells
            recentActiveMenuCollection.register(UINib(nibName: "TopCVCell", bundle: nil), forCellWithReuseIdentifier: "TopCVCell")
            MenuCollection.register(UINib(nibName: "CustomMenuCVC", bundle: nil), forCellWithReuseIdentifier: "CustomMenuCVC")
            setupEdgeGesture()
            // Delegates and DataSources
            recentActiveMenuCollection.delegate = self
            recentActiveMenuCollection.dataSource = self
            MenuCollection.delegate = self
            MenuCollection.dataSource = self
//        pagecontroller.currentPage = 0
            setupHeaderView()
            setupLabels()
            setupProfileImage()
            Global_variabel()
        if let id = messageId ,id != "" {
            handleMenuSelection(menuId: Int(menuId ?? "-1") ?? 0 , messageId: messageId ?? "")
        }
        searchBar.searchTextField.borderStyle = .none
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.layer.cornerRadius = 8
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.backgroundColor = .systemGray5
        searchBar.layer.cornerRadius = 8
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
    }
    
    init(
        comefromNotification: Bool = false,
        menuId : String = "" ,
        messageId : String = "") {
            self.comeFormNotification = comefromNotification
            self.menuId = menuId
            self.messageId = messageId
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        if self.refreshCount{  self.get_MenuCount()
        }else{
            get_dashboard_details()
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        searchBar.isHidden = !sender.isSelected

        if sender.isSelected {
            searchBar.becomeFirstResponder()
        } else {
            searchBar.text = ""
            filteredMenu = menu_details ?? []
            filteredRecentMenu = recentMenuItems ?? []
            MenuCollection.reloadData()
            recentActiveMenuCollection.reloadData()
            searchBar.resignFirstResponder()
        }
    }
    
    // MARK: - API Calls
    func get_dashboard_details() {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        let mobile_num = UserDefaultFileManager.getLoginCredentials()?.mobile_number
        APIService.shared.makeApi(
            url: ServiceUrl.get_dashboard_details,
            parameters: ["member_type": "parent", "mobile_number": mobile_num ?? ""],
            type: ApitTypeSringFile.GET,
            token: childDetails?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<MenuResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status == true, let details = response.data?.first {
                        self.menu_details = details.menus ?? []
                        self.recentMenuItems = details.frequently_used
                        self.MenuCollection.reloadData()
                        self.refreshCount = true
                        self.recentActiveMenuCollection.isHidden = (details.frequently_used?.isEmpty ?? true)
                        self.filteredRecentMenu = details.frequently_used ?? []
                        
                        if let frequent = details.frequently_used{
//                            self.pagecontroller.isHidden = frequent.count < 1
                        }else{
//                            self.pagecontroller.isHidden = true
                        }
                        self.pagecontroller.numberOfPages = details.frequently_used?.count ?? 0
                        self.filteredMenu = details.menus ?? []
                        self.recentActiveMenuCollection.reloadData()
                        self.get_MenuCount() // 🔹 after menus loaded
                        user_inputs.menuList = self.menu_details.compactMap{$0.name}
                        
                        if details.is_birthday ?? false{
                            DispatchQueue.main.async {
                                let vc = BirthDayWishVC(nibName: nil, bundle: nil)
                                vc.modalPresentationStyle = .formSheet
                                self.present(vc, animated: true)
                            }
                        }
                    } else {
                        self.MenuCollection.reloadData()
                    }
                    
                case .failure(let error):
                    if #available(iOS 15.0, *) {
                        self.hideActivityLoader()
                    }
                }
            }
        }
    }

    func Global_variabel() {
        APIService.shared.makeApi(
            url: ServiceUrl.global_global_variables,
            parameters: ["key_names" : []],
            type: ApitTypeSringFile.POST,
            token: "", isBaseUrl: false
        ) { (result: Result<GlobalVariablesResponse, Error>) in
            switch result {
                
            case .success(let successMessage):
                if successMessage.status == true {
                        if let respo = successMessage.data?.first {
                            UserDefaultFileManager
                                .save_global_Selection(data: respo)
                            print("resporespo",respo)}
                        
                    
                    else {
                        print("Device token registration failed")
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    func get_MenuCount() {
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_dashboard_menu_counts,
            parameters: ["member_type": "parent"],
            type: ApitTypeSringFile.GET,
            token: childDetails?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<MenuCountResponse, Error>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard response.status == true,
                          let details = response.data?.first,
                          let newDetails = details.menu_details else {
                        if #available(iOS 15.0, *) { self.hideActivityLoader() }
                        return
                    }
                    // Update menu counts
                    let changedIndexPaths = self.updateMenuCounts(with: newDetails)
                    let menuDetails = self.menu_details
                    let safeIndexPaths = changedIndexPaths.filter { $0.item < menuDetails.count }
                    for indexPath in safeIndexPaths {
                        let item = menuDetails[indexPath.item]

                        if let cell = self.MenuCollection.cellForItem(at: indexPath) as? CustomMenuCVC {
                            cell.readVieaw.isHidden = (item.unread_count ?? 0) == 0
                        }
                        if let cell = self.recentActiveMenuCollection.cellForItem(at: indexPath) as? TopCVCell {
                            cell.readVieaw.isHidden = (item.unread_count ?? 0) == 0
                        }
                    }
                    if #available(iOS 15.0, *) {
                        self.hideActivityLoader()
                    }

                case .failure(let error):
                    print("API Error:", error.localizedDescription)
                    if #available(iOS 15.0, *) {
                        self.hideActivityLoader()
                    }
                }
            }
        }
    }


    func updateMenuCounts(with newDetails: [MenuCountDetail]) -> [IndexPath] {

        var changedIndexPaths: [IndexPath] = []

        for newItem in newDetails {
            guard let newId = newItem.id else { continue }

            // Main menu
            if let index = menu_details.firstIndex(where: { $0.id == newId }) {
                if menu_details[index].unread_count != newItem.unread_count {
                    menu_details[index].unread_count = newItem.unread_count
                    changedIndexPaths.append(IndexPath(item: index, section: 0))
                }
            }

            // Recent menu also update
            if let recentIndex = recentMenuItems?.firstIndex(where: { $0.id == newId }) {
                recentMenuItems?[recentIndex].unread_count = newItem.unread_count
            }
        }

        return changedIndexPaths
    }


    // MARK: - Setup UI
    private func setupHeaderView() {
        headerView.setNeedsDisplay()
    }
    
    private func setupLabels() {
        welcomeLabel.text = childDetails?.school_name
        welcomeLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        welcomeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        nameLabel.text = childDetails?.name
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private func setupProfileImage() {
        profileImageView.kf.setImage(with: URL(string: childDetails?.school_logo_url ?? ""),placeholder:UIImage(systemName: "School Needs"))
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        profileImageView.isUserInteractionEnabled = true
        // 2️⃣ Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        profileImageView.addGestureRecognizer(tapGesture)
    }
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView else { return }
        let cellFrameInSuperview = tappedImageView.convert(tappedImageView.bounds, to: nil)
        
        let vc = PreviewImageVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = transitionDelegate
        transitionDelegate.originFrame = cellFrameInSuperview
        vc.type = "IMAGE"
        vc.selectedFileURL = URL(string: childDetails?.school_logo_url ?? "")
        
        present(vc, animated: true)
    }
    private func setupEdgeGesture() {
        let edgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeSwipe(_:)))
        edgeSwipe.edges = .left
        view.addGestureRecognizer(edgeSwipe)
    }

    @objc private func handleEdgeSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .began {
            showSideMenu()
        }
    }
    // MARK: - Actions
    @IBAction func SideMenu(_ sender: UIButton) {
        showSideMenu()
    }
    
    @IBAction func notificationBtn(_ sender: UIButton) {
        let vc = NotificationViewController(nibName: nil, bundle: nil)
        vc.token = childDetails?.access_token ?? ""
        vc.isParent = true
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func showSideMenu() {
        guard let window = UIApplication.shared.windows.first else { return }
        let dimView = UIView(frame: window.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideSideMenu))
        dimView.addGestureRecognizer(tapGesture)
        window.addSubview(dimView)
        self.dimmedView = dimView
        
        let menuVC = SideMenuVC(isStudent: true)
        menuVC.view.frame = CGRect(x: -250, y: 0, width: 250, height: window.bounds.height)
        applyGradientBackground(to: menuVC.view)
       
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideSideMenu))
        swipeGesture.direction = .left
        dimView.addGestureRecognizer(swipeGesture)
        
        menuVC.delegate = self
        window.addSubview(menuVC.view)
        window.rootViewController?.addChild(menuVC)
        menuVC.didMove(toParent: window.rootViewController)
        self.sideMenu = menuVC
        
        UIView.animate(withDuration: 0.3) {
            menuVC.view.frame.origin.x = 0
        }
    }

    @objc func hideSideMenu() {
        guard let menuVC = sideMenu else { return }
        UIView.animate(withDuration: 0.3, animations: {
            menuVC.view.frame.origin.x = -300
            self.dimmedView?.alpha = 0
        }) { _ in
            menuVC.view.removeFromSuperview()
            menuVC.removeFromParent()
            self.dimmedView?.removeFromSuperview()
            self.sideMenu = nil
            self.dimmedView = nil
        }
    }
    func applyGradientBackground(to view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.31, green: 0.58, blue: 0.98, alpha: 1.0).cgColor,
            UIColor(red: 0.18, green: 0.42, blue: 0.85, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == recentActiveMenuCollection ? (filteredRecentMenu.count) : filteredMenu.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recentActiveMenuCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCVCell", for: indexPath) as! TopCVCell
           let item = filteredRecentMenu[indexPath.item]
                cell.configure(with: item)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomMenuCVC", for: indexPath) as! CustomMenuCVC
            let item = filteredMenu[indexPath.item]
            if let id = item.id {
                let filteredItems = MenuRedirectHandler.shared.Imgitems.filter { $0.id == id }
                let img = UIImage(named: filteredItems.first?.name ?? "school_chimes 2")
                cell.iconBtn.setImage(img, for: .normal)
                cell.imenuName.text = item.name
                cell.menuCondent.text = item.description ?? ""
                cell.readVieaw.isHidden = (item.unread_count ?? 0) == 0
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var menuItem: Int?
        var menuName: String = ""

        if collectionView == MenuCollection {
            menuItem = filteredMenu[indexPath.row].id
            menuName = filteredMenu[indexPath.row].name ?? ""
        } else {
            menuItem = filteredRecentMenu[indexPath.row].id
            menuName = filteredRecentMenu[indexPath.row].name ?? ""
        }
        Menu_id.staffSelectedMenuId = menuItem ?? 0
        MenuStringFile.selectedMenuName = menuName
        guard let menuId = menuItem else { return }
        handleMenuSelection(menuId: menuId, messageId: "")
    }

    private func handleMenuSelection(menuId: Int, messageId : String) {
        Menu_id.staffSelectedMenuId = menuId
        switch menuId {
        case 2:  MenuRedirect.receiverAssignmentNavigate(from: self, PushNotiMsgId: messageId)
        case 4:  MenuRedirect.receiverAttendancereport(
            from: self,
            PushNotiMsgId: messageId)
        case 5:  MenuRedirect.receiverCertificateRequest(from: self)
        case 6:  MenuRedirect.receiverclassTimeTable(from: self)
        case 7:  MenuRedirect.receiverCommunicationNavigate(from: self,PushNotiMsgId: messageId)
        case 9:  MenuRedirect.receiverEvent(from: self,PushNotiMsgId: messageId)
        case 10: MenuRedirect.resiverExamMark(from: self)
        case 12: MenuRedirect.receiverFeeDetails(from: self)
        case 15: MenuRedirect.receiverHomework(from: self,PushNotiMsgId: messageId)
        case 16: MenuRedirect.receiverchat(from: self)
        case 20: MenuRedirect.receiverLsrwNavigate(from: self,PushNotiMsgId: messageId)
        case 23: MenuRedirect.receiverNoticeBoardNavigate(from: self,PushNotiMsgId: messageId)
        case 24: MenuRedirect.receiverOnlineNavigate(from: self)
        case 25: MenuRedirect.senderImportantInfoNavigate(from: self)
        case 26: MenuRedirect.receiverPtmNavigate(from: self)
        case 27: MenuRedirect.QuizExam(from: self,PushNotiMsgId: messageId)
        case 30: MenuRedirect.senderImportantInfoNavigate(from: self)
        case 36: MenuRedirect.senderImportantInfoNavigate(from: self)
        case 39: MenuRedirect.receiverAttachment(from: self,PushNotiMsgId: messageId)
        case 40: MenuRedirect.receiverPauckt(from: self)
        default:
            let alert = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .alert
            )
            alert.addIconTitleMessage(
                icon: UIImage(named: "school_chimes 2"),
                title: "Coming Soon",
                message: "This feature is under development."
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
    }

    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView == recentActiveMenuCollection {
//            let visibleIndexes = recentActiveMenuCollection.indexPathsForVisibleItems.map { $0.item }
//            if let maxIndex = visibleIndexes.max() {
//                pagecontroller.currentPage = maxIndex
//            }
//        }
//    }
}

@available(iOS 14.0, *)
extension CustomParentDashboardVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == recentActiveMenuCollection {
            return CGSize(width: 200, height: 90)
        } else {
            return CGSize(width: (collectionView.frame.width - 25) / 2, height: 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
extension CustomParentDashboardVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else {
            filteredMenu = menu_details
            filteredRecentMenu = recentMenuItems ?? []
            MenuCollection.reloadData()
            recentActiveMenuCollection.reloadData()
            return
        }

        filteredMenu = menu_details.filter {
            ($0.name?.localizedCaseInsensitiveContains(text) ?? false) ||
            ($0.description?.localizedCaseInsensitiveContains(text) ?? false)
        }

        filteredRecentMenu = recentMenuItems?.filter {
            ($0.name?.localizedCaseInsensitiveContains(text) ?? false) ||
            ($0.description?.localizedCaseInsensitiveContains(text) ?? false)
        } ?? []

        MenuCollection.reloadData()
        recentActiveMenuCollection.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
