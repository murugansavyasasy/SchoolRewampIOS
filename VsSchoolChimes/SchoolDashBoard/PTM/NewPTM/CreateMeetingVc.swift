//
//  CreateMeetingVc.swift
//  School Chimes
//
//  Created by Lakshmanan on 14/08/25.
//

import UIKit
import FSCalendar
import DropDown

struct ClassDisplayItem {
    let displayName: String
    let standardId: String
    let sectionId: String
}

@available(iOS 14.0, *)
class CreateMeetingVc: UIViewController, Datepicker, FSCalendarDelegate, FSCalendarDataSource, reloadDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var purposeDefLbl: UILabel!
    @IBOutlet weak var purposeTextfield: UITextField!
    @IBOutlet weak var ModeDefLbl: UILabel!
    @IBOutlet weak var inpersonBtn: UIButton!
    @IBOutlet weak var phonecallBtn: UIButton!
    @IBOutlet weak var onlineBtn: UIButton!
    @IBOutlet weak var EnterMobileDefLbl: UILabel!
    @IBOutlet weak var mobileTextfield: UITextField!
    @IBOutlet weak var meetingLinkDefLbl: UILabel!
    @IBOutlet weak var meetingLinkTextfield: PasteOnlyTextField!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var mobileStack: UIStackView!
    @IBOutlet weak var linkStack: UIStackView!
    @IBOutlet weak var selectClassDefLbl: UILabel!
    @IBOutlet weak var classCv: UICollectionView!
    @IBOutlet weak var classCVHeight: NSLayoutConstraint!
    @IBOutlet weak var selectDateTimeDefLbl: UILabel!
    @IBOutlet weak var dateSelectionView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var FromTimeView: UIView!
    @IBOutlet weak var fromTimeLbl: UILabel!
    @IBOutlet weak var toTimeView: UIView!
    @IBOutlet weak var toTimeLbl: UILabel!
    @IBOutlet weak var stepper: LabeledStepper!
    @IBOutlet weak var breakDurationCV: UICollectionView!
    @IBOutlet weak var SelectClassBaseView: UIView!
    @IBOutlet weak var selectDateTimeBaseView: UIView!
    @IBOutlet weak var DurationBaseView: UIView!
    @IBOutlet weak var selectDurationView: UIView!
    @IBOutlet weak var DurationAndBreakDefLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var calendarBaseview: UIView!
    @IBOutlet weak var calenderHideView: UIView!
    @IBOutlet weak var calendarMonthLbl: UILabel!
    @IBOutlet weak var calendarDoneBtn: UIButton!
    @IBOutlet weak var selectedDatesCv: UICollectionView!
    @IBOutlet weak var DatesCvHeight: NSLayoutConstraint!
    @IBOutlet weak var customDurationView: UIView!
    @IBOutlet weak var durationTextfield: UITextField!
    @IBOutlet weak var minutesDefLbl: UILabel!
    @IBOutlet weak var breakSwitch: UISwitch!
    @IBOutlet weak var breakSlotView: UIView!
    @IBOutlet weak var BreakDurationDefLbl: UILabel!
    @IBOutlet weak var CheckSlotBtn: UIButton!
    @IBOutlet weak var academicYearView: UIView!
    @IBOutlet weak var chooseAcademicyeardefLbl: UILabel!
    @IBOutlet weak var academicYearLabel: UILabel!
    @IBOutlet weak var academicyearView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var needBreakDefLbl: UILabel!
    @IBOutlet weak var breakAfterLbl: UILabel!
    @IBOutlet weak var afterSlotsDefLbl: UILabel!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var calendarcancelBtn: UIButton!
    
    var breakDuration: [String] = []
    var SelectedClasses = Set<IndexPath>()
    var SelectedDuration: IndexPath = IndexPath(item: 0, section: 0)
    var SelectedDates: [String] = []
    private var fromTimePickerContainer: UIView?
    private var toTimePickerContainer: UIView?
    private var fromTimePicker: UIDatePicker?
    private var toTimePicker: UIDatePicker?
    let dropDown = DropDown()
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var validatedData : [ValidatedSlotData] = []
    var academicYearDataList: [AcadimicYearData] = []
    var academicYears: [String] = []
    var academicDropDown = DropDown()
    var academicId: Int?
    var classList: [ClassDisplayItem] = []
    var selectedClasses: [[String: String]] = []
    var meetingMode = "In Person"
    var BreakBetweenSlot = 1
    var durationValue: Int? // store the duration you'll send in API
    var breakDurationValue = 0
    private var activeTextField: UITextField?
    var currentPage: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.layer.cornerRadius = 20
        topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        NameLbl.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName, secondLine: staffDetails?.school_name ?? "")
        
        titleLbl.isHidden = true
        
        titleLbl.setFont(style: .header, size: FontSize.HeaderSize)
        purposeDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        ModeDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        EnterMobileDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        meetingLinkDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        selectClassDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        selectDateTimeDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        DurationAndBreakDefLbl.setFont(style: .title, size: FontSize.TitleSize)
        dateLbl.setFont(style: .body, size: FontSize.BodySize)
        fromTimeLbl.setFont(style: .body, size: FontSize.BodySize)
        toTimeLbl.setFont(style: .body, size: FontSize.BodySize)
        academicYearLabel.setFont(style: .body, size: FontSize.BodySize)
        chooseAcademicyeardefLbl.setFont(style: .body, size: FontSize.BodySize)
        needBreakDefLbl.setFont(style: .body, size: FontSize.BodySize)
        breakAfterLbl.setFont(style: .body, size: FontSize.BodySize)
        afterSlotsDefLbl.setFont(style: .body, size: FontSize.BodySize)
        BreakDurationDefLbl.setFont(style: .body, size: FontSize.BodySize)
        
        inpersonBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        phonecallBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        onlineBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        inpersonBtn.titleLabel?.numberOfLines = 0
        inpersonBtn.titleLabel?.lineBreakMode = .byWordWrapping
        phonecallBtn.titleLabel?.numberOfLines = 0
        phonecallBtn.titleLabel?.lineBreakMode = .byWordWrapping
        onlineBtn.titleLabel?.numberOfLines = 0
        onlineBtn.titleLabel?.lineBreakMode = .byWordWrapping
        
        [firstView, SelectClassBaseView, selectDateTimeBaseView, DurationBaseView]
          .compactMap { $0 }
          .forEach { $0.applyCardStyle() }
        
        Translate()
        
        customDurationView.isHidden = true
        
        breakSlotView.isHidden = true
        BreakDurationDefLbl.isHidden = true
        breakDurationCV.isHidden = true
        
        inpersonBtn.layer.cornerRadius = 10
        phonecallBtn.layer.cornerRadius = 10
        onlineBtn.layer.cornerRadius = 10
        
        mobileStack.isHidden = true
        linkStack.isHidden = true
        
        purposeTextfield.addDoneButton()
        mobileTextfield.addDoneButton()
        durationTextfield.addDoneButton()
        
        meetingLinkTextfield.delegate = self
        meetingLinkTextfield.inputView = UIView()
        
        stepper.minimumValue = 1
        stepper.value = 1
        
        dateSelectionView.layer.cornerRadius = 10
        FromTimeView.layer.cornerRadius = 10
        toTimeView.layer.cornerRadius = 10
        selectDurationView.layer.cornerRadius = 10
        dateSelectionView.layer.borderWidth = 1
        FromTimeView.layer.borderWidth = 1
        toTimeView.layer.borderWidth = 1
        selectDurationView.layer.borderWidth = 1
        dateSelectionView.layer.borderColor = UIColor.systemGray4.cgColor
        FromTimeView.layer.borderColor = UIColor.systemGray4.cgColor
        toTimeView.layer.borderColor = UIColor.systemGray4.cgColor
        selectDurationView.layer.borderColor = UIColor.systemGray4.cgColor
        
        academicyearView.layer.cornerRadius = 10
        academicyearView.layer.shadowColor = UIColor.black.cgColor
        academicyearView.layer.shadowOpacity = 0.4
        academicyearView.layer.shadowOffset = CGSize(width: 2, height: 2)
        academicyearView.layer.shadowRadius = 4
        academicyearView.layer.masksToBounds = false
        
        getAcadmicYear()
        Get_Standards_Api()
        
        dateSelectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectDate)))
        FromTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectFromTime)))
        toTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectTotime)))
        selectDurationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDuration)))
        
        setupDropDown()
        
        calenderHideView.isHidden = true
        
        calendar.delegate = self
        calendar.dataSource = self
        calendar.appearance.headerTitleColor = .systemBlue
        calendar.appearance.weekdayTextColor = .darkGray
        calendar.appearance.selectionColor = .systemRed
        calendar.placeholderType = .none
        calendar.headerHeight = 0
        calendar.allowsMultipleSelection = true
        currentPage = calendar.currentPage
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        calendarMonthLbl.text = formatter.string(from: calendar.currentPage)
        prevButton.isEnabled = !isCurrentMonth(calendar.currentPage)
        prevButton.tintColor = isCurrentMonth(calendar.currentPage) ? .darkGray : .systemBlue
        
        calendar.appearance.todayColor = .clear      // removes the circle background
        calendar.appearance.titleTodayColor = .systemBlue   // set text color for today
        
        calendar.appearance.selectionColor = .backGroundClr
        calendar.appearance.titleSelectionColor = .white
        
        calendarBaseview.layer.shadowColor = UIColor.black.cgColor   // shadow color
        calendarBaseview.layer.shadowOpacity = 0.2                   // transparency (0 = invisible, 1 = solid)
        calendarBaseview.layer.shadowOffset = CGSize(width: 0, height: 4) // shadow position
        calendarBaseview.layer.shadowRadius = 6                      // blur radius
        calendarBaseview.layer.masksToBounds = false                 // must be false for shadow to show
        calendarBaseview.layer.cornerRadius = 12                     // optional rounded corners
        
        calendarDoneBtn.layer.cornerRadius = 10
        calendarDoneBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        calendarcancelBtn.layer.cornerRadius = 10
        calendarcancelBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        calendarMonthLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        CheckSlotBtn.layer.cornerRadius = 12
        CheckSlotBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        let five = String(format: PTMString.minShort, 5)   // "5 Min"
        let ten = String(format: PTMString.minShort, 10)   // "10 Min"
        let fifteen = String(format: PTMString.minShort, 15) // "15 Min"
        let thirty = String(format: PTMString.minShort, 30) // "30 Min"

        breakDuration = [five,ten,fifteen,thirty]
        
        //breakDurationCV.allowsMultipleSelection = false
        classCv.allowsMultipleSelection = true
        
        DatesCvHeight.constant = 0
        
        if let layout = selectedDatesCv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = .zero
            layout.itemSize.height = 50
        }
        
        classCv.register(UINib(nibName: "SlotCV", bundle: nil), forCellWithReuseIdentifier: "SlotCV")
        breakDurationCV.register(UINib(nibName: "SlotCV", bundle: nil), forCellWithReuseIdentifier: "SlotCV")
        selectedDatesCv.register(UINib(nibName: CellConfingName.DateCVC, bundle: nil), forCellWithReuseIdentifier: CellConfingName.DateCVC)
        classCv.delegate = self
        classCv.dataSource = self
        breakDurationCV.delegate = self
        breakDurationCV.dataSource = self
        selectedDatesCv.delegate = self
        selectedDatesCv.dataSource = self
        
        NotificationCenter.default.addObserver(self,
                                                      selector: #selector(keyboardWillShow),
                                                      name: UIResponder.keyboardWillShowNotification,
                                                      object: nil)

               NotificationCenter.default.addObserver(self,
                                                      selector: #selector(keyboardWillHide),
                                                      name: UIResponder.keyboardWillHideNotification,
                                                      object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    
    func Translate(){
        
        titleLbl.text = PTMString.createMeeting
        purposeDefLbl.text = PTMString.purposeOfMeeting
        ModeDefLbl.text = PTMString.selectMeetingMode
        meetingLinkDefLbl.text = PTMString.pasteMeetingLink
        selectClassDefLbl.text = PTMString.selectYourClasses
        chooseAcademicyeardefLbl.text = PTMString.chooseAcademicYear
        selectDateTimeDefLbl.text = PTMString.selectDateTime
        dateLbl.text = PTMString.selectDates
        fromTimeLbl.text = PTMString.startWith
        toTimeLbl.text = PTMString.endWith
        DurationAndBreakDefLbl.text = PTMString.durationAndBreak
        durationLbl.text = "Select Slot Duration"//PTMString.duration
        minutesDefLbl.text = PTMString.minutes
        needBreakDefLbl.text = PTMString.needBreakBetweenSlots
        breakAfterLbl.text = PTMString.breakAfter
        afterSlotsDefLbl.text = PTMString.slot
        BreakDurationDefLbl.text = PTMString.breakDuration
        inpersonBtn.setTitle(PTMString.inPerson, for: .normal)
        phonecallBtn.setTitle(PTMString.phoneCall, for: .normal)
        onlineBtn.setTitle(PTMString.virtual, for: .normal)
        CheckSlotBtn.setTitle(PTMString.checkSlotAvailability, for: .normal)
        calendarDoneBtn.setTitle(AlertstringFile.Done, for: .normal)
    }

    
    func getAcadmicYear() {
        academicYears = localData.accidamic_year_data?.data?.compactMap { $0.year } ?? []
        academicYearDataList = localData.accidamic_year_data?.data ?? []
        academicYearLabel.text = academicYears.last ?? ""
        academicId = localData.accidamic_year_data?.data?.last?.id ?? 0
    }
    
    
    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    
    @IBAction func inpersonAct(_ sender: Any) {
        
        meetingMode = "In Person"
        inpersonBtn.backgroundColor = .systemBlue
        inpersonBtn.setTitleColor(.white, for: .normal)
        
        phonecallBtn.backgroundColor = .systemGray5
        phonecallBtn.setTitleColor(.black, for: .normal)
        onlineBtn.backgroundColor = .systemGray5
        onlineBtn.setTitleColor(.black, for: .normal)
        
        mobileStack.isHidden = true
        linkStack.isHidden = true
    }
    
    @IBAction func PhoneCallAct(_ sender: Any) {
        
        meetingMode = "Phone Call"
        phonecallBtn.backgroundColor = .systemBlue
        phonecallBtn.setTitleColor(.white, for: .normal)
        
        inpersonBtn.backgroundColor = .systemGray5
        inpersonBtn.setTitleColor(.black, for: .normal)
        onlineBtn.backgroundColor = .systemGray5
        onlineBtn.setTitleColor(.black, for: .normal)
        
        mobileStack.isHidden = true
        linkStack.isHidden = true
    }
    
    @IBAction func OnlineAct(_ sender: Any) {
        
        meetingMode = "Online"
        onlineBtn.backgroundColor = .systemBlue
        onlineBtn.setTitleColor(.white, for: .normal)
        
        inpersonBtn.backgroundColor = .systemGray5
        inpersonBtn.setTitleColor(.black, for: .normal)
        phonecallBtn.backgroundColor = .systemGray5
        phonecallBtn.setTitleColor(.black, for: .normal)
        
        mobileStack.isHidden = true
        linkStack.isHidden = false
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date() // User cannot select before today
    }
    
    @IBAction func NextMonthBtnAct(_ sender: Any) {
        
        moveCurrentPage(isNext: true)
    }
    
    @IBAction func previousMonthBtnAct(_ sender: Any) {
        
        moveCurrentPage(isNext: false)
    }
    
    func moveCurrentPage(isNext: Bool) {
        let calendarSystem = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = isNext ? 1 : -1
        
        if let currentPage = currentPage,
           let newPage = calendarSystem.date(byAdding: dateComponents, to: currentPage) {
            calendar.setCurrentPage(newPage, animated: true)
            self.currentPage = newPage
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        calendarMonthLbl.text = formatter.string(from: calendar.currentPage)
        
        prevButton.isEnabled = !isCurrentMonth(calendar.currentPage)
        prevButton.tintColor = isCurrentMonth(calendar.currentPage) ? .darkGray : .systemBlue
    }
    
    func isCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        
        let todayComponents = calendar.dateComponents([.year, .month], from: today)
        let dateComponents = calendar.dateComponents([.year, .month], from: date)
        
        return todayComponents.year == dateComponents.year &&
               todayComponents.month == dateComponents.month
    }

    
//    // Disable typing manually
//        func textField(_ textField: UITextField,
//                       shouldChangeCharactersIn range: NSRange,
//                       replacementString string: String) -> Bool {
//            if textField == meetingLinkTextfield {
//                return false // block typing entirely
//            }
//            return true
//        }
//
//        // Allow only paste action
//        override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//            if meetingLinkTextfield.isFirstResponder {
//                if action == #selector(UIResponderStandardEditActions.paste(_:)) {
//                    return true
//                } else {
//                    return false
//                }
//            }
//            return super.canPerformAction(action, withSender: sender)
//        }
//
//        // Handle paste action
//        override func paste(_ sender: Any?) {
//            if meetingLinkTextfield.isFirstResponder {
//                if let pastedString = UIPasteboard.general.string {
//                    meetingLinkTextfield.text = pastedString.trimmingCharacters(in: .whitespacesAndNewlines)
//                }
//            } else {
//                super.paste(sender)
//            }
//        }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return monthPosition == .current
    }
    
    
    @IBAction func selectAcademicYear(_ sender: UIButton) {
        academicDropDown.anchorView = sender
        academicDropDown.dataSource = academicYears
        academicDropDown.bottomOffset = CGPoint(x: 0, y: sender.bounds.height)
        academicDropDown.show()
        
        academicDropDown.selectionAction = { [weak self] index, item in
            self?.academicYearLabel.text = item
            self?.academicId = self?.academicYearDataList[index].id
            self?.Get_Standards_Api()
        }
    }
    
    @IBAction func SelectFromTime(){
        
        showTimePicker(below: FromTimeView, isFrom: true)
    }
    
    private func showTimePicker(below baseView: UIView, isFrom: Bool) {
        // Remove old picker (so only one shows at a time)
        fromTimePickerContainer?.removeFromSuperview()
        toTimePickerContainer?.removeFromSuperview()
        
        // Container
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 10
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.25
        container.layer.shadowOffset = CGSize(width: 0, height: 3)
        container.layer.shadowRadius = 5
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        // Picker
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(picker)
        
        // Done button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = UIColor.systemBlue
        doneButton.layer.cornerRadius = 6
        doneButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(doneButton)
        
        // Layout below the tapped view
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: baseView.bottomAnchor, constant: 8),
            container.centerXAnchor.constraint(equalTo: baseView.centerXAnchor),
            container.widthAnchor.constraint(equalToConstant: 200),
            container.heightAnchor.constraint(equalToConstant: 160),
            
            picker.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            picker.heightAnchor.constraint(equalToConstant: 110),
            
            doneButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            doneButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        // Assign
        if isFrom {
            fromTimePickerContainer = container
            fromTimePicker = picker
            doneButton.tag = 1
        } else {
            toTimePickerContainer = container
            toTimePicker = picker
            doneButton.tag = 2
        }
        
        // Done button action
        doneButton.addTarget(self, action: #selector(doneTapped(_:)), for: .touchUpInside)
    }

    
    // MARK: - Done Action
    @objc private func doneTapped(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"  // 12-hour with leading zero + AM/PM
        formatter.amSymbol = "am"        // force lowercase
        formatter.pmSymbol = "pm"        // force lowercase

        if sender.tag == 1, let picker = fromTimePicker {
            let formattedTime = formatter.string(from: picker.date)
            print("From Time: \(formattedTime)")
            fromTimeLbl.text = formattedTime
            fromTimePickerContainer?.removeFromSuperview()
        } else if sender.tag == 2, let picker = toTimePicker {
            let formattedTime = formatter.string(from: picker.date)
            print("To Time: \(formattedTime)")
            toTimeLbl.text = formattedTime
            toTimePickerContainer?.removeFromSuperview()
        }
    }
    
    @IBAction func selectTotime(){
        
        showTimePicker(below: toTimeView, isFrom: false)
    }
    
    @IBAction func SelectDate(){
        showCalendar()
    }
    
    func showCalendar() {
        calenderHideView.alpha = 0
        calenderHideView.isHidden = false
        
        UIView.animate(withDuration: 0.1) {
            self.calenderHideView.alpha = 1
        }
    }
    
    func hideCalendar() {
        UIView.animate(withDuration: 0.1, animations: {
            self.calenderHideView.alpha = 0
        }) { _ in
            self.calenderHideView.isHidden = true
        }
    }
    
    func setSelectedDatesInCalendar(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        for date in calendar.selectedDates{
            calendar.deselect(date)
        }
        
        calendar.allowsMultipleSelection = true
        
        for dateString in SelectedDates{
            if let date = formatter.date(from: dateString) {
                calendar.select(date)
            }
        }
    }
    
    func date(date: String) {
        
        dateLbl.text = date
    }
    @IBAction func DateDoneAct(_ sender: Any) {
        
        let PickedDates = calendar.selectedDates
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateStrings = PickedDates.map { formatter.string(from: $0)}
        self.SelectedDates = dateStrings
        let rows = ceil(Double(SelectedDates.count) / 3.0)
        let height = CGFloat(rows) * 50.0
        DispatchQueue.main.async {
            self.DatesCvHeight.constant = height
            self.view.layoutIfNeeded()
            self.selectedDatesCv.reloadData()
        }
        hideCalendar()
    }
    
    @IBAction func cancelAct(_ sender: Any) {
        hideCalendar()
        setSelectedDatesInCalendar()
    }
    
    func reload(index: Int) {
    }
    
    func deleteDelegate(index: Int) {
        let dateString = SelectedDates[index]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        if let dateToRemove = formatter.date(from: dateString) {
            calendar.deselect(dateToRemove) // removes highlight
        }
        
        SelectedDates.remove(at: index)
        
        let rows = ceil(Double(SelectedDates.count) / 3.0)
        
        DispatchQueue.main.async {
            self.DatesCvHeight.constant = CGFloat(rows) * 50.0
            self.view.layoutIfNeeded()
            self.selectedDatesCv.reloadData()
        }
    }

    
    @IBAction func selectDuration(){
        
        dropDown.show()
    }
    
    private func setupDropDown() {
        dropDown.anchorView = selectDurationView
        
        let duration10 = String(format: PTMString.min, 10)
        let duration15 = String(format: PTMString.min, 15)
        let duration20 = String(format: PTMString.min, 20)
        let duration30 = String(format: PTMString.min, 30)

        dropDown.dataSource = [duration10, duration15, duration20, duration30, PTMString.custom]

        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            durationLbl.text = item
            
            if index == dropDown.dataSource.count - 1 {
                // Custom option selected
                customDurationView.isHidden = false
                durationValue = nil // will be set when user enters custom value
            } else {
                customDurationView.isHidden = true
                durationTextfield.text = ""
                
                // Extract the number from the string and store it as Int
                let components = item.components(separatedBy: " ")
                if let firstPart = components.first, let intValue = Int(firstPart) {
                    durationValue = intValue
                }
            }
        }
        
        // UI tweaks
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y: selectDurationView.bounds.height)
        dropDown.cellHeight = 50
        dropDown.backgroundColor = .white
        dropDown.textColor = .black
    }

    
    @IBAction func breakSwitchAct(_ sender: Any) {
        
        if breakSwitch.isOn {
            breakSlotView.isHidden = false
            BreakDurationDefLbl.isHidden = false
            breakDurationCV.isHidden = false
            let components = breakDuration[SelectedDuration.item].components(separatedBy: " ")
            if let firstPart = components.first, let intValue = Int(firstPart) {
                breakDurationValue = intValue
            }
        }else {
            breakSlotView.isHidden = true
            BreakDurationDefLbl.isHidden = true
            breakDurationCV.isHidden = true
            breakDurationValue = 0
        }
    }
    
    func validateInputs() -> Bool {
        // Trimmed text helpers
        let purpose = purposeTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let meetingLink = meetingLinkTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let fromTime = fromTimeLbl.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let toTime = toTimeLbl.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // 1. Purpose validation
        guard !purpose.isEmpty else {
            CustomAlert.showAlertWithOkAction(
                title: "Missing Information",
                message: "Please enter the purpose of the meeting",
                on: self
            )
            return false
        }
        
        // 2. Meeting mode-specific validations
//        if meetingMode == "Phone Call" {
//            guard !mobile.isEmpty else {
//                CustomAlert.showAlertWithOkAction(
//                    title: "Missing Information",
//                    message: "Please enter the mobile number",
//                    on: self
//                )
//                return false
//            }
//        } else
        
        if meetingMode == "Online" {
            guard !meetingLink.isEmpty else {
                CustomAlert.showAlertWithOkAction(
                    title: "Missing Information",
                    message: "Please enter the meeting link",
                    on: self
                )
                return false
            }
        }
        
        // 3. Time validation
        if fromTime == "Start with" {
            CustomAlert.showAlertWithOkAction(
                title: "Missing Information",
                message: "Please select the start time",
                on: self
            )
            return false
        }
        
        if toTime == "End with" {
            CustomAlert.showAlertWithOkAction(
                title: "Missing Information",
                message: "Please select the end time",
                on: self
            )
            return false
        }
        
        // 4. Classes validation
        guard !selectedClasses.isEmpty else {
            CustomAlert.showAlertWithOkAction(
                title: "Missing Information",
                message: "Please select at least one class",
                on: self
            )
            return false
        }
        
        // 5. Dates validation
        guard !SelectedDates.isEmpty else {
            CustomAlert.showAlertWithOkAction(
                title: "Missing Information",
                message: "Please select the dates for the meeting",
                on: self
            )
            return false
        }
        
        // 6. Duration validation
            var finalValue: Int?
            
            if customDurationView.isHidden {
                // Dropdown duration
                finalValue = durationValue
            } else {
                // Textfield duration
                if let text = durationTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                   let typedValue = Int(text), typedValue > 0 {
                    finalValue = typedValue
                } else {
                    finalValue = nil
                }
            }
            
            guard let duration = finalValue, duration > 0 else {
                CustomAlert.showAlertWithOkAction(
                    title: "Missing Information",
                    message: "Please select or enter a valid duration for the meeting",
                    on: self
                )
                return false
            }
        
        // 7. Time vs Today validation
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            let todayString = formatter.string(from: Date())
            
        if SelectedDates.contains(todayString) {
            // Parse "hh:mm a" formatted times
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm a"
            timeFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let from = timeFormatter.date(from: fromTime) {
                // Build today’s datetime with the selected fromTime
                let calendar = Calendar.current
                let comps = calendar.dateComponents([.hour, .minute], from: from)
                if let fromDateTime = calendar.date(bySettingHour: comps.hour!,
                                                    minute: comps.minute!,
                                                    second: 0,
                                                    of: Date()) {
                    if Date() > fromDateTime {
                        CustomAlert.showAlertWithOkAction(
                            title: "Invalid Time",
                            message: "Start time cannot be in the past for today",
                            on: self
                        )
                        return false
                    }
                }
            }
        }
        // ✅ Passed all validations
        return true
    }

    
    @available(iOS 15.0, *)
    @IBAction func checkSlotAct(_ sender: Any) {
        
//        if purposeTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true{
//            
//            CustomAlert.showAlertWithOkAction(title: "Missing Information", message: "please enter the purpose of meeting", on: self)
//        }
//        
//        if meetingMode == "Phone Call" && mobileTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
//            
//            CustomAlert.showAlertWithOkAction(title: "Missing Information", message: "please enter the mobile number", on: self)
//        }
//        
//        if meetingMode == "Online" && meetingLinkTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
//            
//            CustomAlert.showAlertWithOkAction(title: "Missing Information", message: "please enter the mobile number", on: self)
//        }
//        
//        if selectedClasses.isEmpty {
//            CustomAlert.showAlertWithOkAction(title: "Missing Information", message: "Plese Select the class", on: self)
//        }
//        
//        if SelectedDates.isEmpty {
//            CustomAlert.showAlertWithOkAction(title: "Missing Information", message: "Plese Select the Dates for the meeting", on: self)
//        }
        if validateInputs(){
            Check_Slots_Api_call()
        }
    }

    func generateSlots(
        from startTime: String,
        to endTime: String,
        slotDuration: Int,
        breakDuration: Int = 0,
        breakAfterSlots: Int = 1
    ) -> [[String: String]] {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let start = formatter.date(from: startTime),
              let end = formatter.date(from: endTime) else {
            return []
        }
        
        var slots: [[String: String]] = []
        var currentStart = start
        var slotCount = 0
        
        while true {
            let currentEnd = currentStart.addingTimeInterval(TimeInterval(slotDuration * 60))
            
            // Stop if next slot exceeds end time (skip partial slot)
            if currentEnd > end { break }
            
            slots.append([
                "from_time": formatter.string(from: currentStart).lowercased(),
                "to_time": formatter.string(from: currentEnd).lowercased()
            ])
            
            slotCount += 1
            currentStart = currentEnd
            
            // Add break if needed
            if breakDuration > 0 && breakAfterSlots > 0 && slotCount % breakAfterSlots == 0 {
                currentStart = currentStart.addingTimeInterval(TimeInterval(breakDuration * 60))
            }
        }
        
        return slots
    }
    
    func Get_Standards_Api(){
        
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: [COMMON_PARAMETER.academic_year_id:academicId ?? 0], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [weak self] (result: Result<GetStandardsSuc , Error>) in
            
            DispatchQueue.main.sync { [weak self] in
                
                guard let self = self else {return}
                
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        
                        classList.removeAll()
                        selectedClasses.removeAll()
                        let standardData =  success.data ?? []
                        
                        for standard in standardData{
                            for section in standard.sections ?? [] {
        
                                let displayName = "\(standard.name ?? "") - \(section.name ?? "")"
                                classList.append(ClassDisplayItem(displayName: displayName, standardId: standard.id ?? "", sectionId: section.id ?? ""))
                            }
                        }
                        
                        classCv.reloadData()
                        classCv.layoutIfNeeded()
                        classCVHeight.constant =
                        classCv.collectionViewLayout.collectionViewContentSize.height
                        view.layoutIfNeeded()
                        
                    }else {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self) {
                            self.dismiss(animated: true)
                        }
                    }
                    
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self) {
                        self.dismiss(animated: true)
                    }
                }
            }
            
        }
    }
    
    func Check_Slots_Api_call(){
        
        var finalValue: Int?

           if customDurationView.isHidden {
               finalValue = durationValue // from preset selection
           } else {
               finalValue = Int(durationTextfield.text ?? "")
           }
        
        let slots = generateSlots(from: fromTimeLbl.text ?? "", to: toTimeLbl.text ?? "", slotDuration: finalValue ?? 0,breakDuration: breakDurationValue,breakAfterSlots: stepper.value)

        let param: [String: Any] = [
            PTMRequestStringFile.event_name: purposeTextfield.text ?? "",
            PTMRequestStringFile.from_time: fromTimeLbl.text ?? "",
            PTMRequestStringFile.to_time: toTimeLbl.text ?? "",
            PTMRequestStringFile.duration: finalValue ?? "",
            PTMRequestStringFile.event_link: meetingLinkTextfield.text ?? "",
            PTMRequestStringFile.break_time: breakDurationValue,
            PTMRequestStringFile.meeting_mode: meetingMode,
            PTMRequestStringFile.std_sec_details:selectedClasses,
            PTMRequestStringFile.slots: slots
        ]

        let finalParams: [[String: Any]] = SelectedDates.map { date in
            var allParam = param
            allParam[PTMRequestStringFile.date] = date
            return allParam
        }
        
        APIService.shared.PtmApi(url: ServiceUrl.ptm_api_ptm_schedule_validate_slots_for_staff, parameters: finalParams, token: staffDetails?.access_token ?? "") { [weak self] (result: Result<SlotValidationResponse,Error>) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else {return}
                
                switch result {
                case .success(let success):
                    
                    self.validatedData = success.data ?? []
                    
                    let bottomSheetVC = CreateSlotsBottomVC()
                    
                    if #available(iOS 15.0, *) {
                        if let sheet = bottomSheetVC.sheetPresentationController{
                            if #available(iOS 16.0, *) {
                                sheet.detents = [.custom(resolver: { _ in 800 })]
                            } else {
                                sheet.detents = [.large()]
                            } // Height options
                            sheet.prefersGrabberVisible = true    // Shows the little grab bar
                            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                    
                    if validatedData.first?.slots?.isEmpty == true {
                        
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: "No available sots Found in the selected date and time", on: self)
                        
                    }else{
                        bottomSheetVC.slotData = validatedData
                        present(bottomSheetVC, animated: true)
                    }
                    
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: "Error", message: "Something went Wrong", on: self)
                    print("Error: ",failure.localizedDescription)
                }
            }
        }
    }
    
}

