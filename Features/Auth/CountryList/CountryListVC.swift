//
//  CountryListVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 24/03/25.
//

import UIKit
import SDWebImage

class CountryListVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var NoDataImg: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var newBottomview: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var newNextBtn: UIButton!
    @IBOutlet weak var termsCheckBtn: UIButton!
    @IBOutlet weak var termsLbl: UILabel!
    
    // MARK: - Variables
    
    var CountryListRespons: [CountryData] = []
    var Filter_CountryList: [CountryData] = []
    var country_data: CountryData?
    var selectedName = "INDIA"
    var alert = CustomAlert()
    
    private var termsRange: NSRange?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        get_CountryListApi()
        configureUI()
        configureSearchBar()
        configureBottomView()
        configureTableView()
        setupTermsAndConditionsLabel()
    }
    
    // MARK: - UI Setup
    
    private func configureUI() {
        backBtn.layer.cornerRadius = backBtn.frame.width / 2
        newNextBtn.layer.cornerRadius = 10
        newNextBtn.setTitleFont(style: .primary, size: FontSize.TitleSize)
        newNextBtn.setTitle("Next".translated(), for: .normal)
        NoDataImg.isHidden = true
        NoDataLbl.isHidden = true
        termsCheckBtn.tintColor = .backGroundClr
    }
    
    private func configureBottomView() {
        newBottomview.layer.cornerRadius = 40
        newBottomview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func configureTableView() {
        tv.layer.cornerRadius = 40
        tv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tv.showsVerticalScrollIndicator = false
        tv.register(UINib(nibName: CellConfingName.CountryTvcell, bundle: nil), forCellReuseIdentifier: CellConfingName.CountryTvcell)
        tv.delegate = self
        tv.dataSource = self
    }
    
    private func configureSearchBar() {
        searchBar.placeholder = "Find your country".translated()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.addDoneButton()
        searchBar.delegate = self
    }
    
    // MARK: - Terms Label Setup (Underline + Tap Only on Text)
    
    private func setupTermsAndConditionsLabel() {
        let fullText = "I agree to the Terms and Conditions".translated()
        let underlineText = "Terms and Conditions".translated()
        let attributedString = NSMutableAttributedString(string: fullText)
        if let range = fullText.range(of: underlineText) {
            termsRange = NSRange(range, in: fullText)
            attributedString.addAttributes([
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor.systemBlue
            ], range: termsRange!)
        }
        termsLbl.attributedText = attributedString
        termsLbl.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapOnTerms(_:)))
        termsLbl.addGestureRecognizer(tap)
    }
    
    @objc private func handleTapOnTerms(_ gesture: UITapGestureRecognizer) {
        guard let range = termsRange else { return }
        guard let label = gesture.view as? UILabel,
              let attributedText = label.attributedText else { return }
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        let location = gesture.location(in: label)
        let index = layoutManager.characterIndex(
            for: location,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )
        if NSLocationInRange(index, range) {
            openTermsVC()
        }
    }
    
    
    private func openTermsVC() {
        let vc = TermsAndCondVC()
        vc.tittleString = "Terms & Conditions"
        let urlString = NSLocalizedString("TERMS_URL", comment: "")
        vc.url = urlString
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    // MARK: - Checkbox
    @IBAction func TermsCheckAct(_ sender: UIButton) {
        sender.isSelected.toggle()
        let img = sender.isSelected ? UIImage(named: "checked_Tick") : UIImage(systemName: "circle")
        sender.setImage(img, for: .normal)
    }
    
    // MARK: - Next Action
    @IBAction func nextAct(_ sender: Any) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        guard termsCheckBtn.isSelected else {
            alert.showAlert(title: AlertstringFile.Oops, message: AlertstringFile.Terms_And_Conditions, on: self)
            return
        }
        guard let country = country_data else {
            alert.showAlert(title: AlertstringFile.Oops, message: AlertstringFile.Please_Select_Your_Country, on: self)
            return
        }
        
        UserDefaultFileManager.saveCountryDetails(data: country)
        ServiceUrl.baseurl = country.base_url ?? ""
        ServiceUrl.Reporting_baseurl = country.reporting_url ?? ""
        
        if #available(iOS 14.0, *) {
            let vc = MobileNumberVc()
            vc.country_data = country
            vc.isFromCountry = true
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    // MARK: - API
    private func get_CountryListApi() {
        showActivityLoader()
        APIService.shared.makeApi(url: ServiceUrl.country_list,
                                  parameters: [:],
                                  type: ApitTypeSringFile.GET,
                                  token: "", isBaseUrl: true) { [weak self] (result: Result<CountryListSuccess, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let success):
                if success.status == true, let data = success.data {
                    DispatchQueue.main.async {
                        self.CountryListRespons = data
                        self.Filter_CountryList = data
                        self.country_data = data.first
                        self.tv.reloadData()
                    }
                } else {
                    showNoData(text: success.message ?? "")
                }
                
            case .failure(let error):
                showNoData(text: error.localizedDescription)
            }
            self.hideActivityLoader()
        }
    }
    
    private func showNoData(text: String) {
        DispatchQueue.main.async {
            self.NoDataImg.isHidden = false
            self.NoDataLbl.isHidden = false
            self.NoDataLbl.text = text
        }
    }
}
// MARK: - TableView
extension CountryListVC: UITableViewDelegate, UITableViewDataSource {
    
