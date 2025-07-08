////
////  HolidayVC.swift
////  School Chimes
////
////  Created by Chandhru on 07/07/25.
////
//
//import UIKit
//import FSCalendar
//
//@available(iOS 13.4, *)
//class HolidayVC: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {
//    
//    // MARK: - IBOutlets
//    @IBOutlet weak var selectedMonthLbl: UILabel!
//    @IBOutlet weak var selectedYear: UILabel!
//    @IBOutlet weak var calendarContainerView: FSCalendar!
//    @IBOutlet weak var leaveListTable: UITableView!
//    
//    // MARK: - Properties
//    var eventHolidayData: [EventHolidayData]?
//    private var currentSelectedDate: Date?
//    private var filteredHolidays: [EventHolidayData] = []
//    private var holidayColors: [String: UIColor] = [:]
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCalendar()
//        setupTableView()
//        updateFilteredHolidays()
//    }
//
//    // MARK: - Setup Calendar
//    private func setupCalendar() {
//        calendarContainerView.layer.cornerRadius = 10
//        calendarContainerView.layer.borderColor = UIColor.lightGray.cgColor
//        calendarContainerView.layer.borderWidth = 0.6
//        calendarContainerView.delegate = self
//        calendarContainerView.dataSource = self
//        calendarContainerView.scrollDirection = .horizontal
//        calendarContainerView.scope = .month
//        calendarContainerView.firstWeekday = 2
//        calendarContainerView.appearance.borderRadius = 0.0
//        calendarContainerView.placeholderType = .none
//        calendarContainerView.pagingEnabled = true
//        calendarContainerView.headerHeight = 0
//        let appearance = calendarContainerView.appearance
//        appearance.weekdayFont = .systemFont(ofSize: 13, weight: .medium)
//        appearance.titleFont = .systemFont(ofSize: 14, weight: .medium)
//        appearance.todayColor = .clear
//        appearance.selectionColor = .clear
//        appearance.titleTodayColor = .systemRed
//        calendarContainerView.allowsSelection = false
//        updateCustomMonthAndYearLabels()
//    }
//
//    private func updateCustomMonthAndYearLabels() {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMM"
//        selectedMonthLbl.text = formatter.string(from: calendarContainerView.currentPage)
//
//        let yearFormatter = DateFormatter()
//        yearFormatter.dateFormat = "yyyy"
//        selectedYear.text = yearFormatter.string(from: calendarContainerView.currentPage)
//    }
//
//    // MARK: - Setup TableView
//    private func setupTableView() {
//        leaveListTable.delegate = self
//        leaveListTable.dataSource = self
//        leaveListTable.register(UINib(nibName: "HolidayTVC", bundle: nil), forCellReuseIdentifier: "HolidayTVC")
//    }
//
//    // MARK: - Color Assignment (Vibrant Highlight Style)
//    private func colorForHoliday(named name: String) -> UIColor {
//        if let color = holidayColors[name] {
//            return color
//        } else {
//            let hue = CGFloat.random(in: 0...1)               // Full color range
//            let saturation = CGFloat.random(in: 0.6...0.9)     // More saturation
//            let brightness = CGFloat.random(in: 0.8...1.0)     // Brighter colors
//
//            let vibrantColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
//            holidayColors[name] = vibrantColor
//            return vibrantColor
//        }
//    }
//
//
//    // MARK: - Filter Holidays
//    private func updateFilteredHolidays() {
//        let selectedDate = currentSelectedDate ?? Date()
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM"
//
//        let selectedMonth = formatter.string(from: selectedDate)
//
//        filteredHolidays = (eventHolidayData ?? []).filter { event in
//            guard let date = event.date else { return false }
//            return date.hasPrefix(selectedMonth)
//        }.sorted { ($0.date ?? "") < ($1.date ?? "") }
//
//        leaveListTable.reloadData()
//    }
//
//    // MARK: - FSCalendar Delegate
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        if monthPosition != .current {
//            calendar.setCurrentPage(date, animated: true)
//        }
//    }
//
//    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
//        let calendar = Calendar.current
//        let selectedYear = calendar.component(.year, from: date)
//        let currentYear = calendar.component(.year, from: Date())
//        return selectedYear == currentYear
//    }
//
//    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
//        let utilCal = Calendar.current
//        let selectedYear = utilCal.component(.year, from: calendar.currentPage)
//        let currentYear = utilCal.component(.year, from: Date())
//
//        if selectedYear != currentYear {
//            calendar.setCurrentPage(Date(), animated: true)
//        } else {
//            currentSelectedDate = calendar.currentPage
//            updateFilteredHolidays()
//            updateCustomMonthAndYearLabels()
//        }
//    }
//
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let dateString = formatter.string(from: date)
//
//        if (eventHolidayData ?? []).contains(where: { $0.date == dateString }) {
//            return .white
//        }
//
//        if Calendar.current.component(.weekday, from: date) == 1 {
//            return .red
//        }
//
//        return nil
//    }
//
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        let dateString = formatter.string(from: date)
//
//        if let event = (eventHolidayData ?? []).first(where: { $0.date == dateString }),
//           let name = event.name {
//            return colorForHoliday(named: name).withAlphaComponent(0.8)
//        }
//
//        return nil
//    }
//
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
//        return UIColor.systemGray4
//    }
//
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderRadiusFor date: Date) -> CGFloat {
//        return 0 // Square cell
//    }
//
//    // MARK: - Month Navigation
//    @IBAction func previousMont(_ sender: UIButton) {
//        let currentPage = calendarContainerView.currentPage
//        if let prev = Calendar.current.date(byAdding: .month, value: -1, to: currentPage) {
//            calendarContainerView.setCurrentPage(prev, animated: true)
//            updateCustomMonthAndYearLabels()
//        }
//    }
//
//    @IBAction func nextMont(_ sender: UIButton) {
//        let currentPage = calendarContainerView.currentPage
//        if let next = Calendar.current.date(byAdding: .month, value: 1, to: currentPage) {
//            calendarContainerView.setCurrentPage(next, animated: true)
//            updateCustomMonthAndYearLabels()
//        }
//    }
//
//    // MARK: - UITableView
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredHolidays.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "HolidayTVC", for: indexPath) as! HolidayTVC
//        let holiday = filteredHolidays[indexPath.row]
//        cell.nameLbl.text = holiday.name
//        cell.colorBtn.backgroundColor = colorForHoliday(named: holiday.name ?? "")
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        guard !filteredHolidays.isEmpty else { return nil }
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMM yyyy"
//        return "Holidays for \(formatter.string(from: currentSelectedDate ?? Date()))"
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return filteredHolidays.isEmpty ? 0 : 40
//    }
//}
//
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
    @IBOutlet weak var calanderCollectionView: UICollectionView!
    @IBOutlet weak var selectedMonthLbl: UILabel!
    @IBOutlet weak var selectedYear: UILabel!
    @IBOutlet weak var calendarContainerView: UIView!
    @IBOutlet weak var leaveListTable: UITableView!

    // MARK: - Properties
    var eventHolidayData: [EventHolidayData]?
    private var currentDate: Date = Date()
    private var daysInMonth: [Date] = []
    private var filteredHolidays: [EventHolidayData] = []
    private var holidayColors: [String: UIColor] = [:]
    private let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCalendarDates()
        updateFilteredHolidays()
        updateHeaderLabels()
        addSwipeGestures()
    }

    // MARK: - Setup Views
    private func setupViews() {
        calanderCollectionView.delegate = self
        calanderCollectionView.dataSource = self
        leaveListTable.delegate = self
        leaveListTable.dataSource = self

        calanderCollectionView.register(UINib(nibName: "CalanderDateCVC", bundle: nil), forCellWithReuseIdentifier: "CalanderDateCVC")
        leaveListTable.register(UINib(nibName: "HolidayTVC", bundle: nil), forCellReuseIdentifier: "HolidayTVC")

        calanderCollectionView.backgroundColor = .white
        calanderCollectionView.layer.borderWidth = 1
        calanderCollectionView.layer.borderColor = UIColor.lightGray.cgColor
    }

    // MARK: - Setup Calendar Dates
    private func setupCalendarDates() {
        daysInMonth.removeAll()
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Week starts on Monday

        guard let range = calendar.range(of: .day, in: .month, for: currentDate),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else { return }

        let weekdayOffset = calendar.component(.weekday, from: firstOfMonth) - calendar.firstWeekday
        let adjustedOffset = (weekdayOffset + 7) % 7

        for i in 0..<(35 - adjustedOffset) {
            if i < adjustedOffset {
                daysInMonth.append(Date.distantPast)
            } else if let date = calendar.date(byAdding: .day, value: i - adjustedOffset, to: firstOfMonth) {
                daysInMonth.append(date)
            }
        }

        while daysInMonth.count < 35 {
            daysInMonth.append(Date.distantPast)
        }

        calanderCollectionView.reloadData()
    }

    private func updateHeaderLabels() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        selectedMonthLbl.text = formatter.string(from: currentDate)

        formatter.dateFormat = "yyyy"
        selectedYear.text = formatter.string(from: currentDate)
    }

    // MARK: - Swipe Gestures
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
            if let next = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) {
                currentDate = next
                updateCalendarView(with: .left)
            }
        case .right:
            if let prev = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
                currentDate = prev
                updateCalendarView(with: .right)
            }
        default:
            break
        }
    }

    // MARK: - Calendar Animation
    private func updateCalendarView(with direction: UISwipeGestureRecognizer.Direction) {
        let transition = CATransition()
        transition.type = .push
        transition.subtype = direction == .left ? .fromRight : .fromLeft
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        calanderCollectionView.layer.add(transition, forKey: "slideTransition")

        setupCalendarDates()
        updateFilteredHolidays()
        updateHeaderLabels()
    }

    // MARK: - Color Assignment
    private func colorForHoliday(named name: String) -> UIColor {
        if let color = holidayColors[name] {
            return color
        } else {
            let hue = CGFloat.random(in: 0...1)
            let saturation = CGFloat.random(in: 0.6...0.9)
            let brightness = CGFloat.random(in: 0.8...1.0)
            let vibrantColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
            holidayColors[name] = vibrantColor
            return vibrantColor
        }
    }

    private func updateFilteredHolidays() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        let selectedMonth = formatter.string(from: currentDate)

        filteredHolidays = (eventHolidayData ?? []).filter {
            guard let date = $0.date else { return false }
            return date.hasPrefix(selectedMonth)
        }.sorted { ($0.date ?? "") < ($1.date ?? "") }

        leaveListTable.reloadData()
    }

    // MARK: - Month Navigation
    @IBAction func previousMonth(_ sender: UIButton) {
        if let prev = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = prev
            updateCalendarView(with: .right)
        }
    }

    @IBAction func nextMonth(_ sender: UIButton) {
        if let next = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = next
            updateCalendarView(with: .left)
        }
    }

    // MARK: - UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7 + daysInMonth.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalanderDateCVC", for: indexPath) as! CalanderDateCVC
        cell.reset()

        if indexPath.row < 7 {
            // Weekday headers
            cell.dateLbl.text = weekdays[indexPath.row]
            cell.dateLbl.textColor = weekdays[indexPath.row] == "Sun" ? .red : .black
            cell.dateLbl.font = .systemFont(ofSize: 12, weight: .bold)
            cell.outerView.backgroundColor = .systemGray6
        } else {
            let dateIndex = indexPath.row - 7
            let date = daysInMonth[dateIndex]

            if date == Date.distantPast {
                cell.dateLbl.text = ""
                cell.outerView.backgroundColor = .clear
            } else {
                let day = Calendar.current.component(.day, from: date)
                cell.dateLbl.text = "\(day)"
                cell.dateLbl.font = .systemFont(ofSize: 12, weight: .medium)

                var calendar = Calendar.current
                calendar.firstWeekday = 2 // Monday
                let weekday = calendar.component(.weekday, from: date)

                // Highlight only Sunday
                cell.dateLbl.textColor = (weekday == 1) ? .red : .black

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let dateString = formatter.string(from: date)

                if let holiday = eventHolidayData?.first(where: { $0.date == dateString }), let name = holiday.name {
                    cell.outerView.backgroundColor = colorForHoliday(named: name)
                } else {
                    cell.outerView.backgroundColor = .white
                }
            }

            cell.outerView.layer.borderWidth = 0.5
            cell.outerView.layer.borderColor = UIColor.lightGray.cgColor
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 7
        let height = collectionView.frame.height / 6
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredHolidays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HolidayTVC", for: indexPath) as! HolidayTVC
        let holiday = filteredHolidays[indexPath.row]
        cell.nameLbl.text = "\(holiday.name ?? "") (\(holiday.date ?? ""))"
        cell.colorBtn.backgroundColor = colorForHoliday(named: holiday.name ?? "")
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard !filteredHolidays.isEmpty else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return "Holidays for \(formatter.string(from: currentDate))"
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return filteredHolidays.isEmpty ? 0 : 40
    }
}
