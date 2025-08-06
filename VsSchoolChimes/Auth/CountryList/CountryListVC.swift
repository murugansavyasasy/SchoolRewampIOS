//
//  CountryListVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 24/03/25.
//

import UIKit
import DropDown
import Kingfisher

class CountryListVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var newBottomview: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var newNextBtn: UIButton!
    
    @IBOutlet weak var viewTermsAndCondition: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var BottomView: UIView!
    @IBOutlet weak var checkBoxBtn: UIButton!
    @IBOutlet weak var flagImg: UIImageView!
    @IBOutlet weak var countryNameLbl: UILabel!
    @IBOutlet weak var CountryList: UIView!
    @IBOutlet weak var countryCV: UICollectionView!
    let dropDown = DropDown()
    var CountryCheck = 0
    var images = [String]()
    var dropDownList = [String]()
    var CountryListRespons : [CountryData]?
    var country_data : CountryData?
    var timer: Timer?
        var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        get_CountryListApi()
        confingNew()
        BottomView.layer.cornerRadius = 30
        BottomView.backgroundColor = Colornames.auth_screen_color
        BottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        countryCV.register(UINib(nibName: "CountryListCVC", bundle: nil), forCellWithReuseIdentifier: "CountryListCVC")
        if flagImg.image == nil {
            flagImg.isHidden = true
            }
        nextBtn.layer.cornerRadius = 15
        CountryList.layer.cornerRadius = 8
        CountryList.layer.masksToBounds = false
        CountryList.layer.shadowColor = UIColor.black.cgColor
        CountryList.layer.shadowOffset = CGSize(width: 0, height: 5)
        CountryList.layer.shadowOpacity = 0.3
        CountryList.layer.shadowRadius = 6
        nextBtn.layer.masksToBounds = false
        nextBtn.layer.shadowColor = UIColor.black.cgColor
        nextBtn.layer.shadowOffset = CGSize(width: 0, height: 5)
        nextBtn.layer.shadowOpacity = 0.3
        nextBtn.layer.shadowRadius = 6
        nextBtn.applyRightButton()
        startAutoScroll()
        // Underline text
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.blue
        ]
        let attributedString = NSAttributedString(string: "View Terms and Conditions", attributes: attributes)
        viewTermsAndCondition.attributedText = attributedString
    }
    
    func confingNew(){
        newBottomview.layer.cornerRadius = 40
        newBottomview.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        newNextBtn.layer.cornerRadius = 10
        newNextBtn.setTitleFont(style: .primary, size: FontSize.TitleSize)
        
        tv.register(UINib(nibName: "CountryTvcell", bundle: nil), forCellReuseIdentifier: "CountryTvcell")
        tv.delegate = self
        tv.dataSource = self
    }
    
    func startAutoScroll() {
            timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(autoScroll), userInfo: nil, repeats: true)
        }

        @objc func autoScroll() {
            let totalItems = countryCV.numberOfItems(inSection: 0)
            if totalItems == 0 { return }
            
            currentIndex += 1
            if currentIndex >= totalItems {
                currentIndex = 0 // Reset to the first item
            }
            
            let indexPath = IndexPath(item: currentIndex, section: 0)
            countryCV.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let centerX = scrollView.contentOffset.x + (scrollView.frame.size.width / 2)
            
            for cell in countryCV.visibleCells {
                guard let indexPath = countryCV.indexPath(for: cell) else { continue }
                
                let cellFrame = countryCV.layoutAttributesForItem(at: indexPath)?.frame ?? .zero
                let cellCenterX = cellFrame.midX
                let distance = abs(cellCenterX - centerX)
                
                // Scale effect (center cell is bigger, side cells shrink)
                let scale = max(0.85, 1 - (distance / scrollView.frame.size.width) * 0.3)
                
                // Apply scale transformation
                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
                
                // Adjust opacity for smooth effect
                let alpha = max(0.5, 1 - (distance / scrollView.frame.size.width))
                cell.alpha = alpha
            }
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            timer?.invalidate() // Stop timer when leaving screen
        }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CountryListRespons?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = countryCV.dequeueReusableCell(withReuseIdentifier: "CountryListCVC", for: indexPath) as! CountryListCVC
        cell.countryName.text = CountryListRespons?[indexPath.item].name
        cell.countryImg.kf.setImage(with:URL(string: CountryListRespons?[indexPath.item].flag_url ?? ""))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20)/2.3
        return CGSize(width: width, height: collectionView.frame.height)
    }

    @IBAction func togel(_ sender: UIButton) {
        checkBoxBtn.isSelected.toggle()
        let image = checkBoxBtn.isSelected ? UIImage(named: "checkedSquare"):UIImage(named: "uncheckedSquare")
        checkBoxBtn.setImage(image, for: .normal)
    }
    @IBAction func openTermsCondition(_ sender: UIButton) {
        let vc = TermsAndCondVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    @IBAction func selectCountry(_ sender: UIButton) {
    
        dropDown.anchorView = CountryList
        dropDown.show()
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y: CountryList.bounds.height)
        dropDownBtn.setImage( UIImage(systemName: "chevron.up"), for: .normal)
        
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            flagImg.isHidden = false
            flagImg.kf.setImage(with: URL(string: images[index]))
            countryNameLbl.text = item
            dropDownBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            country_data = CountryListRespons?[index]
            
        }
        dropDown.cancelAction = { [weak self] in
            self?.dropDownBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        }
    }
    @IBAction func Next(_ sender: UIButton) {
        if checkBoxBtn.isSelected{
           
            UserDefaultFileManager
                .saveCountryDetails(
                    data: (country_data)!)
            
            ServiceUrl.baseurl = country_data?.base_url ?? ""
            ServiceUrl.report_url = country_data?.reporting_url ?? ""
            if #available(iOS 14.0, *) {
                let vc = MobileNumberVc(nibName: nil, bundle: nil)
                vc.country_data = country_data
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
        }
    }
    func get_CountryListApi() {
        
        APIService.shared.makeApi(url: ServiceUrl.country_list, parameters: [:], type: ApitTypeSringFile.GET, token: "") { [self] (result: Result<CountryListSuccess, Error>) in
            switch result {
            case .success(let successMessage):
                print("get_meeting_detailsApi", result)
                
                if successMessage.status == true {
                    DispatchQueue.main.async { [self] in
                        CountryListRespons?.removeAll()
                        CountryListRespons = successMessage.data
                        dropDownList.removeAll()
                        images.removeAll()
                        for i in 0..<(CountryListRespons?.count ?? 0) {
                            if let countryName = CountryListRespons?[i].name,
                               let flagURL = CountryListRespons?[i].flag_url {  // Fixed missing comma and variable name
                                images.append(flagURL)
                                dropDownList.append(countryName)  // Ensuring the order is maintained

                            }
                        }
                        dropDown.dataSource = dropDownList
                        dropDown.imageURLs = images
                            for j in 0..<images.count {
                                if let cell = dropDown.tableView.cellForRow(at: IndexPath(row: j, section: 0)) as? DropDownCell {
                                    dropDown.configureCell(cell, at: j)
                                }
                            }
                        CountryList.isUserInteractionEnabled = true
                        countryCV.reloadData()
                        tv.reloadData()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CountryListRespons?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv.dequeueReusableCell(withIdentifier: "CountryTvcell", for: indexPath) as! CountryTvcell
        let country = CountryListRespons?[indexPath.row]
        cell.nameLbl.text = country?.name
        if let urlstr = country?.flag_url, let url = URL(string: urlstr) {
            cell.FlagImage.sd_setImage(with: url, placeholderImage: UIImage(systemName: "globe"))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

//@available(iOS 14.0, *)
//extension CountryVc: UITableViewDelegate, UITableViewDataSource {
//
//    
//    
//}
