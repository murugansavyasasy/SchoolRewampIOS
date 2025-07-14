////
////  TimetableVC.swift
////  VsSchoolChimes
////
////  Created by Admin on 16/01/25.
////
//import UIKit
//
//class TimetableVC: UIViewController {
//
//    @IBOutlet weak var StandardLbl: UILabel!
//    @IBOutlet weak var BackBtn: UIButton!
//    @IBOutlet weak var tv: UITableView!
//    @IBOutlet weak var bgview: UIView!
//    @IBOutlet weak var NameLbl: UILabel!
//    @IBOutlet weak var cv: UICollectionView!
//    @IBOutlet weak var noDataImg: UIImageView!
//    @IBOutlet weak var noDataLbl: UILabel!
//    let id = "TimetableTv"
//    let id2 = "LastCell"
//
//    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
//    let colours = ["AttendenceColor","Clr","Color","lesson1","lesson3"]
//    var getCurrentDay: String!
//    var selectedIndex: Int = 0
//    var timeTable: [TimetableHour]?
//    var studentDetails = UserDefaultFileManager.get_child_Details()
//    var dayStatus = ""
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        getCurrentDay = getCurrentDayShort()
//        if let todayIndex = days.firstIndex(of: getCurrentDay) {
//            selectedIndex = todayIndex
//        }
//        BackBtn.applyBackButton()
//        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
//        NameLbl.setFont(style: .body, size: FontSize.BodySize)
//        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
//        NameLbl.text = studentDetails?.name
//        StandardLbl.text = (studentDetails?.standard_name ?? "") + " - " + (studentDetails?.section_name ?? "")
//
//        tv.register(UINib(nibName: CellConfingName.TimetableTv, bundle: nil), forCellReuseIdentifier: CellConfingName.TimetableTv)
//        tv.register(UINib(nibName: id2, bundle: nil), forCellReuseIdentifier: id2)
//        tv.delegate = self
//        tv.dataSource = self
//
//        cv.register(UINib(nibName: CellConfingName.WeekDaysNameCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.WeekDaysNameCollectionViewCell)
//        cv.delegate = self
//        cv.dataSource = self
//
//        DispatchQueue.main.async {
//            self.cv.selectItem(at: IndexPath(item: self.selectedIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
//        }
//
//        daily_collectionApi(type: selectedIndex)
//    }
//
//    func daily_collectionApi(type: Int) {
//        APIService.shared.makeApi(
//            url: ServiceUrl.lms_api_time_table_get_schedule,
//            parameters: ["day_id": type + 1],
//            type: ApitTypeSringFile.GET,
//            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
//        ) { [weak self] (result: Result<TimetableResponse, Error>) in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    self?.tv.isHidden = false
//                    self?.timeTable = response.data
//                    self?.noDataImg.isHidden = !(self?.timeTable?.isEmpty ?? false)
//                    self?.noDataLbl.isHidden = !(self?.timeTable?.isEmpty ?? false)
//                    self?.noDataLbl.text = response.message
//                    self?.tv.reloadData()
//                case .failure(let error):
//                    print("API Error:", error)
//                }
//            }
//        }
//    }
//
//    override func viewDidLayoutSubviews() {
//        view.applyGradient(colors: [Colornames.gradientBlue, Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5), endPoint: CGPoint(x: 0, y: 0.5))
//        bgview.applyGradient(colors: [Colornames.gradientBlue, Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5), endPoint: CGPoint(x: 0, y: 0.5))
//    }
//
//    @IBAction func BackAct(_ sender: Any) {
//        dismiss(animated: true)
//    }
//}
//
//extension TimetableVC: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return timeTable?.count ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let item = timeTable?[indexPath.row],
//              let cell = tv.dequeueReusableCell(withIdentifier: id, for: indexPath) as? TimetableTv else {
//            return UITableViewCell()
//        }
//
//        cell.TimeLbl.text = "\(item.start_time ?? "")"
//        cell.DurationLbl.text = "\(item.start_time ?? "") - \(item.end_time ?? "")"
//        cell.hrsType.text = "\(item.duration ?? "")"
//        cell.SubjectLbl.text = item.subject_name ?? ""
//        cell.StaffNameLbl.text = item.name ?? ""
//        
//        switch dayStatus {
//        case "present":
//            let isPastTime = hasCurrentTimeCrossed(endTimeString: item.end_time ?? "")
//            cell.CheckImgview.image = isPastTime ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
//            cell.ProgressView.backgroundColor = isPastTime ? .green : .lightGray
//
//        case "past":
//            cell.CheckImgview.image = UIImage(systemName: "checkmark.circle.fill")
//            cell.ProgressView.backgroundColor = .green
//
//        case "future":
//            cell.CheckImgview.image = UIImage(systemName: "circle")
//            cell.ProgressView.backgroundColor = .lightGray
//
//        default:
//            break
//        }
//        
//        let colour = indexPath.row % colours.count
//        cell.DetailsView.backgroundColor = UIColor(named: colours[colour])
//
//        return cell
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//}
//
//extension TimetableVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return days.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.WeekDaysNameCollectionViewCell, for: indexPath) as! WeekDaysNameCollectionViewCell
//
//        let day = days[indexPath.row]
//        cell.weekDaysNameLbl.text = day
//        cell.bgView.backgroundColor = (indexPath.row == selectedIndex) ? UIColor(named: "Priority") : .systemGray6
//        dayStatus = getDayStatus(for: days[selectedIndex])
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        selectedIndex = indexPath.row
//        daily_collectionApi(type: selectedIndex)
//        collectionView.reloadData()
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        if let cell = collectionView.cellForItem(at: indexPath) as? WeekDaysNameCollectionViewCell {
//            cell.bgView.backgroundColor = .systemGray6
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 120, height: 50)
//    }
//}
//
//// MARK: - Helpers
//
//func hasCurrentTimeCrossed(endTimeString: String) -> Bool {
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "hh:mm a"
//    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//
//    guard let endTimeDate = dateFormatter.date(from: endTimeString) else {
//        print("Invalid end time: \(endTimeString)")
//        return false
//    }
//
//    let calendar = Calendar.current
//    let now = Date()
//
//    let endComponents = calendar.dateComponents([.hour, .minute], from: endTimeDate)
//    let nowComponents = calendar.dateComponents([.year, .month, .day], from: now)
//
//    var fullEndComponents = DateComponents()
//    fullEndComponents.year = nowComponents.year
//    fullEndComponents.month = nowComponents.month
//    fullEndComponents.day = nowComponents.day
//    fullEndComponents.hour = endComponents.hour
//    fullEndComponents.minute = endComponents.minute
//
//    if let fullEndDate = calendar.date(from: fullEndComponents) {
//        return now > fullEndDate
//    }
//
//    return false
//}
//
//func getCurrentDayShort() -> String {
//    let formatter = DateFormatter()
//    formatter.dateFormat = "EEE"
//    formatter.locale = Locale(identifier: "en_US_POSIX")
//    return formatter.string(from: Date())
//}
//// Helper function: compare selectedDate with today
//func getDayStatus(for dayShort: String) -> String {
//    let weekDays: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
//
//    guard let todayIndex = weekDays.firstIndex(of: getCurrentDayShort()),
//          let targetIndex = weekDays.firstIndex(of: dayShort) else {
//        return "unknown"
//    }
//
//    if targetIndex == todayIndex {
//        return "present"
//    } else if targetIndex < todayIndex {
//        return "past"
//    } else {
//        return "future"
//    }
//}
//
import UIKit

