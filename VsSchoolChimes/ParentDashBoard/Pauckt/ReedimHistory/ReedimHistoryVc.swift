//
//  ReedimHistoryVc.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 24/02/25.
//  Copyright © 2025 Gayathri. All rights reserved.
//

import UIKit

class ReedimHistoryVc: UIViewController {
    
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var Searchbar: UISearchBar!
    @IBOutlet weak var segments: UISegmentedControl!
    @IBOutlet weak var cv: UICollectionView!
    
    var CouponType = "all"
    var couponList: [Coupon] = []
    var filteredCouponList: [Coupon] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        cv.backgroundColor = .clear
        cv.backgroundView = backgroundView
        
        segments.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        segments.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        
        cv.register(UINib(nibName: "ReedimHistoryCell", bundle: nil), forCellWithReuseIdentifier: "ReedimHistoryCell")
        
        cv.delegate = self
        cv.dataSource = self
        
        segments.selectedSegmentIndex = 0
        
        Searchbar.delegate = self
        
        if let searchTextField = Searchbar.value(forKey: "searchField") as? UITextField {
            searchTextField.inputAccessoryView = getDoneToolbar()
        }
        MyCouponDetails(coupon_type: CouponType)
    }
    
    @IBAction func SegmentAction(_ sender: Any) {
        
        if segments.selectedSegmentIndex == 0 {
            CouponType = "all"
        } else if segments.selectedSegmentIndex == 1 {
            CouponType = "activated"
        } else if segments.selectedSegmentIndex == 2 {
            CouponType = "expired"
        } else if segments.selectedSegmentIndex == 3 {
            CouponType = "claimed"
        }
        Searchbar.text = "" // clear search text when switching segment
        MyCouponDetails(coupon_type: CouponType)
        Searchbar.resignFirstResponder()
    }
    
    
    
    func MyCouponDetails(coupon_type: String) {
        
        let param: [String: Any] = [
            "mobile_no": "91" + (UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? ""),
            "coupon_status": coupon_type
        ]
        
        APIService.shared.makeApi(
            url: ServiceUrl.my_coupons,
            parameters: param,
            type: ApitTypeSringFile.POST,
            token: PaucketHeader.Paucket
        ) { [weak self] (result: Result<MyCouponResponse, Error>) in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let success):
                print("✅ API Success:", success)
                
                DispatchQueue.main.async {
                    
                    let coupons = success.data?.couponList?.data ?? []
                    
                    if coupons.isEmpty {
                        self.cv.isHidden = true
                        self.Searchbar.isHidden = true
                        self.nodataLbl.isHidden = false
                        self.nodataLbl.text = "No Coupons Found"
                        
                    } else {
                        self.nodataLbl.isHidden = true
                        self.cv.isHidden = false
                        self.Searchbar.isHidden = false
                        
                        self.couponList = coupons
                        self.filteredCouponList = coupons
                        self.cv.reloadData()
                    }
                }
                
            case .failure(let error):
                print("❌ API Error:", error.localizedDescription)
                
                DispatchQueue.main.async {
                    self.nodataLbl.isHidden = false
                    self.nodataLbl.text = "Something went wrong"
                    self.cv.isHidden = true
                    self.Searchbar.isHidden = true
                }
            }
        }
    }
    
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
extension ReedimHistoryVc:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCouponList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReedimHistoryCell", for: indexPath) as! ReedimHistoryCell
        let coupon = filteredCouponList[indexPath.row]
        
        cell.BrandLogoImage.sd_setImage(with: URL(string: coupon.merchantLogo ?? ""), placeholderImage: UIImage(named: "placeHolder.png"), options: .refreshCached)
        
        if coupon.couponStatus == "expired" {
            cell.CouponStatusView.isHidden = false
            cell.CouponStatusView.backgroundColor = .systemGray
            cell.CouponStatusLbl.text = coupon.couponStatus
        } else if coupon.couponStatus == "claimed" {
            cell.CouponStatusView.isHidden = false
            cell.CouponStatusView.backgroundColor = .systemGreen
            cell.CouponStatusLbl.text = "Redeemed"
        } else {
            cell.CouponStatusView.isHidden = true
        }
        
        cell.BrandNameLbl.text = coupon.merchantName
        cell.OfferLbl.text = coupon.offerToShow
        cell.ExpireyDateLbl.text = "Expires in \(coupon.expiresIn ?? 0) days"
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = ClaimCouponVc(nibName: nil, bundle: nil)
        vc.couponDetails = filteredCouponList[indexPath.row]
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
extension ReedimHistoryVc:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2, height: 200)
    }
}

extension ReedimHistoryVc : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCouponList = couponList
            nodataLbl.isHidden = couponList.count != 0
        } else {
            filteredCouponList = couponList.filter {
                $0.merchantName?.lowercased().contains(searchText.lowercased()) ?? false ||
                $0.offerToShow?.lowercased().contains(searchText.lowercased()) ?? false
            }
            nodataLbl.isHidden = filteredCouponList.count != 0
            nodataLbl.text = "No Search Results"
        }
        
        cv.reloadData()
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
    
}
