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
    
    @IBOutlet weak var calanderCollectionView: UICollectionView!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var noRecordImg: UIImageView!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var searchview: UISearchBar!
    
    var didSelectDelegate : DidSelectDelegate?
    var data : [Report]?
    var filteredData :[Report]?
    var calendarItems: [AssignmentCalendar] = []
    var shouldShowFooter = true
    var tapGesture: UITapGestureRecognizer?
    var selectedIndexPath: IndexPath?
    let today = Date()
    var studentDetails = UserDefaultFileManager.get_child_Details()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NameLbl.text = studentDetails?.name
        StandardLbl.text = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        monthBtn.setShadow()
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        nodataLbl.setFont(style: .title, size: FontSize.HeaderSize)
        searchview.placeholder = CommonStringFile.Search.translated()
        searchview.delegate = self
        calendarItems = getAllPastDatesIncludingTodayForLastMonth()
        if let todayIndex = calendarItems.firstIndex(where: { Calendar.current.isDateInToday($0.date) }) {
            selectedIndexPath = IndexPath(item: todayIndex, section: 0)
            let selectedDate = calendarItems[todayIndex].date
            monthBtn.setTitle(selectedDate.getMonthName(), for: .normal)
            // Scroll to today's date
            DispatchQueue.main.async { [weak self] in
                self?.calanderCollectionView.scrollToItem(at: IndexPath(item: todayIndex, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    
        calanderCollectionView.delegate = self
        calanderCollectionView.dataSource = self
        calanderCollectionView.register(UINib(nibName: "AssignmentDateCVC", bundle: nil), forCellWithReuseIdentifier: "AssignmentDateCVC")
        searchview.searchTextField.addDoneButton()
        nodataLbl.isHidden = true
        noRecordImg.isHidden = true
        searchview.isHidden = true
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
        ) { [weak self] (result: Result<AssignmentReportResponse, Error>) in
            
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
                    self?.searchview.isHidden = self?.data?.count ?? 0 <= 2 && !((self?.searchBtn.isSelected) == nil)
                            
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

    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func search(_ sender: UIButton) {
        searchview.becomeFirstResponder()
        sender.isSelected.toggle()
        let icon = sender.isSelected ? "magnifyingglass.circle.fill" : "magnifyingglass"
        searchBtn.setImage(UIImage(systemName: icon), for: .normal)
        searchview.isHidden = !sender.isSelected
    }
    func register(){
        listTable.register(UINib(nibName: CellConfingName.AssignmentListCTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.AssignmentListCTVC)
        listTable.register(UINib(nibName: "AssignmentTVC", bundle: nil), forCellReuseIdentifier: "AssignmentTVC")
    }
    
}

// Table view delegate and data source
extension AssignmentListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData?.count ?? 0 // Adjust this based on your data
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = listTable.dequeueReusableCell(withIdentifier: "AssignmentTVC", for: indexPath) as! AssignmentTVC
        if let report = filteredData?[indexPath.row]{
            cell.configure(with: report)
            cell.loadFiles(into: cell, files: report.file_path ?? [])
        }
       
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func ViewAct(_ sender: Any){
        let vc = ImageShowVc(nibName: nil, bundle: nil)
//        vc.FileURL = fileUrl
//        vc.type = 0
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
              // Example logic: red dot on Wednesdays, green on Saturdays
              let weekday = calendar.component(.weekday, from: currentDate)
              var status: DotStatus? = nil
              if weekday == 4 { status = .red }      // Wednesday
              if weekday == 7 { status = .green }    // Saturday

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
import UIKit

extension AssignmentListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = calendarItems[indexPath.item]
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssignmentDateCVC", for: indexPath) as? AssignmentDateCVC else {
            return UICollectionViewCell()
        }
        
        let isSelected = indexPath == selectedIndexPath
        cell.configure(with: item.date, isSelected: isSelected, status: item.status)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let selectedDate = calendarItems[indexPath.item].date
        monthBtn.setTitle(selectedDate.getMonthName(), for: .normal)

        collectionView.reloadData()
           DispatchQueue.main.async {
               self.scrollToCenter(of: indexPath, in: collectionView)
           }
    }
    func scrollToCenter(of indexPath: IndexPath, in collectionView: UICollectionView) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        guard let attributes = layout.layoutAttributesForItem(at: indexPath) else {
            collectionView.layoutIfNeeded()
            if let newAttributes = layout.layoutAttributesForItem(at: indexPath) {
                centerScrollLogic(attributes: newAttributes, collectionView: collectionView)
            }
            return
        }

        centerScrollLogic(attributes: attributes, collectionView: collectionView)
    }

    private func centerScrollLogic(attributes: UICollectionViewLayoutAttributes, collectionView: UICollectionView) {
        let cellFrame = attributes.frame
        let collectionViewWidth = collectionView.bounds.size.width
        let targetX = cellFrame.midX - collectionViewWidth / 2
        let maxOffsetX = collectionView.contentSize.width - collectionViewWidth
        let finalOffsetX = max(0, min(targetX, maxOffsetX))

        let targetOffset = CGPoint(x: finalOffsetX, y: 0)
        collectionView.setContentOffset(targetOffset, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 110)
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
