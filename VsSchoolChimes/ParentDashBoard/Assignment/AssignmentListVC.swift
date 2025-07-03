import UIKit

class AssignmentListVC: UIViewController, DidSelectDelegate, SumitionDelegate{
    func sumition(index: Int) {
        if #available(iOS 14.0, *) {
            let vc = SubmitVC(nibName: nil, bundle: nil)
            vc.id = filteredData?[index].header_id
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false)
        }
       
    }
    
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var noRecordImg: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var searchview: UISearchBar!
    
    var didSelectDelegate : DidSelectDelegate?
    var data : [Assignment]?
    var filteredData :[Assignment]?
    var shouldShowFooter = true
    var tapGesture: UITapGestureRecognizer?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NameLbl.text = studentDetails?.name
        StandardLbl.text = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        backBtn.setTitle(ReceiverMenuItems.Assignment.translated(), for: .normal)
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        HeaderLabel.setFont(style: .header, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        nodataLbl.setFont(style: .title, size: FontSize.HeaderSize)
        searchview.placeholder = CommonStringFile.Search.translated()
        searchview.delegate = self
        searchview.searchTextField.addDoneButton()
        nodataLbl.isHidden = true
        noRecordImg.isHidden = true
        searchview.isHidden = true
        setupTableFooter()
        register()
        getAssigment()
    }
    
    func getAssigment() {
        
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<AssignmentResponse, Error>) in
            
            DispatchQueue.main.async {
                
                if #available(iOS 15.0, *) {
                    self?.hideLottieProgressLoader()
                }
                
                switch result {
                case .success(let response):
                        
                            self?.data = response.data ?? []
                            self?.filteredData = self?.data
                            let isEmpty = self?.data?.isEmpty ?? true
                            self?.nodataLbl.isHidden = !isEmpty
                            self?.nodataLbl.text = isEmpty ? response.message : CommonStringFile.No_data_found
                            self?.noRecordImg.isHidden = !isEmpty
                            self?.searchview.isHidden = isEmpty
                            
                            self?.listTable.reloadData()
                        
                case .failure(let error):
                    self?.nodataLbl.isHidden = false
                    self?.noRecordImg.isHidden = false
                    self?.nodataLbl.text = error.localizedDescription
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
    }
    func getArchiveAssigment() {
        
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_list_archive,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<AssignmentResponse, Error>) in
            
            DispatchQueue.main.async {
                
                if #available(iOS 15.0, *) {
                    self?.hideLottieProgressLoader()
                }
                
                switch result {
                    
                case .success(let response):
                    
                    self?.data?.append(contentsOf: response.data ?? [])
                    self?.filteredData = self?.data
                    let isEmpty = self?.data?.isEmpty ?? true
                    self?.nodataLbl.isHidden = !isEmpty
                    self?.nodataLbl.text = isEmpty ? response.message : CommonStringFile.No_data_found
                    self?.noRecordImg.isHidden = !isEmpty
                    self?.searchview.isHidden = isEmpty
                    self?.listTable.reloadData()
                    
                case .failure(let error):
                    
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
    }
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    func register(){
        listTable.register(UINib(nibName: CellConfingName.AssignmentListCTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.AssignmentListCTVC)
    }
    
}

// Table view delegate and data source
extension AssignmentListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData?.count ?? 0 // Adjust this based on your data
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: CellConfingName.AssignmentListCTVC, for: indexPath) as! AssignmentListCTVC
        cell.tittleLbl.text = filteredData?[indexPath.row].title
        cell.DescriptionLbl.setupExpandable(text: filteredData?[indexPath.row].description ?? "")
        cell.DescriptionLbl.onExpandableTap = {
            
            cell.DescriptionLbl.isExpanded.toggle()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        cell.categoryLbl.text = filteredData?[indexPath.row].category
        if !isDueDatePassed(dueDate: filteredData?[indexPath.row].end_date ?? "") {
            cell.dueDateLbl.textColor = .black
        } else {
            cell.dueDateLbl.textColor = .red
        }
        cell.id = filteredData?[indexPath.row].header_id
        cell.assignmentId = filteredData?[indexPath.row].id
        cell.FilesUrl = filteredData?[indexPath.row].file_path
        cell.dueDateLbl.text = filteredData?[indexPath.row].end_date?.convertToTargetDateFormat()
        cell.CreaterdDate.text = filteredData?[indexPath.row].date
        cell.sendByLbl.text = filteredData?[indexPath.row].sent_by
        cell.Delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func ViewAct(_ sender: Any){
        let vc = ImageShowVc(nibName: nil, bundle: nil)
//        vc.FileURL = fileUrl
        vc.type = 0
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func select(index: Int, value: String?, Img: [String], Pdf: String?, text: String?, type: String) {
        didSelectDelegate?.select(index: index, value: value,Img:Img,Pdf:Pdf,text:text,type:type)
    }
    
    // Method to load the footer from nib and set it as tableFooterView
    func setupTableFooter() {
        if shouldShowFooter {
            if let footer = Bundle.main.loadNibNamed("SeeMoreFooterView", owner: self, options: nil)?.first as? SeeMoreFooterView {
                // Adjust the frame based on your needs.
                footer.frame = CGRect(x: 0, y: 0, width: listTable.frame.width, height: 200)
               
                let buttonTitle = "See More"
                let attributedString = NSMutableAttributedString(string: buttonTitle)

                let customFont = UIFont(name: "Poppins-Medium", size: 17) ?? UIFont.systemFont(ofSize: 18)
                attributedString.addAttribute(.font, value: customFont, range: NSRange(location: 0, length: buttonTitle.count))
                
                // Apply underline style
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: buttonTitle.count))

                // Set attributed title to UIButton
                footer.SeeMoreBtn.setAttributedTitle(attributedString, for: .normal)

                let seeMoreTap = UITapGestureRecognizer(target: self, action: #selector(seeMoreAction))
                footer.SeeMoreBtn.addGestureRecognizer(seeMoreTap)
                footer.SeeMoreBtn.isUserInteractionEnabled = true
                
                // Set the footer view.
                listTable.tableFooterView = footer
            }
        } else {
            listTable.tableFooterView = nil
        }
    }
    
    @objc func seeMoreAction() {
        print("Footer button tapped. Hiding the footer.")
        
        if let footer = listTable.tableFooterView {
            UIView.animate(withDuration: 0.3, animations: {
                footer.alpha = 0
            }, completion: {[self] _ in
                
                getArchiveAssigment()
                
                listTable.tableFooterView = nil
                shouldShowFooter = false
            })
        } else {
            
            shouldShowFooter = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
}

extension AssignmentListVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let data = data else { return }

        let lowercasedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if lowercasedQuery.isEmpty {
            filteredData = data
        } else {
            filteredData = data.filter { item in
                let title = item.title?.lowercased() ?? ""
                let subject = item.subject?.lowercased() ?? ""
                let endDate = item.end_date?.lowercased() ?? ""
                let sentBy = item.sent_by?.lowercased() ?? ""
                let category = item.category?.lowercased() ?? ""

                return title.contains(lowercasedQuery) ||
                       subject.contains(lowercasedQuery) ||
                       endDate.contains(lowercasedQuery) ||
                       sentBy.contains(lowercasedQuery) ||
                       category.contains(lowercasedQuery)
            }
        }

        // Update No Data UI
        let isEmpty = filteredData?.isEmpty ?? true
        nodataLbl.isHidden = !isEmpty
        noRecordImg.isHidden = !isEmpty
        nodataLbl.text = CommonStringFile.No_data_found

        listTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredData = data
        listTable.reloadData()
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
    }
}
