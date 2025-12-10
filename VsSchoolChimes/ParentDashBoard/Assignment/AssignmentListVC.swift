protocol SumitionDelegate{
    func sumition(index:Int)
}

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
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var searchview: UISearchBar!
    @IBOutlet weak var MenuNameLbl: UILabel!
    
    var didSelectDelegate : DidSelectDelegate?
    var data : [Report]?
    var filteredData :[Report]?
    var calendarItems: [AssignmentCalendar] = []
    var shouldShowFooter = true
    var tapGesture: UITapGestureRecognizer?
    var selectedIndexPath: IndexPath?
    let today = Date()
    let transitionDelegate = TransitioningDelegate()
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var clickedMessageId: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        let Name = studentDetails?.name ?? ""
        let Standard = (studentDetails?.standard_name ?? "") + " - " + (studentDetails?.section_name ?? "")
        NameLbl.configureAsBackTitle(firstLine: Name, secondLine: Standard)
        MenuNameLbl.text = MenuStringFile.selectedMenuName
        nodataLbl.setFont(style: .title, size: FontSize.HeaderSize)
        searchview.placeholder = CommonStringFile.Search.translated()
        searchview.delegate = self
        searchview.searchTextField.addDoneButton()
        searchview.isHidden = true
        searchview.backgroundImage = UIImage()
        calendarItems = getAllPastDatesIncludingTodayForLastMonth()
        nodataLbl.isHidden = true
        noRecordImg.isHidden = true
        register()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAssigment()
    }
    func getAssigment() {
        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        APIService.shared.makeApi(
            url: ServiceUrl.comm_api_assignment_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<AssignmentReportResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                        
                            self?.data = response.data ?? []
                            self?.filteredData = self?.data
                            let isEmpty = self?.data?.isEmpty ?? true
                            self?.nodataLbl.isHidden = !isEmpty
                            self?.nodataLbl.text = isEmpty ? response.message : CommonStringFile.No_data_found
                            self?.noRecordImg.isHidden = !isEmpty
                            self?.searchBtn.isHidden = isEmpty
                            self?.listTable.reloadData()
                    
                    if !isEmpty{
                        if self?.clickedMessageId != ""{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self?.scrollToClickedMessage()
                            }
                        }
                    }
                    
                    if response.status == true{
                        if user_inputs.clearTempData(){
                            let parms = [ "mobile_number": UserDefaultFileManager.get_child_Details()?.whatsapp_number ?? "",
                                          "activity": "VIEW_ASSIGNMENT",
                                          "user_type": 1,
                                          "menu_id": Menu_id.staffSelectedMenuId] as [String : Any]
                                self?.paketApiCall(params:parms)
                        }
                    }
                    
                case .failure(let error):
                    self?.nodataLbl.isHidden = false
                    self?.noRecordImg.isHidden = false
                    self?.searchBtn.isHidden = true
                    self?.nodataLbl.text = error.localizedDescription
                    print("API Error: \(error.localizedDescription)")
                }
                if #available(iOS 15.0, *) {
                    self?.hideActivityLoader()
                }
            }
        }
    }
    private func scrollToClickedMessage() {
        guard let id = clickedMessageId,
              let index = filteredData?.firstIndex(where: { $0.header_id == id }) else {
            return
        }

        let indexPath = IndexPath(row: index, section: 0)
        
        // Scroll to that cell smoothly
        listTable.scrollToRow(at: indexPath, at: .middle, animated: true)
        
        // Optionally highlight the cell for 1 second
        if let cell = listTable.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.3, animations: {
                cell.contentView.backgroundColor = UIColor.lightGray
                    .withAlphaComponent(0.3)
            }) { _ in
                UIView.animate(withDuration: 0.5, delay: 1.0, options: []) {
                    cell.contentView.backgroundColor = .white
                }
            }
        }
    }
    func paketApiCall(params:[String:Any]){
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_pauket_add_points,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {

                guard let self = self else { return }

                switch result {
                case .success(let response):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(response.message, duration: 2.0, position: .bottom)
                    }
                case .failure(let error):
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(error.localizedDescription, duration: 2.0, position: .bottom)
                    }
                }
            }
        }
    }

    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func search(_ sender: UIButton) {
       
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        searchBtn.setImage(UIImage(systemName: icon), for: .normal)
        searchview.isHidden = !sender.isSelected
       if sender.isSelected{
            searchview.becomeFirstResponder()
       }else {
           view.endEditing(true)
           searchview.searchTextField.text = ""
           filteredData = data
           let isEmpty = filteredData?.isEmpty ?? true
           nodataLbl.isHidden = !isEmpty
           noRecordImg.isHidden = !isEmpty
           nodataLbl.text = CommonStringFile.No_data_found
           listTable.reloadData()
       }
    }
    func register(){
        listTable.register(UINib(nibName: CellConfingName.AssignmentListCTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.AssignmentListCTVC)
        listTable.register(UINib(nibName: "AssignmentTVC", bundle: nil), forCellReuseIdentifier: "AssignmentTVC")
    }
    
}

// Table view delegate and data source
extension AssignmentListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: "AssignmentTVC", for: indexPath) as! AssignmentTVC
        if let report = filteredData?[indexPath.row]{
            cell.configure(with: report)
            cell.id = report.header_id
            cell.subject = report.subject
            cell.readVieaw.isHidden = !(report.is_unread ?? false)
            cell.loadFiles(into: cell, files: report.file_path ?? [])
            cell.mysubmitBtn.isHidden = report.submitted_count == 0
        }
        cell.submittedProgressStack.isHidden = true
        cell.editBtn.isHidden = true
        
        cell.submitBtnStack.isHidden = false
        cell.layoutIfNeeded()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath),
              indexPath.row < filteredData?.count ?? 0 else { return }
        
        let cellFrameInSuperview = tableView.convert(cell.frame, to: view)
        
        let detailVC = AssignmentPriview()
        let selectedItem = filteredData?[indexPath.row]
        detailVC.data = selectedItem
        detailVC.userNameValue = UserDefaultFileManager.get_child_Details()?.name
        detailVC.sectionValue = UserDefaultFileManager.get_child_Details()?.school_name
        detailVC.onDismiss = { [weak self] in
            self?.getAssigment()
        }
        detailVC.reciver = true
        detailVC.modalPresentationStyle = .custom
        transitionDelegate.originFrame = cellFrameInSuperview
        detailVC.transitioningDelegate = transitionDelegate
        
        present(detailVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func select(index: Int, value: String?, Img: [String], Pdf: String?, text: String?, type: String) {
        didSelectDelegate?.select(index: index, value: value,Img:Img,Pdf:Pdf,text:text,type:type)
    }
    
  
    func getAllPastDatesIncludingTodayForLastMonth() -> [AssignmentCalendar] {
          var items: [AssignmentCalendar] = []
          let calendar = Calendar.current
          let today = Date()
          
          guard let pastStartDate = calendar.date(byAdding: .month, value: -6, to: today) else {
              return items
          }

          var currentDate = pastStartDate
          while currentDate <= today {
              let weekday = calendar.component(.weekday, from: currentDate)
              var status: DotStatus? = nil
              if weekday == 4 { status = .red }
              if weekday == 7 { status = .green }

              items.append(AssignmentCalendar(date: currentDate, status: status))
              guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                  break
              }
              currentDate = nextDate
          }
          return items
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

struct AssignmentCalendar {
    var date: Date
    var status: DotStatus?
}

enum DotStatus {
    case red
    case green
}
extension Date {
    func getMonthName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: self)
    }
}
