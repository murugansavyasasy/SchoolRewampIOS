//
//  CountryListVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 24/03/25.
//

import UIKit
import DropDown
import Kingfisher

class CountryListVC: UIViewController, UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var newBottomview: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var newNextBtn: UIButton!
    let dropDown = DropDown()
    var CountryCheck = 0
    var images = [String]()
    var dropDownList = [String]()
    var CountryListRespons : [CountryData]?
    var Filter_CountryList : [CountryData]?
    var country_data : CountryData?
    var timer: Timer?
    var selectedName = "INDIA"
    var selectedIndex:Int?
    var alert = CustomAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        get_CountryListApi()
        confingNew()
        searchBar.searchTextField.backgroundColor = .clear
    }
    
    func confingNew(){
        newBottomview.layer.cornerRadius = 40
        newBottomview.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        tv.layer.cornerRadius = 40
        tv.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        searchBar.placeholder = "Find your country"
        searchBar.searchBarStyle = .minimal
        searchBar.barTintColor = .white
//        searchBar.backgroundColor = .white
//        searchBar.layer.cornerRadius = 10
//        searchBar.clipsToBounds = true
        searchBar.searchTextField.addDoneButton()
        searchBar.delegate = self
        
        //        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
        //                textField.backgroundColor = .white
        //                textField.layer.cornerRadius = 10
        //                textField.clipsToBounds = true
        //            }
        //
        //            // Remove default background
        //            searchBar.backgroundImage = UIImage()
        //            searchBar.barTintColor = .white
        //            searchBar.backgroundColor = .white
        newNextBtn.layer.cornerRadius = 10
        newNextBtn.setTitleFont(style: .primary, size: FontSize.TitleSize)
        
        tv.register(UINib(nibName: "CountryTvcell", bundle: nil), forCellReuseIdentifier: "CountryTvcell")
        tv.delegate = self
        tv.dataSource = self
    }
    
    @available(iOS 14.0, *)
    @IBAction func nextAct(_ sender: Any) {
        
        if let CountryDetails = country_data {
            
            UserDefaultFileManager
                .saveCountryDetails(
                    data: (CountryDetails))
            
            ServiceUrl.baseurl = country_data?.base_url ?? ""
            ServiceUrl.report_url = country_data?.reporting_url ?? ""
            let vc = MobileNumberVc(nibName: nil, bundle: nil)
            vc.country_data = country_data
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        }else {
            
            alert.showAlert(title: "", message: AlertstringFile.Please_Select_Your_Country, on: self)
            
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if query.isEmpty {
            Filter_CountryList = CountryListRespons
        } else {
            Filter_CountryList = CountryListRespons?.filter { item in
                let values = [
                    item.name?.lowercased()
                ]

                return values.contains { $0?.contains(query) == true }
            }
        }
        
        tv.reloadData()

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
                        Filter_CountryList = CountryListRespons
                        country_data = CountryListRespons?.first
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
        return Filter_CountryList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tv.dequeueReusableCell(withIdentifier: "CountryTvcell", for: indexPath) as! CountryTvcell
        let country = Filter_CountryList?[indexPath.row]
        cell.nameLbl.text = country?.name
        if let urlstr = country?.flag_url, let url = URL(string: urlstr) {
            cell.FlagImage.sd_setImage(with: url, placeholderImage: UIImage(systemName: "globe"))
        }
        
        
        if country?.name?.uppercased() == selectedName{
            cell.checkImage.isHidden = false
            cell.cellView.backgroundColor = .white
            cell.cellView.layer.borderColor = UIColor.systemBlue.cgColor
        }else{
            cell.checkImage.isHidden = true
            cell.cellView.backgroundColor = .systemGray5
            cell.cellView.layer.borderColor = UIColor.clear.cgColor
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        selectedName = Filter_CountryList?[selectedIndex ?? 0].name?.uppercased() ?? ""
        country_data = Filter_CountryList?[selectedIndex ?? 0]
        tv.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
