//
//  homeWorkVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 21/07/25.
//

import UIKit

class homeWorkVc: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
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
            detailVC.selectedDate  = selectedDate
            detailVC.titleString  = FilterHomeWorkList[indexPath.row].title
            detailVC.descriptionString  = FilterHomeWorkList[indexPath.row].description
            detailVC.homeWorkid  = FilterHomeWorkList[indexPath.row].id
            detailVC.postedBy  = FilterHomeWorkList[indexPath.row].sent_by
            detailVC.subject_name  = FilterHomeWorkList[indexPath.row].subject_name
            detailVC.modalPresentationStyle = .custom
            transitionDelegate.originFrame = cellFrameInSuperview
            detailVC.transitioningDelegate = transitionDelegate
            
            present(detailVC, animated: true)
            
        }else{
            
            scrollToCenter(of: indexPath, in: collectionView)
            
            let item = calendarItems[indexPath.item]
            let today = Date()
            
            // Disable future date selection
            guard item.date <= today else { return }
            
            // Convert date to string format matching API
            let selectedDate = convertDateToString(item.date)
            self.selectedDate = selectedDate
            selectedIndexPath = indexPath
            
            // Filter from cached API response
            FilterHomeWorkList = filterHomeworkGroupByDate(from: allHomeworkData, date: selectedDate)
            
            let isEmpty = FilterHomeWorkList.isEmpty
            //                    self.noDataLbl.text = response.message
            //                    self.noDataLbl.isHidden = !isEmpty
            noDataImage.isHidden = !isEmpty
            NodataFoundLbl.isHidden = !isEmpty
            homeWorkDefaultLbl.isHidden = isEmpty
            bottomCV.isHidden  = isEmpty
            
            bottomCV.reloadData() // reload homework list
            cv.reloadData() // optional: refresh selection UI
               

            
        }
        }
    
    func convertDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy" // Match API format!
        formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return formatter.string(from: date)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == bottomCV{
            let item = FilterHomeWorkList[indexPath.item]
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeWorkCvCell", for: indexPath) as? HomeWorkCvCell else {
                return UICollectionViewCell()
            }
            isReadStatus = item.is_unread
            cell.SubjectLbl.text = item.subject_name
            cell.stafNamLbl.text = item.sent_by
            
            if isReadStatus == true{
                let percentage = Double(0)
                cell.setProgress(to: percentage)
                cell.roundview.isHidden = false
            }else{
                
                let percentage = Double(50)
                cell.roundview.isHidden = true
                cell.setProgress(to: percentage)
                
            }
            
            
            if item.is_completed == true{
                //                    complete_homework
                cell.homeWorkCompletImg.isHidden = false
                cell.pieChartWidth.constant = 0
                cell.PieChartTrailling.constant = -10
                cell.pieChart.isHidden = true
            }
            //                else{
            //
            //                    cell.homeWorkCompletImg.isHidden = true
            //                    cell.pieChart.isHidden = false
            //                    cell.pieChartWidth.constant = -30
            //                    cell.PieChartTrailling.constant = 80
            //
            //
            //                }
            
            return cell
        }else{
            let item = calendarItems[indexPath.item]
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalanderCvCell", for: indexPath) as? CalanderCvCell else {
                return UICollectionViewCell()
            }
            
            
            
            let isToday = Calendar.current.isDateInToday(item.date)
            let isFuture = item.date > today
            
            //                print("itemitem",item.date)
            // Configure UI
            cell.configure(
                with: item,
                isToday: isToday,
                isSelected: indexPath == selectedIndexPath,
                hasHomework: item.hasHomework,
                isFuture: item.date > today
            )
            
            
            // Grey out future dates
            //                cell.isUserInteractionEnabled = !isFuture
            //                cell.alpha = isFuture ? 0.4 : 1.0
            //
            // Selected highlight (today selected by default)
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
    
    @IBOutlet weak var NodataFoundLbl: UILabel!
    @IBOutlet weak var homeWorkDefaultLbl: UILabel!
    @IBOutlet weak var searchBtnName: UIButton!
    
    @IBOutlet weak var noDataImage: UIImageView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var cv: UICollectionView!
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var bottomCV: UICollectionView!
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        searchbar.isHidden = true
        searchbar.delegate = self
        searchbar.searchTextField.addDoneButton()
        topView.layer.cornerRadius = 30
        topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        topView.layer.masksToBounds = true
        
        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
                   layout.scrollDirection = .horizontal
                   layout.minimumLineSpacing = 0
               }
    
        calendarItems = getAllDatesPast1MonthPlus1Month()
        cv.register(UINib(nibName: "CalanderCvCell", bundle: nil), forCellWithReuseIdentifier: "CalanderCvCell")
        
        bottomCV.register(UINib(nibName: "HomeWorkCvCell", bundle: nil), forCellWithReuseIdentifier: "HomeWorkCvCell")
        
        cv.delegate = self
        cv.dataSource = self
        if let todayIndex = calendarItems.firstIndex(where: { Calendar.current.isDateInToday($0.date) }) {
            selectedIndexPath = IndexPath(item: todayIndex, section: 0)
        }
        cv.reloadData()
        
        scrollToToday(in: cv, with: calendarItems)
        
    }
    
    
    @IBAction func searchBtn(_ sender: UIButton) {
        toggle.toggle()
        searchbar.isHidden = toggle
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GetHomeWorkReport()
    }
    
    
    func getAllDatesPast1MonthPlus1Month() -> [CalendarItem] {
        var items: [CalendarItem] = []
        let calendar = Calendar.current
        let today = Date()
        
        let pastStartDate = calendar.date(byAdding: .month, value: -1, to: today)!
        let futureEndDate = calendar.date(byAdding: .month, value: 1, to: today)!
        
        var currentDate = pastStartDate
        while currentDate <= futureEndDate {
            items.append(CalendarItem(date: currentDate))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return items
    }
    
    
    
    func GetHomeWorkReport() {
        
        FilterHomeWorkList.removeAll()
        if #available(iOS 15.0, *) { showLottieProgressLoader(animationName: "loader (2)") }
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_homework_get_homework_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<HomeworListkResponse, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) { self?.hideLottieProgressLoader() }
                
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
                    
                    let isEmpty = filteredHomework.isEmpty
                    self.NodataFoundLbl.text = response.message
                    self.NodataFoundLbl.isHidden = !isEmpty
                    
                    self.noDataImage.isHidden = !isEmpty
                    //                    self.searchbar.isHidden = isEmpty
                    self.homeWorkDefaultLbl.isHidden = isEmpty
                    
                case .failure(let error):
                    
                    self.noDataImage.isHidden = false
                    self.searchbar.isHidden = true
                    
                    
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
        formatter.dateFormat = "dd-MM-yyyy"
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
