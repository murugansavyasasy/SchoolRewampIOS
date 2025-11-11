//
//  HolidayVC.swift
//  School Chimes
//
//  Created by Chandhru on 07/07/25.
//
import UIKit

@available(iOS 13.4, *)
class HolidayVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var calanderCollectionView: UICollectionView!
    @IBOutlet weak var noHolidayLbl: UILabel!
    @IBOutlet weak var selectedMonthLbl: UILabel!
    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var leaveListTable: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var noLeaveImage: UIImageView!
    
    // MARK: - Properties
    var eventHolidayData: [EventHolidayData]?
    private var currentDate: Date = Date()
    private var daysInMonth: [Date] = []
    private var filteredHolidays: [EventHolidayData] = []
    private var holidayColors: [String: UIColor] = [:]
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var staffDetails = UserDefaultFileManager.get_child_Details()
    private let weekdays = ["Sun","Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let formatter = DateFormatter()
    var passValue = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TopView.layer.cornerRadius = 20
        TopView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        if passValue == 1 || passValue == 2{
            BackBtn.isHidden = true
            titleLbl.isHidden = true
            studentNameLbl.text = "  " + AttendanceString.holidays
            studentNameLbl.setFont(style: .title, size: FontSize.TitleSize)
        }else{
            BackBtn.isHidden = false
            titleLbl.isHidden = false
            let name = studentDetails?.name ?? ""
            let stanard = (studentDetails?.standard_name ?? "") + " - " + (studentDetails?.section_name ?? "")
            studentNameLbl.configureAsBackTitle(firstLine: name, secondLine: stanard)
            titleLbl.text = AttendanceString.holidays
        }
        
        noHolidayLbl.isHidden = true
        noLeaveImage.isHidden = true
        
        setupViews()
        addSwipeGestures()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        updateTableviewHeight()
    }
    
    func updateTableviewHeight(){
        leaveListTable.layoutIfNeeded()
        tableviewHeight.constant = leaveListTable.contentSize.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        event_holiday()
    }

    // MARK: - API
    func event_holiday() {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }

        var token = ""
        if passValue == 1{
            token = staffDetails?.access_token ?? ""
        }else{
            token = studentDetails?.access_token ?? ""
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.school_event_view_holidays,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: token) { [weak self] (result: Result<EventHolidayResponse, Error>) in
                DispatchQueue.main.async {
                    if #available(iOS 15.0, *) {
                        self?.hideActivityLoader()
                    }
                    
                    switch result {
                    case .success(let response):
                        self?.eventHolidayData = response.data
                        self?.setupCalendarDates()
                        self?.updateFilteredHolidays()
                        self?.updateHeaderLabels()
                        if response.status == true{
                            
                            if self?.passValue == 0{
                                if user_inputs.clearTempData(){
                                    let parms = [ "mobile_number": UserDefaultFileManager.get_child_Details()?.whatsapp_number ?? "",
                                                  "activity": "VIEW_EVENTS",
                                                  "user_type": 1,
                                                  "menu_id": Menu_id.staffSelectedMenuId] as [String : Any]
                                    self?.paketApiCall(params:parms)
                                }
                            }
                        }
                    case .failure(let error):
                        print("Error fetching holidays:", error.localizedDescription)
                    }
                }
            }
    }
    func paketApiCall(params:[String:Any]){
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_pauket_add_points,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
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
    // MARK: - Setup
    private func setupViews() {
        calanderCollectionView.delegate = self
        calanderCollectionView.dataSource = self
        leaveListTable.delegate = self
        leaveListTable.dataSource = self
        
        calanderCollectionView.register(UINib(nibName: "CalanderDateCVC", bundle: nil), forCellWithReuseIdentifier: "CalanderDateCVC")
        leaveListTable.register(UINib(nibName: "HolidayTVC", bundle: nil), forCellReuseIdentifier: "HolidayTVC")
        
        calanderCollectionView.backgroundColor = .systemGray6
        calanderCollectionView.layer.borderWidth = 0.5
        calanderCollectionView.layer.borderColor = UIColor.lightGray.cgColor
    }

//    private func setupCalendarDates() {
//        daysInMonth.removeAll()
//        var calendar = Calendar.current
//        calendar.firstWeekday = 1
//        
//        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
//              let range = calendar.range(of: .day, in: .month, for: currentDate) else { return }
//        
//        let firstWeekday = calendar.component(.weekday, from: monthStart)
//        let offset = (firstWeekday - 1 + 7) % 7
//        let totalDateCells = 42
//        daysInMonth = Array(repeating: Date.distantPast, count: totalDateCells)
//        
//        for day in 0..<range.count {
//            if let date = calendar.date(byAdding: .day, value: day, to: monthStart) {
//                let index = offset + day
//                if index < totalDateCells {
//                    daysInMonth[index] = date
//                }
//            }
//        }
//        
//        for i in 0..<offset {
//            if let date = calendar.date(byAdding: .day, value: -(offset - i), to: monthStart) {
//                daysInMonth[i] = date
//            }
//        }
//
//        let lastDayIndex = offset + range.count
//        if lastDayIndex < totalDateCells {
//            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart)!
//            for i in (lastDayIndex + 1)..<totalDateCells {
//                let dayOffset = i - lastDayIndex
//                if let date = calendar.date(byAdding: .day, value: dayOffset, to: nextMonthStart) {
//                    daysInMonth[i] = date
//                }
//            }
//        }
//            calanderCollectionView.reloadData()
//    }
    private func setupCalendarDates() {
        daysInMonth.removeAll()
        var calendar = Calendar.current
        calendar.firstWeekday = 1

        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
              let range = calendar.range(of: .day, in: .month, for: currentDate) else { return }

        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let offset = (firstWeekday - 1 + 7) % 7
        let totalDateCells = 42
        daysInMonth = Array(repeating: Date.distantPast, count: totalDateCells)

        for day in 0..<range.count {
            if let date = calendar.date(byAdding: .day, value: day, to: monthStart) {
                daysInMonth[offset + day] = date
            }
        }

        // Fill previous month
        for i in 0..<offset {
            if let date = calendar.date(byAdding: .day, value: -(offset - i), to: monthStart) {
                daysInMonth[i] = date
            }
        }

        // Fill next month
        let lastDayIndex = offset + range.count
        if lastDayIndex < totalDateCells {
            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart)!
            for i in lastDayIndex..<totalDateCells {
                if let date = calendar.date(byAdding: .day, value: i - lastDayIndex, to: nextMonthStart) {
                    daysInMonth[i] = date
                }
            }
        }

        calanderCollectionView.reloadData()
    }
    private func updateFilteredHolidays() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentDate)

        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else { return }

        filteredHolidays = (eventHolidayData ?? []).filter {
            guard let holidayDate = $0.date?.dateFromISO8601 else { return false }
            return holidayDate >= startOfMonth && holidayDate < endOfMonth
        }.sorted { ($0.date ?? "") < ($1.date ?? "") }
        formatter.dateFormat = "MMMM yyyy"
        noHolidayLbl.text = "\("No holidays in") \(formatter.string(from: currentDate))"
        noHolidayLbl.isHidden = !filteredHolidays.isEmpty
        noLeaveImage.isHidden = !filteredHolidays.isEmpty
        leaveListTable.reloadData()
    }
    private func updateHeaderLabels() {
        formatter.dateFormat = "MMMM yyyy"
        selectedMonthLbl.text = formatter.string(from: currentDate)
    }
    
