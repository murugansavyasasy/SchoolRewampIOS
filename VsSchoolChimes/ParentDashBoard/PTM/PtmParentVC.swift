//
//  PtmParentVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 28/08/25.
//

import UIKit
import DropDown

class PtmParentVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var scheduleMeetingBtn: UIButton!
    @IBOutlet weak var yourMeetingBtn: UIButton!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var CV: UICollectionView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var BookSlotBtn: UIButton!
    @IBOutlet weak var subjectsView: UIView!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var noDataImage: UIImageView!
    @IBOutlet weak var NodataLbl: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var dateComponents: [(month: String, day: String, date: Date, count: String?)] = []
    var selectedIndex: IndexPath?
    var childDetails = UserDefaultFileManager.get_child_Details()
    var subjectList : [Subject] = []
    var events : [EventData] = []
    var selectedSlots: [StudentSlot] = []     // only user-selected (not API my_booking)
    var EventDate = ""
    var subjectId = "0"
    var classteacherId = "0"
    let alert = CustomAlert()
    let dropDown = DropDown()
    var childVc : PtmHistoryVC?
    var availableSlots : [AvailableSlot] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        generateDates()
        getsubjects()
        Get_Available_slot_count()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    
    func updateTableHeight() {
        tv.layoutIfNeeded()
        tableViewHeight.constant = tv.contentSize.height
    }
    
    private func setupUI() {
        topView.layer.cornerRadius = 20
        topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        let name = childDetails?.name ?? ""
        let standard = (childDetails?.standard_name ?? "") + " - " + (childDetails?.section_name ?? "")
        backBtn.configureAsBackButton(firstLine: name, secondLine: standard)
        
        scheduleMeetingBtn.setTitle(PTMString.scheduleMeeting, for: .normal)
        yourMeetingBtn.setTitle(PTMString.yourMeetings, for: .normal)
        BookSlotBtn.setTitle(PTMString.bookSlot, for: .normal)
        
        subjectLbl.text = PTMString.allSubjects
        
        scheduleMeetingBtn.setTitleFont(style: .body, size: FontSize.HeaderSize)
        yourMeetingBtn.setTitleFont(style: .body, size: FontSize.HeaderSize)
        
        scheduleMeetingBtn.layer.cornerRadius = 12
        scheduleMeetingBtn.backgroundColor = .white
        yourMeetingBtn.layer.cornerRadius = 12
        
        noDataImage.isHidden = true
        NodataLbl.isHidden = true
        NodataLbl.setFont(style: .body, size: FontSize.TitleSize)
        searchBtn.isHidden = true
        
        CV.layer.cornerRadius = 12
        CV.backgroundColor = .clear
        CV.register(UINib(nibName: "DateCvCell", bundle: nil), forCellWithReuseIdentifier: "DateCvCell")
        CV.delegate = self
        CV.dataSource = self
        
        subjectsView.layer.cornerRadius = 15
        subjectsView.layer.borderWidth = 0.5
        subjectsView.layer.borderColor = UIColor.systemGray4.cgColor
        subjectsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectSubjectAct)))
        
        BookSlotBtn.layer.cornerRadius = 12
        
        tv.register(UINib(nibName: "parentPTMcell", bundle: nil), forCellReuseIdentifier: "parentPTMcell")
        tv.delegate = self
        tv.dataSource = self
    }
    
    // MARK: - Date Generation
    private func generateDates() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        EventDate = formatter.string(from: Date())
        
        let monthFormatter = DateFormatter(); monthFormatter.dateFormat = "MMM"
        let dayFormatter = DateFormatter(); dayFormatter.dateFormat = "dd"
        let today = Calendar.current.startOfDay(for: Date())
        
        for i in 0..<60 {
            if let nextDate = Calendar.current.date(byAdding: .day, value: i, to: today) {
                dateComponents.append((month: monthFormatter.string(from: nextDate),
                                       day: dayFormatter.string(from: nextDate),
                                       date: nextDate,
                                       count: nil))
                if Calendar.current.isDate(nextDate, inSameDayAs: today) {
                    selectedIndex = IndexPath(item: i, section: 0)
                }
            }
        }
    }
    
    // MARK: - DropDown
    private func setupDropDown() {
        dropDown.anchorView = subjectsView
        dropDown.dataSource = [PTMString.allSubjects] + subjectList.compactMap { $0.name }
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            subjectLbl.text = item
            
            switch index {
            case 0:
                self.subjectId = "0"; self.classteacherId = "0"
            case 1:
                self.subjectId = "0"; self.classteacherId = self.subjectList[index - 1].id ?? ""
            default:
                self.classteacherId = "0"; self.subjectId = self.subjectList[index - 1].id ?? ""
            }
            self.getSlotsApi()
        }
        
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y: subjectsView.bounds.height)
        dropDown.cellHeight = 50
        dropDown.backgroundColor = .white
        dropDown.textColor = .black
    }
    
    // MARK: - APIs
    func getsubjects(){
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_subject_list_with_class_teacher,
                                  parameters: [:],
                                  type: ApitTypeSringFile.GET,
                                  token: childDetails?.access_token ?? "") { [weak self] (result: Result<SubjectListResponse,Error>) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success.status == true {
                        self.subjectList = success.data ?? []
                        self.setupDropDown()
                        self.getSlotsApi()
                    }
                case .failure:
                    print("Error")
                }
            }
        }
    }
    
    func getSlotsApi(){
        let param : [String:Any] = [
            PTMRequestStringFile.event_date:EventDate,
            PTMRequestStringFile.subject_id:subjectId,
            PTMRequestStringFile.class_teacher_id: classteacherId
        ]
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_teacherwise_slots_availability_for_student,
                                  parameters: param,
                                  type: ApitTypeSringFile.GET,
                                  token: childDetails?.access_token ?? "") { [weak self] (result: Result<StudentSlotResponse,Error>) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success.status == true {
                        self.selectedSlots.removeAll()
                        self.events = (success.data ?? []).map { ev in
                            var copy = ev
                            copy.slots = ev.slots?.map { s in
                                var x = s
                                x.userSelected = false
                                x.is_conflictDisabled = false
                                return x
                            }
                            return copy
                        }
                        self.recomputeConflicts() // lock rows with my_booking
                        self.tv.isHidden = false
                        self.noDataImage.isHidden = true
                        self.NodataLbl.isHidden = true
                        self.BookSlotBtn.isHidden = false
                        self.tv.reloadData()
                        DispatchQueue.main.async {
                            self.updateTableHeight()
                        }
                    } else {
                        self.NodataLbl.text = success.message
                        self.tv.isHidden = true
                        self.noDataImage.isHidden = false
                        self.NodataLbl.isHidden = false
                        self.BookSlotBtn.isHidden = true
                    }
                case .failure(let failure):
                    print("Error:", failure.localizedDescription)
                    self.NodataLbl.text = failure.localizedDescription
                    self.tv.isHidden = true
                    self.tableViewHeight.constant = 0
                    self.noDataImage.isHidden = false
                    self.NodataLbl.isHidden = false
                    self.BookSlotBtn.isHidden = true
                }
            }
        }
    }
    
    func Book_Slots_Api(){
        let slots : [String] = selectedSlots.compactMap { $0.id }
        let param : [String:Any] = [PTMRequestStringFile.slot_ids: slots]
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_book_slots_for_student,
                                  parameters: param,
                                  type: ApitTypeSringFile.PUT,
                                  token: childDetails?.access_token ?? "") { [weak self] (result:Result<CommonApiSuc,Error>) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success.status == true {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success,
                                                          message: success.message ?? "",
                                                          on: self) {
                            self.getSlotsApi()
                        }
                    } else {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed,
                                                          message: success.message ?? "",
                                                          on: self)
                    }
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed,
                                                      message: failure.localizedDescription,
                                                      on: self)
                }
            }
        }
    }
    
    func Get_Available_slot_count(){
        APIService.shared.makeApi(url:ServiceUrl.ptm_api_ptm_schedule_available_slots_count_for_student,
                                  parameters: [:],
                                  type: ApitTypeSringFile.GET,
                                  token: childDetails?.access_token ?? "") { [weak self] (result:Result<AvailableSlotsResponse , Error>) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self.availableSlots = success.data ?? []
                    
                    
                    // Map counts into dateComponents
                    let formatter = DateFormatter(); formatter.dateFormat = "dd-MM-yyyy"
                    for i in 0..<self.dateComponents.count {
                        let compDate = self.dateComponents[i].date
                        let compDateStr = formatter.string(from: compDate)
                        if let match = self.availableSlots.first(where: { $0.event_date == compDateStr }) {
                            self.dateComponents[i].count = match.count
                        } else {
                            self.dateComponents[i].count = nil
                        }
                    }
                    self.CV.reloadData()
                    
                    
                case .failure(let failure):
                    print("Error: ", failure.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Time helpers
    private lazy var timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "hh:mm a"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.amSymbol = "AM"; f.pmSymbol = "PM"
        return f
    }()
    private func timeStringToDate(_ time: String?) -> Date? {
        guard let t = time, !t.isEmpty else { return nil }
        return timeFormatter.date(from: t)
    }
    private func isOverlapping(slot1: StudentSlot, slot2: StudentSlot) -> Bool {
        guard let s1 = timeStringToDate(slot1.slot_from),
              let e1 = timeStringToDate(slot1.slot_to),
              let s2 = timeStringToDate(slot2.slot_from),
              let e2 = timeStringToDate(slot2.slot_to) else { return false }
        return max(s1, s2) < min(e1, e2)
    }
    
    // MARK: - Conflict recomputation (locks my_booking rows; ignores them in cross-row conflicts)
    private func recomputeConflicts() {
        struct Selection { let slot: StudentSlot; let eventIndex: Int }
        var blockingSelections: [Selection] = []

        // Collect blocking slots = user selections + my_booking slots
        for (eIdx, ev) in events.enumerated() {
            guard let slots = ev.slots else { continue }
            for sl in slots {
                if (sl.userSelected ?? false) || (sl.my_booking ?? false) {
                    blockingSelections.append(.init(slot: sl, eventIndex: eIdx))
                }
            }
        }

        for e in 0..<events.count {
            guard var slots = events[e].slots else { continue }
            let rowHasMyBooking = slots.contains { $0.my_booking ?? false }

            for s in 0..<slots.count {
                var slot = slots[s]

                if rowHasMyBooking {
                    // Row has a booked slot → only keep that booked slot enabled
                    slot.is_conflictDisabled = false//!(slot.my_booking ?? false)
                } else if slot.is_booked ?? false {
                    // Already booked by someone else
                    slot.is_conflictDisabled = false
                } else {
                    // Normal row → check conflicts with other rows
                    let hasConflict = blockingSelections.contains { sel in
                        sel.eventIndex != e && isOverlapping(slot1: sel.slot, slot2: slot)
                    }
                    slot.is_conflictDisabled = hasConflict
                }

                slots[s] = slot
            }
            events[e].slots = slots
        }
    }



    
    private func updateSelectedSlots() {
        selectedSlots.removeAll()
        for event in events {
            if let slots = event.slots {
                selectedSlots.append(contentsOf: slots.filter { $0.userSelected ?? false })
            }
        }
    }

    
    private func handleSlotSelection(eventIndex: Int, slotIndex: Int) {
        var event = events[eventIndex]
        guard var slots = event.slots else { return }
        var tapped = slots[slotIndex]

        // Toggle selection
        if tapped.userSelected ?? false {
            tapped.userSelected = false
            slots[slotIndex] = tapped
            events[eventIndex].slots = slots
            updateSelectedSlots()      // ✅ keep array updated
            recomputeConflicts()
            tv.reloadData()
            return
        }

        // Only one slot can be selected in this event
        for i in 0..<slots.count {
            slots[i].userSelected = (i == slotIndex)
        }
        events[eventIndex].slots = slots

        updateSelectedSlots()          // ✅ keep array updated
        recomputeConflicts()
        tv.reloadData()
    }


    
    // MARK: - Actions
    @IBAction func selectSubjectAct(){
        dropDown.show()
    }
    
    @IBAction func BookSlotsAct(_ sender: Any) {
        if selectedSlots.isEmpty {
            CustomAlert.showAlertWithOkAction(title: "Missing Information",
                                              message: "Please select at least one slot to continue",
                                              on: self)
        } else {
            alert.showAlertCancel(title: AlertstringFile.Confirm,
                                  message: "Are you sure you want to book selected slots?",
                                  actionLbl1: AlertstringFile.OK,
                                  actionLbl2: AlertstringFile.Cancel,
                                  on: self) {
                self.Book_Slots_Api()
            } onNo: { }
        }
    }
    
   
    @IBAction func scheduleMeetingAct(_ sender: Any) {
        scheduleMeetingBtn.backgroundColor = .white
        yourMeetingBtn.backgroundColor = .clear
        removeChildVc()
        getSlotsApi()
    }
    @IBAction func yourMeetingAct(_ sender: Any) {
        scheduleMeetingBtn.backgroundColor = .clear
        yourMeetingBtn.backgroundColor = .white
        addChildVc()
    }
    @IBAction func backAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func searchBtnAct(_ sender: Any) {
        
        if let Child = childVc{
            Child.searchBar.isHidden.toggle()
        }
    }
    
    
    // MARK: - Child VC
    func addChildVc(){
        removeChildVc()
        searchBtn.isHidden = false
        let vc = PtmHistoryVC(nibName: nil, bundle: nil)
        addChild(vc)
        vc.view.frame = containerView.bounds
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
        self.childVc = vc
    }
    func removeChildVc(){
        guard let vc = childVc else { return }
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
        childVc = nil
        searchBtn.isHidden = true
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "parentPTMcell",
                                          for: indexPath) as! parentPTMcell
        let event = events[indexPath.row]
        cell.configure(with: event.slots ?? [], parentTableView: tv)
        cell.TitleLbl.text = event.event_name
        cell.StaffNameLbl.text = event.staff_name
        cell.subjectLbl.text = event.subject_name
        cell.MeetingTypeBtn.setTitle(event.slots?.first?.event_mode, for: .normal)
        if let name = event.staff_name, let firstChar = name.first {
            cell.initialBtn.setTitle(String(firstChar), for: .normal)
        }

        if event.slots?.first?.event_mode == "In Person"{
            cell.MeetingTypeBtn.setImage(UIImage(systemName: "person.2.fill"), for: .normal)
        }else if event.slots?.first?.event_mode == "Phone Call"{
            cell.MeetingTypeBtn.setImage(UIImage(systemName: "phone"), for: .normal)
        }else if event.slots?.first?.event_mode == "Virtual" {
            cell.MeetingTypeBtn.setImage(UIImage(systemName: "network"), for: .normal)
        }
        
        cell.slotSelected = { [weak self] selectedIndex in
            guard let self = self else { return }
            self.handleSlotSelection(eventIndex: indexPath.row, slotIndex: selectedIndex)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            DispatchQueue.main.async {
                self.updateTableHeight()
            }
        }
    
    // MARK: - CollectionView (Dates)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dateComponents.count
    }
    
   func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CV.dequeueReusableCell(withReuseIdentifier: "DateCvCell", for: indexPath) as! DateCvCell
        let comp = dateComponents[indexPath.item]
        cell.monthLbl.text = comp.month
        cell.dateLbl.text = comp.day
        
        // Configure selection UI
        if selectedIndex == indexPath {
            cell.cellView.backgroundColor = .systemBlue
            cell.monthLbl.textColor = .white
            cell.dateBaseView.backgroundColor = .white
        } else {
            cell.cellView.backgroundColor = .clear
            cell.monthLbl.textColor = .black
            cell.dateBaseView.backgroundColor = .clear
        }
        
        // Show count if available
        if let count = comp.count {
            cell.countBtn.setTitle("Avl: "+count, for: .normal)
            cell.countBtn.isHidden = false
        } else {
            cell.countBtn.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        let selectedDate = dateComponents[indexPath.item].date
        let formatter = DateFormatter(); formatter.dateFormat = "dd-MM-yyyy"
        EventDate = formatter.string(from: selectedDate)
        getSlotsApi()
        CV.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 65, height: 120)
    }
}
