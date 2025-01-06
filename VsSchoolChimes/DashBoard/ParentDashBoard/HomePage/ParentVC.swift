//
//  ParentVC.swift
//  VsSchoolChimes
//
//  Created by admin on 14/12/24.
//

import UIKit
import AVFoundation

@available(iOS 14.0, *)
class ParentVC: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var lowBottomCv: UICollectionView!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var templateview: UIView!
    @IBOutlet weak var profileFullview: UIView!
    @IBOutlet weak var bottomCvHeight: NSLayoutConstraint!
    @IBOutlet weak var loginDetailView: UIView!
    @IBOutlet weak var Searchbar: UISearchBar!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var SchoolNameLabel: UILabel!
    @IBOutlet weak var BellImage: UIImageView!
    @IBOutlet weak var schoolLogoImg: UIImageView!
    @IBOutlet weak var searchImgView: UIImageView!
    @IBOutlet weak var searchHeightCon: NSLayoutConstraint!
    @IBOutlet weak var TopCv: UICollectionView!
    @IBOutlet weak var pageContorler: UIPageControl!
    @IBOutlet weak var bottomCv: UICollectionView!
    
    @IBOutlet weak var collectionBtn: UIView!
    @IBOutlet weak var homeworkBtn: UIButton!
    @IBOutlet weak var assignmentkBtn: UIButton!
    @IBOutlet weak var onlineMeetingBtn: UIButton!
    @IBOutlet weak var heightStackview: NSLayoutConstraint!
    
    var filteredItems: [String] = []
    var getValue : Int!
    var searchItem = 0
    var currentIndex = 0
    var autoScrollTimer: Timer?
    
    private var containerView = UIView()
    private lazy var secondVC = SettingsViewController()
    private lazy var thirdVC = SettingsViewController()
    private lazy var fourthVC = SettingsViewController()
    let MenuRedirect = MenuRedirectHandler.shared
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
    override func viewDidLoad() {
        super.viewDidLoad()
        displayedCategories = Array(MenuRedirect.receiverItems.prefix(6))
        displayedCategories.insert(newString, at: 5)
        filteredItems = MenuRedirect.items
        setupSearchBar()
        //    startAutoScroll()
        cellRegistration()
        startPlaceholderRotation()
        addDoneButton()
        
        templateview.roundTopCorners(radius: 10)
        
        let midIndex = MenuRedirect.receiverItems.count / 2
        firstArray = Array(MenuRedirect.receiverItems.prefix(midIndex))  // First half
        secondArray = Array(MenuRedirect.receiverItems.suffix(from: midIndex))  // Second half
        
        reportView.layer.cornerRadius = 5
        reportView.layer.shadowColor = UIColor.black.cgColor
        reportView.layer.shadowOpacity = 0.5
        reportView.layer.shadowOffset = CGSize(width: 4, height: 4)
        reportView.layer.shadowRadius = 3
        reportView.layer.masksToBounds = false
        
        //
        profileFullview.layer.cornerRadius =  30
        loginDetailView.layer.cornerRadius =  30
        homeworkBtn.layer.cornerRadius = 10
        assignmentkBtn.layer.cornerRadius = 10
        onlineMeetingBtn.layer.cornerRadius = 10
        
        view.applyGradient(
            colors: [
                UIColor(hex: "#7ed957"),  // Green
                UIColor(hex: "#0097b2")   // Blue
            ],
            startPoint: CGPoint(x: 1, y: 0.5),  // Right-center
            endPoint: CGPoint(x: 0, y: 0.5)     // Left-center
        )
        
        setupVideoBackground()
        
        let value = UserDefaults.standard.integer(forKey: "passvalue")
        getValue = value
        // Do any additional setup after loading the view.
        Searchbar.placeholder = CommonStringFile.Search.translated()
        Searchbar.delegate = self
        searchHeightCon.constant = 0
        
        bottomCv.isPrefetchingEnabled = true
        Searchbar.delegate = self
   
        
        let searchImage  = UITapGestureRecognizer(target: self, action:#selector(SearchViewHidden))
        searchImgView.addGestureRecognizer(searchImage)
        
        searchImgView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openNotification))
        BellImage.addGestureRecognizer(tap)
        BellImage.isUserInteractionEnabled = true
        
        SchoolNameLabel.setFont(style: .title, size: FontSize.TitleSize)
        AddressLabel.setFont(style: .body, size: FontSize.BodySize)
        let redirectGesture =  UITapGestureRecognizer(target: self, action: #selector(redirectAct))
        loginDetailView.addGestureRecognizer(redirectGesture)
        
        
       
        configureButton(
            homeworkBtn,
            title: "Online  Meeting",
            imageName: UIImage(named: "Online  Meeting"),
            gradientColors:[UIColor.green,UIColor.purple],
            opacity: 0.4, // 70% opacity
            lightenFactor: 0.8// 40% lighter
        )
        
        // Configure assignmentkBtn
        configureButton(
            assignmentkBtn,
            title: "Notice Board",
            imageName: UIImage(named: "Notice Board"),
            gradientColors: [UIColor.blue,UIColor.gradient2], opacity: 0.4, // 70% opacity
            lightenFactor: 0.6 // 40% lighter
        )
        
        // Configure onlineMeetingBtn
        configureButton(
            onlineMeetingBtn,
            title: "Assignment",
            imageName: UIImage(named: "Resiverassignment"),
            gradientColors:[UIColor.yellow,UIColor.red],opacity: 0.4, // 70% opacity
            lightenFactor: 0.8// 40% lighter
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        view.applyGradient(
            colors: [
                UIColor(hex: "#7ed957"),  // Green
                UIColor(hex: "#0097b2")   // Blue
            ],
            startPoint: CGPoint(x: 1, y: 0.5),  // Right-center
            endPoint: CGPoint(x: 0, y: 0.5)     // Left-center
        )
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottomCv.delegate = self
        bottomCv.dataSource = self
        bottomCv.reloadData()
        
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
            button.setImage(resizedImage, for: .normal)
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



    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear - View has appeared on the screen.")
        
        bottomCv.delegate = self
        bottomCv.dataSource = self
        
        
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
    
    @IBAction func redirectAct() {
        dismiss(animated: true)
        
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
        gradientLayer.colors = colours //[UIColor.parentClr.cgColor,UIColor.priority.cgColor]
        gradientLayer.startPoint = CGPoint(x: xstart, y: ystart)  // Top-left
        gradientLayer.endPoint = CGPoint(x: 0.9, y: 0.9)    // Bottom-right
        profileFullview.layer.insertSublayer(gradientLayer, at: 0)
        profileFullview.layer.masksToBounds = true
  
    }
    
    func cellRegistration(){
        bottomCv.register(UINib(nibName: CellConfingName.HomePageBottomCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.HomePageBottomCell)
        bottomCv.register(UINib(nibName: CellConfingName.seeMore, bundle: nil), forCellWithReuseIdentifier: CellConfingName.seeMore)
        
    }
    
    func setupSearchBar() {
        Searchbar.placeholder = CommonStringFile.Search.translated()  + MenuRedirect.items[currentPlaceholderIndex].translated()
    }
    
    func startPlaceholderRotation() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.updatePlaceholder()
        }
    }
    
    func updatePlaceholder() {
        currentPlaceholderIndex = (currentPlaceholderIndex + 1) % MenuRedirect.items.count
        Searchbar.placeholder = CommonStringFile.Search.translated()  + MenuRedirect.items[currentPlaceholderIndex].translated()
    }
    
   
    
    @IBAction func openNotification(){
        let vc = NotificationViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
}



@available(iOS 14.0, *)
extension ParentVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedCategories.count // Ensure ItemnCount matches your data source
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Row: \(indexPath.row)")
        
        if indexPath.row == 6 {
            // Handle the "seeMore" cell
            let adCell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.seeMore, for: indexPath) as! seeMore
            adCell.advertisements = advertisements // Pass advertisement data to the ad cell
            adCell.adCollectionView.reloadData() // Refresh the embedded collection view
            adCell.seeAllButton.setTitle(isShowingAll ? "Show Less" : "See All", for: .normal)
            adCell.seeAllButton.addTarget(self, action: #selector(seeAllButtonTapped), for: .touchUpInside)
            return adCell
        } else {
            // Handle regular cells
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.HomePageBottomCell, for: indexPath) as! BottomCVCell
            cell.MenuLbl.text = nil
            cell.MenuImgView.image = nil
          
            
            let label = MenuRedirect.receiverItems[indexPath.row].translated()
            let img = UIImage(named: MenuRedirect.receiverItems[indexPath.row])
            cell.MenuLbl.setFont(style: .body, size: 10)
            cell.MenuLbl.text = label
            cell.MenuImgView.image = img
            cell.GradientView.backgroundColor = .clr
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                cell.GradientView.animateView(enable: false)
            }
            
            return cell
        }
    }

    
    @objc func seeAllButtonTapped() {
        if isShowingAll {
            // Collapse back to show only the first 6 items
            displayedCategories = Array(MenuRedirect.receiverItems.prefix(6))
            displayedCategories.insert(newString, at: 5)
            heightStackview.constant = 90
            collectionBtn.isHidden = false
        } else {
            // Expand to show all items
            displayedCategories = MenuRedirect.receiverItems
            heightStackview.constant = 0
            collectionBtn.isHidden = true
        }
        
        isShowingAll.toggle() // Toggle the state
        bottomCv.reloadData() // Refresh the collection view
//        updateCollectionViewHeight()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Ignore taps on the "seeMore" cell (indexPath.row == 6)
        if indexPath.row == 6 {
            return
        }
        
        if indexPath.row < MenuRedirect.receiverItems.count {
          
            let menuItem = MenuRedirect.receiverItems[indexPath.row].translated()
            
            switch menuItem {
            case ReceiverMenuItems.Video.translated():
                MenuRedirect.receiverVideoNavigate(from: self)
            case ReceiverMenuItems.Communication.translated():
                MenuRedirect.receiverCommunicationNavigate(from: self)
            case ReceiverMenuItems.ImagePdf.translated():
                MenuRedirect.receiverImgPdfNavigate(from: self)
            case ReceiverMenuItems.PTM.translated():
                MenuRedirect.receiverPtmNavigate(from: self)
            case ReceiverMenuItems.NoticeBoard.translated():
                MenuRedirect.receiverNoticeBoardNavigate(from: self)
            case ReceiverMenuItems.Assignment.translated():
                MenuRedirect.receiverAssignmentNavigate(from: self)
            case ReceiverMenuItems.ExamTest.translated():
                MenuRedirect.receiverExamTestNavigate(from: self)
            case ReceiverMenuItems.LSRW.translated():
                MenuRedirect.receiverLsrwNavigate(from: self)
            case ReceiverMenuItems.EventsHolidays.translated():
                MenuRedirect.receiverEvent(from: self)
            case ReceiverMenuItems.RequestLeave.translated():
                MenuRedirect.LeaveRquest(from: self)
            case ReceiverMenuItems.FeeDetails.translated():
                MenuRedirect.receiverchat(from: self)
            case ReceiverMenuItems.InteractionWithStaff.translated():
                MenuRedirect.receiverchat(from: self)
            case ReceiverMenuItems.ClassTimetable.translated():
                MenuRedirect.receiverclassTimeTable(from: self)
            case ReceiverMenuItems.Homework.translated():
                MenuRedirect.receiverHomework(from: self)
            case ReceiverMenuItems.AttendanceReport.translated():
                MenuRedirect.receiverAttendancereport(from: self)
            case ReceiverMenuItems.ExamMarks.translated():
                MenuRedirect.resiverExamMark(from: self)
            default:
                break
            }
        }
    }
    @IBAction func assignment(_ sender: UIButton) {
        
        MenuRedirect.receiverNoticeBoardNavigate(from: self)
    }
    @IBAction func onlineMeeting(_ sender: UIButton) {
        
        MenuRedirect.receiverAssignmentNavigate(from: self)
    }
    
    @IBAction func homeWork(_ sender: UIButton) {
//        MenuRedirect.receiverHomework(from: self)
        MenuRedirect.senderOnlineNavigate(from: self)
    }

}

