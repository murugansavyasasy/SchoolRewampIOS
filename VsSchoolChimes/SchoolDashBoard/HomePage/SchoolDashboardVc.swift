//
//  HomePageVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit
import AVFoundation
import StoreKit
import Kingfisher

@available(iOS 14.0, *)
class SchoolDashboardVc: UIViewController,UITabBarDelegate, UISearchBarDelegate{
    
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var ViewDetailsBtn: UIButton!
    @IBOutlet weak var changeRollLbl: UILabel!
    @IBOutlet weak var loginDetailView: UIView!
    @IBOutlet weak var Searchbar: UISearchBar!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var SchoolNameLabel: UILabel!
    @IBOutlet weak var BellImage: UIImageView!
    @IBOutlet weak var schoolLogoImg: UIImageView!
    @IBOutlet weak var searchImgView: UIImageView!
    @IBOutlet weak var searchHeightCon: NSLayoutConstraint!
    
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollCollection: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var TopCv: UICollectionView!
    @IBOutlet weak var pageContorler: UIPageControl!
    @IBOutlet weak var bottomCv: UICollectionView!
    
    var advertisements: [String] = ["Ad 1: Special Offer",
                                    "Ad 2: Final Sale",
                                    "Ad 3: New Arrivals",
                                    "Ad 4: Discount Up to 50%"]
    var filteredItems: [MenuDetail]?
    let menuName = MenuStringFile()
    var menu_details: [MenuDetail]?
    var filteredMenu_details: [MenuDetail]?
    var getValue : Int!
    var searchItem = 0
    var currentIndex = 0
    var autoScrollTimer: Timer?
    private let tabBar = UITabBar()
    private lazy var secondVC = SettingsViewController()
    private lazy var thirdVC = SettingsViewController()
    private lazy var fourthVC = SettingsViewController()
    let MenuRedirect = MenuRedirectHandler.shared
    var currentPlaceholderIndex = 0
    var timer: Timer?
    let alert = CustomAlert()
    var isShowingAll = false
    var profileSwith : ProfileSwitchDelegate?
    var displayedCategories: [String] = []
    let newString = "Add"
    
    deinit {
        timer?.invalidate()
    }
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let is_staff = UserDefaultFileManager.getUserDetails()?.user_details?.is_staff
    let is_parent =  UserDefaultFileManager.getUserDetails()?.user_details?.is_parent
    let staff_roll = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(staff_roll == PriorityType.is_staff){
            SchoolNameLabel.text = staffDetails?.school_name
            AddressLabel.text = staffDetails?.school_address
            schoolLogoImg.kf.setImage(with: URL(string:staffDetails?.school_logo ?? ""))
            
            
        }
        else{
            if staffDetailsCount?.count ?? 0 > 1{
                SchoolNameLabel.text = staffDetails?.role
                
            }
            else{
                SchoolNameLabel.text = staffDetails?.school_name
                AddressLabel.text = staffDetails?.school_address
                schoolLogoImg.kf.setImage(with: URL(string:staffDetails?.school_logo ?? ""))
                
            }
            
        }
        
        
        if is_staff == true && is_parent == true{
            
            changeRollLbl.isHidden = false
            
        }else if is_staff == true{
            
            if staff_roll == PriorityType.is_staff{
                if staffDetailsCount?.count ?? 0 > 1{
                    changeRollLbl.isHidden = false
                }else{
                    changeRollLbl.isHidden = true
                }
            }else{
                changeRollLbl.isHidden = true
            }
            
        }
        
        
        
