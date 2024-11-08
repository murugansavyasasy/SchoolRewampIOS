//
//  HomePageVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class HomePageVc: UIViewController,UITabBarDelegate {

    
    @IBOutlet weak var searchImgView: UIImageView!
    
    @IBOutlet weak var searchHeightCon: NSLayoutConstraint!
    @IBOutlet weak var TopCv: UICollectionView!
    
    @IBOutlet weak var pageContorler: UIPageControl!
    @IBOutlet weak var bottomCv: UICollectionView!
     
    var items : [String] = [ "discussion","SmallIcon","drawing-compass","knowledge","pencil","scale","schoolss","university","support","SmallIcon","Video"]
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
        
        bottomCv.delegate = self
        bottomCv.dataSource = self
        bottomCv.reloadData()
        TopCv.delegate = self
        TopCv.dataSource = self
        TopCv.reloadData()
        
        
        startAutoScroll()
        

        NotificationCenter.default.addObserver(self, selector: #selector(stopAutoScroll), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopAutoScroll), name: UIApplication.willEnterForegroundNotification, object: nil)
      
        let searchImage  = UITapGestureRecognizer(target: self, action:#selector(SearchViewHidden))
        searchImgView.addGestureRecognizer(searchImage)
        
        searchImgView.isUserInteractionEnabled = true
        
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



extension HomePageVc: UICollectionViewDelegate, UICollectionViewDataSource {
    
 
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == bottomCv{
            
            return items.count
        }else{
            
            
            return 5
        }
       
    }
    
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        
        if collectionView == bottomCv{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.HomePageBottomCell , for: indexPath) as! BottomCVCell
            
            
//            if items[indexPath.row]
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) { [self] in
                cell.shimmersViewss.animateView(enable: false)
                cell.MenuLbl.text = items[indexPath.row]
                cell.MenuImgView.image  = UIImage(named: items[indexPath.row])
                
            }
            return cell
        }else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.HomePageTopCell , for: indexPath) as! TopCVCell
            
            return cell
        }
       
 
       
    }
 
}

extension HomePageVc: UICollectionViewDelegateFlowLayout {
    
    // Set item size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == bottomCv{
            

            return CGSize(width: collectionView.frame.width/3, height: 140)
        }
        else{
            
            
         
            return CGSize(width: 250, height: 115)
        }
     
    }
    
    
    
    
    
   
}
