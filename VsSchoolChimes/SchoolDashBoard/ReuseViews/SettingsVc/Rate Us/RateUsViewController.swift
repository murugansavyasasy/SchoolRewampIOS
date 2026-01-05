//
//  RateUsViewController.swift
//  VsSchoolChimes
//  Created by Chandhru veeramalai on 05/11/24.
//

import UIKit
import StoreKit

protocol RatingDelegate: AnyObject {
    func rating(_ ratingcount: Int)
    func Submit(_ category: CategoriesSection, suggessions: String)
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
        getReview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
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
extension RateUsViewController: RatingDelegate,RatingTypeCellDelegate {
    func didUpdateHeight() {
        self.tableview.beginUpdates()
        self.tableview.endUpdates()
    }
    func rating(_ ratingcount: Int) {
        selectedRating = ratingcount
        isSelected = ratingcount > 0
        tableview.reloadData()
        DispatchQueue.main.async {
            self.delegate?.viewAttachment(sender: UIButton())
        }
    }

    func Submit(_ category: CategoriesSection, suggessions: String) {
        if let index = categorySections?.firstIndex(where: { $0.rating == category.rating }) {
            categorySections?[index] = category
            for i in 0..<(categorySections?.count ?? 0) {
                if i != index {
                    for j in 0..<(categorySections?[i].category?.count ?? 0) {
                        categorySections?[i].category?[j].selected = false
                    }
                }
            }
        }
        submit = true
        isSelected = false
        tableview.reloadData()
        delegate?.viewAttachment(sender: UIButton())
        saveRatingToBackend(rating: selectedRating, description: suggessions)
       
    }
    
    func getReview() {
        let mobile = UserDefaultFileManager.getLoginCredentials()?.mobile_number ?? ""
        
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_reviews_list,
            parameters: ["mobile_number": mobile],
            type: ApitTypeSringFile.GET,
            token: "", isBaseUrl: false
        ) { [weak self] (result: Result<ReviewResponse, Error>) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    if let review = response.data?.first {
                        self.descriptionContent = review.description ?? ""
                        self.selectedRating = review.rating ?? 0
                        self.isSelected = self.selectedRating > 0
                        self.categorySections = review.remarks
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
        
        let formattedCategories = categorySections?.map { section in
            return [
                "name": section.name ?? "",
                "rating": section.rating ?? 0,
                "category": section.category?.map { cat in
                    return [
                        "name": cat.name ?? "",
                        "selected": cat.selected ?? false
                    ]
                } ?? []
            ] as [String : Any]
        }

        let params: [String: Any] = [
            "mobile_number": mobile,
            "rating": rating,
            "description": description ?? "",
            "categories":formattedCategories ?? []
        ]
        
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_reviews_add,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: "", isBaseUrl: true
        ) { [weak self] (result: Result<ValidateOTPSuc, Error>) in
            
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
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
            cell.heightDelegate = self
            cell.suggestContetTxtView.text = descriptionContent
            let filtered = categorySections?.filter { $0.rating == selectedRating }
            cell.configure(names: filtered?.first, rating: selectedRating)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
