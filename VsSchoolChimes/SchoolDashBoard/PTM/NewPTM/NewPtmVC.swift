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

class NewPtmVC: UIViewController {

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
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var Meeting_data: [SlotDateData] = []
    var sections: [SectionData] = []
    var tvHidden:Bool?
    //let colours: [UIColor] = [.systemIndigo, .cyan, .systemPink, .systemGreen,UIColor(hex: "#E1E0F9")]
    let colours: [UIColor] = [UIColor(hex: "#E1E0F9"),UIColor(hex: "#DCEBFB"),UIColor(hex: "#F4E1FA"),UIColor(hex: "#E5FBE7")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tv.isHidden = tvHidden ?? false

        topView.layer.cornerRadius = 20
        topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        backBtn.configureAsBackButton(firstLine: "PTM", secondLine: "savyasasy School", colour: .white)
        
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
        
        Get_Meetings_Api()
        
    }

    func Get_Meetings_Api() {
        let param = [PTMRequestStringFile.event_date:"ALL"]

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
                            self.sections.append(SectionData(title: "Today", events: events))
                        }
                        
                        // Upcoming
                        if let upcomingGroups = slotData.upcoming, !upcomingGroups.isEmpty {
                            let events = upcomingGroups.compactMap { $0.details }.flatMap { $0 }
                            self.sections.append(SectionData(title: "Upcoming", events: events))
                        }
                        
                        // Completed
                        if let completedGroups = slotData.completed, !completedGroups.isEmpty {
                            let events = completedGroups.compactMap { $0.details }.flatMap { $0 }
                            self.sections.append(SectionData(title: "Completed", events: events))
                        }
                        
                        self.tv.reloadData()
                        self.cv.reloadData() // if you’re also showing in collection view
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
}


extension NewPtmVC: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].events.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "MeetingDetailTV", for: indexPath) as! MeetingDetailTV
        cell.cellView.backgroundColor = colours[indexPath.row % colours.count]
        let event = sections[indexPath.section].events[indexPath.row]
        cell.MeetingNameLbl.text = event.event_name
        cell.dateBtn.setTitle(event.date?.convertToTargetDateFormat(), for: .normal)
        let time = (event.start_time ?? "") + " - " + (event.end_time ?? "")
        cell.timeBtn.setTitle(time, for: .normal)
        cell.modeLbl.text = event.event_mode
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = SlotListVC(nibName: nil, bundle: nil)
        vc.slotData = sections[indexPath.section].events[indexPath.row]
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
