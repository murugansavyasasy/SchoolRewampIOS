//
//  EventHistoryVC.swift
//  VsSchoolChimes
//
//  Created by admin on 04/12/24.
//

import UIKit

@available(iOS 14.0, *)
class EventHistoryVC: UIViewController,UITableViewDelegate,UITableViewDataSource,SelectNotice, UISearchBarDelegate {
    
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var nodataImg: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var historyTable: UITableView!
    var previousOffset: CGFloat = 0.0
    var delegate : HistorySelectDelegate?
    var event:[EventData]?
    var allEventSections: [EventDisplaySection] = []
    var filteredSections: [EventDisplaySection] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTable.register(UINib(nibName: CellConfingName.EventTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.EventTVC)
        historyTable.register(UINib(nibName: "OngoingTVC", bundle: nil), forCellReuseIdentifier: "OngoingTVC")
        historyTable.register(UINib(nibName: "ReciverEventTVC", bundle: nil), forCellReuseIdentifier: "ReciverEventTVC")
        historyTable.delegate = self
        historyTable.dataSource = self
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.applyRightTxt()
        searchBar.backgroundImage = UIImage()
        searchBar.barTintColor = .clear
        searchBar.backgroundColor = .clear
        searchBar.delegate = self
        searchBar.addDoneButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GetEvent()
    }

    // MARK: - API Call
    func GetEvent() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }

        APIService.shared.makeApi(
            url: ServiceUrl.api_school_event_get_event,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "") { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self?.hideLottieProgressLoader()
                }

                guard let self = self else { return }

                switch result {
                case .success(let response):
                    self.allEventSections = []
                    if let firstSection = response.data.first {
                        if !firstSection.on_going.isEmpty {
                            self.allEventSections.append(.featured(firstSection.on_going))
                        }
                        if !firstSection.categories.isEmpty {
                            var updatedCategories = firstSection.categories
                            let allCategory = EventCategory(id: nil, name: "All", url: "")
                            updatedCategories.insert(allCategory, at: 0)
                            self.allEventSections.append(.categories(updatedCategories))
                        }
                        if !firstSection.up_coming.isEmpty {
                            self.allEventSections.append(.upcoming(firstSection.up_coming))
                        }
                        if !firstSection.completed.isEmpty {
                            self.allEventSections.append(.completed(firstSection.completed))
                        }
                    }
                    self.filteredSections = self.allEventSections
                    self.noDataLbl.isHidden = true
                    self.nodataImg.isHidden = true
                    self.searchBar.isHidden = false
                    self.historyTable.reloadData()

                case .failure(let error):
                    print(error.localizedDescription)
                    self.noDataLbl.text = error.localizedDescription
                    self.noDataLbl.isHidden = false
                    self.nodataImg.isHidden = false
                    self.searchBar.isHidden = true
                }
            }
        }
    }

    func didTapButton(title: String, content: String, items: [FilePath]) {
        delegate?.select(Title: title, Description: content, Images: [], pdf: "")
        
    }
    func loadFiles(into cell: ReciverEventTVC, files: [FilePath]) {

        for (index, item) in files.enumerated() {
            guard let urlString = item.url, let url = URL(string: urlString) else { continue }
            let imageView: UIImageView? = [cell.img1, cell.img2, cell.img3][safe: index]
            imageView?.isHidden = false

            if item.type?.lowercased() != "image" {
                let iconName = getFileIconName(for: url)
                imageView?.image = UIImage(named: iconName)
            } else {
                imageView?.kf.setImage(with: url)
            }
        }

        if files.count > 3 {
            let extraCount = files.count - 3
            if let button = cell.imgCount as? UIButton {
                button.setTitle("+\(extraCount)", for: .normal)
            }
            cell.imgCount.isHidden = false
        }
    }
}

// MARK: - UITableViewDelegate & DataSource
@available(iOS 14.0, *)
extension EventHistoryVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return filteredSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch filteredSections[section] {
        case .featured, .categories: return 1
        case .upcoming(let events), .completed(let events): return events.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionData = filteredSections[indexPath.section]

