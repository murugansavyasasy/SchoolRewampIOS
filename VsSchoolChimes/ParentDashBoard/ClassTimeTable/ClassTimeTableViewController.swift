//import UIKit
//
//class ClassTimeTableViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
//    
//    @IBOutlet weak var cv: UICollectionView!
//    @IBOutlet weak var NameLbl: UILabel!
//    @IBOutlet weak var StandardLbl: UILabel!
//    @IBOutlet weak var tv: UITableView!
//    @IBOutlet weak var backBtn: UIButton!
//    @IBOutlet weak var bgView: UIView!
//    
//    var getTimes: String!
//    var getCurrentDay: String!
//    var timeTable: [TimetableHour]?
//    var selectedIndex: Int = 0 // default to 0 (Monday)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Setup
//        tv.dataSource = self
//        tv.delegate = self
//        cv.dataSource = self
//        cv.delegate = self
//        
//        // Register XIBs
//        cv.register(UINib(nibName: CellConfingName.WeekDaysNameCollectionViewCell, bundle: nil),
//                    forCellWithReuseIdentifier: CellConfingName.WeekDaysNameCollectionViewCell)
//        tv.register(UINib(nibName: CellConfingName.ClassTimeTableTableViewCell, bundle: nil),
//                    forCellReuseIdentifier: CellConfingName.ClassTimeTableTableViewCell)
//        
//        // Styling
//        backBtn.setTitle(ReceiverMenuItems.ClassTimetable.translated(), for: .normal)
//        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
//        backBtn.applyBackButton()
//        NameLbl.setFont(style: .body, size: FontSize.BodySize)
//        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
//        
//   
//    }
//    
//    override func viewDidLayoutSubviews() {
//        view.applyGradient(colors: [Colornames.gradientBlue, Colornames.gradientgreen],
//                           startPoint: CGPoint(x: 1, y: 0.5),
//                           endPoint: CGPoint(x: 0, y: 0.5))
//        bgView.applyGradient(colors: [Colornames.gradientBlue, Colornames.gradientgreen],
//                             startPoint: CGPoint(x: 1, y: 0.5),
//                             endPoint: CGPoint(x: 0, y: 0.5))
//    }
//    
//    // MARK: - API Call
//    
//    func daily_collectionApi(type: Int) {
//        APIService.shared.makeApi(
//            url: ServiceUrl.lms_api_time_table_get_schedule,
//            parameters: ["day_id": type],
//            type: ApitTypeSringFile.GET,
//            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? ""
//        ) { [weak self] (result: Result<TimetableResponse, Error>) in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    self?.tv.isHidden = false
//                    self?.timeTable = response.data
//                    
//                    self?.tv.reloadData()
//                case .failure(let error):
//                    print("API Error:", error)
//                }
//            }
//        }
//    }
//    
//    // MARK: - Table View
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return timeTable?.count ?? 0
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let item = timeTable?[indexPath.row],
//              let cell = tableView.dequeueReusableCell(
//                withIdentifier: CellConfingName.ClassTimeTableTableViewCell,
//                for: indexPath
//              ) as? ClassTimeTableTableViewCell else {
//            return UITableViewCell()
//        }
//        
//        cell.fromLbl.text = item.start_time
//        cell.toLbl.text = item.end_time
//        cell.subNameLbl.text = item.subject_name
//        cell.durationNameLbl.text = item.duration
//        cell.staffNameLbl.text = item.name
//        
//        if hasCurrentTimeCrossed(endTimeString: item.end_time) {
//            cell.animateView.backgroundColor = .gray
//            cell.fromImg.image = UIImage(named: "circle")
//        } else {
//            cell.animateView.backgroundColor = .green
//            cell.fromImg.image = UIImage(named: "round")
//        }
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//    
//    // MARK: - Collection View
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return classTimeTableStrings.weekDaysShort.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(
//            withReuseIdentifier: CellConfingName.WeekDaysNameCollectionViewCell,
//            for: indexPath
//        ) as! WeekDaysNameCollectionViewCell
//        
//        let day = classTimeTableStrings.weekDaysShort[indexPath.row]
//        cell.weekDaysNameLbl.text = day
//        
//        if indexPath.row == selectedIndex {
//            cell.bgView.backgroundColor = UIColor(named: "priortitClr1") // Highlighted
//        } else {
//            cell.bgView.backgroundColor = UIColor(named: "PriorityClr2")
//        }
//        
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        selectedIndex = indexPath.row
//        daily_collectionApi(type: selectedIndex)
//        collectionView.reloadData()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 150, height: 150)
//    }
//    
//    // MARK: - Actions
//    
//    @IBAction func back(_ sender: UIButton) {
//        dismiss(animated: true)
//    }
//}
//
//// MARK: - Helper Functions
//
//
