//
//  ReciverHomeworkVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 20/12/24.
//

import UIKit

@available(iOS 14.0, *)
class ReciverHomeworkVC: UIViewController, SelectNotice {
    
    func didTapButton(title: String, content: String, items: [FilePath]) {
        delegate?.select(Title: title, Description: content, Images: [], pdf: "")
    }
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var TV: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var HeaderLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    var expandedSections: Set<Int> = [] // Tracks expanded sections
    var delegate : HistorySelectDelegate?
    var homeWorkList:[HomeworkList]?
    var FilterHomeWorkList:[HomeworkList]?
    var playIndex : Int = 0
    var shouldShowFooter = true
    var studentDetails = UserDefaultFileManager.get_child_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        NameLbl.text = studentDetails?.name
        StandardLbl.text = "\(studentDetails?.standard_name ?? "") :\(studentDetails?.section_name ?? "")"
        GetHomeWorkReport()
        StyleAndTranslate()
        searchBar.addDoneButton()
        backBtn.applyBackButton()
        searchBar.applyRightTxt()
        RegisterCell()
        setupTableFooter()
        TV.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        TV.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        TV.delegate = self
        TV.dataSource = self
        
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    func StyleAndTranslate(){
        //MARK: UI Changes
        
        //FontStyle
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        
        //Translation
        backBtn.setTitle(MenuStringFile.Homework.translated(), for: .normal)
        searchBar.placeholder = CommonStringFile.Search.translated()
    }
    
    //MARK: Cell Registration
    func RegisterCell(){
        let nib = UINib(nibName: CellConfingName.HomeWorkTVC, bundle: nil)
        TV.register(nib, forCellReuseIdentifier: CellConfingName.HomeWorkTVC)
        
        let nib1 = UINib(nibName: CellConfingName.HomeworkreportTV, bundle: nil)
        TV.register(nib1, forCellReuseIdentifier: CellConfingName.HomeworkreportTV)
        
        let head = UINib(nibName: CellConfingName.ReciverHomeworkHeader, bundle: nil)
        TV.register(head, forHeaderFooterViewReuseIdentifier: CellConfingName.ReciverHomeworkHeader)
    }
    
