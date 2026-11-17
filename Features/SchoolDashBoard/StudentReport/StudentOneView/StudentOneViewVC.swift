//
//  StudentOneViewVC.swift
//  School Chimes
//
//  Staff side: Student Report → tap a student → Student One View.
//  One screen for the 18 student-one-view-report APIs, grouped in tabs:
//  Overview · Profile · Fees · Exams · Attendance · Transport · Hostel · Certificates · Well-being.
//  Each tab loads only its own APIs the first time it is opened; pull to refresh reloads them.
//  Layout: StudentOneViewVC.xib, OneViewTabCell.xib, OneViewHeaderCell.xib,
//          OneViewSummaryCell.xib, OneViewKeyValueCell.xib, OneViewListCell.xib
//

import UIKit
import SafariServices

final class StudentOneViewVC: UIViewController {

    // MARK: - Input (set before presenting)
    var studentId = ""
    var studentName = ""
    var classSection = ""
    var academicYearId = ""

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tabsCollection: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    // MARK: - State
    private var currentTab: OneViewTab = .overview
    private var results: [OneViewAPI: FeeRecord] = [:]
    private var errors: [OneViewAPI: String] = [:]
    private var loading = Set<OneViewAPI>()
    private var sections: [OneViewSection] = []
    private let refresh = UIRefreshControl()

    private var token: String { UserDefaultFileManager.get_staff_Details()?.access_token ?? "" }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = studentName
        subtitleLabel.text = classSection

        tabsCollection.register(UINib(nibName: OneViewTabCell.id, bundle: nil), forCellWithReuseIdentifier: OneViewTabCell.id)
        tabsCollection.dataSource = self
        tabsCollection.delegate = self

        for id in [OneViewHeaderCell.id, OneViewSummaryCell.id, OneViewKeyValueCell.id, OneViewListCell.id,
                   OneViewRingCell.id, OneViewTilesCell.id, OneViewBarCell.id] {
            tableView.register(UINib(nibName: id, bundle: nil), forCellReuseIdentifier: id)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        refresh.addTarget(self, action: #selector(reloadTab), for: .valueChanged)
        tableView.refreshControl = refresh

        rebuild()
        load(currentTab)
    }

    @IBAction func backAct(_ sender: UIButton) {
        dismiss(animated: true)
    }

    // MARK: - Data

    @objc private func reloadTab() {
        for api in currentTab.apis {
            results[api] = nil
            errors[api] = nil
        }
        load(currentTab)
    }

    private func load(_ target: OneViewTab) {
        let needed = target.apis.filter { results[$0] == nil && errors[$0] == nil && !loading.contains($0) }
        guard !needed.isEmpty else {
            refresh.endRefreshing()
            rebuild()
            return
        }
        if !refresh.isRefreshing { spinner.startAnimating() }
        emptyLabel.isHidden = true

        let group = DispatchGroup()
        for api in needed {
            loading.insert(api)
            group.enter()
            fetch(api) { [weak self] response, errorMessage in
                guard let self = self else { group.leave(); return }
                self.loading.remove(api)
                if let record = response?.record {
                    self.results[api] = record
                } else if response?.status == true {
                    // Worked but returned no data: keep "" so the section shows its own empty text.
                    self.errors[api] = ""
                } else {
                    self.errors[api] = errorMessage ?? response?.message ?? "Could not load this section.".translated()
                }
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            if self.loading.isEmpty { self.spinner.stopAnimating() }
            self.refresh.endRefreshing()
            self.rebuild()
        }
    }

    /// Calls one API (or reads its sample response). The completion runs on the main queue.
    private func fetch(_ api: OneViewAPI, completion: @escaping (OneViewResponse?, String?) -> Void) {
        if StudentOneViewConfig.useSampleData {
            let response = StudentOneViewSampleData.response(for: api)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { completion(response, nil) }
            return
        }
        var params: [String: Any] = [
            "student_id": studentId,
            "academic_year_id": academicYearId,
            "country_id": UserDefaultFileManager.getCountryDetails()?.id ?? 1
        ]
        api.extraParams.forEach { params[$0.key] = $0.value }

        APIService.shared.makeApi(
            url: api.path,
            parameters: params,
            type: ApitTypeSringFile.GET,
            token: token,
            isBaseUrl: false
        ) { (result: Result<OneViewResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response): completion(response, nil)
                case .failure(let error): completion(nil, error.localizedDescription)
                }
            }
        }
    }

