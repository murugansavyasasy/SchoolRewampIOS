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
    @IBOutlet weak var noDataView: UIView!
    
    
    var dateComponents: [(month: String, day: String, date: Date)] = []
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        generateDates()
        getsubjects()
    }
    
    private func setupUI() {
        topView.layer.cornerRadius = 20
        topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        scheduleMeetingBtn.layer.cornerRadius = 12
        scheduleMeetingBtn.backgroundColor = .white
        yourMeetingBtn.layer.cornerRadius = 12
        
        noDataView.isHidden = true
        NodataLbl.setFont(style: .body, size: FontSize.TitleSize)
        
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
                                       date: nextDate))
                if Calendar.current.isDate(nextDate, inSameDayAs: today) {
                    selectedIndex = IndexPath(item: i, section: 0)
                }
            }
        }
    }
    
    // MARK: - DropDown
    private func setupDropDown() {
        dropDown.anchorView = subjectsView
        dropDown.dataSource = ["All Subjects"] + subjectList.compactMap { $0.name }
        
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
                        self.noDataView.isHidden = true
                        self.tv.reloadData()
                    } else {
                        self.NodataLbl.text = success.message
                        self.tv.isHidden = true
                        self.noDataView.isHidden = false
                    }
                case .failure:
                    print("Error")
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
        struct SelectedBlock { let slot: StudentSlot; let eventIndex: Int }
        var selectedBlocks: [SelectedBlock] = []

        // Build selected blocks from userSelected only (ignore API my_booking rows here,
        // since you said locked rows shouldn't participate in conflict checks)
        for (eIdx, ev) in events.enumerated() {
            guard let slots = ev.slots else { continue }
            // skip locked rows from producing conflicts
            if slots.contains(where: { $0.my_booking ?? false }) { continue }
            for sl in slots where (sl.userSelected ?? false) {
                selectedBlocks.append(.init(slot: sl, eventIndex: eIdx))
            }
        }

        // Now compute for each row — only compare against selectedBlocks from OTHER rows
        for e in 0..<events.count {
            guard var slots = events[e].slots else { continue }

            let rowLocked = slots.contains(where: { $0.my_booking ?? false })

            for s in 0..<slots.count {
                var slot = slots[s]

                // If row is locked by API -> make non-booked slots disabled, keep my_booking slot active
                if rowLocked {
                    slot.is_conflictDisabled = !(slot.my_booking ?? false)
                }
                else if slot.is_booked ?? false {
                    // slot is already booked by someone else - keep as server state (not "conflict")
                    slot.is_conflictDisabled = false
                }
                else {
                    // check only against selectedBlocks from OTHER rows
                    let hasConflict = selectedBlocks.contains { block in
                        block.eventIndex != e && isOverlapping(slot1: block.slot, slot2: slot)
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
    }
    @IBAction func yourMeetingAct(_ sender: Any) {
        scheduleMeetingBtn.backgroundColor = .clear
        yourMeetingBtn.backgroundColor = .white
        addChildVc()
    }
    @IBAction func backAct(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - Child VC
    func addChildVc(){
        removeChildVc()
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
        cell.StaffNameLbl.text = (event.staff_name ?? "") + " - " + (event.subject_name ?? "")
        cell.MeetingTypeBtn.setTitle(event.slots?.first?.event_mode, for: .normal)
        
        cell.slotSelected = { [weak self] selectedIndex in
            guard let self = self else { return }
            guard var rowSlots = self.events[indexPath.row].slots else { return }

            // If this row is locked by API booking -> ignore taps
            if rowSlots.contains(where: { $0.my_booking ?? false }) { return }

            var tapped = rowSlots[selectedIndex]
            if tapped.is_booked ?? false { return }                 // already booked by others
            if tapped.is_conflictDisabled ?? false { return }       // disabled by conflicts

            // Toggle selection (only one per row)
            if tapped.userSelected ?? false {
                // deselect
                tapped.userSelected = false
            } else {
                // select -> clear other selections in this row and set this one
                for i in 0..<rowSlots.count { rowSlots[i].userSelected = false }
                tapped.userSelected = true
            }
            rowSlots[selectedIndex] = tapped

            // IMPORTANT: ensure other slots in the SAME ROW are never marked as conflict
            // (we only consider conflicts across other rows)
            for i in 0..<rowSlots.count {
                // keep server states intact (my_booking/is_booked)
                if rowSlots[i].my_booking ?? false || rowSlots[i].is_booked ?? false {
                    // leave as-is
                } else {
                    rowSlots[i].is_conflictDisabled = false
                }
            }

            // write back the row
            self.events[indexPath.row].slots = rowSlots

            // update selectedSlots (only user selections)
            self.updateSelectedSlots()

            // recompute conflicts for other rows
            self.recomputeConflicts()

            // debug — remove later
            print("SelectedSlots after toggle:", self.selectedSlots.map { ($0.slot_from ?? "") + "-" + ($0.slot_to ?? "") })

            self.tv.reloadData()
        }

        return cell
    }
    
    // MARK: - CollectionView (Dates)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dateComponents.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CV.dequeueReusableCell(withReuseIdentifier: "DateCvCell", for: indexPath) as! DateCvCell
        cell.monthLbl.text = dateComponents[indexPath.item].month
        cell.dateLbl.text = dateComponents[indexPath.item].day
        if selectedIndex == indexPath {
            cell.cellView.backgroundColor = .systemBlue
            cell.monthLbl.textColor = .white
            cell.dateBaseView.backgroundColor = .white
        } else {
            cell.cellView.backgroundColor = .clear
            cell.monthLbl.textColor = .black
            cell.dateBaseView.backgroundColor = .clear
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
        CGSize(width: 65, height: 105)
    }
}
