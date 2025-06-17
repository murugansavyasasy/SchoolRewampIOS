//
//  LessonPlanVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 09/12/24.
//

import UIKit


class LessonPlanVC: UIViewController {
    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var NodataLbl: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let cellcolour = [Colornames.lesson1,Colornames.lesson2,Colornames.lesson3]
    let colours1 = ["AttendenceColor","Clr","Color","lesson1","lesson3"]
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var LessonPlanData: [LessonPlanStaffReport]?
    var ViewLessonData: [LessonPlanDetail]?
    var isViewLesson = false
    var ReqestType = "myclass"
    var staffRole = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIupdate()
        BackBtn.applyBackButton()
        searchBar.applyRightTxt()
        searchBar.searchTextField.addDoneButton()
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.LessonPlan, secondLine: staffDetails?.school_name ?? "")
        
        if staffRole == "p3" {
            ReqestType = "myclass"
            segmentControl.isHidden = true
        }else{
            ReqestType = "allclass"
        }
        
        lesson_plan_staff_report_Api()
        
        let nib1 = UINib(nibName: CellConfingName.LessonPlanTvCell, bundle: nil)
        tableview.register(nib1, forCellReuseIdentifier: CellConfingName.LessonPlanTvCell)
        let nib = UINib(nibName: CellConfingName.LessonProgressCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.LessonProgressCell)
        
        let nib2 = UINib(nibName: CellConfingName.LessonDashboardTv, bundle: nil)
        tableview.register(nib2, forCellReuseIdentifier: CellConfingName.LessonDashboardTv)
        
        let nib3 = UINib(nibName: "LessonViewTvCell", bundle: nil)
        tableview.register(nib3, forCellReuseIdentifier: "LessonViewTvCell")
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    func UIupdate(){

        NodataImage.isHidden = true
        NodataLbl.isHidden = true
    }
    
    //MARK: Lesson plan Api call
    func lesson_plan_staff_report_Api(){
        
        let param: [String: Any] = [LessonPlanStringFile.request_type: ReqestType]
        
        APIService.shared.makeApi(url: ServiceUrl.lms_api_lesson_plan_staff_report, parameters: param, type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [self] (result: Result<LessonPlanStaffReportResponse,Error>) in
            
            switch result{
                
            case .success(let success):
                DispatchQueue.main.async { [self] in
                    
                    LessonPlanData = success.data
                    NodataImage.isHidden = !(LessonPlanData?.isEmpty ?? false)
                    NodataLbl.isHidden = !(LessonPlanData?.isEmpty ?? false)
                    
                    tableview.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {[self] in
                    
                    NodataImage.isHidden = false
                    NodataLbl.isHidden = false
                    NodataLbl.text = error.localizedDescription
                    
                    print("Error: ",error.localizedDescription)
                }
            }
        }
    }
    
    func View_Lesson_Plan_Api(){
        
        let param: [String: Any] = [LessonPlanStringFile.section_subject_id : "355065",LessonPlanStringFile.lesson_plan_status: 0]
        
        APIService.shared.makeApi(url: ServiceUrl.lms_api_lesson_plan_view, parameters: param, type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [self] (result: Result<LessonPlanDetailResponse,Error>) in
            
            switch result {
            case .success(let success):
                
                DispatchQueue.main.async { [self] in
                    
                    ViewLessonData = success.data
                    NodataImage.isHidden = !(ViewLessonData?.isEmpty ?? false)
                    NodataLbl.isHidden = !(ViewLessonData?.isEmpty ?? false)
                    NodataLbl.text = success.message
                    tableview.reloadData()
                }
                
            case .failure(let failure):
                
                DispatchQueue.main.async {[self] in
                    
                    NodataImage.isHidden = false
                    NodataLbl.isHidden = false
                    NodataLbl.text = failure.localizedDescription
                    
                    print("Error: ",failure.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func SegmentAct(_ sender: Any) {
        
        if segmentControl.selectedSegmentIndex == 0{
            ReqestType = "allclass"
        }else {
            ReqestType = "myclass"
        }
        
        lesson_plan_staff_report_Api()
    }
    
    @IBAction func BackBtnAct(_ sender: Any) {
        if isViewLesson == true{
            isViewLesson = false
            tableview.reloadData()
        }else{
            dismiss(animated: true)
        }
    }
}


@available(iOS 15.0, *)
extension LessonPlanVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isViewLesson == false {
            return LessonPlanData?.count ?? 0
        }else{
            return ViewLessonData?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isViewLesson == false{
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LessonDashboardTv, for: indexPath) as! LessonDashboardTv
         cell.SubjectLbl.text = LessonPlanData?[indexPath.row].subject_name
         cell.StandardLbl.text = (LessonPlanData?[indexPath.row].class_name ?? "") + " - " + (LessonPlanData?[indexPath.row].section_name ?? "")
         cell.StaffNameLbl.text = LessonPlanData?[indexPath.row].staff_name
         let percentage = Double(LessonPlanData?[indexPath.row].percentage_value ?? 0)
         cell.setProgress(to: percentage)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewbtnAct))
            cell.ViewBtn.addGestureRecognizer(tap)
            return cell
        }
        else{
//            let colour = cellcolour[indexPath.row % cellcolour.count]
//            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.LessonProgressCell, for: indexPath) as! LessonProgressCell
//    
//            // Set the default state before configuring the cell
//            cell.progressView.backgroundColor = .systemGreen  // Default color
//           // cell.ProgressHeight.constant = 85  // Default height
//            
//            if indexPath.row == 0{
//                cell.TopProgressView.isHidden = true
//            }
//            
//            let colour1 = indexPath.row % colours1.count
//            cell.Baseview.backgroundColor = UIColor(named: colours1[colour1])
//            
//            let totalRows = tableView.numberOfRows(inSection: indexPath.section)
//            
//            if indexPath.row > 5 {
//                cell.checkImageView.image = UIImage(named: "CheckCircle")
//                cell.progressView.backgroundColor = .lightGray
//                cell.TopProgressView.backgroundColor = .lightGray
//            } else {
//                cell.checkImageView.image = UIImage(named: "round")
//                cell.progressView.backgroundColor = .systemGreen
//            }
//            
//            if indexPath.row == totalRows - 1 {
//                //cell.ProgressHeight.constant = 0
//                cell.progressView.isHidden = true
//            } else {
//                // Calculate dynamic height if needed
//                //    let distance = distanceBetweenImageViews(in: tableView, at: indexPath)
//                //    cell.ProgressHeight.constant = distance ?? 85
//            }
//            
//            cell.TitleLbl.text = ViewLessonData?[indexPath.row].details[0].name
//            
//            cell.setNeedsLayout()
//            cell.layoutIfNeeded()
//            return cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "LessonViewTvCell", for: indexPath) as! LessonViewTvCell
            
            let details = ViewLessonData?[indexPath.row].details ?? []

            cell.configure(with: details)
            
            return cell
        }
    }
    
    func distanceBetweenImageViews(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat? {
        // Ensure there's a next row
        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        guard indexPath.row + 1 < tableView.numberOfRows(inSection: indexPath.section) else {
                    return nil
                }
        guard let currentCell = tableView.cellForRow(at: indexPath) as? LessonProgressCell,
              let nextCell = tableView.cellForRow(at: nextIndexPath) as? LessonProgressCell else {
            return nil // Return nil if the next cell is not visible
        }

        // Get image view centers
        let currentImageCenter = currentCell.checkImageView.center
        let nextImageCenter = nextCell.checkImageView.center

        // Calculate Euclidean distance
        let distance = sqrt(pow(nextImageCenter.x - currentImageCenter.x, 2) +
                            pow(nextImageCenter.y - currentImageCenter.y, 2))
        print("distance between images",distance)

        return distance
    }

//    func distanceBetweenImageViews(in tableView: UITableView, at indexPath: IndexPath) -> CGFloat? {
//        let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
//        // Add this check at the beginning of your function
//        guard indexPath.row + 1 < tableView.numberOfRows(inSection: indexPath.section) else {
//            return nil
//        }
//        // Use dequeueReusableCell instead of cellForRow
//        guard let currentCell = tableView.dequeueReusableCell(withIdentifier: "LessonProgressCell") as? LessonProgressCell,
//              let nextCell = tableView.dequeueReusableCell(withIdentifier: "LessonProgressCell") as? LessonProgressCell else {
//            return nil
//        }
//        
//        // Configure cells if needed
//        // currentCell.configure(with: yourDataSource[indexPath.row])
//        // nextCell.configure(with: yourDataSource[nextIndexPath.row])
//        
//        // Force layout if needed
//        currentCell.layoutIfNeeded()
//        nextCell.layoutIfNeeded()
//        
//        // Convert image view center to table view coordinates
//        let currentImageCenter = currentCell.checkImageView.convert(currentCell.checkImageView.center, to: tableView)
//        let nextImageCenter = nextCell.checkImageView.convert(nextCell.checkImageView.center, to: tableView)
//        
//        // Calculate Euclidean distance
//        let distance = sqrt(pow(nextImageCenter.x - currentImageCenter.x, 2) +
//                           pow(nextImageCenter.y - currentImageCenter.y, 2))
//        
//        return distance
//    }
    
  
    @IBAction func ViewbtnAct() {
        isViewLesson = true
        View_Lesson_Plan_Api()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  isViewLesson == true {
            return 100
        }else{
          
            return UITableView.automaticDimension
        }
    }
    
}

extension LessonPlanVC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
}
