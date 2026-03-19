import UIKit

struct OutpassRequest {
    let name: String
    let room: String
    let destination: String
    let description: String?
    let outDate: String?
    let returnDate: String?
    let status: String  // "Pending", "Approved", "Rejected"
}

class OutpassRequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var dimmingButton: UIButton!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var newRequestButton: UIButton!

    @IBOutlet weak var tableView: UITableView!

    var requests: [OutpassRequest] = [
        OutpassRequest(
            name: "Aarav Sharma", room: "Room 101", destination: "Library", description: "Study",
            outDate: "Mar 5 at 10:00 AM", returnDate: "Mar 5 at 12:00 PM", status: "Pending"),
        OutpassRequest(
            name: "Ishaan Roy", room: "Room 108", destination: "Cafeteria", description: nil,
            outDate: nil, returnDate: nil, status: "Approved"),
        OutpassRequest(
            name: "Myra Kapoor", room: "Room 105", destination: "Home", description: "Family event",
            outDate: nil, returnDate: nil, status: "Rejected"),
    ]

    var pendingRequests: [OutpassRequest] {
        requests.filter { $0.status.lowercased() == "pending" }
    }
    var approvedRequests: [OutpassRequest] {
        requests.filter { $0.status.lowercased() == "approved" }
    }
    var rejectedRequests: [OutpassRequest] {
        requests.filter { $0.status.lowercased() == "rejected" }
    }

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
        
        print("OUT PASS REQUESTS", requests)
        setupUI()
        setupTableView()

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

        let request: OutpassRequest
        if indexPath.section == 0 {
            request = pendingRequests[indexPath.row]
        } else if indexPath.section == 1 {
            request = approvedRequests[indexPath.row]
        } else {
            request = rejectedRequests[indexPath.row]
        }

        cell.configure(
            name: request.name, room: request.room, status: request.status,
            dest: request.destination, desc: request.description, outDate: request.outDate,
            returnDate: request.returnDate)

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
}
