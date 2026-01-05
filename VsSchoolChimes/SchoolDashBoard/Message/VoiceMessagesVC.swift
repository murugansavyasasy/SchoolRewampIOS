//
//  VoiceMessagesVC.swift
//  School Chimes
//
//  Created by apple on 27/12/25.
//

import UIKit

class VoiceMessagesVC: UIViewController, AudioPlaybackDelegate1, selectedAudio {
    func selectedAudio(index: Int) {
        selectedVoiceUrl = VoiceHistory?[index].url ?? ""
        IsSelectedHistory = false
        tv.reloadData()
    }
    
    func audioCell(_ cell: CommunicationTVC, willStartPlayingAtIndex index: Int) {
        if let audioCell = cell as? CommunicationTVC,
           audioCell.cellIndex != index {
            audioCell.stopPlayback()
        }
    }
    
    func audioCell(_ cell: CommunicationTVC, didStopPlayingAtIndex index: Int) {
        ""
    }
   
    @IBOutlet weak var selectFromHistoryLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    var VoiceHistory:[VoiceData]?
    var IsSelectedHistory:Bool = false
    var selectedVoiceUrl : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        tv.dataSource = self
        tv.delegate  = self
        tv.register(UINib(nibName: "VoiceCellTV", bundle: nil), forCellReuseIdentifier: "VoiceCellTV")
        tv.register(UINib(nibName: "CommunicationTVC", bundle: nil), forCellReuseIdentifier: "CommunicationTVC")
        tv.reloadData()
        let selectFromHis = UITapGestureRecognizer(target: self, action: #selector(selectFromHistory))
        selectFromHistoryLbl.addGestureRecognizer(selectFromHis)
        
    }
}

extension VoiceMessagesVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  IsSelectedHistory{
            return VoiceHistory?.count ?? 0
        }else{
            return 1
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if  IsSelectedHistory{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommunicationTVC", for: indexPath) as? CommunicationTVC else {
           return UITableViewCell()
            }
            let voiceData = VoiceHistory?[indexPath.row]
            cell.emergencyBtnName.isHidden = true
            if let sentOn = voiceData?.sent_on {
                cell.dateLbl.attributedText = formattedDateTimeText(from: sentOn)
            }
            cell.selectedAudioDelegate = self
            cell.selectBtnName.tag = indexPath.row
            cell.waveView.durationLabel.isHidden = true
            cell.titleLbl.text = voiceData?.title
            cell.selectBtnHeight.constant = 30
            let duration = voiceData?.duration ?? 0
            let formattedDuration = formatDuration(duration)
            cell.tottalDurationLbl.text = formattedDuration
                cell.newImageView.isHidden = true
            configureAudioCell(cell, at: indexPath)
            
            return cell
        }else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "VoiceCellTV", for: indexPath) as? VoiceCellTV else {
           return UITableViewCell()
            }
            if selectedVoiceUrl != "" {
                let url = URL(string: selectedVoiceUrl)
                 cell.audioURL = url
                cell.uiUpdate(isHiden:false)
            }else{
                cell.uiUpdate(isHiden:true)
            }
            
            return cell
        }
       
    }
    
    func formattedDateTimeText(from sentOn: String) -> NSAttributedString? {
        guard let date = DateFormatterHelper.shared.parseDate(from: sentOn) else {
            return nil
        }
        let dateString = DateFormatterHelper.shared.formatDateToDayMonthYear(date: date)   // "11 Apr 2025"
        let timeString = DateFormatterHelper.shared.formatTime(date: date)                // "01:04 PM"
        let fullText = "\(dateString) \(timeString)"
        let attributedText = NSMutableAttributedString(string: fullText)
        // Change only time color
        if let timeRange = fullText.range(of: timeString) {
            let nsRange = NSRange(timeRange, in: fullText)
            attributedText.addAttribute(.foregroundColor, value: UIColor.gray, range: nsRange)
        }
        return attributedText
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: - Audio Cell Configuration
    private func configureAudioCell(_ cell: CommunicationTVC, at indexPath: IndexPath) {
        let file = VoiceHistory?[indexPath.item]
        if let urlString = file?.url,
           let url = URL(string: urlString) {
            cell.audioURL = url
        }
        cell.audioDelegate = self
        cell.cellIndex = indexPath.item
        cell.waveView.setParentCell(cell)
       
    }
    
   
}
extension VoiceMessagesVC  {
    
    @IBAction func selectFromHistory() {
        
        if selectFromHistoryLbl.text == "<<Back to compose"{
            selectFromHistoryLbl.textAlignment = .right
            IsSelectedHistory = false
            selectFromHistoryLbl.text = "<<Select from history"
            tv.reloadData()
        }else if selectFromHistoryLbl.text == "<<Select from history"{
            selectFromHistoryLbl.textAlignment = .left
            IsSelectedHistory = true
            selectFromHistoryLbl.text = "<<Back to compose"
            get_Voice_History()
        }
       
    }
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
                            guard let self = self else { return }
                            self.VoiceHistory = succesmessage.data
                            self.tv.delegate = self
                            self.tv.dataSource = self
                            self.tv.reloadData()
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
