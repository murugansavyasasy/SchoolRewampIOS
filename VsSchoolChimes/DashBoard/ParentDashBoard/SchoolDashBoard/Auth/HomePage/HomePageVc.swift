//
//  HomePageVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

@available(iOS 14.0, *)
class HomePageVc: UIViewController,UITabBarDelegate {

    
    @IBOutlet weak var schoolLogoImg: UIImageView!
    @IBOutlet weak var searchImgView: UIImageView!
    
    @IBOutlet weak var searchHeightCon: NSLayoutConstraint!
    @IBOutlet weak var TopCv: UICollectionView!
    
    @IBOutlet weak var pageContorler: UIPageControl!
    @IBOutlet weak var bottomCv: UICollectionView!
     
    var items : [String] = [ "Communication","Image/Pdf","Video Upload","Circulars","Homework","Schedule Exam/Test","Notice Board","Attendance marking","Messages from management","Leave Requests","Assignment","Interaction with student","Online Meeting","Lesson Plan","PTM","Mark your attendence"]
    
    var Imgitems : [String] = [ "Communication","ImagePdf","Video Upload","Circulars","Homework","Schedule ExamTest","Notice Board","Attendance marking","Messages from management","Leave Requests","Assignment","Interaction with student","Online Meeting","Lesson Plan","PTM","Mark your attendence"]
    
    let HomePageBottomCell = "BottomCVCell"
    var currentIndex = 0
    var autoScrollTimer: Timer?
    private let tabBar = UITabBar()
      private var containerView = UIView()
    
   
       private lazy var secondVC = SettingsViewController()
    private lazy var thirdVC = SettingsViewController()
       private lazy var fourthVC = SettingsViewController()
    
    
    let name = "saran"
    
    
  
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
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
        

        NotificationCenter.default.addObserver(self, selector: #selector(stopAutoScroll), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopAutoScroll), name: UIApplication.willEnterForegroundNotification, object: nil)
      
        let searchImage  = UITapGestureRecognizer(target: self, action:#selector(SearchViewHidden))
        searchImgView.addGestureRecognizer(searchImage)
        
        searchImgView.isUserInteractionEnabled = true
        
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
                   cell.shimmersViewss.animateView(enable: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [self] in
                    cell.shimmersViewss.animateView(enable: false)
                }
            
               }
        
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
    
    
  
}



@available(iOS 14.0, *)
extension HomePageVc: UICollectionViewDelegate, UICollectionViewDataSource {
    
 
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("numberOfItemsInSection")
        if collectionView == bottomCv{
            
            return items.count
        }else{
            
            
            return 5
        }
       
    }
    
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        
        if collectionView == bottomCv{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.HomePageBottomCell , for: indexPath) as! BottomCVCell
            
            cell.MenuLbl.text = nil
            cell.MenuImgView.image  = nil
//            if items[indexPath.row]
            let label = items[indexPath.row].translated()
            let img = UIImage(named: Imgitems[indexPath.row])
            
            cell.MenuLbl.text = label
            cell.MenuImgView.image  = img
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                cell.shimmersViewss.animateView(enable: false)
                //cell.image = UIImage(named: Imgitems[indexPath.row] )!
                //cell.setImg(img: UIImage(named: Imgitems[indexPath.row] )!)
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
                
                //imagePdfNavigate()
            }
            else if items[indexPath.row] == "university".translated() {
                
                videoNavigate()

            }else if items[indexPath.row].translated() == "Notice Board".translated() {
                
                let vc = NoticeBoardVc(nibName: nil, bundle: nil)
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)

            }  else if items[indexPath.row] == "schoolss".translated() {
                
                homeWorkNavigate()

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
            

            return CGSize(width: collectionView.frame.width/3, height: 140)
        }
        else{
            
            
         
            return CGSize(width: 350, height: 140)
        }
     
    }
    
    
    
    
    
   
}