//    private func updateFilteredHolidays() {
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.year, .month], from: currentDate)
//        
//        guard let startOfMonth = calendar.date(from: components),
//              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else { return }
//        noHolidayLbl.text = "Holidays for \(formatter.string(from: currentDate))"
//        filteredHolidays = (eventHolidayData ?? []).filter {
//            guard let holidayDate = $0.date?.dateFromISO8601 else { return false }
//            return holidayDate >= startOfMonth && holidayDate < endOfMonth
//        }.sorted { ($0.date ?? "") < ($1.date ?? "") }
//        noHolidayLbl.isHidden = !filteredHolidays.isEmpty
//        leaveListTable.reloadData()
//    }

    // MARK: - Gestures
    private func addSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        calanderCollectionView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        calanderCollectionView.addGestureRecognizer(swipeRight)
    }

    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .left:
            currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
            updateCalendarView(with: .left)
        case .right:
            currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
            updateCalendarView(with: .right)
        default: break
        }
    }

    private func updateCalendarView(with direction: UISwipeGestureRecognizer.Direction) {
        let transition = CATransition()
        transition.type = .push
        transition.subtype = direction == .left ? .fromRight : .fromLeft
        transition.duration = 0.3
        transition.timingFunction = .init(name: .easeInEaseOut)
        calanderCollectionView.layer.add(transition, forKey: "calendarSwipe")

        setupCalendarDates()
        updateFilteredHolidays()
        updateHeaderLabels()
    }

    // MARK: - Color
    private func colorForHoliday(named name: String) -> UIColor {
        if let color = holidayColors[name] {
            return color
        } else {
            let hue = CGFloat.random(in: 0...1)
            let vibrantColor = UIColor(hue: hue, saturation: 0.7, brightness: 0.95, alpha: 1.0)
            holidayColors[name] = vibrantColor
            return vibrantColor
        }
    }

    private func isDateInCurrentMonth(_ date: Date) -> Bool {
        return Calendar.current.isDate(date, equalTo: currentDate, toGranularity: .month)
    }

    // MARK: - IBActions
    @IBAction func previousMonth(_ sender: UIButton) {
        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        updateCalendarView(with: .right)
    }

    @IBAction func nextMonth(_ sender: UIButton) {
        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        updateCalendarView(with: .left)
    }
    
    
    @IBAction func BackAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7 + daysInMonth.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalanderDateCVC", for: indexPath) as! CalanderDateCVC
        cell.reset() // make sure this method is implemented in CalanderDateCVC

        if indexPath.row < 7 {
            let day = weekdays[indexPath.row]
            cell.dateLbl.text = day
            cell.dateLbl.textColor = day == "Sun" ? .red : .black
            cell.dateLbl.font = .boldSystemFont(ofSize: 12)
            cell.outerView.backgroundColor = .clear
            return cell
        }

        let dateIndex = indexPath.row - 7
        let date = daysInMonth[dateIndex]
        
        if date == Date.distantPast {
            cell.dateLbl.text = ""
            cell.outerView.backgroundColor = .white
            return cell
        }

        let day = Calendar.current.component(.day, from: date)
        cell.dateLbl.text = "\(day)"
        cell.dateLbl.font = .systemFont(ofSize: 12)

        let weekday = Calendar.current.component(.weekday, from: date)
        let isCurrentMonth = isDateInCurrentMonth(date)

        if isCurrentMonth {
            cell.dateLbl.textColor = weekday == 1 ? .red : .black
        } else {
            cell.dateLbl.textColor = .lightGray
        }

        let dateStr = DateFormatter.yyyyMMdd.string(from: date)
        if let holiday = eventHolidayData?.first(where: { $0.date == dateStr }), isCurrentMonth {
            cell.outerView.backgroundColor = .backGroundClr//colorForHoliday(named: holiday.name ?? "")
            cell.dateLbl.textColor = .white
        } else {
            cell.outerView.backgroundColor = .white
        }

        if Calendar.current.isDateInToday(date) {
            cell.outerView.backgroundColor = .systemYellow.withAlphaComponent(0.3)
        }

        cell.outerView.layer.borderWidth = 0.2
        cell.outerView.layer.borderColor = UIColor.lightGray.cgColor
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        let height = collectionView.frame.height / 7
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout layout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { 0 }
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 0 }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredHolidays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HolidayTVC", for: indexPath) as! HolidayTVC
        let holiday = filteredHolidays[indexPath.row]
        cell.nameLbl.text = holiday.name
        cell.DateLbl.text = holiday.date?.convertToTargetDateFormat()
        cell.colorBtn.backgroundColor = .backGroundClr//colorForHoliday(named: holiday.name ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            self.updateTableviewHeight()
        }
    }

//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        guard !filteredHolidays.isEmpty else { return nil }
//        formatter.dateFormat = "MMMM yyyy"
////        return "Holidays"
//        return "Holidays for \(formatter.string(from: currentDate))"
//    }
//    
//     func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        if let header = view as? UITableViewHeaderFooterView {
//            // Customize font
//            header.textLabel?.font = UIFont(name: "Poppins-Bold", size: 13)
//            
//            // Customize color
//            header.textLabel?.textColor = .black.withAlphaComponent(0.8)
//            
//            // Optional: background color
//            header.contentView.backgroundColor = .clear
//        }
//    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .clear  // Customize color

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFont(style: .title, size: FontSize.TitleSize)
        label.textColor = .darkGray
        label.text = "\(AttendanceString.holidaysFor) \(formatter.string(from: currentDate))"
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 5)])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return filteredHolidays.isEmpty ? 0 : 30
    }
}

// MARK: - Extensions
extension String {
    var dateFromISO8601: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self)
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
