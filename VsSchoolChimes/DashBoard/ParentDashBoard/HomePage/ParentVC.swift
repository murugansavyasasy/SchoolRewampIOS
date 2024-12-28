//
//  ParentVC.swift
//  VsSchoolChimes
//
//  Created by admin on 14/12/24.
//

import UIKit

@available(iOS 14.0, *)
class ParentVC: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
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
    
    var filteredItems: [String] = []
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
    var currentSelectedIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustCollectionViewHeight()
        bottomCv.isScrollEnabled = false
        filteredItems = MenuRedirect.items
        setupSearchBar()
        //    startAutoScroll()
        cellRegistration()
        startPlaceholderRotation()
        addDoneButton()
        let value = UserDefaults.standard.integer(forKey: "passvalue")
        getValue = value
        // Do any additional setup after loading the view.
        Searchbar.placeholder = CommonStringFile.Search.translated()
        Searchbar.delegate = self
        searchHeightCon.constant = 0
        TopCv.delegate = self
        TopCv.dataSource = self
        TopCv.collectionViewLayout = CardsCollectionFlowLayout()
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
        
        SchoolNameLabel.setFont(style: .title, size: FontSize.TitleSize)
        AddressLabel.setFont(style: .body, size: FontSize.BodySize)
        let redirectGesture =  UITapGestureRecognizer(target: self, action: #selector(redirectAct))
        loginDetailView.addGestureRecognizer(redirectGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear - View is about to appear.")
        
        TopCv.reloadData()
        TopCv.delegate = self
        TopCv.dataSource = self
        bottomCv.delegate = self
        bottomCv.dataSource = self
        bottomCv.reloadData()
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
    
    func cellRegistration(){
        bottomCv.register(UINib(nibName: CellConfingName.HomePageBottomCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.HomePageBottomCell)
        TopCv.register(UINib(nibName: CellConfingName.HomePageTopCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.HomePageTopCell)
        
        TopCv.register(UINib(nibName: CellConfingName.PiechartCVCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.PiechartCVCell)
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
    
    deinit {
        timer?.invalidate()
    }
    
    
    
    func adjustCollectionViewHeight() {
        let numberOfColumns: CGFloat = 4
        let spacing: CGFloat = 10 // Adjust based on your collection view layout
        
        // Get layout attributes
        guard let layout = bottomCv.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        // Calculate item size
        let totalSpacing = (numberOfColumns - 1) * layout.minimumInteritemSpacing + layout.sectionInset.left + layout.sectionInset.right
        let itemWidth = (bottomCv.frame.width - totalSpacing) / numberOfColumns
        let itemHeight = itemWidth // Assuming square items
        
        // Calculate rows
        let numberOfRows = ceil(CGFloat(MenuRedirect.receiverItems.count) / numberOfColumns)
        
        // Update height constraint
        bottomCvHeight.constant = (numberOfRows * itemHeight) + ((numberOfRows - 1) * layout.minimumLineSpacing) + layout.sectionInset.top + layout.sectionInset.bottom
        
        // Refresh layout
        bottomCv.layoutIfNeeded()
    }
    
    
    
    func restartAnimations() {
        // Assuming you have shimmer animations or other animations that need to be reset
        
        
        if let cell = TopCv.cellForItem(at: IndexPath(row: 0, section: 0)) as? PiechartCVCell {
            // Reset shimmer view or any other animations
            cell.pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInExpo)
        }
        
        for cell in bottomCv.visibleCells as! [BottomCVCell] {
            // Reset shimmer view or any other animations
            cell.shimmersViewss.parentview.isHidden = false
            cell.shimmersViewss.animateView(enable: true)
            cell.MenuLbl.isHidden = true
            cell.GradientView.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                cell.shimmersViewss.animateView(enable: false)
                cell.MenuLbl.isHidden = false
                cell.GradientView.isHidden = false
                cell.shimmersViewss.parentview.isHidden = true
            }
            
        }
        
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
extension ParentVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bottomCv{
            
            return MenuRedirect.receiverItems.count
            
        }else{
            return 5
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == bottomCv{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.HomePageBottomCell , for: indexPath) as! BottomCVCell
            cell.MenuLbl.text = nil
            cell.MenuImgView.image  = nil
            let label = MenuRedirect.receiverItems[indexPath.row].translated()
            let img = UIImage(named: MenuRedirect.receiverItems[indexPath.row])
            cell.MenuLbl.setFont(style: .body, size: 10)
            cell.MenuLbl.text = label
            cell.MenuImgView.image  = img
            cell.applyGradient(colours: [UIColor.parentClr.cgColor,UIColor.priority.cgColor],xstart: 0.4,ystart: 0.4)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                cell.GradientView.animateView(enable: false)
                
            }
            
            return cell
        }
        
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.HomePageTopCell , for: indexPath) as! TopCVCell
            if currentSelectedIndex == indexPath.row {
                cell.transformToLarge()
            }
            
            return cell
            //    }
            
        }
        
        
        
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView == TopCv{
            
            guard scrollView == TopCv else {
                return
            }
            
            targetContentOffset.pointee = scrollView.contentOffset
            
            let flowLayout = TopCv.collectionViewLayout as! CardsCollectionFlowLayout
            let cellWidthIncludingSpacing = flowLayout.itemSize.width + flowLayout.minimumLineSpacing
            let offset = targetContentOffset.pointee
            let horizontalVelocity = velocity.x
            
            var selectedIndex = currentSelectedIndex
            
            switch horizontalVelocity {
                // On swiping
            case _ where horizontalVelocity > 0 :
                selectedIndex = currentSelectedIndex + 1
            case _ where horizontalVelocity < 0:
                selectedIndex = currentSelectedIndex - 1
                
                // On dragging
            case _ where horizontalVelocity == 0:
                let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
                let roundedIndex = round(index)
                
                selectedIndex = Int(roundedIndex)
            default:
                print("Incorrect velocity for collection view")
            }
            
            let safeIndex = max(0, min(selectedIndex, 5 - 1))
            let selectedIndexPath = IndexPath(row: safeIndex, section: 0)
            
            flowLayout.collectionView!.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
            
            let previousSelectedIndex = IndexPath(row: Int(currentSelectedIndex), section: 0)
            let previousSelectedCell = TopCv.cellForItem(at: previousSelectedIndex)
            let nextSelectedCell = TopCv.cellForItem(at: selectedIndexPath)
            
            currentSelectedIndex = selectedIndexPath.row
            
            previousSelectedCell?.transformToStandard()
            nextSelectedCell?.transformToLarge()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == bottomCv{
            let menuItem = MenuRedirect.receiverItems[indexPath.row].translated()
            
            switch menuItem {
            case ReceiverMenuItems.Video.translated():
                
                MenuRedirect.receiverVideoNavigate(from: self)
                
            case ReceiverMenuItems.Communication.translated():
                MenuRedirect.receiverCommunicationNavigate(from: self)
                
            case ReceiverMenuItems.ImagePdf.translated():
                MenuRedirect.receiverImgPdfNavigate(from: self)
                MenuRedirect.receiverCertificateRequest(from: self)
                
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
            case ReceiverMenuItems.InteractionWithStaff.translated():
                ""
            case ReceiverMenuItems.OnlineMeeting.translated():
                ""
            case ReceiverMenuItems.ClassTimetable.translated():
                MenuRedirect.receiverclassTimeTable(from: self)
            case ReceiverMenuItems.Homework.translated():
                MenuRedirect.receiverHomework(from: self)
            case ReceiverMenuItems.AttendanceReport.translated():
                MenuRedirect.receiverAttendancereport(from: self)
            case ReceiverMenuItems.CertificateRequest.translated():
                ""
            case ReceiverMenuItems.ExamMarks.translated():
                
                MenuRedirect.resiverExamMark(from: self)
                
                
                // Do nothing for these cases
                break
                
            default:
                // Handle unknown menu items if needed
                break
            }
            
        }
    }
    
}

@available(iOS 14.0, *)
extension ParentVC: UICollectionViewDelegateFlowLayout {
    
    // Set item size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == bottomCv{
            
            let numberOfColumns: CGFloat = 4
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                return CGSize(width: 50, height: 50) // Default fallback
            }
            let totalSpacing = (numberOfColumns - 1) * layout.minimumInteritemSpacing + layout.sectionInset.left + layout.sectionInset.right
            let itemWidth = (collectionView.frame.width - totalSpacing) / numberOfColumns
            return CGSize(width: itemWidth, height: itemWidth) // Assuming square items
        }
        else{
            return CGSize(width: 250, height: 110)
            
        }
        
    }
    
    
}


@available(iOS 14.0, *)
extension ParentVC: UISearchBarDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        Searchbar.endEditing(true)
        let currentCell = TopCv.cellForItem(at: IndexPath(row: Int(currentSelectedIndex), section: 0))
        currentCell?.transformToStandard()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        Searchbar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchItem = 1
        if searchText.isEmpty {
            filteredItems = MenuRedirect.items // Show all items if no search text
        } else {
            filteredItems = MenuRedirect.items.filter { $0.lowercased().contains(searchText.lowercased()) }
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
