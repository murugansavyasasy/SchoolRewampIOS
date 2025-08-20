//
//  CreateMeetingVc.swift
//  School Chimes
//
//  Created by Lakshmanan on 14/08/25.
//

import UIKit
import FSCalendar
import DropDown

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
    @IBOutlet weak var meetingLinkTextfield: UITextField!
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
    @IBOutlet weak var stepper: UIStepper!
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
    
    var breakDuration = ["5 Min", "10 Min", "15 Min", "30 Min"]
    var SelectedClasses = Set<IndexPath>()
    var SelectedDuration: IndexPath?
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
    var selectedClasses: [StdSecDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.layer.cornerRadius = 20
        topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        backBtn.configureAsBackButton(firstLine: "PTM", secondLine: "savyasasy School", colour: .white)
        
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
        
        firstView.layer.cornerRadius = 10
        firstView.layer.shadowColor = UIColor.black.cgColor
        firstView.layer.shadowOpacity = 0.1   // very light shadow
        firstView.layer.shadowOffset = CGSize(width: 0, height: 2) // subtle vertical shadow
        firstView.layer.shadowRadius = 4      // soft blur
        firstView.layer.masksToBounds = false // important: let shadow show outside bounds
        
        SelectClassBaseView.layer.cornerRadius = 10
        SelectClassBaseView.layer.shadowColor = UIColor.black.cgColor
        SelectClassBaseView.layer.shadowOpacity = 0.1   // very light shadow
        SelectClassBaseView.layer.shadowOffset = CGSize(width: 0, height: 2) // subtle vertical shadow
        SelectClassBaseView.layer.shadowRadius = 4      // soft blur
        SelectClassBaseView.layer.masksToBounds = false // important: let shadow show outside bounds
        
        selectDateTimeBaseView.layer.cornerRadius = 10
        selectDateTimeBaseView.layer.shadowColor = UIColor.black.cgColor
        selectDateTimeBaseView.layer.shadowOpacity = 0.1   // very light shadow
        selectDateTimeBaseView.layer.shadowOffset = CGSize(width: 0, height: 2) // subtle vertical shadow
        selectDateTimeBaseView.layer.shadowRadius = 4      // soft blur
        selectDateTimeBaseView.layer.masksToBounds = false // important: let shadow show outside bounds
        
        DurationBaseView.layer.cornerRadius = 10
        DurationBaseView.layer.shadowColor = UIColor.black.cgColor
        DurationBaseView.layer.shadowOpacity = 0.1   // very light shadow
        DurationBaseView.layer.shadowOffset = CGSize(width: 0, height: 2) // subtle vertical shadow
        DurationBaseView.layer.shadowRadius = 4      // soft blur
        DurationBaseView.layer.masksToBounds = false // important: let shadow show outside bounds
        
        customDurationView.isHidden = true
        
        breakSlotView.isHidden = true
        BreakDurationDefLbl.isHidden = true
        breakDurationCV.isHidden = true
        
        inpersonBtn.layer.cornerRadius = 10
        phonecallBtn.layer.cornerRadius = 10
        onlineBtn.layer.cornerRadius = 10
        
        mobileStack.isHidden = true
        linkStack.isHidden = true
        
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
        
        academicYearView.layer.cornerRadius = 10
        academicYearView.layer.shadowColor = UIColor.black.cgColor
        academicYearView.layer.shadowOpacity = 0.4
        academicYearView.layer.shadowOffset = CGSize(width: 2, height: 2)
        academicYearView.layer.shadowRadius = 4
        academicYearView.layer.masksToBounds = false
        
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
        
        calendarBaseview.layer.shadowColor = UIColor.black.cgColor   // shadow color
        calendarBaseview.layer.shadowOpacity = 0.2                   // transparency (0 = invisible, 1 = solid)
        calendarBaseview.layer.shadowOffset = CGSize(width: 0, height: 4) // shadow position
        calendarBaseview.layer.shadowRadius = 6                      // blur radius
        calendarBaseview.layer.masksToBounds = false                 // must be false for shadow to show
        calendarBaseview.layer.cornerRadius = 12                     // optional rounded corners
        
        calendarDoneBtn.layer.cornerRadius = 10
        calendarDoneBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        calendarMonthLbl.setFont(style: .title, size: FontSize.TitleSize)
        
        CheckSlotBtn.layer.cornerRadius = 12
        CheckSlotBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        //breakDurationCV.allowsMultipleSelection = false
        classCv.allowsMultipleSelection = true
        
        DatesCvHeight.constant = 0
        
        if let layout = selectedDatesCv.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            layout.sectionInset = .zero
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
    }
    
    func getAcadmicYear() {
        academicYears = localData.accidamic_year_data?.data?.compactMap { $0.year } ?? []
        academicYearDataList = localData.accidamic_year_data?.data ?? []
        academicYearLabel.text = academicYears.last ?? ""
        academicId = localData.accidamic_year_data?.data?.last?.id ?? 0
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        classCv.layoutIfNeeded()
//        classCVHeight.constant = classCv.contentSize.height
//    }
    
    
    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    
    @IBAction func inpersonAct(_ sender: Any) {
        
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
        
        phonecallBtn.backgroundColor = .systemBlue
        phonecallBtn.setTitleColor(.white, for: .normal)
        
        inpersonBtn.backgroundColor = .systemGray5
        inpersonBtn.setTitleColor(.black, for: .normal)
        onlineBtn.backgroundColor = .systemGray5
        onlineBtn.setTitleColor(.black, for: .normal)
        
        mobileStack.isHidden = false
        linkStack.isHidden = true
    }
    
    @IBAction func OnlineAct(_ sender: Any) {
        
        onlineBtn.backgroundColor = .systemBlue
        onlineBtn.setTitleColor(.white, for: .normal)
        
        inpersonBtn.backgroundColor = .systemGray5
        inpersonBtn.setTitleColor(.black, for: .normal)
        phonecallBtn.backgroundColor = .systemGray5
        phonecallBtn.setTitleColor(.black, for: .normal)
        
        mobileStack.isHidden = true
        linkStack.isHidden = false
    }
    
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
            
            doneButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            doneButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
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
        formatter.timeStyle = .short
        
        if sender.tag == 1, let picker = fromTimePicker {
            print("From Time: \(formatter.string(from: picker.date))")
            fromTimePickerContainer?.removeFromSuperview()
        } else if sender.tag == 2, let picker = toTimePicker {
            print("To Time: \(formatter.string(from: picker.date))")
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
    
    
    
    func date(date: String) {
        
        dateLbl.text = date
    }
    @IBAction func DateDoneAct(_ sender: Any) {
        
        let selectedDates = calendar.selectedDates
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateStrings = selectedDates.map { formatter.string(from: $0)}
        self.SelectedDates = dateStrings
        DatesCvHeight.constant = SelectedDates.count == 0 ? 0 : 50
        selectedDatesCv.reloadData()
        hideCalendar()
    }
    
    func reload(index: Int) {
    }
    
    func deleteDelegate(index: Int) {
        
        SelectedDates.remove(at: index)
        DatesCvHeight.constant = SelectedDates.count == 0 ? 0 : 50
        selectedDatesCv.reloadData()
    }
    
    @IBAction func selectDuration(){
        
        dropDown.show()
    }
    
    private func setupDropDown() {
        dropDown.anchorView = selectDurationView       // The view dropdown will appear from
        dropDown.dataSource = ["10 Minutes", "15 Minutes", "20 Minutes", "30 Minutes","Custom"]
        
        // Dropdown selection action
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            durationLbl.text = item
            if index == dropDown.dataSource.count - 1{
                customDurationView.isHidden = false
            }else {
                customDurationView.isHidden = true
                durationTextfield.text = ""
            }
        }
        
        // Optional customizations
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
        }else {
            breakSlotView.isHidden = true
            BreakDurationDefLbl.isHidden = true
            breakDurationCV.isHidden = true
        }
    }
    
    
    @available(iOS 15.0, *)
    @IBAction func checkSlotAct(_ sender: Any) {
        
        let bottomSheetVC = CreateSlotsBottomVC()
        
        if let sheet = bottomSheetVC.sheetPresentationController{
            sheet.detents = [.large(), .large()] // Height options
            sheet.prefersGrabberVisible = true    // Shows the little grab bar
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        }
        present(bottomSheetVC, animated: true)
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
                        classCVHeight.constant = classCv.collectionViewLayout.collectionViewContentSize.height
                        view.layoutIfNeeded()
                        
                    }else {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self) {
                            
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

        let param: [String: Any] = [
            PTMRequestStringFile.event_name: "test",
            PTMRequestStringFile.from_time: "3:23 am",
            PTMRequestStringFile.to_time: "6:23 am",
            PTMRequestStringFile.duration: 10,
            PTMRequestStringFile.event_link: "",
            PTMRequestStringFile.break_time: 5,
            PTMRequestStringFile.meeting_mode: "In Person",
            PTMRequestStringFile.std_sec_details: [
                [
                    PTMRequestStringFile.section_id: "90813",
                    PTMRequestStringFile.class_id: "32582"
                ]
            ],
            PTMRequestStringFile.slots: [
                [
                    PTMRequestStringFile.from_time: "03:43 am",
                    PTMRequestStringFile.to_time: "03:53 am"
                ]
            ]
        ]

        let finalParams: [[String: Any]] = SelectedDates.map { date in
            var allParam = param
            allParam[PTMRequestStringFile.date] = date
            return allParam
        }

        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_validate_slots_for_staff, parameters: [:], type: ApitTypeSringFile.POST, token: staffDetails?.access_token ??  "") { [weak self] (result: Result<SlotValidationResponse,Error>) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else {return}
                
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        
                        
                    }else {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
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
            cell.closeBtn.isHidden = true
            cell.label.textAlignment = .center
            cell.label.text = classList[indexPath.item].displayName
            
            let classItem = classList[indexPath.row]
            let detail = StdSecDetail(class_id: classItem.standardId, section_id: classItem.sectionId)
            
            // ✅ Highlight if this class is in selectedClasses
            if selectedClasses.contains(where: { $0.class_id == detail.class_id && $0.section_id == detail.section_id }) {
                cell.cellView.backgroundColor = .systemBlue
                cell.label.textColor = .white
            } else {
                cell.cellView.backgroundColor = .systemGray4
                cell.label.textColor = .black
            }
            
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
            cell.dateDelet.tag = indexPath.item
            cell.delegate = self
            return cell
        }
        
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == classCv {
            let classItem = classList[indexPath.row]
                    let detail = StdSecDetail(class_id: classItem.standardId, section_id: classItem.sectionId)
                    
                    if !selectedClasses.contains(where: { $0.section_id == detail.section_id && $0.class_id == detail.class_id }) {
                        selectedClasses.append(detail)
                    }
                    
                    if let cell = collectionView.cellForItem(at: indexPath) as? SlotCV {
                        cell.cellView.backgroundColor = .systemBlue
                        cell.label.textColor = .white
                    }
            
        } else if collectionView == breakDurationCV {
            if SelectedDuration == indexPath { return }
            SelectedDuration = indexPath
            collectionView.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == classCv {
            let classItem = classList[indexPath.row]
            selectedClasses.removeAll { $0.section_id == classItem.sectionId && $0.class_id == classItem.standardId }
            
            if let cell = collectionView.cellForItem(at: indexPath) as? SlotCV {
                cell.cellView.backgroundColor = .systemGray4
                cell.label.textColor = .black
            }
        }
    }

    
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
        return 8 // vertical spacing between rows (try 0–4)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8 // horizontal spacing between items (try 0–4)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero // remove extra padding around the section
    }
    
}
