//
//  CustomDashboard.swift
//  School Chimes
//
//  Created by Chandhru on 01/08/25.
//
import UIKit

@available(iOS 14.0, *)
class CustomDashboard: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SideMenuDelegate, SwitchRollDelegate {
    func didTapProfileImage(from imageView: UIImageView?) {
        guard let tappedImageView = imageView else { return }
        let cellFrameInSuperview = tappedImageView.convert(tappedImageView.bounds, to: nil)
        let vc = PreviewImageVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = transitionDelegate
        transitionDelegate.originFrame = cellFrameInSuperview
        vc.type = "IMAGE"
        vc.selectedFileURL = URL(string: staffDetails?.staff_profile ?? "")
        
        present(vc, animated: true)
    }

    func switchRoll(userToken: String) {
        self.get_dashboard_details(token: userToken)
        setupLabels(name: staffDetails?.name, school: staffDetails?.school_name, roll: staffDetails?.role)
        setupProfileImage()
    }

    // MARK: - Outlets
    @IBOutlet weak var headerView: HeaderWaveView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pagecontroller: UIPageControl!
    @IBOutlet weak var recentActiveMenuCollection: UICollectionView!
    @IBOutlet weak var MenuCollection: UICollectionView!
    
    // MARK: - Properties
    var recentMenuItems: [MenuDetail]?
    var menu_details: [MenuDetail]?
    var filteredMenu: [MenuDetail] = []
    var filteredRecentMenu: [MenuDetail] = []
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let is_staff = UserDefaultFileManager.getUserDetails()?.user_details?.is_staff
    let is_parent = UserDefaultFileManager.getUserDetails()?.user_details?.is_parent
    let staff_roll = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role
    let MenuRedirect = MenuRedirectHandler.shared
    var sideMenu: SideMenuVC?
    var dimmedView: UIView?
    var delegate: backNavigation?
    let transitionDelegate = TransitioningDelegate()
    var refreshCount = false
    var pushNotificationId : String?
    var PushNotificationMenuId : String?
    var comeFormNotification : Bool = false
    var tourKey = "staffDashboard"
    var tourImg = ["sender_msg1","sender_file2"]
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cells
        recentActiveMenuCollection.register(UINib(nibName: CellConfingName.TopCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.TopCVCell)
        MenuCollection.register(UINib(nibName: CellConfingName.CustomMenuCVC, bundle: nil), forCellWithReuseIdentifier: CellConfingName.CustomMenuCVC)
        
        if checkMutipleSchool(isSingle: staffDetailsCount?.count == 1) {
            profileImageView.isHidden = true
            let schoolname = staffDetailsCount?.count == 1 ? staffDetails?.school_name:""
            setupLabels(
                name: staffDetails?.name,
                school: schoolname, roll:staffDetails?.role)
        } else {
            profileImageView.isHidden = false
            setupLabels(name: staffDetails?.name, school: staffDetails?.school_name, roll: nil)
        }
        // Delegates and DataSources
        recentActiveMenuCollection.delegate = self
        recentActiveMenuCollection.dataSource = self
        MenuCollection.delegate = self
        MenuCollection.dataSource = self
        setupEdgeGesture()
        DeviceTokenAPIcall()
        setupHeaderView()
        Global_variabel()
        setupProfileImage()
        if let id = pushNotificationId ,id != "" {
            handleMenuSelection(
                menuId: Int(PushNotificationMenuId ?? "-1") ?? -1,
                PushNotiMsg : pushNotificationId ?? ""
            )
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
        handleBiometricAuthentication()
        
    }
    private func handleBiometricAuthentication() {
        
        if !BiometricAuthentication.shared.isBiometricEnabledInApp(),
           !BiometricAuthentication.shared.isBiometricDeclineInApp() {
            
            BiometricAuthentication.shared.showEnableBiometricPopup(
                from: self,
                message: "Would you like to enable Face ID / Touch ID for this app?"
            ){[weak self] _ in
                guard let self = self else { return }
                self.presentAppTourIfNeeded()
            }
        } else {
            presentAppTourIfNeeded()
        }
    }

    private func presentAppTourIfNeeded() {
        let bundleID = Bundle.main.bundleIdentifier

        guard bundleID == CommonStringFile.Base_bundle_id else { return }
        guard !UserDefaults.standard.bool(forKey: tourKey) else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let vc = AppTourVC()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.tourKey = self.tourKey
            vc.image = self.tourImg
            self.present(vc, animated: true)
        }
    }
    
