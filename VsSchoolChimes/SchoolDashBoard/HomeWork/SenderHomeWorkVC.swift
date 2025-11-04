

//
//  SenderHomeWorkVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 16/04/25.
//

import UIKit
import DropDown

@available(iOS 14.0, *)
class SenderHomeWorkVC: UIViewController, SelectedId {
    func selectId(id: String?, edit: Bool?) {
        
        if edit ?? false{
            if let selectedEvent = HomeWork(withId: id ?? "") {
                selectNotice?.editDta(edit: selectedEvent)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                   
                        let vc = SenderSideHomeWorkViewController(nibName: nil, bundle: nil)
                    vc.editId = selectedEvent.id
                    vc.EditHomeWork = selectedEvent
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    
                }
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.homeWorkDelete(id:id ?? "")
            }
        }
    }
    @IBOutlet weak var backLbl: UILabel!
    @IBOutlet weak var headerView: UIView!

    @IBOutlet weak var designUseView: UIView!
    @IBOutlet weak var cvHeight: NSLayoutConstraint!
    // MARK: - Outlets
    @IBOutlet weak var Cv: UICollectionView!
    @IBOutlet weak var noDataFound: UIImageView!
    @IBOutlet weak var nodataFoundLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var SectionLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var standerdView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var acodomicYearLbl: UILabel!
    @IBOutlet weak var dropDownStack: UIStackView!
    @IBOutlet weak var todayLbl: UILabel!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var acodemicdropView: UIView!
    @IBOutlet weak var searchBtn: UIButton!
    
    // MARK: - Properties
    let standardDropdown = DropDown()
    let SectionDropdown = DropDown()
    let acidamicdrops = DropDown()
    let formatter = DateFormatter()
    let customdate = DateFormatter()
    var homeWorkList: [Homework]?
    var FilterHomeWorkList: [Homework]?
    var AcadimicYearDatas: [AcadimicYearData] = []
    var accadimYr: [String] = []
    var standardDetails: [StandardDetail]?
    var sectionsDetails: [sectionsDetail]?
    var sectionList = [String]()
    var standerdList = [String]()
    var selectedImgUrl: [FilePath] = []
    var acodemicId: Int?
    var sectionId: String?
    var selectNotice: EditObjectDelegate?
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    let staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    let transitionDelegate = TransitioningDelegate()
    let alert = CustomAlert()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        HomeWorkCvCell
        setupViews()
        registerCVCells()
       
        searchBar.delegate = self
    }
 
    @IBAction func backBtnAct(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
    

    @IBAction func searchBtnAct(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected{
            
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
            sender.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        }else{
            searchBar.isHidden = true
            searchBar.resignFirstResponder()
            sender.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            searchBar.searchTextField.text = ""
            FilterHomeWorkList = homeWorkList
            let isListEmpty = FilterHomeWorkList?.isEmpty ?? true
            noDataFound.isHidden = !isListEmpty
            nodataFoundLbl.isHidden = !isListEmpty
            Cv.reloadData()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getAcademicYearList()
    }
    // MARK: - Setup
    private func setupViews() {
//        applyShadowAndCornerRadius(to: dateView)
        backLbl.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName, secondLine: staffDetails?.school_name ?? "")
        headerView.layer.cornerRadius = 20
        headerView.layer.masksToBounds = true
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        acodemicdropView.setShadow()
        standerdView.setShadow(cornerRadius: 8)
        sectionView.setShadow(cornerRadius: 8)
        dateView.layer.borderColor = UIColor.lightGray.cgColor
        dateView.layer.borderWidth = 0.5
        dateView.layer.cornerRadius = 8
        dateBtn.layer.cornerRadius = 8
        dateBtn.backgroundColor = .blue.withAlphaComponent(0.6)
        acodemicdropView.layer.borderColor = UIColor.lightGray.cgColor
        acodemicdropView.layer.borderWidth = 0.5
        
        standerdView.layer.borderColor = UIColor.lightGray.cgColor
        standerdView.layer.borderWidth = 0.5
        
        sectionView.layer.borderColor = UIColor.lightGray.cgColor
        sectionView.layer.borderWidth = 0.5

        searchBar.searchTextField.addDoneButton()
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.backgroundImage = UIImage()
        dateLbl.setFont(style: .title, size: FontSize.TitleSize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        SectionLbl.setFont(style: .body, size: FontSize.BodySize)
        dateSelect(nil)
    }

    private func registerCVCells() {
        
        Cv.register(
                UINib(nibName: "HomeWorkCvCell", bundle: nil),
                forCellWithReuseIdentifier: "HomeWorkCvCell"
            )
//        homeWorkTable.register(UINib(nibName: CellConfingName.VideoTVCell, bundle: nil), forCellReuseIdentifier: CellConfingName.VideoTVCell)
    }

    // MARK: - Dropdown Selections
    @IBAction func selectAcademicYear(_ sender: UIButton) {
        acidamicdrops.anchorView = acodemicdropView
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acodemicdropView.bounds.height)
        acidamicdrops.show()
        acidamicdrops.selectionAction = { [weak self] index, item in
            self?.acodomicYearLbl.text = item
            self?.acodemicId = self?.AcadimicYearDatas[index].id
            self?.getStandardsAPI()
        }
    }

    
    @IBAction func CreateNewAct(_ sender: UIButton) {
        
        let vc = SenderSideHomeWorkViewController(nibName: nil, bundle: nil)
        vc.editId = ""
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func selectStandard(_ sender: UIButton) {
        guard !dropDownStack.isHidden else { return }
        standardDropdown.anchorView = standerdView
        standardDropdown.dataSource = standerdList
        standardDropdown.bottomOffset = CGPoint(x: 0, y: standerdView.bounds.height)
        standardDropdown.direction = .bottom
        standardDropdown.show()

        standardDropdown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            guard let selectedSections = self.standardDetails?[index].sections else { return }
            self.searchBar.text = ""
            self.sectionsDetails = selectedSections
            self.sectionList = selectedSections.compactMap { $0.name }
            self.sectionId = selectedSections.first?.id
            self.StandardLbl.text = item
            self.SectionLbl.text = selectedSections.first?.name ?? ""
//            DispatchQueue.main.async {
//                self.Cv.layoutIfNeeded()
//                self.cvHeight.constant = 300
//            }
            self.GetHomeWorkReport(self.sectionId, self.dateLbl.text ?? "")
        }
    }

    @IBAction func selectSection(_ sender: UIButton) {
        guard !dropDownStack.isHidden else { return }
        SectionDropdown.anchorView = sectionView
        SectionDropdown.dataSource = sectionList
        SectionDropdown.bottomOffset = CGPoint(x: 0, y: sectionView.bounds.height)
        SectionDropdown.show()
        
        SectionDropdown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            guard index < (self.sectionsDetails?.count ?? 0) else { return }
            self.searchBar.text = ""
            self.sectionId = self.sectionsDetails?[index].id
            self.SectionLbl.text = item
//            DispatchQueue.main.async {
//                self.Cv.layoutIfNeeded()
//                self.cvHeight.constant = 300
//            }
            self.GetHomeWorkReport(self.sectionId, self.dateLbl.text ?? "")
        }
    }

    @IBAction func selectDate(_ sender: UIButton) {
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.date = dateLbl.text
        vc.maximumDate = Date()
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        present(vc, animated: false)
    }

    // MARK: - Date Selection
    func dateSelect(_ date: String?) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")

        var selectedDate = Date()
        if let dateStr = date, !dateStr.isEmpty {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "dd MMM yy"
            inputFormatter.locale = Locale(identifier: "en_US_POSIX")
            selectedDate = inputFormatter.date(from: dateStr) ?? Date()
        }

        let comparison = Calendar.current.compare(selectedDate, to: Date(), toGranularity: .day)
        todayLbl.text = (comparison == .orderedSame) ? "Today" :
                        (comparison == .orderedAscending) ? "Past Date" : "Future Date"
        dateLbl.text = outputFormatter.string(from: selectedDate)
    }

    // MARK: - API Calls
    func getAcademicYearList() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_recipient_get_academic_year_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<get_academic_yearSuc, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    guard res.status == true else { return }
                    self.AcadimicYearDatas = res.data ?? []
                    self.accadimYr = self.AcadimicYearDatas.compactMap { $0.year }

                    if let current = self.AcadimicYearDatas.first(where: { $0.current_academic_year == true }) {
                        self.acodemicId = current.id
                        self.acodomicYearLbl.text = current.year
                        self.getStandardsAPI()
                    }
                case .failure(let error):
                    print("Academic year fetch failed:", error.localizedDescription)
                }
            }
        }
    }

    func getStandardsAPI() {
        guard let academicId = acodemicId else { return }
        APIService.shared.makeApi(
            url: ServiceUrl.recipient_get_standards,
            parameters: ["academic_year_id": academicId],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<GetStandardsSuc, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    guard res.status == true else {
                        self.handleNoData(message: res.message ?? "No data")
                        self.searchBtn.isHidden = true
                        return
                    }

                    self.standardDetails = res.data
                    self.standerdList = res.data?.compactMap { $0.name } ?? []

                    if let first = res.data?.first {
                        self.sectionsDetails = first.sections
                        self.sectionList = first.sections?.compactMap { $0.name } ?? []
                        self.sectionId = first.sections?.first?.id
                        self.StandardLbl.text = first.name
                        self.SectionLbl.text = first.sections?.first?.name
                        self.GetHomeWorkReport(self.sectionId, self.dateLbl.text ?? "")
                    }

                    self.dropDownStack.isHidden = false
                    self.searchBar.isHidden = true
                    self.nodataFoundLbl.isHidden = true
                    self.noDataFound.isHidden = true
                case .failure(let err):
                    self.handleNoData(message: err.localizedDescription)
                }
            }
        }
    }

    func GetHomeWorkReport(_ sectionId: String?, _ date: String?) {
       let dateFormatted = ConvertDateStringSmart(date)

        if #available(iOS 15.0, *) {
            showActivityLoader()
        }

        APIService.shared.makeApi(
            url: ServiceUrl.comm_homework_get_homework_report,
            parameters: ["section_id": sectionId ?? "", "date": dateFormatted, "academic_year_id": acodemicId ?? 0],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<HomeworkResponse, Error>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self.hideActivityLoader()
                }

                switch result {
                case .success(let response):
                   
                    if response.status == true{
                        
                        self.FilterHomeWorkList = response.data
                        self.homeWorkList = response.data
                        self.nodataFoundLbl.isHidden = true
                        self.noDataFound.isHidden = true
                        self.designUseView.isHidden = true
                        self.Cv.isHidden = false
                        self.searchBtn.isHidden = false
                        self.Cv.delegate = self
                        self.Cv.dataSource = self
                        self.Cv.reloadData()
                        DispatchQueue.main.async {
                            self.cvHeight.constant = self.Cv.contentSize.height
                        }
                    }else{
                        self.designUseView.isHidden = false
                        self.nodataFoundLbl.isHidden = false
                        self.nodataFoundLbl.text = response.message ?? ""
                        self.noDataFound.isHidden = false
                        self.Cv.isHidden = true
                        self.cvHeight.constant = 0
                        self.searchBtn.isHidden = true
                    }
                case .failure(let error):
                    print("Homework API failed:", error.localizedDescription)
                    self.noDataFound.isHidden = false
                    self.designUseView.isHidden = false
                    self.cvHeight.constant = 0
                    self.searchBtn.isHidden = true
                }
            }
        }
    }

    private func handleNoData(message: String) {
        dropDownStack.isHidden = true
        searchBar.isHidden = true
        sectionId = ""
        nodataFoundLbl.text = message
        nodataFoundLbl.isHidden = false
        noDataFound.isHidden = false
        Cv.isHidden = true
//        cvHeight.constant = 0
    }
}

