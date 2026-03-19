import UIKit

struct AdminRequest {
    let room: String
    let student: String
    let issue: String
    let dateStr: String
    let isResolved: Bool
}

class AdminRequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var dimmingButton: UIButton!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var newRequestButton: UIButton!
    @IBOutlet weak var formContainerView: UIView!
    @IBOutlet weak var formHeightConstraint: NSLayoutConstraint!  // Start at 0, open to ~250

    @IBOutlet weak var roomTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var tableView: UITableView!

    var requests: [AdminRequest] = [
        AdminRequest(
            room: "Room 101", student: "Aarav Sharma", issue: "Tap not working in bathroom",
            dateStr: "Mar 4, 10:30 AM", isResolved: false),
        AdminRequest(
            room: "Room 108", student: "Ishaan Roy", issue: "Light switch broken",
            dateStr: "Mar 3, 02:15 PM", isResolved: false),
        AdminRequest(
            room: "Room 105", student: "Myra Kapoor", issue: "Door lock issue",
            dateStr: "Mar 2, 09:00 AM", isResolved: true),
    ]

    var pendingRequests: [AdminRequest] { requests.filter { !$0.isResolved } }
    var resolvedRequests: [AdminRequest] { requests.filter { $0.isResolved } }

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
        closeButton.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        closeButton.tintColor = .darkGray

        newRequestButton.layer.cornerRadius = 12
        newRequestButton.backgroundColor = UIColor(red: 0.16, green: 0.39, blue: 0.98, alpha: 1.0)

        formContainerView.clipsToBounds = true
        formHeightConstraint.constant = 0  // Hide initially

        // Form styling
        roomTextField.layer.cornerRadius = 12
        roomTextField.layer.borderWidth = 1
        roomTextField.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor

        let paddingView = UIView(
            frame: CGRect(x: 0, y: 0, width: 16, height: roomTextField.frame.height))
        roomTextField.leftView = paddingView
        roomTextField.leftViewMode = .always

        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        descriptionTextView.textContainerInset = UIEdgeInsets(
            top: 12, left: 12, bottom: 12, right: 12)

        submitButton.layer.cornerRadius = 12
        cancelButton.layer.cornerRadius = 12
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
    }

    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120

        let nib = UINib(nibName: "RequestItemCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "RequestItemCell")
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

    @IBAction func newRequestTapped(_ sender: Any) {
        view.endEditing(true)

        let isOpening = formHeightConstraint.constant == 0

        UIView.animate(withDuration: 0.3) {
            self.formHeightConstraint.constant = isOpening ? 280 : 0
            self.newRequestButton.isHidden = isOpening
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func submitRequestTapped(_ sender: Any) {
        // Validate and insert
        guard let rm = roomTextField.text, !rm.isEmpty, let desc = descriptionTextView.text,
            !desc.isEmpty
        else { return }

        let newReq = AdminRequest(
            room: rm, student: "New Student", issue: desc, dateStr: "Just now", isResolved: false)
        requests.insert(newReq, at: 0)

        roomTextField.text = ""
        descriptionTextView.text = ""
        view.endEditing(true)

        tableView.reloadData()

        // Hide form
        UIView.animate(withDuration: 0.3) {
            self.formHeightConstraint.constant = 0
            self.newRequestButton.isHidden = false
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func cancelFormTapped(_ sender: Any) {
        view.endEditing(true)

        UIView.animate(withDuration: 0.3) {
            self.formHeightConstraint.constant = 0
            self.newRequestButton.isHidden = false
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? pendingRequests.count : resolvedRequests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "RequestItemCell", for: indexPath) as? RequestItemCell
        else { return UITableViewCell() }
        let request =
            indexPath.section == 0
            ? pendingRequests[indexPath.row] : resolvedRequests[indexPath.row]

        cell.configure(
            roomNum: request.room, studentName: request.student, issue: request.issue,
            date: request.dateStr, isResolved: request.isResolved)

        return cell
    }

    // MARK: - Headers
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 && pendingRequests.isEmpty { return nil }
        if section == 1 && resolvedRequests.isEmpty { return nil }

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
            titleLabel.text = "Pending (\(pendingRequests.count))"
            titleLabel.textColor = UIColor(red: 0.94, green: 0.55, blue: 0.03, alpha: 1.0)
        } else {
            iconView.image = UIImage(systemName: "checkmark.circle")
            iconView.tintColor = UIColor(red: 0.1, green: 0.65, blue: 0.3, alpha: 1.0)
            titleLabel.text = "Resolved (\(resolvedRequests.count))"
            titleLabel.textColor = UIColor(red: 0.1, green: 0.65, blue: 0.3, alpha: 1.0)
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
        if section == 1 && resolvedRequests.isEmpty { return 0 }
        return 50
    }
}
