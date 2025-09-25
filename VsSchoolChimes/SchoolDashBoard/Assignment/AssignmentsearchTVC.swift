//
//  AssignmentsearchTVC.swift
//  School Chimes
//
//  Created by Chandhru on 08/08/25.
//

import UIKit

protocol SearchDelegate: AnyObject {
    func searchText(_ text: String)
}

class AssignmentsearchTVC: UITableViewCell, UISearchBarDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var submitedBtn: UIButton!
    @IBOutlet weak var pendingBtn: UIButton!
    @IBOutlet weak var allLbl: UILabel!
    @IBOutlet weak var submitLbl: UILabel!
    @IBOutlet weak var pendingLbl: UILabel!
    
    // MARK: - Properties
    weak var delegate: SearchDelegate?
    private var selectedTab: Int = 0
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        searchBar.delegate = self
        updateTabUI()
    }
    
    // MARK: - Actions
    @IBAction func switchTab(_ sender: UIButton) {
        selectedTab = sender.tag
        updateTabUI()
    }
    
    // MARK: - Helper
    private func updateTabUI() {
        // Hide all labels first
        allLbl.isHidden = true
        submitLbl.isHidden = true
        pendingLbl.isHidden = true
        allBtn.tintColor = .black
        submitedBtn.tintColor = .black
        pendingBtn.tintColor = .black
        searchBar.placeholder = "Search here..."
        searchBar.backgroundImage = UIImage()
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.addDoneButton()
        }
        // Show the selected one
        switch selectedTab {
        case 0:
            allLbl.isHidden = false
            delegate?.searchText("All")
            allBtn.tintColor = .blue
        case 1:
            submitLbl.isHidden = false
            delegate?.searchText("Submited")
            submitedBtn.tintColor = .blue
        case 2:
            pendingLbl.isHidden = false
            delegate?.searchText("Pending")
            pendingBtn.tintColor = .blue
        default: break
        }
    }
    
    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        sender.setImage(UIImage(systemName: icon), for: .normal)
        searchBar.isHidden = !sender.isSelected
        delegate?.searchText("true")
        if !sender.isSelected{
            searchBar.endEditing(true)
        }
    }
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchText(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
