// CustomDashboard.swift
// School Chimes

import UIKit

@available(iOS 14.0, *)
class CustomDasboard: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SideMenuDelegate {
    func meunu(viewController: UIViewController?) {
        hideSideMenu()

        guard let vc = viewController else {
            dismiss(animated: true)
            return
        }
        // 👇 Optional: Hide tab bar when pushing
//        vc.hidesBottomBarWhenPushed = true

        if vc is SettingsViewController || vc is ProfileViewController || vc is HelpVc {
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            delegate?.back()
        }
    }
    
    
    @IBOutlet weak var headerView: HeaderWaveView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var pagecontroller: UIPageControl!
    @IBOutlet weak var recentActiveMenuCollection: UICollectionView!
    @IBOutlet weak var MenuCollection: UICollectionView!
    
    // MARK: - Sample Data
    var recentMenuItems: [MenuDetail]?
    var menu_details: [MenuDetail]?
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let is_staff = UserDefaultFileManager.getUserDetails()?.user_details?.is_staff
    let is_parent =  UserDefaultFileManager.getUserDetails()?.user_details?.is_parent
    let staff_roll = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role
    let MenuRedirect = MenuRedirectHandler.shared
    var sideMenu: SideMenuVC?
    var dimmedView: UIView?
    var delegate: backNavigation?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cells
        recentActiveMenuCollection.register(UINib(nibName: "TopCVCell", bundle: nil), forCellWithReuseIdentifier: "TopCVCell")
        MenuCollection.register(UINib(nibName: "CustomMenuCVC", bundle: nil), forCellWithReuseIdentifier: "CustomMenuCVC")
        // Delegates and DataSources
        recentActiveMenuCollection.delegate = self
        recentActiveMenuCollection.dataSource = self
        MenuCollection.delegate = self
        MenuCollection.dataSource = self
        DeviceTokenAPIcall()
        setupHeaderView()
        setupLabels()
        setupProfileImage()
        getacadmicYr{
            self.get_dashboard_details()
        }
    }
    
    func get_dashboard_details() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        let mobile_num = UserDefaultFileManager.getLoginCredentials()?.mobile_number
        APIService.shared.makeApi(
            url: ServiceUrl.get_dashboard_details,
            parameters: ["member_type": "staff","mobile_number":mobile_num ?? ""],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<MenuResponse, Error>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self.hideLottieProgressLoader()
                }

                switch result {
                case .success(let response):
                    if response.status == true, let details = response.data?.first {
                        self.menu_details = details.menus
                        self.recentMenuItems = details.frequently_used
                        self.MenuCollection.reloadData()
                        self.recentActiveMenuCollection.isHidden = details.frequently_used?.count == 0
                        self.pagecontroller.isHidden = details.frequently_used?.count == 0
                        self.pagecontroller.numberOfPages = self.recentMenuItems?.count ?? 0
                        self.recentActiveMenuCollection.reloadData()
                    } else {
                        print("No data or status false")
                        self.menu_details = []
                        self.MenuCollection.reloadData()
                    }

                case .failure(let error):
                    print("API Error:", error.localizedDescription)
                    // Optionally show alert here
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        headerView.startWaveAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        headerView.stopWaveAnimation()
    }
    
    private func setupHeaderView() {
        headerView.setNeedsDisplay()
    }
    @IBAction func SideMenu(_ sender: UIButton) {
        showSideMenu()
    }
    
    func showSideMenu() {
        guard let window = UIApplication.shared.windows.first else { return }
        
        // Dimmed Background
        let dimView = UIView(frame: window.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideSideMenu))
        dimView.addGestureRecognizer(tapGesture)
        window.addSubview(dimView)
        self.dimmedView = dimView
        
        // Side Menu Setup
        let menuVC = SideMenuVC(nibName: "SideMenuVC", bundle: nil)
        menuVC.view.frame = CGRect(x: -250, y: 0, width: 250, height: window.bounds.height)
        applyGradientBackground(to: menuVC.view)
        
        // 👉 Add swipe gesture for left swipe
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideSideMenu))
        swipeGesture.direction = .left
        menuVC.view.addGestureRecognizer(swipeGesture)
        
        menuVC.delegate = self
        window.addSubview(menuVC.view)
        window.rootViewController?.addChild(menuVC)
        menuVC.didMove(toParent: window.rootViewController)
        self.sideMenu = menuVC
        
        // Animate In
        UIView.animate(withDuration: 0.3) {
            menuVC.view.frame.origin.x = 0
        }
    }
    func getacadmicYr(onComplete: @escaping () -> Void){
        APIService.shared
            .makeApi(url: ServiceUrl.comm_recipient_get_academic_year_list , parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [] (
                result:Result <get_academic_yearSuc,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        localData.accidamic_year_data = successMessage
                    }else{
                        localData.accidamic_year_data = successMessage
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
        onComplete()
    }
    func DeviceTokenAPIcall(){
        let secureID = SecureIDManager.getSecureID()
        
        var deviceToken: String? // Use var instead of let
        let mobile_num = UserDefaultFileManager.getLoginCredentials()?.mobile_number
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            deviceToken = appDelegate.DeviceToken
        }
        
        APIService.shared
            .makeApi(
                url: ServiceUrl.auth_device_token,
                parameters:[
                    
                    COMMON_PARAMETER.mobile_number : mobile_num ?? "" ,
                    DeviceTokenStringFile.device_token : deviceToken ?? "",
                    COMMON_PARAMETER.device_type : API_PARAMS_HOTCODE.device_type,
                    DeviceTokenStringFile.secure_id : secureID,
                    DeviceTokenStringFile.device_info : [
                        
                        DeviceTokenStringFile.manufacturer : "iphone" ,
                        DeviceTokenStringFile.model : "iphone12",
                        DeviceTokenStringFile.device : "iphone",
                        DeviceTokenStringFile.brand : "iphone",
                        DeviceTokenStringFile.hardware : "",
                        DeviceTokenStringFile.product : "",
                        DeviceTokenStringFile.os_version : 8.1,
                        DeviceTokenStringFile.sdk_int : 33,
                        DeviceTokenStringFile.app_version : 1
                    ]
                    
                    
                ] ,
                type: ApitTypeSringFile.POST,
                token: ServiceUrl.token
            ){ [self] (
                result : Result<DeviceTokenResponseSuc,
                Error>
            ) in
                
                switch result {
                    
                case.success(let succesmessage) :
                    
                    if succesmessage.status == true {
                        
                        DispatchQueue.main.async { [self] in
                            
                            print("Status true5656565656565656")
                        }
                    }else {
                        
                        DispatchQueue.main.async {
                            print(" status false")
                        }
                    }
                    
                case.failure(let error) :
                    
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
                
            }
    }
    func applyGradientBackground(to view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        gradientLayer.colors = [
            UIColor(red: 0.31, green: 0.58, blue: 0.98, alpha: 1.0).cgColor, // Light blue
            UIColor(red: 0.18, green: 0.42, blue: 0.85, alpha: 1.0).cgColor  // Dark blue
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        // Remove existing gradient layers to avoid layering
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        view.layer.insertSublayer(gradientLayer, at: 0)
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
    private func setupLabels() {
        welcomeLabel.text = staffDetails?.school_name
        welcomeLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        welcomeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        nameLabel.text = staffDetails?.name
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    private func setupProfileImage() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    }
    
    // MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recentActiveMenuCollection {
            return recentMenuItems?.count ?? 0
        } else {
            return menu_details?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recentActiveMenuCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCVCell", for: indexPath) as! TopCVCell
            if let item = recentMenuItems?[indexPath.item]{
                cell.configure(with: item)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomMenuCVC", for: indexPath) as! CustomMenuCVC
            let item = menu_details?[indexPath.item]
            if let name = item?.id {
                    let filteredItems = MenuRedirectHandler.shared.Imgitems.filter { $0.id == name }
                    let img = UIImage(named: filteredItems.first?.name ?? "")
                    cell.iconBtn.setImage(img, for: .normal)
                    cell.imenuName.text = item?.name
                    cell.menuCondent.text = item?.description
            }
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Pick correct menu based on collectionView
        let selectedItem: MenuDetail?
        if collectionView == recentActiveMenuCollection {
            selectedItem = recentMenuItems?[indexPath.row]
        } else {
            selectedItem = menu_details?[indexPath.row]
        }
        
        guard let item = selectedItem else { return }
        
        Menu_id.staffSelectedMenuId = item.id ?? 0
        MenuStringFile.selectedMenuName = item.name ?? ""
        
        // Short helper for avoiding repeated code
        func navigateOrSchoolList(_ defaultAction: () -> Void) {
            if checkMutipleSchool() {
                MenuRedirect.SchoolListVc(from: self)
            } else {
                defaultAction()
            }
        }
        
        switch item.id {
        case 1:
            navigateOrSchoolList { MenuRedirect.senderAbsenteesReport(from: self) }
        case 2:
            navigateOrSchoolList { MenuRedirect.senderAssignmentNavigate(from: self) }
        case 3:
            navigateOrSchoolList { MenuRedirect.senderMarkAttendence(from: self) }
        case 5:
            MenuRedirect.senderPtmNavigate(from: self)
        case 7:
            MenuRedirect.senderCommunicationNavigate(from: self)
        case 8:
            navigateOrSchoolList { MenuRedirect.senderDailyCollectionNavigate(from: self) }
        case 9:
            MenuRedirect.senderEventNavigate(from: self)
        case 14:
            navigateOrSchoolList { MenuRedirect.senderFeePendingNavigate(from: self) }
        case 15:
            navigateOrSchoolList { MenuRedirect.senderHomeWorkNavigate(from: self) }
        case 17:
            navigateOrSchoolList { MenuRedirect.Senderchat(from: self) }
        case 18:
            MenuRedirect.senderLeaveRequestNavigate(from: self)
        case 19:
            navigateOrSchoolList { MenuRedirect.senderLessonplanNavigate(from: self) }
        case 21:
            navigateOrSchoolList { MenuRedirect.senderMarkAttendanceNavigate(from: self) }
        case 22:
            navigateOrSchoolList { MenuRedirect.senderMgmt(from: self) }
        case 23:
            MenuRedirect.senderNoticeboardNavigate(from: self)
        case 24:
            MenuRedirect.senderOnlineNavigate(from: self)
        case 26:
            MenuRedirect.senderPtmNavigate(from: self)
        case 28:
            MenuRedirect.senderLeaveRequestNavigate(from: self)
        case 29:
            navigateOrSchoolList { MenuRedirect.senderEventNavigate(from: self) }
        case 30:
            MenuRedirect.senderSchoolNeedsNavigate(from: self)
        case 31:
            navigateOrSchoolList { MenuRedirect.senderSchoolStrength(from: self) }
        case 33:
            navigateOrSchoolList { MenuRedirect.StaffWiseAttendance(from: self) }
        case 35:
            navigateOrSchoolList { MenuRedirect.senderStudentreportNavigate(from: self) }
        case 36:
            MenuRedirect.senderImportantInfoNavigate(from: self)
        case 38:
            MenuRedirect.SenderLSRWVCNavigate(from: self)
        case 39:
            MenuRedirect.senderAttachment(from: self)
        default:
            print("Unknown menuId:", item.id ?? 0)
        }
    }

}
@available(iOS 14.0, *)
extension CustomDasboard: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == recentActiveMenuCollection {
            return CGSize(width: 200, height: 90) // Horizontal scroll items
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
    func checkMutipleSchool() -> Bool {
        if staffDetailsCount?.count ?? 0 > 1 {
            switch staff_roll {
            case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                return true
            default:
                print("Unhandled staff role")
                return false
            }
        }
        return false
    }
}

struct DashboardMenu {
    let icon: String
    let title: String
    let subtitle: String
}
