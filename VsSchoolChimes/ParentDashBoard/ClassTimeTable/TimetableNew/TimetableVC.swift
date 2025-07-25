////
////  TimetableVC.swift
////  VsSchoolChimes
////
////  Created by Admin on 16/01/25.
////
import UIKit

class TimetableVC: UIViewController {

    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var bgview: UIView!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var MenuTitleLbl: UILabel!
    @IBOutlet weak var TodayDateLbl: UILabel!
    @IBOutlet weak var TodayDefLbl: UILabel!
    
    var BottomsheetPresented = false
    let id = "TimetableTv"
    let id2 = "LastCell"

    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let daysFullname = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    let colours = ["AttendenceColor"]

    var getCurrentDay: String!
    var selectedIndex: Int = 0
    var timeTable: [TimetableHour]?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var dayStatus = ""
    private var progressTimer: Timer?
    
    var bottomSheetVC: TimetableBottomVC?


    override func viewDidLoad() {
        super.viewDidLoad()

        getCurrentDay = getCurrentDayShort()
        if let todayIndex = days.firstIndex(of: getCurrentDay) {
            selectedIndex = todayIndex
        }
        
//        containerView.layer.cornerRadius = 10
//        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yy"
        let formattedDate = formatter.string(from: Date())
        TodayDateLbl.text = formattedDate
        print(formattedDate)


        BackBtn.applyBackButton()
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        MenuTitleLbl.setFont(style: .header, size: 20)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        TodayDefLbl.setFont(style: .body, size: FontSize.BodySize)
        TodayDateLbl.setFont(style: .body, size: FontSize.BodySize)
        NameLbl.text = studentDetails?.name
        StandardLbl.text = (studentDetails?.standard_name ?? "") + " - " + (studentDetails?.section_name ?? "")

        cv.register(UINib(nibName: CellConfingName.WeekDaysNameCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: CellConfingName.WeekDaysNameCollectionViewCell)
        cv.delegate = self
        cv.dataSource = self

        DispatchQueue.main.async {
            self.cv.selectItem(at: IndexPath(item: self.selectedIndex, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if !BottomsheetPresented {
            PresentBottomSheet()
            BottomsheetPresented = true
        }
        daily_collectionApi(type: selectedIndex)
    }
    
    func PresentBottomSheet(){
        
        let Bottomsheet = TimetableBottomVC()
        self.bottomSheetVC = Bottomsheet
        let nav = UINavigationController(rootViewController: Bottomsheet)
        nav.modalPresentationStyle = .pageSheet
        
        
        
        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                
                if #available(iOS 16.0, *) {
                    sheet.detents = [.custom(resolver: { _ in 510 }), .large()]
                } else {
                    sheet.detents = [.medium(), .large()] // Fallback
                }
                
                sheet.largestUndimmedDetentIdentifier = .large
                sheet.prefersGrabberVisible = true
            }
        } else {
            // Fallback on earlier versions
        }
        
        nav.isModalInPresentation = true
        present(nav, animated: true)
    }
    
   //"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjaGlsZF9pZCI6Ijk2NzQ2ODYiLCJzY2hvb2xfaWQiOiI3MDQzIiwiY2xhc3NfaWQiOjMyNTgyLCJzZWN0aW9uX2lkIjo5MDgxMywiaWF0IjoxNzUzMzM5ODIxfQ.BTdYpDv8tZG7B0L5myEMVbpDi7nerChzozTgOgJKhc8"
   
    func daily_collectionApi(type: Int) {
        APIService.shared.makeApi(
            url: ServiceUrl.lms_api_time_table_get_schedule,
            parameters: ["day_id": type + 1],
            type: ApitTypeSringFile.GET,
            token:  UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<TimetableResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                   
                    self?.timeTable = response.data
                    self?.bottomSheetVC?.DayLbl.text = self?.daysFullname[self?.selectedIndex ?? 0]
                    self?.bottomSheetVC?.updateData(response.data ?? [])
                    self?.dayStatus = getDayStatus(for: self?.days[self?.selectedIndex ?? 0] ?? "")
                case .failure(let error):
                    print("API Error:", error)
                }
            }
        }
    }

    @IBAction func BackAct(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }

    
}
// MARK: - CollectionView

extension TimetableVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.WeekDaysNameCollectionViewCell, for: indexPath) as! WeekDaysNameCollectionViewCell
        let day = days[indexPath.row]
        cell.weekDaysNameLbl.text = day
        cell.bgView.backgroundColor = (indexPath.row == selectedIndex) ? Colornames.Timetable : .clear
        cell.bgView.layer.borderColor = (indexPath.row == selectedIndex) ? Colornames.Timetable.cgColor : UIColor.white.cgColor
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        bottomSheetVC?.DayLbl.text = daysFullname[indexPath.row]
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        daily_collectionApi(type: selectedIndex)
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? WeekDaysNameCollectionViewCell {
            cell.bgView.backgroundColor = .systemGray6
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}

// MARK: - Helper Functions

func getCurrentDayShort() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: Date())
}

func getDayStatus(for dayShort: String) -> String {
    let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    guard let todayIndex = weekDays.firstIndex(of: getCurrentDayShort()),
          let selectedIndex = weekDays.firstIndex(of: dayShort) else {
        return "unknown"
    }

    if selectedIndex == todayIndex {
        return "present"
    } else if selectedIndex < todayIndex {
        return "past"
    } else {
        return "future"
    }
}
