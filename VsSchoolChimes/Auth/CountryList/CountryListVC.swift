//
//  CountryListVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 24/03/25.
//

import UIKit
import DropDown
import SDWebImage   // Use this instead of Kingfisher

class CountryListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var newBottomview: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var newNextBtn: UIButton!
    
    let dropDown = DropDown()
    var CountryCheck = 0
    var CountryListRespons: [CountryData] = []
    var Filter_CountryList: [CountryData] = []
    var country_data: CountryData?
    var selectedName = "INDIA"
    var selectedIndex: Int?
    var alert = CustomAlert()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        get_CountryListApi()
        configureUI()
        searchBar.searchTextField.backgroundColor = .white
    }
    
    private func configureUI() {
        newBottomview.layer.cornerRadius = 40
        newBottomview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        tv.layer.cornerRadius = 40
        tv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        newNextBtn.layer.cornerRadius = 10
        newNextBtn.setTitleFont(style: .primary, size: FontSize.TitleSize)
        
        tv.register(UINib(nibName: "CountryTvcell", bundle: nil), forCellReuseIdentifier: "CountryTvcell")
        tv.delegate = self
        tv.dataSource = self
        searchBar.placeholder = "Find your country"
        searchBar.searchTextField.addDoneButton()
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        searchBar.barTintColor = .clear
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let searchTextField = searchBar.value(forKey: "searchField") as? UITextField {
            searchTextField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.deactivate(searchTextField.constraints)
            
            NSLayoutConstraint.activate([
                searchTextField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 8),
                searchTextField.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -8),
                searchTextField.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 8),
                searchTextField.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: -8)
            ])
            
            searchTextField.layer.cornerRadius = 8
            searchTextField.clipsToBounds = true
            if let leftView = searchTextField.leftView {
                leftView.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
                
                let separator = UIView(frame: CGRect(x: leftView.frame.width + 2,
                                                     y:0,
                                                     width: 1,
                                                     height: leftView.frame.height))
                separator.backgroundColor = .lightGray
                separator.tag = 999
                separator.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
                leftView.addSubview(separator)
            }
        }
    }



    // MARK: - Next Action
    @available(iOS 14.0, *)
    @IBAction func nextAct(_ sender: Any) {
        guard let CountryDetails = country_data else {
            alert.showAlert(title: "", message: AlertstringFile.Please_Select_Your_Country, on: self)
            return
        }
        
        UserDefaultFileManager.saveCountryDetails(data: CountryDetails)
        ServiceUrl.baseurl = CountryDetails.base_url ?? ""
        ServiceUrl.report_url = CountryDetails.reporting_url ?? ""
        
        let vc = MobileNumberVc(nibName: nil, bundle: nil)
        vc.country_data = CountryDetails
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    // MARK: - Search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if query.isEmpty {
            Filter_CountryList = CountryListRespons
        } else {
            Filter_CountryList = CountryListRespons.filter { item in
                return item.name?.lowercased().contains(query) ?? false
            }
        }
        tv.reloadData()
    }
    
    // MARK: - API
    func get_CountryListApi() {
        APIService.shared.makeApi(url: ServiceUrl.country_list,
                                  parameters: [:],
                                  type: ApitTypeSringFile.GET,
                                  token: "") { [weak self] (result: Result<CountryListSuccess, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let successMessage):
                print("get_CountryListApi", result)
                if successMessage.status == true, let data = successMessage.data {
                    DispatchQueue.main.async {
                        self.CountryListRespons = data
                        self.Filter_CountryList = data
                        self.country_data = data.first
                        self.tv.reloadData()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Filter_CountryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tv.dequeueReusableCell(withIdentifier: "CountryTvcell", for: indexPath) as? CountryTvcell else {
            return UITableViewCell()
        }
        
        let country = Filter_CountryList[indexPath.row]
        cell.nameLbl.text = country.name
        
        if let urlStr = country.flag_url, let url = URL(string: urlStr) {
            cell.FlagImage.sd_setImage(with: url, placeholderImage: UIImage(systemName: "globe"))
        }
        
        if country.name?.uppercased() == selectedName {
            cell.checkImage.isHidden = false
            cell.cellView.backgroundColor = .white
            cell.cellView.layer.borderWidth = 1
            cell.cellView.layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            cell.checkImage.isHidden = true
            cell.cellView.backgroundColor = .systemGray5
            cell.cellView.layer.borderWidth = 0
            cell.cellView.layer.borderColor = UIColor.clear.cgColor
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        selectedName = Filter_CountryList[indexPath.row].name?.uppercased() ?? ""
        country_data = Filter_CountryList[indexPath.row]
        tv.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
