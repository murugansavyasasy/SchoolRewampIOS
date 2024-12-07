//
//  cancelTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 03/07/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit

class cancelTableViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    
    
    
    @IBOutlet weak var cv: UICollectionView!
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var holeview: UIViewX!
    @IBOutlet weak var lineview: UIViewX!
    var identifier = "TimeCollectionViewCell"
    var getTeacherData : [GetTeacherwiseSlotAvailabilityData] = []
    
    var duplicateStaffTimes: [Int: [(from_time: String, to_time: String)]] = [:]
    var staffIdsArray : [Int] = []
    var getStaffId : Int!
    var slotdetails = [Slot]()
    var slotdetails1 = [Slot]()
    var events : [Event] = []
    let dateFormatter = DateFormatter()
    var ids : [Int] = []
    var slotIdArr : [Int] = []
    var timesarr : [String] = []
    var fromTimeArry : [String] = []
    var ToTimeArry : [String] = []
    var timeAArr : [Int] = []
    var call_back: ((String) -> Void)?
    var expandType = "1"
    var CustomOrange = "CustomOrange"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        cv.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
                dateFormatter.dateFormat = "hh:mm a"

                cv.delegate = self
                cv.dataSource = self
                
                
            }
            
            
            
            func configure(with slots: [Slot]) {
                self.slotdetails = slots
                fromTimeArry.removeAll()
                print("ISBODVAL",slotdetails)
//                DefaultsKeys.bookingSlotId.removeAll()
//                timeAArr.removeAll()
                cv.reloadData()
            }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
     
        return slotdetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! TimeCollectionViewCell
                
               
                cell.timelbl.text =   slotdetails[indexPath.row].fromTime + " - " +  slotdetails[indexPath.row].toTime


        timeAArr.removeAll()
        
        
                for i in slotdetails{

                    if i.isBooked == 1{
                        for ival in slotdetails {
                                timeAArr.append(ival.slotId)

                    }
                    }
                    else{

                    }

                }


                if timeAArr.count != 0 {


                    for value in slotdetails {
                       
                        if timeAArr.contains(value.slotId) {


                            if slotdetails[indexPath.row].isBooked == 1{
                                cell.timeHoleView.backgroundColor = .systemOrange
                                        cell.timelbl.textColor = .white
                                cell.timeHoleView.isUserInteractionEnabled = false
                                cv.allowsSelection = false


                                    }
                                    else{
                                        cell.timeHoleView.backgroundColor = .white
                                        cell.timeHoleView.borderColor = .lightGray
                                        cell.timelbl.textColor = .lightGray
                                        cell.timeHoleView.isUserInteractionEnabled = false
                                        cv.allowsSelection = false


                                    }

                        }
                    }

                }else {
                    cell.timeHoleView.backgroundColor = .white
                    cell.timeHoleView.isUserInteractionEnabled = true
                    cell.timelbl.textColor = .black
                    cv.allowsSelection = true

                   


                }

        
        
        
        let lowercasedArray = DefaultsKeys.timesarr.map { $0.lowercased() }
                if DefaultsKeys.timesarr.count != 0 {
                                      
                                    
                     if lowercasedArray.contains(slotdetails[indexPath.row].fromTime) || lowercasedArray.contains(slotdetails[indexPath.row].toTime) {
                                               cell.timeHoleView.backgroundColor = .white
                                               cell.timeHoleView.borderColor = .lightGray
                                               cell.timelbl.textColor = .lightGray
                                               cell.timeHoleView.isUserInteractionEnabled = false
                         cv.allowsSelection = false


                                           }else{
                                               cell.timeHoleView.backgroundColor = .white
                                               cell.timeHoleView.isUserInteractionEnabled = true
                                               cell.timelbl.textColor = .black
                                               cv.allowsSelection = true




                                           }
                                       
                               }
        
        
        
        
        
        
     

        if DefaultsKeys.ClickID == slotdetails[indexPath.row].slotId  {
            cell.timeHoleView.backgroundColor = .systemOrange
                   cell.timelbl.textColor = .white
            cv.allowsSelection = true

            if DefaultsKeys.bookingSlotId.count != 0{
                
                    
                
                var seen = Set<Int>()
                                let uniqueValues = DefaultsKeys.bookingSlotId.filter { element in
                                    if seen.contains(element) {
                                        print("element",element)
                                        return false
                                    } else {
                                        seen.insert(element)
                //
                                        print("seenseen",seen)

                                        return true
                                    }
                                }
                                print("uniqueValues",uniqueValues)
                                DefaultsKeys.bookingSlotId = uniqueValues
                            }
                
                
            
                          }
        
        
        
        
        
        
                          else{
//                              cell.timeHoleView.backgroundColor = .white
//                              cell.timeHoleView.borderColor = .lightGray
//                              cell.timelbl.textColor = .lightGray
//                              cell.timeHoleView.isUserInteractionEnabled = false

                          }
        
        
        
        
                return cell
            
    }
    
   
    
    
    
 
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 50)
    }
    
    
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
            DefaultsKeys.timesarr.removeAll()
    
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeCollectionViewCell", for: indexPath) as! TimeCollectionViewCell

            DefaultsKeys.ClickID = slotdetails[indexPath.row].slotId
            print("slotde.row.isBooked",slotdetails[indexPath.row].isBooked)
            print("slotdDefaultsKeys.ClickIDd",slotdetails[indexPath.row].isBooked)


