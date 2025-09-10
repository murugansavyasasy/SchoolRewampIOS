//
//  NewPtmVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 11/08/25.
//

struct SectionData {
    let title: String
    let events: [SlotEventDetail]
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
    
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var Meeting_data: [SlotDateData] = []
    var sections: [SectionData] = []
    var tvHidden:Bool?
    var MeetingDate = "ALL"
    var selectedDate = ""
    //let colours: [UIColor] = [.systemIndigo, .cyan, .systemPink, .systemGreen,UIColor(hex: "#E1E0F9")]
    let colours: [UIColor] = [UIColor(hex: "#E1E0F9"),UIColor(hex: "#DCEBFB"),UIColor(hex: "#F4E1FA"),UIColor(hex: "#E5FBE7")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeDateBtn.isHidden = true
        tv.isHidden = tvHidden ?? false

        topView.layer.cornerRadius = 20
        topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        backBtn.configureAsBackButton(firstLine: "PTM", secondLine: staffDetails?.school_name ?? "",colour: .white)
        
        selectDateBtn.setTitle(CommonStringFile.all, for: .normal)
        
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
        
        //addUnderline(to: allBtn, unSelectedBtn: [upcomingBtn,completedBtn,canceledBtn])
        
        cv.register(UINib(nibName: "PtmCV", bundle: nil), forCellWithReuseIdentifier: "PtmCV")
        cv.delegate = self
        cv.dataSource = self
        
        tv.register(UINib(nibName: "MeetingDetailTV", bundle: nil), forCellReuseIdentifier: "MeetingDetailTV")
        tv.register(UINib(nibName: "SlotListTV", bundle: nil), forCellReuseIdentifier: "SlotListTV")
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
        
        if selectedDate == ""{
            Get_Meetings_Api(EventDate: "ALL")
        }else {
            Get_Meetings_Api(EventDate: selectedDate)
        }
    }

    func Get_Meetings_Api(EventDate: String) {
        let param = [PTMRequestStringFile.event_date:EventDate]

        APIService.shared.makeApi(
            url: ServiceUrl.ptm_api_ptm_schedule_slot_details_for_staff,
            parameters: param,
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<PTMSlotResponse, Error>) in
            
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let success):
                    if success.status {
                        self.Meeting_data = success.data ?? []
                        self.sections.removeAll()
                        
                        guard let slotData = success.data?.first else { return }
                        
                        // Today
                        if let todayGroups = slotData.today, !todayGroups.isEmpty {
                            let events = todayGroups.compactMap { $0.details }.flatMap { $0 }
                            self.sections.append(SectionData(title: "Today Meetings", events: events))
                        }
                        
                        // Upcoming
                        if let upcomingGroups = slotData.upcoming, !upcomingGroups.isEmpty {
                            let events = upcomingGroups.compactMap { $0.details }.flatMap { $0 }
                            self.sections.append(SectionData(title: "Upcoming Meetings", events: events))
                        }
                        
                        // Completed
                        if let completedGroups = slotData.completed, !completedGroups.isEmpty {
                            let events = completedGroups.compactMap { $0.details }.flatMap { $0 }
                            self.sections.append(SectionData(title: "Completed Meetings", events: events))
                        }
                       
                        self.MeetingCountLbl.text = "You have " + String(slotData.today?.count ?? 0) + " Meetings Today"
                        
                        self.tv.reloadData()
                        self.cv.reloadData() // if you’re also showing in collection view
                    }else {
                        self.Meeting_data = success.data ?? []
                        self.sections.removeAll()
                        self.tv.reloadData()
                    }
                    
                case .failure(let error):
                    print("Error: ", error.localizedDescription)
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
        
        selectDateBtn.setTitle("All", for: .normal)
        removeDateBtn.isHidden = true
        selectedDate = ""
        Get_Meetings_Api(EventDate: "ALL")
    }
    
    
    @available(iOS 14.0, *)
    @IBAction func selectDateAct(_ sender: Any) {
        
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.delegate = self
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true)
    }
    
    func date(date: String) {
        selectDateBtn.setTitle(date, for: .normal)
        removeDateBtn.isHidden = false
        selectedDate = convertDate(date) ?? ""
        Get_Meetings_Api(EventDate: convertDate(date) ?? "")
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
        let cell = tv.dequeueReusableCell(withIdentifier: "MeetingDetailTV", for: indexPath) as! MeetingDetailTV
        //cell.cellView.backgroundColor = .white//colours[indexPath.row % colours.count]
        let event = sections[indexPath.section].events[indexPath.row]
        cell.MeetingNameLbl.text = event.event_name
        cell.dateBtn.setTitle(event.date?.convertToTargetDateFormat(), for: .normal)
        let time = (event.start_time ?? "") + " - " + (event.end_time ?? "")
        cell.timeBtn.setTitle(time, for: .normal)
        cell.modeLbl.text = event.event_mode
        if event.profiles?.count == 0 {
            cell.imageStack.isHidden = true
            cell.joinBtn.isHidden = false
        }else {
            cell.imageStack.isHidden = false
            cell.joinBtn.isHidden = true
            loadImages(into: cell, urls: event.profiles ?? [])
        }
       
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = SlotListVC(nibName: nil, bundle: nil)
        vc.slotData = sections[indexPath.section].events[indexPath.row]
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