@available(iOS 14.0, *)
extension CreateMeetingVc: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case classCv:
            return classList.count
        case selectedDatesCv:
            return SelectedDates.count
        default:
            return  4
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == classCv {
            let cell = classCv.dequeueReusableCell(withReuseIdentifier: "SlotCV", for: indexPath) as! SlotCV
            
            let classItem = classList[indexPath.item]
            
            cell.closeBtn.isHidden = true
            cell.label.textAlignment = .center
            cell.label.text = classItem.displayName
            
           
            let isSelected = selectedClasses.contains {
                $0["class_id"] == classItem.standardId &&
                $0["section_id"] == classItem.sectionId
            }
            
            // ✅ Update UI here
            cell.cellView.backgroundColor = isSelected ? .systemBlue : .systemGray4
            cell.label.textColor = isSelected ? .white : .black
            
            return cell
            
        } else if collectionView == breakDurationCV {
            let cell = breakDurationCV.dequeueReusableCell(withReuseIdentifier: "SlotCV", for: indexPath) as! SlotCV
            cell.closeBtn.isHidden = true
            cell.label.textAlignment = .center
            cell.label.text = breakDuration[indexPath.item]
            cell.cellView.backgroundColor = (SelectedDuration == indexPath) ? .systemGreen : .systemGray4
            cell.label.textColor = (SelectedDuration == indexPath) ? .white : .black
            return cell
            
        } else if collectionView == selectedDatesCv {
            let cell = selectedDatesCv.dequeueReusableCell(withReuseIdentifier: CellConfingName.DateCVC, for: indexPath) as! DateCVC
            cell.dateLbl.text = SelectedDates[indexPath.item].convertToTargetDateFormat()
            cell.dateLbl.setFont(style: .body, size: FontSize.BodySize)
            cell.dateDelet.tag = indexPath.item
            cell.delegate = self
            return cell
        }
        
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == classCv {
                let classItem = classList[indexPath.row]
                let detail: [String: String] = [
                    "class_id": classItem.standardId,
                    "section_id": classItem.sectionId
                ]
                
                // Toggle selection
                if let index = selectedClasses.firstIndex(where: { $0["class_id"] == detail["class_id"] && $0["section_id"] == detail["section_id"] }) {
                    selectedClasses.remove(at: index)
                } else {
                    selectedClasses.append(detail)
                }
                
                // ✅ Refresh just that cell
                collectionView.reloadItems(at: [indexPath])
            
            } else if collectionView == breakDurationCV {
                
            if SelectedDuration == indexPath { return }
            SelectedDuration = indexPath
            let components = breakDuration[indexPath.item].components(separatedBy: " ")
            if let firstPart = components.first, let intValue = Int(firstPart) {
                breakDurationValue = intValue
            }
            collectionView.reloadData()
        }
    }