        switch sectionData {
        case .featured(let events):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OngoingTVC", for: indexPath) as! OngoingTVC
            cell.config(category: nil, onGoing: events, type: false)
            cell.pageController.numberOfPages = events.count
            return cell

        case .categories(let categories):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OngoingTVC", for: indexPath) as! OngoingTVC
            cell.config(category: categories, onGoing: nil, type: true)
            cell.delegate = self
            return cell

        case .upcoming(let events):
            let event = events[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReciverEventTVC", for: indexPath) as! ReciverEventTVC
            cell.titleLbl.text = event.title
            cell.dateLbl.text = "\(event.category)  \(event.time) - \(event.date.convertToTargetDateFormat() ?? "")"
            cell.placeLbl.text = event.venue
            cell.descriptionLbl.text = event.description
            cell.date = event.date
            cell.time = event.time
            cell.reminderBtn.isHidden = false
            cell.outerView.backgroundColor = UIColor(hex: "8000FF").withAlphaComponent(0.5)
            loadFiles(into: cell, files: event.file_path)
            return cell
        case .completed(let events):
            let event = events[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReciverEventTVC", for: indexPath) as! ReciverEventTVC
            cell.titleLbl.text = event.title
            cell.dateLbl.text = "\(event.category)  \(event.time) - \(event.date.convertToTargetDateFormat() ?? "")"
            cell.placeLbl.text = event.venue
            cell.descriptionLbl.text = event.description
            cell.date = event.date
            cell.time = event.time
            cell.reminderBtn.isHidden = true
            cell.outerView.backgroundColor = .black
            loadFiles(into: cell, files: event.file_path)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch filteredSections[indexPath.section] {
        case .featured: return 220
        case .categories: return 130
        case .upcoming, .completed: return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear

        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false

        switch filteredSections[section] {
        case .featured: label.text = "Today's Events"
        case .categories: label.text = "Event Categories"
        case .upcoming: label.text = "Upcoming Events"
        case .completed: label.text = "Completed Events"
        }

        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

// MARK: - UISearchBarDelegate
@available(iOS 14.0, *)
extension EventHistoryVC: UISearchBarDelegate, FilterCatagories {

    func filterCatagories(name: String) {
        self.filteredSections = filterEventListsByTitle(searchText: name)
        self.historyTable.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        DispatchQueue.main.async {
            if searchText.isEmpty {
                self.filteredSections = self.allEventSections
            } else {
                self.filteredSections = self.allEventSections.compactMap { section in
                    switch section {
                    case .featured(let events):
                        let matched = events.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
                        return matched.isEmpty ? nil : .featured(matched)

                    case .categories(let categories):
                        let matched = categories.filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
                        return matched.isEmpty ? nil : .categories(matched)

                    case .upcoming(let events):
                        let matched = events.filter {
                            $0.title.localizedCaseInsensitiveContains(searchText) ||
                            $0.description.localizedCaseInsensitiveContains(searchText)
                        }
                        return matched.isEmpty ? nil : .upcoming(matched)

                    case .completed(let events):
                        let matched = events.filter {
                            $0.title.localizedCaseInsensitiveContains(searchText) ||
                            $0.description.localizedCaseInsensitiveContains(searchText)
                        }
                        return matched.isEmpty ? nil : .completed(matched)
                    }
                }
            }
            self.historyTable.reloadData()
        }
    }

    func filterEventListsByTitle(searchText: String) -> [EventDisplaySection] {
        var filtered: [EventDisplaySection] = []

        let upcoming = allEventSections.compactMap { section -> [EventList]? in
            if case .upcoming(let events) = section {
                return events.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
            }
            return nil
        }.flatMap { $0 }

        if !upcoming.isEmpty {
            filtered.append(.upcoming(upcoming))
        }

        let completed = allEventSections.compactMap { section -> [EventList]? in
            if case .completed(let events) = section {
                return events.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
            }
            return nil
        }.flatMap { $0 }

        if !completed.isEmpty {
            filtered.append(.completed(completed))
        }

        return filtered
    }
}
