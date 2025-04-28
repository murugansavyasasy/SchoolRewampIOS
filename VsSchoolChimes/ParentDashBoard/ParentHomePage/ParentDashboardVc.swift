//
//  ParentHomePageVc.swift
//  VsSchoolChimes
//
//  Created by Admin on 31/01/25.
//

import UIKit
import AVFoundation
import Kingfisher

@available(iOS 14.0, *)
class ParentDashboardVc: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    @IBOutlet weak var seeAllButton: UIButton!
    @IBOutlet weak var Profileimage: UIImageViewX!
    @IBOutlet weak var changeRollLbl: UILabel!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var templateview: UIView!
    @IBOutlet weak var profileFullview: UIView!
    @IBOutlet weak var loginDetailView: UIView!
    @IBOutlet weak var Searchbar: UISearchBar!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var SchoolNameLabel: UILabel!
    @IBOutlet weak var BellImage: UIImageView!
    @IBOutlet weak var searchImgView: UIImageView!
    @IBOutlet weak var searchHeightCon: NSLayoutConstraint!
    @IBOutlet weak var scrollCollection: UIScrollView!
    
    @IBOutlet weak var bottomCv: UICollectionView!
    @IBOutlet weak var userNameLbl: UILabel!
    var filteredItems: [MenuDetail]?
    var getValue : Int!
    var searchItem = 0
    var currentIndex = 0
    var autoScrollTimer: Timer?
    
    private lazy var secondVC = SettingsViewController()
    private lazy var thirdVC = SettingsViewController()
    private lazy var fourthVC = SettingsViewController()
    let MenuRedirect = MenuRedirectHandler.shared
    var menu_details: [MenuDetail]?
    var filteredMenu_details: [MenuDetail]?
    var currentPlaceholderIndex = 0
    var timer: Timer?
    let alert = CustomAlert()
    var currentSelectedIndex = 0
    var isShowingAll = false
    private var firstArray: [String] = []
    private var secondArray: [String] = []
   
    let advertisements = [
        "Ad 1: Special Offer",
        "Ad 2: Final Sale",
        "Ad 3: New Arrivals",
        "Ad 4: Discount Up to 50%"
    ]
    var displayedCategories: [String] = []
    var indexNo = 0
    let newString = "Add"
    var childDetailscount = UserDefaultFileManager.getUserDetails()?.user_details?.child_details
    var childDetails = UserDefaultFileManager.get_child_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        bottomCv.delegate = self
        bottomCv.dataSource = self
        Profileimage.layer.borderWidth = 1
        Profileimage.layer.borderColor = UIColor.black.cgColor
        let is_staff = UserDefaultFileManager.getUserDetails()?.user_details?.is_staff
        let is_parent =  UserDefaultFileManager.getUserDetails()?.user_details?.is_parent
        
        if(is_staff == true) &&  (is_parent == true){
            changeRollLbl.isHidden = false
        
        }else{
            if childDetailscount?.count ?? 0 > 1{
                changeRollLbl.isHidden = false
            }else{
                changeRollLbl.isHidden = true
            }
            
        }
        
        userNameLbl.text = "Hello, " + (childDetails?.name ?? "")
            SchoolNameLabel.text = childDetails?.school_name
        AddressLabel.text = childDetails?.address
        Profileimage.kf.setImage(with: URL(string: childDetails?.profile ?? ""))
        
        DeviceTokenAPIcall()
        get_dashboard_details()
        StyleAndTranslater()
        
       
        
        cellRegistration()
        //startPlaceholderRotation()
        Searchbar.addDoneButton()
        
        let midIndex = displayedCategories.count / 2
        firstArray = Array(MenuRedirect.receiverItems.prefix(midIndex))  // First half
        secondArray = Array(MenuRedirect.receiverItems.suffix(from: midIndex))  // Second half
        
        setupVideoBackground()
        
        let value = UserDefaults.standard.integer(forKey: "passvalue")
        getValue = value
        Searchbar.delegate = self
        searchHeightCon.constant = 0
        
        bottomCv.isPrefetchingEnabled = true
        Searchbar.delegate = self
        
        setTapgesture()
    }
    
    @IBAction func ViewDetailsBtn(_ sender: Any) {
        MenuRedirect.receiverAttendancereport(from: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.applyGradient(
            colors: [
                Colornames.gradientBlue,  // Green
                Colornames.gradientgreen   // Blue
            ],
            startPoint: CGPoint(x: 1, y: 0.5),  // Right-center
            endPoint: CGPoint(x: 0, y: 0.5)     // Left-center
        )
    }
    
    func configureView(
        _ view: UIView,
        gradientColors: [UIColor],
        cornerRadius: CGFloat = 10,
        opacity: CGFloat = 0.5, // Opacity for the gradient
        lightenFactor: CGFloat = 0.3 // Factor to lighten colors (0 = no change, 1 = full white)
    ) {
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
    
    func StyleAndTranslater(){
        //MARK: UI Changes
        changeRollLbl.textColor = .link
        templateview.layer.cornerRadius = 10 // Adjust as needed
        templateview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top-left and Top-right corners
        templateview.clipsToBounds = true // Ensures the corners are clipped
        
        reportView.layer.cornerRadius = 5
        reportView.layer.shadowColor = UIColor.black.cgColor
        reportView.layer.shadowOpacity = 0.5
        reportView.layer.shadowOffset = CGSize(width: 4, height: 4)
        reportView.layer.shadowRadius = 3
        reportView.layer.masksToBounds = false
        
        profileFullview.layer.cornerRadius =  30
        loginDetailView.layer.cornerRadius =  30
       
        
        
        //MARK: Set Font Style
        changeRollLbl.setFont(style: .body, size: FontSize.TitleSize)
        SchoolNameLabel.setFont(style: .title, size: FontSize.TitleSize)
        AddressLabel.setFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Translate
        Searchbar.placeholder = CommonStringFile.Search.translated()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear - View has appeared on the screen.")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear - View is about to disappear.")
        currentIndex = -1
    }
    
    @IBAction func redirectAct() {
        dismiss(animated: true)
        
    }
    @IBAction func gotoProfile() {
        let vc = ProfileViewController(nibName: nil, bundle: nil)
        vc.passvalue = 2
        vc.HideBackButton = false
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func setupVideoBackground() {
        guard let path = Bundle.main.path(forResource: "Mathematics", ofType: "mp4") else { return }
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = profileFullview.bounds
        playerLayer.opacity = 0.1
        playerLayer.videoGravity = .resizeAspectFill
        profileFullview.layer.addSublayer(playerLayer)
        player.play()
    }
    
    
    func applyGradient(colours: [CGColor],xstart:Double,ystart:Double) {
        if let existingGradientLayer = profileFullview.layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            existingGradientLayer.removeFromSuperlayer()
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = profileFullview.bounds
        gradientLayer.colors = colours
        gradientLayer.startPoint = CGPoint(x: xstart, y: ystart)  // Top-left
        gradientLayer.endPoint = CGPoint(x: 0.9, y: 0.9)    // Bottom-right
        profileFullview.layer.insertSublayer(gradientLayer, at: 0)
        profileFullview.layer.masksToBounds = true
        
    }
    //MARK: Cell Registration
    func cellRegistration(){
        bottomCv.register(UINib(nibName: CellConfingName.HomePageBottomCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.HomePageBottomCell)
        bottomCv.register(UINib(nibName: CellConfingName.seeMore, bundle: nil), forCellWithReuseIdentifier: CellConfingName.seeMore)
        
    }
    
    //MARK: Set Tap Gesture
    func setTapgesture(){
        
        let searchImage  = UITapGestureRecognizer(target: self, action:#selector(SearchViewHidden))
        searchImgView.addGestureRecognizer(searchImage)
        searchImgView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openNotification))
        BellImage.addGestureRecognizer(tap)
        BellImage.isUserInteractionEnabled = true
        
        let redirectGesture =  UITapGestureRecognizer(target: self, action: #selector(redirectAct))
        changeRollLbl.addGestureRecognizer(redirectGesture)
        
        let profiletap = UITapGestureRecognizer(target: self, action: #selector(gotoProfile))
        Profileimage.addGestureRecognizer(profiletap)
        Profileimage.isUserInteractionEnabled = true
    }
    
    
    @IBAction func openNotification(){
        let vc = NotificationViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
}


//MARK: Collectionview Delegate
@available(iOS 14.0, *)
extension ParentDashboardVc: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMenu_details?.count ?? 0 // Ensure ItemnCount matches your data source
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Row: \(indexPath.row)")
        
        if indexPath.row == 6 {
            // Handle the "seeMore" cell
            let adCell = collectionView.dequeueReusableCell(withReuseIdentifier:CellConfingName.seeMore, for: indexPath) as! seeMore
            
            adCell.advertisements = advertisements
            adCell.adCollectionView.reloadData()
            return adCell
        } else {
            // Handle regular cells
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.HomePageBottomCell, for: indexPath) as! BottomCVCell
            cell.MenuLbl.text = nil
            cell.MenuImgView.image = nil
            
            
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
    }
    @IBAction func seeAllShow(_ sender: UIButton) {
        isShowingAll.toggle()
           seeAllButton.setTitle(!isShowingAll ? "See Less" : "See All", for: .normal)
           
           if isShowingAll{
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
           // Toggle the state
           bottomCv.reloadData()
           let contentViewHeight = bottomCv.collectionViewLayout.collectionViewContentSize.height
           collectionHeight.constant = contentViewHeight
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Ignore taps on the "seeMore" cell (indexPath.row == 6)
        if indexPath.row == 6 {
            return
        }
        
        if indexPath.row < MenuRedirect.receiverItems.count {
            
            let menuItem = filteredMenu_details?[indexPath.row].id
            
            switch menuItem {
            case 0:
                MenuRedirect.receiverCommunicationNavigate(from: self)
            case 3:
                MenuRedirect.receiverHomework(from: self)
            case 5:
                MenuRedirect.resiverExamMark(from: self)
            case 6:
                MenuRedirect.receiverExamTestNavigate(from: self)
            case 7:
                MenuRedirect.receiverNoticeBoardNavigate(from: self)
            case 8:
                MenuRedirect.receiverEvent(from: self)
            case 9:
                MenuRedirect.receiverAttendancereport(from: self)
            case 10:
                MenuRedirect.LeaveRquest(from: self)
            case 11:
                MenuRedirect.receiverCommunicationNavigate(from: self)
            case 13:
                MenuRedirect.receiverHomework(from: self)
            case 14:
                MenuRedirect.receiverchat(from: self)
                MenuRedirect.getValue = getValue
            case 15:
                MenuRedirect.resiverExamMark(from: self)
            case 18:
                MenuRedirect.receiverAssignmentNavigate(from: self)
            case 19:
                MenuRedirect.receiverImgPdfNavigate(from: self)
            case 20:
                MenuRedirect.receiverOnlineNavigate(from: self)
            case 21:
                MenuRedirect.QuizExam(from: self)
            case 22:
                MenuRedirect.receiverLsrwNavigate(from: self)
            case 23:
                MenuRedirect.receiverclassTimeTable(from: self)
            case 25:
                MenuRedirect.receiverCertificateRequest(from: self)
            default:
                break
            }
        }
    }
    @IBAction func assignment(_ sender: UIButton) {
        MenuRedirect.receiverAssignmentNavigate(from: self)
    }
    @IBAction func onlineMeeting(_ sender: UIButton) {
        MenuRedirect.receiverOnlineNavigate(from: self)
    }
    
    @IBAction func homeWork(_ sender: UIButton) {
        MenuRedirect.receiverNoticeBoardNavigate(from: self)
    }
    
}

@available(iOS 14.0, *)
extension ParentDashboardVc: UICollectionViewDelegateFlowLayout {
    
    // Set item size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 6{
            return CGSize(width: collectionView.frame.width, height: 160)
        }
        
        let width = (collectionView.frame.width) / 3.2
        let padding: CGFloat = 10
        let maxTextWidth = width - padding * 2
        
        let label = filteredMenu_details?[indexPath.row].name?.translated()
        let font = UIFont.preferredFont(forTextStyle: .body).withSize(10) // Use the same font style and size as set in the cell
        let textHeight = label?.height(withConstrainedWidth: maxTextWidth, font: font) ?? 0
        
        let height = max(textHeight + padding * 2, width - 10)
        return CGSize(width: width, height: height + 10)
    }
}
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
}

