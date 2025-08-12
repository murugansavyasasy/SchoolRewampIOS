//
//  CustomParentDashboardVC.swift
//  School Chimes
//
//  Created by Chandhru on 01/08/25.
//

import UIKit
protocol backNavigation{
    func back()
}
@available(iOS 14.0, *)
class CustomParentDashboardVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SideMenuDelegate {
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
    var childDetailscount = UserDefaultFileManager.getUserDetails()?.user_details?.child_details
    var childDetails = UserDefaultFileManager.get_child_Details()
    let MenuRedirect = MenuRedirectHandler.shared
    var sideMenu: SideMenuVC?
    var dimmedView: UIView?
    var delegate: backNavigation?
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        // Register cells
        recentActiveMenuCollection.register(UINib(nibName: "TopCVCell", bundle: nil), forCellWithReuseIdentifier: "TopCVCell")
        MenuCollection.register(UINib(nibName: "CustomMenuCVC", bundle: nil), forCellWithReuseIdentifier: "CustomMenuCVC")
        pagecontroller.numberOfPages = recentMenuItems?.count ?? 0
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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func get_dashboard_details() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        APIService.shared.makeApi(
            url: ServiceUrl.get_dashboard_details,
            parameters: ["member_type": "parent","mobile_number":childDetails?.whatsapp_number ?? ""],
            type: ApitTypeSringFile.GET,
            token: childDetails?.access_token ?? ""
        ) { [weak self] (result: Result<MenuResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    if #available(iOS 15.0, *) {
                        self.hideLottieProgressLoader()
                    }
                    if response.status == true, let details = response.data?.first {
                        self.menu_details = details.menus
                        self.recentMenuItems = details.frequently_used
                        self.MenuCollection.reloadData()
                        self.recentActiveMenuCollection.isHidden = details.frequently_used?.count == 0
                        self.pagecontroller.isHidden = details.frequently_used?.count == 0
                    } else {
                        self.MenuCollection.reloadData()
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error:", error.localizedDescription)
                }
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        headerView.startWaveAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        headerView.stopWaveAnimation()
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
            let item = recentMenuItems?[indexPath.item]
//            cell.configure(with: item)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomMenuCVC", for: indexPath) as! CustomMenuCVC
            let item = menu_details?[indexPath.item]
            if let name = item?.id {
                if #available(iOS 14.0, *) {
                    let filteredItems = MenuRedirectHandler.shared.Imgitems.filter { $0.id == name }
                    let img = UIImage(named: filteredItems.first?.name ?? "")
                    cell.iconBtn.setImage(img, for: .normal)
                    cell.imenuName.text = item?.name
                    cell.menuCondent.text = "Lorem ipsum dolor sit amet.Lorem ipsum dolor sit amet."
                }
            }
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView != recentActiveMenuCollection {
            
            let menuItem = menu_details?[indexPath.row].id
            MenuStringFile.selectedMenuName = menu_details?[indexPath.row].name ?? ""
            switch menuItem {
            case 2:
                MenuRedirect.receiverAssignmentNavigate(from: self)
            case 4:
                MenuRedirect.receiverAttendancereport(from: self)
            case 5:
                MenuRedirect.receiverCertificateRequest(from: self)
            case 6:
                MenuRedirect.receiverclassTimeTable(from: self)
            case 7:
                MenuRedirect.receiverCommunicationNavigate(from: self)
            case 9:
                MenuRedirect.receiverEvent(from: self)
            case 10:
                MenuRedirect.resiverExamMark(from: self)
            case 12:
                MenuRedirect.receiverFeeDetails(from: self)
            case 13:
                break    //fee payment
            case 15:
                MenuRedirect.receiverHomework(from: self)
            case 16:
                MenuRedirect.receiverchat(from: self)
            case 20:
                MenuRedirect.receiverLsrwNavigate(from: self)
            case 23:
                MenuRedirect.receiverNoticeBoardNavigate(from: self)
            case 24:
                MenuRedirect.receiverOnlineNavigate(from: self)
            case 25:
                MenuRedirect.receiverFeeDetails(from: self)
            case 26:
                MenuRedirect.receiverPtmNavigate(from: self)
            case 27:
                MenuRedirect.QuizExam(from: self)
            case 28:
                MenuRedirect.LeaveRquest(from: self)
            case 36:
                MenuRedirect.senderImportantInfoNavigate(from: self)
            case 39:
                MenuRedirect.receiverAttachment(from: self)
            case 40:
                MenuRedirect.receiverPauckt(from: self)
            default:
                break
            }

        }
        
    }
}
@available(iOS 14.0, *)
extension CustomParentDashboardVC: UICollectionViewDelegateFlowLayout {
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
}