//            if slotdetails[indexPath.row].isBooked == 1{




                //                    if timeAArr.contains(value.slotId) {

print("COLRR",cell.timeHoleView.backgroundColor)

//            if cell.timeHoleView.backgroundColor == UIColor(named: CustomOrange) {
//print("NOTWORKING")
//                }
//                else{

                    for i in slotdetails{

                        ids.append(i.slotId)


                    }


                    if ids.contains(slotdetails[indexPath.row].slotId){

                        slotIdArr.append(slotdetails[indexPath.row].slotId)
                        DefaultsKeys.bookingSlotId.append(contentsOf: slotIdArr)

                    }else{

                    }

                    let time = slotdetails[indexPath.row].fromTime
                    let time2 = slotdetails[indexPath.row].toTime
                    var frmHr : Int!
                    var fromMins : Int!
                    var toHr : Int!
                    var tomins : Int!

                    if let (hour, minute) = extractHoursAndMinutes(from: time) {
                        print("Hour: \(hour), Minute: \(minute)")


                        frmHr = hour
                        fromMins = minute
                        // Define 1:30 PM and 1:40 PM as DateComponents

                    } else {
                        print("Invalid time format")
                    }

                    if let (hours, minutes) = extractHoursAndMinutes1(from: time2) {
                        print("Hour: \(hours), Minute: \(minutes)")
                        toHr = hours
                        tomins = minutes
                    } else {
                        print("Invalid time format")
                    }

                    let calendar = Calendar.current

                    let currentDate = Date()
                    let startTimeComponents = DateComponents(hour: frmHr, minute: fromMins)
                    let endTimeComponents = DateComponents(hour: toHr, minute: tomins)

                    // Create dates for 1:30 PM and 1:40 PM
                    if let startTime = calendar.date(bySettingHour: startTimeComponents.hour!, minute: startTimeComponents.minute!, second: 0, of: currentDate),
                       let endTime = calendar.date(bySettingHour: endTimeComponents.hour!, minute: endTimeComponents.minute!, second: 0, of: currentDate) {

                        // Loop through the time range and print each minute
                        var time = startTime
                        while time <= endTime {
                            let timeFormatter = DateFormatter()
                            timeFormatter.dateFormat = "hh:mm a"

                            // Format for displaying time in 12-hour format with AM/PM
                            var timeGetList = timeFormatter.string(from: time)



                            DefaultsKeys.timesarr.append(timeGetList)
                            print("DefaultsKeys.timesarr", DefaultsKeys.timesarr)


                            time = calendar.date(byAdding: .minute, value: 1, to: time)!
                        }

                    }


                    call_back?("")
