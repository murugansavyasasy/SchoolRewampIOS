import UIKit

struct FlatSession {
    let roomId: String
    let totalSessionsInRoom: Int
    let session: AttendanceHistorySession
    let isFirstInRoom: Bool
}
class AttendanceHistoryViewController: UIViewController, Datepicker
{
    func date(date: String) {
        setInitialButtonTitles(date: date)
    }
    
    @IBOutlet weak var selectDateDefaultLbl: UILabel!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var DateFullView: UIView!
    @IBOutlet weak var dayLbl: UILabel!
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dateSelectionView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var dimmingButton: UIButton!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    private var flatSessions: [FlatSession] = []
    private var expandedSections: Set<Int> = []
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    var academicYearId : String?
    var dateString : String?
    var datas: [AttendanceHistoryData]?
    var hostelData : HostelListData?
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

    func setInitialButtonTitles(date dateString: String?, inputFormat: String = "dd MMM yyyy") {
        let savedCode = UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en"
        let localeID = normalizedLocaleIdentifier(for: savedCode)
        let locale = Locale(identifier: localeID)
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = inputFormat
        
        let dateToUse: Date
        if let dateString = dateString, let parsed = parser.date(from: dateString) {
            dateToUse = parsed
        } else {
            dateToUse = Date()
        }
        let displayDateFormatter = DateFormatter()
        displayDateFormatter.locale = locale
        displayDateFormatter.dateFormat = "dd MMM yyyy"
        
        let displayTimeFormatter = DateFormatter()
        displayTimeFormatter.locale = locale
        displayTimeFormatter.timeStyle = .short
        
        let dayFormatter = DateFormatter()
        dayFormatter.locale = locale
        dayFormatter.dateFormat = "EEEE"
        dateLbl.text = displayDateFormatter.string(from: dateToUse)
       
        dayLbl.text = dayFormatter.string(from: dateToUse)
        let date = convertDate(dateLbl?.text ?? "")
        GetAttendaceHistoryList(academicYear: academicYearId ?? "", date: date ?? "", hostelId: hostelData?.id ?? "")
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bottomConstraint.constant = -800
        dimmingButton.alpha = 0
        self.bottomSheetView.backgroundColor = UIColor(white: 0.96, alpha: 1)
        // Setup TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedSectionHeaderHeight = 0
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0
        
        // Registering native XIBs
        tableView.register(UINib(nibName: "AttendanceStudentCell", bundle: nil), forCellReuseIdentifier: "AttendanceStudentCell")
        tableView.register(UINib(nibName: "AttendanceSessionHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "AttendanceSessionHeader")
        setInitialButtonTitles(date:nil)
        GetAttendaceHistoryList(academicYear: academicYearId ?? "", date: getCurrentDateString(), hostelId:  hostelData?.id ?? "")
        
        let dateTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectDateTapped))
        dateSelectionView.isUserInteractionEnabled = true
        dateSelectionView.addGestureRecognizer(dateTapGesture)
    }
    @objc private func selectDateTapped() {
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.minimumDate = nil
        vc.maximumDate = Date()
        vc.date = dateLbl.text
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
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
        subtitleLabel.text = hostelData?.name ?? ""
        selectDateDefaultLbl.setRequiredText(selectDateDefaultLbl.text ?? "")
        bottomSheetView.layer.cornerRadius = 32
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomSheetView.clipsToBounds = true

        closeButton.layer.cornerRadius = 18
        closeButton.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        closeButton.tintColor = .white
        DateFullView.layer.cornerRadius = 18
        DateFullView.layer.borderColor = UIColor.lightGray.cgColor
        DateFullView.layer.borderWidth = 0.5
        dateBtn.layer.cornerRadius = 8
        dateBtn.backgroundColor = .blue.withAlphaComponent(0.6)
    }


    @IBAction func closeTapped(_ sender: Any) {
        UIView.animate(
            withDuration: 0.3, delay: 0, options: .curveEaseIn,
            animations: {
                self.dimmingButton.alpha = 0.0
                self.bottomConstraint.constant = -800
                self.view.layoutIfNeeded()
            }
        ) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }

}

extension AttendanceHistoryViewController : UITableViewDelegate, UITableViewDataSource,AttendanceSessionHeaderDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return flatSessions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard expandedSections.contains(section) else { return 0 }
        return flatSessions[section].session.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttendanceStudentCell", for: indexPath) as! AttendanceStudentCell
        let student = flatSessions[indexPath.section].session.students[indexPath.row]
        cell.configure(student: student)
        // Adjust card bottom corners if it's the last student
        let isLast = indexPath.row == (flatSessions[indexPath.section].session.students.count) - 1
        if isLast {
            cell.cardView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.cardView.layer.cornerRadius = 16
            cell.bottomSeparatorView.isHidden = true
        } else {
            cell.cardView.layer.cornerRadius = 0
            cell.bottomSeparatorView.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AttendanceSessionHeader") as! AttendanceSessionHeader
        let flatSession = flatSessions[section]
        let isExpanded = expandedSections.contains(section)
        // Pass room data only if we need to show the room title (i.e. first session in a room)
        let rId = flatSession.isFirstInRoom ? flatSession.roomId : nil
        let sCount = flatSession.isFirstInRoom ? flatSession.totalSessionsInRoom : nil
        
        header.configure(session: flatSession.session,
                         section: section,
                         isExpanded: isExpanded,
                         roomId: rId,
                         totalSessionsInRoom: sCount,totalsessions : datas?.first?.sessions.count ?? 0 )
        header.delegate = self
        
        return header
    }
    
    // Auto-calculate height because we use Stack View in AttendanceSessionHeader
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 280
    }
    
    // MARK: - Header Delegate
    func didTapToggleStudents(in section: Int) {
            tableView.beginUpdates()
            let count = flatSessions[section].session.students.count
            let indexPaths = (0..<count).map { IndexPath(row: $0, section: section) }
            if expandedSections.contains(section) {
                expandedSections.remove(section)
                tableView.deleteRows(at: indexPaths, with: .none)
            } else {
                expandedSections.insert(section)
                tableView.insertRows(at: indexPaths, with: .none)
            }
            tableView.endUpdates()
        }
    
    func GetAttendaceHistoryList(academicYear:String,date:String,hostelId : String) {
        APIService.shared.makeApi(url: ServiceUrl.comm_api_hostel_attendance_attendance_report, parameters: ["hostel_id" : hostelId,"academic_year_id" : academicYear, "date" : date], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: false) {[self] (result: Result<AttendanceHistoryResponse,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    // Flatten the nested Room -> Session architecture
                    var flattened: [FlatSession] = []
                    datas = Success.data
                    for room in Success.data {
                        for (index, session) in room.sessions.enumerated() {
                            let isFirst = (index == 0)
                            let flat = FlatSession(roomId: String(room.roomId),
                                                   totalSessionsInRoom: room.sessions.count,
                                                   session: session,
                                                   isFirstInRoom: isFirst)
                            flattened.append(flat)
                        }
                    }
                    
                    self.flatSessions = flattened
                    tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                   
                }
            }
        }
    }
}
