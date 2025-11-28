//
//  RateUsViewController.swift
//  VsSchoolChimes
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
    var submit: Bool = false
    weak var delegate: ViewAttachments?
    private var selectedRating = 0
    private var descriptionContent = ""
    var categorySections: [CategoriesSection]?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerKeyboardNotifications()
        setupRatingCategories()
        getReview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    private func setupRatingCategories() {
        categorySections = [
            CategoriesSection(
                name: "What went wrong?",
                rating: 1,
                category: [
                    Categories(name: "Limited amenities", selected: false),
                    Categories(name: "Limited facilities", selected: false),
                    Categories(name: "Unmaintained facilities", selected: false),
                    Categories(name: "Irrelevant curriculum", selected: false),
                    Categories(name: "Inexperienced", selected: false),
                    Categories(name: "Extra fees", selected: false)
                ]
            ),
            CategoriesSection(
                name: "What went wrong?",
                rating: 2,
                category: [
                    Categories(name: "Inadequate security", selected: false),
                    Categories(name: "Unmaintained facilities", selected: false),
                    Categories(name: "Limited facilities", selected: false),
                    Categories(name: "Less/No evaluation", selected: false),
                    Categories(name: "Extra fees", selected: false),
                    Categories(name: "Not specialised", selected: false)
                ]
            ),
            CategoriesSection(
                name: "What did you like and dislike?",
                rating: 3,
                category: [
                    Categories(name: "AC classrooms", selected: false),
                    Categories(name: "Cafeteria", selected: false),
                    Categories(name: "Limited amenities", selected: false),
                    Categories(name: "Limited facilities", selected: false),
                    Categories(name: "Reasonably priced", selected: false),
                    Categories(name: "Highly priced", selected: false)
                ]
            ),
            CategoriesSection(
                name: "What did you like and dislike?",
                rating: 4,
                category: [
                    Categories(name: "AC classrooms", selected: false),
                    Categories(name: "Multiple facilities", selected: false),
                    Categories(name: "Limited amenities", selected: false),
                    Categories(name: "Limited facilities", selected: false),
                    Categories(name: "Reasonable fees", selected: false),
                    Categories(name: "High fee structure", selected: false)
                ]
            ),
            CategoriesSection(
                name: "What did you love?",
                rating: 5,
                category: [
                    Categories(name: "Resourceful library", selected: false),
                    Categories(name: "Sports", selected: false),
                    Categories(name: "Relevant curriculum", selected: false),
                    Categories(name: "Adequate security", selected: false),
                    Categories(name: "Expert faculty", selected: false),
                    Categories(name: "Reasonable fees", selected: false)
                ]
            )
        ]
    }
    
    // MARK: - UI SETUP
    private func setupUI() {
        tableview.showsHorizontalScrollIndicator = false
        tableview.showsVerticalScrollIndicator = false
        tableview.register(UINib(nibName: CellConfingName.BanerTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.BanerTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.RatingTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.RatingTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.RatingTypeTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.RatingTypeTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.SuccesseRatusTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.SuccesseRatusTVC)
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    // MARK: - KEYBOARD
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom()
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        tableview.contentInset = .zero
        tableview.scrollIndicatorInsets = .zero
    }
    
    private func scrollToBottom() {
        guard tableview.numberOfSections > 0 else { return }
        let lastSection = tableview.numberOfSections - 1
        guard tableview.numberOfRows(inSection: lastSection) > 0 else { return }
        let lastRow = tableview.numberOfRows(inSection: lastSection) - 1
        tableview.scrollToRow(at: IndexPath(row: lastRow, section: lastSection), at: .bottom, animated: true)
    }
}


// MARK: - Rating Delegate
extension RateUsViewController: RatingDelegate {
    func rating(_ ratingcount: Int) {
        selectedRating = ratingcount
        isSelected = ratingcount > 0
        tableview.reloadData()
        delegate?.viewAttachment(sender: UIButton())
    }
    
    func Submit(_ category: Set<String>, suggessions: String) {
        submit = true
        isSelected = false
        
        saveRatingToBackend(rating: selectedRating, description: suggessions)
        tableview.reloadData()
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
                    if let review = response.data?.first {
                        self.descriptionContent = review.description ?? ""
                        self.selectedRating = review.rating ?? 0
                        self.isSelected = self.selectedRating > 0
                        self.tableview.reloadData()
                        self.tableview.layoutIfNeeded()
                        UIView.performWithoutAnimation {
                            self.tableview.beginUpdates()
                            self.tableview.endUpdates()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.delegate?.viewAttachment(sender: UIButton())
                        }
                    }
                }
                
                
            case .failure(let error):
                print("API error: \(error.localizedDescription)")
            }
        }
    }
}


// MARK: - BACKEND
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
                print("API error: \(error.localizedDescription)")
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

// MARK: - TABLEVIEW
extension RateUsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return submit ? 1 : (isSelected ? 3 : 2)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if submit {
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
            let filtered = categorySections?.filter { $0.rating == selectedRating }
            cell.configure(names: filtered?.first)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
