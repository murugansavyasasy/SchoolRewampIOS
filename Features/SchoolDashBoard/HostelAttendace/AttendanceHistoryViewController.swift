import UIKit

struct AttendanceHistory {
    let dateStr: String
    let year: String
    let pct: String
    let isUp: Bool
    let totalStudents: String
    let present: String
    let absent: String
    let roomsMarkedText: String
    let roomsMarkedProgress: Float
}

class AttendanceHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var dimmingButton: UIButton!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    let historyData: [AttendanceHistory] = [
        AttendanceHistory(
            dateStr: "Tuesday, Mar 3", year: "2026", pct: "91%", isUp: true, totalStudents: "23",
            present: "21", absent: "2", roomsMarkedText: "6/8", roomsMarkedProgress: 0.75),
        AttendanceHistory(
            dateStr: "Monday, Mar 2", year: "2026", pct: "87%", isUp: true, totalStudents: "23",
            present: "20", absent: "3", roomsMarkedText: "8/8", roomsMarkedProgress: 1.0),
        AttendanceHistory(
            dateStr: "Sunday, Mar 1", year: "2026", pct: "83%", isUp: false, totalStudents: "23",
            present: "19", absent: "4", roomsMarkedText: "8/8", roomsMarkedProgress: 1.0),
    ]

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
        print("historyDatahistoryData",historyData)
        setupUI()
        setupTableView()

        bottomConstraint.constant = -800
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
    }

    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 240
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)

        // Top corners rounded on bottom sheet instead
        tableView.layer.cornerRadius = 0
        tableView.layer.maskedCorners = []

        let nib = UINib(nibName: "AttendanceHistoryCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "AttendanceHistoryCell")
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

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "AttendanceHistoryCell", for: indexPath) as? AttendanceHistoryCell
        else {
            return UITableViewCell()
        }
        let data = historyData[indexPath.row]
        cell.configure(
            date: data.dateStr, year: data.year, pct: data.pct, isUp: data.isUp,
            total: data.totalStudents, present: data.present, absent: data.absent,
            rooms: data.roomsMarkedText, progress: data.roomsMarkedProgress)
        return cell
    }
}
