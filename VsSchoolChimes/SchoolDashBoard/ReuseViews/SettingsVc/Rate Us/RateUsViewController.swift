//
//  RateUsViewController.swift
//  VoiceSnap
//
//  Created by Chandhru veeramalai on 05/11/24.
//

import UIKit
import StoreKit

protocol RatingDelegate: AnyObject {
    func rating(_ ratingcount: Int)
    func Submit(_ category: Set<String>, suggessions: String)
}

class RateUsViewController: UIViewController {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var tableview: UITableView!

    var isSelected: Bool = false
    var passValue = 1
    var submit: Bool? = false

    weak var delegate: ViewAttachments?

    private var selectedRating = 0
    private var descriptionContent = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerKeyboardNotifications()
        getReview()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        tableview.register(UINib(nibName: CellConfingName.BanerTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.BanerTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.RatingTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.RatingTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.RatingTypeTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.RatingTypeTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.SuccesseRatusTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.SuccesseRatusTVC)

        tableview.delegate = self
        tableview.dataSource = self
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 100
    }

    // MARK: - Keyboard Handler
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom()
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        tableview.contentInset = .zero
        tableview.scrollIndicatorInsets = .zero
    }

    private func scrollToBottom() {
        tableview.layoutIfNeeded()

        let lastSection = tableview.numberOfSections - 1
        guard lastSection >= 0 else { return }

        let lastRow = tableview.numberOfRows(inSection: lastSection) - 1
        guard lastRow >= 0 else { return }

        let indexPath = IndexPath(row: lastRow, section: lastSection)
        tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

// MARK: - Rating Popup Callback
extension RateUsViewController: RatingDelegate {

    func rating(_ ratingcount: Int) {
        selectedRating = ratingcount
        let showSection3 = ratingcount > 0
        let previousValue = isSelected
        isSelected = showSection3

        tableview.beginUpdates()
        if !previousValue && showSection3 {
            tableview.insertSections(IndexSet(integer: 2), with: .fade)
        } else if previousValue && !showSection3 {
            tableview.deleteSections(IndexSet(integer: 2), with: .fade)
        }
        tableview.endUpdates()
        delegate?.viewAttachment(sender: UIButton())
    }

    func Submit(_ category: Set<String>, suggessions: String) {
        print("📌 Selected Issue Types:", category)
        print("📝 Description:", suggessions)

        submit = true
        isSelected = false
        saveRatingToBackend(rating: selectedRating, description: suggessions)
        tableview.reloadData()
        delegate?.viewAttachment(sender: UIButton())
    }

    func getReview() {
        let mobile = UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? ""

        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_reviews_list,
            parameters: ["mobile_number": mobile],
            type: ApitTypeSringFile.GET,
            token: ""
        ) { [weak self] (result: Result<ReviewResponse, Error>) in

            guard let self = self else { return }

            switch result {
            case .success(let response):
                DispatchQueue.main.async {

                    if let reviewData = response.data?.first {

                        self.descriptionContent = reviewData.description ?? ""
                        self.selectedRating = reviewData.rating ?? 0
                        self.tableview.beginUpdates()
                        if let ratingCell = self.tableview.cellForRow(at: IndexPath(row: 0, section: 1)) as? RatingTableViewCell {
                            ratingCell.updateRating(self.selectedRating)
                        }

                        if self.descriptionContent != "" && self.tableview.numberOfSections == 2 {
                            self.isSelected = true
                            self.tableview.insertSections(IndexSet(integer: 2), with: .fade)
                        }
                        if let descriptionCell = self.tableview.cellForRow(at: IndexPath(row: 0, section: 2)) as? RatingTypeTableViewCell {
                            descriptionCell.suggestContetTxtView.text = self.descriptionContent
                        }
                        self.tableview.endUpdates()
                        self.delegate?.viewAttachment(sender: UIButton())
                    }
                }

            case .failure(let error):
                print("❌ API error:", error.localizedDescription)
            }
        }
    }

}

// MARK: - Backend API
extension RateUsViewController {

    func saveRatingToBackend(rating: Int, description: String?) {

        let mobile = UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? ""

        let params: [String: Any] = [
            "mobile_number": mobile,
            "rating": rating,
            "description": description ?? ""
        ]

        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_reviews_add,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: ""
        ) { [weak self] (result: Result<ValidateOTPSuc, Error>) in

            guard let self = self else { return }

            switch result {
            case .success(_):
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if self.selectedRating >= 4 {
                        self.redirectToAppStoreWriteReview()
                    }
                    self.dismiss(animated: true)
                    self.delegate?.dismiss(true)
                }

            case .failure(let error):
                print("❌ API error:", error.localizedDescription)
            }
        }
    }

    func redirectToAppStoreWriteReview() {
        let appId = "700513732"
        if let url = URL(string: "https://apps.apple.com/app/id\(appId)?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - TableView Delegates
extension RateUsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return submit == true ? 1 : (isSelected ? 3 : 2)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if submit == true {
            return tableview.dequeueReusableCell(withIdentifier: CellConfingName.SuccesseRatusTVC, for: indexPath)
        }

        switch indexPath.section {
        case 0:
            return tableview.dequeueReusableCell(withIdentifier: CellConfingName.BanerTableViewCell, for: indexPath)

        case 1:
            let cell = tableview.dequeueReusableCell(withIdentifier: CellConfingName.RatingTableViewCell, for: indexPath) as! RatingTableViewCell
            cell.RatingDelegate = self
            cell.updateRating(selectedRating)
            return cell

        case 2:
            let cell = tableview.dequeueReusableCell(withIdentifier: CellConfingName.RatingTypeTableViewCell, for: indexPath) as! RatingTypeTableViewCell
            cell.ratingDelegate = self
            cell.suggestContetTxtView.text = descriptionContent
            return cell

        default:
            return UITableViewCell()
        }
    }
}
