//
//  paymentProofVc.swift
//  School Chimes
//
//  Created by apple on 08/09/26.
//

import UIKit

class paymentProofVc: UIViewController {

    @IBOutlet weak var studentNameLbl: UILabel!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var nodataStackView: UIStackView!
    // MARK: - IBOutlets
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Filter Model
    struct FilterOption {
        let title: String
        let status: PaymentValidationStatus?
        var count: Int
    }

    // MARK: - Data Source Properties
//    private var studentDetails: StudentDetails?
    private var allPayments: [PaymentDetailItem] = []
    private var filteredPayments: [PaymentDetailItem] = []
    private var filterOptions: [FilterOption] = []
    private var selectedFilterIndex = 0
    private var currentSearchQuery = ""
    var studentDetails = UserDefaultFileManager.get_child_Details()
   override func viewDidLoad() {
        super.viewDidLoad()
        Get_paymentProof()
        setupCollectionView()
        setupTableView()
      
    }

    @IBAction func backBtnAct(_ sender: UIButton) {
        dismiss(animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if ProcessInfo.processInfo.arguments.contains("-AutoOpenDetail") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self = self, self.navigationController?.topViewController == self else { return }
                self.tableView(self.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
            }
        }
    }


    // MARK: - Setup Collection View
    private func setupCollectionView() {
        filterCollectionView.dataSource = self
        filterCollectionView.delegate = self
        filterCollectionView.register(
            UINib(nibName: FilterChipCell.reuseIdentifier, bundle: nil),
            forCellWithReuseIdentifier: FilterChipCell.reuseIdentifier
        )
    }

    // MARK: - Setup Table View
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            UINib(nibName: PaymentProofCardCell.reuseIdentifier, bundle: nil),
            forCellReuseIdentifier: PaymentProofCardCell.reuseIdentifier
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90.0
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 24, right: 0)
    }

    // MARK: - Data Loading & Filtering
    
    func Get_paymentProof(){
        showActivityLoader()
        APIService.shared.makeApi(url: ServiceUrl.fee_api_fee_details_payment_proof, parameters: ["country_id" : UserDefaultFileManager.getCountryDetails()?.id ?? ""], type: ApitTypeSringFile.GET, token: studentDetails?.access_token ?? "", isBaseUrl: false) {[weak self] (result: Result<PaymentProofAPIResponse,Error>) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success.status{
                        self.loadData(resp:success)
                        self.nodataStackView.isHidden = true
                        self.tableView.isHidden = false
                    }else{
                        self.nodataStackView.isHidden = false
                        self.tableView.isHidden = true
                        self.nodataLbl.text = success.message
                        
                    }
                case .failure(let failure):
                    self.nodataStackView.isHidden = false
                    self.tableView.isHidden = true
                    self.nodataLbl.text = failure.localizedDescription
                    
                    print("Error:", failure.localizedDescription)
                }
            }
        }
        
       hideActivityLoader()
    }
    
    private func loadData(resp:PaymentProofAPIResponse){
        
     
              let firstGroup = resp.data.first

        self.allPayments = firstGroup?.paymentDetails ?? []

        studentNameLbl.configureAsBackTitle(firstLine: studentDetails?.name ?? "", secondLine: "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")")

        // Calculate counts for filters
        let pendingCount = allPayments.filter { $0.validationStatus == .pending }.count
        let approvedCount = allPayments.filter { $0.validationStatus == .approved }.count
        let rejectedCount = allPayments.filter { $0.validationStatus == .rejected }.count

        self.filterOptions = [
            FilterOption(title: "All".translated(), status: nil, count: allPayments.count),
            FilterOption(title: "Pending".translated(), status: .pending, count: pendingCount),
            FilterOption(title: "Approved".translated(), status: .approved, count: approvedCount),
            FilterOption(title: "Rejected".translated(), status: .rejected, count: rejectedCount)
        ]

        applyFilters()
        filterCollectionView.reloadData()
    }

    private func applyFilters() {
        let activeStatus = filterOptions[selectedFilterIndex].status

        var list = allPayments
        if let status = activeStatus {
            list = list.filter { $0.validationStatus == status }
        }

        // Apply Search query if active
        let query = currentSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            list = list.filter { item in
                item.totalAmount.lowercased().contains(query) ||
                item.createdOn.lowercased().contains(query) ||
                item.validatedBy.lowercased().contains(query) ||
                item.validationStatus.displayName.lowercased().contains(query) ||
                item.remarks.lowercased().contains(query)
            }
        }
            self.filteredPayments = list
            self.tableView.reloadData()
       
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension paymentProofVc: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterOptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FilterChipCell.reuseIdentifier,
            for: indexPath
        ) as? FilterChipCell else {
            return UICollectionViewCell()
        }

        let option = filterOptions[indexPath.item]
        let pillTitle = "\(option.title) (\(option.count))"
        let isSelected = (indexPath.item == selectedFilterIndex)
        cell.configure(title: pillTitle, isSelected: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedFilterIndex != indexPath.item else { return }
        selectedFilterIndex = indexPath.item
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()

        filterCollectionView.reloadData()
        
        UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.applyFilters()
        }, completion: nil)
        

    if filteredPayments.count == 0 {
    tableView.isHidden = true
    nodataLbl.text = "No Data Found"
    nodataStackView.isHidden = false
    }
    else{
    tableView.isHidden = false
    nodataStackView.isHidden = true
    }
        
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let option = filterOptions[indexPath.item]
        let text = "\(option.title) \(option.count)"
        let font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
        let cellWidth = max(textWidth + 45.0, 72.0)
        return CGSize(width: cellWidth, height: 36.0)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension paymentProofVc: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPayments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PaymentProofCardCell.reuseIdentifier,
            for: indexPath
        ) as? PaymentProofCardCell else {
            return UITableViewCell()
        }

        let item = filteredPayments[indexPath.row]
        cell.configure(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = filteredPayments[indexPath.row]

        let vc = paymentProofDetailVc()
        vc.paymentItem = item
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

// MARK: - UISearchResultsUpdating & UISearchControllerDelegate
extension paymentProofVc: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        self.currentSearchQuery = searchController.searchBar.text ?? ""
        applyFilters()
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        navigationItem.searchController = nil
        currentSearchQuery = ""
        applyFilters()
    }
}
