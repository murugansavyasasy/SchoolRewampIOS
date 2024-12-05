//
//  HomePageVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

@available(iOS 14.0, *)
class HomePageVc: UIViewController,UITabBarDelegate, UISearchBarDelegate{
    
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
    
    var items : [String] = [ "Communication","Image/Pdf","Video Upload","Circulars","Notice Board","Leave Requests","Assignment","Online Meeting","Homework","Schedule Exam/Test","Attendance marking","Messages from management","Interaction with student","Lesson Plan","PTM","Mark your attendence", "Absentees Report","School strenght","Daily Collection","Student Report","Fee Pending Report","Mark Your Attendance","Staff Wise Attendance Report"
    ]
    
    
    var Imgitems : [String] = [ "Communication","ImagePdf","Video Upload","Circulars","Notice Board","Leave Requests","Assignment","Online Meeting","Homework","Schedule ExamTest","Attendance marking","Messages from management","Interaction with student","Lesson Plan","PTM","Mark your attendence", "Absentees Report","School strenght","Daily Collection","Student Report","Fee Pending Report","Mark Your Attendance","Staff Wise Attendance Report"]
    
    let HomePageBottomCell = "BottomCVCell"
    var currentIndex = 0
    var autoScrollTimer: Timer?
    private let tabBar = UITabBar()
    private var containerView = UIView()
    
    private lazy var secondVC = SettingsViewController()
    private lazy var thirdVC = SettingsViewController()
    private lazy var fourthVC = SettingsViewController()
    
    
    let name = "saran"
    
    var currentPlaceholderIndex = 0
    var timer: Timer?
    let alert = CustomAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("getValue",getValue)
        
        // Do any additional setup after loading the view.
        Searchbar.placeholder = "Search".translated()
        Searchbar.delegate = self
        addDoneButton()
        searchHeightCon.constant = 0
        
