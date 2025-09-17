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
    
    // MARK: - SideMenuDelegate
    func meunu(viewController: UIViewController?) {
        hideSideMenu()
        guard let vc = viewController else {
            dismiss(animated: true)
            return
        }
        if vc is SettingsViewController || vc is UpdateProfileVC || vc is HelpVc {
            navigationController?.pushViewController(vc, animated: true)
        } else if vc is LogoutViewController {
            delegate?.back(logout: false)
        }else{
            delegate?.back(logout: false)
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var headerView: HeaderWaveView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var pagecontroller: UIPageControl!
    @IBOutlet weak var recentActiveMenuCollection: UICollectionView!
    @IBOutlet weak var MenuCollection: UICollectionView!
    
    // MARK: - Properties
    var recentMenuItems: [MenuDetail]?
    var menu_details: [MenuDetail] = []
    
    var childDetailscount = UserDefaultFileManager.getUserDetails()?.user_details?.child_details
    var childDetails = UserDefaultFileManager.get_child_Details()
    
    let MenuRedirect = MenuRedirectHandler.shared
    var sideMenu: SideMenuVC?
    var dimmedView: UIView?
    var delegate: backNavigation?
    
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
        
        setupHeaderView()
        setupLabels()
        setupProfileImage()
        get_dashboard_details()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - API Calls
    func get_dashboard_details() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        
        let mobile_num = UserDefaultFileManager.getLoginCredentials()?.mobile_number
        APIService.shared.makeApi(
            url: ServiceUrl.get_dashboard_details,
            parameters: ["member_type": "parent", "mobile_number": mobile_num ?? ""],
            type: ApitTypeSringFile.GET,
            token: childDetails?.access_token ?? ""
        ) { [weak self] (result: Result<MenuResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self.hideLottieProgressLoader()
                }
                switch result {
                case .success(let response):
                    if response.status == true, let details = response.data?.first {
                        self.menu_details = details.menus ?? []
                        self.recentMenuItems = details.frequently_used
                        self.MenuCollection.reloadData()
                        self.recentActiveMenuCollection.isHidden = (details.frequently_used?.isEmpty ?? true)
                        self.pagecontroller.isHidden = (details.frequently_used?.count ?? 0) < 2
                        self.pagecontroller.numberOfPages = self.recentMenuItems?.count ?? 0
                        self.recentActiveMenuCollection.reloadData()
                        self.get_MenuCount() // 🔹 after menus loaded
                    } else {
                        self.MenuCollection.reloadData()
                    }
                    
                case .failure(let error):
                    print("API Error:", error.localizedDescription)
                }
            }
        }
    }

    func get_MenuCount() {
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_dashboard_menu_counts,
            parameters: ["member_type": "parent"],
            type: ApitTypeSringFile.GET,
            token: childDetails?.access_token ?? ""
        ) { [weak self] (result: Result<MenuCountResponse, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status == true,
                       let details = response.data?.first,
                       let newDetails = details.menu_details {
                        
                        let changedIndexPaths = self.updateMenuCounts(with: newDetails)
                        if !changedIndexPaths.isEmpty {
                            self.MenuCollection.reloadItems(at: changedIndexPaths)
                        }
                    }
                case .failure(let error):
                    print("API Error:", error.localizedDescription)
                }
            }
        }
    }

    func updateMenuCounts(with newDetails: [MenuCountDetail]) -> [IndexPath] {
        var changedIndexPaths: [IndexPath] = []
        
        for newItem in newDetails {
            if let newId = newItem.id,
               let index = menu_details.firstIndex(where: { $0.id == newId }) {
                
                if menu_details[index].unread_count != newItem.unread_count {
                    menu_details[index].unread_count = newItem.unread_count
                    changedIndexPaths.append(IndexPath(item: index, section: 0))
                }
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
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
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
        
        let menuVC = SideMenuVC(nibName: "SideMenuVC", bundle: nil)
        menuVC.view.frame = CGRect(x: -250, y: 0, width: 250, height: window.bounds.height)
        applyGradientBackground(to: menuVC.view)
        menuVC.isStudent = true
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(hideSideMenu))
        swipeGesture.direction = .left
        menuVC.view.addGestureRecognizer(swipeGesture)
        
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
        return collectionView == recentActiveMenuCollection ? (recentMenuItems?.count ?? 0) : menu_details.count
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
            let item = menu_details[indexPath.item]
            if let id = item.id {
                let filteredItems = MenuRedirectHandler.shared.Imgitems.filter { $0.id == id }
                let img = UIImage(named: filteredItems.first?.name ?? "")
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
            menuItem = menu_details[indexPath.row].id
            menuName = menu_details[indexPath.row].name ?? ""
        } else {
            menuItem = recentMenuItems?[indexPath.row].id
            menuName = recentMenuItems?[indexPath.row].name ?? ""
        }

        MenuStringFile.selectedMenuName = menuName
        guard let menuId = menuItem else { return }

        switch menuId {
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
        case 39: MenuRedirect.receiverAttachment(from: self, notificationId: "")
        case 40: MenuRedirect.receiverPauckt(from: self)
        default: break
        }
    }
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
