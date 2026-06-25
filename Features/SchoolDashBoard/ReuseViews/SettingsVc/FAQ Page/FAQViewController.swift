//
//  FAQViewController.swift
//  SchoolchimesDemo
//
//  Created by Admin on 05/11/24.
//

import UIKit

class FAQViewController: UIViewController {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var outerView: UIView!
    
    var selectedIndexPath: IndexPath?
    var qaList: [SchoolQA]?
    var passValue = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup back button direction & style
        let language = UserDefaults.standard.string(forKey: DefaultsKeys.Language)
//        BackBtn.semanticContentAttribute = language == "ar" ? .forceRightToLeft : .forceLeftToRight
//        BackBtn.contentHorizontalAlignment = language == "ar" ? .right : .left
//        BackBtn.imageView?.applyRTLFlip(language == "ar")
        BackBtn.setTitle(MenuTapbar.shared.FAQ, for: .normal)
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        
        // Register tableview cell
        let nib = UINib(nibName: CellConfingName.FAQTableViewCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.FAQTableViewCell)
        tableview.dataSource = self
        tableview.delegate = self
        tableview.tableFooterView = UIView()
        
        // Load FAQs
        Getfaq()
    }
    
    func Getfaq() {
        if #available(iOS 15.0, *) { showActivityLoader() }
        let token = passValue == 2
            ? (UserDefaultFileManager.get_child_Details()?.access_token ?? "")
            : (UserDefaultFileManager.get_staff_Details()?.access_token ?? "")
        
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_dashboard_faqs,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: token, isBaseUrl: false
        ) { [weak self] (result: Result<FAQResponse, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) { self?.hideActivityLoader() }
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    self.qaList = response.data ?? []
                    self.tableview.reloadData()
                case .failure(let error):
                    print("FAQ fetch error:", error.localizedDescription)
                }
            }
        }
    }
    

    @IBAction func SubmitBtnAction(_ sender: Any) {
        // Add your submit logic here
    }
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: - TableView Delegate & DataSource
extension FAQViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return qaList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellConfingName.FAQTableViewCell,
            for: indexPath
        ) as! FAQTableViewCell
        
        let item = qaList?[indexPath.row]
        cell.configure(
            question: item?.question,
            answers: item?.answer,
            isSelected: selectedIndexPath == indexPath
        )
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var reloadPaths: [IndexPath] = []
        if let selected = selectedIndexPath {
            reloadPaths.append(selected)
        }
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil // collapse
        } else {
            selectedIndexPath = indexPath // expand
            reloadPaths.append(indexPath)
        }
        tableView.reloadRows(at: reloadPaths, with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


