//
//  NewPtmVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 11/08/25.
//

struct SectionData {
    let title: String
    let type : SectionType
    var events: [Any]
}

enum SectionType {
    case meetings
    case slots
}

import UIKit

class NewPtmVC: UIViewController, Datepicker {
   
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var selectDateBtn: UIButton!
    @IBOutlet weak var MeetingCountLbl: UILabel!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var upcomingBtn: UIButton!
    @IBOutlet weak var completedBtn: UIButton!
    @IBOutlet weak var canceledBtn: UIButton!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var sheduledBtn: UIButton!
    @IBOutlet weak var AttendedBtn: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var removeDateBtn: UIButton!
    @IBOutlet weak var menuNameLbl: UILabel!
    @IBOutlet weak var noDataImage: UIImageView!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var meetingsBtn: UIButton!
    @IBOutlet weak var bookedSlotsBtn: UIButton!
    
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var Meeting_data: [SlotDateData] = []
    var sections: [SectionData] = []
    var Booked_slot_data: [BookedSlotsData] = []
    var tvHidden:Bool?
    var MeetingDate = PTMString.All.translated()
    var selectedDate = ""
    var isBookedSlots = false
    //let colours: [UIColor] = [.systemIndigo, .cyan, .systemPink, .systemGreen,UIColor(hex: "#E1E0F9")]
    let colours: [UIColor] = [UIColor(hex: "#E1E0F9"),UIColor(hex: "#DCEBFB"),UIColor(hex: "#F4E1FA"),UIColor(hex: "#E5FBE7")]
    
    var expandedIndex: IndexPath?
    var pushNotiMsgId:String?
    var slotIndexMap: [String: IndexPath] = [:]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeDateBtn.isHidden = true
        tv.isHidden = tvHidden ?? false
        
        noDataImage.isHidden = true
        nodataLbl.isHidden = true

        topView.layer.cornerRadius = 20
        topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        menuNameLbl.configureAsBackTitle(firstLine: MenuStringFile.selectedMenuName, secondLine: staffDetails?.school_name ?? "")
        
        selectDateBtn.setTitle(CommonStringFile.all, for: .normal)
        selectDateBtn.semanticContentAttribute = .forceRightToLeft
        selectDateBtn.layer.cornerRadius = 10
        selectDateBtn.layer.borderWidth = 1
        selectDateBtn.layer.borderColor = UIColor.white.cgColor
        selectDateBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        MeetingCountLbl.setFont(style: .header, size: FontSize.HeaderSize)
        
        allBtn.setTitleFont(style: .primary, size: FontSize.TitleSize)
        
        sheduledBtn.layer.cornerRadius = 10
        AttendedBtn.layer.cornerRadius = 10
        plusBtn.layer.cornerRadius = 15
        
        sheduledBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        AttendedBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        plusBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        plusBtn.setTitle(PTMString.create.translated(), for: .normal)
        meetingsBtn.setTitle(PTMString.Meetings.translated(), for: .normal)
        bookedSlotsBtn.setTitle(PTMString.Booked_slots.translated(), for: .normal)
        
        meetingsBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        bookedSlotsBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        //addUnderline(to: allBtn, unSelectedBtn: [upcomingBtn,completedBtn,canceledBtn])
        
       
            addUnderline(to: meetingsBtn, unSelectedBtn: [bookedSlotsBtn])
        
       
        
//        cv.register(UINib(nibName: CellConfingName.PtmCV, bundle: nil), forCellWithReuseIdentifier: CellConfingName.PtmCV)
//        cv.delegate = self
//        cv.dataSource = self
        
