////
////  ReciverNoticeBoardVC.swift
////  School Chimes
////
////  Created by Chandhru on 24/07/25.
////

import UIKit
import Kingfisher

class ReciverNoticeBoardVC: UIViewController, UISearchBarDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var noDataImg: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tabView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var todayCount: UIButton!
    @IBOutlet weak var totalCount: UIButton!
    @IBOutlet weak var withFileCount: UIButton!
    @IBOutlet weak var withoutFileCount: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var childDetails = UserDefaultFileManager.get_child_Details()
    let transitionDelegate = TransitioningDelegate()
    // MARK: - Properties
    var searchData: [Notice] = []
    var allNotices: [Notice] = [] // For backup during search
    private var isLoading = false
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        Get_Notice()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCounts()
    }
    
    private func setupView() {
        tabView.layer.borderWidth = 0.5
        tabView.layer.borderColor = UIColor.lightGray.cgColor
        nameLbl.setFont(style: .title, size: FontSize.TitleSize)
        let name = childDetails?.name ?? ""
        let standard = "\(childDetails?.standard_name ?? "") - \(childDetails?.section_name ?? "")"
        nameLbl.configureAsBackTitle(firstLine: name, secondLine: standard)
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
        customizeSearchBar()
        setupCollectionView()
        setupRefreshControl()
        setupLoader()
    }
    
    private func customizeSearchBar() {
        searchBar.searchTextField.borderStyle = .none
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.layer.cornerRadius = 8
        searchBar.layer.cornerRadius = 8
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.placeholder = "Search"
    }
    
    private func setupLoader() {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(UINib(nibName: "NoticeCVC", bundle: nil), forCellWithReuseIdentifier: "NoticeCVC")
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func showLoadingState() {
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoadingState() {
        activityIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    private func updateCounts() {
        let today = getCurrentDateString()
        let todayNotices = searchData.filter { $0.created_on?.contains(today) == true }
        let withFiles = searchData.filter { !($0.file_path?.isEmpty ?? true) }
        let withoutFiles = searchData.filter { $0.file_path?.isEmpty ?? true }
        
        totalCount.setAttributedTitle(formattedCountTitle(count: searchData.count, label: "Total", countColor: .black), for: .normal)
        todayCount.setAttributedTitle(formattedCountTitle(count: todayNotices.count, label: "Today", countColor: .blue), for: .normal)
        withFileCount.setAttributedTitle(formattedCountTitle(count: withFiles.count, label: "With File", countColor: .systemGreen), for: .normal)
        withoutFileCount.setAttributedTitle(formattedCountTitle(count: withoutFiles.count, label: "No File", countColor: .red), for: .normal)
    }
    
    private func formattedCountTitle(count: Int, label: String, countColor: UIColor) -> NSAttributedString {
        let countString = "\(count)\n"
        let fullString = countString + label
        let title = NSMutableAttributedString(string: fullString)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        title.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: countColor,
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: countString.count))
        
        title.addAttributes([
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: countString.count, length: label.count))
        
        return title
    }
    
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    @IBAction func searcBtn(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        searchBar.isHidden = !sender.isSelected
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func refreshData() {
        Get_Notice()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
    func Get_Notice() {
        showLoadingState()
        APIService.shared.makeApi(url: ServiceUrl.api_notice_board_get_notice, parameters: [:], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") { [weak self] (result: Result<NoticeResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoadingState()
                
                switch result {
                case .success(let successResponse):
                    self.allNotices = successResponse.data ?? []
                    self.searchData = self.allNotices
                    self.noDataImg.isHidden = !self.searchData.isEmpty
                    self.updateCounts()
                    self.collectionView.reloadData()
                    if successResponse.status == true{
                        if user_inputs.clearTempData(){
                            let parms = [ "mobile_number": UserDefaultFileManager.get_child_Details()?.whatsapp_number ?? "",
                                          "activity": "VIEW_NOTICE_BOARD",
                                          "user_type": 1,
                                          "menu_id": Menu_id.staffSelectedMenuId] as [String : Any]
                            self.paketApiCall(params:parms)
                        }
                    }
                case .failure(let error):
                    print("Error fetching notices: \(error.localizedDescription)")
                }
            }
        }
    }
    
        func paketApiCall(params:[String:Any]){
            APIService.shared.makeApi(
                url: ServiceUrl.dashboard_api_pauket_add_points,
                parameters: params,
                type: ApitTypeSringFile.POST,
                token: childDetails?.access_token ?? ""
            ) { [weak self] (result: Result<EventResponse, Error>) in
                DispatchQueue.main.async {

                    guard let self = self else { return }

                    switch result {
                    case .success(let response): if let window = UIApplication.shared.windows.first {
                        window.makeToast(response.message, duration: 2.0, position: .bottom)
                    }
                    case .failure(let error):
                        if let window = UIApplication.shared.windows.first {
                            window.makeToast(error.localizedDescription, duration: 2.0, position: .bottom)
                        }
                    }
                }
            }
        }
    // MARK: - SearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchData = allNotices
        } else {
            searchData = allNotices.filter {
                ($0.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        noDataImg.isHidden = !searchData.isEmpty
        noDataImg.image = UIImage(named: "noSearchData")
        updateCounts()
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchData = allNotices
        updateCounts()
        collectionView.reloadData()
    }
    
    // MARK: - Count Buttons
    @IBAction func totalCountTapped(_ sender: UIButton) {
        searchData = allNotices
        updateCounts()
        collectionView.reloadData()
    }
    
    @IBAction func todayCountTapped(_ sender: UIButton) {
        let today = getCurrentDateString()
        searchData = allNotices.filter { $0.created_on?.contains(today) == true }
        updateCounts()
        collectionView.reloadData()
    }
    
    @IBAction func withFileCountTapped(_ sender: UIButton) {
        searchData = allNotices.filter { !($0.file_path?.isEmpty ?? true) }
        updateCounts()
        collectionView.reloadData()
    }
    
    @IBAction func withoutFileCountTapped(_ sender: UIButton) {
        searchData = allNotices.filter { $0.file_path?.isEmpty ?? true }
        updateCounts()
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension ReciverNoticeBoardVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoticeCVC", for: indexPath) as? NoticeCVC else {
            return UICollectionViewCell()
        }
        
        let notice = searchData[indexPath.item]
        cell.configure(with: notice)
        cell.editBtn.isHidden = true
        cell.outerView.setShadow(cornerRadius: 8)
        if let files = notice.file_path {
            loadFiles(into: cell, files: files)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let notice = searchData[indexPath.item]
        guard let attributes = collectionView.layoutAttributesForItem(at: indexPath) else { return }
        let cellFrameInSuperview = collectionView.convert(attributes.frame, to: view)
        let detailVC = PrivewVc()
        detailVC.attachmetList = notice.file_path
        detailVC.selectedDate  = notice.created_on
        detailVC.titleString  = notice.title
        detailVC.descriptionString  = notice.description
        //        detailVC.homeWorkid  = FilterHomeWorkList[indexPath.row].id
        detailVC.postedBy  = notice.sent_by
        detailVC.subject_name = "Notice Board".translated()
        detailVC.modalPresentationStyle = .custom
        transitionDelegate.originFrame = cellFrameInSuperview
        detailVC.transitioningDelegate = transitionDelegate
        present(detailVC, animated: true)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 30) / 2
        
        return CGSize(width: width, height: 250)
    }
    
}

// MARK: - File Handling
extension ReciverNoticeBoardVC {
    private func loadFiles(into cell: NoticeCVC, files: [FilePath]) {
        let imageViews = [cell.img1, cell.img2, cell.img3]
        
        // Reset all image views to hidden state
        imageViews.forEach { $0?.isHidden = true }
        cell.imgCount.isHidden = true
        
        for (index, file) in files.enumerated() {
            guard index < imageViews.count,
                  let imageView = imageViews[index],
                  let urlString = file.url,
                  let url = URL(string: urlString) else { continue }
            
            imageView.isHidden = false
            if file.type?.lowercased() != "image" {
                let iconName = getFileIconName(for: url)
                imageView.image = UIImage(named: iconName)
            } else {
                imageView.kf.setImage(with: url)
            }
            
        }
        
        // Handle extra files count
        if files.count > imageViews.count {
            let remaining = files.count - imageViews.count
            cell.imgCount.isHidden = false
            cell.imgCount.setTitle("+\(remaining)", for: .normal)
        }
    }
}
