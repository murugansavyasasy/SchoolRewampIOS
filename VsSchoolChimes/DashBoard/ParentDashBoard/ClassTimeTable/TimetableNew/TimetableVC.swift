//
//  TimetableVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 16/01/25.
//

import UIKit

class TimetableVC: UIViewController{
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var bgview: UIView!
    
    @IBOutlet weak var cv: UICollectionView!
    let id = "TimetableTv"
    let id2 = "LastCell"
    var getCurrentDay : String!
    let dateFormatter = DateFormatter()
    let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    let subject = ["Tamil","Maths","Science","English","Social Science","EVS","PET","Dance","Yoga","Study"]
    let time = ["08 : 00 AM","09 : 00 AM","10 : 00 AM","11 : 00 AM","12 : 00 PM","01 : 00 PM","02 : 00 PM","03 : 00 PM","04 : 00 PM","05 : 00 PM"]
    
    let colours = ["AttendenceColor","Clr","Color","lesson1","lesson3"]
    var tableanimate = true
    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        bgview.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        
        dateFormatter.dateFormat = "E"
        let currentDayName = dateFormatter.string(from: Date())
        dateFormatter.dateFormat = "dd-MM-yyyy"
        //let formattedDate = dateFormatter.string(from: currentDate)
//        dayLbl.text = formattedDate
//        dateLBl.text = currentDayName
        getCurrentDay = currentDayName
        //print("day",day)
        
        let nib = UINib(nibName: CellConfingName.TimetableTv, bundle: nil)
        tv.register(nib, forCellReuseIdentifier: CellConfingName.TimetableTv)
        
        let cvnib = UINib(nibName: CellConfingName.WeekDaysNameCollectionViewCell, bundle: nil)
        cv.register(cvnib, forCellWithReuseIdentifier: CellConfingName.WeekDaysNameCollectionViewCell)
        cv.delegate = self
        cv.dataSource = self
        
        DispatchQueue.main.async {
            let firstIndexPath = IndexPath(item: 0, section: 0)
            self.cv.selectItem(at: firstIndexPath, animated: false, scrollPosition: .top)
            
            // Manually update the appearance of the first cell
            if let firstCell = self.cv.cellForItem(at: firstIndexPath) as? WeekDaysNameCollectionViewCell {
                firstCell.bgView.backgroundColor = UIColor(named: "Priority")
            }
        }
        
        let nib2 = UINib(nibName: id2, bundle: nil)
        tv.register(nib2, forCellReuseIdentifier: id2)
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
    }
    @IBAction func BackAct(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension TimetableVC : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if indexPath.row == 9{
        //            let cell = tv.dequeueReusableCell(withIdentifier: id2, for: indexPath) as! LastCell
        //            return cell
        //        }else{
        let colour = indexPath.row % colours.count
        let cell = tv.dequeueReusableCell(withIdentifier: id, for: indexPath) as! TimetableTv
        cell.TimeLbl.text = time[indexPath.row]
        cell.SubjectLbl.text = subject[indexPath.row]
        cell.DetailsView.backgroundColor = UIColor(named: colours[colour])
        //cell.animateProgressVertically()
        //cell.animated = tableanimate
//        if cell.animated == false {
//            cell.animated = true
//        }
        return cell
        //}
    }
    
    
}
//extension TimetableVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
//   
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return days.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:CellConfingName.WeekDaysNameCollectionViewCell , for: indexPath)as! WeekDaysNameCollectionViewCell
//        
//        if indexPath.row == 0{
//            cell.bgView.backgroundColor = UIColor(named: "Priority")
//        }
//        cell.weekDaysNameLbl.text = days[indexPath.row]
//        if days[indexPath.row] ==  getCurrentDay {
//            cell.bgView.backgroundColor = UIColor(named: "priortitClr1")
////        } else {
////            cell.bgView.backgroundColor = UIColor(named: "PriorityClr2")
//        }
//        
//        
//        
////        let tapGes = TimeTableGesture(target: self, action: #selector(timeTableTap))
////        tapGes.bgView = cell.bgView
////        cell.bgView.addGestureRecognizer(tapGes)
////
//        
//        return cell
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        let cell = cv.cellForItem(at: indexPath) as! WeekDaysNameCollectionViewCell
//    
//
//        cell.bgView.backgroundColor = UIColor(named: "Priority")
//        tv.reloadData()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        
//        let cell = cv.cellForItem(at: indexPath) as! WeekDaysNameCollectionViewCell
//        
//        cell.bgView.backgroundColor = UIColor(named: "PriorityClr2")
//        
//    }
//    
////    @IBAction func timeTableTap( ges : TimeTableGesture) {
////        ges.bgView.backgroundColor = UIColor(named: "Priority")
////        tv.reloadData()
////    }
////    
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        //return CGSize(width: cv.frame.width/4, height: 150)
//        return CGSize(width: 120, height: 60)
//       
//    }
//    
//}

extension TimetableVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return days.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CellConfingName.WeekDaysNameCollectionViewCell,
                for: indexPath
            ) as! WeekDaysNameCollectionViewCell
            
            cell.weekDaysNameLbl.text = days[indexPath.row]
            
            // Set cell's background color based on selection state
            if collectionView.indexPathsForSelectedItems?.contains(indexPath) == true {
                cell.bgView.backgroundColor = UIColor(named: "Priority") // Selected state
            } else {
                cell.bgView.backgroundColor = UIColor(named: "PriorityClr2") // Default state
            }
            
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // Deselect the 0th index if a different index is selected
            if indexPath.row != 0 {
                let firstCellIndexPath = IndexPath(item: 0, section: 0)
                if let firstCell = collectionView.cellForItem(at: firstCellIndexPath) as? WeekDaysNameCollectionViewCell {
                    collectionView.deselectItem(at: firstCellIndexPath, animated: true)
                    firstCell.bgView.backgroundColor = UIColor(named: "PriorityClr2") // Default state
                }
            }
            
            // Update selected cell's background color
            if let cell = collectionView.cellForItem(at: indexPath) as? WeekDaysNameCollectionViewCell {
                cell.bgView.backgroundColor = UIColor(named: "Priority")
            }
            
            tv.reloadData()
           
        }
        
        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
            // Reset the background color of the deselected cell
            if let cell = collectionView.cellForItem(at: indexPath) as? WeekDaysNameCollectionViewCell {
                cell.bgView.backgroundColor = UIColor(named: "PriorityClr2")
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 120, height: 60)
        }
}
