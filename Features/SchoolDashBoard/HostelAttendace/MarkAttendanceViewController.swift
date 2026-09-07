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
    func outPassApproval(for index: Int) {
        alert.showAlertCancel(
            title: AlertstringFile.Confirm_title,
            message: "Are you sure want to approval outpass?".translated(),
            actionLbl1:  AlertstringFile.Yes_Send,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: {
                self.updateStatus(id: self.studentsdataDetails[index].id ?? "", status: true)
            },
            onNo: {
                
            }
        )
    }
    
    func outPassReject(for index: Int) {
        alert.showAlertCancel(
            title: AlertstringFile.Confirm_title,
            message: "Are you sure want to reject outpass?".translated(),
            actionLbl1:  AlertstringFile.Yes_Send,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: {
                self.updateStatus(id: self.studentsdataDetails[index].id ?? "", status: false)
            },
            onNo: {
                
            }
        )
    }
    


    @IBOutlet weak var SelectDateBtn: UIButton!
    @IBOutlet weak var arrowImageView: UIImageView!
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
    var total_beds : Int?
    let alert = CustomAlert()
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
        SelectionDateFullView.addGestureRecognizer(dateTap)
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
        selectedDate = getCurrentDateString()
        bottomSheetView.layer.cornerRadius = 32
        arrowImageView.layer.cornerRadius = 15
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomSheetView.clipsToBounds = true

        closeButton.layer.cornerRadius = 18
        closeButton.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        closeButton.tintColor = .white

        titleLabel.text = roomTitle
        subtitleLabel.text = roomSubtitle
        markAllButton.layer.cornerRadius = 16
      
        let formatter = DateFormatter()
        formatter.locale = LocaleManager.shared.apiLocale
        formatter.dateFormat = DateOutPut.EE_MMM_dd_yyyy
        // current date string in dd-MM-yyyy
        let currentDateString = formatter.string(from: Date())
        dateLbl.text = currentDateString
        calanderFulView.layer.cornerRadius = 10
        calendar.delegate = self
        calendar.dataSource = self
        calendar.locale = LocaleManager.shared.apiLocale
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
        markAllButton.setTitle("Mark Attendance".translated(), for: .normal)
        SelectDateBtn.setTitle("Select Date".translated(), for: .normal)
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
        let markedCount = studentsdataDetails.filter {
            $0.is_select == "1"
        }.count

        let total = studentsdataDetails.count

        progressLabel.text = "\(markedCount)/\(total)"
        progressView.progress = total == 0 ? 0 : Float(markedCount) / Float(total)
    }


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
        alert.showAlertCancel(
            title: AlertstringFile.Confirm_title,
            message: AlertstringFile.Are_you_sure_want_to_submit,
            actionLbl1:  AlertstringFile.Yes_Send,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: {
                self.MarkAttendace()
            },
            onNo: {
                
            }
        )
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
        let student = studentsdataDetails[indexPath.row]
       
        var state = ""

        if student.is_select == "2" {
            state = "2"
        } else if student.is_select == "1" {
            state = "1"
        } else {
            if student.status?.uppercased() == "PRESENT" {
                state = "2"
            } else if student.status?.uppercased() == "ABSENT" {
                state = "1"
            } else {
                state = "0"
            }
        }
        let inandoutdate = "\("out date :".translated()) \(student.out_date ?? "")"
        cell.indateLbl.text = "\("in date :".translated()) \(student.in_date ?? "")"
        cell.configure(
            name: student.name ?? "",
            id: student.id ?? "",
            parentNum: student.primary_mobile ?? "",
            state: state,
            index: indexPath.row,
            reason: student.reason ?? "",
            out_pass_status: student.outpasss_status ?? "",
            outDateInDate: inandoutdate, outpass_id: student.outpass_id ?? "",
            standard: (student.class_name ?? "") + " - " + (student.section_name ?? "")
        )
        
        cell.absentButton.tag = indexPath.row
        cell.presentButton.tag = indexPath.row
        cell.outpassApproveBtnName.tag = indexPath.row
        cell.OutPassRejectBtnName.tag = indexPath.row
        cell.delegate = self
        return cell
    }

    
    func GetStudentList(roomId :String,academicYear:String,date:String,sessionID : String,hostelId : String) {
        APIService.shared.makeApi(url: ServiceUrl.hostel_attendance_students_for_hostel_attd, parameters: ["session_type_id":sessionID,"hostel_id" : hostelId,"room_id":roomId,"academic_year_id" : academicYear, "date" : date], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: true) {[self] (result: Result<HostelStudentListSuc,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
        
                    if Success.status ?? false{
//                        noRecordStack.isHidden = true
                        tableView.isHidden = false
                        studentsdataDetails = Success.data ?? []
                        for i in studentsdataDetails.indices {
                            let status = studentsdataDetails[i].status?.uppercased()
                            
                            if status == "PRESENT" {
                                studentsdataDetails[i].is_select = "2"
                            } else if status == "ABSENT" {
                                studentsdataDetails[i].is_select = "1"
                            } else {
                                studentsdataDetails[i].is_select = ""
                            }
                        }
                   
                        subtitleLabel.text =   "\(Success.data?.count ?? 0) \("Students".translated()) • \(total_beds ?? 0) \("Beds".translated())"
                        tableView.reloadData()
                        updateProgress()
                        
                    }else{
                        
//                        noRecordStack.isHidden = false
//                        noRecordLbl.text = Success.message ?? ""
//                        noRecordLbl.isHidden  = false
//                        noRecordImage.isHidden = false
                        tableView.isHidden = true
                    }
                   
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
//                    noRecordStack.isHidden = false
//                    noRecordLbl.text = error.localizedDescription
//                    noRecordLbl.isHidden  = false
//                    noRecordImage.isHidden = false
                    tableView.isHidden = true
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
                   sessionBtnName.setTitle(Success.data?.first?.name ?? "", for: .normal)
                    GetStudentList(roomId: roomId ?? "", academicYear: academic_year_id ?? "", date: getCurrentDateString(),sessionID: sessionId ?? "" , hostelId: hostelId ?? "")
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                   
                    
                }
            }
        }
    }
    
    func MarkAttendace() {
        
        let studentDetailsArray: [[String: Any]] = studentsdataDetails.compactMap { student in
            
            guard let id = student.id else { return nil }
            
            let status: String
            if student.is_select == "2" {
                status = "PRESENT"
            } else if student.is_select == "1" {
                status = "ABSENT"
            } else {
                status = student.status?.uppercased() ?? "ABSENT"
            }
            
            return [
                "student_id": id,
                "status": status
            ]
        }
        
        APIService.shared.makeApi(url: ServiceUrl.hostel_attendance_mark_attendance, parameters: ["hostel_id" : hostelId ?? "" , "session_type_id" : Int(sessionId ?? "0") ?? 0, "attendance_date" : selectedDate ?? "", "room_id"  : roomId ?? "","academic_year_id" : academic_year_id ?? "","student_details" : studentDetailsArray], type: ApitTypeSringFile.POST, token: StaffDetails?.access_token ?? "", isBaseUrl: true) {[self] (result: Result<HostelSessionListSuc,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    if Success.status ?? false {
                        CustomAlert
                            .showAlertWithOkAction(
                                title: AlertstringFile.Success,
                                message: Success.message ?? "" ,
                                on: self) {
                                    self.dismiss(animated: true)
                                }
                            
                    }else{
                        self.alert
                            .showAlert(
                                title: AlertstringFile.Oops,
                                message: Success.message ?? "" ,
                                on: self
                            )
                    }
                    
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    self.alert
                        .showAlert(
                            title: AlertstringFile.Oops,
                            message: error.localizedDescription ,
                            on: self
                        )
                }
            }
        }
    }
    
    func updateStatus(id : String,status : Bool) {
        APIService.shared.makeApi(url: ServiceUrl.hostel_attendance_update_status, parameters: ["id" : id , "is_approve" : status ], type: ApitTypeSringFile.PUT, token: StaffDetails?.access_token ?? "", isBaseUrl: true) {[self] (result: Result<CommonApiSuc,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    if Success.status ?? false{
                        self.alert
                            .showAlert(
                                title: AlertstringFile.Success,
                                message: Success.message ?? "" ,
                                on: self
                            )
                        

                    }else{
                        self.alert
                            .showAlert(
                                title: AlertstringFile.Oops,
                                message: Success.message ?? "" ,
                                on: self
                            )
                    }
                   
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    self.alert
                        .showAlert(
                            title: AlertstringFile.Oops,
                            message: error.localizedDescription ,
                            on: self
                        )
                }
            }
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let filterFormatter = DateFormatter()
        filterFormatter.locale = LocaleManager.shared.apiLocale
        filterFormatter.dateFormat = DateInputs.dd_MM_yyyy
        let showFormatter = DateFormatter()
        showFormatter.locale = LocaleManager.shared.apiLocale
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
                showFormatter.locale = LocaleManager.shared.apiLocale
                showFormatter.dateFormat = DateOutPut.EE_MMM_dd_yyyy
            let selectedDateForLabel = showFormatter.string(from: today)
            dateLbl.text = selectedDateForLabel
        }

        updateMonthLabel()
    }

    
    func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.locale = LocaleManager.shared.apiLocale
        formatter.dateFormat = DateInputs.MMMM_yyyy
        mothLbl.text = formatter.string(from: calendar.currentPage)
        let date = calendar.currentPage
        guard let text = mothLbl.text else { return }
        // DateFormatter to read "MMMM yyyy"
        let formatter2 = DateFormatter()
        formatter2.locale = LocaleManager.shared.apiLocale
        formatter2.dateFormat = "MMMM yyyy"
        formatter2.locale = Locale(identifier: "en_US_POSIX")

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
        studentsdataDetails[index].is_select = "2"
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        updateProgress()
    }

    func didTapAbsent(for index: Int) {
        studentsdataDetails[index].is_select = "1"
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        updateProgress()
    }
}