        schoolLogoImg.layer.cornerRadius = schoolLogoImg.frame.width/2
        schoolLogoImg.layer.borderWidth = 1
        schoolLogoImg.layer.borderColor = UIColor.black.cgColor
        StyleAndTranslater()
        setupVideoBackground()
        DeviceTokenAPIcall()
        //startAutoScroll()
        cellRegistration()
        Searchbar.addDoneButton()
        let value = UserDefaults.standard.integer(forKey: "passvalue")
        getValue = value
        Searchbar.delegate = self
        searchHeightCon.constant = 0
        bottomCv.isPrefetchingEnabled = true
        Searchbar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopAutoScroll), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopAutoScroll), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        let searchImage  = UITapGestureRecognizer(target: self, action:#selector(SearchViewHidden))
        searchImgView.addGestureRecognizer(searchImage)
        searchImgView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openNotification))
        BellImage.addGestureRecognizer(tap)
        BellImage.isUserInteractionEnabled = true
        
        let changerollTap = UITapGestureRecognizer(target: self, action: #selector(redirectAct))
        changeRollLbl.addGestureRecognizer(changerollTap)
        changeRollLbl.isUserInteractionEnabled = true
        
        let profileTap =  UITapGestureRecognizer(target: self, action: #selector(OpenProfile))
        schoolLogoImg.addGestureRecognizer(profileTap)
        schoolLogoImg.isUserInteractionEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),  // Right-center
            endPoint: CGPoint(x: 0, y: 0.5)     // Left-center
        )
        loginDetailView.applyGradient(
            colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    func StyleAndTranslater(){
        
        //MARK: UI Changes
        bottomView.layer.cornerRadius = 10
        bottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        bottomView.clipsToBounds = true
        
        reportView.layer.cornerRadius = 5
        reportView.layer.shadowColor = UIColor.black.cgColor
        reportView.layer.shadowOpacity = 0.5
        reportView.layer.shadowOffset = CGSize(width: 4, height: 4)
        reportView.layer.shadowRadius = 3
        reportView.layer.masksToBounds = false
        changeRollLbl.textColor = .link
        
        //MARK: Setting Font Style
        SchoolNameLabel.setFont(style: .title, size: FontSize.TitleSize)
        AddressLabel.setFont(style: .body, size: FontSize.BodySize)
        changeRollLbl.setFont(style: .body, size: FontSize.TitleSize)
    }
    
    func configureView(_ view: UIView,
                       gradientColors: [UIColor],
                       cornerRadius: CGFloat = 10,
                       opacity: CGFloat = 0.5,
                       lightenFactor: CGFloat = 0.3) {
        // Set corner radius
        view.layer.cornerRadius = cornerRadius
        view.layer.masksToBounds = true
        
        // Adjust colors for lightening and opacity
        let adjustedColors = gradientColors.map { color in
            color.blendedWithWhite(factor: lightenFactor).withAlphaComponent(opacity)
        }
        
        // Apply gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = adjustedColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.frame = view.bounds
        gradientLayer.cornerRadius = cornerRadius
        
        // Remove existing gradient layers to prevent duplication
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        // Insert the gradient at the lowest index
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupVideoBackground() {
        guard let path = Bundle.main.path(forResource: "Mathematics", ofType: "mp4") else { return }
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = loginDetailView.bounds
        playerLayer.opacity = 0.1
        playerLayer.videoGravity = .resizeAspectFill
        loginDetailView.layer.addSublayer(playerLayer)
        
        player.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottomCv.delegate = self
        bottomCv.dataSource = self
        get_dashboard_details()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear - View is about to disappear.")
        currentIndex = -1
    }
    
    @IBAction func ViewDetailsAct(_ sender: Any) {
        
        MenuRedirect.senderMarkAttendanceNavigate(from: self)
    }
    
    
    func OpenInside(from viewController: UIViewController){
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = viewController as? SKStoreProductViewControllerDelegate
        storeViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: "YOUR_APP_ID"]) { (loaded, error) in
            if loaded {
                viewController.present(storeViewController, animated: true)
            }else{
                print("can't open the appstore ❤️")
            }
        }
    }
    
    @IBAction func redirectAct() {
        dismiss(animated: true)
        
    }
    @IBAction func OpenProfile() {
        profileSwith?.switchProfile()
    }
    
    func cellRegistration(){
        bottomCv.register(UINib(nibName: CellConfingName.HomePageBottomCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.HomePageBottomCell)
        bottomCv.register(UINib(nibName:CellConfingName.seeMore, bundle: nil), forCellWithReuseIdentifier: CellConfingName.seeMore)
        TopCv.register(UINib(nibName: CellConfingName.HomePageTopCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.HomePageTopCell)
        
        TopCv.register(UINib(nibName: CellConfingName.PiechartCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.PiechartCVCell)
    }
    
    func restartAnimations() {
        
        if let cell = TopCv.cellForItem(at: IndexPath(row: 0, section: 0)) as? PiechartCVCell {
            // Reset shimmer view or any other animations
            cell.pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInExpo)
        }
        
        
        
    }
    @IBAction func assignment(_ sender: UIButton) {
        
        MenuRedirect.senderAssignmentNavigate(from: self)
    }
    @IBAction func onlineMeeting(_ sender: UIButton) {
        MenuRedirect.senderOnlineNavigate(from: self)
    }
    
    @IBAction func homeWork(_ sender: UIButton) {
        MenuRedirect.senderHomeWorkNavigate(from: self)
    }
    @IBAction func seeAllShow(_ sender: UIButton) {
        isShowingAll.toggle()
        seeAllButton.setTitle(!isShowingAll ? "See Less" : "See All", for: .normal)
        
        if isShowingAll {
            // Collapse back to show only the first 9 items
            if let menuDetails = menu_details {
                filteredMenu_details = Array(menuDetails.prefix(9))
                if filteredMenu_details?.count ?? 0 > 5 {
                    filteredMenu_details?.insert(MenuDetail(id: 66, name: "Add", unread_count: 0), at: 6)
                }
            }
        } else {
            // Expand to show all items
            filteredMenu_details = menu_details
        }
        
        bottomCv.reloadData() // Refresh the
        let contentViewHeight = bottomCv.collectionViewLayout.collectionViewContentSize.height
        collectionHeight.constant = contentViewHeight
    }
    func startAutoScroll() {
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
    }
    
    @objc func autoScroll() {
        let nextIndex = (currentIndex + 1) % 5
        let nextIndexPath = IndexPath(item: nextIndex, section: 0)
        TopCv.scrollToItem(at: nextIndexPath, at: .right, animated: true)
        currentIndex = nextIndex
        pageContorler.currentPage = currentIndex
        
    }
    
    @objc func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    @IBAction func openNotification(){
        let vc = NotificationViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
}



@available(iOS 14.0, *)
extension SchoolDashboardVc: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bottomCv{
            
            return filteredMenu_details?.count ?? 0
            
        }else{
            return 5
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == bottomCv{
            if indexPath.row == 6 {
                let adCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.seeMore, for: indexPath) as! seeMore
                adCell.advertisements = advertisements
                return adCell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.HomePageBottomCell , for: indexPath) as! BottomCVCell
                cell.MenuLbl.text = nil
                cell.MenuImgView.image  = nil
                
                let label = filteredMenu_details?[indexPath.row].name?.translated()
                if let name = filteredMenu_details?[indexPath.row].id {
                    let filteredItems = MenuRedirectHandler.shared.Imgitems.filter { $0.id == name}
                    let img = UIImage(named: filteredItems.first?.name ?? "")
                    cell.MenuImgView.image = img
                }
                cell.MenuLbl.setFont(style: .body, size: 10)
                cell.MenuLbl.text = label
                cell.GradientView.backgroundColor = .clr
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    cell.GradientView.animateView(enable: false)
                }
                return cell
            }
            
        }else{
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.PiechartCVCell , for: indexPath) as! PiechartCVCell
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.HomePageTopCell , for: indexPath) as! TopCVCell
                
                return cell
            }
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 6 {
            return
        }
        if collectionView == bottomCv{
            
            let menuItem = filteredMenu_details?[indexPath.row].id
            Menu_id.staffSelectedMenuId = menuItem ?? 0
            switch menuItem {
            case 1: //
                MenuRedirect.senderAbsenteesReport(from: self)
            case 2:
                MenuRedirect.senderAssignmentNavigate(from: self)
            case 3:
                MenuRedirect.senderMarkAttendence(from: self)
                //            case 4:
                
            case 5:
                MenuRedirect.senderPtmNavigate(from: self)
            case 7:
                MenuRedirect.senderCommunicationNavigate(from: self)
            case 8:
                MenuRedirect.senderDailyCollectionNavigate(from: self)
            case 9:
                MenuRedirect.senderEventNavigate(from: self)
                
            case 14:
                MenuRedirect.senderFeePendingNavigate(from: self)
            case 15:
                MenuRedirect.senderHomeWorkNavigate(from: self)
            case 17:
                MenuRedirect.Senderchat(from: self)
            case 18:
                MenuRedirect.senderLeaveRequestNavigate(from: self)
            case 19:
                MenuRedirect.senderLessonplanNavigate(from: self)
            case 21:
                if checkMutipleSchool(){
                    MenuRedirect.SchoolListVc(from: self)
                }else{
                    MenuRedirect.senderMarkAttendanceNavigate(from: self)
                }
            case 22:
                MenuRedirect.senderMgmt(from: self)
            case 23:
                MenuRedirect.senderNoticeboardNavigate(from: self)
            case 24:
                MenuRedirect.senderOnlineNavigate(from: self)
            case 26:
                MenuRedirect.senderPtmNavigate(from: self)
            case 28:
                MenuRedirect.senderLeaveRequestNavigate(from: self)
            case 30:
                MenuRedirect.senderSchoolNeedsNavigate(from: self)
            case 31:
                MenuRedirect.senderSchoolStrength(from: self)
            case 33:
                if checkMutipleSchool(){
                    MenuRedirect.SchoolListVc(from: self)
                }else{
                    MenuRedirect.StaffWiseAttendance(from: self)
                }
            case 35:
                MenuRedirect.senderStudentreportNavigate(from: self)
            case 36:
                MenuRedirect.senderImportantInfoNavigate(from: self)
                
            case 39 :
                MenuRedirect.senderAttachment(from: self)
                
            default:
                // Handle unknown menu items if needed
                print("MenuId",menuItem)
                break
            }
            
        }
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