    init(
        comefromNotification: Bool = false,
        menuId : String = "" ,
        messageId : String = "") {
            self.comeFormNotification = comefromNotification
            self.PushNotificationMenuId = menuId
            self.pushNotificationId = messageId
            super.init(nibName: nil, bundle: nil)
        }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
//            filteredRecentMenu = recentMenuItems ?? []
            MenuCollection.reloadData()
//            recentActiveMenuCollection.reloadData()
            searchBar.resignFirstResponder()
        }
    }

    @IBAction func notificationBtn(_ sender: UIButton) {
        let vc = NotificationViewController(nibName: nil, bundle: nil)
        vc.token = staffDetails?.access_token ?? ""
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        getacadmicYr {
            if self.refreshCount{
                self.get_MenuCount()
            }else{
                self.get_dashboard_details(token: self.staffDetails?.access_token ?? "")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - SideMenuDelegate
    func meunu(viewController: UIViewController?) {
        hideSideMenu()
        if let vc = viewController {
            if vc is SettingsViewController || vc is UpdateProfileVC || vc is HelpVc {
                if let settingsVC = vc as? SettingsViewController {
                    settingsVC.passVale = 1
                }
                delegate?.back(logout: false, vc)
            } else if vc is LogoutViewController {
                let userDefaults = UserDefaults.standard
                userDefaults.set(true, forKey: "Logout")
                let vc = LogoutViewController(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: false)
            }else if vc is CustomDashboard {
                hideSideMenu()
            }else{
                delegate?.back(logout: false, UIViewController())
            }
        }
    }
    
    // MARK: - API Calls
    func get_dashboard_details(token:String) {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        let mobile_num = UserDefaultFileManager.getLoginCredentials()?.mobile_number
        APIService.shared.makeApi(
            url: ServiceUrl.get_dashboard_details,
            parameters: [COMMON_PARAMETER.member_type: API_PARAMS_HOTCODE.staff, COMMON_PARAMETER.mobile_number: mobile_num ?? ""],
            type: ApitTypeSringFile.GET,
            token:token, isBaseUrl: false
        ) { [weak self] (result: Result<MenuResponse, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status == true, let details = response.data?.first {
                        self.menu_details = details.menus
                        self.menu_details?.append(
                            MenuDetail(id: 112, name: "Apply Leave", description: "Used to tracking")
                        )
                        self.menu_details?.append(
                            MenuDetail(id: 113, name: "Hostel Management", description: "Used to apply leave")
                        )
                        
                        self.menu_details?.append(
                            MenuDetail(id: 114, name: "Staff Leave Request", description: "Used to apply leave")
                        )
                        self.refreshCount = true
                        self.get_MenuCount()
                        self.recentMenuItems = details.frequently_used
                        self.filteredRecentMenu = details.frequently_used ?? []
                        
                        if let frequent = details.frequently_used{
//                            self.pagecontroller.isHidden = frequent.count < 1
                        }else{
//                            self.pagecontroller.isHidden = true
                        }
                        self.pagecontroller.numberOfPages = details.frequently_used?.count ?? 0
                        self.filteredMenu = self.menu_details ?? []//details.menus ?? []
                        self.MenuCollection.reloadData()
                        self.recentActiveMenuCollection.isHidden = details.frequently_used?.isEmpty ?? true
                        self.recentActiveMenuCollection.reloadData()
                        user_inputs.menuList = self.menu_details?.compactMap{$0.name} ?? []
                        if details.is_birthday ?? false{
                            DispatchQueue.main.async {
                                let vc = BirthDayWishVC(nibName: nil, bundle: nil)
                                vc.modalPresentationStyle = .formSheet
                                self.present(vc, animated: true)}}
                    } else {
                        self.menu_details = []
                        self.MenuCollection.reloadData()
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
    
    func get_MenuCount() {
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_dashboard_menu_counts,
            parameters: [COMMON_PARAMETER.member_type:API_PARAMS_HOTCODE.staff],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<MenuCountResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status == true,
                       let details = response.data?.first,
                       let newDetails = details.menu_details {
                        
                        let changedIndexPaths = self.updateMenuCounts(with: newDetails)
                        let safeIndexPaths = changedIndexPaths.filter { $0.item < (self.menu_details?.count ?? 0) }
                        
                        for indexPath in safeIndexPaths {
                            guard let item = self.menu_details?[indexPath.item] else { continue }
                            if let cell = self.MenuCollection.cellForItem(at: indexPath) as? CustomMenuCVC {
                                if item.id == Menu_id.MessageFromManagement {
                                    cell.readVieaw.isHidden = (item.unread_count ?? 0) == 0
                                } else {
                                    cell.readVieaw.isHidden = true
                                }
                            }else if let cell = self.recentActiveMenuCollection.cellForItem(at: indexPath) as? TopCVCell {
                                if item.id == Menu_id.MessageFromManagement {
                                    cell.readVieaw.isHidden = (item.unread_count ?? 0) == 0
                                } else {
                                    cell.readVieaw.isHidden = true
                                }
                            }
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

        guard let menuList = menu_details else { return [] }

        var updatedMenu = menuList
        var updatedRecent = recentMenuItems ?? []
        var updatedFilteredMenu = filteredMenu
        var updatedFilteredRecent = filteredRecentMenu

        var changedMainIndex: [IndexPath] = []
        var changedRecentIndex: [IndexPath] = []

        for newItem in newDetails {
            guard let newId = newItem.id else { continue }

            if let index = updatedMenu.firstIndex(where: { $0.id == newId }) {
                if updatedMenu[index].unread_count != newItem.unread_count {
                    updatedMenu[index].unread_count = newItem.unread_count
                    changedMainIndex.append(IndexPath(item: index, section: 0))
                }
            }

            if let index = updatedRecent.firstIndex(where: { $0.id == newId }) {
                updatedRecent[index].unread_count = newItem.unread_count
                changedRecentIndex.append(IndexPath(item: index, section: 0))
            }

            if let index = updatedFilteredMenu.firstIndex(where: { $0.id == newId }) {
                updatedFilteredMenu[index].unread_count = newItem.unread_count
            }

            if let index = updatedFilteredRecent.firstIndex(where: { $0.id == newId }) {
                updatedFilteredRecent[index].unread_count = newItem.unread_count
            }
        }

        self.menu_details = updatedMenu
        self.recentMenuItems = updatedRecent
        self.filteredMenu = updatedFilteredMenu
        self.filteredRecentMenu = updatedFilteredRecent

        self.MenuCollection.reloadItems(at: changedMainIndex)
        self.recentActiveMenuCollection.reloadItems(at: changedRecentIndex)

        return changedMainIndex
    }

    
    
    
    func getacadmicYr(onComplete: @escaping () -> Void) {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_recipient_get_academic_year_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? "", isBaseUrl: false
        ) { (result: Result<get_academic_yearSuc, Error>) in
            switch result {
            case .success(let successMessage):
                localData.accidamic_year_data = successMessage
            case .failure(let error):
                print(error.localizedDescription)
            }
            onComplete()
        }
    }
    
    func DeviceTokenAPIcall() {
        let secureID = SecureIDManager.getSecureID()
        let mobile_num = UserDefaultFileManager.getLoginCredentials()?.mobile_number
        var deviceToken: String?
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            deviceToken = appDelegate.deviceTokenString
        }
        let model = UIDevice.current.modelName
        
        APIService.shared.makeApi(
            url: ServiceUrl.auth_device_token,
            parameters: [
                COMMON_PARAMETER.mobile_number: mobile_num ?? "",
                DeviceTokenStringFile.device_token: deviceToken ?? "",
                COMMON_PARAMETER.device_type: API_PARAMS_HOTCODE.device_type,
                DeviceTokenStringFile.secure_id: secureID,
                DeviceTokenStringFile.device_info: [
                    DeviceTokenStringFile.manufacturer: API_PARAMS_HOTCODE.device_type,
                    DeviceTokenStringFile.model: model,
                    DeviceTokenStringFile.device: API_PARAMS_HOTCODE.device_type,
                    DeviceTokenStringFile.brand: API_PARAMS_HOTCODE.device_type,
                    DeviceTokenStringFile.os_version: UIDevice.current.systemVersion,
                    DeviceTokenStringFile.app_version: 1
                ]
            ],
            type: ApitTypeSringFile.POST,
            token: "", isBaseUrl: true
        ) { (result: Result<DeviceTokenResponseSuc, Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true {
                    print("Device token registered successfully")
                } else {
                    print("Device token registration failed")
                }
            case .failure(let error):
                print(error.localizedDescription)
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
                        .save_global_Selection(data: respo)}
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - UI Setup
    private func setupHeaderView() {
        headerView.setNeedsDisplay()
    }
    
    private func setupLabels(name: String?, school: String?, roll: String?) {

        let schoolText = school?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let rollText = roll?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        var finalText = ""
        if !schoolText.isEmpty && !rollText.isEmpty {
            finalText = "\(schoolText)\n\(rollText)"
        } else if !schoolText.isEmpty {
            finalText = schoolText
        } else if !rollText.isEmpty {
            finalText = "\(rollText)"
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6 
        let attributedString = NSAttributedString(
            string: finalText,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.white.withAlphaComponent(0.9),
                .font: UIFont.systemFont(ofSize: 14, weight: .regular)
            ]
        )

        welcomeLabel.attributedText = attributedString
        welcomeLabel.numberOfLines = 0

        nameLabel.text = name
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }



    
    private func setupProfileImage() {
        profileImageView.kf.setImage(with: URL(string: staffDetails?.school_logo ?? ""),placeholder:UIImage(named: "School Needs"))
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        profileImageView.isUserInteractionEnabled = true
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
        vc.selectedFileURL = URL(string: staffDetails?.school_logo ?? "")
        
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
    @IBAction func switchRoll(_ sender: UIButton) {
        showRoll()
    }
    func showRoll(){
        let bottomSheetVC = SwitchRollVC()
        bottomSheetVC.modalPresentationStyle = .pageSheet
        bottomSheetVC.delegate = self
        if #available(iOS 16.0, *) {
            if let sheet = bottomSheetVC.sheetPresentationController {
                sheet.detents = [
                    .custom { context in
                        return 250
                    },
                    .medium(),
                    .large()
                ]
                //                context.maximumDetentValue * 0.3
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.largestUndimmedDetentIdentifier = .large
            }
            
        }
        present(bottomSheetVC, animated: true, completion: nil)
    }
    @objc func labelTapped() {
        showRoll()
    }
    // MARK: - Side Menu
    @IBAction func SideMenu(_ sender: UIButton) {
        self.view.endEditing(true)
        showSideMenu()
    }
    
    func showSideMenu() {
        guard let window = UIApplication.shared.windows.first else { return }
        let dimView = UIView(frame: window.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideSideMenu))
        dimView.addGestureRecognizer(tapGesture)
        window.addSubview(dimView)
        self.dimmedView = dimView
        
        let menuVC = SideMenuVC()
        menuVC.view.frame = CGRect(x: -250, y: 0, width: 250, height: window.bounds.height)
        applyGradientBackground(to: menuVC.view)
        menuVC.isStudent = false
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
            UIColor.backGroundClr,
            UIColor.backGroundClr.darker(by: 15)
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == recentActiveMenuCollection ? (filteredRecentMenu.count) : (filteredMenu.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recentActiveMenuCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.TopCVCell, for: indexPath) as! TopCVCell
            let item = filteredRecentMenu[indexPath.item]
                cell.configure(with: item)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.CustomMenuCVC, for: indexPath) as! CustomMenuCVC
            let item = filteredMenu[indexPath.item]
                let filteredItems = MenuRedirectHandler.shared.Imgitems.filter { $0.id == item.id }
                let img = UIImage(named: filteredItems.first?.name ?? "school_chimes 2")
                cell.iconBtn.setImage(img, for: .normal)
                cell.imenuName.text = item.name
                cell.menuCondent.text = item.description
                cell.readVieaw.isHidden = (item.unread_count ?? 0) == 0
            return cell
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedItem = collectionView == recentActiveMenuCollection
        ? filteredRecentMenu[indexPath.row]
        : filteredMenu[indexPath.row]
        Menu_id.staffSelectedMenuId = selectedItem.id ?? 0
        self.handleMenuSelection(menuId: selectedItem.id ?? 0, PushNotiMsg: "")
    }
    
    
    func handleMenuSelection(menuId: Int,PushNotiMsg : String) {
        let menuName = filteredMenu.first(where: { $0.id == menuId })?.name ?? ""
        MenuStringFile.selectedMenuName = menuName
        // MENU IDs that need navigateOrSchoolList check
        let needSchoolCheck: Set<Int> = [
            1, 2, 3, 5, 8, 14, 15, 17, 19, 20, 21, 26, 27, 29, 31, 33, 35, 18, 41,113
        ]
        Menu_id.staffSelectedMenuId = menuId
        // All actions with explicit self
        let actions: [Int: () -> Void] = [
            1: { self.MenuRedirect.senderAbsenteesReport(from: self) },
            2: { if PushNotiMsg != ""{
                self.assigemtHistoryPage(pushNoti: PushNotiMsg)}
                self.MenuRedirect.senderAssignmentNavigate(from: self) },
            3: { self.MenuRedirect.senderMarkAttendence(from: self) },
            5: { self.MenuRedirect.senderPtmNavigate(from: self, PushNotiMsgId: PushNotiMsg)},
            7: { self.MenuRedirect.senderCommunicationNavigate(from: self) },
            8: { self.MenuRedirect.senderDailyCollectionNavigate(from: self) },
            9: { self.MenuRedirect.senderEventNavigate(from: self) },
            14: { self.MenuRedirect.senderFeePendingNavigate(from: self) },
            15: { self.MenuRedirect.senderHomeWorkNavigate(from: self) },
            17: { self.MenuRedirect.Senderchat(from: self) },
            18: {self.MenuRedirect.senderLeaveRequestNavigate(from: self, PushnotiMsg_id: PushNotiMsg)},
            19: { self.MenuRedirect.senderLessonplanNavigate(from: self) },
            20: { self.MenuRedirect.SenderLSRWVCNavigate(from: self) },
            21: { self.MenuRedirect.senderMarkAttendanceNavigate(from: self) },
            22: {self.MenuRedirect.senderMgmt(from: self, Notification_MsgId: PushNotiMsg)},
            23: {self.noticeBordHistory{
                self.MenuRedirect.senderNoticeboardNavigate(from: self)}},
            24: {self.MenuRedirect.senderOnlineNavigate(from: self) },
            26: {self.MenuRedirect.senderPtmNavigate(from: self, PushNotiMsgId: PushNotiMsg)},
            27: { self.MenuRedirect.senderQuiz(from: self) },
            28: {self.MenuRedirect
                .senderLeaveRequestNavigate(from: self, PushnotiMsg_id: PushNotiMsg)},
            29: { self.MenuRedirect.senderEventNavigate(from: self) },
            30: { self.MenuRedirect.senderSchoolNeedsNavigate(from: self) },
            31: { self.MenuRedirect.senderSchoolStrength(from: self) },
            33: { self.MenuRedirect.StaffWiseAttendance(from: self) },
            35: { self.MenuRedirect.senderStudentreportNavigate(from: self) },
            36: { self.MenuRedirect.senderImportantInfoNavigate(from: self) },
            39: { self.MenuRedirect.senderAttachment(from: self) },
            40: { self.MenuRedirect.receiverPauckt(from: self) },
            41: { self.MenuRedirect.senderExamMarkNavigate(from: self) },
            112: { self.MenuRedirect.staffApplyLeave(from: self) },
            113: { self.MenuRedirect.HostelManagment(from: self) },
            114: { self.MenuRedirect.StaffLeaveRequest(from: self) },
        ]
 
        
        guard let action = actions[menuId] else {
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
        // If item requires school selection → wrap with navigateOrSchoolList
        if PushNotiMsg == ""{
            if needSchoolCheck.contains(menuId) {
                self.navigateOrSchoolList(action)
            } else {
                action()
            }
        }else{
            action()
        }
        
    }
    
    // MARK: - Helpers
    func navigateOrSchoolList(_ defaultAction: () -> Void) {
        if checkMutipleSchool() {
            MenuRedirect.SchoolListVc(from: self)
        } else {
            defaultAction()
        }
    }
    func noticeBordHistory(_ defaultAction: () -> Void) {
        
        if staffDetailsCount?.count ?? 0 > 0 {
            switch staff_roll {
            case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                defaultAction()
            default:
                let vc = NoticeBoardVc(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
        }
    }
    
    func assigemtHistoryPage(pushNoti:String){
        let vc = AssignmentReport(nibName: nil, bundle: nil)
        vc.pushNotiMsg_id = pushNoti
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    func checkMutipleSchool(isSingle:Bool? = nil) -> Bool {
        if staffDetailsCount?.count ?? 0 > 1 {
            switch staff_roll {
            case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                return true
            default:
                return false
            }
        }else if isSingle ?? false{
            switch staff_roll {
            case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                return true
            default:
                return false
            }
        }
        return false
    }
}

@available(iOS 14.0, *)
extension CustomDashboard: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView == recentActiveMenuCollection
        ? CGSize(width: 200, height: 110)
        : CGSize(width: (collectionView.frame.width - 25) / 2, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

struct DashboardMenu {
    let icon: String
    let title: String
    let subtitle: String
}
extension UIAlertController {
    func addIconTitleMessage(icon: UIImage?, title: String, message: String) {
        
        // Resize icon
        let iconAttachment = NSTextAttachment()
        iconAttachment.image = icon
        iconAttachment.bounds = CGRect(x: 0, y: -10, width: 35, height: 35)
        
        // Icon + Newline
        let iconString = NSAttributedString(attachment: iconAttachment)
        let newline = NSAttributedString(string: "\n\n")
        
        // Title attributed
        let titleAttr = NSAttributedString(
            string: title + "\n",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 17),
                .foregroundColor: UIColor.label
            ]
        )
        
        // Message attributed
        let messageAttr = NSAttributedString(
            string: message,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        
        // Combine all
        let final = NSMutableAttributedString()
        final.append(iconString)
        final.append(newline)
        final.append(titleAttr)
        final.append(messageAttr)
        
        self.setValue(final, forKey: "attributedTitle")
    }
}
extension UIDevice {
    var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            String(cString: ptr)
        }
    }
    
    var modelName: String {
        let identifier = self.modelIdentifier
        
        let map: [String: String] = [
            // iPhone 8 → iPhone 17 Pro Max
            "iPhone10,1": "iPhone 8", "iPhone10,4": "iPhone 8",
            "iPhone10,2": "iPhone 8 Plus", "iPhone10,5": "iPhone 8 Plus",
            "iPhone10,3": "iPhone X", "iPhone10,6": "iPhone X",
            "iPhone11,8": "iPhone XR",
            "iPhone11,2": "iPhone XS",
            "iPhone11,6": "iPhone XS Max", "iPhone11,4": "iPhone XS Max",
            "iPhone12,1": "iPhone 11",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone13,1": "iPhone 12 mini",
            "iPhone13,2": "iPhone 12",
            "iPhone13,3": "iPhone 12 Pro",
            "iPhone13,4": "iPhone 12 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,5": "iPhone 13",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,7": "iPhone 14",
            "iPhone14,8": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 15",
            "iPhone15,5": "iPhone 15 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPhone17,1": "iPhone 16",
            "iPhone17,2": "iPhone 16 Plus",
            "iPhone17,3": "iPhone 16 Pro",
            "iPhone17,4": "iPhone 16 Pro Max",
            "iPhone18,1": "iPhone 17",
            "iPhone18,2": "iPhone 17 Plus",
            "iPhone18,3": "iPhone 17 Pro",
            "iPhone18,4": "iPhone 17 Pro Max"
        ]
        
        return map[identifier] ?? identifier
    }
}
extension CustomDashboard: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else {
            filteredMenu = menu_details ?? []
//            filteredRecentMenu = recentMenuItems ?? []
            MenuCollection.reloadData()
//            recentActiveMenuCollection.reloadData()
            return
        }

        filteredMenu = menu_details?.filter {
            ($0.name?.localizedCaseInsensitiveContains(text) ?? false) ||
            ($0.description?.localizedCaseInsensitiveContains(text) ?? false)
        } ?? []

//        filteredRecentMenu = recentMenuItems?.filter {
//            ($0.name?.localizedCaseInsensitiveContains(text) ?? false) ||
//            ($0.description?.localizedCaseInsensitiveContains(text) ?? false)
//        } ?? []

        MenuCollection.reloadData()
//        recentActiveMenuCollection.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