    var topCountries: [CountryData] {
        return Array(CountryListRespons.prefix(3))
    }
    
    var filteredTopCountries: [CountryData] {
        let ids = Set(topCountries.compactMap { $0.id })
        return Filter_CountryList.filter { ids.contains($0.id ?? -1) }
    }
    
    var filteredAllCountries: [CountryData] {
        let ids = Set(topCountries.compactMap { $0.id })
        return Filter_CountryList.filter { !(ids.contains($0.id ?? -1)) }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredTopCountries.isEmpty ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTopCountries.isEmpty
        ? filteredAllCountries.count
        : (section == 0 ? filteredTopCountries.count : filteredAllCountries.count)
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        return filteredTopCountries.isEmpty
        ? "All Countries".translated()
        : (section == 0 ? "Top Countries".translated() : "All Countries".translated())
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.CountryTvcell, for: indexPath) as? CountryTvcell else {
            return UITableViewCell()
        }
        
        let country = (filteredTopCountries.isEmpty)
        ? filteredAllCountries[indexPath.row]
        : (indexPath.section == 0 ? filteredTopCountries[indexPath.row] : filteredAllCountries[indexPath.row])
        
        cell.nameLbl.text = country.name
        
        if let url = URL(string: country.flag_url ?? "") {
            cell.FlagImage.sd_setImage(with: url, placeholderImage: UIImage(systemName: "globe"))
        }
        
        let isSelected = (country.name?.uppercased() == selectedName)
        cell.checkImage.isHidden = !isSelected
        cell.cellView.backgroundColor = isSelected ? .white : .systemGray5
        cell.cellView.layer.borderWidth = isSelected ? 1 : 0
        cell.cellView.layer.borderColor = isSelected ? UIColor.backGroundClr.cgColor : UIColor.clear.cgColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        let country = (filteredTopCountries.isEmpty)
        ? filteredAllCountries[indexPath.row]
        : (indexPath.section == 0 ? filteredTopCountries[indexPath.row] : filteredAllCountries[indexPath.row])
        selectedName = country.name?.uppercased() ?? ""
        country_data = country
        tableView.reloadData()
    }
}
// MARK: - Search
extension CountryListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        Filter_CountryList = query.isEmpty
        ? CountryListRespons
        : CountryListRespons.filter { $0.name?.lowercased().contains(query) ?? false }
        if Filter_CountryList.isEmpty {
            showNoData(text: "No Data Found".translated())
        } else {
            NoDataImg.isHidden = true
            NoDataLbl.isHidden = true
        }
        tv.reloadData()
    }
}
