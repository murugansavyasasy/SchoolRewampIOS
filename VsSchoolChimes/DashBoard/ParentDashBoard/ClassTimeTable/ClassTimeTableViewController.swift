//
//  ClassTimeTableViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/17/24.
//

import UIKit

class ClassTimeTableViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
  
    
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var dateLBl: UILabel!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    var getTimes : String!
    var getCurrentDay : String!
   
    let dateFormatter1 = DateFormatter()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        bgView.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        tv.dataSource = self
        tv.delegate = self
        cv.dataSource = self
        cv.delegate = self
        
        let currentDate = Date()

        let calendar = Calendar.current
        let day = calendar.component(.day, from: currentDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss" 
        dateFormatter1.dateFormat = "h a"

        cv.register(UINib(nibName: CellConfingName.WeekDaysNameCollectionViewCell, bundle: nil), forCellWithReuseIdentifier:  CellConfingName.WeekDaysNameCollectionViewCell)
    
        dateFormatter.dateFormat = "EEEE"
        let currentDayName = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let formattedDate = dateFormatter.string(from: currentDate)
        dayLbl.text = formattedDate
        dateLBl.text = currentDayName
        getCurrentDay = currentDayName
        print("day",day)
        backBtn.setTitle(ReceiverMenuItems.ClassTimetable.translated(), for: .normal)
        
        tv.register(UINib(nibName: CellConfingName.ClassTimeTableTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.ClassTimeTableTableViewCell)
            
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classTimeTableStrings.timeArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ClassTimeTableTableViewCell, for: indexPath) as! ClassTimeTableTableViewCell
        cell.fromLbl.text = classTimeTableStrings.timeArr[indexPath.row]
        cell.toLbl.text = classTimeTableStrings.toTimeArr[indexPath.row]
        
        classTimeTableStrings.timeArr.append(contentsOf: classTimeTableStrings.toTimeArr)
        let item = classTimeTableStrings.timetable[indexPath.row]
        cell.staffNameLbl.text = item.techer
        cell.durationNameLbl.text  = item.subDuration
        cell.subNameLbl.text  = item.subName
               
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h a"

        let compareTime = convertToDate("11 AM")!

        let filteredTimes = classTimeTableStrings.timeArr.filter { time in
            if let timeDate = convertToDate(time) {
                return timeDate < compareTime
            }
            return false
        }

        var result = [String: String]()
        for time in classTimeTableStrings.timeArr {
            print("timtimeArre",time)
            if filteredTimes.contains(time) {
                result[time] = "blue"
            } else {
                result[time] = "red"
            }
        }

        
        for (time, color) in result {
            let colorString = color
            let color = colorFromString(colorString)
            cell.animateView.backgroundColor = color
            
            
           if cell.animateView.backgroundColor == .red {
               cell.fromImg.image = UIImage(named: "circle")
            }else{
                cell.fromImg.image = UIImage(named: "round")
            }
                
        }
        
        
        return cell
        
    }
    
    func colorFromString(_ colorString: String) -> UIColor {
        switch colorString.lowercased() {
        case "blue":
            return .blue
        case "red":
            return .red
        default:
            return .clear
        }
    }
    func convertToDate(_ time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        return formatter.date(from: time)
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return classTimeTableStrings.weekDays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:CellConfingName.WeekDaysNameCollectionViewCell , for: indexPath)as! WeekDaysNameCollectionViewCell
        
        cell.weekDaysNameLbl.text = classTimeTableStrings.weekDays[indexPath.row]
        if classTimeTableStrings.weekDays[indexPath.row] ==  getCurrentDay {
            cell.bgView.backgroundColor = UIColor(named: "priortitClr1")
        } else {
            cell.bgView.backgroundColor = UIColor(named: "PriorityClr2")
        }
        
        
        
        let tapGes = TimeTableGesture(target: self, action: #selector(timeTableTap))
        tapGes.bgView = cell.bgView
        cell.bgView.addGestureRecognizer(tapGes)
//
        
        return cell
        
    }
    
    
    
    @IBAction func timeTableTap( ges : TimeTableGesture) {
        ges.bgView.backgroundColor = UIColor(named: "Priority")
        tv.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 150)
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }

}
struct SubItem {
    let subName: String!
    var subDuration: String!
    var techer: String!
}



class TimeTableGesture : UITapGestureRecognizer {
    var bgView : UIView!
}