        tv.register(UINib(nibName: CellConfingName.MeetingDetailTV, bundle: nil), forCellReuseIdentifier: CellConfingName.MeetingDetailTV)
        tv.register(UINib(nibName: CellConfingName.SlotListTV, bundle: nil), forCellReuseIdentifier: CellConfingName.SlotListTV)
        tv.delegate = self
        tv.dataSource = self
        
//        if let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
//                    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//                    layout.minimumInteritemSpacing = 8
//                    layout.minimumLineSpacing = 8
//                    layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
//                }
        
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if pushNotiMsgId != ""{
            bookedSlots()
        }else{
            
            if selectedDate == ""{
                Get_Meetings_Api(EventDate: "ALL")
            }else {
                Get_Meetings_Api(EventDate: selectedDate)
            }
        }
    }

    func Get_Meetings_Api(EventDate: String) {
        let param = [PTMRequestStringFile.event_date:EventDate]

        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        APIService.shared.makeApi(
            url: ServiceUrl.ptm_api_ptm_schedule_slot_details_for_staff,
            parameters: param,
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<PTMSlotResponse, Error>) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                if #available(iOS 15.0, *) { self.hideActivityLoader() }
                switch result {
                case .success(let success):
                    if success.status {
                        self.Meeting_data = success.data ?? []
                        self.sections.removeAll()
                        
                        self.noDataImage.isHidden = true
                        self.nodataLbl.isHidden = true
                        guard let slotData = success.data?.first else { return }
                        
                        // Today
                        if let todayGroups = slotData.today, !todayGroups.isEmpty {
                            let events = todayGroups.compactMap { $0.details }.flatMap { $0 }
                            self.sections.append(SectionData(title: PTMString.todayMeetings.translated(), type: .meetings, events: events))
                            let message = String(format:PTMString.meetingsToday.translated(),self.sections.first?.events.count ?? 0)
                            self.MeetingCountLbl.text = message
                        }
                        
                        // Upcoming
                        if let upcomingGroups = slotData.upcoming, !upcomingGroups.isEmpty {
                            let events = upcomingGroups.compactMap { $0.details }.flatMap { $0 }
                            self.sections.append(SectionData(title: PTMString.upcomingMeetings.translated(), type: .meetings, events: events))
                        }
                        
                        // Completed
                        if let completedGroups = slotData.completed, !completedGroups.isEmpty {
                            let events = completedGroups.compactMap { $0.details }.flatMap { $0 }
                            self.sections.append(SectionData(title: PTMString.completedMeetings.translated(), type: .meetings, events: events))
                        }
                       
//                        let message = String(format:PTMString.meetingsToday,slotData.today?.count ?? 0)
//                        self.MeetingCountLbl.text = message
                        //"You have " + String(slotData.today?.count ?? 0) + " Meetings Today"
                        
                        self.tv.reloadData()
                       // self.cv.reloadData() // if you’re also showing in collection view
                    }else {
                        self.nodataLbl.text = success.message
                        self.noDataImage.isHidden = false
                        self.nodataLbl.isHidden = false
                        self.Meeting_data = success.data ?? []
                        self.sections.removeAll()
                        self.tv.reloadData()
                    }
                    
                case .failure(let error):
                    print("Error: ", error.localizedDescription)
                    self.noDataImage.isHidden = false
                    self.nodataLbl.isHidden = false
                    self.nodataLbl.text = error.localizedDescription
                    self.tv.reloadData()
                }
            }
        }
    }

    
    func Get_bookedSlots_Api(EventDate: String){
        
        let param = [PTMRequestStringFile.event_date:EventDate]

        if #available(iOS 15.0, *) {
            showActivityLoader()
        }
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_datewise_booked_slots, parameters: param, type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [weak self] (result: Result<BookedSlotsResponse,Error>) in
            
            DispatchQueue.main.async { [self] in
                guard let self = self else {return}
                if #available(iOS 15.0, *){self.hideActivityLoader()}
                
                switch result {
                case .success(let success):
                    
                    if success.status{
                        
                        self.Booked_slot_data = success.data
                        self.sections.removeAll()
                        self.noDataImage.isHidden = true
                        self.nodataLbl.isHidden = true
                        
                        guard let slotData = success.data.first else {return}
                        
                        //Today
                        if let todaySlots = slotData.today, !todaySlots.isEmpty {
                            let slots = todaySlots.compactMap{$0}
                            self.sections.append(SectionData(title: PTMString.Today_slots.translated(), type: .slots, events: slots))
                        }
                        
                        //Upcoming
                        if let upcomingSlots = slotData.upcoming, !upcomingSlots.isEmpty {
                            let slots = upcomingSlots.compactMap{$0}
                            self.sections.append(SectionData(title:  PTMString.Upcoming_slots.translated(), type: .slots, events: slots))
                        }
                        
                        //Completed
                        if let completedSlots = slotData.completed, !completedSlots.isEmpty {
                            let slots = completedSlots.compactMap{$0}
                            self.sections.append(SectionData(title:  PTMString.completed_slots.translated(), type: .slots, events: slots))
                        }
                        
                        self.buildSlotIndexMap()
                        self.tv.reloadData()
                        if self.pushNotiMsgId != ""{
                            DispatchQueue.main.async {
                                self.scrollToNotificationIfNeeded()
                                self.pushNotiMsgId = ""
                            }
                        }
                    }else {
                        self.sections.removeAll()
                        self.nodataLbl.isHidden = false
                        self.noDataImage.isHidden = false
                        self.nodataLbl.text = success.message
                        self.tv.reloadData()
                    }
                
                    
                case .failure(let failure):
                    self.sections.removeAll()
                    self.nodataLbl.isHidden = false
                    self.noDataImage.isHidden = false
                    self.nodataLbl.text = failure.localizedDescription
                    self.tv.reloadData()
                }
            }
        }
    }
    

    private func scrollToNotificationIfNeeded() {
        guard let id = pushNotiMsgId else { return }

        for (sectionIndex, section) in sections.enumerated() {
            if let rowIndex = section.events.firstIndex(where: {
                ($0 as? BookedSlot)?.slot_id == id
            }) {
                scrollAndHighlight(IndexPath(row: rowIndex, section: sectionIndex))
            }

        }
    }



    func scrollAndHighlight(_ indexPath: IndexPath) {
        tv.scrollToRow(at: indexPath, at: .middle, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            guard let self = self else { return }

            if let cell = self.tv.cellForRow(at: indexPath) {
                UIView.animate(withDuration: 0.25) {
                    cell.contentView.backgroundColor =  UIColor.lightGray
                        .withAlphaComponent(0.3)
                } completion: { _ in
                    UIView.animate(withDuration: 0.7, delay: 0.8) {
                        cell.contentView.backgroundColor = .clear
                    }
                }
            }
        }
    }
    

    @available(iOS 14.0, *)
    @IBAction func createAct(_ sender: Any) {
        let vc = CreateMeetingVc(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    
    @IBAction func removeDateAct(_ sender: Any) {
        
        selectDateBtn.setTitle(PTMString.All.translated(), for: .normal)
        removeDateBtn.isHidden = true
        selectedDate = ""
        
        if isBookedSlots{
            Get_bookedSlots_Api(EventDate: "ALL")
        }else{
            Get_Meetings_Api(EventDate: "ALL")
        }
    }
    
    
    @available(iOS 14.0, *)
    @IBAction func selectDateAct(_ sender: Any) {
        
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.date = selectDateBtn.titleLabel?.text
        vc.delegate = self
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true)
    }
    
    func date(date: String) {
        selectDateBtn.setTitle(date, for: .normal)
        removeDateBtn.isHidden = false
        selectedDate = convertDate(date) ?? ""
        
        if isBookedSlots{
            Get_bookedSlots_Api(EventDate: convertDate(date) ?? "")
        }else{
            Get_Meetings_Api(EventDate: convertDate(date) ?? "")
        }
    }
    
    @IBAction func allAct(_ sender: Any) {
        addUnderline(to: allBtn, unSelectedBtn: [upcomingBtn,completedBtn,canceledBtn])
    }
    @IBAction func upcomingAct(_ sender: Any) {
        addUnderline(to: upcomingBtn, unSelectedBtn: [allBtn,completedBtn,canceledBtn])
    }
    @IBAction func completedAct(_ sender: Any) {
        addUnderline(to: completedBtn, unSelectedBtn: [upcomingBtn,allBtn,canceledBtn])
    }
    
    @IBAction func cancelAct(_ sender: Any) {
        addUnderline(to: canceledBtn, unSelectedBtn: [upcomingBtn,completedBtn,allBtn])
    }
    
    @IBAction func MeetingsBtn(_ sender: Any) {
        
        isBookedSlots = false
        addUnderline(to: meetingsBtn, unSelectedBtn: [bookedSlotsBtn])
        
        if selectedDate == ""{
            Get_Meetings_Api(EventDate: "ALL")
        }else {
            Get_Meetings_Api(EventDate: selectedDate)
        }
    }
    
    @IBAction func bookedSlotsBtn(_ sender: Any) {
        isBookedSlots = true
        bookedSlots()
    }
    
    
    func bookedSlots(){
        addUnderline(to: bookedSlotsBtn, unSelectedBtn: [meetingsBtn])
        
        if selectedDate == ""{
            Get_bookedSlots_Api(EventDate: "ALL")
        }else {
            Get_bookedSlots_Api(EventDate: selectedDate)
        }
    }
    
    func addUnderline(to selectedButton: UIButton, unSelectedBtn: [UIButton]) {
        ([selectedButton] + unSelectedBtn).forEach { button in
            button.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
            button.tintColor = .black
        }
        selectedButton.tintColor = .systemBlue
        let underline = UIView()
        underline.tag = 999
        underline.backgroundColor = .systemBlue
        underline.translatesAutoresizingMaskIntoConstraints = false
        selectedButton.addSubview(underline)

        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 2),
            underline.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: selectedButton.trailingAnchor),
            underline.bottomAnchor.constraint(equalTo: selectedButton.bottomAnchor)
        ])
    }
    
    func buildSlotIndexMap() {
        slotIndexMap.removeAll()

        for (sectionIndex, section) in sections.enumerated() {
            guard section.type == .slots,
                  let slots = section.events as? [BookedSlot] else { continue }

            for (rowIndex, slot) in slots.enumerated() {
                slotIndexMap[slot.slot_id ?? ""] = IndexPath(
                    row: rowIndex,
                    section: sectionIndex
                )
            }
        }
    }

}