//MARK: Searchbar Delegate
@available(iOS 14.0, *)
extension ParentDashboardVc: UISearchBarDelegate{
    
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

//    func get_dashboard_details(){
//
//        print("tokenefrfrdfrfdx",ServiceUrl.token)
//        APIService.shared
//            .makeApi(url:  ServiceUrl.get_dashboard_details, parameters: ["member_type" : "parent"] , type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? ""){ [self] (
//                result : Result<DashboardResponse,
//                Error>
//            ) in
//            
//            switch result {
//                
//            case.success(let succesmessage) :
//                DispatchQueue.main.async { [self] in
//                print("succesmessagesdsds",succesmessage)
//                if succesmessage.status == true {
//                        menu_details = succesmessage.data?.first?.menu_details
//                        if let menu_details = menu_details {
//                            // Extract names from menu_details
//                            displayedCategories = menu_details.prefix(9).map {
//                                $0.name ?? ""
//                            }
//                            filteredMenu_details =  Array(menu_details.prefix(9))
//                            if filteredMenu_details?.count ?? 0 > 5 {
//                                filteredMenu_details?.insert(MenuDetail(id: 66, name: "Add", unread_count: 0), at: 6)
//                            }
//                            filteredItems = menu_details
//                        } else {
//                            displayedCategories = []
//                            filteredItems = []
//                        }
//                        bottomCv.reloadData()
//                        let contentViewHeight = bottomCv.collectionViewLayout.collectionViewContentSize.height
//                    let maxHeight = containerView.frame.size.height - 140 - userNameLbl.frame.height - SchoolNameLabel.frame.height
//
//                    collectionHeight.constant = max(contentViewHeight, maxHeight)
//                    scrollCollection.isScrollEnabled = menu_details.count > 6
//                 
//                    }
//                }
//                
//            case.failure(let error) :
//                
//                DispatchQueue.main.async {
//                    print(error.localizedDescription)
//                }
//            }
//            
//        }
//    }
    func get_dashboard_details() {
        print("Access Token:", ServiceUrl.token)
        
        APIService.shared.makeApi(
            url: ServiceUrl.get_dashboard_details,
            parameters: ["member_type": "parent"],
            type: ApitTypeSringFile.GET,
            token: childDetails?.access_token ?? ""
        ) { [weak self] (result: Result<DashboardResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    print("Dashboard Response:", response)
                    
                    if response.status == true, let details = response.data?.first?.menu_details {
                        self.menu_details = details
                        
                        // Display first 9 categories
                        self.displayedCategories = details.prefix(9).map { $0.name ?? "" }
                        self.filteredMenu_details = Array(details.prefix(9))
                        
                        // Add "Add" button if more than 5 items
                        if self.filteredMenu_details?.count ?? 0 > 5 {
                            self.filteredMenu_details?.insert(MenuDetail(id: 66, name: "Add", unread_count: 0), at: 6)
                        }
                        
                        self.filteredItems = details
                        self.bottomCv.reloadData()
                        
                        // Adjust collection view height
                        let contentViewHeight = self.bottomCv.collectionViewLayout.collectionViewContentSize.height
                        let maxHeight = self.containerView.frame.size.height
                            - 140
                            - self.userNameLbl.frame.height
                            - self.SchoolNameLabel.frame.height
                        
                        self.collectionHeight.constant = max(contentViewHeight, maxHeight)
                        
                        // Enable scrolling if more than 6 items
                        self.scrollCollection.isScrollEnabled = details.count > 6
                    } else {
                        self.displayedCategories = []
                        self.filteredItems = []
                        self.bottomCv.reloadData()
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print("Dashboard API Error:", error.localizedDescription)
                }
            }
        }
    }

    
    
}
extension UICollectionViewCell{
    
    func transformToLarge() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
    }
    func transformToStandard() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
    }
}



extension UIView {
    
    func applyGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        // Adjust the alpha of the colors to make them less opaque
        let adjustedColors = colors.map { $0.withAlphaComponent(0.65) }
        
        // Create a gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = adjustedColors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = self.bounds
        
        // Remove any existing gradient layers to avoid stacking
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        // Add the new gradient layer
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: - UIColor Extension for Hex Support
extension UIColor {
    /// Initialize UIColor with a hex string
    convenience init(hexs: String) {
        var hexSanitized = hexs.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
extension UIView {
    func roundTopCorners(radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
extension UIColor {
    func blendedWithWhite(factor: CGFloat) -> UIColor {
        let factor = max(0.0, min(1.0, factor)) // Clamp factor between 0 and 1
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return UIColor(
            red: red + (1.0 - red) * factor,
            green: green + (1.0 - green) * factor,
            blue: blue + (1.0 - blue) * factor,
            alpha: alpha
        )
    }
    
    
    
}


