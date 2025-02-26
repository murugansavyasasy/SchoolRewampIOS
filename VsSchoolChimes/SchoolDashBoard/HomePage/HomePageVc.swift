//
//  HomePageVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit
import AVFoundation

@available(iOS 14.0, *)
class HomePageVc: UIViewController,UITabBarDelegate, UISearchBarDelegate{
    
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
    @IBOutlet weak var heightStackview: NSLayoutConstraint!
    @IBOutlet weak var homeworkBtn: UIButton!
    @IBOutlet weak var assignmentkBtn: UIButton!
    @IBOutlet weak var onlineMeetingBtn: UIButton!
    @IBOutlet weak var collectionBtn: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var TopCv: UICollectionView!
    @IBOutlet weak var pageContorler: UIPageControl!
    @IBOutlet weak var bottomCv: UICollectionView!
    
    var advertisements: [String] = []
    var filteredItems: [String] = []
    let menuName = MenuStringFile()
    var getValue : Int!
    var searchItem = 0
    var currentIndex = 0
    var autoScrollTimer: Timer?
    private let tabBar = UITabBar()
    private var containerView = UIView()
    private lazy var secondVC = SettingsViewController()
    private lazy var thirdVC = SettingsViewController()
    private lazy var fourthVC = SettingsViewController()
    let MenuRedirect = MenuRedirectHandler.shared
    var currentPlaceholderIndex = 0
    var timer: Timer?
    let alert = CustomAlert()
    var isShowingAll = false
    var displayedCategories: [String] = []
    let newString = "Add"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        advertisements = [
            "Ad 1: Special Offer",
            "Ad 2: Final Sale",
            "Ad 3: New Arrivals",
            "Ad 4: Discount Up to 50%"
        ]
        
        setupVideoBackground()
        filteredItems = MenuRedirect.items
        displayedCategories = Array(filteredItems.prefix(6))
        
        displayedCategories.insert(newString, at: 5)
        
        //startAutoScroll()
        cellRegistration()
        addDoneButton()
        let value = UserDefaults.standard.integer(forKey: "passvalue")
        getValue = value
        
        
        Searchbar.delegate = self
        searchHeightCon.constant = 0
        //        TopCv.delegate = self
        //        TopCv.dataSource = self
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
        
