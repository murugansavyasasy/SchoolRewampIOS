//
//  CreateMeetingVc.swift
//  School Chimes
//
//  Created by Lakshmanan on 14/08/25.
//

import UIKit

class CreateMeetingVc: UIViewController {

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
    
    var dataArray = ["I - A", "III - C", "VI - A", "V - B"]
    var breakDuration = ["5 Min", "10 Min", "15 Min", "30 Min"]
    var SelectedClasses = Set<IndexPath>()
    var SelectedDuration: IndexPath?
    
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
        
        
       // breakDurationCV.allowsMultipleSelection = false
        classCv.allowsMultipleSelection = true
        
        classCv.register(UINib(nibName: "SlotCV", bundle: nil), forCellWithReuseIdentifier: "SlotCV")
        breakDurationCV.register(UINib(nibName: "SlotCV", bundle: nil), forCellWithReuseIdentifier: "SlotCV")
        classCv.delegate = self
        classCv.dataSource = self
        breakDurationCV.delegate = self
        breakDurationCV.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        classCv.layoutIfNeeded()
        classCVHeight.constant = classCv.contentSize.height
    }


    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
    }

}

extension CreateMeetingVc: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == classCv {
            return dataArray.count
        }
        
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == classCv {
            
            let cell = classCv.dequeueReusableCell(withReuseIdentifier: "SlotCV", for: indexPath) as! SlotCV
            
            cell.closeBtn.isHidden = true
            cell.label.textAlignment = .center
            cell.label.text = dataArray[indexPath.item]
            cell.cellView.backgroundColor = SelectedClasses.contains(indexPath) ? .systemBlue : .systemGray4
            cell.label.textColor = SelectedClasses.contains(indexPath) ? .white : .black
            return cell
        }else if collectionView ==  breakDurationCV {
            
            let cell = breakDurationCV.dequeueReusableCell(withReuseIdentifier: "SlotCV", for: indexPath) as! SlotCV
            
            cell.closeBtn.isHidden = true
            cell.label.textAlignment = .center
            cell.label.text = breakDuration[indexPath.item]
            cell.cellView.backgroundColor = (SelectedDuration == indexPath) ? .systemGreen : .systemGray4
            cell.label.textColor = (SelectedDuration == indexPath) ? .white : .black
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            if collectionView == classCv {
                // Toggle selection manually
                if SelectedClasses.contains(indexPath) {
                    SelectedClasses.remove(indexPath) // deselect
                } else {
                    SelectedClasses.insert(indexPath) // select
                }
            } else if collectionView == breakDurationCV {
                if SelectedDuration == indexPath {
                    return
                }
                SelectedDuration = indexPath
            }
             collectionView.reloadData()
        }
        
        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
            print("Entered Deselect")
            if collectionView == classCv {
                // Handle deselection only for multi-select
                SelectedClasses.remove(indexPath)
                collectionView.reloadItems(at: [indexPath])
            }
        }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = collectionView == classCv ?  dataArray[indexPath.item] : breakDuration[indexPath.item]
        let size = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 16)])
        return CGSize(width: size.width + 20, height: size.height + 16) // padding
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
