//
//  VoiceMessageVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 12/11/25.
//

import UIKit

class VoiceMessageVc: UIViewController {

    @IBOutlet weak var TitleAndVoiceFullView: UIView!
    @IBOutlet weak var backToComposeBtnName: UIButton!
    @IBOutlet weak var selectFromHisBtnName: UIButton!
    @IBOutlet weak var VoiceFullStack: UIStackView!
    @IBOutlet weak var currentTimeLbl: UILabel!
    @IBOutlet weak var totalDurationLbl: UILabel!
    @IBOutlet weak var voicePlayBtnName: UIButton!
    @IBOutlet weak var Tvheight: NSLayoutConstraint!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var titleTextFild: UITextField!
    @IBOutlet weak var recordedLbl: UILabel!
    @IBOutlet weak var voiceRecordImgView: UIImageView!
    @IBOutlet weak var EmergencySwitch: UISwitch!
    @IBOutlet weak var RecordedVoiceView: UIView!
    var VoiceHistory:[VoiceData]?
    let  staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var playIndex :Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        uiUpdate()
//        tv.isScrollEnabled = false
        tv.register(UINib(nibName: CellConfingName.HistoryTC, bundle: nil), forCellReuseIdentifier: CellConfingName.HistoryTC)
    }

    
    func uiUpdate() {
        
        RecordedVoiceView.layer.shadowColor = UIColor.black.cgColor
        RecordedVoiceView.layer.shadowOffset = CGSize(width: 0, height: 2)
        RecordedVoiceView.layer.shadowRadius = 5
        RecordedVoiceView.layer.shadowOpacity = 0.3
        RecordedVoiceView.layer.cornerRadius = 8
        
        backToComposeBtnName.setTitleFont(style: .body, size: FontSize.BodySize)
        selectFromHisBtnName.setTitleFont(style: .body, size: FontSize.BodySize)
        
        let title = CommonStringFile.Select_from_history
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        selectFromHisBtnName.setAttributedTitle(attributedTitle, for: .normal)
    }

    @IBAction func BackToComposeBtnAct(_ sender: UIButton) {
        VoiceFullStack.isHidden = false
        tv.isHidden = true
        Tvheight.constant = 0
        
    }
    @IBAction func voicePlayBtnAct(_ sender: UIButton) {
        
    }
    @IBAction func voiceRecdBtnAct(_ sender: UIButton) {
        
    }
    
    @IBAction func selectFromHisBtnAct(_ sender: UIButton) {
        VoiceFullStack.isHidden = true
        tv.isHidden = false
        get_Voice_History()
        
    }
    
    @IBAction func chooseFileBtnAct(_ sender: UIButton) {
        
        
    }

    @IBAction func nextBtnAct(_ sender: UIButton) {
    }
}
extension VoiceMessageVc : UITableViewDelegate , UITableViewDataSource {
    
    func reloadTable() {
        DispatchQueue.main.async { [self] in
            tv.layoutIfNeeded()
            Tvheight.constant = tv.contentSize.height
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VoiceHistory?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.HistoryTC, for: indexPath) as? HistoryTC else{
            return UITableViewCell()
        }
        
        let isPlaying = (playIndex == indexPath.row)
        let voiceData = VoiceHistory?[indexPath.row]
        
        cell.updatePlayState(isPlaying: isPlaying, url: voiceData?.url)
        cell.playBtn.tag = indexPath.row
        cell.sendbtn.tag = indexPath.row
        cell.delegate = self
        cell.ForwordDelegate = self
        cell.FinishPlayingdelegate = self
        
        cell.playBtn.setImage(isPlaying ? ImageName.pausebutton : ImageName.playbutton, for: .normal)
        
        let duration = voiceData?.duration ?? 0
        let formatted = formatDuration(duration)
        cell.totaltime.text = "00:00 / \(formatted)"
        cell.contentlbl.text = voiceData?.title ?? ""
        
        if !isPlaying {
            cell.playerView.progress = 0.0
            cell.playerView.updateWithLevel(0.0)
            cell.playerView.setNeedsDisplay()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            cell.configureShimmer()
        }
        
        if let sentOn = voiceData?.sent_on,
           let date = DateFormatterHelper.shared.parseDate(from: sentOn) {
            
            let dateString = DateFormatterHelper.shared.formatDateToDayMonthYear(date: date) // "11 Apr 2025"
            let timeString = DateFormatterHelper.shared.formatTime(date: date) // "01:04 PM"
            
            let fullText = "\(dateString) \(timeString)" // "11 Apr 2025 01:04 PM"
            
            let attributedText = NSMutableAttributedString(string: fullText)
            
            // Change time part color
            if let timeRange = fullText.range(of: timeString) {
                let nsRange = NSRange(timeRange, in: fullText)
                attributedText.addAttribute(.foregroundColor, value: UIColor.gray, range: nsRange)
            }
            
            cell.datelbl.attributedText = attributedText
        }
        
        
        return cell
    }
}

extension VoiceMessageVc : reloadDelegate, ForwordDelegate, HistoryFinishPalyingDelegate {
    func deleteDelegate(index: Int) {
        ""
    }
    func voiceforword(selectedIndex: Int?) {
        titleTextFild.text = VoiceHistory?[selectedIndex ?? 0].title ?? ""
        
        if EmergencySwitch.isOn && (VoiceHistory?[selectedIndex ?? 0].duration ?? 0) >=  30{
            let alert = UIAlertController(
                title: "Oops!",
                message: "Your Emergency call is ON. You can't forward Above 30 mins voice message",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: AlertstringFile.OK, style: .default))
            self.present(alert, animated: true, completion: nil)
        }else{
            
                //                enabelVoice_view(
                //                    isforward: true,
                //                    voiceUrl:VoiceHistory?[selectedIndex ?? 0].url ?? "",
                //                    title: VoiceHistory?[selectedIndex ?? 0].title ?? "",
                //                    durations: VoiceHistory?[selectedIndex ?? 0].duration ?? 0,
                //                    url: VoiceHistory?[selectedIndex ?? 0].url ?? ""
                //                )
//            }
            
        }
        
    }

    func didFinishPlaying(at index: Int) {
        print("✅ Finished playing voice at row: \(index)")
        playIndex = -1
        tv.reloadData()
    }

    func reload(index: Int) {
        if let currentIndex = playIndex, currentIndex != index {
            let previousIndexPath = IndexPath(row: currentIndex, section: 0)
            if let previousCell = tv.cellForRow(at: previousIndexPath) as? HistoryTC {
                previousCell.updatePlayState(isPlaying: false, url: nil)
            }
        }
        playIndex = (playIndex == index) ? nil : index
        tv.reloadData()
    }

    
}
extension VoiceMessageVc  {
    
    func get_Voice_History(){
        APIService.shared
            .makeApi(url:  ServiceUrl.comm_voice_get_voice_history, parameters: [:] , type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "", isBaseUrl: false){ [self] (
                result : Result<VoiceResponse,
                Error>
            ) in
                switch result {
                case.success(let succesmessage) :
                    if succesmessage.status == true {
                        DispatchQueue.main.async { [weak self] in
//                            no_recordLbl.isHidden = true
                            guard let self = self else { return }
                            self.VoiceHistory = succesmessage.data
                            self.tv.delegate = self
                            self.tv.dataSource = self
                            self.tv.reloadData()
                            self.reloadTable()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
//                            VoiceHistory = []
//                            no_recordLbl.isHidden = false
//                            no_recordLbl.text = succesmessage.message
//                            historytable.reloadData()
                        }
                        
                    }
                case.failure(let error) :
                    
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
            }
    }
    
}
