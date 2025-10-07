////
////  TimetableVC.swift
////  VsSchoolChimes
////
////  Created by Admin on 16/01/25.
////
import UIKit

class TimetableVC: UIViewController {

    
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var MenuTitleLbl: UILabel!
    @IBOutlet weak var TodayDateLbl: UILabel!
    @IBOutlet weak var TodayDefLbl: UILabel!
    @IBOutlet weak var studentNameLbl: UILabel!
    
    
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let daysFullname = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    var getCurrentDay: String!
    var selectedIndex: Int = 0
    var studentDetails = UserDefaultFileManager.get_child_Details()
    
    var bottomSheetVC: TimetableBottomVC?
    var BottomsheetPresented = false

    override func viewDidLoad() {
            super.viewDidLoad()

            // Get today’s short day
            getCurrentDay = getCurrentDayShort()
            if let todayIndex = days.firstIndex(of: getCurrentDay) {
                selectedIndex = todayIndex
            }
            
            // Format today’s date
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, dd MMM yy"
            TodayDateLbl.text = formatter.string(from: Date())

            // UI setup
            BackBtn.applyBackButton()
        
            TodayDefLbl.setFont(style: .body, size: FontSize.BodySize)
            TodayDateLbl.setFont(style: .body, size: FontSize.BodySize)
           // MenuTitleLbl.setFont(style: .header, size: FontSize.HeaderSize)
            
            let Name = studentDetails?.name ?? ""
            let Standard = (studentDetails?.standard_name ?? "") + " - " + (studentDetails?.section_name ?? "")
        
        studentNameLbl.configureAsBackTitle(firstLine: Name, secondLine: Standard)

            // Collection view setup
            cv.register(UINib(nibName: CellConfingName.WeekDaysNameCollectionViewCell, bundle: nil),
                        forCellWithReuseIdentifier: CellConfingName.WeekDaysNameCollectionViewCell)
            cv.delegate = self
            cv.dataSource = self
            
            let bottomSheet = TimetableBottomVC()
            bottomSheetVC = bottomSheet
            bottomSheet.DayId = selectedIndex + 1
            bottomSheet.loadViewIfNeeded()
            bottomSheet.DayLbl.text = daysFullname[selectedIndex]
            //bottomSheet.get_Timetable()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            // ✅ Select today immediately (so no jump later)
            let indexPath = IndexPath(item: selectedIndex, section: 0)
            cv.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            if !BottomsheetPresented, let bottomSheet = bottomSheetVC {
                let nav = UINavigationController(rootViewController: bottomSheet)
                nav.modalPresentationStyle = .pageSheet
                if #available(iOS 15.0, *), let sheet = nav.sheetPresentationController {
                    if #available(iOS 16.0, *) {
                        sheet.detents = [.custom(resolver: { _ in 510 }), .large()]
                    } else {
                        sheet.detents = [.medium(), .large()]
                    }
                    sheet.largestUndimmedDetentIdentifier = .large
                    sheet.prefersGrabberVisible = true
                }
                nav.isModalInPresentation = true
                present(nav, animated: true)
                BottomsheetPresented = true
            }
        }

        
        func PresentBottomSheet(animated: Bool) {
            let bottomSheet = TimetableBottomVC()
            self.bottomSheetVC = bottomSheet
            let nav = UINavigationController(rootViewController: bottomSheet)
            nav.modalPresentationStyle = .pageSheet

            // Pass today’s data
            bottomSheet.DayId = selectedIndex + 1
            bottomSheet.loadViewIfNeeded()
            bottomSheet.DayLbl.text = daysFullname[selectedIndex]
            bottomSheet.get_Timetable()

            if #available(iOS 15.0, *) {
                if let sheet = nav.sheetPresentationController {
                    if #available(iOS 16.0, *) {
                        sheet.detents = [.custom(resolver: { _ in 510 }), .large()]
                    } else {
                        sheet.detents = [.medium(), .large()]
                    }
                    sheet.largestUndimmedDetentIdentifier = .large
                    sheet.prefersGrabberVisible = true
                }
            }

            nav.isModalInPresentation = true
            present(nav, animated: animated) // ✅ controlled by caller
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

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellConfingName.WeekDaysNameCollectionViewCell,
            for: indexPath
        ) as! WeekDaysNameCollectionViewCell
        let day = days[indexPath.row]
        cell.weekDaysNameLbl.text = day
        cell.bgView.backgroundColor = (indexPath.row == selectedIndex) ? Colornames.Timetable : .clear
        cell.bgView.layer.borderColor = (indexPath.row == selectedIndex) ? Colornames.Timetable.cgColor : UIColor.white.cgColor
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        bottomSheetVC?.DayLbl.text = daysFullname[indexPath.row]
        bottomSheetVC?.DayId = indexPath.row + 1
        bottomSheetVC?.get_Timetable() // refresh data
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? WeekDaysNameCollectionViewCell {
            cell.bgView.backgroundColor = .systemGray6
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
}

// MARK: - Helper

func getCurrentDayShort() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.string(from: Date())
}