    private func rebuild() {
        let builder = StudentOneViewBuilder(results: results, errors: errors,
                                            fallbackName: studentName, fallbackClass: classSection)
        let stillLoading = currentTab.apis.contains { loading.contains($0) }
        sections = stillLoading && currentTab.apis.allSatisfy({ results[$0] == nil }) ? [] : builder.sections(for: currentTab)
        if let profile = results[.profile] {
            let name = [profile.s("student_name"), profile.s("last_name")].filter { !$0.isEmpty }.joined(separator: " ")
            if !name.isEmpty { titleLabel.text = name }
        }
        emptyLabel.text = "Nothing to show for this student yet.".translated()
        emptyLabel.isHidden = stillLoading || !sections.isEmpty
        tableView.reloadData()
    }

    private func select(_ newTab: OneViewTab) {
        guard newTab != currentTab else { return }
        currentTab = newTab
        tabsCollection.reloadData()
        tabsCollection.scrollToItem(at: IndexPath(item: newTab.rawValue, section: 0), at: .centeredHorizontally, animated: true)
        sections = []
        tableView.reloadData()
        tableView.setContentOffset(.zero, animated: false)
        rebuild()
        load(newTab)
    }

    private func open(_ link: String) {
        guard let url = URL(string: link), link.hasPrefix("http") else {
            view.makeToast("This file is not available in the app yet.".translated())
            return
        }
        present(SFSafariViewController(url: url), animated: true)
    }
}

// MARK: - Tabs

extension StudentOneViewVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        OneViewTab.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OneViewTabCell.id, for: indexPath) as! OneViewTabCell
        let t = OneViewTab.allCases[indexPath.item]
        cell.configure(t.title, selected: t == currentTab)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        select(OneViewTab.allCases[indexPath.item])
    }
}

// MARK: - Table

extension StudentOneViewVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { sections[section].rows.count }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { sections[section].title }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section].rows[indexPath.row] {
        case let .header(name, line1, line2, photo):
            let cell = tableView.dequeueReusableCell(withIdentifier: OneViewHeaderCell.id, for: indexPath) as! OneViewHeaderCell
            cell.configure(name: name, line1: line1, line2: line2, photo: photo)
            return cell
        case let .summary(caption, value, note, progress, stats):
            let cell = tableView.dequeueReusableCell(withIdentifier: OneViewSummaryCell.id, for: indexPath) as! OneViewSummaryCell
            cell.configure(caption: caption, value: value, note: note, progress: progress, stats: stats)
            return cell
        case let .ring(caption, value, note, center, centerCaption, segments):
            let cell = tableView.dequeueReusableCell(withIdentifier: OneViewRingCell.id, for: indexPath) as! OneViewRingCell
            cell.configure(caption: caption, value: value, note: note, center: center, centerCaption: centerCaption, segments: segments)
            return cell
        case let .tiles(tiles):
            let cell = tableView.dequeueReusableCell(withIdentifier: OneViewTilesCell.id, for: indexPath) as! OneViewTilesCell
            cell.configure(tiles)
            return cell
        case let .bar(bar):
            let cell = tableView.dequeueReusableCell(withIdentifier: OneViewBarCell.id, for: indexPath) as! OneViewBarCell
            cell.configure(bar)
            return cell
        case let .keyValue(key, value):
            let cell = tableView.dequeueReusableCell(withIdentifier: OneViewKeyValueCell.id, for: indexPath) as! OneViewKeyValueCell
            cell.configure(key: key, value: value)
            return cell
        case let .item(item):
            let cell = tableView.dequeueReusableCell(withIdentifier: OneViewListCell.id, for: indexPath) as! OneViewListCell
            cell.configure(item)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if case let .item(item) = sections[indexPath.section].rows[indexPath.row], !item.url.isEmpty {
            open(item.url)
        }
    }
}
