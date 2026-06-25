//
//  RateUsViewController.swift
//  VsSchoolChimes
//  Created by Chandhru veeramalai on 05/11/24.
//

import UIKit
import StoreKit

protocol RatingDelegate: AnyObject {
    func rating(_ ratingcount: Int)
    func Submit(_ category: CategoriesSection )
}


class RateUsViewController: UIViewController {
    
    @IBOutlet weak var submitView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
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
        submitBtn.layer.cornerRadius = submitBtn.frame.height / 2
        submitBtn.setTitle("Submit".translated(), for: .normal)

        submitBtn.layer.shadowColor = UIColor.black.cgColor
        submitBtn.layer.shadowOpacity = 0.4
        submitBtn.layer.shadowOffset = CGSize(width: 0, height: 5)
        submitBtn.layer.shadowRadius = 8
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
        tableview.register(UINib(nibName: CellConfingName.TextviewTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.TextviewTVC)
        tableview.register(UINib(nibName: CellConfingName.RatingTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.RatingTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.RatingTypeTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.RatingTypeTableViewCell)
        tableview.register(UINib(nibName: CellConfingName.SuccesseRatusTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.SuccesseRatusTVC)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 100
    }
    override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            updatePreferredSize()
        }
    func updatePreferredSize() {
            self.view.layoutIfNeeded()

            let contentHeight = tableview.contentSize.height
            let maxHeight = UIScreen.main.bounds.height * 0.85
            let finalHeight = min(contentHeight, maxHeight)

            self.preferredContentSize = CGSize(
                width: self.view.frame.width,
                height: finalHeight
            )
        }

    // MARK: - KEYBOARD
    
    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               self.scrollToTextViewCell()
           }
       }
       
       @objc private func keyboardWillHide(notification: NSNotification) {
           tableview.contentInset = .zero
           tableview.scrollIndicatorInsets = .zero
       }
    
    private func scrollToTextViewCell() {
        guard tableview.numberOfSections > 0 else { return }
               let lastSection = tableview.numberOfSections - 1
               guard tableview.numberOfRows(inSection: lastSection) > 0 else { return }
               let lastRow = tableview.numberOfRows(inSection: lastSection) - 1
               tableview.scrollToRow(at: IndexPath(row: lastRow, section: lastSection), at: .bottom, animated: true)
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true)
        self.delegate?.dismiss(true)
    }
    @IBAction func submitBtn(_ sender: UIButton) {
        submit = true
        submitView.isHidden = true
        isSelected = false
        tableview.reloadData()
        DispatchQueue.main.async {
            self.delegate?.viewAttachment(sender: UIButton())
        }
        saveRatingToBackend(rating: selectedRating, description: descriptionContent)
        
    }
    
}


// MARK: - Rating Delegate
extension RateUsViewController: RatingDelegate,RatingTypeCellDelegate,UITextViewDelegate {
    func didUpdateHeight(_ set:Bool) {
        DispatchQueue.main.async {
            if set{
                self.tableview.beginUpdates()
                self.tableview.endUpdates()
            }
        }
    }
    func rating(_ ratingcount: Int) {
        selectedRating = ratingcount
        isSelected = ratingcount > 0
        tableview.reloadData()
        DispatchQueue.main.async {
            self.delegate?.viewAttachment(sender: UIButton())
        }
    }

    func Submit(_ category: CategoriesSection) {
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            UIView.performWithoutAnimation {
                                self.tableview.beginUpdates()
                                self.tableview.endUpdates()
                            }
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
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
        let appStoreId = NSLocalizedString("APP_STORE_ID", comment: "")
        if let url = URL(string: "https://apps.apple.com/app/id\(appStoreId)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - TABLEVIEW
extension RateUsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return submit ? 1 : 4
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
            cell.categorySections = categorySections
            cell.updateRating(selectedRating)
            return cell
            
        case 2:
            let cell = tableview.dequeueReusableCell(withIdentifier: CellConfingName.RatingTypeTableViewCell, for: indexPath) as! RatingTypeTableViewCell
            cell.ratingDelegate = self
            cell.heightDelegate = self
            
            let filtered = categorySections?.filter { $0.rating == selectedRating }
            cell.configure(names: filtered?.first, rating: selectedRating)
            return cell
        case 3:
            let cell = tableview.dequeueReusableCell(withIdentifier: CellConfingName.TextviewTVC, for: indexPath) as! TextviewTVC
            cell.suggestContetTxtView.text = descriptionContent
            cell.suggestContetTxtView.delegate = self
        return cell
        default:
            return UITableViewCell()
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        descriptionContent = textView.text
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
