//
//  PTMViewController.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 02/07/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import ObjectMapper
import DropDown
import Alamofire
struct Item {
    let title: String
    var isExpanded: Bool
}


struct TeacherSlot {

    var Name                                       : String!
    var className                                      : String!
    var data                                         : [GetTeachData]!

    init(name: String, classN: String) {
            self.Name = name
            self.className = classN
        }
}
struct GetTeachData  {

    var from_time                                    : String!
    var to_time                                      : String!
}

class PTMViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{


    @IBOutlet weak var bookSlotBtn: UIButton!
    

    @IBOutlet weak var tvLeading: NSLayoutConstraint!
    
    @IBOutlet weak var tvTralling: NSLayoutConstraint!
    @IBOutlet weak var dropDownLbl: UILabel!
    
    @IBOutlet weak var tvTop: NSLayoutConstraint!
    
    @IBOutlet weak var subviewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewBack: UIView!
    
    @IBOutlet weak var calendarView: UIView!
   
    @IBOutlet weak var subView: UIView!
    
    @IBOutlet weak var segment2: UIView!
    @IBOutlet weak var cv: UICollectionView!
   
    @IBOutlet weak var segment1: UIView!
  
    @IBOutlet weak var noRecordsLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var calanderHeightCon: NSLayoutConstraint!

    @IBOutlet weak var noRecordsView: UIView!
    var getStaffIdArr = [Int]()
    var getEventNameArr = [String]()
    let drop_down = DropDown()
    var selectedDate = Date()
    var totalSquares = [String]()
    var screenSize : CGRect!
    var screenWidth : CGFloat!
    var screenHeight : CGFloat!
//    var selectedDate: Date?
    var currentYear: Int = Calendar.current.component(.year, from: Date())
    var currentMonth: Int = Calendar.current.component(.month, from: Date())
    var segmentId = 1
    var ClickID = 0
    var tvcellIdentifier = "SlotHistoryTableViewCell"
    var selectedCell:IndexPath?
    let daysInMonth = 30
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    var givenDate = ["15","3","8"]
    var DateArr = [Int]()
    var DayArr = [String]()
    var monthNumberArr = [String]()
    var getStaffArr = [Int]()
    var rowNib = "CalendarCollectionViewCell"
    var selectedIndexPath: IndexPath?

    var clickIdType  = 0
    var getTeacherData : [GetTeacherwiseSlotAvailabilityData] = []
    var slotHistoryForParentData : [SlotHistoryForParentResponseData] = []
    var items: [Item] = [
           Item(title: "Item 1", isExpanded: false),
           Item(title: "Item 2", isExpanded: false),
           Item(title: "Item 3", isExpanded: false),
           Item(title: "Item 4", isExpanded: false),
           Item(title: "Item 5", isExpanded: false),
           Item(title: "Item 6", isExpanded: false)
       ]

    var instituteId  = Int()
    var sectionId = Int()
    var staffId  = Int()
    var studentId  : Int!
    var classId  = 0
    var yearArr = [Int]()
    var teacherSlotIdentifier =  "StaffPtmTableViewCell"
    var HeaderTv = "TimeHeader"
    var cancelTvCell  = "cancelTableViewCell"
    var getSubjectId = 0
    var getSubjectIdArr =  [Int]()
var getLoginClassId : Int!
    var getEventDate : String!
    var dropDownData : [SubjectListForStudentData] = []
    var studSlotData : [SlotAvailabilityForStudentsData] = []
    var eventDateArr = [String]()
    var eventCountArr = [String]()
    var duplicateStaffTimes: [Int: [(from_time: String, to_time: String)]] = [:]
    var clickId : Bool!
    var staffIdss : Int!
    let calendar = Calendar.current
       var dates = [Date]()
    var exNames : [Event] = []
    var slotdetails : [Slot] = []
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        bookSlotBtn.layer.cornerRadius = 5
        tvLeading.constant = 0
        tvTralling.constant = 0
        tv.isHidden=true
        DefaultsKeys.timesarr.removeAll()
        let userDefaults = UserDefaults.standard
        sectionId = userDefaults.integer(forKey: DefaultsKeys.SectionId)
        instituteId = userDefaults.integer(forKey: DefaultsKeys.SchoolD)
        staffId = userDefaults.integer(forKey: DefaultsKeys.StaffID)
        getLoginClassId = userDefaults.integer(forKey: DefaultsKeys.ClassID)
        var strChild = userDefaults.string(forKey: DefaultsKeys.chilId)

      
        studentId = Int(strChild!)
       

