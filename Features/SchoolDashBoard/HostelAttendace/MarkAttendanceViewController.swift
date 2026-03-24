import UIKit
import FSCalendar

struct StudentAttendanceInfo {
    let name: String
    let id: String
    let parentNum: String
    var state: Int  // 0=unset, 1=present, 2=absent
}

class MarkAttendanceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
                                    StudentAttendanceCellDelegate, FSCalendarDelegate, FSCalendarDataSource
{

    @IBOutlet weak var sessionBtnName: UIButton!
    @IBOutlet weak var mothLbl: UILabel!
    @IBOutlet weak var sessionView: UIView!
    @IBOutlet weak var SelectionDateFullView: UIView!
    @IBOutlet weak var mothView: UIView!
    @IBOutlet weak var selectDateView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dimmingButton: UIButton!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var calanderFulView: UIView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    @IBOutlet weak var calanderHeighnt: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var markAllButton: UIButton!

    var roomTitle: String = ""
    var roomSubtitle: String = ""
    var studentsdataDetails: [HostelStudentListData] = []
    var is_calander_open : Bool = false
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    var HostelSessionListDataDetails : [HostelSessionListData] = []
    let dropDown = DropDown()
    var sessionId : String?
    var academic_year_id : String?
    var hostelId : String?
    var roomId : String?
    var selectedDate : String?
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        GetSessionList()
        updateProgress()
        updateMonthLabel()
        
  let dateTap = UITapGestureRecognizer(target: self, action: #selector(Dateclick))
        selectDateView.addGestureRecognizer(dateTap)
  let seesionTap = UITapGestureRecognizer(target: self, action: #selector(SessionClikc))
    sessionView.addGestureRecognizer(seesionTap)
        bottomConstraint.constant = -1000
        dimmingButton.alpha = 0
        
        
    }

    @IBAction func CalanderDoneBtn(_ sender: UIButton) {
        calanderFulView.isHidden = true
        
        GetStudentList(roomId: roomId ?? "", academicYear: academic_year_id ?? "", date: selectedDate ?? "",sessionID: sessionId ?? "", hostelId: hostelId ?? "")
        
    }
    @IBAction func Dateclick(){
        is_calander_open.toggle()
        calanderFulView.isHidden = is_calander_open
        
    }
    @IBAction func SessionClikc(){
        dropDown.show()
    }
    
    func setupDropDowns() {
        // DropDown for Label One
        dropDown.dataSource = HostelSessionListDataDetails.compactMap{$0.name}
        dropDown.anchorView = sessionView
        dropDown.bottomOffset = CGPoint(x: -20, y: sessionView.bounds.height - 10)
        dropDown.width = sessionView.bounds.width
        dropDown.selectionAction = { [weak self] index, item in
            guard let self else { return }
            self.sessionBtnName.setTitle(item, for: .normal)
            self.sessionId = self.HostelSessionListDataDetails[index].id
            self.GetStudentList(roomId: self.roomId ?? "", academicYear: self.academic_year_id ?? "", date: getCurrentDateString(),sessionID: self.sessionId ?? "", hostelId: self.hostelId ?? "")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(
            withDuration: 0.3, delay: 0, options: .curveEaseOut,
            animations: {
                self.dimmingButton.alpha = 1.0
                self.bottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            }, completion: nil)
    }

    private func setupUI() {
        view.backgroundColor = .clear

        bottomSheetView.layer.cornerRadius = 32
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomSheetView.clipsToBounds = true

        closeButton.layer.cornerRadius = 18
        closeButton.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        closeButton.tintColor = .white

        titleLabel.text = roomTitle
        subtitleLabel.text = roomSubtitle
        markAllButton.layer.cornerRadius = 16

        let formatter = DateFormatter()
        formatter.dateFormat = DateOutPut.EE_MMM_dd_yyyy
        // current date string in dd-MM-yyyy
        let currentDateString = formatter.string(from: Date())
        dateLbl.text = currentDateString
        calanderFulView.layer.cornerRadius = 10
        calendar.delegate = self
        calendar.dataSource = self
        calendar.appearance.headerTitleColor = .systemBlue
        calendar.appearance.weekdayTextColor = .darkGray
        calendar.appearance.selectionColor = .primery
        calendar.appearance.todayColor = UIColor.primery.withAlphaComponent(0.6)
        calendar.placeholderType = .none
        calendar.headerHeight = 0
        calendar.allowsMultipleSelection = false
        calendar.scrollEnabled = false
        mothView.layer.cornerRadius = 10
        SelectionDateFullView.layer.cornerRadius = 10
    }

    private func setupTableView() {
        tableView.register(StudentAttendanceCell.self)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
    }

    private func updateProgress() {
        let markedCount = studentsdataDetails.filter { _ in 0 != 0 }.count
        let total = studentsdataDetails.count

        progressLabel.text = "\(markedCount)/\(total)"
        progressView.progress = total > 0 ? Float(markedCount) / Float(total) : 0
    }

//    private func updateMarkAllButton() {
//        let markedCount = students.filter { $0.state != 0 }.count
//        if markedCount == students.count {
//            markAllButton.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
//            markAllButton.setTitleColor(.lightGray, for: .normal)
//        } else {
//            markAllButton.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
//            markAllButton.setTitleColor(UIColor(white: 0.3, alpha: 1.0), for: .normal)
//        }
//    }

    @IBAction func closeTapped(_ sender: Any) {
        UIView.animate(
            withDuration: 0.3, delay: 0, options: .curveEaseIn,
            animations: {
                self.dimmingButton.alpha = 0.0
                self.bottomConstraint.constant = -1000
                self.view.layoutIfNeeded()
            }
        ) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }

    @IBAction func markAllTapped(_ sender: Any) {
//        for i in 0..<studentsdataDetails.count {
//            if studentsdataDetails[i].state == 0 {
//                studentsdataDetails[i].state = 1  // default to present if marking all
//            }
//        }
        tableView.reloadData()
        updateProgress()
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsdataDetails.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "StudentAttendanceCell", for: indexPath) as? StudentAttendanceCell
        else { return UITableViewCell() }
        var student = studentsdataDetails[indexPath.row]
       
        switch student.status{
        case "ABSENT" :
            student.is_select = false
        case  "PRESENT" :
            student.is_select = true
        default:
            student.is_select = nil
        }
        let inandoutdate = " out date : \(student.out_date ?? "") -   in date : \(student.in_date ?? "")"
        cell.configure(
            name: student.name ?? "", id: student.id ?? "", parentNum: student.primary_mobile ?? "", state: student.is_select ?? false,
            index: indexPath.row, reason: student.reason ?? "", out_pass_status: student.outpasss_status ?? "",outDateInDate : inandoutdate)
        cell.delegate = self
        return cell
    }

    
    func GetStudentList(roomId :String,academicYear:String,date:String,sessionID : String,hostelId : String) {
        APIService.shared.makeApi(url: ServiceUrl.hostel_attendance_students_for_hostel_attd, parameters: ["session_type_id":sessionID,"hostel_id" : hostelId,"room_id":roomId,"academic_year_id" : academicYear, "date" : date], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: false) {[self] (result: Result<HostelStudentListSuc,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    studentsdataDetails = Success.data ?? []
                    tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                   
                }
            }
        }
    }
    
    func GetSessionList() {
        APIService.shared.makeApi(url: ServiceUrl.hostel_attendance_session_types, parameters: [:], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: true) {[self] (result: Result<HostelSessionListSuc,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    HostelSessionListDataDetails = Success.data ?? []
                    setupDropDowns()
                    sessionId = Success.data?.first?.id ?? ""
                    GetStudentList(roomId: roomId ?? "", academicYear: academic_year_id ?? "", date: getCurrentDateString(),sessionID: sessionId ?? "" , hostelId: hostelId ?? "")
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                   
                }
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let filterFormatter = DateFormatter()
        filterFormatter.dateFormat = DateInputs.dd_MM_yyyy
        let showFormatter = DateFormatter()
        showFormatter.dateFormat = DateOutPut.EE_MMM_dd_yyyy
        let selectedDateForFilter = filterFormatter.string(from: date)
        let selectedDateForLabel = showFormatter.string(from: date)
        selectedDate = selectedDateForFilter
        dateLbl.text = selectedDateForLabel
        
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date(timeIntervalSince1970: 0) // very old date
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calanderHeighnt.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    @IBAction func nextMonthTapped(_ sender: UIButton) {
        moveCurrentPage(isNext: true)
    }
    
    @IBAction func prevMonthTapped(_ sender: UIButton) {
        moveCurrentPage(isNext: false)
    }
    
//    func moveCurrentPage(isNext: Bool) {
//        let current = calendar.currentPage
//        var dateComponents = DateComponents()
//        dateComponents.month = isNext ? 1 : -1
//        //let newDate = Calendar.current.date(byAdding: dateComponents, to: current)!
//        guard let newDate = Calendar.current.date(byAdding: dateComponents, to: current) else {  return }
//        calendar.setCurrentPage(newDate, animated: true)
//        updateMonthLabel()
//    }
    
    func moveCurrentPage(isNext: Bool) {
        let currentPage = calendar.currentPage

        var dateComponents = DateComponents()
        dateComponents.month = isNext ? 1 : -1

        guard let newDate = Calendar.current.date(byAdding: dateComponents, to: currentPage) else {
            return
        }

        // 1. Remove currently selected date (if any)
        if let selectedDate = calendar.selectedDate {
            calendar.deselect(selectedDate)
        }

        calendar.setCurrentPage(newDate, animated: true)

        // 2. If moved to the current month, select today
        let today = Date()
        if Calendar.current.isDate(newDate, equalTo: today, toGranularity: .month) {
            calendar.select(today)
            let showFormatter = DateFormatter()
                showFormatter.dateFormat = DateOutPut.EE_MMM_dd_yyyy
            let selectedDateForLabel = showFormatter.string(from: today)
            dateLbl.text = selectedDateForLabel
        }

        updateMonthLabel()
    }

    
    func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = DateInputs.MMMM_yyyy 
        mothLbl.text = formatter.string(from: calendar.currentPage)
        let date = calendar.currentPage
        guard let text = mothLbl.text else { return }
        // DateFormatter to read "MMMM yyyy"
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "MMMM yyyy"
        formatter2.locale = Locale(identifier: "en_US_POSIX")

//        if let date = formatter2.date(from: text) {
//
//            let calendar = Calendar.current
//
//            let month = String(calendar.component(.month, from: date))
//            let year  = String(calendar.component(.year, from: date))
//            self.month = month
//            self.year = year
//        }

    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0 {
            calendar.setScope(.week, animated: true)
        } else if velocity.y < 0 {
            calendar.setScope(.month, animated: true)
        }
    }
    
    
    // MARK: - StudentAttendanceCellDelegate
    func didTapPresent(for index: Int) {
        studentsdataDetails[index].is_select = true
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        updateProgress()
    }

    func didTapAbsent(for index: Int) {
        studentsdataDetails[index].is_select = false
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        updateProgress()
    }
}
