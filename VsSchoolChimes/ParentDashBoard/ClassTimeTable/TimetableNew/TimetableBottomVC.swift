//
//  TimetableBottomVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 23/07/25.
//

import UIKit

class TimetableBottomVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var DayLbl: UILabel!
    @IBOutlet weak var noDataimage: UIImageView!
    @IBOutlet weak var nodataLbl: UILabel!
    
    var timetableData: [TimetableHour] = []
    var DayId: Int?
    private var highlightTimer: Timer?
    
    override func viewDidLoad() {
           super.viewDidLoad()
           view.layer.cornerRadius = 30
           view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
           noDataimage.isHidden = true
           DayLbl.setFont(style: .title, size: FontSize.TitleSize)
           nodataLbl.setFont(style: .title, size: FontSize.BodySize)
           tv.register(UINib(nibName: "TimetableTvCell", bundle: nil),
                       forCellReuseIdentifier: "TimetableTvCell")
           tv.delegate = self
           tv.dataSource = self
           
           get_Timetable()
           
           // Schedule periodic check for current hour highlight
           highlightTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
               guard let self = self else { return }
               if self.isTodayMatchingDayLabel() {
                   self.highlightCurrentHour()
               }
           }
       }
       
       deinit {
           highlightTimer?.invalidate()
       }
       
       // MARK: Api call
       func get_Timetable() {
           APIService.shared.makeApi(
               url: ServiceUrl.lms_api_time_table_get_schedule,
               parameters: ["day_id": DayId ?? 0],
               type: ApitTypeSringFile.GET,
               token: UserDefaultFileManager.get_child_Details()?.access_token ?? "", isBaseUrl: false
           ) { [weak self] (result: Result<TimetableResponse, Error>) in
               
               guard let self = self else { return }
               
               DispatchQueue.main.async {
                   switch result {
                   case .success(let success):
                       if success.status == true {
                           self.timetableData = success.data ?? []
                           self.tv.isHidden = false
                           self.tv.reloadData()
                           self.noDataimage.isHidden = true
                           self.nodataLbl.isHidden = true
                           
                           // ✅ Highlight if today
                           if self.isTodayMatchingDayLabel() {
                               DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                   self.highlightCurrentHour()
                               }
                           }
                       } else {
                           self.timetableData = []
                           self.tv.reloadData()
                           self.noDataimage.isHidden = false
                           self.nodataLbl.text = success.message
                           self.nodataLbl.isHidden = false
                       }
                   case .failure(let error):
                       self.timetableData = []
                       self.tv.reloadData()
                       self.noDataimage.isHidden = false
                       self.nodataLbl.text = error.localizedDescription
                       self.nodataLbl.isHidden = false
                       self.tv.isHidden = true
                   }
               }
           }
       }
       
       // MARK: - TableView
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return timetableData.count
       }
       
       func tableView(_ tableView: UITableView,
                      cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tv.dequeueReusableCell(withIdentifier: "TimetableTvCell",
                                             for: indexPath) as! TimetableTvCell
           let data = timetableData[indexPath.row]
           cell.TimeLbl.text = data.start_time
           cell.toTimeLbl.text = data.end_time
           cell.SubjectLbl.text = data.hour_type == "1" ? data.subject_name : data.name
           cell.StaffLbl.text = data.hour_type == "1" ? data.facalty_name : data.staff_name
           cell.startEndTimeLbl.text = "\(data.start_time ?? "") - \(data.end_time ?? "")"
           cell.DurationLbl.text = "Duration - " + (data.duration ?? "")
           return cell
       }
       
       func tableView(_ tableView: UITableView,
                      heightForRowAt indexPath: IndexPath) -> CGFloat {
           return UITableView.automaticDimension
       }
       
       // MARK: - Highlight Current Hour
       func isTodayMatchingDayLabel() -> Bool {
           let formatter = DateFormatter()
           formatter.dateFormat = "EEEE"
           formatter.locale = Locale(identifier: "en_US_POSIX")
           let today = formatter.string(from: Date()).lowercased()
           return today == DayLbl.text?.lowercased()
       }

       func highlightCurrentHour() {
           let formatter = DateFormatter()
           formatter.dateFormat = "hh:mm a"
           formatter.locale = Locale(identifier: "en_US_POSIX")
           
           let now = Date()
           let calendar = Calendar.current
           let today = calendar.startOfDay(for: now)
           
           for (index, hour) in timetableData.enumerated() {
               guard let start = formatter.date(from: hour.start_time ?? ""),
                     let end = formatter.date(from: hour.end_time ?? "") else { continue }
               
               let startComponents = calendar.dateComponents([.hour, .minute], from: start)
               let endComponents = calendar.dateComponents([.hour, .minute], from: end)
               
               guard let startTime = calendar.date(bySettingHour: startComponents.hour ?? 0,
                                                   minute: startComponents.minute ?? 0,
                                                   second: 0, of: today),
                     let endTime = calendar.date(bySettingHour: endComponents.hour ?? 0,
                                                 minute: endComponents.minute ?? 0,
                                                 second: 0, of: today) else { continue }
               
               if now >= startTime && now <= endTime {
                   let indexPath = IndexPath(row: index, section: 0)
                   tv.scrollToRow(at: indexPath, at: .middle, animated: true)
                   
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                       if let cell = self.tv.cellForRow(at: indexPath) {
                           UIView.animate(withDuration: 0.3, animations: {
                               cell.contentView.backgroundColor = UIColor.systemYellow
                               cell.contentView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                               cell.contentView.layer.shadowColor = UIColor.black.cgColor
                               cell.contentView.layer.shadowOpacity = 0.3
                               cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
                               cell.contentView.layer.shadowRadius = 6
                           }) { _ in
                               UIView.animate(withDuration: 0.3, delay: 2.0, options: [], animations: {
                                   cell.contentView.backgroundColor = UIColor.clear
                                   cell.contentView.transform = .identity
                                   cell.contentView.layer.shadowOpacity = 0
                               }, completion: nil)
                           }
                       }
                   }
                   break // only highlight the first match
               }
           }
       }
   }
