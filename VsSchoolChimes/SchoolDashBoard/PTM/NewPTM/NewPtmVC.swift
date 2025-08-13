//
//  NewPtmVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 11/08/25.
//

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
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var Meeting_data: [SlotDateData] = []
    let colours: [UIColor] = [.systemIndigo, .cyan, .systemPink, .systemGreen]
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        APIService.shared.makeApi(url: ServiceUrl.ptm_api_ptm_schedule_slot_details_for_staff, parameters: param, type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") {[weak self] (result: Result<PTMSlotResponse,Error>) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else {return}
                switch result {
                    
                case .success(let success):
                    
                    if success.status == true {
                        self.Meeting_data = success.data ?? []
                    }
                    cv.reloadData()
                    
                case .failure(let error):
                    print("Error: ",error.localizedDescription)
                }
            }
        }
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
        return Meeting_data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cv.dequeueReusableCell(withReuseIdentifier: "PtmCV", for: indexPath) as! PtmCV
        let meeting = Meeting_data[indexPath.item]
        cell.dateBtn.setTitle(meeting.date, for: .normal)
        cell.MeetingNameLbl.text = meeting.details?.first?.event_name
        cell.modeLbl.text = "Mode - " + (meeting.details?.first?.event_mode ?? "")
        cell.standardLbl.text = (meeting.details?.first?.std_sec_details?.first?.class_name ?? "") + " - " + (meeting.details?.first?.std_sec_details?.first?.section_name ?? "")
        cell.cellview.backgroundColor = colours[indexPath.item % colours.count].withAlphaComponent(0.1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpacing = layout.minimumInteritemSpacing + layout.sectionInset.left + layout.sectionInset.right
        
        let width = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = SlotListVC(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
}