    @IBAction func BackBtnAct(_ sender: Any) {
        dismiss(animated: true)
    }
    func GetHomeWorkReport() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        APIService.shared.makeApi(
            url: ServiceUrl.comm_homework_get_homework_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: studentDetails?.access_token ?? ""
        ) { [self] (result: Result<HomeworListkResponse, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self.hideLottieProgressLoader()
                }
                
                switch result {
                case .success(let successMessage):
                    self.homeWorkList = successMessage.data
                    self.FilterHomeWorkList = successMessage.data
                    self.TV.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    func GetHomeWorkArchive() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        APIService.shared.makeApi(
            url: ServiceUrl.comm_homework_get_homework_list_archive,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token:studentDetails?.access_token ?? "") { [self] (result: Result<HomeworListkResponse, Error>) in
                DispatchQueue.main.async {
                    if #available(iOS 15.0, *) {
                        self.hideLottieProgressLoader()
                    }
                    
                    switch result {
                    case .success(let successMessage):
                        self.homeWorkList?.append(contentsOf:successMessage.data ?? [])
                        self.FilterHomeWorkList?.append(contentsOf:successMessage.data ?? [])
                        self.TV.reloadData()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
    }
}

//MARK: Tableview Functions
@available(iOS 14.0, *)
extension ReciverHomeworkVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return FilterHomeWorkList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellConfingName.ReciverHomeworkHeader) as! ReciverHomeworkHeader
        cell.HeaderLbl.text = FilterHomeWorkList?[section].date
        cell.HeaderLbl.setFont(style: .header, size: FontSize.HeaderSize)
        cell.HeaderView.layer.cornerRadius = 10
        cell.HeaderView.layer.borderWidth = 1
        cell.HeaderView.layer.borderColor = UIColor.lightGray.cgColor
        
        cell.HeaderView.layer.shadowColor = UIColor.black.cgColor
        cell.HeaderView.layer.shadowOpacity = 0.2 // Adjust the opacity of the shadow
        cell.HeaderView.layer.shadowOffset = CGSize(width: 0, height: 5) // Position of the shadow
        cell.HeaderView.layer.shadowRadius = 5 // Blur effect of the shadow
        
        // Add tap gesture to header
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSection(_:)))
        cell.tag = section
        cell.addGestureRecognizer(tapGesture)
        
        
        if expandedSections.contains(section){
            cell.ArrowImgview.image = UIImage(named: "arrow_up")
            
        }else{
            cell.ArrowImgview.image = UIImage(named: "arrow_down")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSections.contains(section) ? (FilterHomeWorkList?[section].homework?.count ?? 0) : 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.HomeWorkTVC, for: indexPath) as? HomeWorkTVC,
              let sectionData = FilterHomeWorkList?[indexPath.section],
              let homework = sectionData.homework?[indexPath.row] else {
            return UITableViewCell()
        }
        
        if homework.file_path?.count ?? 0 == 0 {
            cell.CvHeight.constant = 0
        }else{
            cell.CvHeight.constant = 120
        }
        // Configure cell data
        cell.subjectName.text = homework.subject_name
        cell.topics.text = homework.title ?? ""
        cell.dateLble.text = sectionData.date
        cell.forwordBtn.isHidden = true
        cell.SelectBtnHeight.constant = 0
        
        // Load image if available
        if let urls = homework.file_path {
            cell.loadImage(urls: urls)
        }
        let contentText = homework.description ?? ""
        cell.descriptionLbl.setupExpandable(text: contentText)
        cell.newView.isHidden = contentText.count <= 100
        cell.descriptionLbl.onExpandableTap = { [weak tableView] in
            cell.descriptionLbl.isExpanded.toggle()
            cell.newView.isHidden = true
            tableView?.beginUpdates()
            tableView?.endUpdates()
        }
        
        cell.cellview.layoutIfNeeded()
        return cell
    }
    
    
    @objc func toggleSection(_ sender: UITapGestureRecognizer) {
        guard let headerView = sender.view else { return }
        let section = headerView.tag
        
        var sectionsToReload = IndexSet()
        
        if expandedSections.contains(section) {
            expandedSections.remove(section)
            sectionsToReload.insert(section)
        } else {
            if let previousSection = expandedSections.first {
                expandedSections.remove(previousSection)
                sectionsToReload.insert(previousSection)
            }
            
            expandedSections.insert(section)
            sectionsToReload.insert(section)
        }
        
        TV.reloadSections(sectionsToReload, with: .automatic)
    }
    
    
    // Method to load the footer from nib and set it as tableFooterView
    func setupTableFooter() {
        if shouldShowFooter {
            if let footer = Bundle.main.loadNibNamed("SeeMoreFooterView", owner: self, options: nil)?.first as? SeeMoreFooterView {
                footer.frame = CGRect(x: 0, y: 0, width: TV.frame.width, height: 60)
                let seeMoreTap = UITapGestureRecognizer(target: self, action: #selector(seeMoreAction))
                footer.SeeMoreBtn.addGestureRecognizer(seeMoreTap)
                footer.SeeMoreBtn.isUserInteractionEnabled = true
                TV.tableFooterView = footer
            }
        } else {
            TV.tableFooterView = nil
        }
    }
    
    @objc func seeMoreAction() {
        print("Footer button tapped. Hiding the footer.")
        
        // Animate the footer fade-out if desired.
        if let footer = TV.tableFooterView {
            UIView.animate(withDuration: 0.3, animations: {
                footer.alpha = 0
            }, completion: {[self] _ in
                // Hide the footer after animation completes.
                TV.tableFooterView = nil
                shouldShowFooter = false
                GetHomeWorkArchive()
            })
        } else {
            // In case footer is already nil.
            shouldShowFooter = false
        }
    }
}

//MARK: Searchbar delegate
@available(iOS 14.0, *)
extension ReciverHomeworkVC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    //    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    //        if searchText.isEmpty {
    //            FilterHomeWorkList = homeWorkList
    //        } else {
    //            FilterHomeWorkList = homeWorkList?.compactMap { homeworkDate in
    //                let filteredHomeworks = homeworkDate.homework?.filter {
    //                    ($0.topic?.localizedCaseInsensitiveContains(searchText) ?? false) ||
    //                    ($0.subject_name?.localizedCaseInsensitiveContains(searchText) ?? false)
    //                }
    //            }
    //        }
    //        TV.reloadData()
    //    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            FilterHomeWorkList = homeWorkList
            expandedSections.removeAll()
        } else {
            let lowercasedSearch = searchText.lowercased()
            
            FilterHomeWorkList = homeWorkList?.compactMap { hwList in
                guard let homeworkItems = hwList.homework else { return nil }
                
                let filteredHomework = homeworkItems.filter { hw in
                    hw.subject_name?.lowercased().contains(lowercasedSearch) == true ||
                    hw.title?.lowercased().contains(lowercasedSearch) == true ||
                    hw.description?.lowercased().contains(lowercasedSearch) == true
                }
                
                return filteredHomework.isEmpty ? nil : HomeworkList(date: hwList.date, homework: filteredHomework)
            }
            
            expandedSections = Set(0..<(FilterHomeWorkList?.count ?? 0))
        }
        
        TV.reloadData()
        
    }
    
}
