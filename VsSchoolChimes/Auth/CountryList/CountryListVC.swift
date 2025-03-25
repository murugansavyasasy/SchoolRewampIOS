//
//  CountryListVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 24/03/25.
//

import UIKit
import DropDown
import Kingfisher

class CountryListVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    

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
    override func viewDidLoad() {
        super.viewDidLoad()
        get_CountryListApi()
        BottomView.layer.cornerRadius = 30
        BottomView.backgroundColor = Colornames.auth_screen_color
        BottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        countryCV.register(UINib(nibName: "CountryListCVC", bundle: nil), forCellWithReuseIdentifier: "CountryListCVC")
        if flagImg.image == nil {
            flagImg.isHidden = true
            }
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
    @IBAction func togel(_ sender: UIButton) {
        checkBoxBtn.isSelected.toggle()
        let image = checkBoxBtn.isSelected ? UIImage(named: "checked_Tick"):UIImage(named: "CheckCircle")
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
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
        
    }
    
}
