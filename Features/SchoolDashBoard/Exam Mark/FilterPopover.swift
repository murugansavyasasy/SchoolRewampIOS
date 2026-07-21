//
//  FilterPopover.swift
//  School Chimes
//
//  Created by Chandhru on 13/01/26.
//

import UIKit

protocol FilterPopoverDelegate: AnyObject {
    func didApplyFilters(_ filters: [(type: String, sortValue: String)])
}

class FilterPopover: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var verticalstackView: UIStackView!
    @IBOutlet var horizontalstackViews: [UIStackView]!
    @IBOutlet var innerHorizontalStacks: [UIStackView]!
    @IBOutlet var typeViews: [UIView]!
    @IBOutlet var sortViews: [UIView]!
    @IBOutlet var addBtns: [UIButton]!
    
    // MARK: - Properties
    weak var delegate: FilterPopoverDelegate?
    var stackViewReferences: [Int: (typeView: UIView, sortView: UIView, innerStack: UIStackView)] = [:]
    
    var filterSection: [FilterSection]? = [
        FilterSection(type: "Student Name", section: ["Ascending", "Descending"]),
        FilterSection(type: "Admission Number", section: ["Ascending", "Descending"]),
        FilterSection(type: "Roll Number", section: ["Ascending", "Descending"]),
        FilterSection(type: "Gender", section: ["Male", "Female", "Others"])
    ]
    
    var availableFilters: [FilterSection] = []
    var selectedFilters: [(type: String, sortValue: String?, stackIndex: Int)] = []
    var dropdowns: [Int: (typeDropdown: DropDown, sortDropdown: DropDown?)] = [:]
    var isUpdatingPopover: Bool = false
    
    // NEW: Store previously applied filters to restore on reload
    var previouslyAppliedFilters: [(type: String, sortValue: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        availableFilters = filterSection ?? []
        setupButtonTags()
        setupStackReferences()
        
        // Check if we need to restore previous filters
        if !previouslyAppliedFilters.isEmpty {
            restorePreviousFilters()
        } else {
            setupFirstRow()
        }
    }
    
    // MARK: - Restore Previous Filters
    func restorePreviousFilters() {
        // Reset to clean state
        selectedFilters.removeAll()
        dropdowns.removeAll()
        availableFilters = filterSection ?? []
        for (index, stack) in (horizontalstackViews ?? []).enumerated() {
            stack.isHidden = index != 0
        }
        for (stackIndex, appliedFilter) in previouslyAppliedFilters.enumerated() {
            // Show stack if needed
            if stackIndex > 0 {
                if stackIndex < (horizontalstackViews?.count ?? 0) {
                    horizontalstackViews[stackIndex].isHidden = false
                }
            }
            
            // Find the filter section for this type
            if let filterSectionForType = filterSection?.first(where: { $0.type == appliedFilter.type }) {
                // Remove from available filters
                availableFilters.removeAll { $0.type == appliedFilter.type }
                
                // Add to selected filters
                selectedFilters.append((appliedFilter.type, appliedFilter.sortValue, stackIndex))
                
                // Setup type dropdown
                if let typeView = getTypeViewForStack(at: stackIndex) {
                    setupTypeDropdownWithPreselection(for: typeView, stackIndex: stackIndex, selectedType: appliedFilter.type)
                }
                
                // Setup sort dropdown
                if let sortView = getSortViewForStack(at: stackIndex) {
                    setupSortDropdownWithPreselection(for: sortView, filterSection: filterSectionForType, stackIndex: stackIndex, selectedSort: appliedFilter.sortValue)
                }
            }
        }
        
        // Update all dropdowns and buttons
        updateAllTypeDropdowns()
        for i in 0..<(horizontalstackViews?.count ?? 0) {
            if !(horizontalstackViews?[i].isHidden ?? true) {
                updateAddRemoveButton(at: i)
            }
        }
    }
    
    // MARK: - Setup Button Tags
    func setupButtonTags() {
        for (index, button) in (addBtns ?? []).enumerated() {
            button.tag = index
            button.addTarget(self, action: #selector(toggleAddRemoveBtn(_:)), for: .touchUpInside)
        }
    }
    
    // MARK: - Setup Stack References from XIB
    func setupStackReferences() {
        guard let typeViews = typeViews,
              let sortViews = sortViews,
              let innerStacks = innerHorizontalStacks else { return }
        
        for index in 0..<typeViews.count {
            if index < sortViews.count && index < innerStacks.count {
                stackViewReferences[index] = (typeViews[index], sortViews[index], innerStacks[index])
            }
        }
    }
    
    // MARK: - Setup First Row
    func setupFirstRow() {
        if let typeView = stackViewReferences[0]?.typeView {
            setupTypeDropdown(for: typeView, stackIndex: 0)
        }
        
        if let sortView = stackViewReferences[0]?.sortView,
           let firstFilter = filterSection?.first {
            setupSortDropdown(for: sortView, filterSection: firstFilter, stackIndex: 0)
        }
    }
    
    // MARK: - Setup Type Dropdown (Original)
    func setupTypeDropdown(for view: UIView, stackIndex: Int) {
        view.subviews.forEach { $0.removeFromSuperview() }
        
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Select Type", for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemGray4.cgColor
        btn.setTitleColor(.label, for: .normal)
        btn.tag = stackIndex
        
        view.addSubview(btn)
        
        NSLayoutConstraint.activate([
            btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            btn.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            btn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5)
        ])
        
        let typeDropdown = DropDown()
        typeDropdown.anchorView = btn
        typeDropdown.dataSource = availableFilters.map { $0.type }
        typeDropdown.direction = .bottom
        typeDropdown.backgroundColor = .systemBackground
        typeDropdown.selectionBackgroundColor = .systemGray5
        typeDropdown.textColor = .label
        typeDropdown.cornerRadius = 8
        
        typeDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            btn.setTitle(item, for: .normal)
            
            // Get the previously selected type for this stack (if any)
            let previouslySelectedType = self.selectedFilters.first(where: { $0.stackIndex == stackIndex })?.type
            
            // Get the newly selected filter
            let selectedFilter = self.availableFilters[index]
            
            // Remove the newly selected filter from available
            self.availableFilters.remove(at: index)
            
            // If there was a previously selected type that's different, add it back to available
            if let previousType = previouslySelectedType, previousType != selectedFilter.type {
                if let previousFilter = self.filterSection?.first(where: { $0.type == previousType }) {
                    self.availableFilters.append(previousFilter)
                    self.availableFilters.sort { $0.type < $1.type }
                }
            }
            
            self.updateAllTypeDropdowns()
            
            // Update or add to selected filters - reset sort value when type changes
            if let existingIndex = self.selectedFilters.firstIndex(where: { $0.stackIndex == stackIndex }) {
                self.selectedFilters[existingIndex] = (selectedFilter.type, nil, stackIndex)
            } else {
                self.selectedFilters.append((selectedFilter.type, nil, stackIndex))
            }
            
            // Setup sort dropdown with the new filter section
            if let sortView = self.getSortViewForStack(at: stackIndex) {
                self.setupSortDropdown(for: sortView, filterSection: selectedFilter, stackIndex: stackIndex)
            }
            
            // Update button state immediately
            self.updateAddRemoveButton(at: stackIndex)
        }
        
        if dropdowns[stackIndex] == nil {
            dropdowns[stackIndex] = (typeDropdown, nil)
        } else {
            dropdowns[stackIndex]?.typeDropdown = typeDropdown
        }
        
        btn.addTarget(self, action: #selector(showTypeDropdown(_:)), for: .touchUpInside)
    }
    
    // MARK: - Setup Type Dropdown with Preselection
    func setupTypeDropdownWithPreselection(for view: UIView, stackIndex: Int, selectedType: String) {
        view.subviews.forEach { $0.removeFromSuperview() }
        
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle(selectedType, for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemGray4.cgColor
        btn.setTitleColor(.label, for: .normal)
        btn.tag = stackIndex
        
        view.addSubview(btn)
        
        NSLayoutConstraint.activate([
            btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            btn.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            btn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5)
        ])
        
        let typeDropdown = DropDown()
        typeDropdown.anchorView = btn
        typeDropdown.dataSource = availableFilters.map { $0.type }
        typeDropdown.direction = .bottom
        typeDropdown.backgroundColor = .systemBackground
        typeDropdown.selectionBackgroundColor = .systemGray5
        typeDropdown.textColor = .label
        typeDropdown.cornerRadius = 8
        
        typeDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            btn.setTitle(item, for: .normal)
            
            // Get the previously selected type for this stack (if any)
            let previouslySelectedType = self.selectedFilters.first(where: { $0.stackIndex == stackIndex })?.type
            
            // Get the newly selected filter
            let selectedFilter = self.availableFilters[index]
            
            // Remove the newly selected filter from available
            self.availableFilters.remove(at: index)
            
            // If there was a previously selected type that's different, add it back to available
            if let previousType = previouslySelectedType, previousType != selectedFilter.type {
                if let previousFilter = self.filterSection?.first(where: { $0.type == previousType }) {
                    self.availableFilters.append(previousFilter)
                    self.availableFilters.sort { $0.type < $1.type }
                }
            }
            
            self.updateAllTypeDropdowns()
            
            // Update or add to selected filters - reset sort value when type changes
            if let existingIndex = self.selectedFilters.firstIndex(where: { $0.stackIndex == stackIndex }) {
                self.selectedFilters[existingIndex] = (selectedFilter.type, nil, stackIndex)
            } else {
                self.selectedFilters.append((selectedFilter.type, nil, stackIndex))
            }
            
            // Setup sort dropdown with the new filter section
            if let sortView = self.getSortViewForStack(at: stackIndex) {
                self.setupSortDropdown(for: sortView, filterSection: selectedFilter, stackIndex: stackIndex)
            }
            
            // Update button state immediately
            self.updateAddRemoveButton(at: stackIndex)
        }
        
        if dropdowns[stackIndex] == nil {
            dropdowns[stackIndex] = (typeDropdown, nil)
        } else {
            dropdowns[stackIndex]?.typeDropdown = typeDropdown
        }
        
        btn.addTarget(self, action: #selector(showTypeDropdown(_:)), for: .touchUpInside)
    }
    
    // MARK: - Setup Sort Dropdown
    func setupSortDropdown(for view: UIView, filterSection: FilterSection, stackIndex: Int) {
        view.subviews.forEach { $0.removeFromSuperview() }
        
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Sort", for: .normal)
        btn.contentHorizontalAlignment = .center
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemGray4.cgColor
        btn.setTitleColor(.label, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.tag = stackIndex
        
        view.addSubview(btn)
        
        NSLayoutConstraint.activate([
            btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            btn.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            btn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5)
        ])
        
        let sortDropdown = DropDown()
        sortDropdown.anchorView = btn
        sortDropdown.dataSource = filterSection.section
        sortDropdown.direction = .bottom
        sortDropdown.backgroundColor = .systemBackground
        sortDropdown.selectionBackgroundColor = .systemGray5
        sortDropdown.textColor = .label
        sortDropdown.cornerRadius = 8
        
        sortDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            
            let displayText = item
            btn.setTitle(displayText, for: .normal)
            
            if let existingIndex = self.selectedFilters.firstIndex(where: { $0.stackIndex == stackIndex }) {
                self.selectedFilters[existingIndex].sortValue = item
            }
            self.updateAddRemoveButton(at: stackIndex)
            self.notifyParentForSizeUpdate()
        }
        
        if var existing = dropdowns[stackIndex] {
            existing.sortDropdown = sortDropdown
            dropdowns[stackIndex] = existing
        } else {
            dropdowns[stackIndex] = (DropDown(), sortDropdown)
        }
        
        btn.addTarget(self, action: #selector(showSortDropdown(_:)), for: .touchUpInside)
    }
    
    // MARK: - Setup Sort Dropdown with Preselection
    func setupSortDropdownWithPreselection(for view: UIView, filterSection: FilterSection, stackIndex: Int, selectedSort: String) {
        view.subviews.forEach { $0.removeFromSuperview() }
        
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle(selectedSort, for: .normal)
        btn.contentHorizontalAlignment = .center
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.systemGray4.cgColor
        btn.setTitleColor(.label, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.tag = stackIndex
        
        view.addSubview(btn)
        
        NSLayoutConstraint.activate([
            btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            btn.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            btn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5)
        ])
        
        let sortDropdown = DropDown()
        sortDropdown.anchorView = btn
        sortDropdown.dataSource = filterSection.section
        sortDropdown.direction = .bottom
        sortDropdown.backgroundColor = .systemBackground
        sortDropdown.selectionBackgroundColor = .systemGray5
        sortDropdown.textColor = .label
        sortDropdown.cornerRadius = 8
        
        sortDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            
            let displayText = item
            btn.setTitle(displayText, for: .normal)
            
            if let existingIndex = self.selectedFilters.firstIndex(where: { $0.stackIndex == stackIndex }) {
                self.selectedFilters[existingIndex].sortValue = item
            }
            self.updateAddRemoveButton(at: stackIndex)
            self.notifyParentForSizeUpdate()
        }
        
        if var existing = dropdowns[stackIndex] {
            existing.sortDropdown = sortDropdown
            dropdowns[stackIndex] = existing
        } else {
            dropdowns[stackIndex] = (DropDown(), sortDropdown)
        }
        
        btn.addTarget(self, action: #selector(showSortDropdown(_:)), for: .touchUpInside)
    }
    
    // MARK: - Helper Functions
    func getSortViewForStack(at index: Int) -> UIView? {
        return stackViewReferences[index]?.sortView
    }
    
    func getTypeViewForStack(at index: Int) -> UIView? {
        return stackViewReferences[index]?.typeView
    }
    
    // MARK: - Get last visible stack index
    func getLastVisibleStackIndex() -> Int? {
        for i in stride(from: (horizontalstackViews?.count ?? 0) - 1, through: 0, by: -1) {
            if !(horizontalstackViews?[i].isHidden ?? true) {
                return i
            }
        }
        return nil
    }
    
    // MARK: - Check if next stack is visible
    func isNextStackVisible(_ stackIndex: Int) -> Bool {
        let nextIndex = stackIndex + 1
        guard nextIndex < (horizontalstackViews?.count ?? 0) else { return false }
        return !(horizontalstackViews?[nextIndex].isHidden ?? true)
    }
    
    // MARK: - Update Add/Remove Button
    func updateAddRemoveButton(at index: Int) {
        guard index < (addBtns?.count ?? 0) else { return }
        
        let btn = addBtns[index]
        let hasSelectedSort = selectedFilters.first(where: { $0.stackIndex == index })?.sortValue != nil
        
        guard let lastVisibleIndex = getLastVisibleStackIndex() else {
            btn.isHidden = true
            return
        }
        
        // Always show button for visible stacks
        btn.isHidden = false
        
        if index == lastVisibleIndex {
            // Last visible stack
            let nextStackCanBeAdded = !availableFilters.isEmpty && (index + 1) < (horizontalstackViews?.count ?? 0)
            
            if nextStackCanBeAdded && hasSelectedSort {
                // Show plus to add next stack (only if sort is selected)
                btn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
                btn.tintColor = .systemGreen
            } else if index > 0 {
                // Show minus to remove this stack (if not first stack)
                btn.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
                btn.tintColor = .systemRed
            } else {
                // First stack - hide button
                btn.isHidden = true
            }
        } else {
            // Not the last stack - always show minus
            btn.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
            btn.tintColor = .systemRed
        }
    }
    
    func updateAllTypeDropdowns() {
        for (_, dropdown) in dropdowns {
            dropdown.typeDropdown.dataSource = availableFilters.map { $0.type }
        }
    }
    
    // MARK: - Get Visible Stack Count
    func getVisibleStackCount() -> Int {
        let visibleCount = (horizontalstackViews ?? []).filter { !$0.isHidden }.count
        return visibleCount
    }
    
    // MARK: - Notify Parent for Size Update
    func notifyParentForSizeUpdate() {
        let visibleStackCount = getVisibleStackCount()
        if let parentVC = self.presentingViewController as? EnterMarkVC {
            parentVC.updatePopoverSizeForStackCount(visibleStackCount)
        }
    }
    
    // MARK: - Dropdown Actions
    @objc func showTypeDropdown(_ sender: UIButton) {
        let stackIndex = sender.tag
        if let dropdown = dropdowns[stackIndex]?.typeDropdown {
            dropdown.show()
        }
    }
    
    @objc func showSortDropdown(_ sender: UIButton) {
        let stackIndex = sender.tag
        if let sortDropdown = dropdowns[stackIndex]?.sortDropdown {
            sortDropdown.show()
        }
    }
    
    // MARK: - Toggle Add/Remove Button Action
    @objc func toggleAddRemoveBtn(_ sender: UIButton) {
        let stackIndex = sender.tag
        
        // Check if this is a plus or minus button based on tint color
        if sender.tintColor == .systemGreen {
            // It's a plus button - add next stack
            addNextStack(from: stackIndex)
        } else {
            // It's a minus button - remove current stack
            removeStack(at: stackIndex)
        }
    }
    
    // MARK: - Add Next Stack
    func addNextStack(from currentStackIndex: Int) {
        guard !availableFilters.isEmpty else {
            showAlert(message: "No more filters available")
            return
        }
        
        let nextIndex = currentStackIndex + 1
        
        guard nextIndex < (horizontalstackViews?.count ?? 0) else {
            showAlert(message: "Maximum filters reached")
            return
        }
        
        horizontalstackViews[nextIndex].isHidden = false
        if let typeView = getTypeViewForStack(at: nextIndex) {
            setupTypeDropdown(for: typeView, stackIndex: nextIndex)
        }
        
        if let sortView = getSortViewForStack(at: nextIndex),
           let firstFilter = availableFilters.first {
            setupSortDropdown(for: sortView, filterSection: firstFilter, stackIndex: nextIndex)
        }
        
        updateAddRemoveButton(at: currentStackIndex)
        updateAddRemoveButton(at: nextIndex)
        notifyParentForSizeUpdate()
    }
    
    // MARK: - Remove Stack
    func removeStack(at stackIndex: Int) {
        if let selectedFilter = selectedFilters.first(where: { $0.stackIndex == stackIndex }) {
            if let originalFilter = filterSection?.first(where: { $0.type == selectedFilter.type }) {
                availableFilters.append(originalFilter)
                availableFilters.sort { $0.type < $1.type }
            }
        }
        
        selectedFilters.removeAll { $0.stackIndex == stackIndex }
        dropdowns.removeValue(forKey: stackIndex)
        
        horizontalstackViews[stackIndex].isHidden = true
        
        if let typeView = getTypeViewForStack(at: stackIndex) {
            typeView.subviews.forEach { $0.removeFromSuperview() }
        }
        if let sortView = getSortViewForStack(at: stackIndex) {
            sortView.subviews.forEach { $0.removeFromSuperview() }
        }
        
        updateAllTypeDropdowns()
        for i in 0..<(horizontalstackViews?.count ?? 0) {
            if !(horizontalstackViews?[i].isHidden ?? true) {
                updateAddRemoveButton(at: i)
            }
        }
        
        notifyParentForSizeUpdate()
    }
    
    @IBAction func applySort(_ sender: UIButton) {
        let completeFilters = selectedFilters.filter { $0.sortValue != nil }
        
        guard !completeFilters.isEmpty else {
            showAlert(message: "Please select at least one filter with sort option")
            return
        }
        
        let filtersToApply = completeFilters.map { (type: $0.type, sortValue: $0.sortValue!) }
        
        // Store filters for next reload
        previouslyAppliedFilters = filtersToApply
        
        delegate?.didApplyFilters(filtersToApply)
        dismiss(animated: true)
    }
    
    @IBAction func clearSort(_ sender: UIButton) {
        availableFilters = filterSection ?? []
        selectedFilters.removeAll()
        dropdowns.removeAll()
        previouslyAppliedFilters.removeAll()
        
        for (index, stack) in (horizontalstackViews ?? []).enumerated() {
            if index == 0 {
                if let typeView = getTypeViewForStack(at: 0) {
                    setupTypeDropdown(for: typeView, stackIndex: 0)
                }
                if let sortView = getSortViewForStack(at: 0),
                   let firstFilter = filterSection?.first {
                    setupSortDropdown(for: sortView, filterSection: firstFilter, stackIndex: 0)
                }
                updateAddRemoveButton(at: 0)
            } else {
                stack.isHidden = true
            }
        }
        
        delegate?.didApplyFilters([])
        notifyParentForSizeUpdate()
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Filter", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

struct FilterSection {
    let type: String
    let section: [String]
}
