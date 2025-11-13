//
//  homeWorkVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 21/07/25.
//

import UIKit

class homeWorkVc: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, readStatusUpdate {
    func ReadCompleted(Id: String, IscompletedStatus: Bool) {
        markHomeworkAsUnread(eventId: Id, isCompletedStatus: IscompletedStatus)
    }
  
    func markHomeworkAsUnread(eventId: String,isCompletedStatus: Bool) {
        if let index = FilterHomeWorkList.firstIndex(where: { $0.id == eventId }) {
            var updatedHomework = FilterHomeWorkList[index]
            updatedHomework.is_unread = false
            updatedHomework.is_completed = isCompletedStatus
            FilterHomeWorkList[index] = updatedHomework
            if user_inputs.clearTempData(){
                let parms = [ "mobile_number": UserDefaultFileManager.get_staff_Details()?.mobile_no ?? "",
                              "activity": "HOMEWORK",
                              "user_type": 1,
                              "menu_id": Menu_id.staffSelectedMenuId] as [String : Any]
                paketApiCall(params:parms)
            }
            bottomCV.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == bottomCV{
            return FilterHomeWorkList.count
        }else{
            return calendarItems.count
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == bottomCV{
            
            guard let attributes = collectionView.layoutAttributesForItem(at: indexPath) else { return }
            let cellFrameInSuperview = collectionView.convert(attributes.frame, to: view)
            
            let detailVC = PrivewVc()
            detailVC.attachmetList = FilterHomeWorkList[indexPath.row].file_path
            detailVC.isCompleted = FilterHomeWorkList[indexPath.row].is_completed ?? false
            detailVC.selectedDate  = selectedDate
            detailVC.is_unreadStatus = FilterHomeWorkList[indexPath.row].is_unread
            detailVC.titleString  = FilterHomeWorkList[indexPath.row].title
            detailVC.descriptionString  = FilterHomeWorkList[indexPath.row].description
            detailVC.homeWorkdetail_id  = FilterHomeWorkList[indexPath.row].detail_id
            detailVC.homeWorkid  = FilterHomeWorkList[indexPath.row].id
            detailVC.postedBy  = FilterHomeWorkList[indexPath.row].sent_by
            detailVC.subject_name  = FilterHomeWorkList[indexPath.row].subject_name
            detailVC.delegate = self
            detailVC.modalPresentationStyle = .fullScreen
            detailVC.modalPresentationStyle = .custom
            transitionDelegate.originFrame = cellFrameInSuperview
            detailVC.transitioningDelegate = transitionDelegate
            present(detailVC, animated: true)
            
        }else{
            
            scrollToCenter(of: indexPath, in: collectionView)
            
            if selectedIndexPath == indexPath {
                return // do nothing if already selected
            }
            selectedIndexPath = indexPath
            let selectedDate = convertDateToString(calendarItems[indexPath.item].date)
            updateHomeworkUI(for: selectedDate)
            self.cv.reloadData()
        }
    }
    
    func updateHomeworkUI(for date: String) {
        self.selectedDate = date
        self.FilterHomeWorkList = self.filterHomeworkGroupByDate(from: self.allHomeworkData, date: date)
        
        let isEmpty = self.FilterHomeWorkList.isEmpty
        self.NodataFoundLbl.isHidden = !isEmpty
        self.noDataImage.isHidden = !isEmpty
        self.homeWorkDefaultLbl.isHidden = isEmpty
        self.searchBtnName.isHidden = isEmpty
        self.searchbar.searchTextField.text = ""
        view.endEditing(true)
        if searchBtnName.isSelected && searchBtnName.isHidden == false {
            self.searchbar.isHidden = false
        }else {
            self.searchbar.isHidden = true
        }
        
        self.bottomCV.reloadData()
    }

    
    func convertDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateInputs.dd_MM_yyyy// Match API format!
        formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return formatter.string(from: date)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == bottomCV{
            let item = FilterHomeWorkList[indexPath.item]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.HomeWorkCvCell, for: indexPath) as? HomeWorkCvCell else {
                return UICollectionViewCell()
            }
            
            cell.SubjectLbl.text = item.subject_name
            cell.stafNamLbl.text = item.description//item.sent_by
            
            if item.is_unread == false{
                cell.roundview.isHidden = true
                cell.newImage.isHidden = true
                cell.homeWorkCompletImg.isHidden = false
            }else{
                cell.roundview.isHidden = true
                cell.newImage.isHidden = false
                cell.homeWorkCompletImg.isHidden = true
                cell.homeWorkCompletImg.image = UIImage(named: "Pending")
                //cell.homeWorkCompletImg.preferredSymbolConfiguration?() = .
            }
            
            if item.is_completed == true{
                cell.newImage.isHidden = true
                cell.homeWorkCompletImg.isHidden = false
                cell.homeWorkCompletImg.image = UIImage(named: "complete_homework")
            }
            
            
            return cell
        }else{
            let item = calendarItems[indexPath.item]
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.CalanderCvCell, for: indexPath) as? CalanderCvCell else {
                return UICollectionViewCell()
            }
            
            let isToday = Calendar.current.isDateInToday(item.date)
            let isFuture = item.date > today
            
            cell.configure(
                with: item,
                isToday: isToday,
                isSelected: indexPath == selectedIndexPath,
                hasHomework: item.hasHomework,
                isFuture: item.date > today
            )
            
            if indexPath == selectedIndexPath {
                cell.contentView.backgroundColor = .white
                cell.contentView.layer.cornerRadius = 10
                cell.dotView.backgroundColor = UIColor.homeWorkClr
                cell.dayLabel.textColor = .black
                cell.dateLabel.textColor = .black
                cell.monthLabel.textColor = .black
            } else {
                cell.contentView.backgroundColor = .clear
                cell.dotView.backgroundColor = UIColor.white
                cell.dayLabel.textColor = .white
                cell.dateLabel.textColor = .white
                cell.monthLabel.textColor = .white
            }
            return cell
            
        }
    }
    
    // MARK: - CollectionView Delegate FlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == bottomCV{
            return CGSize(width: 170, height: 230)
        }else{
            return CGSize(width: 70, height: 100)
        }
    }
    
    @IBOutlet weak var backBtnName: UIButton!
    @IBOutlet weak var NodataFoundLbl: UILabel!
    @IBOutlet weak var homeWorkDefaultLbl: UILabel!
    @IBOutlet weak var searchBtnName: UIButton!
    @IBOutlet weak var noDataImage: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var bottomCV: UICollectionView!
    @IBOutlet weak var studentNameLbl: UILabel!
    
    var calendarItems: [CalendarItem] = []
    let transitionDelegate = TransitioningDelegate()
    var homeWorkListd: [HomeworkList]?
    var FilterHomeWorkList: [Homework] = []
    var HomeWorkList: [Homework] = []
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var selectedIndexPath: IndexPath?
    let today = Date()
    var selectedDate  : String?
    var allHomeworkData: [HomeworkList] = []
    var isReadStatus : Bool?
    var toggle = true
    var clickedMessageId : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UiUpdate()
        
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
        }
        
        calendarItems = getAllPastDatesIncludingTodayForLastMonth()
        cv
            .register(
                UINib(nibName: CellConfingName.CalanderCvCell, bundle: nil),
                forCellWithReuseIdentifier: CellConfingName.CalanderCvCell
            )
        bottomCV.register(UINib(nibName: CellConfingName.HomeWorkCvCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.HomeWorkCvCell)
        cv.delegate = self
        cv.dataSource = self
        
        if let todayIndex = calendarItems.firstIndex(where: { Calendar.current.isDateInToday($0.date) }) {
            selectedIndexPath = IndexPath(item: todayIndex, section: 0)
        }
        cv.reloadData()
        
        scrollToToday(in: cv, with: calendarItems)
        GetHomeWorkReport()
        
    }
    
    func UiUpdate(){
        
        // Do any additional setup after loading the view.
        
        let Name = studentDetails?.name ?? ""
        let Standard = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        studentNameLbl.configureAsBackTitle(firstLine: Name, secondLine: Standard)
        homeWorkDefaultLbl.text = MenuStringFile.selectedMenuName
        searchbar.isHidden = true
        searchbar.delegate = self
        searchbar.searchTextField.addDoneButton()
        searchbar.placeholder = CommonStringFile.Search
        searchbar.backgroundImage = UIImage()
        topView.layer.cornerRadius = 30
        topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        topView.layer.masksToBounds = true
        
    }
    
    @IBAction func searchBtn(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        searchbar.isHidden = !sender.isSelected
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        searchBtnName.setImage(UIImage(systemName: icon), for: .normal)
        if sender.isSelected {
            searchbar.becomeFirstResponder()
        }else{
            searchbar.searchTextField.text = ""
            NodataFoundLbl.isHidden = true
            noDataImage.isHidden = true
            searchbar.resignFirstResponder()
            self.FilterHomeWorkList = self.filterHomeworkGroupByDate(
                from: self.allHomeworkData,
                date: self.selectedDate ?? ""
            )
            bottomCV.reloadData()
            view.endEditing(true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    
    func getAllPastDatesIncludingTodayForLastMonth() -> [CalendarItem] {
        var items: [CalendarItem] = []
        let calendar = Calendar.current
        let today = Date()
        
        // Start from 1 month ago
        guard let pastStartDate = calendar.date(byAdding: .month, value: -1, to: today) else {
            return items
        }
        
        var currentDate = pastStartDate
        while currentDate <= today {
            items.append(CalendarItem(date: currentDate))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        return items
    }

    
    
    func GetHomeWorkReport() {
        
        FilterHomeWorkList.removeAll()
        if #available(iOS 15.0, *) { showActivityLoader() }
       
        APIService.shared.makeApi(
            url: ServiceUrl.comm_homework_get_homework_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<HomeworListkResponse, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {  self?.hideActivityLoader() }
                
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.allHomeworkData = response.data ?? []
                    let today = self.getCurrentDateString()
                    let filteredHomework = self.filterHomeworkGroupByDate(
                        from: self.allHomeworkData,
                        date: today
                    )
                    self.selectedDate = today
                    self.FilterHomeWorkList = filteredHomework
                    self.bottomCV.delegate  = self
                    self.bottomCV.dataSource  = self
                    self.bottomCV.reloadData()
                    
                    DispatchQueue.main.async {
                        if self.clickedMessageId != "" {
                            if let index = self.FilterHomeWorkList.firstIndex(
                                where: { $0.id == self.clickedMessageId
                                }) {
                                let indexPath = IndexPath(item: index, section: 0)
                                self.bottomCV.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                            }
                            
                        }
                    }
                    let isEmpty = filteredHomework.isEmpty
                  
                    self.NodataFoundLbl.isHidden = !isEmpty
                    
                    self.noDataImage.isHidden = !isEmpty
                    //                    self.searchbar.isHidden = isEmpty
                    self.homeWorkDefaultLbl.isHidden = isEmpty
                    self.searchBtnName.isHidden = isEmpty
                    
                    
                    
                case .failure(let error):
                    
                    self.noDataImage.isHidden = false
                    self.searchbar.isHidden = true
                    self.searchBtnName.isHidden = true
                    
                    
                }
            }
        }
    }
    func paketApiCall(params:[String:Any]){
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_pauket_add_points,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {

                guard let self = self else { return }

                switch result {
                case .success(let response):
                    if let window = UIApplication.shared.windows.first {
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
    func scrollToToday(in collectionView: UICollectionView, with items: [CalendarItem]) {
        let calendar = Calendar.current
        let today = Date()
        
        if let todayIndex = items.firstIndex(where: {
            calendar.isDate($0.date, inSameDayAs: today)
        }) {
            let indexPath = IndexPath(item: todayIndex, section: 0)
            DispatchQueue.main.async {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    func scrollToCenter(of indexPath: IndexPath, in collectionView: UICollectionView) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let attributes = layout.layoutAttributesForItem(at: indexPath)
        let cellFrame = attributes?.frame ?? .zero
        
        let collectionViewWidth = collectionView.bounds.size.width
        let targetX = cellFrame.midX - collectionViewWidth / 2
        let maxOffsetX = collectionView.contentSize.width - collectionViewWidth
        let finalOffsetX = max(0, min(targetX, maxOffsetX))
        
        let targetOffset = CGPoint(x: finalOffsetX, y: 0)
        collectionView.setContentOffset(targetOffset, animated: true)
    }
    
    
    func getCurrentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateInputs.dd_MM_yyyy
        return formatter.string(from: Date())
    }
    
    func filterHomeworkGroupByDate(from data: [HomeworkList], date: String) -> [Homework] {
        if let matchedGroup = data.first(where: { $0.date == date }) {
            return matchedGroup.homework ?? []
        }
        return []
    }
    
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
}

extension homeWorkVc: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            // Reset to full filtered list for selected date
            self.FilterHomeWorkList = self.filterHomeworkGroupByDate(
                from: self.allHomeworkData,
                date: self.selectedDate ?? ""
            )
            self.NodataFoundLbl.isHidden = !self.FilterHomeWorkList.isEmpty
            self.noDataImage.isHidden = !self.FilterHomeWorkList.isEmpty
            self.bottomCV.reloadData()
            return
        }
        
        let allItems = self.filterHomeworkGroupByDate(
            from: self.allHomeworkData,
            date: self.selectedDate ?? ""
        )
        
        self.FilterHomeWorkList = allItems.filter {
            ($0.title ?? "").localizedCaseInsensitiveContains(searchText) ||
            ($0.sent_by ?? "").localizedCaseInsensitiveContains(searchText) ||
            ($0.subject_name ?? "").localizedCaseInsensitiveContains(searchText)
        }
        
        // Show/hide no results label
        self.NodataFoundLbl.isHidden = !self.FilterHomeWorkList.isEmpty
        self.noDataImage.isHidden = !self.FilterHomeWorkList.isEmpty
        self.homeWorkDefaultLbl.isHidden = self.FilterHomeWorkList.isEmpty
      
        self.bottomCV.reloadData()
    }

}


struct CalendarItem {
    let date: Date
    var hasHomework: Bool = false // new
    
    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }
}
