import UIKit

class AssignmentListVC: UIViewController,UISearchBarDelegate, DidSelectDelegate, SumitionDelegate{
    func sumition(index: Int) {
        if #available(iOS 14.0, *) {
            let vc = SubmitVC(nibName: nil, bundle: nil)
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
    override func viewDidLoad() {
        super.viewDidLoad()
       
        backBtn.setTitle(ReceiverMenuItems.Assignment.translated(), for: .normal)
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        HeaderLabel.setFont(style: .header, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        filteredData = data
        searchview.placeholder = CommonStringFile.Search.translated()
        searchview.delegate = self
        searchview.layer.borderWidth = 0
        searchview.backgroundImage = UIImage()
        searchview.addDoneButton()
        getAssigment()
        setupTableFooter()
        register()
    }
    func getAssigment() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<AssignmentResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status == true {
                    DispatchQueue.main.async {
                        self?.data = response.data ?? []
                        self?.filteredData = self?.data
                        let isEmpty = self?.data?.isEmpty ?? true
                        self?.nodataLbl.isHidden = !isEmpty
                        self?.nodataLbl.text = isEmpty ? response.message : ""
                        self?.noRecordImg.isHidden = !isEmpty

                        self?.listTable.reloadData()
                    }
                }
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
            }
        }
    }
    func getArchiveAssigment() {
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_list_archive,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<AssignmentResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status == true {
                    DispatchQueue.main.async {
                        self?.data = response.data ?? []
                        self?.filteredData = self?.data
                        let isEmpty = self?.data?.isEmpty ?? true
                        self?.nodataLbl.isHidden = !isEmpty
                        self?.nodataLbl.text = isEmpty ? response.message : ""
                        self?.noRecordImg.isHidden = !isEmpty

                        self?.listTable.reloadData()
                    }
                }
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
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
    func isDueDatePassed(dueDate: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        guard let dueDateObject = dateFormatter.date(from: dueDate) else {
            print("Invalid date format")
            return false
        }
        let currentDate = Calendar.current.startOfDay(for: Date())
        
        // Compare dueDate with currentDate
        return dueDateObject < currentDate
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Automatically show the keyboard when search bar is clicked
        searchBar.becomeFirstResponder()
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
        if !isDueDatePassed(dueDate: filteredData?[indexPath.row].end_date ?? "") {
            cell.dueDateLbl.textColor = .black
        } else {
            cell.dueDateLbl.textColor = .red
        }
        cell.FilesUrl = filteredData?[indexPath.row].file_path
        cell.dueDateLbl.text = filteredData?[indexPath.row].end_date
        cell.CreaterdDate.text = filteredData?[indexPath.row].date
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
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredData = data
        } else {
            filteredData = data?.filter {
                ($0.title?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ($0.subject?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ($0.end_date?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ($0.sent_by?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ("\($0.submitted_count ?? 0)".contains(searchText))
            }
        }
        listTable.reloadData()
    }

    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredData = data
        listTable.reloadData()
        searchBar.endEditing(true)
        searchBar.resignFirstResponder()
    }
    func setupTableFooter() {
        if shouldShowFooter {
            if let footer = Bundle.main.loadNibNamed("SeeMoreFooterView", owner: self, options: nil)?.first as? SeeMoreFooterView {
                footer.frame = CGRect(x: 0, y: 0, width: listTable.frame.width, height: 60)
                let buttonTitle = "See More"
                let attributedString = NSMutableAttributedString(string: buttonTitle)
                
                let customFont = UIFont(name: "Poppins-Medium", size: 17) ?? UIFont.systemFont(ofSize: 18)
                attributedString.addAttribute(.font, value: customFont, range: NSRange(location: 0, length: buttonTitle.count))
                
                // Apply underline style
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: buttonTitle.count))
                footer.SeeMoreBtn.setAttributedTitle(attributedString, for: .normal)
                let seeMoreTap = UITapGestureRecognizer(target: self, action: #selector(seeMoreAction))
                footer.SeeMoreBtn.addGestureRecognizer(seeMoreTap)
                footer.SeeMoreBtn.isUserInteractionEnabled = true
                listTable.tableFooterView = footer
            }
        } else {
            listTable.tableFooterView = nil
        }
    }
    
    @objc func seeMoreAction() {
        if let footer = listTable.tableFooterView {
            UIView.animate(withDuration: 0.3, animations: {
                footer.alpha = 0
            }, completion: {[self] _ in
                // Hide the footer after animation completes.
                listTable.tableFooterView = nil
                shouldShowFooter = false
                getArchiveAssigment()
            })
        } else {
            // In case footer is already nil.
            shouldShowFooter = false
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
}