        bottomCv.register(UINib(nibName: CellConfingName.HomePageBottomCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.HomePageBottomCell)
        TopCv.register(UINib(nibName: CellConfingName.HomePageTopCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.HomePageTopCell)
        
        TopCv.register(UINib(nibName: "PiechartCVCell", bundle: nil), forCellWithReuseIdentifier: "PiechartCVCell")
        
        
        TopCv.delegate = self
        TopCv.dataSource = self
        
        //        bottomCv.delegate = self
        //        bottomCv.dataSource = self
        //        bottomCv.reloadData()
        bottomCv.isPrefetchingEnabled = true
        
        startAutoScroll()
        
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
    
    @IBAction func redirectAct() {
        
        dismiss(animated: true)

    }
    func setupSearchBar() {
        Searchbar.placeholder = "Search "  + items[currentPlaceholderIndex].translated()
        }

        func startPlaceholderRotation() {
            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
                self?.updatePlaceholder()
            }
        }

        func updatePlaceholder() {
            currentPlaceholderIndex = (currentPlaceholderIndex + 1) % items.count
            Searchbar.placeholder = "Search "  + items[currentPlaceholderIndex].translated()
        }

        deinit {
            timer?.invalidate()
        }

    
   
    
    //    override func viewWillAppear(_ animated: Bool) {
    //            super.viewWillAppear(animated)
    //            print("viewWillAppear - View is about to appear.")
    //
    //        TopCv.reloadData()
    //
    //          TopCv.delegate = self
    //          TopCv.dataSource = self
    //
    //          bottomCv.delegate = self
    //          bottomCv.dataSource = self
    //
    //        bottomCv.reloadData()
    //
    //        restartAnimations()
    //        }
    
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
            
//            cell.MenuLabelview.animateView(enable: true)
            cell.MenuLbl.isHidden = true
            cell.GradientView.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [self] in
                cell.shimmersViewss.animateView(enable: false)
//                cell.MenuLabelview.animateView(enable: true)
                cell.MenuLbl.isHidden = false
                cell.GradientView.isHidden = false
                cell.shimmersViewss.parentview.isHidden = true
            }
            
        }

    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        Searchbar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        Searchbar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchItem = 1
            if searchText.isEmpty {
                filteredItems = items // Show all items if no search text
            } else {
                filteredItems = items.filter { $0.lowercased().contains(searchText.lowercased()) }
            }
        TopCv.reloadData() // Refresh the table view to show filtered results
        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear - View has appeared on the screen.")
        
        bottomCv.delegate = self
        bottomCv.dataSource = self
        // bottomCv.reloadData()
        restartAnimations()
        
        //            bottomCv.reloadData()
        
        // startAutoScroll()
        
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
    
    
    @objc func SearchViewHidden() {
        
       
        
        if searchHeightCon.constant == 0{
            
            searchHeightCon.constant = 56
            
            
        }else{
            
            
            searchHeightCon.constant = 0
            
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
extension HomePageVc: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("numberOfItemsInSection")
        if searchItem == 1 {
            return filteredItems.count
        }else{
            
            if collectionView == bottomCv{
                
                return items.count
            }else{
                
                
                return 5
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == bottomCv{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.HomePageBottomCell , for: indexPath) as! BottomCVCell
            
            if searchItem == 1 {
                
                let label = items[indexPath.row].translated()
                cell.MenuLbl.text = label
            }else{
               
                cell.MenuLbl.text = nil
                cell.MenuImgView.image  = nil
                //            if items[indexPath.row]
                let label = items[indexPath.row].translated()
                
                let img = UIImage(named: Imgitems[indexPath.row])
                //           let sum = indexPath.row % Imgitems.count
                //            let img = UIImage(named: Imgitems[sum] )
                
                cell.MenuLbl.setFont(style: .body, size: 10)
                
                cell.MenuLbl.text = label
                cell.MenuImgView.image  = img
                //            cell.MenuImgView.image = img!.withRenderingMode(.alwaysTemplate)
                //            cell.MenuImgView.tintColor = .white
                //
                cell.applyGradient()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                    cell.GradientView.animateView(enable: false)
                    //                cell.MenuLabelview.animateView(enable: false)
                    //cell.image = UIImage(named: Imgitems[indexPath.row] )!
                    //cell.setImg(img: UIImage(named: Imgitems[indexPath.row] )!)
                }
            }
            return cell
        }else{
            
            if indexPath.row == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PiechartCVCell" , for: indexPath) as! PiechartCVCell
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
            
//            getValue = 1 for Sender side  0 for parent side
            
            if getValue == 1 {
                let name = "Video Upload".translated()
                let comunication = "Communication".translated()
                if name == items[indexPath.row].translated(){
                    videoNavigate()
                }else if comunication == items[indexPath.row].translated(){
                    let vc = ComunicationVC(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }else if items[indexPath.row].translated() == "Image/Pdf".translated() {
                    let vc = SenderImgPdfVC(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                    
                }else if items[indexPath.row].translated() == "Lesson Plan".translated() {
                    
                    alert.showAlertCancel (
                        title: "Confirm Action",
                        message: "Are you sure you want to proceed?",actionLbl1: "No",actionLbl2: "Submit",
                        on: self,
                        onOk: {
                            
                            print("OK button tapped")
                            // Perform OK action
                        },
                        onNo: {
                          
                            print("No button tapped")
                            // Perform No action
                        }
                    )
                }
                else if items[indexPath.row] == "PTM".translated() {
                    
                    
                }else if items[indexPath.row].translated() == "Notice Board".translated() {
                    
                    let vc = SenderNoticeBoardVC(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                    
                }  else if items[indexPath.row] == "schoolss".translated() {
                    
                    homeWorkNavigate()
                    
                }else if items[indexPath.row] == "Leave Requests".translated(){
                    //                let vc = AssignmentListVC(nibName: nil, bundle: nil)
                    let vc = StudentHistryVC(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                    
                }else if items[indexPath.row] == "Assignment".translated(){
                    
                    let vc = SenderAssignmentViewController(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }else if items[indexPath.row] == "Circulars".translated(){
                    let vc = SenderEventsVC(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }else if items[indexPath.row] == "Online Meeting".translated(){
                    let vc = SenderSideOnlineMeetingViewController(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }else if items[indexPath.row] == "Homework".translated(){
                    let vc = SenderSideHomeWorkViewController(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
                
                
                
               
            }else{
                
                
                let name = "Video Upload".translated()
                let comunication = "Communication".translated()
                if name == items[indexPath.row].translated(){
                    let vc = VideoVC(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }else if comunication == items[indexPath.row].translated(){
                    let vc = ComunicationVC(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }else if items[indexPath.row].translated() == "Image/Pdf".translated() {
                    let vc = ImagePdfVC(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                    
                }else if items[indexPath.row].translated() == "Lesson Plan".translated() {
                    
                    alert.showAlertCancel (
                        title: "Confirm Action",
                        message: "Are you sure you want to proceed?",actionLbl1: "No",actionLbl2: "Submit",
                        on: self,
                        onOk: {
                            
                            print("OK button tapped")
                            // Perform OK action
                        },
                        onNo: {
                          
                            print("No button tapped")
                            // Perform No action
                        }
                    )
                }
                else if items[indexPath.row] == "PTM".translated() {
                    
                    videoNavigate()
                    
                }else if items[indexPath.row].translated() == "Notice Board".translated() {
                    
                    let vc = NoticeBoardVc(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                    
                }  else if items[indexPath.row] == "schoolss".translated() {
                    
                    homeWorkNavigate()
                    
                }else if items[indexPath.row] == "Leave Requests".translated(){
                    //                let vc = AssignmentListVC(nibName: nil, bundle: nil)
                    let vc = StudentHistryVC(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                    
                }else if items[indexPath.row] == "Assignment".translated(){
                    
                    let vc = PageVC(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }else if items[indexPath.row] == "Circulars".translated(){
                    let vc = EventPageVC(nibName: nil, bundle: nil)
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
                
            }
            
        }
    }
    
    //    func imagePdfNavigate() {
    //        let vc = SenderSideImagePdfViewController(nibName: nil, bundle: nil)
    //        vc.modalPresentationStyle = .fullScreen
    //        present(vc, animated: true)
    //    }
    
    func videoNavigate() {
        let vc = SenderSideVideoViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    
    func homeWorkNavigate() {
        let vc = SenderSideHomeWorkViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

@available(iOS 14.0, *)
extension HomePageVc: UICollectionViewDelegateFlowLayout {
    
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
extension HomePageVc: UISearchBarDelegate{
 
    
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
