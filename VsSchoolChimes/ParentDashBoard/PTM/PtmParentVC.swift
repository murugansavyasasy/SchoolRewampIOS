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
    var selectedSlots: [StudentSlot] = []
    var EventDate = ""
    var subjectId = "0"
    var classteacherId = "0"
    let alert = CustomAlert()
    let dropDown = DropDown()
    var childVc : PtmHistoryVC?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.layer.cornerRadius = 20
        topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        scheduleMeetingBtn.layer.cornerRadius = 12
        scheduleMeetingBtn.backgroundColor = .white
        yourMeetingBtn.layer.cornerRadius = 12
        
        noDataView.isHidden = true
        
        NodataLbl.setFont(style: .body, size: FontSize.TitleSize)
        
        CV.layer.cornerRadius = 12
        CV.backgroundColor = .clear
        
        
        subjectsView.layer.cornerRadius = 15
        subjectsView.layer.borderWidth = 0.5
        subjectsView.layer.borderColor = UIColor.systemGray4.cgColor
        
        subjectsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectSubjectAct)))
        
        BookSlotBtn.layer.cornerRadius = 12
        
        generateDates()
        
        getsubjects()
        
        CV.register(UINib(nibName: "DateCvCell", bundle: nil), forCellWithReuseIdentifier: "DateCvCell")
        CV.delegate = self
        CV.dataSource = self
        
        tv.register(UINib(nibName: "parentPTMcell", bundle: nil), forCellReuseIdentifier: "parentPTMcell")
        tv.delegate = self
        tv.dataSource = self
    }
    
    private func generateDates() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        EventDate = formatter.string(from: Date())
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd"
        
        let today = Calendar.current.startOfDay(for: Date())
        
        for i in 0..<60 {
            if let nextDate = Calendar.current.date(byAdding: .day, value: i, to: today) {
                let month = monthFormatter.string(from: nextDate)
                let day = dayFormatter.string(from: nextDate)
                dateComponents.append((month: month, day: day, date: nextDate))
                
                if Calendar.current.isDate(nextDate, inSameDayAs: today) {
                    selectedIndex = IndexPath(item: i, section: 0)
                }
            }
        }
    }
    
    private func setupDropDown() {
        dropDown.anchorView = subjectsView
        
        // Add "All" as the first option
        let subjectNames = ["All Subjects"] + subjectList.compactMap { $0.name }
        dropDown.dataSource = subjectNames
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return } // self is optional now
            
            print("Selected item: \(item) at index: \(index)")
            subjectLbl.text = item
            
            switch index {
            case 0:
                // "All" selected
                subjectId = "0"
                classteacherId = "0"
                
            case 1:
                // First real subject in your list
                subjectId = "0"
                classteacherId = subjectList[index - 1].id ?? ""
                
            default:
                // Other subjects
                classteacherId = "0"
                subjectId = subjectList[index - 1].id ?? ""
            }
            
            getSlotsApi()
        }
        
        // UI tweaks
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y: subjectsView.bounds.height)
        dropDown.cellHeight = 50
        dropDown.backgroundColor = .white
        dropDown.textColor = .black
    }

    
    
    
    //MARK: API call functions
    
    func getsubjects(){
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_subject_list_with_class_teacher, parameters: [:], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") { [weak self] (result: Result<SubjectListResponse,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        self.subjectList = success.data ?? []
                        self.subjectId = "0"
                        self.classteacherId = "0"
                        self.setupDropDown()
                        self.getSlotsApi()
                    }else {
                        
                    }
                    
                case .failure(let failure):
                    print("Error")
                }
            }
        }
    }
    
    func getSlotsApi(){
        
        let param : [String:Any] = [PTMRequestStringFile.event_date:EventDate,PTMRequestStringFile.subject_id:subjectId,PTMRequestStringFile.class_teacher_id: classteacherId]
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_teacherwise_slots_availability_for_student, parameters: param, type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") { [weak self] (result: Result<StudentSlotResponse,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        self.events = success.data ?? []
                        self.tv.reloadData()
                        self.noDataView.isHidden = true
                        self.tv.isHidden = false
                    }else {
                        self.NodataLbl.text = success.message
                        self.tv.isHidden = true
                        self.noDataView.isHidden = false
                    }
                    
                case .failure(let failure):
                    print("Error")
                }
            }
        }
    }
    
    func Book_Slots_Api(){
        
        let slots : [String] = selectedSlots.compactMap {$0.id}
        let param : [String:Any] = [PTMRequestStringFile.slot_ids: slots]
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_book_slots_for_student, parameters: param, type: ApitTypeSringFile.PUT, token: childDetails?.access_token ?? "") { [weak self] (result:Result<CommonApiSuc,Error>) in
            
            guard let self = self else {return}
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    
                    if success.status == true {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success, message: success.message ?? "", on: self) {
                            
                            self.getSlotsApi()
                        }
                    }else {
                        
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                    }
                    
                case .failure(let failure):
                    
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
                }
            }
        }
    }
    
    @IBAction func selectSubjectAct(){
        dropDown.show()
    }
    
    @IBAction func BookSlotsAct(_ sender: Any) {
        
        if selectedSlots.isEmpty{
            CustomAlert.showAlertWithOkAction(title: "Missing Information", message: "minimum select one slot continue", on: self)
        }else {
            alert.showAlertCancel(title: AlertstringFile.Confirm, message: "Are you sure want to book selected Slots?", actionLbl1: AlertstringFile.OK, actionLbl2: AlertstringFile.Cancel, on: self) {
                self.Book_Slots_Api()
            } onNo: {
                
            }
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
    
    // MARK: - Time helpers
    private lazy var timeFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "hh:mm a"
            f.locale = Locale(identifier: "en_US_POSIX")
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

        // MARK: - Conflict recomputation
    private func recomputeConflicts() {
        struct SelectedBlock { let slot: StudentSlot; let eventIndex: Int }
        var selectedBlocks: [SelectedBlock] = []

        for (eIdx, ev) in events.enumerated() {
            guard let slots = ev.slots else { continue }
            for sl in slots {
                // ✅ include both API my_booking AND local userSelected
                if (sl.my_booking ?? false) || (sl.userSelected ?? false) {
                    selectedBlocks.append(.init(slot: sl, eventIndex: eIdx))
                }
            }
        }

        for e in 0..<events.count {
            guard var slots = events[e].slots else { continue }

            for s in 0..<slots.count {
                var slot = slots[s]

                if (slot.my_booking ?? false) || (slot.is_booked ?? false) {
                    // already locked → don't conflict-disable
                    slot.is_conflictDisabled = false
                } else {
                    // disable if overlaps with any selected/my_booking in OTHER rows
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
        // MARK: - Update selectedSlots storage
        private func updateSelectedSlots() {
            selectedSlots.removeAll()
            for event in events {
                if let slots = event.slots {
                    let chosen = slots.filter { $0.userSelected ?? false }
                    selectedSlots.append(contentsOf: chosen)
                }
            }
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "parentPTMcell", for: indexPath) as! parentPTMcell
        cell.configure(with: events[indexPath.row].slots ?? [], parentTableView: tv)
        
        let event = events[indexPath.row]
        
        cell.TitleLbl.text = event.event_name
        cell.StaffNameLbl.text = (event.staff_name ?? "") + " - " + (event.subject_name ?? "")
        cell.MeetingTypeBtn.setTitle(event.slots?.first?.event_mode, for: .normal)
        
        cell.slotSelected = { [weak self] selectedIndex in
                    guard let self = self else { return }
                    guard var rowSlots = self.events[indexPath.row].slots else { return }

                    var tapped = rowSlots[selectedIndex]

                    // 🚫 If this event has a locked API booking, do nothing
                    if rowSlots.contains(where: { $0.my_booking ?? false }) { return }
                    // 🚫 If already booked by another user, do nothing
                    if tapped.is_booked ?? false { return }

                    // ✅ Toggle selection
                    if tapped.userSelected ?? false {
                        // Deselect
                        tapped.userSelected = false
                        rowSlots[selectedIndex] = tapped
                    } else {
                        // Only one slot per event → clear first
                        for i in 0..<rowSlots.count { rowSlots[i].userSelected = false }
                        tapped.userSelected = true
                        rowSlots[selectedIndex] = tapped
                    }
                    self.events[indexPath.row].slots = rowSlots

                    // Recompute conflicts across events
                    self.recomputeConflicts()
                    // Refresh storage (only user selections, not my_booking)
                    self.updateSelectedSlots()

                    print("User selected slots: \(self.selectedSlots.map { ($0.slot_from ?? "") + "-" + ($0.slot_to ?? "") })")

                    self.tv.reloadData()
                }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dateComponents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = CV.dequeueReusableCell(withReuseIdentifier: "DateCvCell", for: indexPath) as! DateCvCell
        
        cell.monthLbl.text = dateComponents[indexPath.item].month
        cell.dateLbl.text = dateComponents[indexPath.item].day
        
        if selectedIndex == indexPath{
            cell.cellView.backgroundColor = .systemBlue
            cell.monthLbl.textColor = .white
            cell.dateBaseView.backgroundColor = .white
        }else {
            cell.cellView.backgroundColor = .clear
            cell.monthLbl.textColor = .black
            cell.dateBaseView.backgroundColor = .clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath
        let selectedDate = dateComponents[indexPath.item].date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let requestDate = formatter.string(from: selectedDate)
        EventDate = requestDate
        getSlotsApi()
        CV.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 65, height: 105)
    }
}
