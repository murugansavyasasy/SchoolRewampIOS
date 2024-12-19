//
//  ParentVC.swift
//  VsSchoolChimes
//
//  Created by admin on 14/12/24.
//

import UIKit

@available(iOS 14.0, *)
class ParentVC: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
   
    

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

    override func viewDidLoad() {
    super.viewDidLoad()
    filteredItems = MenuRedirect.items
    setupSearchBar()
    startAutoScroll()
    cellRegistration()
    startPlaceholderRotation()
    addDoneButton()
    let value = UserDefaults.standard.integer(forKey: "passvalue")
    getValue = value
    // Do any additional setup after loading the view.
    Searchbar.placeholder = CommonStringFile.Search
    Searchbar.delegate = self
    searchHeightCon.constant = 0
    TopCv.delegate = self
    TopCv.dataSource = self
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

    restartAnimations()
    }

    override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    print("viewDidAppear - View has appeared on the screen.")

    bottomCv.delegate = self
    bottomCv.dataSource = self
    restartAnimations()

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
    Searchbar.placeholder = CommonStringFile.Search  + MenuRedirect.items[currentPlaceholderIndex]
    }

    func startPlaceholderRotation() {
    timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
    self?.updatePlaceholder()
    }
    }

    func updatePlaceholder() {
    currentPlaceholderIndex = (currentPlaceholderIndex + 1) % MenuRedirect.items.count
    Searchbar.placeholder = CommonStringFile.Search  + MenuRedirect.items[currentPlaceholderIndex]
    }

    deinit {
    timer?.invalidate()
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
    if getValue == 1 {
    return filteredItems.count
    }else{
    return MenuRedirect.receiverItems.count
    }
    }else{
    return 5
    }
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    if collectionView == bottomCv{
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.HomePageBottomCell , for: indexPath) as! BottomCVCell

    if getValue == 1 {
    cell.MenuLbl.text = nil
    cell.MenuImgView.image  = nil
    let label = filteredItems[indexPath.row]
    let img = UIImage(named: MenuRedirect.Imgitems[indexPath.row])
    cell.MenuLbl.setFont(style: .body, size: 10)
    cell.MenuLbl.text = label
    cell.MenuImgView.image  = img
    cell.applyGradient()

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    cell.GradientView.animateView(enable: false)
    }

    }else{
    if searchItem == 1 {
    let label = MenuRedirect.receiverItems[indexPath.row]
    cell.MenuLbl.text = label
    }else{

    cell.MenuLbl.text = nil
    cell.MenuImgView.image  = nil
    let label = MenuRedirect.receiverItems[indexPath.row]
    let img = UIImage(named: MenuRedirect.receiverImageItems[indexPath.row])
    cell.MenuLbl.setFont(style: .body, size: 10)
    cell.MenuLbl.text = label
    cell.MenuImgView.image  = img
    cell.applyGradient()

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
    cell.GradientView.animateView(enable: false)
    }
    }
    }
    return cell
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

    if collectionView == bottomCv{
    if getValue == 1 {

    let menuItem = MenuRedirect.items[indexPath.row]

    switch menuItem {
    case menuName.VideoUpload:
    MenuRedirect.senderVideoNavigate(from: self)

    case MenuStringFile.Communication:
    MenuRedirect.senderCommunicationNavigate(from: self)

    case menuName.ImagePdf, menuName.ImagePdf.translated():
    MenuRedirect.senderImgPDfNavigate(from: self)

    case menuName.Circulars.translated():
    MenuRedirect.senderEventNavigate(from: self)

    case menuName.NoticeBoard:
    MenuRedirect.senderNoticeboardNavigate(from: self)

    case menuName.PTM:
    MenuRedirect.senderPtmNavigate(from: self)

    case menuName.LeaveRequests:
    MenuRedirect.senderStudentreportNavigate(from: self)

    case menuName.Assignment:
    MenuRedirect.senderAssignmentNavigate(from: self)

    case menuName.OnlineMeeting:
    MenuRedirect.senderOnlineNavigate(from: self)

    case menuName.Homework:
    MenuRedirect.senderHomeWorkNavigate(from: self)

    case menuName.LessonPlan:
    MenuRedirect.senderLessonplanNavigate(from: self)

    case menuName.AbsenteesReport:
    MenuRedirect.senderAbsenteesNavigate(from: self)

    case menuName.FeePendingReport:
    MenuRedirect.senderFeePendingNavigate(from: self)

    case menuName.StudentReport:
    MenuRedirect.senderStudentreportNavigate(from: self)

    case menuName.VeryImportantInfo:
    MenuRedirect.senderImportantInfoNavigate(from: self)

    case menuName.SchoolStrength:
    MenuRedirect.senderSchoolStrength(from: self)

    case menuName.DailyCollection,
    menuName.ScheduleExamTest,
    menuName.MarkYourAttendance,
    "":
    // Do nothing for these cases
    break

    default:
    // Handle unknown menu items if needed
    break
    }

    }else{

    let menuItem = MenuRedirect.items[indexPath.row]

    switch menuItem {
    case menuName.VideoUpload:
    MenuRedirect.receiverVideoNavigate(from: self)

    case MenuStringFile.Communication:
    MenuRedirect.receiverCommunicationNavigate(from: self)

    case menuName.ImagePdf:
        MenuRedirect.receiverclassTimeTable(from: self)

    case menuName.PTM:
    MenuRedirect.receiverPtmNavigate(from: self)

    case menuName.NoticeBoard,
    menuName.Circulars:
    MenuRedirect.receiverNoticeBoardNavigate(from: self)

    case menuName.Assignment:
    MenuRedirect.receiverAssignmentNavigate(from: self)

    case menuName.ScheduleExamTest:
    MenuRedirect.receiverExamTestNavigate(from: self)

    case menuName.LSRW:
    MenuRedirect.receiverLsrwNavigate(from: self)

    case menuName.LessonPlan,
    menuName.LeaveRequests:
    // Do nothing for these cases
    break

    default:
    // Handle unknown menu items if needed
    break
    }

    }
    }
    }
    }

    @available(iOS 14.0, *)
    extension ParentVC: UICollectionViewDelegateFlowLayout {

    // Set item size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    if collectionView == bottomCv{

    return CGSize(width: collectionView.frame.width/4, height: 130)

    }
    else{

    return CGSize(width: 350, height: 140)

    }

    }


    }


    @available(iOS 14.0, *)
    extension ParentVC: UISearchBarDelegate{

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