@available(iOS 14.0, *)
extension ParentVC: UICollectionViewDelegateFlowLayout {
    
    // Set item size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 6{
            return CGSize(width: collectionView.frame.width, height: 160)
        }
   
        let width = (collectionView.frame.width) / 3
        let padding: CGFloat = 10
        let maxTextWidth = width - padding * 2

        let label = MenuRedirect.receiverItems[indexPath.row].translated()
        let font = UIFont.preferredFont(forTextStyle: .body).withSize(10) // Use the same font style and size as set in the cell
        let textHeight = label.height(withConstrainedWidth: maxTextWidth, font: font)

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

@available(iOS 14.0, *)
extension ParentVC: UISearchBarDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        Searchbar.endEditing(true)
        //        let currentCell = TopCv.cellForItem(at: IndexPath(row: Int(currentSelectedIndex), section: 0))
        //        currentCell?.transformToStandard()
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
            heightStackview.constant = 90
            collectionBtn.isHidden = false
            searchHeightCon.constant = 0
            
        }
    }
    
    func addDoneButton(){
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(DoneBtnAct))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace,doneButton], animated: false)
        Searchbar.inputAccessoryView = toolbar
    }
    
    @IBAction func DoneBtnAct(){
        
        Searchbar.resignFirstResponder()
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
    /// Apply a gradient color to the view
    /// - Parameters:
    ///   - colors: Array of `UIColor` for the gradient
    ///   - startPoint: The start point of the gradient (default is top-center)
    ///   - endPoint: The end point of the gradient (default is bottom-center)
    func applyGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        // Adjust the alpha of the colors to make them less opaque
        let adjustedColors = colors.map { $0.withAlphaComponent(0.7) }
        
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