        cv.register(UINib(nibName: "PTMCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PTMCollectionViewCell")

        tv.register(UINib(nibName: cancelTvCell, bundle: nil), forCellReuseIdentifier: cancelTvCell)

        tv.register(UINib(nibName: tvcellIdentifier, bundle: nil), forCellReuseIdentifier: tvcellIdentifier)
        tv.register(UINib(nibName: teacherSlotIdentifier, bundle: nil), forCellReuseIdentifier: teacherSlotIdentifier)
//

        
        tv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        selectedCell = IndexPath()

        
        let segments1 = UITapGestureRecognizer(target: self, action: #selector(seg1Vc))
        
        segment1.addGestureRecognizer(segments1)
        let segments2 = UITapGestureRecognizer(target: self, action: #selector(seg2Vc))
        
        segment2.addGestureRecognizer(segments2)
        
//        updateMonthLabel()
        segment1.backgroundColor = UIColor(named: "CheckBoxSelectColor")
//


        noRecordsView.isHidden = true
        noRecordsLbl.isHidden =  true


        let backGesture = UITapGestureRecognizer(target: self, action: #selector(backVc))
        viewBack.addGestureRecognizer(backGesture)
        let dropDownGesture = UITapGestureRecognizer(target: self, action: #selector(DropDownVc))
        subView.addGestureRecognizer(dropDownGesture)



print("studentId",studentId)
     
        slotAvailability(studId: studentId, instId: instituteId)


        cv.register(UINib(nibName: rowNib, bundle: nil), forCellWithReuseIdentifier: rowNib)

        cv.dataSource = self
        cv.delegate = self
        generateDates()
       
        subjectListForStudent(studId: studentId, instId: instituteId)
        
        var todaysDate = NSDate()
                var dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                var DateInFormat = dateFormatter.string(from: todaysDate as Date)
                print("DateInFormat",DateInFormat)

                getEventDate = DateInFormat



        
        teacherWiseSlotAvailable(eventDate: getEventDate)

        tv.register(UINib(nibName: "TimeHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "TimeHeader")

        
        
    }
    


    func generateDates() {
           let currentDate = Date()
           for i in 0..<366 { // Including the current day
               if let futureDate = calendar.date(byAdding: .day, value: i, to: currentDate) {
                   dates.append(futureDate)
                   
               }
           }
           cv.reloadData()
       }
       




    @IBAction func DropDownVc(){

        var sub_names : [String] = []


        dropDownData.forEach { (field) in
            sub_names.append(field.subjectName)
            getSubjectIdArr.append(field.subjectId)
        }

        drop_down.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            dropDownLbl.text = item
            getSubjectId = getSubjectIdArr[index]
            print(" gest.fieldLbl.text", dropDownLbl.text)
            teacherWiseSlotAvailable(eventDate: getEventDate)

            if index < 1 {
                classId = 0
            }

        }


        drop_down.dataSource = sub_names
        drop_down.anchorView = subView
        drop_down.bottomOffset = CGPoint(x: 0, y:(drop_down.anchorView?.plainView.bounds.height)!)
        drop_down.show()

    }
    @IBAction func backVc(){
        
        DefaultsKeys.bookingSlotId.removeAll()
        dismiss(animated: true)


    }


  


    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {


        dates.count
        }


        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: rowNib, for: indexPath) as! CalendarCollectionViewCell

            let date = dates[indexPath.item]
            
            
            if ClickID == indexPath.row {
                cell.caleView.backgroundColor = .systemOrange
                cell.dayLbl.textColor = .white
                cell.dateLbl.textColor = .white
                cell.slotCountLbl.textColor = .white
                
            }
            else{
                cell.caleView.backgroundColor = UIColor(named: "NoDataColor")
                cell.dayLbl.textColor = .black
                cell.dateLbl.textColor = .black
                cell.slotCountLbl.textColor = .black
            }
        
           
            
            var boools = true
            
            for i in studSlotData{
                
                let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy" // Set your desired format
                    let dateString = dateFormatter.string(from: date)
              
                if i.eventDate == dateString{
                    boools = false
                    print("dateString",dateString)
                    cell.slotCountLbl.isHidden = boools
                    
                    cell.slotCountLbl.text = "Available slots " + i.count
                    
                }else{
                    
                    cell.slotCountLbl.isHidden = boools
                }
                
            }
            
            
            
            let dateFormatter = DateFormatter()
            // Input format
            dateFormatter.dateFormat = "dd/MM/yyyy"

    
                
                dateFormatter.dateFormat = "yyyy"
                let formattedDate1 = dateFormatter.string(from: date)
                
                dateFormatter.dateFormat = "MMM"
                let formattedDate2 = dateFormatter.string(from: date)
                
                dateFormatter.dateFormat = "d"
                let formattedDate = dateFormatter.string(from: date)
                
                cell.monthLbl.text =  formattedDate2
                cell.dateLbl.text = formattedDate + "," + formattedDate1
            
                    return cell




                }




    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Deselect the previously selected cell

        
        
        ClickID = indexPath.row

        let selectedDate = dates[indexPath.item]
        
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy" // Set your desired format
            let dateString = dateFormatter.string(from: selectedDate)
        teacherWiseSlotAvailable(eventDate : dateString)

        cv.dataSource = self
        cv.delegate = self
        cv.reloadData()


    }





                   // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
          return CGSize(width: 120, height: 100)
      }



    @IBAction func seg1Vc(){
        
        tvLeading.constant = 0
        tvTralling.constant = 0
        segmentId = 1
        segment1.backgroundColor = UIColor(named: "CheckBoxSelectColor")
        segment2.backgroundColor = .white
        calanderHeightCon.constant = 130

        subView.isHidden = false
        calendarView.isHidden = false
        subviewHeight.constant = 40
        tvTop.constant = 20
        teacherWiseSlotAvailable(eventDate: getEventDate)
        noRecordsView.isHidden = true
        tv.isHidden = false
        bookSlotBtn.isHidden = false

    }
    @IBAction func seg2Vc(){
        segmentId = 2

        tvLeading.constant = 30
        tvTralling.constant = 30
        subView.isHidden = true
        calendarView.isHidden = true
        slotHistoryForParent()
        print("calanderHeightCon.constant",calanderHeightCon.constant)
        calanderHeightCon.constant = 0
        subviewHeight.constant = -20
        print("calanderHeightt",calanderHeightCon.constant)

        tvTop.constant = -20
        segment2.backgroundColor = UIColor(named: "CheckBoxSelectColor")
        segment1.backgroundColor = .white
        if let headerView = tv.tableHeaderView {
            headerView.isHidden = true
        }

        tv.tableHeaderView = nil
        bookSlotBtn.isHidden = true
        tv.isHidden = false
        tv.dataSource = self
        tv.delegate = self
        tv.reloadData()
        
    }
    


//
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if segment1.backgroundColor == UIColor(named: "CheckBoxSelectColor") {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TimeHeader") as! TimeHeader



        

            headerView.meetingLbl.text = exNames[section].eventName
            headerView.modeLbl.text = exNames[section].event_mode

            headerView.nameAndSubjectLbl.text = exNames[section].subjectName + " - " + exNames[section].staff_name
            
            
            
            headerView.holeView.layer.cornerRadius = 8
                       
                        headerView.holeView.layer.masksToBounds = true
                        headerView.holeView.layer.shadowColor = UIColor.black.cgColor
                        headerView.holeView.layer.shadowOpacity = 0.5
                        headerView.holeView.layer.shadowOffset = CGSize(width: 4, height: 4)
                         headerView.holeView.layer.shadowRadius = 5
                        headerView.holeView.layer.masksToBounds = false
            
            return headerView
        }else{
            let view = UIView()
                   return view
        }

    }
    