extension NewPtmVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5//Meeting_data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cv.dequeueReusableCell(withReuseIdentifier: "PtmCV", for: indexPath) as! PtmCV
//        let meeting = Meeting_data[indexPath.item]
//        cell.dateBtn.setTitle(meeting.date, for: .normal)
//        cell.MeetingNameLbl.text = meeting.details?.first?.event_name
//        cell.modeLbl.text = "Mode - " + (meeting.details?.first?.event_mode ?? "")
//        cell.standardLbl.text = (meeting.details?.first?.std_sec_details?.first?.class_name ?? "") + " - " + (meeting.details?.first?.std_sec_details?.first?.section_name ?? "")
//        cell.cellview.backgroundColor = colours[indexPath.item % colours.count]
//        cell.timeLbl.text = (meeting.date ?? "") + ", " + "4:30 PM"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpacing = layout.minimumInteritemSpacing + layout.sectionInset.left + layout.sectionInset.right
        
        let width = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: width, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
//        let vc = SlotListVC(nibName: nil, bundle: nil)
//        vc.slotData = Meeting_data[indexPath.row]
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
    }
    
    func loadImages(into cell: MeetingDetailTV, urls: [String]) {
        // Hide all image views and button initially
        [cell.img1, cell.img2, cell.img3].forEach { $0?.isHidden = true }
        cell.countBtn.isHidden = true
        
        let imageViews = [cell.img1, cell.img2, cell.img3]
        
        // Show first 3 images
        for (index, urlString) in urls.prefix(3).enumerated() {
            guard let imageView = imageViews[safe: index] else { continue }
            
            imageView?.isHidden = false
            
            if let url = URL(string: urlString), !urlString.isEmpty {
                // Load from URL
                imageView?.sd_setImage(
                    with: url,
                    placeholderImage: UIImage(named: "Default_profile"),
                    options: [.retryFailed, .continueInBackground]
                )
            } else {
                // Invalid/empty → set default image
                imageView?.image = UIImage(named: "Default_profile")
            }
        }
        
        // Show remaining count if more than 3
        if urls.count > 3 {
            let extraCount = urls.count - 3
            cell.countBtn.setTitle("+\(extraCount)", for: .normal)
            cell.countBtn.isHidden = false
        }
    }


    
}


