//
//  NoticeBoardVc.swift
//  VsSchoolChimes
//
//  Created by admin on 15/11/24.
//

import UIKit
import DropDown
protocol EditObjectDelegate{
    func editDta(edit:Any?)
}
@available(iOS 14.0, *)
class NoticeBoardVc: UIViewController,UISearchBarDelegate, SelectNotice, SelectedId {
    func selectId(id: String?, edit: Bool?) {
        if edit ?? false{
            if let selectedNotice = self.searchData.first(where: { $0.id == id }) {
//                delegate?.editDta(edit: selectedNotice)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let vc = SenderNoticeBoardVC()
                    
                    vc.editReport = selectedNotice
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.deleteNotice(id:id ?? "")
            }
        }
    }
    
    func didTapButton(
        title: String,
        content: String,
        items: [FilePath],
        editId:String
    ) {
        print("dsafersd")
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var outerDropDownView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var schoolName: UILabel!
    @IBOutlet weak var schoolDropDown: UIView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var noDataImg: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var staffdetails = UserDefaultFileManager.get_staff_Details()
    var Scholldetails = UserDefaultFileManager.getUserDetails()
    let transitionDelegate = TransitioningDelegate()
    // MARK: - Properties
    var searchData: [Notice] = []
    var allNotices: [Notice] = []
    var delegate:EditObjectDelegate?
    let alert = CustomAlert()
    let dropDown = DropDown()
    var schoolList:[String]?
    private var isLoading = false
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    var school_details = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var token : String?
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.searchTextField.addDoneButton()
        
        if checkMutipleSchool() {
            backBtn.setTitle("NoticeBoard", for: .normal)
        } else {
            let schoolName = UserDefaultFileManager.get_staff_Details()?.school_name ?? ""
            backBtn.configureAsBackButton(firstLine: "NoticeBoard", secondLine: schoolName)
        }
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        schoolDropDown.setShadow(cornerRadius: 4)
        if school_details?.count ?? 0 > 1 {
            schoolDropDown.isHidden = false
            if let staffToken = staffdetails?.access_token {
                let matchedSchoolName = school_details?
                    .first?
                    .school_name
                schoolName.text = matchedSchoolName ?? "School name not found"
            }
            schoolList = school_details?.compactMap { $0.school_name }
            self.dropDown.dataSource = self.schoolList ?? []
        }else{
            outerDropDownView.isHidden = true
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(catagoryTapped))
        schoolDropDown.isUserInteractionEnabled = true
        schoolDropDown.addGestureRecognizer(tapGesture)
        setupView()
    }
    func checkMutipleSchool() -> Bool {
        let staffCount = Scholldetails?.user_details?.staff_details?.count ?? 0
        if staffCount > 1 {
            switch Scholldetails?.user_details?.staff_details?.first?.priority_level {
            case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                return true
            default:
                return false
            }
        }
        return false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Get_Notice()
    }
    @objc func catagoryTapped() {
        print("Category View Tapped")
        dropDown.anchorView = schoolDropDown
        dropDown.show()
        dropDown.bottomOffset = CGPoint(x: 0, y: schoolDropDown.bounds.height)
        dropDown.selectionAction = { [self] (index: Int, item: String) in
            schoolName.text = item
            if let selectedSchool = school_details?.first(where: { $0.school_name == item }) {
                
                localData.editToken = selectedSchool.access_token
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.Get_Notice()
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupView() {
        customizeSearchBar()
        setupCollectionView()
        setupRefreshControl()
        setupLoader()
        createBtn.layer.cornerRadius = createBtn.frame.height / 2
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    func searchHide(hide: Bool) {
        //        searchBar?.isHidden = !hide
        //        if hide {
        //            searchBar?.becomeFirstResponder()
        //        } else {
        //            searchBar?.resignFirstResponder()
        //        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        searchBar?.isHidden = !sender.isSelected
        if sender.isSelected {
            searchBar?.becomeFirstResponder()
        } else {
            searchData = allNotices
            self.noDataLbl.isHidden = !self.searchData.isEmpty
            self.noDataImg.isHidden = !self.searchData.isEmpty
            collectionView.reloadData()
            searchBar.searchTextField.text = ""
            searchBar?.resignFirstResponder()
        }
    }
    @IBAction func createAssignment(_ sender: UIButton) {
        let vc = SenderNoticeBoardVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    private func customizeSearchBar() {
        searchBar.searchTextField.borderStyle = .none
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.layer.cornerRadius = 8
        searchBar.searchTextField.backgroundColor = .white
        searchBar.layer.cornerRadius = 8
        searchBar.searchTextField.layer.masksToBounds = true
        searchBar.placeholder = "Search"
        searchBar.delegate = self
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
    
    private func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    @objc private func refreshData() {
        Get_Notice()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
    func Get_Notice() {
        showLoadingState()
        APIService.shared.makeApi(url: ServiceUrl.admin_api_notice_board_report, parameters: [:], type: ApitTypeSringFile.GET, token: localData.editToken ?? staffdetails?.access_token ?? "") { [weak self] (result: Result<NoticeResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.hideLoadingState()
                
                switch result {
                case .success(let successResponse):
                    self.allNotices = successResponse.data ?? []
                    self.searchData = self.allNotices
                    self.collectionView.reloadData()
                    self.noDataLbl.text = successResponse.message ?? ""
                    self.noDataLbl.isHidden = !self.searchData.isEmpty
                    self.noDataImg.isHidden = !self.searchData.isEmpty
                    self.searchBtn.isHidden = self.searchData.isEmpty
                case .failure(let error):
                    print("Error fetching notices: \(error.localizedDescription)")
                }
            }
        }
    }
    func deleteNotice(id: String?) {
        guard let noticeId = id, !noticeId.isEmpty else {
            print("Invalid notice ID")
            return
        }
        
        alert.showAlertCancel(
            title: AlertstringFile.Confirm,
            message: AlertstringFile.deletemessage,
            actionLbl1: AlertstringFile.delete,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: {
                APIService.shared.makeApi(
                    url: ServiceUrl.admin_api_notice_board_delete,
                    parameters: ["id": noticeId],
                    type: ApitTypeSringFile.PUT,
                    token: self.staffdetails?.access_token ?? ""
                ) { [weak self] (result: Result<ResetPasswordSuc, Error>) in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.hideLoadingState()
                        
                        switch result {
                        case .success(let successResponse):
                            if successResponse.status == true {
                                CustomAlert.showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: successResponse.message ?? "",
                                    on: self
                                ) {
                                    self.allNotices.removeAll { $0.id == noticeId }
                                    self.searchData.removeAll { $0.id == noticeId }
                                    self.collectionView.reloadData()
                                    self.noDataLbl.isHidden = !self.searchData.isEmpty
                                    self.noDataImg.isHidden = !self.searchData.isEmpty
                                }
                            } else {
                                self.alert.showAlert(
                                    title: AlertstringFile.Failed,
                                    message: successResponse.message ?? "",
                                    on: self
                                )
                            }
                            
                        case .failure(let error):
                            print("Error deleting notice: \(error.localizedDescription)")
                            self.alert.showAlert(title: "Error", message: error.localizedDescription, on: self)
                        }
                    }
                }
            },
            onNo: {
                print("User canceled deletion")
            }
        )
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
        self.noDataLbl.isHidden = !self.searchData.isEmpty
        self.noDataImg.isHidden = !self.searchData.isEmpty
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchData = allNotices
        collectionView.reloadData()
    }
    
    // MARK: - Count Buttons
    @IBAction func totalCountTapped(_ sender: UIButton) {
        searchData = allNotices
        collectionView.reloadData()
    }
    
    @IBAction func todayCountTapped(_ sender: UIButton) {
        let today = getCurrentDateString()
        searchData = allNotices.filter { $0.created_on?.contains(today) == true }
        collectionView.reloadData()
    }
    
    @IBAction func withFileCountTapped(_ sender: UIButton) {
        searchData = allNotices.filter { !($0.file_path?.isEmpty ?? true) }
        collectionView.reloadData()
    }
    
    @IBAction func withoutFileCountTapped(_ sender: UIButton) {
        searchData = allNotices.filter { $0.file_path?.isEmpty ?? true }
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource & Delegate
@available(iOS 14.0, *)
extension NoticeBoardVc: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoticeCVC", for: indexPath) as? NoticeCVC else {
            return UICollectionViewCell()
        }
        
        let notice = searchData[indexPath.item]
        cell.configure(with: notice)
        cell.editBtn.isHidden = false
//        cell.reminderBtn.isHidden = false
        cell.edit = notice.can_edit
        cell.delete = notice.can_delete
        cell.selectedId = notice.id
        cell.editBtn.isHidden = !(notice.can_edit ?? false || notice.can_delete ?? false)
        cell.delegate = self
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
        detailVC.subject_name = "Notice Board".translated()
        detailVC.postedBy  = notice.sent_by
        detailVC.modalPresentationStyle = .custom
        transitionDelegate.originFrame = cellFrameInSuperview
        detailVC.transitioningDelegate = transitionDelegate
        present(detailVC, animated: true)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 10) / 2
        
        return CGSize(width: width, height: 250)
    }
    
}

// MARK: - File Handling
@available(iOS 14.0, *)
extension NoticeBoardVc {
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