class TimetableVC: UIViewController {

    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var bgview: UIView!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var noDataImg: UIImageView!
    @IBOutlet weak var noDataLbl: UILabel!

    let id = "TimetableTv"
    let id2 = "LastCell"

    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let colours = ["AttendenceColor", "Clr", "Color", "lesson1", "lesson3"]

    var getCurrentDay: String!
    var selectedIndex: Int = 0
    var timeTable: [TimetableHour]?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var dayStatus = ""
    private var progressTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        getCurrentDay = getCurrentDayShort()
        if let todayIndex = days.firstIndex(of: getCurrentDay) {
            selectedIndex = todayIndex
        }

        BackBtn.applyBackButton()
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        NameLbl.text = studentDetails?.name
        StandardLbl.text = (studentDetails?.standard_name ?? "") + " - " + (studentDetails?.section_name ?? "")

        tv.register(UINib(nibName: CellConfingName.TimetableTv, bundle: nil), forCellReuseIdentifier: id)
        tv.delegate = self
        tv.dataSource = self

        cv.register(UINib(nibName: CellConfingName.WeekDaysNameCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.WeekDaysNameCollectionViewCell)
        cv.delegate = self
        cv.dataSource = self

        DispatchQueue.main.async {
            self.cv.selectItem(at: IndexPath(item: self.selectedIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }

        daily_collectionApi(type: selectedIndex)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startProgressTimer()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopProgressTimer()
    }

    func startProgressTimer() {
        stopProgressTimer()
        if dayStatus == "present" {
            progressTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(updateVisibleCellsProgress), userInfo: nil, repeats: true)
        }
    }

    func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    @objc func updateVisibleCellsProgress() {
        for cell in tv.visibleCells {
            guard let indexPath = tv.indexPath(for: cell),
                  let item = timeTable?[indexPath.row],
                  let timetableCell = cell as? TimetableTv else { continue }

            let progress = getTimeProgress(startTime: item.start_time ?? "", endTime: item.end_time ?? "")
            timetableCell.progrssView.setProgress(Float(progress), animated: true)
            timetableCell.CheckImgview.image = progress >= 1.0 ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        }
    }


    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }

//    func startProgressTimer() {
//        stopProgressTimer()
//        if dayStatus == "present" {
//            progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateVisibleCellsProgress), userInfo: nil, repeats: true)
//        }
//    }


//    @objc func updateVisibleCellsProgress() {
//        guard dayStatus == "present" else { return }
//
//        for cell in tv.visibleCells {
//            guard let indexPath = tv.indexPath(for: cell),
//                  let item = timeTable?[indexPath.row],
//                  let timetableCell = cell as? TimetableTv else { continue }
//
//            let progress = getTimeProgress(startTime: item.start_time ?? "", endTime: item.end_time ?? "")
//
//            timetableCell.progressBar.setProgress(Float(progress), animated: true)
//            UIView.animate(withDuration: 0.3) {
//                timetableCell.progressBar.progressTintColor = progress >= 1.0 ? .systemGreen : .systemBlue
//            }
//            timetableCell.CheckImgview.image = progress >= 1.0 ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
//        }
//    }