extension NewPtmVC: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].events.count
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return sections[section].title
//    }
//    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = .clear  // Customize color

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFont(style: .title, size: FontSize.TitleSize)
        label.textColor = .darkGray
        label.text = sections[section].title
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5)])

        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let Sections = sections[indexPath.section]
        
        switch Sections.type{
            
        case .meetings:
            
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.MeetingDetailTV, for: indexPath) as! MeetingDetailTV
            //cell.cellView.backgroundColor = .white//colours[indexPath.row % colours.count]
            let event = sections[indexPath.section].events[indexPath.row] as? SlotEventDetail
        
            cell.MeetingNameLbl.text = event?.event_name
            cell.dateBtn.setTitle(event?.date?.convertToTargetDateFormat(), for: .normal)
            let time = (event?.start_time ?? "") + " - " + (event?.end_time ?? "")
            cell.timeBtn.setTitle(time, for: .normal)
            cell.modeLbl.text = "Mode - " + (event?.event_mode ?? "")
            if event?.profiles?.count == 0 {
                cell.imageStack.isHidden = true
                cell.joinBtn.isHidden = false
            }else {
                cell.imageStack.isHidden = false
                cell.joinBtn.isHidden = true
                loadImages(into: cell, urls: event?.profiles ?? [])
            }
           
            return cell
            
        case .slots:
            
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.SlotListTV, for: indexPath) as! SlotListTV
            
            let slot = sections[indexPath.section].events[indexPath.row] as? BookedSlot
            let MeetingStatus = sections[indexPath.section].title
            
            cell.meetigModeLbl.isHidden = false
            cell.meetigNameLbl.isHidden = false
            cell.dateStack.isHidden = false
            cell.modeStack.isHidden = false
            cell.meetigNameLbl.text = slot?.event_name
            cell.meetigModeLbl.text = slot?.event_mode

            // MARK: - Basic Info
            cell.TimeLbl.text = "\(slot?.from_time ?? "") - \(slot?.to_time ?? "") (\(slot?.meeting_duration ?? 0) \(PTMString.minutes.translated()))"
            cell.DurationLbl.text = slot?.date?.convertToTargetDateFormat()//"\(PTMString.duration.translated()) - \(slot?.meeting_duration ?? 0) \(PTMString.minutes.translated())"
            cell.bookedByNameLbl.text = slot?.student_name
            cell.fatherNameLbl.text = slot?.father_name
            cell.motherNameLbl.text = slot?.mother_name
            cell.standardLbl.text = "\(slot?.class_name ?? "") - \(slot?.section_name ?? "")"

            // MARK: - Image
            if let url = URL(string: slot?.profile_url ?? "") {
                cell.profileImage.sd_setImage(with: url, placeholderImage: UIImage(named: "interactProfile"))
            }else{
                cell.profileImage.image = UIImage(named: "interactProfile")
            }

            // MARK: - Options Button Logic
            if slot?.can_cancel == true {
                cell.edit(
                    edit: slot?.is_cancelled ?? false,
                    delete: !(slot?.is_cancelled ?? false),
                    selectedId: slot?.slot_id ?? ""
                )
                

                if MeetingStatus == "Completed Slots" {
                    cell.optionsBtn.isHidden = true
                } else if MeetingStatus == "Today Slots" {
                    cell.optionsBtn.isHidden = isCurrentTimeLater(than: slot?.from_time ?? "")
                }else{
                    cell.optionsBtn.isHidden = false
                }

                cell.delegate = self
            } else {
                cell.optionsBtn.isHidden = true
            }
            // MARK: - Reset common UI
            cell.BookedStatusView.isHidden = true
            cell.WaitingLbl.isHidden = true
            cell.WaitingLbl.text = nil

            // MARK: - Slot Status Handling
            if slot?.slot_status == "Expired" {

                cell.StatusBtn.backgroundColor = .systemGray5
                cell.StatusBtn.setImage(UIImage(systemName: "exclamationmark.circle"), for: .normal)
                cell.StatusBtn.setTitle("Expired", for: .normal)
                cell.StatusBtn.tintColor = .black
                cell.StatusBtn.setTitleColor(.black, for: .normal)

                cell.BookingBaseview.backgroundColor = .systemGray5

                cell.WaitingLbl.isHidden = false
                cell.WaitingLbl.textColor = .black
                cell.WaitingLbl.text = "Slot Expired"

            }
            else if slot?.is_cancelled_by_staff == true {

                cell.StatusBtn.backgroundColor = .systemRed.withAlphaComponent(0.1)
                cell.StatusBtn.setImage(UIImage(systemName: "x.circle"), for: .normal)
                cell.StatusBtn.setTitle("Cancelled", for: .normal)
                cell.StatusBtn.tintColor = .red
                cell.StatusBtn.setTitleColor(.red, for: .normal)

                cell.BookingBaseview.backgroundColor = .systemRed.withAlphaComponent(0.1)

                cell.WaitingLbl.isHidden = false
                cell.WaitingLbl.textColor = .systemRed
                cell.WaitingLbl.text = "Slot Cancelled"

            }
            else if slot?.is_booked == true {

                cell.StatusBtn.backgroundColor = .green.withAlphaComponent(0.1)
                cell.StatusBtn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)

                let title = MeetingStatus == PTMString.completedMeetings.translated() ? "Completed" : "Booked"
                cell.StatusBtn.setTitle(title, for: .normal)

                cell.StatusBtn.tintColor = .aproved
                cell.StatusBtn.setTitleColor(.aproved, for: .normal)

                cell.BookingBaseview.backgroundColor = .systemGreen.withAlphaComponent(0.1)
                cell.BookedStatusView.isHidden = false

            }
            else { // Available

                cell.StatusBtn.backgroundColor = .systemBlue.withAlphaComponent(0.075)
                cell.StatusBtn.setImage(UIImage(systemName: "exclamationmark.circle"), for: .normal)
                cell.StatusBtn.setTitle("Available", for: .normal)
                cell.StatusBtn.tintColor = .systemBlue
                cell.StatusBtn.setTitleColor(.black, for: .normal)

                cell.BookingBaseview.backgroundColor = .systemBlue.withAlphaComponent(0.1)

                cell.WaitingLbl.isHidden = false
                cell.WaitingLbl.textColor = .systemBlue
                cell.WaitingLbl.text = "Waiting for Booking"
            }
            
            
               cell.Collapsedelegate = self
               cell.indexPath = indexPath
               
               // update expansion
               let isExpanded = expandedIndex == indexPath
               cell.updateExpansion(isExpanded: isExpanded)
            
            cell.onCall = { [weak self] in
                
                self?.callButtonTapped(Mobile: slot?.mobile_no ?? "")
            }
            
            cell.onJoin = {[weak self] in
                self?.JoinButtonTapped(Link: slot?.event_link ?? "")
            }
            
            cell.callImage.isHidden = !(slot?.event_mode == "Phone Call")
            cell.LinkImage.isHidden = !(slot?.event_mode == "Virtual")

            return cell
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = sections[indexPath.section]
        if section.type == .meetings{
            let vc = SlotListVC(nibName: nil, bundle: nil)
            vc.slotData = sections[indexPath.section].events[indexPath.row] as? SlotEventDetail
            vc.MeetingStatus = sections[indexPath.section].title
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func isCurrentTimeLater(than timeString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let givenDate = formatter.date(from: timeString) else {
            return false // invalid input
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Extract hour and minute from given time
        let components = calendar.dateComponents([.hour, .minute], from: givenDate)
        
        guard let givenTimeToday = calendar.date(bySettingHour: components.hour!,
                                                 minute: components.minute!,
                                                 second: 0,
                                                 of: now) else {
            return false
        }
        
        return now > givenTimeToday
    }
    
    func callButtonTapped(Mobile: String) {
           if let url = URL(string: "tel://\(Mobile)"),
              UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url)
           } else {
               print("This device cannot make phone calls.")
           }
       }
    
    func JoinButtonTapped(Link: String) {
        var fixedLink = Link
        if !fixedLink.lowercased().hasPrefix("http") {
            fixedLink = "https://" + fixedLink
        }
        
        if let url = URL(string: fixedLink) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot open meeting link")
        }
    }
}