//                }

        }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        
        print("didDeselectItemAt")
    }
    
//    dids
    
//    @IBAction func pickDate(ges : timeclick) {
//      
//        
//        fromTimeArry.removeAll()
//        ToTimeArry.removeAll()
//        timesarr.removeAll()
//        for i in slotdetails{
//            
//            ids.append(i.slotId)
//        
//            
//        }
//        
//       
//        if ids.contains(ges.idGet){
//            
//            slotIdArr.append(ges.idGet)
//            DefaultsKeys.bookingSlotId.append(contentsOf: slotIdArr)
//            
//        }else{
//            
//        }
//        
//        
//        print("slotIdArrslotIdArr",slotIdArr)
//        print("DefaultsKeys.bookingSlotId",DefaultsKeys.bookingSlotId)
//        
//        
//        
//        
//       
//        
//        // Get the current date
//       
//       
////        let time = ges.fromtime
////        let time2 = ges.toTime
////        var frmHr : Int!
////        var fromMins : Int!
////        var toHr : Int!
////        var tomins : Int!
////        
////        if let (hour, minute) = extractHoursAndMinutes(from: time!) {
////            print("Hour: \(hour), Minute: \(minute)")
////            
////           
////            frmHr = hour
////            fromMins = minute
////            // Define 1:30 PM and 1:40 PM as DateComponents
////            
////           
////        } else {
////            print("Invalid time format")
////        }
////        
////        if let (hours, minutes) = extractHoursAndMinutes1(from: time2!) {
////            print("Hour: \(hours), Minute: \(minutes)")
////            toHr = hours
////            tomins = minutes
////        } else {
////            print("Invalid time format")
////        }
////        
////        let calendar = Calendar.current
////        
////        let currentDate = Date()
////        let startTimeComponents = DateComponents(hour: frmHr, minute: fromMins)
////        let endTimeComponents = DateComponents(hour: toHr, minute: tomins)
////        
////        // Create dates for 1:30 PM and 1:40 PM
////        if let startTime = calendar.date(bySettingHour: startTimeComponents.hour!, minute: startTimeComponents.minute!, second: 0, of: currentDate),
////           let endTime = calendar.date(bySettingHour: endTimeComponents.hour!, minute: endTimeComponents.minute!, second: 0, of: currentDate) {
////            
////            // Loop through the time range and print each minute
////            var time = startTime
////            while time <= endTime {
////                let timeFormatter = DateFormatter()
////                timeFormatter.dateFormat = "hh:mm a"
////               
////                // Format for displaying time in 12-hour format with AM/PM
////                var timeGetList = timeFormatter.string(from: time)
////                
////              
////
////                timesarr.append(timeGetList)
////                print("timesarr",timesarr)
////                
////               
////                
////                
////
////                time = calendar.date(byAdding: .minute, value: 1, to: time)!
////            }
////            
////            
////            
////        }
////        
////        
//////        3
////        
////        print("frommtimes",fromTimeArry)
////        
////        
////        cv.delegate = self
////                        cv.dataSource = self
////        cv.reloadData()
//        
//    }
    
    
  
    
    
    
    func extractHoursAndMinutes(from timeString: String) -> (Int, Int)? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // Format for "1:04 PM"
        
        guard let date = dateFormatter.date(from: timeString) else {
            return nil
        }
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        return (hour, minute)
        
    }
    
    func extractHoursAndMinutes1(from timeString: String) -> (Int, Int)? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // Format for "1:04 PM"
        
        guard let date = dateFormatter.date(from: timeString) else {
            return nil
        }
        
        let calendar = Calendar.current
        let hours = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        return (hours, minutes)
        
    }
    
}

class timeclick : UITapGestureRecognizer{
    
    var sloId : Int!
    var fromtime : String!
    var toTime : String!
    var idGet : Int!
        var dateGet : String!
        var fromToTime : String!
}