//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        if collectionView == classCv {
//                let classItem = classList[indexPath.row]
//                
//                selectedClasses.removeAll {
//                    $0["class_id"] == classItem.standardId && $0["section_id"] == classItem.sectionId
//                }
//                
//                if let cell = collectionView.cellForItem(at: indexPath) as? SlotCV {
//                    cell.cellView.backgroundColor = .systemGray4
//                    cell.label.textColor = .black
//                }
//            }
//    }

    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == selectedDatesCv {
            
            let columns: CGFloat = 3
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            
            let totalSpacing = (columns - 1) * layout.minimumInteritemSpacing
            + layout.sectionInset.left
            + layout.sectionInset.right
            
            let availableWidth = collectionView.bounds.width - totalSpacing
            let width = floor(availableWidth / columns)
            
            return CGSize(width: width, height: 50)
            
        }
        
        else {
            let text: String
            if collectionView == classCv {
                text = classList[indexPath.item].displayName
            } else if collectionView == breakDurationCV {
                text = breakDuration[indexPath.item]
            } else {
                text = SelectedDates[indexPath.item]
            }
            
            let size = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 16)])
            return CGSize(width: size.width + 20, height: size.height + 16) // padding
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero // vertical spacing between rows (try 0–4)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero // horizontal spacing between items (try 0–4)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero // remove extra padding around the section
    }
    
}