extension NewPtmVC: BookingCellDelegate, SelectedId {

    func didTapCollapse(cell: SlotListTV) {
        guard let indexPath = cell.indexPath else { return }

        tv.beginUpdates()

        if expandedIndex == indexPath {
            // collapse current
            expandedIndex = nil
        } else {
            // collapse previous
            if let previous = expandedIndex {
                tv.reloadRows(at: [previous], with: .automatic)
            }
            // expand new
            expandedIndex = indexPath
        }

        // reload the tapped cell
        tv.reloadRows(at: [indexPath], with: .automatic)

        tv.endUpdates()
    }
    
    func selectId(id: String?, edit: Bool?) {
        if edit ?? false{
            Cancel_and_Reopen_Slot_api(SlotId: id ?? "")
        }else{
            cancel_and_close_slot_Api(SlotId: id ?? "")
        }
    }
    
    func Cancel_and_Reopen_Slot_api(SlotId:String){
        
        let param : [String:Any] = ["slot_id":SlotId]
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_cancel_and_reopen_slot, parameters: param, type: ApitTypeSringFile.PUT, token: staffDetails?.access_token ?? "") { [weak self] (result:Result<CommonApiSuc,Error>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    if success.status == true {
                        
                        guard let indexPath = self.slotIndexMap[SlotId] else { return }
                        
                        var section = self.sections[indexPath.section]
                        guard var slots = section.events as? [BookedSlot] else { return }

                        slots[indexPath.row].is_booked = false
                        slots[indexPath.row].is_cancelled = false
                        slots[indexPath.row].is_cancelled_by_staff = false
                        
                        section.events = slots
                        self.sections[indexPath.section] = section

                        self.tv.reloadRows(at: [indexPath], with: .automatic)
                        
                    }else {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                    }
                case .failure(let failure):
                    print("Error: ",failure.localizedDescription)
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
                }
                
            }
        }
    }
    
    func cancel_and_close_slot_Api(SlotId:String){
        let slot_id = [SlotId]
        let param : [String:Any] = ["slot_ids":slot_id]
        
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_cancel_and_close_slot, parameters: param, type: ApitTypeSringFile.PUT, token: staffDetails?.access_token ?? "") { [weak self] (result:Result<CommonApiSuc,Error>) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let success):
                    if success.status == true {
                        
                        guard let indexPath = self.slotIndexMap[SlotId] else { return }
                        
                        var section = self.sections[indexPath.section]
                        guard var slots = section.events as? [BookedSlot] else { return }

                        slots[indexPath.row].is_booked = false
                        slots[indexPath.row].is_cancelled = true
                        slots[indexPath.row].is_cancelled_by_staff = true
                        
                        section.events = slots
                        self.sections[indexPath.section] = section

                        self.tv.reloadRows(at: [indexPath], with: .automatic)
                        
                    }else {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                    }
                case .failure(let failure):
                    print("Error: ",failure.localizedDescription)
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
                }
                
            }
            
        }
    }
    
    func indexPathForSlot(slotId: String) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            guard section.type == .slots,
                  let slots = section.events as? [BookedSlot] else { continue }

            if let rowIndex = slots.firstIndex(where: { $0.slot_id == slotId }) {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
   
}
