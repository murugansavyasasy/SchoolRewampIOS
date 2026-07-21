
import UIKit
class HomePaucktVC: UIViewController
,UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate,UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var UsedCoinsLbl: UILabel!
    @IBOutlet weak var AllCouponsLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var TotalcoinsFullView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var totalCoinsLbl: UILabel!
    @IBOutlet weak var couponsCV: UICollectionView!
    @IBOutlet weak var categoriesCV: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var norecordLbl: UILabel!
    @IBOutlet weak var norecordImg: UIImageView!
    
    
    enum SectionType: Int, CaseIterable {
        case firstCellType
        case secondCellType
        case thirdCellType
    }
    
    var offers: [Offer] = []
    var secondArray: [Int] = [10, 20, 30, 40]
    var thirdArray: [Bool] = [true, false, true, false]
    var categories: [Categorys] = []
    var CampaignData : [Campaign] = []
    var filteredOffers: [Campaign] = []
    var getCoinData : GetCoinData?
    var childId : String?
    var mobileNumber : String?
    var selectedCategoryIndex: Int = 0 // Default is "All"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackBtn.setTitle(MenuStringFile.selectedMenuName, for: .normal)
        
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.delegate = self
        
        // Remove the default background of UISearchBar
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = .clear
        searchBar.isTranslucent = true
        
        // Set textfield background color
        let textField = searchBar.searchTextField
        textField.backgroundColor = .systemGray5
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        
        textField.addDoneButton()
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.inputAccessoryView = getDoneToolbar()
        }
        //        couponsCV.backgroundColor = .clear
        //        let gradientLayer = CAGradientLayer()
        //        gradientLayer.colors = [
        //            UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0).cgColor,
        //            UIColor.white.cgColor
        //        ]
        //        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        //        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        //        gradientLayer.frame = couponsCV.bounds
        //
        //        let backgroundView = UIView(frame: couponsCV.bounds)
        //        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        //        gradientLayer.frame = UIScreen.main.bounds
        //        view.layer.insertSublayer(gradientLayer, at: 0)
        //        couponsCV.backgroundView = backgroundView
        //
        TotalcoinsFullView.layer.cornerRadius = 12
        TotalcoinsFullView.layer.shadowColor = UIColor.black.cgColor
        TotalcoinsFullView.layer.shadowOpacity = 0.1
        TotalcoinsFullView.layer.shadowOffset = CGSize(width: 0, height: 2)
        TotalcoinsFullView.layer.shadowRadius = 4
        //
        Get_Categories()
        //        BackBtn.setTitleFont(style: .secondary, size: 15)
        totalCoinsLbl.setFont(style: .title, size: 17)
        UsedCoinsLbl.setFont(style: .body, size: 15)
        AllCouponsLbl.setFont(style: .title, size: 17)
        setupCollectionView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //        get_coins(){
        //
        //            self.Get_Categories()
        //        }
    }
    
    func getDoneToolbar() -> UIToolbar {
        let doneToolbar = UIToolbar()
        doneToolbar.barStyle = .default
        doneToolbar.tintColor = .systemBlue
        doneToolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        done.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        
        doneToolbar.items = [flexSpace, done]
        return doneToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        
        searchBar?.isHidden = !sender.isSelected
        
        if sender.isSelected {
            searchBar?.becomeFirstResponder()
        } else {
            searchBar?.resignFirstResponder()
        }
        
        filteredOffers = CampaignData
        norecordImg.isHidden = filteredOffers.count != 0
        norecordLbl.isHidden = filteredOffers.count != 0
        norecordLbl.text = "Data Not Found"
        searchBar.searchTextField.text = ""
        searchBar?.resignFirstResponder()
        couponsCV.reloadData()
    }
    func setupCollectionView() {
        
        couponsCV.register(UINib(nibName: "CoupenCvCell", bundle: nil), forCellWithReuseIdentifier: "CoupenCvCell")
        categoriesCV.register(UINib(nibName: "CaterogyCvCell", bundle: nil), forCellWithReuseIdentifier: "CaterogyCvCell")
        couponsCV.showsHorizontalScrollIndicator = false
        couponsCV.showsVerticalScrollIndicator = false
        couponsCV.delegate = self
        couponsCV.dataSource = self
        
    }
    
    @IBAction func  back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        if collectionView == categoriesCV{
            
            return categories.count
            
        }else{
            
            return filteredOffers.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == categoriesCV{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CaterogyCvCell", for: indexPath) as! CaterogyCvCell
            let category = categories[indexPath.item]
            cell.configure(with: category, selected: indexPath.item == selectedCategoryIndex)
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoupenCvCell", for: indexPath) as! CoupenCvCell
            //               cell.configure(with: thirdArray[indexPath.item])
            
            let offer = filteredOffers[indexPath.row]
            cell.titleLabel.text = offer.category_name
            cell.subtitleLabel.text = offer.merchant_name
            cell.discountLabel.text = offer.offer_to_show
            
            
            let futureDateString = offer.end_date
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = LocaleManager.shared.apiLocale
            
            if let futureDate = dateFormatter.date(from: futureDateString ?? "") {
                
                let currentDate = Date()
                
                // Calculate the difference in days using Calendar
                let calendar = Calendar.current
                let components = calendar.dateComponents([.day], from: currentDate, to: futureDate)
                
                if let daysDifference = components.day {
                    cell.durationLabel.text = String(daysDifference) + " days"
                } else {
                    print("Couldn't calculate the difference in days.")
                }
            } else {
                print("Invalid date format.")
            }
            
            
            
            cell.backgroundImageView.sd_setImage(with: URL(string: offer.thumbnail ?? ""), placeholderImage: UIImage(named: ""))
            cell.brandImg.layer.cornerRadius = 12
            cell.brandImg.sd_setImage(with: URL(string: offer.merchant_logo ?? ""), placeholderImage: UIImage(named: ""))
            return cell
            
        }
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoriesCV {
            let category = categories[indexPath.item]
            let font = UIFont.systemFont(ofSize: 12)
            let padding: CGFloat = 24
            let text = category.category_name ?? ""
            
            let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
            let width = max(textWidth + padding, 70) // minimum width
            return CGSize(width: 100, height: collectionView.bounds.height)
        } else {
            return CGSize(width: collectionView.frame.width / 2, height: 290)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == couponsCV{
            
            let vc = CooponViewVC(nibName: nil, bundle: nil)
            vc.source_Link = filteredOffers[indexPath.row].source_link ?? ""
            vc.Category = filteredOffers[indexPath.row].category_name
            vc.ThumbnailImg = filteredOffers[indexPath.row].thumbnail
            vc.totalPoints = String(getCoinData?.pointsEarned ?? 0)
            
            if let status = filteredOffers[indexPath.row].coupon_status {
                
                vc.ActivatedStatus = status
            }
            
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        } else if collectionView == categoriesCV {
            
            selectedCategoryIndex = indexPath.item
            categoriesCV.reloadData()
            
            let selectedCategory = categories[indexPath.item]
            if selectedCategory.id == 0 {
                AllCouponsLbl.text = "All Coupons"
                Get_campians(
                    parameter: ["mobile_no": "91" + (UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? "")]
                )
            } else {
                AllCouponsLbl.text = selectedCategory.category_name
                searchBar.searchTextField.text = ""
                searchBar?.resignFirstResponder()
                Get_campians(
                    parameter: [
                        "mobile_no": "91" + (
                            UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? ""
                        ),
                        "category_id": "\(selectedCategory.id ?? 0)"
                    ]
                )
            }
            couponsCV.reloadData()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredOffers = CampaignData
        } else {
            filteredOffers = CampaignData.filter { offer in
                offer.campaign_name?
                    .lowercased()
                    .contains(searchText.lowercased()) == true ||
                offer.merchant_name?
                    .lowercased()
                    .contains(searchText.lowercased()) == true ||
                offer.category_name?
                    .lowercased()
                    .contains(searchText.lowercased()) == true
            }
        }
        norecordImg.isHidden = filteredOffers.count != 0
        norecordLbl.isHidden = filteredOffers.count != 0
        norecordLbl.text = "Data Not Found"
        couponsCV.reloadData()
    }
    
    func Get_Categories(){
        
        let param: [String: Any] = [:]
        
        APIService.shared.makeApi(url: ServiceUrl.get_category_list, parameters: param, type: ApitTypeSringFile.GET, token: PaucketHeader.Paucket, isBaseUrl: false) {[self] (result: Result<CategoriesResponse,Error>) in
            
            switch result{
                
            case .success(let success):
                DispatchQueue.main.async { [self] in
                    
                    if success.data?.categories?.count == 0 {
                        AllCouponsLbl.isHidden = true
                        norecordLbl.isHidden = false
                        norecordLbl.text = "There is no Coupon Found"
                    } else {
                        norecordLbl.isHidden = true
                        AllCouponsLbl.isHidden = false
                        
                        var updatedCategories = success.data?.categories ?? []
                        let allCategory = Categorys(id: 0, category_name: "All")
                        updatedCategories.insert(allCategory, at: 0)
                        self.categories = updatedCategories
                        
                        categoriesCV.delegate = self
                        categoriesCV.dataSource = self
                        self.categoriesCV.reloadData()
                        
                        // ✅ Auto-select and auto-scroll to first index
                        let firstIndex = IndexPath(item: 0, section: 0)
                        self.categoriesCV.selectItem(at: firstIndex, animated: false, scrollPosition: [])
                        self.categoriesCV.scrollToItem(at: firstIndex, at: .left, animated: true)
                        self.collectionView(self.categoriesCV, didSelectItemAt: firstIndex)
                    }
                    
                    
                    Get_campians(
                        parameter: ["mobile_no": "91" + (UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? "")]
                    )
                }
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print("Error:",error.localizedDescription)
                }
            }
        }
    }
    
    func Get_campians(parameter : [String: Any]){
        print("paramparamm,nc",parameter)
        
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        APIService.shared
            .makeApi(url: ServiceUrl.get_campaigns, parameters: parameter, type: ApitTypeSringFile.POST, token: PaucketHeader.Paucket, isBaseUrl: false) {[self] (
                result: Result<CampaignsResponse,
                Error>
            ) in
                
                switch result{
                    
                case .success(let success):
                    print("successseadasadad`",success)
                    DispatchQueue.main.async { [self] in
                        if success.data?.campaigns?.data?.count ?? 0 == 0 {
                            norecordLbl.isHidden = false
                            norecordImg.isHidden = false
                            norecordLbl.text = "There is no Coupon Found"
                            AllCouponsLbl.isHidden = true
                            couponsCV.isHidden = true
                        }else{
                            norecordLbl.isHidden = true
                            norecordImg.isHidden = true
                            AllCouponsLbl.isHidden = false
                            CampaignData = success.data?.campaigns?.data ?? []
                            filteredOffers = CampaignData
                            couponsCV.isHidden = false
                            couponsCV.delegate = self
                            couponsCV.dataSource = self
                            couponsCV.reloadData()
                        }
                        if #available(iOS 15.0, *) {
                            self.hideActivityLoader()
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        if #available(iOS 15.0, *) {
                            self.hideActivityLoader()
                        }
                    }
                }
            }
    }
}



struct Offer {
    let title: String
    let subtitle: String
    let discount: String
    let locationInfo: String
    let durationInfo: String
    let imageName: String
}


struct PaucktCategory {
    let id: Int
    let name: String
    let imageUrl: String
}