    func daily_collectionApi(type: Int) {
        APIService.shared.makeApi(
            url: ServiceUrl.lms_api_time_table_get_schedule,
            parameters: ["day_id": type + 1],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<TimetableResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self?.tv.isHidden = false
                    self?.timeTable = response.data
                    self?.noDataImg.isHidden = !(self?.timeTable?.isEmpty ?? false)
                    self?.noDataLbl.isHidden = !(self?.timeTable?.isEmpty ?? false)
                    self?.noDataLbl.text = response.message
                    self?.dayStatus = getDayStatus(for: self?.days[self?.selectedIndex ?? 0] ?? "")
                    self?.tv.reloadData()
//                    self?.startProgressTimer()
                case .failure(let error):
                    print("API Error:", error)
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue, Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5), endPoint: CGPoint(x: 0, y: 0.5))
        bgview.applyGradient(colors: [Colornames.gradientBlue, Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5), endPoint: CGPoint(x: 0, y: 0.5))
    }
}

// MARK: - TableView

extension TimetableVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeTable?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = timeTable?[indexPath.row],
              let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as? TimetableTv else {
            return UITableViewCell()
        }

        cell.TimeLbl.text = item.start_time ?? ""
        cell.DurationLbl.text = "\(item.start_time ?? "") - \(item.end_time ?? "")"
        cell.hrsType.text = "\(" ")\(item.duration ?? "") \(" ")"
        cell.SubjectLbl.text = item.subject_name ?? ""
        cell.StaffNameLbl.text = item.name ?? ""

        let progress = getTimeProgress(startTime: item.start_time ?? "", endTime: item.end_time ?? "")

        switch dayStatus {
        case "present":
            cell.progrssView.setProgress(0.0, animated: false)
            cell.progrssView.setProgress(Float(progress), animated: true)
            cell.CheckImgview.image = progress >= 1.0 ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")

        case "past":
            cell.progrssView.setProgress(1.0, animated: false)
            cell.CheckImgview.image = UIImage(systemName: "checkmark.circle.fill")

        case "future":
            cell.progrssView.setProgress(0.0, animated: false)
            cell.CheckImgview.image = UIImage(systemName: "circle")

        default:
            break
        }


        let colour = indexPath.row % colours.count
        cell.DetailsView.backgroundColor = UIColor(named: colours[colour])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - CollectionView

extension TimetableVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.WeekDaysNameCollectionViewCell, for: indexPath) as! WeekDaysNameCollectionViewCell
        let day = days[indexPath.row]
        cell.weekDaysNameLbl.text = day
        cell.bgView.backgroundColor = (indexPath.row == selectedIndex) ? UIColor(named: "Priority") : .systemGray6
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        daily_collectionApi(type: selectedIndex)
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? WeekDaysNameCollectionViewCell {
            cell.bgView.backgroundColor = .systemGray6
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 50)
    }
}

// MARK: - Helper Functions

func getCurrentDayShort() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: Date())
}

func getDayStatus(for dayShort: String) -> String {
    let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    guard let todayIndex = weekDays.firstIndex(of: getCurrentDayShort()),
          let selectedIndex = weekDays.firstIndex(of: dayShort) else {
        return "unknown"
    }

    if selectedIndex == todayIndex {
        return "present"
    } else if selectedIndex < todayIndex {
        return "past"
    } else {
        return "future"
    }
}

func getTimeProgress(startTime: String, endTime: String) -> Double {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    formatter.locale = Locale(identifier: "en_US_POSIX")

    guard let start = formatter.date(from: startTime),
          let end = formatter.date(from: endTime) else {
        print("Invalid time format: \(startTime) → \(endTime)")
        return 0.0
    }

    let calendar = Calendar.current
    let now = Date()

    var startComp = calendar.dateComponents([.hour, .minute], from: start)
    var endComp = calendar.dateComponents([.hour, .minute], from: end)
    let todayComp = calendar.dateComponents([.year, .month, .day], from: now)

    startComp.year = todayComp.year
    startComp.month = todayComp.month
    startComp.day = todayComp.day

    endComp.year = todayComp.year
    endComp.month = todayComp.month
    endComp.day = todayComp.day

    guard let startDate = calendar.date(from: startComp),
          let endDate = calendar.date(from: endComp) else {
        return 0.0
    }

    let total = endDate.timeIntervalSince(startDate)
    let elapsed = now.timeIntervalSince(startDate)

    let percent = max(0.0, min(1.0, elapsed / total))

    print("⏱️ \(startTime) → \(endTime) | Elapsed: \(elapsed)s / \(total)s = \(percent * 100)%")
    return percent
}
