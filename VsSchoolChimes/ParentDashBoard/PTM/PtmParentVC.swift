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
    
    var dateComponents: [(month: String, day: String, date: Date)] = []
    var selectedIndex: IndexPath?
    var childDetails = UserDefaultFileManager.get_child_Details()
    var subjectList : [Subject] = []
    var events : [EventData] = []
    var selectedSlots: [StudentSlot] = []
    var EventDate = ""
    var subjectId = "0"
    var classteacherId = "0"
    
    let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.layer.cornerRadius = 20
        topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        scheduleMeetingBtn.layer.cornerRadius = 12
        scheduleMeetingBtn.backgroundColor = .white
        
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
        dropDown.dataSource = subjectList.compactMap{$0.name}
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            subjectLbl.text = item
            
            if index == 0 {
                subjectId = "0"
                classteacherId = subjectList[index].id ?? ""
            }else {
                classteacherId = "0"
                subjectId = subjectList[index].id ?? ""
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
                    }else {
                        self.events = success.data ?? []
                        self.tv.reloadData()
                    }
                    
                case .failure(let failure):
                    print("Error")
                }
            }
        }
    }
    
    @IBAction func selectSubjectAct(){
        dropDown.show()
    }
    
    @IBAction func scheduleMeetingAct(_ sender: Any) {
        
        scheduleMeetingBtn.backgroundColor = .white
        yourMeetingBtn.backgroundColor = .clear
    }
    
    @IBAction func yourMeetingAct(_ sender: Any) {
        scheduleMeetingBtn.backgroundColor = .clear
        yourMeetingBtn.backgroundColor = .white
    }
    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
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

        // MARK: - Conflict recomputation (ONLY across other rows)
        private func recomputeConflicts() {
            // 1) Build list of selected blocks from ALL rows:
            //    include API my_booking and local userSelected
            struct SelectedBlock { let slot: StudentSlot; let eventIndex: Int }
            var selectedBlocks: [SelectedBlock] = []

            for (eIdx, ev) in events.enumerated() {
                guard let slots = ev.slots else { continue }
                for sl in slots {
                    if (sl.my_booking ?? false) || (sl.userSelected ?? false) {
                        selectedBlocks.append(.init(slot: sl, eventIndex: eIdx))
                    }
                }
            }

            // 2) For every row, disable ONLY if overlapping with selections from OTHER rows
            for e in 0..<events.count {
                guard var slots = events[e].slots else { continue }

                for s in 0..<slots.count {
                    var slot = slots[s]

                    // Server-locked states: never interact, never conflict-disable
                    if (slot.my_booking ?? false) || (slot.is_booked ?? false) {
                        slot.is_conflictDisabled = false
                    } else {
                        // conflict if overlaps with any selection from other rows
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "parentPTMcell", for: indexPath) as! parentPTMcell
        cell.configure(with: events[indexPath.row].slots ?? [], parentTableView: tv)
        
        let event = events[indexPath.row]
        
        cell.slotSelected = { [weak self] selectedIndex in
                    guard let self = self else { return }
                    guard var rowSlots = self.events[indexPath.row].slots else { return }

                    var tapped = rowSlots[selectedIndex]

                    // toggle selection in THIS row only
                    if tapped.userSelected ?? false {
                        // Deselect
                        tapped.userSelected = false
                        rowSlots[selectedIndex] = tapped
                    } else {
                        // Clear other user selections in this row, then select tapped
                        for i in 0..<rowSlots.count { rowSlots[i].userSelected = false }
                        tapped.userSelected = true
                        rowSlots[selectedIndex] = tapped
                    }
                    self.events[indexPath.row].slots = rowSlots

                    // Recompute conflicts across OTHER rows only
                    self.recomputeConflicts()

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
        }else {
            cell.cellView.backgroundColor = .white
            cell.monthLbl.textColor = .black
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
