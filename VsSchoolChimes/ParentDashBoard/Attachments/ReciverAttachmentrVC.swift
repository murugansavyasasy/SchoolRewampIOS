//
//  ReciverAttachmentrVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 18/04/25.
//

import UIKit
import DropDown

class ReciverAttachmentrVC: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var fiterView: UIView!
    @IBOutlet weak var standerd: UILabel!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var attachmentTable: UITableView!
    var attachmentData:[Attachment]?
    var filteredAttachments:[Attachment]?
    var filterDropDown = DropDown()
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var shouldShowFooter = false
    override func viewDidLoad() {
        super.viewDidLoad()
        studentName.text = studentDetails?.name
        standerd.text = "\(studentDetails?.standard_name ?? ""),\(studentDetails?.section_name ?? "")"
        studentName.setFont(style: .body, size: FontSize.BodySize)
        standerd.setFont(style: .body, size:10)
        setupView()
//        fetchAttachments()
        setupTableFooter()
    }
    func setupTableFooter() {
        if shouldShowFooter {
            if let footer = Bundle.main.loadNibNamed("SeeMoreFooterView", owner: self, options: nil)?.first as? SeeMoreFooterView {
                footer.frame = CGRect(x: 0, y: 0, width: attachmentTable.frame.width, height: 60)
                let seeMoreTap = UITapGestureRecognizer(target: self, action: #selector(seeMoreAction))
                footer.SeeMoreBtn.addGestureRecognizer(seeMoreTap)
                footer.SeeMoreBtn.isUserInteractionEnabled = true
                attachmentTable.tableFooterView = footer
            }
        } else {
            attachmentTable.tableFooterView = nil
        }
    }
    
    @objc func seeMoreAction() {
        print("Footer button tapped. Hiding the footer.")
        
        // Animate the footer fade-out if desired.
        if let footer = attachmentTable.tableFooterView {
            UIView.animate(withDuration: 0.3, animations: {
                footer.alpha = 0
            }, completion: {[self] _ in
                // Hide the footer after animation completes.
                attachmentTable.tableFooterView = nil
                shouldShowFooter = false
                fetchAttachments()
            })
        } else {
            // In case footer is already nil.
            shouldShowFooter = false
        }
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    private func setupView() {
        RegisterCell()
        searchBar.delegate = self
        searchBar.placeholder = CommonStringFile.Search.translated()
        
        let filterTap = UITapGestureRecognizer(target: self, action: #selector(showFilterOptions))
        fiterView.addGestureRecognizer(filterTap)
    }
    
    @objc private func showFilterOptions() {
        filterDropDown.anchorView = fiterView
        filterDropDown.dataSource = ["All", "Image", "Video", "Pdf"]
        filterDropDown.bottomOffset = CGPoint(x: 0, y: fiterView.bounds.height)
        filterDropDown.show()
        
        filterDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            self?.applyFilter(type: item.uppercased())
        }

    }
    
    private func applyFilter(type: String) {
        if type == "ALL" {
            filteredAttachments = attachmentData
        } else {
            filteredAttachments = attachmentData?.filter { $0.type?.uppercased() == type }
        }
        attachmentTable.reloadData()
    }
    
    private func fetchAttachments() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_communication_attachment_list_archive,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjaGlsZF9pZCI6IjkzNjM1MTkiLCJzY2hvb2xfaWQiOiI1NTEyIiwiY2xhc3NfaWQiOjIyMzEsInNlY3Rpb25faWQiOjg5NDUsImlhdCI6MTc0NDI2MzQ0MH0.4eXMhZIWU0ymmOPCTs3iBANhRwhJqft3Rp89ITh79Ts"
        ) { [weak self] (result: Result<AttachmentsResponse, Error>) in
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self?.hideLottieProgressLoader()
                }
                
                switch result {
                case .success(let response):
                    self?.attachmentData = response.data
                    self?.filteredAttachments = response.data
                    self?.attachmentTable.reloadData()
                case .failure(let error):
                    print("Error fetching attachments:", error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    private func RegisterCell() {
        attachmentTable.register(UINib(nibName: CellConfingName.TAttacmentTVC, bundle: nil),
                                 forCellReuseIdentifier: CellConfingName.TAttacmentTVC)
        
        attachmentTable.register(UINib(nibName: CellConfingName.VideoTVCell, bundle: nil),
                                 forCellReuseIdentifier: CellConfingName.VideoTVCell)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredAttachments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = filteredAttachments?[indexPath.row] else {
            return UITableViewCell() // Safely return a default cell if data is nil
        }

        switch data.type?.uppercased() {
        case "VIDEO":
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.VideoTVCell, for: indexPath) as! VideoTVCell
            cell.descriptContent.text = data.description
            cell.datelbl.text = data.date
            cell.videoName.text = data.title
            return cell

        case "DOCUMENT":
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.TAttacmentTVC, for: indexPath) as! TAttacmentTVC
            cell.titleLbl.text = data.title
            cell.descriptionLbl.text = data.description
            cell.dateLbl.text = data.date
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.TAttacmentTVC, for: indexPath) as! TAttacmentTVC
            cell.titleLbl.text = data.title
            cell.descriptionLbl.text = data.description
            cell.dateLbl.text = data.date
            cell.homeworkDocs = data.file_path
            return cell
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Search Bar Delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filteredAttachments = attachmentData
            attachmentTable.reloadData()
            return
        }
        
        filteredAttachments = attachmentData?.filter {
            ($0.title?.lowercased().contains(searchText.lowercased()) ?? false) ||
            ($0.description?.lowercased().contains(searchText.lowercased()) ?? false) ||  ($0.date?.lowercased().contains(searchText.lowercased()) ?? false)
        }
        attachmentTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredAttachments = attachmentData
        attachmentTable.reloadData()
    }
}
