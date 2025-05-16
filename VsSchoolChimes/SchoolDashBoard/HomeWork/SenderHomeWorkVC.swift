//
//  SenderHomeWorkVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 16/04/25.
//

import UIKit
import DropDown

@available(iOS 14.0, *)
class SenderHomeWorkVC: UIViewController,UITableViewDelegate,UITableViewDataSource, SelectNotice, Datepicker, UISearchBarDelegate {
    func date(date: String) {
        dateSelect(date)
        GetHomeWorkReport(sectionId, dateLbl.text ?? "")
    }
    
    func didTapButton(title: String, content: String, items: [FilePath]) {
        
        selectNotice?.didTapButton(title: title, content: content, items: items)
    }
    
    @IBOutlet weak var noDataFound: UIImageView!
    @IBOutlet weak var nodataFoundLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    @IBOutlet weak var SectionLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var homeWorkTable: UITableView!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var standerdView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var acodomicYearLbl: UILabel!
    
    @IBOutlet weak var dropDownStack: UIStackView!
    @IBOutlet weak var todayLbl: UILabel!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var acodemicView: UIView!
    @IBOutlet weak var acodemicdropView: UIView!
    
    var selectedImages: [UIImage] = []
    var selectedImgUrl: [FilePath] = []
    var url : URL?
    let photoPickManager = PhotoPickerManager.shared
    let Img = ImageName()
    let formatter = DateFormatter()
    let standardDropdown = DropDown()
    let SectionDropdown = DropDown()
    let acidamicdrops = DropDown()
    var image = "image/pdf"
    var delegate : HistorySelectDelegate?
    let customdate = DateFormatter()
    let initialHeight: CGFloat = 60
    let maxHeight: CGFloat = 300
    var homeWorkList:[Homework]?
    var FilterHomeWorkList:[Homework]?
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let  staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    var sectionsDetails: [sectionsDetail]?
    var standardDetails: [StandardDetail]?
    var sectionList = [String]()
    var standerdList = [String]()
    var AcadimicYearDatas : [AcadimicYearData] = []
    var accadimYr :[String] = []
    var acodemicId:Int?
    var sectionId:String?
    var selectNotice : SelectNotice?
    override func viewDidLoad() {
        super.viewDidLoad()
        applyShadowAndCornerRadius(to: dateView)
        applyShadowAndCornerRadius(to: acodemicView)
        applyShadowAndCornerRadius(to: standerdView)
        applyShadowAndCornerRadius(to: sectionView)
        searchBar.addDoneButton()
        dateView.layer.borderColor = UIColor.lightGray.cgColor
        dateView.layer.borderWidth = 0.5
        
        acodemicView.layer.borderColor = UIColor.lightGray.cgColor
        acodemicView.layer.borderWidth = 0.5
        
        standerdView.layer.borderColor = UIColor.lightGray.cgColor
        standerdView.layer.borderWidth = 0.5
        
        sectionView.layer.borderColor = UIColor.lightGray.cgColor
        sectionView.layer.borderWidth = 0.5
        
        getacadmicYr()
        getStandardsAPI()
        //        acodemicView.cornerRadius()
        //        standerdView.cornerRadius()
        //        sectionView.cornerRadius()
        let imgPdfTV = UINib(nibName:CellConfingName.HomeWorkTVC, bundle: nil)
        homeWorkTable.register(imgPdfTV, forCellReuseIdentifier: CellConfingName.HomeWorkTVC)
        dateSelect(nil)
        searchBar.delegate = self
        searchBar.placeholder = CommonStringFile.Search.translated()
        dateLbl.setFont(style: .title, size: FontSize.TitleSize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        SectionLbl.setFont(style: .body, size: FontSize.BodySize)
        
    }
    func dateSelect(_ date: String?) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEE d MMM yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        var selectedDate = Date()
        if let dateStr = date, !dateStr.isEmpty {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "dd MMM yy"
            inputFormatter.locale = Locale(identifier: "en_US_POSIX")
            if let parsedDate = inputFormatter.date(from: dateStr) {
                selectedDate = parsedDate
            }
        }
        
        // ✅ Compare selected date with today
        let today = Date()
        let comparison = Calendar.current.compare(selectedDate, to: today, toGranularity: .day)
        
        switch comparison {
        case .orderedSame:
            todayLbl.text = "Today"
        case .orderedAscending:
            todayLbl.text = "Past Date"
        case .orderedDescending:
            todayLbl.text = "Future Date"
        default:
            todayLbl.text = "Selected Date"
        }
        let formattedDate = outputFormatter.string(from: selectedDate)
        dateLbl.text = formattedDate
    }

    
    