// MARK: - Keyboard handling
@available(iOS 14.0, *)
extension CreateMeetingVc: UITextFieldDelegate{

    func textFieldDidBeginEditing(_ textField: UITextField) {
            activeTextField = textField
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            if activeTextField == textField {
                activeTextField = nil
            }
        }
    
    
        @objc func keyboardWillShow(notification: NSNotification) {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardHeight = keyboardFrame.height

                var contentInset = scrollView.contentInset
                contentInset.bottom = keyboardHeight + 20
                scrollView.contentInset = contentInset
                scrollView.scrollIndicatorInsets = contentInset

                // ✅ Scroll active text field into view
                if let activeTextField = activeTextField {
                    let visibleRect = view.frame.inset(by: UIEdgeInsets(top: 0,
                                                                        left: 0,
                                                                        bottom: keyboardHeight,
                                                                        right: 0))
                    if !visibleRect.contains(activeTextField.frame.origin) {
                        scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
                    }
                }
            }
        }

        @objc func keyboardWillHide(notification: NSNotification) {
            var contentInset = scrollView.contentInset
            contentInset.bottom = 0
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
        }
}


extension UIView {
    func applyCardStyle(
        cornerRadius: CGFloat = 10,
        shadowColor: UIColor = .black,
        shadowOpacity: Float = 0.1,
        shadowOffset: CGSize = CGSize(width: 0, height: 2),
        shadowRadius: CGFloat = 4,
        backgroundColor: UIColor = .white
    ) {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = false
        self.backgroundColor = backgroundColor
    }
}