        ButtonUIupdate()
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
        
        
        //MARK: Translation
        Searchbar.placeholder = CommonStringFile.Search.translated()
    }
    
    
    //MARK: Apply gradient for the UIButton
    func ButtonUIupdate(){
        
        configureButton(
            homeworkBtn,
            title: MenuStringFile.Homework.translated(),
            imageName: UIImage(named: "Homework"),
            gradientColors:[UIColor.green,UIColor.blue],
            opacity: 0.4, // 70% opacity
            lightenFactor: 0.8// 40% lighter
        )
        
        // Configure assignmentkBtn
        configureButton(
            assignmentkBtn,
            title: MenuStringFile.Assignment.translated(),
            imageName: UIImage(named: "Assignment"),
            gradientColors: [UIColor.blue,UIColor.gradient2], opacity: 0.4, // 70% opacity
            lightenFactor: 0.7 // 40% lighter
        )
        configureButton(
            onlineMeetingBtn,
            title: MenuStringFile.OnlineMeeting.translated(),
            imageName: UIImage(named: "online_meeting"),
            gradientColors:[UIColor.blue,UIColor.systemPink],opacity: 0.4, // 70% opacity
            lightenFactor: 0.8// 40% lighter
        )
    }
    
    // Helper function to configure the button
    func configureButton(
        _ button: UIButton,
        title: String,
        imageName: UIImage?,
        gradientColors: [UIColor],
        cornerRadius: CGFloat = 10,
        imageSize: CGSize = CGSize(width: 40, height: 40),
        spacing: CGFloat = 8.0,
        opacity: CGFloat = 0.5, // Opacity for the gradient
        lightenFactor: CGFloat = 0.3 // Factor to lighten colors (0 = no change, 1 = full white)
    ) {
        // Set corner radius
        button.layer.cornerRadius = cornerRadius
        button.layer.masksToBounds = true
        
        // Adjust colors for lightening and opacity
        let adjustedColors = gradientColors.map { color in
            color.blendedWithWhite(factor: lightenFactor).withAlphaComponent(opacity)
        }
        
        // Apply gradient
        button.applyGradient(
            colors: adjustedColors,
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
        button.setTitleFont(style: .body, size: FontSize.BodySize)
        
        // Set title and image
        button.setTitle(title, for: .normal)
        if let image = imageName {
            let resizedImage = UIGraphicsImageRenderer(size: imageSize).image { _ in
                image.draw(in: CGRect(origin: .zero, size: imageSize))
            }
            button.setImage(resizedImage.withRenderingMode(.alwaysTemplate), for: .normal)
            button.tintColor = .gray
        }
        
        // Align image and title
        button.contentHorizontalAlignment = .center  // Ensure horizontal alignment
        if let imageSize = button.imageView?.frame.size,
           let titleSize = button.titleLabel?.intrinsicContentSize {
            let totalHeight = imageSize.height + titleSize.height + spacing
            
            button.imageEdgeInsets = UIEdgeInsets(
                top: -(totalHeight - imageSize.height),  // Move image to the top
                left: 0,
                bottom: 0,
                right: -titleSize.width // Center align horizontally
            )
            
            button.titleEdgeInsets = UIEdgeInsets(
                top: 0,  // No padding at the top
                left: -imageSize.width,  // Center align horizontally
                bottom: -(totalHeight - titleSize.height),  // Move title below the image
                right: 0
            )
            
            button.contentEdgeInsets = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: spacing,
                right: 0
            )
        }
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
        print("viewWillAppear - View is about to appear.")
        //
        //        TopCv.reloadData()
        //        TopCv.delegate = self
        //        TopCv.dataSource = self
        bottomCv.delegate = self
        bottomCv.dataSource = self
        bottomCv.reloadData()
        filteredItems = MenuRedirect.items
        //restartAnimations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear - View has appeared on the screen.")
        
        bottomCv.delegate = self
        bottomCv.dataSource = self
        // restartAnimations()
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear - View is about to disappear.")
        currentIndex = -1
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear - View has disappeared from the screen.")
        
    }
    
    @IBAction func ViewDetailsAct(_ sender: Any) {
        
        let vc  = LocationHistoryVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    @IBAction func redirectAct() {
        dismiss(animated: true)
        
    }
    @IBAction func OpenProfile() {
        
        let vc = ProfileViewController(nibName: nil, bundle: nil)
        vc.HideBackButton = false
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func cellRegistration(){
        bottomCv.register(UINib(nibName: CellConfingName.HomePageBottomCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.HomePageBottomCell)
        bottomCv.register(UINib(nibName:CellConfingName.seeMore, bundle: nil), forCellWithReuseIdentifier: CellConfingName.seeMore)
        TopCv.register(UINib(nibName: CellConfingName.HomePageTopCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.HomePageTopCell)
        
        TopCv.register(UINib(nibName: CellConfingName.PiechartCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.PiechartCVCell)
    }
    
    
    
    deinit {
        timer?.invalidate()
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
    @objc func seeAllButtonTapped() {
        if isShowingAll {
            // Collapse back to show only the first 6 items
            displayedCategories = Array(filteredItems.prefix(6))
            displayedCategories.insert(newString, at: 5)
            heightStackview.constant = 110
            collectionBtn.isHidden = false
            ButtonUIupdate()
        } else {
            // Expand to show all items
            displayedCategories = filteredItems
            heightStackview.constant = 0
            collectionBtn.isHidden = true
        }
        
        isShowingAll.toggle() // Toggle the state
        bottomCv.reloadData() // Refresh the collection view
        //        updateCollectionViewHeight()
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
extension HomePageVc: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bottomCv{
            
            return displayedCategories.count
            
        }else{
            return 5
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == bottomCv{
            if indexPath.row == 6 {
                let adCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.seeMore, for: indexPath) as! seeMore
                adCell.advertisements = advertisements
                adCell.seeAllButton.setTitle(isShowingAll ? "See Less" : "See All", for: .normal)
                adCell.seeAllButton.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
                return adCell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.HomePageBottomCell , for: indexPath) as! BottomCVCell
                cell.MenuLbl.text = nil
                cell.MenuImgView.image  = nil
                
                let label = filteredItems[indexPath.row].translated()
                let img = UIImage(named: MenuRedirect.Imgitems[indexPath.row])
                cell.MenuLbl.setFont(style: .body, size: 10)
                cell.MenuLbl.text = label
                cell.MenuImgView.image  = img
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
            }
            else{
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
            
            let menuItem = MenuRedirect.items[indexPath.row].translated()
            
            switch menuItem {
            case MenuStringFile.VideoUpload.translated():
                MenuRedirect.senderVideoNavigate(from: self)
                
            case MenuStringFile.Communication.translated():
                MenuRedirect.senderCommunicationNavigate(from: self)
                
            case MenuStringFile.ImagePdf.translated():
                MenuRedirect.senderImgPDfNavigate(from: self)
                
            case MenuStringFile.Circulars.translated():
                MenuRedirect.senderEventNavigate(from: self)
                
            case MenuStringFile.NoticeBoard.translated():
                MenuRedirect.senderNoticeboardNavigate(from: self)
                
            case MenuStringFile.PTM.translated():
                MenuRedirect.senderPtmNavigate(from: self)
                
            case MenuStringFile.LeaveRequests.translated():
                MenuRedirect.senderLeaveRequestNavigate(from: self)
                
            case MenuStringFile.Assignment.translated():
                MenuRedirect.senderAssignmentNavigate(from: self)
                
            case MenuStringFile.OnlineMeeting.translated():
                MenuRedirect.senderOnlineNavigate(from: self)
                
            case MenuStringFile.Homework.translated():
                MenuRedirect.senderHomeWorkNavigate(from: self)
                
                
            case MenuStringFile.LessonPlan.translated():
                MenuRedirect.senderLessonplanNavigate(from: self)
                
            case MenuStringFile.AbsenteesReport.translated():
                MenuRedirect.senderAbsenteesNavigate(from: self)
                
            case MenuStringFile.FeePendingReport.translated():
                MenuRedirect.senderFeePendingNavigate(from: self)
                
            case MenuStringFile.StudentReport.translated():
                MenuRedirect.senderStudentreportNavigate(from: self)
                
            case MenuStringFile.VeryImportantInfo.translated():
                MenuRedirect.senderImportantInfoNavigate(from: self)
            case MenuStringFile.SchoolNeeds.translated() :
                MenuRedirect.senderSchoolNeedsNavigate(from: self)
                
            case MenuStringFile.SchoolClassEvents.translated():
                MenuRedirect.senderEventNavigate(from: self)
            case MenuStringFile.SchoolStrength.translated():
                MenuRedirect.senderSchoolStrength(from: self)
                
            case MenuStringFile.MarkYourAttendance.translated():
                print("Mark your Attendance")
                
            case MenuStringFile.InteractionWithStudent.translated():
                MenuRedirect.Senderchat(from: self)
                MenuRedirect.getValue = getValue
            case MenuStringFile.ScheduleExamTest.translated():
                MenuRedirect.ScheduleExamVCNavigat(from: self)
            case MenuStringFile.DailyCollection:
                MenuRedirect.dailyCollectionNavigate(from: self)
            case MenuStringFile.StaffWiseAttendanceReport:
                MenuRedirect.StaffWiseAttendance(from: self)
                
            case MenuStringFile.AttendanceMarking:
                MenuRedirect.senderMarkAttendanceNavigate(from: self)
                break
                
            default:
                // Handle unknown menu items if needed
                break
            }
            
        }
        
        
    }
}

@available(iOS 14.0, *)
extension HomePageVc: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 6{
            return CGSize(width: collectionView.frame.width, height: 170)
        }
        
        let width = (collectionView.frame.width) / 3
        let padding: CGFloat = 10
        let maxTextWidth = width - padding * 2
        
        let label = filteredItems[indexPath.row].translated()
        let font = UIFont.preferredFont(forTextStyle: .body).withSize(10) // Use the same font style and size as set in the cell
        let textHeight = label.height(withConstrainedWidth: maxTextWidth, font: font)
        
        let height = max(textHeight + padding * 2, width - 10)
        return CGSize(width: width, height: height + 10)
        
    }
    
}


@available(iOS 14.0, *)
extension HomePageVc: UISearchBarDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        Searchbar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        Searchbar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchItem = 1
        if searchText.isEmpty {
            
            filteredItems = MenuRedirect.items // Show all items if no search text
            displayedCategories = Array(filteredItems.prefix(6))
            displayedCategories.insert(newString, at: 5)
        } else {
            filteredItems = MenuRedirect.items.filter { $0.lowercased().contains(searchText.lowercased()) }
            displayedCategories = filteredItems
        }
        bottomCv.reloadData()
    }
    
    
    //MARK: Searchview Hide
    @objc func SearchViewHidden() {
        
        if searchHeightCon.constant == 0{
            heightStackview.constant = 0
            collectionBtn.isHidden = true
            searchHeightCon.constant = 56
        }else{
            heightStackview.constant = 110
            collectionBtn.isHidden = false
            ButtonUIupdate()
            searchHeightCon.constant = 0
            
        }
    }
    
    func addDoneButton(){
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: AlertstringFile.Done, style: .done, target: self, action: #selector(DoneBtnAct))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        toolbar.setItems([flexibleSpace,doneButton], animated: false)
        
        Searchbar.inputAccessoryView = toolbar
    }
    
    @IBAction func DoneBtnAct(){
        
        Searchbar.resignFirstResponder()
    }
    
}