// MARK: - TableView
@available(iOS 14.0, *)
extension SenderHomeWorkVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FilterHomeWorkList?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeWorkCvCell", for: indexPath) as? HomeWorkCvCell else {
            return UICollectionViewCell()
        }
       
        cell.SubjectLbl.text = FilterHomeWorkList?[indexPath.row].subject_name
        cell.stafNamLbl.text = FilterHomeWorkList?[indexPath.row].sent_by
        cell.edit(edit: FilterHomeWorkList?[indexPath.row].can_edit ?? false, delete:  FilterHomeWorkList?[indexPath.row].can_delete ?? false, selectedId: FilterHomeWorkList?[indexPath.row].id ?? "")
        cell.threeDotBtn.isHidden = (
            (FilterHomeWorkList?[indexPath.row].can_edit) == false
        )
        cell.delegate = self
        cell.roundview.isHidden = true
        cell.homeWorkCompletImg.isHidden = true
//        cell.threeDotBtn.isHidden = false
            
            return cell
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
      
            return CGSize(width: 170, height: 230)
       
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        guard let attributes = collectionView.layoutAttributesForItem(at: indexPath) else { return }
        let cellFrameInSuperview = collectionView.convert(attributes.frame, to: view)
        
        let detailVC = PrivewVc()
        detailVC.attachmetList = FilterHomeWorkList?[indexPath.row].file_path
        detailVC.selectedDate  = dateLbl.text
        detailVC.titleString  = FilterHomeWorkList?[indexPath.row].title
        detailVC.descriptionString  = FilterHomeWorkList?[indexPath.row].description
