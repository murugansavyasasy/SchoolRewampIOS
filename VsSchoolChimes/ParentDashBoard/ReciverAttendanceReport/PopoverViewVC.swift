//
// PopoverViewVC.swift
// School Chimes
//
// Created by Chandhru on 30/10/25.
//

import UIKit

class PopoverViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var listTable: UITableView!
    
    enum PopoverType { case badge, symbol }
    
    private var configData: [(symbol: String, title: String, color: UIColor)]?
    private var configType: PopoverType?
    var itemCount: Int { configData?.count ?? 0 }
    var delegate: SelectedId?
    var filterdelegate: FilterStudentMark?
    var selectedId:String?
    var delete:Bool?
    var filterSections: [FilterSection] = [
        FilterSection(gender: "Male", isExpanded: false),
        FilterSection(gender: "Female", isExpanded: false),
        FilterSection(gender: "rollAZ", isExpanded: false),
        FilterSection(gender: "nameZA", isExpanded: false),
        FilterSection(gender: "rollZA", isExpanded: false),
        FilterSection(gender: "admAZ", isExpanded: false),
        FilterSection(gender: "admZA", isExpanded: false),
        FilterSection(gender: "nameAZ", isExpanded: false)
    ]
    
    let sortOptions: [SortType] = [
        .nameAZ, .nameZA,
        .rollAZ, .rollZA,
        .admAZ, .admZA
    ]
    @IBOutlet weak var stackView: UIStackView!
    var selectedSectionIndex: Int? = nil
    var selectedSortIndex: Int? = nil
    var isFilterMode: Bool {
        return configData == nil || configData?.isEmpty == true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 17.4, *) {
            view.backgroundColor = .clear
            self.popoverPresentationController?.backgroundColor = .white
        }
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        listTable.showsHorizontalScrollIndicator = false
        listTable.showsVerticalScrollIndicator = false
        listTable.register(UINib(nibName: "PopoverTVC", bundle: nil), forCellReuseIdentifier: "PopoverTVC")
        let nib = UINib(nibName: "PopoverHeaderView", bundle: nil)
        listTable.register(nib, forHeaderFooterViewReuseIdentifier: "PopoverHeaderView")
        listTable.delegate = self
        listTable.dataSource = self
        stackView.isHidden = !isFilterMode
    }
    
    // MARK: - Configure From Parent VC
    func configureButtons(
        with data: [(symbol: String, title: String, color: UIColor)],
        type: PopoverType
    ) {
        self.configData = data
        self.configType = type
        
        if isViewLoaded {
            listTable.reloadData()
        }
    }
    @IBAction func clearBtn(_ sender: UIButton) {
        selectedSortIndex = nil
        selectedSectionIndex = nil
        for i in 0..<filterSections.count {
            filterSections[i].isExpanded = false
        }
        listTable.reloadData()
        filterdelegate?.applySort(type: nil, gender: nil)
        dismiss(animated: true)
    }
    @IBAction func applyBtn(_ sender: UIButton) {
        
        if let row = selectedSortIndex, let section  = selectedSectionIndex{
            let sortType = sortOptions[row]
            let gender = filterSections[section].gender
            filterdelegate?.applySort(type: sortType, gender: gender)
        } else if let row = selectedSectionIndex {
            let gender = filterSections[row].gender
            filterdelegate?.applySort(type:nil, gender: gender)
        }
        dismiss(animated: true)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return !isFilterMode ? 1 : filterSections.count
    }
    // MARK: - TableView Datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return !isFilterMode ? itemCount: filterSections[section].isExpanded ? sortOptions.count : 0
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PopoverTVC",
            for: indexPath
        ) as! PopoverTVC
        if isFilterMode {
            
            let sort = sortOptions[indexPath.row]
            cell.tittleLbl.text = titleForSort(sort)
            
            let isChecked = selectedSortIndex == indexPath.row
            
            cell.iconImg.isHidden = false
            cell.iconBtn.isHidden = true
            cell.iconImg.image = UIImage(systemName: isChecked ? "checkmark.square.fill" : "square")
            cell.iconImg.tintColor = .systemBlue
            
            return cell
        }
        
        guard let item = configData?[indexPath.row],
              let type = configType else { return cell }
        
        cell.tittleLbl.text = item.title
        
        
        switch type {
        case .badge:
            cell.iconImg.isHidden = true
            cell.iconBtn.isHidden = item.symbol.isEmpty
            cell.iconBtn.setTitle(item.symbol, for: .normal)
            cell.iconBtn.titleLabel?.font = .boldSystemFont(ofSize: 13)
            cell.iconBtn.backgroundColor = item.color
            cell.iconBtn.layer.cornerRadius = 8
            cell.iconBtn.clipsToBounds = true
            if item.symbol == "Pᴸᴬ" {
                let text = NSMutableAttributedString(string: "Pᴸᴬ")
                // Color P = white
                text.addAttribute(.foregroundColor, value: UIColor.white,
                                  range: NSRange(location: 0, length: 1))
                // Color LA = orange
                text.addAttribute(.foregroundColor, value: UIColor.button,
                                  range: NSRange(location: 1, length: 2))
                // Apply attributed title
                cell.iconBtn.setAttributedTitle(text, for: .normal)
                
            } else {
                // Normal symbols
                cell.iconBtn.setTitle(item.symbol, for: .normal)
                cell.iconBtn.setTitleColor(.white, for: .normal)
            }
            
        case .symbol:
            cell.iconBtn.isHidden = true
            cell.iconImg.isHidden = false
            let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
            if let sysImg = UIImage(systemName: item.symbol, withConfiguration: config) {
                cell.iconImg.image = sysImg
                cell.iconImg.tintColor = item.color
            } else if let assetImg = UIImage(named: item.symbol) {
                cell.iconImg.image = assetImg
                cell.iconImg.tintColor = nil
            }
        }
        
        return cell
    }
    func titleForSort(_ type: SortType) -> String {
        switch type {
        case .nameAZ: return "Name A → Z"
        case .nameZA: return "Name Z → A"
        case .rollAZ: return "Roll No A → Z"
        case .rollZA: return "Roll No Z → A"
        case .admAZ:  return "Admiss No A → Z"
        case .admZA:  return "Admiss No Z → A"
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard isFilterMode else { return nil }
        
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "PopoverHeaderView"
        ) as! PopoverHeaderView
        
        let filter = filterSections[section]
        header.tittleLbl.text = filter.gender
        let imageName = selectedSectionIndex == section ? "largecircle.fill.circle" : "circle"
        header.selectBtn.setImage(UIImage(systemName: imageName), for: .normal)
        header.selectBtn.tintColor = selectedSectionIndex == section ? .systemBlue : .lightGray
        
        // Use button directly instead of stackView
        header.selectBtn.removeTarget(nil, action: nil, for: .allEvents)
        header.selectBtn.tag = section
        header.selectBtn.addTarget(self, action: #selector(headerButtonTapped(_:)), for: .touchUpInside)
        header.stackView.gestureRecognizers?.forEach {
            header.stackView.removeGestureRecognizer($0)
        }
        header.stackView.tag = section
        header.stackView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(headerStackViewTapped(_:)))
        header.stackView.addGestureRecognizer(tap)
        
        return header
    }
    
    @objc func headerStackViewTapped(_ gesture: UITapGestureRecognizer) {
        guard let stackView = gesture.view else { return }
        headerButtonTapped(section: stackView.tag)
    }
    
    @objc func headerButtonTapped(_ sender: UIButton) {
        headerButtonTapped(section: sender.tag)
    }
    
    private func headerButtonTapped(section: Int) {
        selectedSectionIndex = section
        selectedSortIndex = nil
        
        for i in 0..<filterSections.count {
            if filterSections[i].gender == "Male" || filterSections[i].gender == "Female" {
                filterSections[i].isExpanded = (i == section)
            }
        }
        
        listTable.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    // MARK: - Row Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isFilterMode {
            selectedSortIndex = indexPath.row
            listTable.reloadData()
            return
        }
        if configData?[indexPath.row].title == "Delete" {
            delegate?.selectId(id: selectedId, edit: false)
        } else {
            delegate?.selectId(id: selectedId, edit: true)
        }
        dismiss(animated: true)
    }
    
}
enum SortType {
    case nameAZ, nameZA
    case rollAZ, rollZA
    case admAZ, admZA
}

struct FilterSection {
    let gender: String   // "M" or "F"
    var isExpanded: Bool
}