import UIKit

class LabeledStepper: UIControl {

    private let decreaseButton = UIButton(type: .system)
    private let increaseButton = UIButton(type: .system)
    private let countLabel = UILabel()

    var minimumValue: Int = 1
    var value: Int = 1 {
        didSet {
            countLabel.text = "\(value)"
            updateButtonStates()
            sendActions(for: .valueChanged)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // Style container
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 10
        layer.masksToBounds = true

        // Configure buttons
        decreaseButton.setTitle("–", for: .normal)
        increaseButton.setTitle("+", for: .normal)
        decreaseButton.titleLabel?.font = .boldSystemFont(ofSize: 20)
        increaseButton.titleLabel?.font = .boldSystemFont(ofSize: 20)

        // Configure label
        countLabel.text = "\(value)"
        countLabel.textAlignment = .center
        countLabel.font = .systemFont(ofSize: 16, weight: .medium)

        // Add subviews
        addSubview(decreaseButton)
        addSubview(countLabel)
        addSubview(increaseButton)

        // Actions
        decreaseButton.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        increaseButton.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)

        updateButtonStates()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let buttonWidth: CGFloat = 40
        let labelWidth = bounds.width - (buttonWidth * 2)

        decreaseButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: bounds.height)
        countLabel.frame = CGRect(x: buttonWidth, y: 0, width: labelWidth, height: bounds.height)
        increaseButton.frame = CGRect(x: buttonWidth + labelWidth, y: 0, width: buttonWidth, height: bounds.height)
    }

    @objc private func decreaseTapped() {
        if value > minimumValue {
            value -= 1
        }
    }

    @objc private func increaseTapped() {
        value += 1   // ✅ no maximum limit
    }

    private func updateButtonStates() {
        // Disable – only at minimum
        decreaseButton.isEnabled = value > minimumValue
        decreaseButton.alpha = decreaseButton.isEnabled ? 1.0 : 0.5
    }
}

