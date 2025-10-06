//
//  CustomDashboard.swift
//  School Chimes
//
//  Created by Chandhru on 01/08/25.
//
import UIKit

@available(iOS 14.0, *)
class CustomDasboard: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SideMenuDelegate, SwitchRollDelegate {
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
        setupLabels(name: staffDetails?.name, school: staffDetails?.school_name)
        setupProfileImage()
    }
    
    
    // MARK: - Outlets
    @IBOutlet weak var headerView: HeaderWaveView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var pagecontroller: UIPageControl!
    @IBOutlet weak var recentActiveMenuCollection: UICollectionView!
    @IBOutlet weak var MenuCollection: UICollectionView!
    
    // MARK: - Properties
    var recentMenuItems: [MenuDetail]?
    var menu_details: [MenuDetail]?
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
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cells
        recentActiveMenuCollection.register(UINib(nibName: "TopCVCell", bundle: nil), forCellWithReuseIdentifier: "TopCVCell")
        MenuCollection.register(UINib(nibName: "CustomMenuCVC", bundle: nil), forCellWithReuseIdentifier: "CustomMenuCVC")
        
        if checkMutipleSchool() {
            profileImageView.isHidden = true
            setupLabels(
                name: staffDetails?.name,
                school: staffDetails?.role)
        } else {
            profileImageView.isHidden = false
            setupLabels(name: staffDetails?.name, school: staffDetails?.school_name)
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
            self.get_dashboard_details(token: self.staffDetails?.access_token ?? "")
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
                self.navigationController?.pushViewController(vc, animated: true)
            } else if vc is LogoutViewController {
                let userDefaults = UserDefaults.standard
                userDefaults.set(true, forKey: "Logout")
                let vc = LogoutViewController(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: false)
            }else if vc is CustomDasboard {
                hideSideMenu()
            }else{
                delegate?.back(logout: false)
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
            parameters: ["member_type": "staff", "mobile_number": mobile_num ?? ""],
            type: ApitTypeSringFile.GET,
            token:token
        ) { [weak self] (result: Result<MenuResponse, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status == true, let details = response.data?.first {
                        self.menu_details = details.menus
                        self.get_MenuCount()
                        self.recentMenuItems = details.frequently_used
                        self.MenuCollection.reloadData()
                        self.recentActiveMenuCollection.isHidden = details.frequently_used?.isEmpty ?? true
                        self.pagecontroller.isHidden = details.frequently_used?.count ?? 0 < 2
                        self.pagecontroller.numberOfPages = self.recentMenuItems?.count ?? 0
                        self.recentActiveMenuCollection.reloadData()
                        user_inputs.menuList = self.menu_details?.compactMap{$0.name} ?? []
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
            parameters: ["member_type": "staff"],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
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
        guard let currentDetails = menu_details else { return [] }
        var updatedDetails = currentDetails
        var changedIndexPaths: [IndexPath] = []
        
        for newItem in newDetails {
            guard let newId = newItem.id,
                  let index = updatedDetails.firstIndex(where: { $0.id == newId }) else { continue }
            
            if updatedDetails[index].unread_count != newItem.unread_count {
                updatedDetails[index].unread_count = newItem.unread_count
                changedIndexPaths.append(IndexPath(item: index, section: 0))
            }
        }
        self.menu_details = updatedDetails
        return changedIndexPaths
    }
    
    
    
    func getacadmicYr(onComplete: @escaping () -> Void) {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_recipient_get_academic_year_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
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
            deviceToken = appDelegate.DeviceToken
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.auth_device_token,
            parameters: [
                COMMON_PARAMETER.mobile_number: mobile_num ?? "",
                DeviceTokenStringFile.device_token: deviceToken ?? "",
                COMMON_PARAMETER.device_type: API_PARAMS_HOTCODE.device_type,
                DeviceTokenStringFile.secure_id: secureID,
                DeviceTokenStringFile.device_info: [
                    DeviceTokenStringFile.manufacturer: "iPhone",
                    DeviceTokenStringFile.model: "iPhone12",
                    DeviceTokenStringFile.device: "iPhone",
                    DeviceTokenStringFile.brand: "iPhone",
                    DeviceTokenStringFile.os_version: UIDevice.current.systemVersion,
                    DeviceTokenStringFile.app_version: 1
                ]
            ],
            type: ApitTypeSringFile.POST,
            token: ServiceUrl.token
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
            token: ""
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
    
    // MARK: - UI Setup
    private func setupHeaderView() {
        headerView.setNeedsDisplay()
    }
    
    private func setupLabels(name:String?,school:String?) {
        welcomeLabel.text = school
        welcomeLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        welcomeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        nameLabel.text = name
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private func setupProfileImage() {
        profileImageView.kf.setImage(with: URL(string: staffDetails?.school_logo ?? ""),placeholder:UIImage(systemName: "School Needs"))
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
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
        return collectionView == recentActiveMenuCollection ? (recentMenuItems?.count ?? 0) : (menu_details?.count ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recentActiveMenuCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCVCell", for: indexPath) as! TopCVCell
            if let item = recentMenuItems?[indexPath.item] {
                cell.configure(with: item)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomMenuCVC", for: indexPath) as! CustomMenuCVC
            if let item = menu_details?[indexPath.item] {
                let filteredItems = MenuRedirectHandler.shared.Imgitems.filter { $0.id == item.id }
                let img = UIImage(named: filteredItems.first?.name ?? "")
                cell.iconBtn.setImage(img, for: .normal)
                cell.imenuName.text = item.name
                cell.menuCondent.text = item.description
                cell.readVieaw.isHidden = (item.unread_count ?? 0) == 0
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = collectionView == recentActiveMenuCollection ? recentMenuItems?[indexPath.row] : menu_details?[indexPath.row]
        guard let item = selectedItem else { return }
        
        Menu_id.staffSelectedMenuId = item.id ?? 0
        MenuStringFile.selectedMenuName = item.name ?? ""
        
        switch item.id {
        case 1: navigateOrSchoolList { MenuRedirect.senderAbsenteesReport(from: self) }
        case 2: navigateOrSchoolList { MenuRedirect.senderAssignmentNavigate(from: self) }
        case 3: navigateOrSchoolList { MenuRedirect.senderMarkAttendence(from: self) }
        case 5: navigateOrSchoolList { MenuRedirect.senderPtmNavigate(from: self) }
        case 7: MenuRedirect.senderCommunicationNavigate(from: self)
        case 8: navigateOrSchoolList { MenuRedirect.senderDailyCollectionNavigate(from: self) }
        case 9: MenuRedirect.senderEventNavigate(from: self)
        case 14: navigateOrSchoolList { MenuRedirect.senderFeePendingNavigate(from: self) }
        case 15: navigateOrSchoolList { MenuRedirect.senderHomeWorkNavigate(from: self) }
        case 17: navigateOrSchoolList { MenuRedirect.Senderchat(from: self) }
        case 18: MenuRedirect.senderLeaveRequestNavigate(from: self)
        case 19: navigateOrSchoolList { MenuRedirect.senderLessonplanNavigate(from: self) }
        case 20: navigateOrSchoolList { MenuRedirect.SenderLSRWVCNavigate(from: self) }
        case 21: navigateOrSchoolList { MenuRedirect.senderMarkAttendanceNavigate(from: self) }
        case 22: navigateOrSchoolList { MenuRedirect.senderMgmt(from: self) }
        case 23: MenuRedirect.senderNoticeboardNavigate(from: self)
        case 24: MenuRedirect.senderOnlineNavigate(from: self)
        case 26: navigateOrSchoolList { MenuRedirect.senderPtmNavigate(from: self) }
        case 27: navigateOrSchoolList { MenuRedirect.senderQuiz(from: self) }
        case 28: MenuRedirect.senderLeaveRequestNavigate(from: self)
        case 29: navigateOrSchoolList { MenuRedirect.senderEventNavigate(from: self) }
        case 30: MenuRedirect.senderSchoolNeedsNavigate(from: self)
        case 31: navigateOrSchoolList { MenuRedirect.senderSchoolStrength(from: self) }
        case 33: navigateOrSchoolList { MenuRedirect.StaffWiseAttendance(from: self) }
        case 35: navigateOrSchoolList { MenuRedirect.senderStudentreportNavigate(from: self) }
        case 36: MenuRedirect.senderImportantInfoNavigate(from: self)
        case 38: break
        case 39:MenuRedirect.senderAttachment(from: self)
        case 40:navigateOrSchoolList { MenuRedirect.receiverPauckt(from: self) }
        default: print("Unknown menuId:", item.id ?? 0)
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
    
    func checkMutipleSchool() -> Bool {
        if staffDetailsCount?.count ?? 0 > 1 {
            switch staff_roll {
            case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                return true
            default:
                return false
            }
        }
        return false
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == recentActiveMenuCollection {
            let visibleIndexes = recentActiveMenuCollection.indexPathsForVisibleItems.map { $0.item }
            if let maxIndex = visibleIndexes.max() {
                pagecontroller.currentPage = maxIndex
            }
        }
    }
}

@available(iOS 14.0, *)
extension CustomDasboard: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView == recentActiveMenuCollection
        ? CGSize(width: 200, height: 90)
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
