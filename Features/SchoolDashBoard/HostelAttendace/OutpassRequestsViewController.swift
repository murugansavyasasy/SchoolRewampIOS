import UIKit



class OutpassRequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, approvalBtnclick {
    func approvalClikc(index: Int) {
        
        alert.showAlertCancel(
            title: AlertstringFile.Confirm_title,
            message: AlertstringFile.Are_you_sure_want_to_submit,
            actionLbl1:  AlertstringFile.Yes_Send,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: {
                self.updateStatus(id:self.pendingRequests[index].id ?? "" , status: true)
            },
            onNo: {
                
            }
        )
    }
    
    func rejectClick(index: Int) {
        
        alert.showAlertCancel(
            title: AlertstringFile.Confirm_title,
            message: AlertstringFile.Are_you_sure_want_to_submit,
            actionLbl1:  AlertstringFile.Yes_Send,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: {
                self.updateStatus(id:self.pendingRequests[index].id ?? "" , status: false)
            },
            onNo: {
                
            }
        )
    }
    
    @IBOutlet weak var norecordLbl: UILabel!
    @IBOutlet weak var norecordImage: UIImageView!
    @IBOutlet weak var dimmingButton: UIButton!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var newRequestButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var StaffDetails = UserDefaultFileManager.get_staff_Details()
    var outpassDataDetails : [OutpassSection] = []
    var pendingRequests : [OutpassStudent] = []
    var approvedRequests : [OutpassStudent] = []
    var rejectedRequests : [OutpassStudent] = []
    var hostelId : String = ""
    var accidemicyearId : String = ""
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
        GetOutPassReport(hostelId : hostelId,academicYearId : accidemicyearId)
        bottomConstraint.constant = -1000
        dimmingButton.alpha = 0
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

        newRequestButton.layer.cornerRadius = 12
        newRequestButton.backgroundColor = .white
    }

    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 220
        tableView.register(OutpassRequestCell.self)
    }

    @IBAction func closeTapped(_ sender: Any) {
        dismissWithAnimation()
    }

    @IBAction func dimmingTapped(_ sender: Any) {
        dismissWithAnimation()
    }

    private func dismissWithAnimation() {
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

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return pendingRequests.count }
        if section == 1 { return approvedRequests.count }
        return rejectedRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "OutpassRequestCell", for: indexPath) as? OutpassRequestCell
        else { return UITableViewCell() }

        let request: OutpassStudent
        if indexPath.section == 0 {
            request = pendingRequests[indexPath.row]
        } else if indexPath.section == 1 {
            request = approvedRequests[indexPath.row]
        } else {
            request = rejectedRequests[indexPath.row]
        }

        cell.configure(
            name: request.student_name ?? "", room: request.room_no ?? "", status: request.status ?? "",
            dest: request.reason ?? "", desc: request.reason ?? "", outDate: request.out_date ?? "",
            returnDate: request.in_date ?? "")
        cell.approvelAndReject = self
        cell.approveButton.tag = indexPath.row
        cell.rejectButton.tag = indexPath.row
        return cell
    }

    // MARK: - Headers
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var count = 0
        if section == 0 {
            count = pendingRequests.count
        } else if section == 1 {
            count = approvedRequests.count
        } else {
            count = rejectedRequests.count
        }

        if count == 0 { return nil }

        let headerView = UIView()
        headerView.backgroundColor = .white

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)

        if section == 0 {
            iconView.image = UIImage(systemName: "clock")
            iconView.tintColor = UIColor(red: 0.94, green: 0.55, blue: 0.03, alpha: 1.0)
            titleLabel.text = "Pending Approval (\(count))"
            titleLabel.textColor = UIColor(red: 0.94, green: 0.55, blue: 0.03, alpha: 1.0)
        } else if section == 1 {
            iconView.image = UIImage(systemName: "checkmark.circle")
            iconView.tintColor = UIColor(red: 0.0, green: 0.75, blue: 0.4, alpha: 1.0)
            titleLabel.text = "Approved (\(count))"
            titleLabel.textColor = UIColor(red: 0.0, green: 0.75, blue: 0.4, alpha: 1.0)
        } else {
            iconView.image = UIImage(systemName: "xmark.circle")
            iconView.tintColor = UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1.0)
            titleLabel.text = "Rejected (\(count))"
            titleLabel.textColor = UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1.0)
        }

        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)

        headerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            stackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
        ])

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && pendingRequests.isEmpty { return 0 }
        if section == 1 && approvedRequests.isEmpty { return 0 }
        if section == 2 && rejectedRequests.isEmpty { return 0 }
        return 50
    }
    
    func GetOutPassReport(hostelId : String,academicYearId : String) {
        APIService.shared.makeApi(url: ServiceUrl.hostel_attendance_outpass_report, parameters: ["year_id" : String(getCurrentYear()) , "month_id" : String(getCurrentMonth()),"hostel_id" : hostelId,"academic_year_id": academicYearId], type: ApitTypeSringFile.GET, token: StaffDetails?.access_token ?? "", isBaseUrl: false) {[self] (result: Result<OutpassResponseSuc,Error>) in
            switch result{
            case .success(let Success):
                DispatchQueue.main.async {[self] in
                    if Success.status{
                        outpassDataDetails = Success.data
                        norecordLbl.isHidden = true
                        norecordImage.isHidden = true
                        tableView.isHidden = false
                        pendingRequests = outpassDataDetails
                            .filter { $0.status?.lowercased() == "pending" }
                            .flatMap { $0.attd_details ?? [] }

                        approvedRequests = outpassDataDetails
                            .filter { $0.status?.lowercased() == "approved" || $0.status?.lowercased() == "approval" }
                            .flatMap { $0.attd_details ?? [] }

                        rejectedRequests = outpassDataDetails
                            .filter { $0.status?.lowercased() == "rejected" }
                            .flatMap { $0.attd_details ?? [] }
                        tableView.reloadData()
                    }else{
                        norecordLbl.isHidden = false
                        norecordImage.isHidden = false
                        tableView.isHidden = true
                        norecordLbl.text = Success.message
                    }
                   
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                   
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
                        
                        GetOutPassReport(hostelId : hostelId,academicYearId : accidemicyearId)
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
    func getCurrentMonth() -> Int {
        return Calendar.current.component(.month, from: Date())
    }
    func getCurrentYear() -> Int {
        return Calendar.current.component(.year, from: Date())
    }
}
