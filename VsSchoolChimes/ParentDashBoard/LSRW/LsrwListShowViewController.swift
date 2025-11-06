//
//  LsrwListShowViewController.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 11/20/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class LsrwListShowViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var nodataImg: UIImageView!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    
    private let rowIdentifier = "NewLSRWTVcell"
    private var tasks: [LSRWTask] = []
    private var filteredTasks: [LSRWTask] = []
    
    var instituteId = Int()
    var studentId = String()
    var childDetails = UserDefaultFileManager.get_child_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setup
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.delegate = self
        searchBar.searchTextField.addDoneButton()
        searchBar.searchTextField.backgroundColor = .systemGray5
        searchBar.layer.cornerRadius = 8
        searchBar.searchTextField.layer.masksToBounds = true
        backBtn.applyBackButton()
        backBtn.configureAsBackButton(
            firstLine: "\(childDetails?.name ?? "")",
            secondLine: "\(childDetails?.standard_name ?? "") - \(childDetails?.section_name ?? "")"
        )
        
        let formattedText = breakIntoLines(text: ReceiverMenuItems.LSRW.translated(), maxCharactersPerLine: 15)
        backBtn.setTitle(formattedText, for: .normal)
        backBtn.titleLabel?.numberOfLines = 0
        backBtn.titleLabel?.lineBreakMode = .byWordWrapping
        
        tv.register(UINib(nibName: rowIdentifier, bundle: nil), forCellReuseIdentifier: rowIdentifier)
        tv.delegate = self
        tv.dataSource = self
        tv.estimatedRowHeight = 80
        tv.rowHeight = UITableView.automaticDimension
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SkillListApi()
    }
    private func SkillListApi() {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.lms_api_lsrw_skill_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: childDetails?.access_token ?? ""
        ) { [weak self] (result: Result<LSRWListResponse, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self?.hideActivityLoader()
                }
                
                switch result {
                case .success(let response):
                    self?.tasks = response.data ?? []
                    self?.filteredTasks = self?.tasks ?? []
                    self?.nodataImg.isHidden = !(self?.filteredTasks.isEmpty ?? true)
                    self?.nodataLbl.isHidden = !(self?.filteredTasks.isEmpty ?? true)
                    self?.nodataLbl.text = response.message ?? ""
                    self?.tv.reloadData()
                    
                case .failure(let error):
                    print("API Error:", error)
                    self?.nodataImg.isHidden = !(self?.filteredTasks.isEmpty ?? true)
                    self?.nodataLbl.isHidden = !(self?.filteredTasks.isEmpty ?? true)
                    self?.nodataLbl.text = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func takeReadingSkill() {
        let vc = LSRWTakingSkillViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func search(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if sender.isSelected {
            searchBar.isHidden = false
            searchBar.becomeFirstResponder()
            searchBtn.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        } else {
            searchBar.resignFirstResponder()
            searchBar.isHidden = true
            searchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        }
        filteredTasks = tasks
        nodataImg.isHidden = !filteredTasks.isEmpty
        nodataLbl.isHidden = !filteredTasks.isEmpty
        nodataLbl.text = ""
        tv.reloadData()
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: rowIdentifier, for: indexPath) as? NewLSRWTVcell else {
            return UITableViewCell()
        }
        
        let item = filteredTasks[indexPath.row]
        cell.configure(with: item)
        cell.readVieaw.isHidden = !(item.is_unread ?? false)
        cell.startBtn.tag = indexPath.row
        cell.starticon.tag = indexPath.row
        cell.startBtn.addTarget(self, action: #selector(AttachmentRedirect(_:)), for: .touchUpInside)
        cell.starticon.addTarget(self, action: #selector(AttachmentRedirect(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc private func AttachmentRedirect(_ sender: UIButton) {
        let index = sender.tag
        guard filteredTasks.indices.contains(index) else { return }
        
        let selectedTask = filteredTasks[index]
        
        if #available(iOS 15.0, *) {
            let vc = LSRWActivitesVC(nibName: nil, bundle: nil)
            vc.lsrw = selectedTask
            vc.onDismiss = { [weak self] in
                self?.SkillListApi()
            }
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    // MARK: - Search Bar
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredTasks = tasks
        } else {
            filteredTasks = tasks.filter {
                ($0.title ?? "").lowercased().contains(searchText.lowercased()) ||
                ($0.description ?? "").lowercased().contains(searchText.lowercased()) ||
                ($0.subject ?? "").lowercased().contains(searchText.lowercased()) ||
                ($0.activity_type?.displayName.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        
        nodataImg.isHidden = !filteredTasks.isEmpty
        nodataLbl.isHidden = !filteredTasks.isEmpty
        nodataLbl.text = "No Data Found"
        tv.reloadData()
    }
    
    // MARK: - Helper
    private func breakIntoLines(text: String, maxCharactersPerLine: Int) -> String {
        var result = ""
        var currentLine = ""
        
        for word in text.split(separator: " ") {
            if currentLine.count + word.count + 1 <= maxCharactersPerLine {
                currentLine += (currentLine.isEmpty ? "" : " ") + word
            } else if word.count > maxCharactersPerLine {
                if !currentLine.isEmpty {
                    result += currentLine + "\n"
                    currentLine = ""
                }
                var startIndex = word.startIndex
                while startIndex < word.endIndex {
                    let endIndex = word.index(startIndex, offsetBy: maxCharactersPerLine, limitedBy: word.endIndex) ?? word.endIndex
                    result += word[startIndex..<endIndex] + "\n"
                    startIndex = endIndex
                }
            } else {
                result += currentLine + "\n"
                currentLine = String(word)
            }
        }
        result += currentLine
        return result
    }
}

// MARK: - Gesture
class LsrwListShowGesture: UITapGestureRecognizer {
    var getSkillId: String?
}