import UIKit

class PasteOnlyTextField: UITextField {

    override var inputView: UIView? {
        get { return UIView() } // disable keyboard
        set { }
    }

    override func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
        return false // block typing
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.paste(_:))
    }

    override func paste(_ sender: Any?) {
        guard var pasted = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines),
              !pasted.isEmpty else { return }

        // Auto-add https:// if missing
        if !pasted.lowercased().hasPrefix("http") {
            pasted = "https://" + pasted
        }

        // Validate URL
        if let url = URL(string: pasted),
           let host = url.host,
           host.contains("."),
           !isPrivateIP(host) {

            super.text = pasted
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            super.text = ""
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            print("❌ Rejected non-public URL: \(pasted)")
        }
    }

    // Detect private IPs
    private func isPrivateIP(_ host: String) -> Bool {
        // Check if host is IPv4
        let parts = host.split(separator: ".").compactMap { UInt8($0) }
        if parts.count == 4 {
            let first = parts[0]
            let second = parts[1]
            // 10.0.0.0/8
            if first == 10 { return true }
            // 172.16.0.0/12
            if first == 172 && second >= 16 && second <= 31 { return true }
            // 192.168.0.0/16
            if first == 192 && second == 168 { return true }
            // 127.x.x.x loopback
            if first == 127 { return true }
        }
        return false
    }
}