    func timesBetween(start: String, end: String, intervalMinutes: Int) -> [Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"

        guard let startDate = dateFormatter.date(from: start),
              let endDate = dateFormatter.date(from: end) else {
            print("Invalid time format")
            return []
        }

        var times: [Date] = []
        var currentTime = startDate

        while currentTime <= endDate {
            times.append(currentTime)

            guard let nextTime = Calendar.current.date(byAdding: .minute, value: intervalMinutes, to: currentTime) else {
                break
            }

            currentTime = nextTime
        }

        return times
    }
    func numberOfSections(in tableView: UITableView) -> Int {

            if segment1.backgroundColor == UIColor(named: "CheckBoxSelectColor") {

                print("getTeacherDatacount",exNames.count)

                return  exNames.count

            }else{

                return 1

            }

        }

        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

            return UITableView.automaticDimension

        }



        

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            if segment1.backgroundColor == UIColor(named: "CheckBoxSelectColor") {

               return 1

            }else{

                

                return slotHistoryForParentData.count

            }

        }

        

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            print("TVcellForRowAtcellForRowAt")

            if segment1.backgroundColor == UIColor(named: "CheckBoxSelectColor") {

                let cell = tableView.dequeueReusableCell(withIdentifier: cancelTvCell, for: indexPath) as! cancelTableViewCell

                               cell.events = exNames
                               let event = exNames[indexPath.section]
                               cell.configure(with: event.slots)
                               
                               var timeAArr : [Int] = []


               print("ISBOOKEDVAL",exNames[indexPath.section].slots[indexPath.row].isBooked == 1)

                               


                               cell.slotdetails1 = exNames[indexPath.row].slots

                
                
                cell.call_back = { [self]
                    (val) in

//                    cell.configure(with: event.slots)
                   
                    tv.dataSource = self
                    tv.delegate = self
                    tv.reloadData()
                    }

                

                               return cell


            }else{



                let cell = tableView.dequeueReusableCell(withIdentifier: teacherSlotIdentifier, for: indexPath) as! StaffPtmTableViewCell
                
                cell.backView.layer.cornerRadius = 20
               
                cell.backView.layer.masksToBounds = true
                cell.backView.layer.shadowColor = UIColor.black.cgColor
                cell.backView.layer.shadowOpacity = 0.5
                cell.backView.layer.shadowOffset = CGSize(width: 4, height: 4)
                cell.backView.layer.shadowRadius = 1
                cell.backView.layer.masksToBounds = false
                cell.statusview.layer.masksToBounds = true
                cell.statusview.layer.shadowColor = UIColor.white.cgColor
                cell.statusview.layer.shadowOpacity = 0.5
                cell.statusview.layer.shadowOffset = CGSize(width: 4, height: 4)
                cell.statusview.layer.shadowRadius = 5
                cell.statusview.layer.masksToBounds = false

                var slotHistort : SlotHistoryForParentResponseData = slotHistoryForParentData[indexPath.row]

                cell.cancelAndReponeView.isHidden = true

                if slotHistort.status == "Upcoming" {

                    cell.cancelView.isHidden = false

                }else{

                    cell.cancelView.isHidden = true

                }

                let cancelGes = CanelSlotGesture(target: self, action: #selector(slotCancelAct))

                cancelGes.slotId = Int(slotHistort.slot_id)

                print("SLotId",slotHistort.slot_id)

                cell.cancelView.addGestureRecognizer(cancelGes)

                cell.eventName.text = slotHistort.purpose

                cell.studentName.text = slotHistort.staff_name

                cell.statusLbl.text = slotHistort.status

                cell.dateAndTimeLbl.text = slotHistort.slot_date

                cell.zoomLbl.text =  " Mode - " + slotHistort.mode

//                cell.eventLink.text = slotHistort.event_link



                if slotHistort.status == "Completed" {

                    cell.statusLbl.textColor = UIColor(named: "completed")

               } else if slotHistort.status == "Available" {

                   cell.statusLbl.textColor = .systemCyan

                } else if slotHistort.status == "Upcoming" {

                    cell.statusLbl.textColor = .systemCyan

               }else if slotHistort.status == "Expired" {

                   cell.statusLbl.textColor = UIColor(named: "Expried")

                }else if slotHistort.status == "Cancelled" {

                    cell.statusLbl.textColor = UIColor(named: "Expried")

                }else{

                    cell.statusLbl.textColor = UIColor(named: "Expried")

               }
//
                
                if slotHistort.event_link == ""{

                    cell.eventLink.isHidden = true

                }else{

                    cell.eventLink.isHidden = false
                   
                    cell.eventLink.isUserInteractionEnabled = true
                    let click = LinkSClicks(target: self, action: #selector(linkClickVC))
                    click.link = slotHistort.event_link
                    cell.eventLink.addGestureRecognizer(click)


                }
                
                
                let eventDate = slotHistort.slot_date
                let dateFormatter = DateFormatter()
                // Input format
                dateFormatter.dateFormat = "dd/MM/yyyy"

                if let date = dateFormatter.date(from: eventDate!) {

                    dateFormatter.dateFormat = "E, MMM d, yyyy"
                    let formattedDate = dateFormatter.string(from: date)

                    cell.dateAndTimeLbl.text = formattedDate + "," + slotHistort.slot_time 
                    print(formattedDate)
                } else {
                    print("Invalid date format")
                } // date converstion End

                return cell

            }

        }



    @IBAction func linkClickVC(ges: LinkSClicks){
        print("linkClickVC")
        openZoomLink(eventLink: ges.link)
    }
    
    func openZoomLink(eventLink: String) {
        // Encode the URL string to handle spaces and special characters
        guard let encodedLink = eventLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedLink) else {
            print("Invalid URL")
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            // The app is installed, open the link in the app
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // The app is not installed, redirect to the App Store
            let appStoreLink = "https://apps.apple.com/us/app/zoom-cloud-meetings/id546505307" // Zoom's App Store URL
            if let appStoreURL = URL(string: appStoreLink) {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
        }
    }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

            



            if segment1.backgroundColor == UIColor(named: "CheckBoxSelectColor") {



                let text = exNames[indexPath.section].slots.count


                if text == 1{
                    
                    return 80
                }
                           else if text < 5 {

                                return CGFloat(text * 40)
                            } else if text < 10 {
                                return CGFloat(text * 30)
                            } else{
                            return 300
                            }

            }else {


                return UITableView.automaticDimension



            }

        }



        func groupSlotsByStaffEventSubject(apiResponse: GetTeacherwiseSlotAvailabilityResponse) -> [Event] {

            var eventDict: [String: Event] = [:]

            

            for slotData in apiResponse.data {

                let key = "\(slotData.staff_id)-\(slotData.event_name)-\(slotData.subject_name)"

                

                // Create Slot object

                let slot = Slot(fromTime: slotData.from_time, toTime: slotData.to_time, slotId: slotData.slot_id,isBooked: slotData.is_booked)

                

                if var event = eventDict[key] {

                    // If the event already exists, append the slot

                    event.slots.append(slot)

                    eventDict[key] = event

                } else {

                    // If the event doesn't exist, create a new Event object

                    let newEvent = Event(staffId: slotData.staff_id, eventName: slotData.event_name, subjectName: slotData.subject_name, staff_name: slotData.staff_name, event_mode: slotData.event_mode, slots: [slot])

                    eventDict[key] = newEvent

                }

            }

            

            // Convert the dictionary to an array of Event objects

            return Array(eventDict.values)

        }



        @objc func slotClick(gets : CanelSlotGesture ) {



            teacherWiseSlotAvailable(eventDate: gets.slotDate)

        }





                

           func teacherWiseSlotAvailable(eventDate : String) {

               duplicateStaffTimes.removeAll()

            print("CONDTION")
               
               DefaultsKeys.date.removeAll()

            let param : [String : Any] =

            [

                "event_date": eventDate,

                "student_id": studentId!,

                "subject_id": getSubjectId,

                "class_teacher_id": classId,

                "institute_id": instituteId

            ]

               print(param)
   
            GetTeacherWiseSlotAvailabilityRequest.call_request(param: param){ [self]

                (res) in



                let teacherWiseSlotResponse : GetTeacherwiseSlotAvailabilityResponse = Mapper<GetTeacherwiseSlotAvailabilityResponse>().map(JSONString: res)!

                print("teacherWiseSlotAvailableRESPONSE",teacherWiseSlotResponse)

                if teacherWiseSlotResponse.Status == 1  {

                       let groupedEvents = groupSlotsByStaffEventSubject(apiResponse: teacherWiseSlotResponse)

                    exNames = groupedEvents
             
                    
                    
                    
                    tv.isHidden = false

                    noRecordsView.isHidden = true

                    noRecordsLbl.isHidden =  true

                    tv.dataSource = self

                    tv.delegate = self

                    tv.reloadData()

                    cv.dataSource = self

                    cv.delegate = self

                    cv.reloadData()



                }else{



                    noRecordsView.isHidden = false

                    noRecordsLbl.isHidden =  false

                    noRecordsLbl.text = teacherWiseSlotResponse.Message

                    tv.isHidden = true
                    
              
           }

            }

        }



        func subjectListForStudent(studId : Int,instId : Int) {

            let param : [String : Any] =

            [

                "student_id": studId,



                "institute_id": instId

            ]



    print("teacherWiseSlotAvailablePARAM",param)



            SubjectListForStudentRequest.call_request(param: param){ [self]

                (res) in



                let teacherWiseSlotResponse : SubjectListForStudentResponse = Mapper<SubjectListForStudentResponse>().map(JSONString: res)!





                if teacherWiseSlotResponse.Status == 1  {


                    dropDownData = teacherWiseSlotResponse.data

                    if dropDownData.count == 0{

                        

                        

                    }else{

//                        dropDownLbl.text = dropDownData[0].subjectName

                        //                classId = dropDownData[0].classTeacherId

                    }

                    tv.dataSource = self

                    tv.delegate = self

                    tv.reloadData()



                }else{


                    tv.dataSource = self
                    tv.delegate = self
                    tv.reloadData()



                }

            }



        }





        func slotAvailability(studId : Int,instId : Int) {


            let param : [String : Any] =

            [

                "student_id": studId,



                "institute_id": instId

            ]





    print("slotAvailabilityPARAM",param)

            SlotAvailablityForStudentRequest.call_request(param: param){ [self]

                (res) in



                let slotAvailabilityResponse : SlotAvailabilityForStudentsResponse = Mapper<SlotAvailabilityForStudentsResponse>().map(JSONString: res)!





                if slotAvailabilityResponse.Status == 1  {


                    studSlotData = slotAvailabilityResponse.data

                    cv.dataSource = self

                    cv.delegate = self

                    cv.reloadData()



                }else{



                    cv.dataSource = self

                    cv.delegate = self

                    cv.reloadData()



                }

            }



        }







        func bookingSlot() {

            let bookingSlotsForStudModal = BookingSlotsForStudModal()



            bookingSlotsForStudModal.student_id = studentId

            bookingSlotsForStudModal.slot_id  = DefaultsKeys.bookingSlotId

            bookingSlotsForStudModal.institute_id = instituteId


         


            var  bookingSlotsForStudModalStr = bookingSlotsForStudModal.toJSONString()

            print("bookingSlotsForStudModalStr",bookingSlotsForStudModal.toJSON())





            BookSlotsForStudentRequest.call_request(param: bookingSlotsForStudModalStr!) {



                [self] (res) in



                let bookingSlotsForStudRes : BookingSlotsForStudentsResponse = Mapper<BookingSlotsForStudentsResponse>().map(JSONString: res)!



                if bookingSlotsForStudRes.Status == 1 {


                    DefaultsKeys.bookingSlotId.removeAll()

                    let refreshAlert = UIAlertController(title: "", message: bookingSlotsForStudRes.Message, preferredStyle: UIAlertController.Style.alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in
                       
                        dismiss(animated: true)
                       
                    }))
                    present(refreshAlert, animated: true, completion: nil)


                }else{

                }

            }



        }









        @IBAction  func slotCancelAct(ges : CanelSlotGesture){

            let alertController = UIAlertController(title: "Alert",

                                                            message: "Reason for Cancel",

                                                            preferredStyle: .alert)

            

                    alertController.addTextField { textField in

                        textField.placeholder = "Reason"

                        textField.textColor = .blue

                        textField.clearButtonMode = .whileEditing

                        textField.borderStyle = .roundedRect

                    }

            



            let okAction = UIAlertAction(title: "OK", style: .default) { [self] action in

                        if let textFields = alertController.textFields,

                           let nameField = textFields.first {



                            if nameField.text != "" {

                                cancelSlot(slotId: ges.slotId,SlotReason: nameField.text!)

                                print("SLOTID",ges.slotId)

                                print("SlotReason",nameField.text!)

                            }else{

                                self.view.makeToast("Enter Reason")

                                print("Enter Reason")

                            }

                        }

                    }

            

                    alertController.addAction(okAction)

                    self.present(alertController, animated: true, completion: nil)

            





        }



        func cancelAndClose() {


            let cancelSlotsForStudModal = CancelAndCloseSlotByStaffModal()



            cancelSlotsForStudModal.slot_id = 49

            cancelSlotsForStudModal.staff_id = staffId

            cancelSlotsForStudModal.institute_id = instituteId


            var  cancelSlotsForStudModalStr = cancelSlotsForStudModal.toJSONString()

            print("cancelSlotsForStudModalStr",cancelSlotsForStudModal.toJSON())

            CancelSlotByParentRequest.call_request(param: cancelSlotsForStudModalStr!) {

                [self] (res) in


                let cancelSlotsForStudRes : CancelSlotsForStudentsResponse = Mapper<CancelSlotsForStudentsResponse>().map(JSONString: res)!



                if cancelSlotsForStudRes.Status == 1 {


                }else{

                
                }

            }



        }





        func slotHistoryForParent() {

            let param : [String : Any] =

            [



                "student_id": studentId!,



                "section_id": sectionId,

                "class_id":  getLoginClassId!,



                "institute_id": instituteId





            ]



    print("slotHistoryForParentPARAM",param)

            SlotHistoryForStudentRequest.call_request(param: param){ [self]

                (res) in



                let slotHistoryResponse : SlotHistoryForParentResponse = Mapper<SlotHistoryForParentResponse>().map(JSONString: res)!





                if slotHistoryResponse.Status == 1  {





                    slotHistoryForParentData = slotHistoryResponse.data



                    noRecordsView.isHidden = true

                    noRecordsLbl.isHidden =  true



                    if let headerView = tv.tableHeaderView {

                        headerView.isHidden = true

                    }

                    tv.dataSource = self

                    tv.delegate = self

                    tv.reloadData()



                }else{

                    if let headerView = tv.tableHeaderView {

                        headerView.isHidden = true

                    }

                    noRecordsView.isHidden = false

                    noRecordsLbl.isHidden =  false

                    noRecordsLbl.text = slotHistoryResponse.Message




                }

            }



        }



        

        



    //STAFF



        func createSlotByStaff() {





                     let createStdModal = CreateStdSecDetails()

                        createStdModal.class_id = classId

                        createStdModal.section_id = sectionId



                    let createSlotsModal = CreateSlotList()



                    createSlotsModal.from_time = "12"

                    createSlotsModal.to_time = "1333"







            let createSlotsByStaffModal = CreateSlotsByStaffModal()



                            createSlotsByStaffModal.institute_id = instituteId

                            createSlotsByStaffModal.date = "1333"

                            createSlotsByStaffModal.staff_id = staffId

                            createSlotsByStaffModal.break_time = 12

                            createSlotsByStaffModal.duration = 1333

                            createSlotsByStaffModal.event_name = "1344555"

                            createSlotsByStaffModal.from_time = "12"

                            createSlotsByStaffModal.to_time = "1333"

                            createSlotsByStaffModal.meeting_mode = "1344555"

                            createSlotsByStaffModal.event_link = "12"

                            createSlotsByStaffModal.slots = [createSlotsModal]

                            createSlotsByStaffModal.std_sec_details = [createStdModal]



            var  createSlotsByStaffModalStr = createSlotsByStaffModal.toJSONString()

            print("createSlotsByStaffModal",createSlotsByStaffModal.toJSON())

            BookSlotsForStudentRequest.call_request(param: createSlotsByStaffModalStr!) {



                [self] (res) in



                let bookingSlotsForStudRes : BookingSlotsForStudentsResponse = Mapper<BookingSlotsForStudentsResponse>().map(JSONString: res)!

                //

                //

                if bookingSlotsForStudRes.Status == 1 {









                }else{

                    //



                }

            }



        }










        func cancelSlot(slotId : Int,SlotReason : String) {







            let cancelSlotsForStudModal = CancelSlotsForStudModal()



            cancelSlotsForStudModal.student_id = studentId

            cancelSlotsForStudModal.slot_id = slotId

            cancelSlotsForStudModal.cancelled_reason = SlotReason

            cancelSlotsForStudModal.institute_id = instituteId





            var  cancelSlotsForStudModalStr = cancelSlotsForStudModal.toJSONString()

            print("cancelSlotsForStudModalStr",cancelSlotsForStudModal.toJSON())





            CancelSlotByParentRequest.call_request(param: cancelSlotsForStudModalStr!) {



                [self] (res) in



                let cancelSlotsForStudRes : CancelSlotsForStudentsResponse = Mapper<CancelSlotsForStudentsResponse>().map(JSONString: res)!



                if cancelSlotsForStudRes.Status == 1 {





                    let alert = UIAlertController(title: "", message: cancelSlotsForStudRes.Message, preferredStyle: UIAlertController.Style.alert)

                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))

                    self.present(alert, animated: true, completion:{ [self] in

                        //



                        tv.dataSource = self

                        tv.delegate = self

                        tv.reloadData()



                        alert.view.superview?.isUserInteractionEnabled = true

    //                    alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))

                    })







                }else{

                    //



                    let alert = UIAlertController(title: "Alert", message: cancelSlotsForStudRes.Message, preferredStyle: UIAlertController.Style.alert)

                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))

                    self.present(alert, animated: true, completion:{ [self] in

                        //



                        tv.dataSource = self

                        tv.delegate = self

                        tv.reloadData()



                        alert.view.superview?.isUserInteractionEnabled = true

    //

                    })



                }







            }



        }







        func cancelAndReopenSlot() {







            let cancelSlotsForStudModal = CancelSlotsForStudModal()



            cancelSlotsForStudModal.student_id = 12

            cancelSlotsForStudModal.slot_id = 1333

            cancelSlotsForStudModal.institute_id = instituteId

            cancelSlotsForStudModal.cancelled_reason = "ttt"





            var  cancelSlotsForStudModalStr = cancelSlotsForStudModal.toJSONString()

            print("cancelSlotsForStudModalStr",cancelSlotsForStudModal.toJSON())





            CancelSlotByParentRequest.call_request(param: cancelSlotsForStudModalStr!) {



                [self] (res) in



                let cancelSlotsForStudRes : CancelSlotsForStudentsResponse = Mapper<CancelSlotsForStudentsResponse>().map(JSONString: res)!



                if cancelSlotsForStudRes.Status == 1 {









                }else{

                    //



                }







            }



        }











        @IBAction func bookSlotAct(_ sender: Any) {

if DefaultsKeys.bookingSlotId.count == 0{

    let refreshAlert = UIAlertController(title: "", message: "Select time", preferredStyle: UIAlertController.Style.alert)

                       refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in


                       }))
                   present(refreshAlert, animated: true, completion: nil)

}else{


    let refreshAlert = UIAlertController(title: "", message: "Are you sure do you want to Book Slot?", preferredStyle: UIAlertController.Style.alert)

    refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] (action: UIAlertAction!) in



        bookingSlot()

    }))


    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
    print("Handle Cancel Logic here")
    }))

    present(refreshAlert, animated: true, completion: nil)



}
        }

        

        override open var shouldAutorotate: Bool

        {

            return false

        }

        

       

    }









    class CanelSlotGesture : UITapGestureRecognizer {

        var slotId : Int!

        var slotDate : String!

        var ViewColorChange : UIView!

        var pos : Int!

        var selectClickId : Int!

    }









    struct Slot: Codable {

        let fromTime: String

        let toTime: String

        let slotId: Int
        let isBooked: Int


    }



    struct Event: Codable {

        let staffId: Int

        let eventName: String

        let subjectName: String
        let staff_name: String
        let event_mode: String
        var slots: [Slot]

    }



    // Define the ApiResponse model

    struct SlotData: Codable {

        let event_link: String

       

        let event_name: String

        let from_time: String

        let is_booked: Int

        let my_booking: Int

        let slot_id: Int

        let staff_id: Int

      

        let subject_name: String

        let to_time: String

    }



    struct ApiResponse: Codable {

        let Message: String

        let Status: Int

        let data: [SlotData]

    }

class LinkSClicks : UITapGestureRecognizer{

    var link  : String!
    var slotid : Int!

}
