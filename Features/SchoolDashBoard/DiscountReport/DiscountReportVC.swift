//
//  DiscountReportVC.swift
//  School Chimes
//
//  Principal side: Dashboard → "Discount" menu (Menu_id.discountReport).
//  Shows discounts and subsidies given, grouped by discount category, from
//  fee/api/fee-report/discount-report.
//  Filters: academic year, type (all / discount / subsidy), class, section,
//  and an optional given-date range.
//  Layout: DiscountReportVC.xib, DiscountSummaryCell.xib,
//          DiscountCategoryCell.xib, DiscountEntryCell.xib
//

import UIKit
final class DiscountReportVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var classButton: UIButton!
    @IBOutlet weak var sectionButton: UIButton!
    @IBOutlet weak var discountButton: UIButton!
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var dateRow: UIStackView!
    @IBOutlet weak var fromPicker: UIDatePicker!
    @IBOutlet weak var toPicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    // MARK: - Filter state
    private var years: [AcadimicYearData] = []
    private var yearId: Int?
    private var type = DiscountFilterType.all
    private var standards: [StandardDetail] = []
    private var selectedClass: StandardDetail?
    private var selectedSection: sectionsDetail?
    private var selectedDiscountTypeId: Int = 0

    // MARK: - Data
    private var report: DiscountReport?
    private var collapsed = Set<Int>()      // category indexes that are folded
    private var requestNumber = 0           // ignores responses from older requests
    private let refresh = UIRefreshControl()
    private let staffToken = UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
    
    
    private enum DiscountButtonFilter: Int, CaseIterable {
        case allType = 0
        case discount = 1
        case subsidy = 2

        var title: String {
            switch self {
            case .allType:
                return "All Types".translated()
            case .discount:
                return "Discount".translated()
            case .subsidy:
                return "Subsidy".translated()
            }
        }
    }

    private var selectedDiscountFilter: DiscountButtonFilter = .allType
    private var discountTypes: [DiscountTypeData] = []
    private var selectedDiscountId: String?

    private static let apiDate: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "dd-MM-yyyy"
        return f
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let menuName = MenuStringFile.selectedMenuName.isEmpty ? "Discount".translated() : MenuStringFile.selectedMenuName
        backButton.configureAsBackButton(firstLine: menuName,
                                         secondLine: UserDefaultFileManager.get_staff_Details()?.school_name ?? "")
        dateTitleLabel.text = "Filter by given date".translated()

        for nib in [DiscountSummaryCell.id, DiscountCategoryCell.id, DiscountEntryCell.id] {
            tableView.register(UINib(nibName: nib, bundle: nil), forCellReuseIdentifier: nib)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        refresh.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refresh
        
        dateSwitch.isOn = false
        dateRow.isHidden = true
        updateFilterMenus()
        
        loadAcademicYears()
        
        getDiscountTypes(type: type.rawValue)
    }

    @IBAction func backAct(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: - Date filter
    @IBAction func dateSwitchChanged(_ sender: UISwitch) {
        UIView.animate(withDuration: 0.2) { self.dateRow.isHidden = !sender.isOn }
        loadReport()
    }

    @IBAction func dateChanged(_ sender: UIDatePicker) {
        // to_date must be on or after from_date
        toPicker.minimumDate = fromPicker.date
        if toPicker.date < fromPicker.date { toPicker.date = fromPicker.date }
        loadReport()
    }

    /// Academic year "2026 - 2027" → 01-04-2026 … 31-03-2027; otherwise today.
    private func resetDates(for yearName: String?) {
        let years = (yearName ?? "").split(whereSeparator: { !$0.isNumber }).compactMap { Int($0) }.filter { $0 > 1900 }
        let cal = Calendar(identifier: .gregorian)
        if let start = years.first,
           let from = cal.date(from: DateComponents(year: start, month: 4, day: 1)),
           let to = cal.date(from: DateComponents(year: years.count > 1 ? years[1] : start + 1, month: 3, day: 31)) {
            toPicker.minimumDate = nil
            fromPicker.date = from
            toPicker.date = to
        } else {
            fromPicker.date = Date()
            toPicker.date = Date()
        }
        toPicker.minimumDate = fromPicker.date
    }

    // MARK: - Filter menus (tap a filter → pick from a menu)
    private func updateFilterMenus() {
        let yearName = years.first { $0.id == yearId }?.year
        setFilter(yearButton, title: yearName ?? "Academic year".translated(),
                  actions: years.map { y in
                      UIAction(title: y.year ?? "-", state: y.id == yearId ? .on : .off) { [weak self] _ in
                          self?.selectYear(y)
                      }
                  }
        )
 
        let hasDiscountTypes = !discountTypes.isEmpty

        // Keep the button visible, but disable it when no options are found.
        discountButton.isHidden = false
        discountButton.isEnabled = hasDiscountTypes
        discountButton.alpha = hasDiscountTypes ? 1.0 : 0.5
        
        if !hasDiscountTypes {
            switch type {
            case .all:
                discountButton.setTitle("No Discount".translated(), for: .normal)
            case .discount:
                discountButton.setTitle("No Discount".translated(), for: .normal)
            case .subsidy:
                discountButton.setTitle("No Subsidy".translated(), for: .normal)
            }
        }
       
        let discountTitle: String

        if let selectedName = selectedDiscountId.flatMap({ id in
            discountTypes.first(where: { $0.id == id })?.discount_name
        }) {
            discountTitle = selectedName
        } else {
           
            switch type {
          
            case .all:
                discountTitle = "All types".translated()
            case .discount:
                discountTitle = "All discount types".translated()
            case .subsidy:
                discountTitle = "All subsidy types".translated()
            }
        }
        
        let allTitle: String

        switch type {
        case .all:
            allTitle = "All types".translated()
        case .discount:
            allTitle = "All discount types".translated()
        case .subsidy:
            allTitle = "All subsidy types".translated()
        }


        let allDiscountsAction = UIAction(
            title: allTitle,
            state: selectedDiscountId == nil ? .on : .off
        ) { [weak self] _ in
            guard let self = self else { return }

            self.selectedDiscountId = nil
            self.updateFilterMenus()
            self.loadReport()
        }
        
        
        setFilter(
            discountButton,
            title: discountTitle,
            actions: hasDiscountTypes
                ? [allDiscountsAction] + discountTypes.map { item in
                    UIAction(
                        title: "\(item.discount_name ?? "-") (\(item.type_name ?? "-"))",
                        state: selectedDiscountId == item.id ? .on : .off
                    ){ [weak self] _ in
                        guard let self = self else { return }

                        self.selectedDiscountId = item.id
                        self.updateFilterMenus()
                        self.loadReport()
                    }
                }
                : []
        )
        
        // Disable discountButton when Subsidy is selected
//        let isSubsidySelected = type == .subsidy
//
//        discountButton.isEnabled = !isSubsidySelected
//        discountButton.alpha = isSubsidySelected ? 0.5 : 1.0
        

        // Disable class and section filters when no discount types are available
        classButton.isEnabled = hasDiscountTypes
        classButton.alpha = hasDiscountTypes ? 1.0 : 0.5
        
        dateView.isUserInteractionEnabled = hasDiscountTypes
        dateView.alpha = hasDiscountTypes ? 1.0 : 0.5
        
        sectionButton.isEnabled = hasDiscountTypes
            && selectedClass != nil
        && !(selectedClass?.sections?.isEmpty ?? true)

        sectionButton.alpha = sectionButton.isEnabled ? 1.0 : 0.5
        
        setFilter(typeButton, title: type.title,
                  actions: DiscountFilterType.allCases.map { t in
                      UIAction(title: t.title, state: t == type ? .on : .off) { [weak self] _ in
                          self?.type = t
                          self?.updateFilterMenus()
                          self?.getDiscountTypes(type: String(t.rawValue))
                          self?.loadReport()
                      }
                  })

        let allClasses = UIAction(title: "All classes".translated(), state: selectedClass == nil ? .on : .off) { [weak self] _ in
            self?.selectedClass = nil
            self?.selectedSection = nil
            self?.updateFilterMenus()
            self?.loadReport()
        }
        setFilter(classButton, title: selectedClass?.name ?? "All classes".translated(),
                  actions: [allClasses] + standards.map { s in
                      UIAction(title: s.name ?? "-", state: s.id == selectedClass?.id ? .on : .off) { [weak self] _ in
                          self?.selectedClass = s
                          self?.selectedSection = nil
                          self?.updateFilterMenus()
                          self?.loadReport()
                      }
                  })

        let sections = selectedClass?.sections ?? []
        let allSections = UIAction(title: "All sections".translated(), state: selectedSection == nil ? .on : .off) { [weak self] _ in
            self?.selectedSection = nil
            self?.updateFilterMenus()
            self?.loadReport()
        }
        setFilter(sectionButton, title: selectedSection?.name ?? "All sections".translated(),
                  actions: [allSections] + sections.map { sec in
                      UIAction(title: sec.name ?? "-", state: sec.id == selectedSection?.id ? .on : .off) { [weak self] _ in
                          self?.selectedSection = sec
                          self?.updateFilterMenus()
                          self?.loadReport()
                      }
                  })
//        sectionButton.isEnabled = selectedClass != nil && !sections.isEmpty
//        sectionButton.alpha = sectionButton.isEnabled ? 1 : 0.5
    }

    private func setFilter(
        _ button: UIButton,
        title: String,
        actions: [UIMenuElement]
    ) {
        button.setTitle(title, for: .normal)
        button.menu = actions.isEmpty ? nil : UIMenu(children: actions)
        button.showsMenuAsPrimaryAction = true

        // Light gray text when disabled
        if !button.isEnabled {
            button.setTitleColor(.lightGray, for: .normal)
        } else {
            button.setTitleColor(.label, for: .normal)
        }
    }

    private func selectYear(_ year: AcadimicYearData) {
        yearId = year.id
        selectedClass = nil
        selectedSection = nil
        standards = []
        resetDates(for: year.year)
        updateFilterMenus()
        loadStandards()
        loadReport()
    }

    // MARK: - API
    private func loadAcademicYears() {
        spinner.startAnimating()
        APIService.shared.makeApi(
            url: ServiceUrl.comm_recipient_get_academic_year_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: staffToken,
            isBaseUrl: false
        ) { [weak self] (result: Result<get_academic_yearSuc, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case.success(let response):
                    self.years = response.data ?? []
                    if let current = self.years.first(where: { $0.current_academic_year == true }) ?? self.years.first {
                        self.selectYear(current)
                    } else {
                        self.showEmpty(response.message ?? "No academic year found.".translated())
                    }
                case .failure(let error):
                    self.showEmpty(error.localizedDescription)
                }
            }
        }
    }

    private func loadStandards() {
        guard let yearId = yearId else { return }
        APIService.shared.makeApi(
            url: ServiceUrl.recipient_get_standards,
            parameters: [COMMON_PARAMETER.academic_year_id: yearId],
            type: ApitTypeSringFile.GET,
            token: staffToken,
            isBaseUrl: false
        ) { [weak self] (result: Result<GetStandardsSuc, Error>) in
            DispatchQueue.main.async {
                guard let self = self, self.yearId == yearId else { return }
                if case .success(let response) = result, response.status == true {
                    self.standards = response.data ?? []
                    self.updateFilterMenus()
                }
            }
        }
    }
    
    private func getDiscountTypes(type: String) {
        self.discountTypes.removeAll()
        selectedDiscountId = nil
            updateFilterMenus()
        
        
        APIService.shared.makeApi(
            url: ServiceUrl.discount_count_type_list,
            parameters: ["type": type],
            type: ApitTypeSringFile.GET,
            token: staffToken,
            isBaseUrl: false
        ) { [weak self] (result: Result<DiscountTypeResponse, Error>) in

            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let response):
                    if response.status == true {
                        self.discountTypes = response.data ?? []
                        self.updateFilterMenus()

                        print(
                            "Discount names:",
                            self.discountTypes.map { $0.discount_name }
                        )
                    } else {
                        print("Discount types:", response.message ?? "Unknown error")
                        self.updateFilterMenus()
                        
                    }

                case .failure(let error):
                    print(
                        "Discount types API error:",
                        error.localizedDescription
                    )
                    self.updateFilterMenus()
                }
            }
        }
    }
    
    @objc private func pullToRefresh() {
        loadReport()
    }
    
    private func loadReport() {
        guard let yearId = yearId else { refresh.endRefreshing(); return }
        var params: [String: Any] = [
            "academic_year_id": yearId,
            "country_id": String(UserDefaultFileManager.getCountryDetails()?.id ?? 1),
            "type": type.rawValue,
            "class_id": selectedClass?.id ?? "0",
            "section_id": selectedSection?.id ?? "0",
            "discount_type_id": String(selectedDiscountId.flatMap { Int($0) } ?? 0)
        ]
        
        if dateSwitch.isOn {
            params["from_date"] = Self.apiDate.string(from: fromPicker.date)
            params["to_date"] = Self.apiDate.string(from: toPicker.date)
        }

        requestNumber += 1
        let number = requestNumber
        if !refresh.isRefreshing { spinner.startAnimating() }
        emptyLabel.isHidden = true

        APIService.shared.makeApi(
            url: ServiceUrl.fee_api_fee_report_discount_report,
            parameters: params,
            type: ApitTypeSringFile.GET,
            token: staffToken,
            isBaseUrl: false
        ) { [weak self] (result: Result<DiscountReportResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self, number == self.requestNumber else { return }
                switch result {
                case .success(let response):
                    self.show(response)
                case .failure(let error):
                    self.showEmpty(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Display
    private func show(_ response: DiscountReportResponse) {
        spinner.stopAnimating()
        refresh.endRefreshing()
        collapsed.removeAll()
        if let r = DiscountReport(response), !r.isEmpty {
            report = r
            emptyLabel.isHidden = true
            tableView.reloadData()
        } else {
            showEmpty(response.status == true || response.message == nil
                      ? "No discounts found for the selected filters.".translated()
                      : response.message ?? "")
        }
    }

    private func showEmpty(_ message: String) {
        spinner.stopAnimating()
        refresh.endRefreshing()
        report = nil
        emptyLabel.text = message
        emptyLabel.isHidden = false
        tableView.reloadData()
    }
}

// MARK: - Table
// Section 0 = summary; section n = category n-1 (row 0 = category header, rows 1… = students).

extension DiscountReportVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let r = report else { return 0 }
        return 1 + r.categories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let r = report else { return 0 }
        if section == 0 { return 1 }
        let index = section - 1
        return 1 + (collapsed.contains(index) ? 0 : r.categories[index].entries.count)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 ? "Categories".translated() : nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let r = report else { return UITableViewCell() }
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: DiscountSummaryCell.id, for: indexPath) as! DiscountSummaryCell
            cell.configure(r, type: type)
            return cell
        }
        let index = indexPath.section - 1
        let category = r.categories[index]
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: DiscountCategoryCell.id, for: indexPath) as! DiscountCategoryCell
            cell.configure(category, collapsed: collapsed.contains(index))
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: DiscountEntryCell.id, for: indexPath) as! DiscountEntryCell
        cell.configure(category.entries[indexPath.row - 1], kind: category.kind)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.section > 0, indexPath.row == 0 else { return }
        let index = indexPath.section - 1
        if collapsed.contains(index) { collapsed.remove(index) } else { collapsed.insert(index) }
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }
}