    func getacadmicYr(){
        APIService.shared
            .makeApi(url: ServiceUrl.comm_recipient_get_academic_year_list , parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""){ [self] (
                result:Result <get_academic_yearSuc,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            AcadimicYearDatas = successMessage.data ?? []
                            for i in 0..<(AcadimicYearDatas.count){
                                if AcadimicYearDatas[i].current_academic_year ?? false == true{
                                    acodomicYearLbl.text = AcadimicYearDatas[i].year
                                    acodemicId = AcadimicYearDatas[i].id
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
    }
    
    
    @IBAction func selectAcodemic(_ sender: UIButton) {
        accadimYr.removeAll()
        for i in 0..<(AcadimicYearDatas.count) {
            accadimYr.append(AcadimicYearDatas[i].year ?? "")
        }
        acidamicdrops.anchorView = acodemicdropView
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acodemicdropView.bounds.height)
        acidamicdrops.show()
        
        acidamicdrops.selectionAction = { [self] (index: Int, item: String) in
            acodomicYearLbl.text = item
            acodemicId = AcadimicYearDatas[index].id
            getStandardsAPI()
        }
    }
    
    @IBAction func selectSection(_ sender: UIButton) {
        if !dropDownStack.isHidden{
            SectionDropdown.anchorView = sectionView
            SectionDropdown.dataSource = sectionList
            SectionDropdown.show()
            SectionDropdown.bottomOffset = CGPoint(x: 0, y: sectionView.bounds.height)
            standardDropdown.direction = .bottom
            SectionDropdown.selectionAction = { [self] (index: Int, item: String) in
                
                if index < sectionsDetails?.count ?? 0{
                    sectionId = sectionsDetails?[index].id
                    GetHomeWorkReport(sectionsDetails?[index].id, dateLbl.text ?? "")
                }
                if let label = sectionView.subviews.first(where: { $0 is UILabel }) as? UILabel {
                    label.text = item
                }
                homeWorkTable.isHidden = false
                homeWorkTable.reloadData()
            }
        }
    }
    @IBAction func selectDate(_ sender: UIButton) {
        
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.date = dateLbl.text
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func selectStanderd(_ sender: UIButton) {
        // Setup dropdown anchor and data source
        if !dropDownStack.isHidden{
            standardDropdown.anchorView = standerdView
            standardDropdown.dataSource = standerdList
            standardDropdown.bottomOffset = CGPoint(x: 0, y: standerdView.bounds.height)
            standardDropdown.direction = .bottom
            standardDropdown.show()
            
            standardDropdown.selectionAction = { [weak self] (index: Int, item: String) in
                guard let self = self else { return }
                guard let selectedSections = standardDetails?[index].sections else { return }
                sectionsDetails = selectedSections
                sectionList.removeAll()
                sectionId = selectedSections.first?.id
                apiCall()
                sectionList.append(contentsOf: selectedSections.compactMap { $0.name })
                SectionLbl.text = selectedSections.first?.name ?? ""
                if let label = self.standerdView.subviews.compactMap({ $0 as? UILabel }).first {
                    label.text = item
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilterHomeWorkList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = homeWorkTable.dequeueReusableCell(withIdentifier: CellConfingName.HomeWorkTVC, for: indexPath) as! HomeWorkTVC
//        cell.ishomework = true
        cell.CvHeight.constant = 0
        cell.ImageCollectionView.isHidden = true
        cell.delegate = self
        let data = FilterHomeWorkList?[indexPath.row]
        cell.subjectName.text = data?.subject_name
        cell.topics.text = data?.title ?? ""
        cell.dateLble.text = dateLbl.text ?? ""
        cell.ImageCollectionView.isHidden = (data?.file_path?.isEmpty ?? true)
        if let urls = data?.file_path, urls.count != 0{
            cell.ImageCollectionView.isHidden = false
            cell.CvHeight.constant = 150
            cell.loadImage(urls: urls)
        }
        
        cell.FilterHomeWorkList = data
        cell.newView.isHidden = true
        cell.descriptionLbl.setupExpandable(text: data?.description ?? "")
        cell.descriptionLbl.onExpandableTap = {
            cell.descriptionLbl.isExpanded.toggle()
            tableView.beginUpdates()
            tableView.endUpdates()
            DispatchQueue.main.async {
                   let contentHeight = tableView.contentSize.height
                   self.tableviewHeight.constant = contentHeight
               }
        }
        cell.cellview.layoutIfNeeded()
        DispatchQueue.main.async {
            let contentHeight = self.homeWorkTable.contentSize.height
            self.tableviewHeight.constant = contentHeight
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func apiCall() {
        guard let labelText = dateLbl?.text, !labelText.isEmpty,
              let sectionId = sectionId, !sectionId.isEmpty else {
            print("Missing sectionId or dateLbl")
            return
        }
        GetHomeWorkReport(sectionId, labelText)
    }


    func GetHomeWorkReport(_ sectionId: String?, _ dates: String?) {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        
        let date = ConvertDateStringSmart(dates)
        APIService.shared.makeApi(
            url: ServiceUrl.comm_homework_get_homework_report,
            parameters: ["section_id": sectionId ?? "", "date": date],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<HomeworkResponse, Error>) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self.hideLottieProgressLoader()
                }
                
                switch result {
                case .success(let successMessage):
                    
                    if successMessage.status == true{
                        self.tableviewHeight.constant = 100
                        self.nodataFoundLbl.isHidden = true
                        self.homeWorkList = successMessage.data
                        self.FilterHomeWorkList = successMessage.data
                        self.homeWorkTable.reloadData()
                        self.noDataFound.isHidden = true
                    }else{
                        self.nodataFoundLbl.isHidden = false
                        self.noDataFound.isHidden = false
                        self.nodataFoundLbl.text = successMessage.message
                        self.FilterHomeWorkList = successMessage.data
                        self.homeWorkTable.reloadData()
                        self.tableviewHeight.constant = 0
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    self.tableviewHeight.constant = 0
                    self.noDataFound.isHidden = false
                }
            }
        }
    }
    
    
    
    func getStandardsAPI(){
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: ["academic_year_id":"\(acodemicId ?? 6)"], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "") { [self] (result:Result <GetStandardsSuc,Error>) in
            switch result {
            case .success(let successMessage):
                print("successsuccess",successMessage.data)
                DispatchQueue.main.async { [self] in
                    if successMessage.status == true{
                        
                        standardDetails = successMessage.data
                        standardDetails?.enumerated().forEach { index, student in
                            standerdList.append(student.name ?? "")
                        }
                        
                        if let sections = standardDetails?.first?.sections{
                            sectionsDetails = sections
                            for j in 0..<sections.count {
                                sectionList.append(sectionsDetails?[j].name ?? "")
                            }
                        }
                    sectionId = standardDetails?.first?.sections?.first?.id
                        GetHomeWorkReport(standardDetails?.first?.sections?.first?.id, dateLbl.text ?? "")
                        StandardLbl.text = standardDetails?.first?.name
                        SectionLbl.text = standardDetails?.first?.sections?.first?.name ?? ""
                        dropDownStack.isHidden = false
                        searchBar.isHidden = true
                    }else{
                        dropDownStack.isHidden = true
                        sectionId = ""
                        searchBar.isHidden = true
                        self.nodataFoundLbl.isHidden = false
                        self.noDataFound.isHidden = false
                        self.nodataFoundLbl.text = successMessage.message
                        self.tableviewHeight.constant = 0
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    print(error.localizedDescription)
                    dropDownStack.isHidden = true
                    searchBar.isHidden = true
                    self.nodataFoundLbl.isHidden = false
                    self.noDataFound.isHidden = false
                    self.nodataFoundLbl.text = error.localizedDescription
                    self.tableviewHeight.constant = 0
                    sectionId = ""
                }
            }
        }
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            FilterHomeWorkList = homeWorkList
        } else {
            FilterHomeWorkList = homeWorkList?.filter { item in
                let lowercasedSearchText = searchText.lowercased()
                return item.subject_name?.lowercased().contains(lowercasedSearchText) == true ||
                item.title?.lowercased().contains(lowercasedSearchText) == true ||
                item.description?.lowercased().contains(lowercasedSearchText) == true
            }
        }
        homeWorkTable.reloadData()
    }
    
}
extension UIView{
    func cornerRadius(_ radius: CGFloat = 8) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
