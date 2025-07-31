

//
//  SenderHomeWorkVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 16/04/25.
//

import UIKit
import DropDown

@available(iOS 14.0, *)
class SenderHomeWorkVC: UIViewController {

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
    @IBOutlet weak var acodemicView: UIView!
    @IBOutlet weak var acodemicdropView: UIView!

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
    var selectNotice: SelectNotice?
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    let staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        HomeWorkCvCell
        setupViews()
        registerCVCells()
        getAcademicYearList()
        searchBar.delegate = self
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // clear caches or large objects
    }

    // MARK: - Setup
    private func setupViews() {
//        applyShadowAndCornerRadius(to: dateView)
        applyShadowAndCornerRadius(to: acodemicView)
        applyShadowAndCornerRadius(to: standerdView)
        applyShadowAndCornerRadius(to: sectionView)
        searchBar.addDoneButton()
//        dateView.layer.borderColor = UIColor.lightGray.cgColor
//        dateView.layer.borderWidth = 0.5
        
        acodemicView.layer.borderColor = UIColor.lightGray.cgColor
        acodemicView.layer.borderWidth = 0.5
        
        standerdView.layer.borderColor = UIColor.lightGray.cgColor
        standerdView.layer.borderWidth = 0.5
        
        sectionView.layer.borderColor = UIColor.lightGray.cgColor
        sectionView.layer.borderWidth = 0.5

        searchBar.addDoneButton()
        searchBar.placeholder = CommonStringFile.Search.translated()
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

            self.sectionsDetails = selectedSections
            self.sectionList = selectedSections.compactMap { $0.name }
            self.sectionId = selectedSections.first?.id
            self.StandardLbl.text = item
            self.SectionLbl.text = selectedSections.first?.name ?? ""
            DispatchQueue.main.async {
                self.Cv.layoutIfNeeded()
                self.cvHeight.constant = 300
            }
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

            self.sectionId = self.sectionsDetails?[index].id
            self.SectionLbl.text = item
            DispatchQueue.main.async {
                self.Cv.layoutIfNeeded()
                self.cvHeight.constant = 300
            }
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
            showLottieProgressLoader(animationName: "loader (2)")
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
                    self.hideLottieProgressLoader()
                }

                switch result {
                case .success(let response):
                    self.FilterHomeWorkList = response.data
                    self.homeWorkList = response.data
                    self.nodataFoundLbl.isHidden = response.status ?? false
                    self.noDataFound.isHidden = response.status ?? false
                    self.nodataFoundLbl.text = response.message
                    self.Cv.reloadData()
                    DispatchQueue.main.async {
                        self.Cv.layoutIfNeeded()
                        self.cvHeight.constant = self.Cv.contentSize.height
                    }

                case .failure(let error):
                    print("Homework API failed:", error.localizedDescription)
                    self.noDataFound.isHidden = false
                    self.cvHeight.constant = 0
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
        cvHeight.constant = 0
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
        
        
        
        
       
            
        cell.roundview.isHidden = true
        cell.homeWorkCompletImg.isHidden = false
        cell.homeWorkCompletImg.image = UIImage(named: "three-dot")
            cell.pieChartWidth.constant = 0
            cell.PieChartTrailling.constant = -10
            cell.pieChart.isHidden = true
        

            return cell
        }
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if (FilterHomeWorkList?.count ?? 0) - 1 == indexPath.row{
//            let contentHeight = self.Cv.contentSize.height
//            self.cvHeight.constant = contentHeight
//        }
//        
//        return UITableView.automaticDimension
//    }


// MARK: - Delegates
@available(iOS 14.0, *)
extension SenderHomeWorkVC: SelectNotice, Datepicker, UISearchBarDelegate {
    func date(date: String) {
        dateSelect(date)
        GetHomeWorkReport(sectionId, date)
    }

    func didTapButton(title: String, content: String, items: [FilePath]) {
        selectNotice?.didTapButton(title: title, content: content, items: items)
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
        Cv.reloadData()
    }
}
extension UIView{
    func cornerRadius(_ radius: CGFloat = 8) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
