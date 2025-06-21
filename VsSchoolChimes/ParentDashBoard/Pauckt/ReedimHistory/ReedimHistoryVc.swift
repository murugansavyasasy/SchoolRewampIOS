////
////  ReedimHistoryVc.swift
////  VoicesnapSchoolApp
////
////  Created by admin on 24/02/25.
////  Copyright © 2025 Gayathri. All rights reserved.
////
//
//import UIKit
//import ObjectMapper
//
//class ReedimHistoryVc: UIViewController {
//
//    @IBOutlet weak var nodataLbl: UILabel!
//    @IBOutlet weak var Searchbar: UISearchBar!
//    @IBOutlet weak var segments: UISegmentedControl!
//    @IBOutlet weak var cv: UICollectionView!
//    
//    var CouponType = "all"
//    var couponList: [Coupon] = []
//    var filteredCouponList: [Coupon] = []
//
//    var mobileNumber : String?
//    override func viewDidLoad() {
//            super.viewDidLoad()
//           
//        mobileNumber = UserDefaults.standard.object(forKey:USERNAME) as? String ?? ""
//        cv.backgroundColor = .clear
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [
//            UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0).cgColor,
//            UIColor.white.cgColor
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
//        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
//        gradientLayer.frame = cv.bounds
//        
//        let backgroundView = UIView(frame: cv.bounds)
//        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
//        gradientLayer.frame = view.bounds
//        view.layer.insertSublayer(gradientLayer, at: 0)
//        
//        cv.backgroundView = backgroundView
//        
//           segments.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
//           segments.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
//        
//        cv.register(UINib(nibName: "ReedimHistoryCell", bundle: nil), forCellWithReuseIdentifier: "ReedimHistoryCell")
//         
//        cv.delegate = self
//        cv.dataSource = self
//        
//        segments.selectedSegmentIndex = 0
//        
//        Searchbar.delegate = self
//       
//        if let searchTextField = Searchbar.value(forKey: "searchField") as? UITextField {
//                searchTextField.inputAccessoryView = getDoneToolbar()
//            }
//        MyCouponDetails(coupon_type: CouponType)
//        }
//    
//    @IBAction func SegmentAction(_ sender: Any) {
//        
//        if segments.selectedSegmentIndex == 0 {
//              CouponType = "all"
//          } else if segments.selectedSegmentIndex == 1 {
//              CouponType = "activated"
//          } else if segments.selectedSegmentIndex == 2 {
//              CouponType = "expired"
//          } else if segments.selectedSegmentIndex == 3 {
//              CouponType = "claimed"
//          }
//          Searchbar.text = "" // clear search text when switching segment
//          MyCouponDetails(coupon_type: CouponType)
//          Searchbar.resignFirstResponder()
//    }
//    
//    
//    
//    func MyCouponDetails(coupon_type : String){
//        
//        let param : [String : Any] = [
//            "mobile_no": "91" + (mobileNumber ?? ""),
//            "coupon_status":coupon_type
//        ]
//        
//        print("parsmdddd",param)
//        My_Coupons_Request.call_request(param: param, headers:  DefaultsKeys.packut_Headers){ [self]
//            (res) in
//
//            if let couponResponse = Mapper<MyCouponResponse>().map(JSONString: res) {
//                
//                
//                if couponResponse.data?.couponList?.data?.count == 0{
//                    cv.isHidden = true
//                    Searchbar.isHidden = true
//                    nodataLbl.isHidden = false
//                    nodataLbl.text = "No Coupons Found"
//                }else{
//                    nodataLbl.isHidden = true
//                    cv.isHidden = false
//                    Searchbar.isHidden = false
//                    if let coupons = couponResponse.data?.couponList?.data {
//                        self.couponList = coupons
//                        self.filteredCouponList = coupons  // <-- This is important
//                        self.cv.reloadData()
//                    }
//                    
//                }
//
//            }
//            
//        }
//    }
//        
//    @IBAction func back(_ sender: UIButton) {
//        dismiss(animated: true)
//    }
//    
//    }
//extension ReedimHistoryVc:UICollectionViewDelegate,UICollectionViewDataSource{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return filteredCouponList.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReedimHistoryCell", for: indexPath) as! ReedimHistoryCell
//        let coupon = filteredCouponList[indexPath.row]
//
//        cell.BrandLogoImage.sd_setImage(with: URL(string: coupon.merchantLogo ?? ""), placeholderImage: UIImage(named: "placeHolder.png"), options: .refreshCached)
//
//        if coupon.couponStatus == "expired" {
//            cell.CouponStatusView.isHidden = false
//            cell.CouponStatusView.backgroundColor = .systemGray
//            cell.CouponStatusLbl.text = coupon.couponStatus
//        } else if coupon.couponStatus == "claimed" {
//            cell.CouponStatusView.isHidden = false
//            cell.CouponStatusView.backgroundColor = .systemGreen
//            cell.CouponStatusLbl.text = "Redeemed"
//        } else {
//            cell.CouponStatusView.isHidden = true
//        }
//
//        cell.BrandNameLbl.text = coupon.merchantName
//        cell.OfferLbl.text = coupon.offerToShow
//        cell.ExpireyDateLbl.text = "Expires in \(coupon.expiresIn ?? 0) days"
//        return cell
//    }
//
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//    
//        let vc = ClaimCouponVc(nibName: nil, bundle: nil)
//        vc.couponDetails = filteredCouponList[indexPath.row]
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
//    }
//}
//extension ReedimHistoryVc:UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.width/2, height: 200)
//    }
//}
//
//extension ReedimHistoryVc : UISearchBarDelegate {
//    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText.isEmpty {
//            filteredCouponList = couponList
//            nodataLbl.isHidden = couponList.count != 0
//        } else {
//            filteredCouponList = couponList.filter {
//                $0.merchantName?.lowercased().contains(searchText.lowercased()) ?? false ||
//                $0.offerToShow?.lowercased().contains(searchText.lowercased()) ?? false
//            }
//            nodataLbl.isHidden = filteredCouponList.count != 0
//            nodataLbl.text = "No Search Results"
//        }
//
//        cv.reloadData()
//    }
//
//
//    func getDoneToolbar() -> UIToolbar {
//        let doneToolbar = UIToolbar()
//        doneToolbar.barStyle = .default
//        doneToolbar.tintColor = .systemBlue
//        doneToolbar.sizeToFit()
//
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
//        done.setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
//
//        doneToolbar.items = [flexSpace, done]
//        return doneToolbar
//    }
//
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//
//}