@available(iOS 14.0, *)
extension SchoolDashboardVc: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 6{
            return CGSize(width: collectionView.frame.width, height: 170)
        }
        
        let width = (collectionView.frame.width) / 3
        let padding: CGFloat = 10
        let maxTextWidth = width - padding * 2
        
        let label = filteredMenu_details?[indexPath.row].name?.translated()
        let font = UIFont.preferredFont(forTextStyle: .body).withSize(10) // Use the same font style and size as set in the cell
        let textHeight = label?.height(withConstrainedWidth: maxTextWidth, font: font) ?? 0
        
        let height = max(textHeight + padding * 2, width - 10)
        return CGSize(width: width, height: height + 10)
    }
}


@available(iOS 14.0, *)
extension SchoolDashboardVc: UISearchBarDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        Searchbar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Searchbar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchItem = 1
        if searchText.isEmpty {
            filteredItems = menu_details
            filteredMenu_details = menu_details.map { Array($0.prefix(9)) }
        } else {
            filteredItems = menu_details?.filter { $0.name?.lowercased().contains(searchText.lowercased()) ?? false }
        }
        
        bottomCv.reloadData()
    }
    
    
    //MARK: Searchview Hide
    @objc func SearchViewHidden() {
        
        if searchHeightCon.constant == 0{
            searchHeightCon.constant = 56
        }else{
            searchHeightCon.constant = 0
        }
    }
    
    func DeviceTokenAPIcall(){
        let secureID = SecureIDManager.getSecureID()
        
        var deviceToken: String? // Use var instead of let
        let mobile_num = UserDefaultFileManager.getLoginCredentials()?.mobile_number
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            deviceToken = appDelegate.DeviceToken
        }
        
        APIService.shared
            .makeApi(url: ServiceUrl.auth_device_token, parameters:[
                
                COMMON_PARAMETER.mobile_number : mobile_num ?? "" ,
                DeviceTokenStringFile.device_token : deviceToken ?? "",
                COMMON_PARAMETER.device_type : API_PARAMS_HOTCODE.device_type,
                DeviceTokenStringFile.secure_id : secureID
                
            ] , type: ApitTypeSringFile.POST, token: ServiceUrl.token){ [self] (
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
    func get_dashboard_details() {
        APIService.shared.makeApi(
            url: ServiceUrl.get_dashboard_details,
            parameters: ["member_type": "staff"],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<DashboardResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                print("Dashboard Response:", response)
                
                DispatchQueue.main.async {
                    if response.status == true, let details = response.data?.first?.menu_details {
                        self.menu_details = details
                        
                        // Extract names from menu_details
                        self.displayedCategories = details.prefix(9).map { $0.name ?? "" }
                        self.filteredMenu_details = Array(details.prefix(9))
                        
                        // Insert "Add" item if count > 5
                        if self.filteredMenu_details?.count ?? 0 > 5 {
                            self.filteredMenu_details?.insert(MenuDetail(id: 66, name: "Add", unread_count: 0), at: 6)
                        }
                        
                        self.filteredItems = details
                        self.bottomCv.reloadData()
                        
                        // Calculate and apply dynamic height
                        let contentViewHeight = self.bottomCv.collectionViewLayout.collectionViewContentSize.height
                        let maxHeight = self.containerView.frame.height
                        - 140
                        - self.SchoolNameLabel.frame.height
                        - self.AddressLabel.frame.height
                        
                        self.collectionHeight.constant = max(contentViewHeight, maxHeight)
                        
                        // Enable scrolling if more than 6 items
                        self.scrollCollection.isScrollEnabled = details.count > 6
                    } else {
                        // Fallback if menu is nil or status false
                        self.displayedCategories = []
                        self.filteredItems = []
                        self.bottomCv.reloadData()
                        self.collectionHeight.constant = 500 // Default height
                        self.scrollCollection.isScrollEnabled = false
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error:", error.localizedDescription)
                }
            }
        }
    } 
}