//        detailVC.homeWorkid  = FilterHomeWorkList?[indexPath.row].id
        detailVC.postedBy  = FilterHomeWorkList?[indexPath.row].sent_by
        detailVC.subject_name  = FilterHomeWorkList?[indexPath.row].subject_name
        detailVC.modalPresentationStyle = .custom
        transitionDelegate.originFrame = cellFrameInSuperview
        detailVC.transitioningDelegate = transitionDelegate
        
        present(detailVC, animated: true)
        
    }
    }



// MARK: - Delegates
@available(iOS 14.0, *)
extension SenderHomeWorkVC:Datepicker, UISearchBarDelegate {


    func date(date: String) {
        dateSelect(date)
        GetHomeWorkReport(sectionId, date)
    }
    
    func HomeWork(withId eventId: String) -> Homework? {
        return homeWorkList?.first(where: { $0.id == eventId })
    }


    func homeWorkDelete(id: String?) {
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
                    url: ServiceUrl.comm_api_homework_delete,
                    parameters: ["id": noticeId],
                    type: ApitTypeSringFile.PUT,
                    token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
                ) { [weak self] (result: Result<ResetPasswordSuc, Error>) in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let successResponse):
                            if successResponse.status == true {
                                CustomAlert.showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: successResponse.message ?? "",
                                    on: self
                                ) {
                                    self.removeEvent(withId: noticeId)
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
    
    
    
    func removeEvent(withId eventId: String) {
        // Remove from filtered list
        FilterHomeWorkList = FilterHomeWorkList?.filter { $0.id != eventId }

        // Remove from original list
        homeWorkList = homeWorkList?.filter { $0.id != eventId }
        // Reload the UI
        if FilterHomeWorkList?.count == 0{
            self.noDataFound.isHidden = false
            self.cvHeight.constant = 0
        }
        Cv.reloadData()
    }

    

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            FilterHomeWorkList = homeWorkList
        } else {
            let lower = searchText.lowercased()
            FilterHomeWorkList = homeWorkList?.filter {
                $0.subject_name?.lowercased().contains(lower) == true ||
                $0.title?.lowercased().contains(lower) == true ||
                $0.description?.lowercased().contains(lower) == true
            }
        }
        let isListEmpty = FilterHomeWorkList?.isEmpty ?? true
        noDataFound.isHidden = !isListEmpty
        nodataFoundLbl.isHidden = !isListEmpty
        nodataFoundLbl.text = CommonStringFile.No_data_found
        Cv.reloadData()
    }
}
extension UIView{
    func cornerRadius(_ radius: CGFloat = 8) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
