import UIKit
import FSCalendar
import AVFoundation
import UniformTypeIdentifiers
import AVFAudio
import AudioToolbox
protocol reloadDelegate{
    func reload(index: Int)
    func deleteDelegate(index:Int)
}

extension ComunicationVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none // Ensures popover on iPhone
    }
}
class ComunicationVC: UIViewController, AVAudioRecorderDelegate, reloadDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, FSCalendarDelegate, FSCalendarDataSource, SelectedTextDelegate, ForwordDelegate, HistoryFinishPalyingDelegate, selectedAudio, AudioPlaybackDelegate1{
    func audioCell(_ cell: CommunicationTVC, willStartPlayingAtIndex index: Int) {
        if let audioCell = cell as? CommunicationTVC,
           audioCell.cellIndex != index {
            audioCell.stopPlayback()
        }
    }
    
    func audioCell(_ cell: CommunicationTVC, didStopPlayingAtIndex index: Int) {
        ""
    }
    
    func selectedAudio(index: Int) {
        voiceTitleeTxt.text = VoiceHistory?[index].title ?? ""
        if emengencyCall.isOn && (VoiceHistory?[index].duration ?? 0) >=  30{
            let alert = UIAlertController(
                title: "Oops!",
                message: "Your Emergency call is ON. You can't forward Above 30 mins voice message",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: AlertstringFile.OK, style: .default))
            self.present(alert, animated: true, completion: nil)
        }else{
            if isScheduleSelected{
                enabelScheduleView(
                    isforward: true,
                    voiceUrl:VoiceHistory?[index].url ?? "",
                    title: VoiceHistory?[index].title ?? "",
                    durations: VoiceHistory?[index].duration ?? 0,
                    url: VoiceHistory?[index].url ?? ""
                )
                guard let url = URL(string: VoiceHistory?[index].url ?? "") else { return }
                // Check if it's a remote URL (http or https)
                if url.isFileURL {
                    do {
                        try audioManager.setupPlayer(with: url)
                        waveView.audioURL = url
                        self.waveView.onDurationUpdate = { [weak self] time in
                            self?.voiceTiming.text = time
                        }
                    } catch {
                        print("❌ Failed to set up audio player:", error)
                    }
                } else {
                    // Remote URL - download it first
                    downloadAndPrepareAudio(from: url)
                }
            }else{
                enabelVoice_view(
                    isforward: true,
                    voiceUrl:VoiceHistory?[index].url ?? "",
                    title: VoiceHistory?[index].title ?? "",
                    durations: VoiceHistory?[index].duration ?? 0,
                    url: VoiceHistory?[index].url ?? ""
                )
                AudioPlayUrl = VoiceHistory?[index].url ?? ""
                
                guard let url = URL(string: VoiceHistory?[index].url ?? "") else { return }
                // Check if it's a remote URL (http or https)
                if url.isFileURL {
                    do {
                        try audioManager.setupPlayer(with: url)
                        waveView.audioURL = url
                        self.waveView.onDurationUpdate = { [weak self] time in
                            self?.voiceTiming.text = time
                        }
                    } catch {
                        print("❌ Failed to set up audio player:", error)
                    }
                } else {
                    // Remote URL - download it first
                    downloadAndPrepareAudio(from: url)
                }
            }
        }
    }
    
    
    func voiceforword(selectedIndex: Int?) {
        voiceTitleeTxt.text = VoiceHistory?[selectedIndex ?? 0].title ?? ""
        if emengencyCall.isOn && (VoiceHistory?[selectedIndex ?? 0].duration ?? 0) >=  30{
            let alert = UIAlertController(
                title: "Oops!",
                message: "Your Emergency call is ON. You can't forward Above 30 mins voice message",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: AlertstringFile.OK, style: .default))
            self.present(alert, animated: true, completion: nil)
        }else{
            if isScheduleSelected{
                enabelScheduleView(
                    isforward: true,
                    voiceUrl:VoiceHistory?[selectedIndex ?? 0].url ?? "",
                    title: VoiceHistory?[selectedIndex ?? 0].title ?? "",
                    durations: VoiceHistory?[selectedIndex ?? 0].duration ?? 0,
                    url: VoiceHistory?[selectedIndex ?? 0].url ?? ""
                )
                guard let url = URL(string: AudioPlayUrl ?? "") else { return }
                // Check if it's a remote URL (http or https)
                if url.isFileURL {
                    do {
                        try audioManager.setupPlayer(with: url)
                        waveView.audioURL = url
                        self.waveView.onDurationUpdate = { [weak self] time in
                            self?.voiceTiming.text = time
                        }
                    } catch {
                        print("❌ Failed to set up audio player:", error)
                    }
                } else {
                    // Remote URL - download it first
                    downloadAndPrepareAudio(from: url)
                }
            }else{
                enabelVoice_view(
                    isforward: true,
                    voiceUrl:VoiceHistory?[selectedIndex ?? 0].url ?? "",
                    title: VoiceHistory?[selectedIndex ?? 0].title ?? "",
                    durations: VoiceHistory?[selectedIndex ?? 0].duration ?? 0,
                    url: VoiceHistory?[selectedIndex ?? 0].url ?? ""
                )
                
                guard let url = URL(string: AudioPlayUrl ?? "") else { return }
                // Check if it's a remote URL (http or https)
                if url.isFileURL {
                    do {
                        try audioManager.setupPlayer(with: url)
                        waveView.audioURL = url
                        waveView.updateWaveformColor(progress: 0.0)
                        self.waveView.onDurationUpdate = { [weak self] time in
                            self?.voiceTiming.text = time
                        }
                    } catch {
                        print("❌ Failed to set up audio player:", error)
                    }
                } else {
                    // Remote URL - download it first
                    downloadAndPrepareAudio(from: url)
                }
            }
        }
    }
    
    
    
    var isKeyboardVisible = false
    var selectedDates: [Date] = [] // Store selected dates
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var player : AVPlayer?
    var AudioPlayUrl: String?
    var isRecording = false
    var updateTimer: Timer?
    var recordingTimer: Timer?
    var recordingStartTime: Date?
    var bars: [UIView] = [] // Array to hold individual wave bars
    var playerItem : AVPlayerItem?
    var playIndex :Int?
    var playVoicce = false
    var timeObserver: Any?
    var isAudioRecordingGranted : Bool?
    var timePicker: UIDatePicker!
    var doneButton: UIButton!
    var activeButton: UIButton?
    var isScheduleSelected = false
    let backgroundcolor: UIColor = .backGroundClr//Colornames.topBackgroundCLr1
    let tapColor: UIColor = .backGroundClr
    var placeholderLabel: UILabel!
    let alert = CustomAlert()
    var activeField: UIView?
    
    @IBOutlet weak var textMsgVoiceCountLbl: UILabel!
    @IBOutlet weak var voiceTileTextFldCount: UILabel!
    @IBOutlet weak var acidmicYrLbl: UILabel!
    @IBOutlet weak var acidamicYrDropView: UIView!
    @IBOutlet weak var chooseAcidyrDefaultLbl: UILabel!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var TxtMsgSendBtn: UIButton!
    @IBOutlet weak var TextMsgTitleLbl: UILabel!
    @IBOutlet weak var timePickerHeight: NSLayoutConstraint!
    @IBOutlet weak var fromTime: UIButton!
    @IBOutlet weak var toTime: UIButton!
    @IBOutlet weak var waveView: AudioMessageView!
    @IBOutlet weak var tittlemessage: UILabel!
    @IBOutlet weak var emengencyCall: UISwitch!
    @IBOutlet weak var historytable: UITableView!
    @IBOutlet weak var textmessageview: UIView!
    @IBOutlet weak var historyview: UIView!
    @IBOutlet weak var voiceview: UIView!
    @IBOutlet weak var recrdimg: UIImageView!
    @IBOutlet weak var recoderbtn: UIButton!
    @IBOutlet weak var playadiuoslider: UISlider!
    @IBOutlet weak var playerview: UIView!
    @IBOutlet weak var btnplay: UIButton!
    @IBOutlet weak var dltbtn: UIButton!
    @IBOutlet weak var informationcontent: UITextView!
    @IBOutlet weak var enableVoiceHistory: UISwitch!
    @IBOutlet weak var enableVoiceHistoryLabel: UILabel!
    @IBOutlet weak var playerheight: NSLayoutConstraint!
    @IBOutlet weak var radio2: UIButton!
    @IBOutlet weak var radio1: UIButton!
    @IBOutlet weak var voiceStackview: UIStackView!
    @IBOutlet weak var addfile: UIButton!
    @IBOutlet weak var messageSendTime: UILabel!
    @IBOutlet weak var voiceTiming: UILabel!
    @IBOutlet weak var Timinglbl: UILabel!
    @IBOutlet weak var moveTextmessage: UIButton!
    @IBOutlet weak var moveVoiceMessage: UIButton!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var schedulCallView: UIView!
    @IBOutlet weak var voiceBtn: UIButton!
    @IBOutlet weak var scheduleBtn: UIButton!
    @IBOutlet weak var textBtn: UIButton!
    @IBOutlet weak var dateCV: UICollectionView!
    @IBOutlet weak var dateSelectedViewHeight: NSLayoutConstraint!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var historyBtn: UIButton!
    @IBOutlet weak var calanderOuter: UIView!
    @IBOutlet weak var DateSelection: FSCalendar!
    @IBOutlet weak var voiceTitleeTxt: UITextField!
    @IBOutlet weak var nextMontBtn: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var TxtTitle: UITextField!
    @IBOutlet weak var voiceClickView: UIView!
    @IBOutlet weak var textClickView: UIView!
    @IBOutlet weak var seduleClickView: UIView!
    @IBOutlet weak var clickVoiceLbl: UILabel!
    @IBOutlet weak var clickSchedule: UILabel!
    @IBOutlet weak var clickTextView: UILabel!
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var ScheduleLbl: UILabel!
    @IBOutlet weak var ToDateLbl: UILabel!
    @IBOutlet weak var TextMsgTittle: UITextField!
    @IBOutlet weak var TextMsgContent: UILabel!
    @IBOutlet weak var EnableCallLbl: UILabel!
    @IBOutlet weak var textViewOuter: UIView!
    @IBOutlet weak var textCountLbl: UILabel!
    @IBOutlet weak var no_recordLbl: UILabel!
    @IBOutlet weak var voiceSetTitleLbl: UILabel!
    @IBOutlet weak var recordImgHeightCon: NSLayoutConstraint!
    @IBOutlet weak var menuNameLbl: UILabel!
    @IBOutlet weak var dateBtn: UIButton!
    private let audioManager = AudioManager()
    let  staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    
    var VoiceHistory:[VoiceData]?
    var TextHistory:[TextDetail]?
    var isEmergencyVoice : Bool?
    var voiceRecordedDuration : Int?
    var ScheduleSelectedDate : [String] = []
    var AcadimicYearDatas : [AcadimicYearData] = []
    var accadimYr :[String] = []
    let acidamicdrops = DropDown()
    var  selectedAcadimicYearId: Int?
    var accadimYrIDs :[Int] = []
    var accadmicDefaultYrName : String?
    var forWardVoiceDuraction : Int?
    var Defaultdurations = "00:00/00:30"

    override func viewDidLoad() {
        super.viewDidLoad()
        acidamicYrDropView.isHidden = true
        chooseAcidyrDefaultLbl.isHidden = true
        voiceTileTextFldCount.text = "0/50"
        textMsgVoiceCountLbl.text = "0/50"
        enableVoiceHistory.isHidden = true
        enableVoiceHistoryLabel.isHidden = true
        voiceTitleeTxt.delegate = self
        TxtTitle.delegate = self
        textCountLbl.isHidden = true
        textMsgVoiceCountLbl.isHidden = true
        updateEmergencyCallVisibility( staff_role)
        applyShadowAndCornerRadius(to:acidamicYrDropView)
        sendbtn.isEnabled = true
        check_record_permission()
        printCurrentMonth()
        hideCalendarHeader()
        uiUUpdate()
        setupPlaceholder()
        setupAudioSession()
        CellRegistre()
        setupWaveBars()
        setupTimePicker()
        TxtTitle.addDoneButton()
        voiceTitleeTxt.addDoneButton()
        informationcontent.addDoneButton()
        setInitialButtonTitles()
        StyleAndTranslater()
        [voiceTitleeTxt, TxtTitle, TextMsgTittle].forEach {$0?.delegate = self}
        informationcontent.delegate = self
        if emengencyCall.isOn{
            isEmergencyVoice = true
        }
        else{
            isEmergencyVoice = false
        }
        if staff_role == "p3"{
            seduleClickView.isHidden = true
        }else{
            seduleClickView.isHidden = false
        }
    
        historytable.delegate = self
        historytable.dataSource = self
        DateSelection.delegate = self
        DateSelection.dataSource = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        EnableCallLbl.isUserInteractionEnabled = true
        let bubbleClick = UITapGestureRecognizer(target: self, action: #selector(Enabel_buble))
        EnableCallLbl.addGestureRecognizer(bubbleClick)
        waveView.setParentCell(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        playVoicce = false
    }
    func applyShadowAndCornerRadius(to view: UIView, cornerRadius: CGFloat = 10, shadowColor: UIColor = .black, shadowOffset: CGSize = CGSize(width: 4, height: 4), shadowOpacity: Float = 0.5, shadowRadius: CGFloat = 4, backgroundColor: UIColor = .white) {
        view.layer.cornerRadius = cornerRadius
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = shadowOffset
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowRadius = shadowRadius
        view.backgroundColor = backgroundColor
    }
    
    @objc func Enabel_buble() {
        AudioServicesPlaySystemSound(1004)
        let popoverVC = EmergencyInfoPopoverVCViewController()
        popoverVC.modalPresentationStyle = .popover
        if let popover = popoverVC.popoverPresentationController {
            popover.sourceView = EnableCallLbl
            popover.sourceRect = EnableCallLbl.bounds
            popover.permittedArrowDirections = .up
            popover.delegate = self
        }
        self.present(popoverVC, animated: true) {
            // Auto dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                popoverVC.dismiss(animated: true, completion: nil)
            }
        }
    }
    func updateEmergencyCallVisibility(_ staff_role: String) {
        if staff_role == PriorityType.is_admin ||
            staff_role == PriorityType.is_grouphead ||
            staff_role == PriorityType.is_principal || VoiceHistory != nil || TextHistory != nil{
            if isScheduleSelected{
                ViewAnimator.hideFade(EnableCallLbl)
                ViewAnimator.hideFade(emengencyCall)
            }else{
                if staff_role == PriorityType.is_staff{
                    ViewAnimator.hideFade(EnableCallLbl)
                    ViewAnimator.hideFade(emengencyCall)
                }else{
                    ViewAnimator.showFade(emengencyCall)
                    ViewAnimator.showFade(EnableCallLbl)
                }
            }
            staffDetails = staffDetailsCount?.first
        } else {
            ViewAnimator.hideFade(EnableCallLbl)
            ViewAnimator.hideFade(emengencyCall)
            
        }
    }
    @IBAction func switchAction(_ sender: Any) {
        if emengencyCall.isOn{
            stopRecording()
            if let url = URL(string:AudioPlayUrl ?? ""){
                deletRecoding()
            }
            isEmergencyVoice = true
            Timinglbl.text = Defaultdurations
            Enabel_buble()
        }
        else{
            isEmergencyVoice = false
            Timinglbl.text = Defaultdurations
        }
    }
    
    @IBAction func voice_sendBtn_action(_ sender: UIButton) {
        ScheduleSelectedDate.removeAll()
        for i in 0..<selectedDates.count {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let formattedDate = dateFormatter.string(from: selectedDates[i])
            ScheduleSelectedDate.append(formattedDate)
        }
        let today_date = getCurrentDateString()
        guard AudioPlayUrl != "", let voiceTitle = voiceTitleeTxt.text, !voiceTitle.isEmpty else {
            alert.showAlert(title: "", message: AlertstringFile.voice_or_title_is_required, on: self)
            return
        }
        user_inputs.voice_link = AudioPlayUrl!
        user_inputs.description = voiceTitle
        user_inputs.duration = voiceRecordedDuration ?? forWardVoiceDuraction ?? 0
        user_inputs.is_schedule = isScheduleSelected
        user_inputs.is_emergency = isEmergencyVoice ?? false
        user_inputs.file_name = "sss-" + today_date + ".mp3"
        // If emergency or not scheduling, send immediately
        if emengencyCall.isOn || !isScheduleSelected {
            user_inputs.schedule_date = [today_date]
            user_inputs.start_time = ""
            user_inputs.end_time = ""
            recienpient_validation(isVoice: true)
            return
        }
        // --- Schedule Validation ---
        guard ScheduleSelectedDate.count != 0 else {
            alert.showAlert(title: "", message: AlertstringFile.select_date, on: self)
            return
        }
        // Convert date strings
        let convertedDates = convertDateStrings(dates: ScheduleSelectedDate)
        ScheduleSelectedDate = convertedDates
        user_inputs.schedule_date = ScheduleSelectedDate
        guard let fromTimeText = fromTime.titleLabel?.text,
              let toTimeText = toTime.titleLabel?.text else {
            alert.showAlert(title: "", message: MenuStringFile.Invalid_time_selection, on: self)
            return
        }
        
        // 1️⃣ Validate To Time > From Time
        guard let sampleDate = selectedDates.first,
              let fromDateSample = combineDateAndTime(date: sampleDate, timeString: fromTimeText),
              let toDateSample = combineDateAndTime(date: sampleDate, timeString: toTimeText),
              toDateSample > fromDateSample else {
            alert.showAlert(title: "", message: MenuStringFile.End_time_must_be_greater_than_start_time, on: self)
            return
        }
        
        // 2️⃣ Validate no past times for today in *any* selected date
        let now = Date()
        let calendar = Calendar.current
        for selectedDate in selectedDates {
            if calendar.isDateInToday(selectedDate),
               let fromDate = combineDateAndTime(date: selectedDate, timeString: fromTimeText),
               fromDate < now {
                alert.showAlert(title: "", message: MenuStringFile.You_cannot_select_a_past_time_for_today_date, on: self)
                return
            }
        }
        // ✅ All good — proceed
        user_inputs.start_time = fromTimeText
        user_inputs.end_time = toTimeText
        recienpient_validation(isVoice: true)
    }
    
    
    
    @IBAction func text_sendActionBtn(_ sender: UIButton) {
        if  informationcontent.text != "" && TextMsgTittle.text != ""{
            user_inputs.description = informationcontent.text!
            user_inputs.title = TextMsgTittle.text!
            recienpient_validation(isVoice : false)
        }
        else{
            alert
                .showAlert(
                    title: "",
                    message: AlertstringFile.enter_title_description,
                    on: self)}
    }
    
    func recienpient_validation(isVoice : Bool){
        if(staffDetailsCount?.count ?? 0 > 1){
            if(isVoice == true){
                if(staff_role == PriorityType.is_principal || staff_role == PriorityType
                    .is_grouphead || staff_role == PriorityType.is_admin){
                    if #available(iOS 14.0, *) {
                        let vc = SchoolListVC(nibName: nil, bundle: nil)
                        if(isEmergencyVoice == true){
                            vc.screen_type = screenType.is_emergencyvoice
                        }else{
                            vc.screen_type = screenType.non_emergencyvoice
                        }
                        vc.modalPresentationStyle = .fullScreen
                        present(vc, animated: true)
                    }
                }
                else{
                    let vc = RecipientVc(nibName: nil, bundle: nil)
                    if(isEmergencyVoice == true){
                        vc.ScreenType = screenType.is_emergencyvoice
                    }else{
                        vc.ScreenType = screenType.non_emergencyvoice
                    }
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
            }
            else{
                if(staff_role == PriorityType.is_principal || staff_role == PriorityType
                    .is_grouphead || staff_role == PriorityType.is_admin){
                    if #available(iOS 14.0, *) {
                        let vc = SchoolListVC(nibName: nil, bundle: nil)
                        vc.screen_type = screenType.communication_text
                        vc.modalPresentationStyle = .fullScreen
                        present(vc, animated: true)
                    }
                }
                
                else{
                    let vc = RecipientVc(nibName: nil, bundle: nil)
                    vc.ScreenType = screenType.communication_text
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                }
            }
            
        }
        else{
            
            if(isVoice == true){
                let vc = RecipientVc(nibName: nil, bundle: nil)
                if(isEmergencyVoice == true){
                    vc.ScreenType = screenType.is_emergencyvoice
                }else{
                    vc.ScreenType = screenType.non_emergencyvoice
                }
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
                
            }
            else{
                let vc = RecipientVc(nibName: nil, bundle: nil)
                vc.ScreenType = screenType.communication_text
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
        }
        
        
    }
    func combineDateAndTime(date: Date, timeString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // match your button format (e.g. "2:30 PM")
        if let timeDate = dateFormatter.date(from: timeString) {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)
            var combinedComponents = DateComponents()
            combinedComponents.year = dateComponents.year
            combinedComponents.month = dateComponents.month
            combinedComponents.day = dateComponents.day
            combinedComponents.hour = timeComponents.hour
            combinedComponents.minute = timeComponents.minute
            
            return calendar.date(from: combinedComponents)
        }
        return nil
    }
    func StyleAndTranslater() {
        //MARK: Translate
        fromDateLbl.text = CommonStringFile.FromTime.translated()
        ScheduleLbl.text = CommonStringFile.Schedule.translated()
        ToDateLbl.text = CommonStringFile.ToTime.translated()
        EnableCallLbl.text = CommonStringFile.Emergencyvoicemessages.translated()
        clickVoiceLbl.text = CommonStringFile.VoiceMessage.translated()
        clickTextView.text = CommonStringFile.TextMessage.translated()
        clickSchedule.text = CommonStringFile.ScheduleCall.translated()
        menuNameLbl.text = MenuStringFile.selectedMenuName
        //MARK: Label font style
        menuNameLbl.setFont(style: .header, size: FontSize.HeaderSize)
        tittlemessage.setFont(style: .title, size: FontSize.TitleSize)
        voiceSetTitleLbl.setRequiredText(CommonStringFile.Title)
        ScheduleLbl.setRequiredText(ScheduleLbl.text ?? "")
        fromDateLbl.setRequiredText(fromDateLbl.text ?? "")
        ToDateLbl.setRequiredText(ToDateLbl.text ?? "")
        messageSendTime.setFont(style: .body, size: FontSize.BodySize)
        voiceTiming.setFont(style: .body, size: FontSize.BodySize)
        Timinglbl.setFont(style: .body, size: FontSize.BodySize)
        clickVoiceLbl.setFont(style: .title, size: FontSize.TitleSize)
        clickSchedule.setFont(style: .title, size: FontSize.TitleSize)
        clickTextView.setFont(style: .title, size: FontSize.TitleSize)
        ScheduleLbl.setFont(style: .title, size: FontSize.BodySize)
        fromDateLbl.setFont(style: .title, size: FontSize.BodySize)
        ToDateLbl.setFont(style: .title, size: FontSize.BodySize)
        EnableCallLbl.setFont(style: .title, size: FontSize.TitleSize)
        TextMsgTitleLbl.setRequiredText(CommonStringFile.Title)
        TextMsgContent.setRequiredText(CommonStringFile.Description)
        textCountLbl.setFont(style: .body, size: FontSize.BodySize)
        textMsgVoiceCountLbl.setFont(style: .body, size: FontSize.BodySize)
        
        //MARK: Button Title font style
        fromTime.setTitleFont(style: .body, size: FontSize.BodySize)
        toTime.setTitleFont(style: .body, size: FontSize.BodySize)
        recoderbtn.setTitleFont(style: .body, size: FontSize.BodySize)
        btnplay.setTitleFont(style: .body, size: FontSize.BodySize)
        dltbtn.setTitleFont(style: .body, size: FontSize.BodySize)
        addfile.setTitleFont(style: .body, size: FontSize.BodySize)
        sendbtn.setTitleFont(style: .body, size: FontSize.BodySize)
        scheduleBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        textBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        doneBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        historyBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        nextMontBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        radio1.setTitleFont(style: .body, size: FontSize.BodySize)
        radio2.setTitleFont(style: .body, size: FontSize.BodySize)
        moveTextmessage.setTitleFont(style: .body, size: FontSize.BodySize)
        moveVoiceMessage.setTitleFont(style: .body, size: FontSize.BodySize)
        voiceBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        scheduleBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        TxtMsgSendBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        BackBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        
    }
    func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.text =  CommonStringFile.Description.translated()
        placeholderLabel.font = informationcontent.font
        placeholderLabel.textColor = .lightGray
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin = CGPoint(x: 5, y: 8) // Adjust padding
        TextMsgTittle.applyRightTxt()
        TxtTitle.applyRightTxt()
        TextMsgTitleLbl.applyRightTxt()
        voiceSetTitleLbl.applyRightTxt()
        voiceTitleeTxt.applyRightTxt()
        TextMsgContent.applyRightTxt()
        informationcontent.applyRightTxt()
        informationcontent.applyRightTxt(with: placeholderLabel)
        informationcontent.addSubview(placeholderLabel)
        placeholderLabel.isHidden = !informationcontent.text.isEmpty // Hide if text exists
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        guard let activeField = activeField else { return }
        let keyboardTop = view.frame.height - keyboardFrame.height
        let activeFieldBottom = activeField.convert(activeField.bounds, to: view).maxY
        if activeFieldBottom > keyboardTop {
            let offset = activeFieldBottom - keyboardTop + 16 // 16pt padding
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -offset)
            }
            isKeyboardVisible = true
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = .identity
        }
        isKeyboardVisible = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func uiUUpdate(){
        emengencyCall.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        moveTextmessage.applyRightButton()
        historyBtn.applyBackButton()
        moveVoiceMessage.applyRightButton()
        BackBtn.applyBackButton()
        toTime.applyRightButton()
        fromTime.applyRightButton()
        //MARK: FSCalander View
        Timinglbl.text = "00:00/03:00"
        calanderOuter.isHidden = true
        calanderOuter.layer.cornerRadius = 20
        calanderOuter.layer.shadowColor = UIColor.black.cgColor
        calanderOuter.layer.shadowOffset = CGSize(width: 0, height: 2)
        calanderOuter.layer.shadowRadius = 5
        calanderOuter.layer.shadowOpacity = 0.3
        DateSelection.appearance.weekdayTextColor = .red
        DateSelection.appearance.todayColor = .orange
        DateSelection.appearance.eventDefaultColor = .purple
        DateSelection.allowsMultipleSelection = true
        DateSelection.scrollEnabled = false
        DateSelection.placeholderType = .none
        DateSelection.setCurrentPage(Date(), animated: false)
        //MARK: VOICE BUTTON BACKGROUND
        voiceBtn.backgroundColor = .white
        voiceClickView.layer.cornerRadius = 8
        textClickView.layer.cornerRadius = 8
        seduleClickView.layer.cornerRadius = 8
        voiceClickView.layer.cornerRadius = 8
        voiceClickView.backgroundColor = tapColor
        voiceBtn.layer.cornerRadius = 20
        voiceBtn.layer.shadowColor = UIColor.black.cgColor
        voiceBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        voiceBtn.layer.shadowRadius = 5
        voiceBtn.layer.shadowOpacity = 0.3
        voiceBtn.tintColor = .white
        clickVoiceLbl.textColor = .white
        voiceBtn.backgroundColor = backgroundcolor
        
        //MARK: TEXT BUTTON BACKGROUND
        textBtn.layer.cornerRadius = 20
        textBtn.layer.shadowColor = UIColor.black.cgColor
        textBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        textBtn.layer.shadowRadius = 5
        textBtn.layer.shadowOpacity = 0.3
        
        //MARK: SCHEDULE BUTTON BACKGROUND
        scheduleBtn.layer.cornerRadius = 20
        scheduleBtn.layer.shadowColor = UIColor.black.cgColor
        scheduleBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        scheduleBtn.layer.shadowRadius = 5
        scheduleBtn.layer.shadowOpacity = 0.3
        schedulCallView.isHidden = true
        timePickerHeight.constant = 0
        
        //MARK: FROM TIME BUTTON BACKGROUND
        fromTime.layer.cornerRadius = 4
        fromTime.layer.shadowColor = UIColor.black.cgColor
        fromTime.layer.shadowOffset = CGSize(width: 0, height: 2)
        fromTime.layer.shadowRadius = 5
        fromTime.layer.shadowOpacity = 0.3
        fromTime.layer.cornerRadius = 8
        
        //MARK: TO TIME BUTTON BACKGROUND
        toTime.layer.cornerRadius = 4
        toTime.layer.shadowColor = UIColor.black.cgColor
        toTime.layer.shadowOffset = CGSize(width: 0, height: 2)
        toTime.layer.shadowRadius = 5
        toTime.layer.shadowOpacity = 0.3
        toTime.layer.cornerRadius = 8
        
        //MARK: TO TIME BUTTON BACKGROUND
        sendbtn.layer.shadowColor = UIColor.black.cgColor
        sendbtn.layer.shadowOffset = CGSize(width: 0, height: 2)
        sendbtn.layer.shadowRadius = 5
        sendbtn.layer.shadowOpacity = 0.3
        sendbtn.layer.cornerRadius = 8
        
        //MARK: AUDIO PLAY VIEW BACKGROUND
        playerheight.constant = 0
        playadiuoslider.value = 0
        playerview.layer.shadowColor = UIColor.black.cgColor
        playerview.layer.shadowOffset = CGSize(width: 0, height: 2)
        playerview.layer.shadowRadius = 5
        playerview.layer.shadowOpacity = 0.3
        playerview.layer.cornerRadius = 8
        voiceStackview.isHidden = true
        dltbtn.isHidden = true
        informationcontent.delegate = self
        textViewOuter.layer.cornerRadius = 10
        textViewOuter.layer.borderWidth = 1
        textViewOuter.layer.borderColor = UIColor.black.cgColor
        emengencyCall.isOn = false
        addfile.layer.cornerRadius = 4
        dateSelectedViewHeight.constant = 0
        doneBtn.layer.cornerRadius = 8
        
        let title = CommonStringFile.Select_from_history
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        moveTextmessage.setAttributedTitle(attributedTitle, for: .normal)
        moveVoiceMessage.setAttributedTitle(attributedTitle, for: .normal)
        
        updatePlayButtonState(isPlaying: false)
    }
    
    //MARK: CELL REGISTRATION
    func CellRegistre(){
        historytable.register(UINib(nibName: "CommunicationTVC", bundle: nil), forCellReuseIdentifier: "CommunicationTVC")
        historytable.register(UINib(nibName: CellConfingName.TextHistoryTVCell, bundle: nil), forCellReuseIdentifier: CellConfingName.TextHistoryTVCell)
        dateCV.register(UINib(nibName: CellConfingName.DateCVC, bundle: nil), forCellWithReuseIdentifier: CellConfingName.DateCVC)
        
    }
    
    //MARK: BUTTON TITLE CURRANT TIME
    private func setInitialButtonTitles() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        // Set initial times
        let initialFromTime = Date() // Current time for example
        let initialToTime = Calendar.current.date(byAdding: .minute, value: 40, to: initialFromTime) ?? Date()
        fromTime.setTitle(formatter.string(from: initialFromTime), for: .normal)
        toTime.setTitle(formatter.string(from: initialToTime), for: .normal)
    }
    
    //MARK: PERMISSION CHECKING
    func check_record_permission()
    {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSession.RecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSession.RecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }
    
    
    //MARK: GET FILE URL
    func getFileUrl(for filename: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent(filename)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func deleteFile(at url: URL) {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
            }
        } else {
            print("⚠️ File does not exist at path: \(url.path)")
        }
    }
    
    func getFileUrl() -> URL {
        let filename = "RecordedAudio.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        if FileManager.default.fileExists(atPath: filePath.path) {
            try? FileManager.default.removeItem(at: filePath)
        }
        AudioPlayUrl = filePath.absoluteString
        return filePath
    }
    
    //MARK: Setup Audio Session
    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .allowBluetooth)
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    //MARK: SETUP RECORDER
    func setupRecorder() {
        if isAudioRecordingGranted ?? true {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
                try session.setActive(true)
                
                let settings: [String: Any] = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
                let fileURL = getFileUrl()
                audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
                audioRecorder?.delegate = self
                audioRecorder?.isMeteringEnabled = true
                audioRecorder?.record(forDuration: 180.00) // record for 3 minutes
                audioRecorder?.prepareToRecord()
            } catch {
                print("Error setting up recorder: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: DOCUMENT PICKER
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            print("No file selected.")
            return
        }
        // Access the file securely if necessary
        if selectedFileURL.startAccessingSecurityScopedResource() {
            defer { selectedFileURL.stopAccessingSecurityScopedResource() }
            do {
                // Get the audio duration
                let asset = AVAsset(url: selectedFileURL)
                let duration = CMTimeGetSeconds(asset.duration)
                guard duration.isFinite else { return }
                // ✅ Check if the audio is more than 30 seconds
                voiceRecordedDuration = Int(duration)
                if emengencyCall.isOn{
                    if duration > 30 {
                        alert
                            .showAlert(
                                title: AlertstringFile.Alert_title,
                                message: AlertstringFile.Audio_file_should80,
                                on: self)
                        return
                    }
                }else{
                    if duration > 180 {
                        alert
                            .showAlert(
                                title: AlertstringFile.Alert_title,
                                message: AlertstringFile.Audio_file_should180,
                                on: self
                            )
                        return
                    }
                }
                // Proceed if valid duration
                recordImgHeightCon.constant = 0
                Timinglbl.isHidden = true
                addfile.isHidden = true
                setupRecorder()
                btnplay.setImage(ImageName.playbutton, for: .normal)
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                messageSendTime.text = "\(formatter.string(from: Date()))"
                let destinationURL = getFileUrl(for: selectedFileURL.lastPathComponent)
                if !FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.copyItem(at: selectedFileURL, to: destinationURL)
                }
                AudioPlayUrl = destinationURL.absoluteString
                if let filePath = AudioPlayUrl,
                   let durationStr = getAudioDuration(from: filePath) {
                    voiceTiming.text = durationStr
                }
                playerheight.constant = 60
                voiceStackview.isHidden = false
                dltbtn.isHidden = false
                recoderbtn.isEnabled = false
                if let audioUrl = URL(string: AudioPlayUrl ?? "") {
                    playerItem = AVPlayerItem(url: audioUrl)
                    player = AVPlayer(playerItem: playerItem)
                }
                
            } catch {
                print("Error copying file: \(error.localizedDescription)")
            }
        } else {
            print("Failed to access security scoped resource.")
        }
    }
    
    
    
    func getAudioDuration(from filePath: String) -> String? {
        let fileURL = URL(fileURLWithPath: filePath)
        let asset = AVAsset(url: fileURL)
        let duration = asset.duration
        let durationInSeconds = CMTimeGetSeconds(duration)
        guard durationInSeconds.isFinite else { return nil }
        let minutes = Int(durationInSeconds) / 60
        let seconds = Int(durationInSeconds) % 60
        return String(format: CommonStringFile.Time_formate, minutes, seconds) // e.g., "01:27"
    }
    
    // Handle cancellation
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
    
    //MARK: PLAY AUDIO
    func playAudio() {
        if let audioUrlString = AudioPlayUrl, let audioUrl = URL(string: audioUrlString) {
            playerItem = AVPlayerItem(url: audioUrl)
            player = AVPlayer(playerItem: playerItem)
            player?.play()
        }
    }
    //MARK: VOICE MESSAGE VIEW
    func showVoiceMessageView() {
        ViewAnimator.showFade(voiceview)
        ViewAnimator.hideFade(textmessageview)
        ViewAnimator.hideFade(historyview)
        tittlemessage.text = CommonStringFile.VoiceMessage.translated()
    }
    
    //MARK: HISTORY VIEW
    func showHistoryView() {
        ViewAnimator.showFade(historyview)
        ViewAnimator.hideFade(voiceview)
        ViewAnimator.hideFade(textmessageview)
        recrdimg.image = ImageName.mic1
        audioRecorder?.stop()
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        deletRecoding()
        ViewAnimator.animateConstraintChange { [self] in
            playerheight.constant = 0
            self.view.layoutIfNeeded()
        }
        radio1.setImage(ImageName.circle, for: .normal)
        ViewAnimator.hideFade(calanderOuter)
        
        let isTextMode = tittlemessage.text == CommonStringFile.TextMessage.translated()
        let title = isTextMode ? CommonStringFile.BacktoTextMessage.translated() : CommonStringFile.BackToVoiceMessage.translated()
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        historyBtn.setAttributedTitle(attributedTitle, for: .normal)
        if isTextMode {
            get_Text_History()
        } else {
            updateEmergencyCallVisibility(staff_role)
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
                        DispatchQueue.main.async { [self] in
                            no_recordLbl.isHidden = true
                            VoiceHistory = succesmessage.data
                            historytable.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            VoiceHistory = []
                            no_recordLbl.isHidden = false
                            no_recordLbl.text = succesmessage.message
                            historytable.reloadData()
                        }
                    }
                case.failure(let error) :
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                    }
                }
            }
    }
    func get_Text_History(){
        APIService.shared
            .makeApi(url:  ServiceUrl.comm_text_message_get_text_history, parameters: [:] , type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "", isBaseUrl: false){ [self] (
                result : Result<TextDetailsResponse,
                Error>
            ) in switch result {
            case.success(let succesmessage) :
                if succesmessage.status == true {
                    DispatchQueue.main.async { [self] in
                        no_recordLbl.isHidden = true
                        TextHistory = succesmessage.data
                        historytable.reloadData()
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        TextHistory = []
                        no_recordLbl.isHidden = false
                        no_recordLbl.text = succesmessage.message
                        historytable.reloadData()
                    }
                }
            case.failure(let error) :
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
            }
    }
    //MARK: DELETE RECORDING
    func deletRecoding(){
        recoderbtn.isEnabled = true
        dltbtn.isHidden = true
        voiceStackview.isHidden = true
        addfile.isHidden = false
        recordImgHeightCon.constant = 80
        Timinglbl.isHidden = false
        player?.pause()
        AudioPlayUrl = ""
        stopPlayback()
        playerheight.constant = 0
        if emengencyCall.isOn{
            Timinglbl.text = Defaultdurations
        }else{
            Timinglbl.text = Defaultdurations
        }
        moveTextmessage.isHidden = false
        voiceTitleeTxt.text = ""
    }
    
    func startRecording() {
        player?.pause()
        playVoicce = false
        btnplay.setImage(ImageName.playbutton, for: .normal)
        addfile.isHidden = true
        sendbtn.isUserInteractionEnabled = false
        recrdimg.image = UIImage.gifImageWithName("Mic")
        isRecording = true
        recordingStartTime = Date()
        setupRecorder()
        UIApplication.shared.isIdleTimerDisabled = true
        audioRecorder?.record()
        recordingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRecordingTime), userInfo: nil, repeats: true)
        voiceStackview.isHidden = true
        playerheight.constant = 0
        dltbtn.isHidden = true
    }
    
    func stopRecording() {
        UIApplication.shared.isIdleTimerDisabled = false
        recrdimg.image = ImageName.mic1
        sendbtn.isUserInteractionEnabled = true
        audioRecorder?.stop()
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        btnplay.setImage(ImageName.playbutton, for: .normal)
        if let urls = URL(string: AudioPlayUrl ?? ""){
            // Calculate total recording duration and set Timinglbl
            if let startTime = recordingStartTime {
                let duration = Date().timeIntervalSince(startTime)
                let minutes = Int(duration) / 60
                let seconds = Int(duration) % 60
                voiceTiming.text = String(format: CommonStringFile.Time_formate, minutes, seconds)
                let durationString =  voiceTiming.text ?? ""
                let totalSeconds = convertTimeStringToSeconds(durationString)
                voiceRecordedDuration = totalSeconds
                
            }
            // Set message send time
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            messageSendTime.text = "\(formatter.string(from: Date()))"
            playerheight.constant = voiceTiming.text == "00:00" ? 0:60
            voiceStackview.isHidden = voiceTiming.text == "00:00" ? true:false
            dltbtn.isHidden = voiceTiming.text == "00:00" ? true:false
            sendbtn.isEnabled = voiceTiming.text == "00:00" ? false:true
            addfile.isHidden = voiceTiming.text == "00:00" ? false:true
            voiceTileTextFldCount.isHidden = true
            
        }
        
        guard let url = URL(string: AudioPlayUrl ?? "") else { return }
        // Check if it's a remote URL (http or https)
        if url.isFileURL {
            do {
                try audioManager.setupPlayer(with: url)
                waveView.durationLabel.isHidden = true
                waveView.audioURL = url
                waveView.updateWaveformColor(progress: 0.0)
            } catch {
                print("❌ Failed to set up audio player:", error)
            }
        } else {
            // Remote URL - download it first
            waveView.durationLabel.isHidden = true
            downloadAndPrepareAudio(from: url)
        }
    }
  
    //MARK: TIME PICKER
    func showTimePicker(for button: UIButton) {
        activeButton = button
        let buttonFrame = button.convert(button.bounds, to: self.view)
        timePicker.frame = CGRect(x: (self.view.frame.width - 250) / 2, y: buttonFrame.maxY + 10, width: 250, height: 200)
        doneButton.frame = CGRect(x: timePicker.frame.maxX - 80, y: timePicker.frame.maxY - 40, width: 70, height: 30)
        timePicker.backgroundColor = .white
        timePicker.layer.cornerRadius = 20
        timePicker.layer.shadowColor = UIColor.black.cgColor
        timePicker.layer.shadowOffset = CGSize(width: 0, height: 2)
        timePicker.layer.shadowRadius = 5
        timePicker.layer.shadowOpacity = 0.3
        
        timePicker.fadeAndPopIn()
        doneButton.fadeAndPopIn()
    }
    
    
    //MARK: UPDATE RECORDING UPDATE DURATION
    @objc func updateRecordingTime() {
        if let startTime = recordingStartTime {
            let elapsed = Date().timeIntervalSince(startTime)
            if emengencyCall.isOn {
                if elapsed >= 30 {
                    stopRecording()
                    Timinglbl.text = "00:30"
                } else {
                    let minutes = Int(elapsed) / 60
                    let seconds = Int(elapsed) % 60
                    Timinglbl.text = String(format: CommonStringFile.Time_formate, minutes, seconds)
                }
            }else{
                if elapsed >= 180 {
                    stopRecording()
                    Timinglbl.text = "03:00"
                } else {
                    let minutes = Int(elapsed) / 60
                    let seconds = Int(elapsed) % 60
                    Timinglbl.text = String(format: CommonStringFile.Time_formate, minutes, seconds)
                }
            }
            
        }
    }
    
   
    
    func setupWaveBars() {
        // Define the width and spacing of each bar
        let barWidth: CGFloat = 6
        let barSpacing: CGFloat = 2
        let numberOfBars = Int(waveView.frame.width / (barWidth + barSpacing))
        
        // Remove existing bars if any
        bars.forEach { $0.removeFromSuperview() }
        bars.removeAll()
        
        // Create and add bars to the wave view
        for i in 0..<numberOfBars {
            let bar = UIView()
            bar.frame = CGRect(x: CGFloat(i) * (barWidth + barSpacing), y: waveView.frame.height / 2, width: barWidth, height: 0)
            bar.backgroundColor = .blue
            waveView.addSubview(bar)
            bars.append(bar)
        }
    }
   
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: CommonStringFile.Time_formate, minutes, seconds)
    }
    
    @IBAction func previousMont(_ sender: UIButton) {
        let currentPage = DateSelection.currentPage
        if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentPage) {
            DateSelection.setCurrentPage(previousMonth, animated: true)
        }
    }
    
    @IBAction func nextMont(_ sender: UIButton) {
        let currentPage = DateSelection.currentPage
        if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentPage) {
            DateSelection.setCurrentPage(nextMonth, animated: true)
        }
    }
    
    
    @IBAction func backToHome(_ sender: UIButton) {
        playbackOff()
        if tittlemessage.text == CommonStringFile.TextMessage.translated(){
            showTextMessageView(isforwardtext: false)
            
        }else{
            showVoiceMessageView()
        }
    }
    
    @IBAction func timeChanged(_ sender: UIButton) {
        showTimePicker(for: sender)
        
    }
    @IBAction func fromTime(_ sender: UIButton) {
        showTimePicker(for: sender)
    }
    
    @IBAction func voiceview(_ sender: Any) {
        playbackOff()
        let title = CommonStringFile.Select_from_history
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        moveTextmessage.setAttributedTitle(attributedTitle, for: .normal)
        moveVoiceMessage.setAttributedTitle(attributedTitle, for: .normal)
        enabelVoice_view(isforward: false,voiceUrl: "",title: "",durations: 0, url: "")
    }
    
    func playbackOff(){
        if let currentIndex = playIndex{
            let previousIndexPath = IndexPath(row: currentIndex, section: 0)
            if let previousCell = historytable.cellForRow(at: previousIndexPath) as? HistoryTC {
                previousCell.updatePlayState(isPlaying: false, url: nil)
                previousCell.player = nil
                playIndex = nil
                
            }
        }
    }
    
    @IBAction func doneSelection(_ sender: Any) {
        ViewAnimator.animateConstraintChange { [self] in
            reloadCollectionAndUpdateHeight()
        }
        dateBtn.isSelected = false
        ViewAnimator.hideFade(calanderOuter)
    }
    
    @IBAction func history(_ sender: UIButton) {
        showHistoryView()
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func calander(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            ViewAnimator.showFade(calanderOuter)
        } else {
            ViewAnimator.hideFade(calanderOuter)
        }
    }
    @IBAction func textviewshow(_ sender: Any) {
        playbackOff()
        let title = CommonStringFile.Select_from_history
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        moveTextmessage.setAttributedTitle(attributedTitle, for: .normal)
        moveVoiceMessage.setAttributedTitle(attributedTitle, for: .normal)
        recrdimg.image = ImageName.mic1
        audioRecorder?.stop()
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        deletRecoding()
        voiceTiming.text  = "00:00 / 03:00"
        emengencyCall.isOn = false
        updateEmergencyCallVisibility( staff_role)
        showTextMessageView(isforwardtext: false)
        deletRecoding()
    }
    
    @IBAction func scheduleCall(_ sender: UIButton) {
        for i in 0..<selectedDates.count {
            DateSelection.deselect(selectedDates[i])
        }
        DateSelection.reloadData()
        playbackOff()
        selectedDates.removeAll()
        let title = CommonStringFile.Select_from_history
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        moveTextmessage.setAttributedTitle(attributedTitle, for: .normal)
        moveVoiceMessage.setAttributedTitle(attributedTitle, for: .normal)
        enabelScheduleView(
            isforward: false,
            voiceUrl: "",
            title: "",
            durations: 0, url: ""
        )
    }
    
    //MARK: TEXT MESSAGE VIEW
    func showTextMessageView(isforwardtext: Bool) {
        if !isforwardtext {
            informationcontent.text = ""
            TextMsgTittle.text = ""
            textCountLbl.text = "0 / 500"
            textMsgVoiceCountLbl.text = "0 / 50"
        }
        ViewAnimator.hideFade(calanderOuter)
        ViewAnimator.hideFade(timePicker)
        ViewAnimator.hideFade(doneButton)
        activeButton = nil
        textBtn.backgroundColor = backgroundcolor
        textBtn.tintColor = .white
        scheduleBtn.tintColor = .black
        textClickView.backgroundColor = tapColor
        voiceClickView.backgroundColor = .white
        seduleClickView.backgroundColor = .white
        clickTextView.textColor = .white
        clickSchedule.textColor = .black
        clickVoiceLbl.textColor = .black
        voiceBtn.tintColor = .black
        voiceBtn.backgroundColor = .white
        ViewAnimator.hideFade(historyview)
        ViewAnimator.showFade(textmessageview)
        ViewAnimator.hideFade(voiceview)
        tittlemessage.text = CommonStringFile.TextMessage.translated()
        scheduleBtn.backgroundColor = .white
        isScheduleSelected = false
        ViewAnimator.hideFade(schedulCallView)
        ViewAnimator.animateConstraintChange { [self] in
            timePickerHeight.constant = 0
            dateSelectedViewHeight.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    func enabelVoice_view(isforward: Bool, voiceUrl: String, title: String, durations: Int,url: String) {
        isScheduleSelected = false
        updateEmergencyCallVisibility(staff_role)
        
        if isforward {
            recordImgHeightCon.constant = 0
            Timinglbl.isHidden = true
            addfile.isHidden = true
            btnplay.setImage(ImageName.playbutton, for: .normal)
            AudioPlayUrl = url
            let formatted = formatDuration(durations)
            voiceTiming.text = "00:00 / \(formatted)"
            forWardVoiceDuraction = durations
            AudioPlayUrl = voiceUrl
            voiceTileTextFldCount.isHidden = true
            ViewAnimator.animateConstraintChange { [self] in
                playerheight.constant = 60
                self.view.layoutIfNeeded()
            }
            ViewAnimator.showFade(voiceStackview)
            ViewAnimator.showFade(dltbtn)
            recoderbtn.isEnabled = false
            
            if let audioUrl = URL(string: voiceUrl) {
                playerItem = AVPlayerItem(url: audioUrl)
                player = AVPlayer(playerItem: playerItem)
            }
            
            voiceTitleeTxt.text = title
        } else {
            recordImgHeightCon.constant = 80
            Timinglbl.isHidden = false
            recrdimg.image = ImageName.mic1
            audioRecorder?.stop()
            isRecording = false
            recordingTimer?.invalidate()
            recordingTimer = nil
            deletRecoding()
            voiceTiming.text = "00:00 / 03:00"
            voiceTitleeTxt.text = title
        }
        
        voiceBtn.backgroundColor = backgroundcolor
        textClickView.backgroundColor = .white
        voiceClickView.backgroundColor = tapColor
        seduleClickView.backgroundColor = .white
        textBtn.backgroundColor = .white
        
        ViewAnimator.showFade(voiceview)
        ViewAnimator.hideFade(textmessageview)
        ViewAnimator.hideFade(historyview)
        
        tittlemessage.text = CommonStringFile.VoiceMessage.translated()
        clickVoiceLbl.textColor = .white
        clickTextView.textColor = .black
        clickSchedule.textColor = .black
        scheduleBtn.tintColor = .black
        voiceBtn.tintColor = .white
        textBtn.tintColor = .black
        scheduleBtn.backgroundColor = .white
        
        ViewAnimator.hideFade(schedulCallView)
        ViewAnimator.hideFade(timePicker)
        ViewAnimator.hideFade(doneButton)
        ViewAnimator.hideFade(calanderOuter)
        
        ViewAnimator.animateConstraintChange { [self] in
            timePickerHeight.constant = 0
            dateSelectedViewHeight.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func enabelScheduleView(
        isforward: Bool,
        voiceUrl: String,
        title: String,
        durations: Int,
        url: String){
            
            emengencyCall.isOn = false
            if isforward {
                recordImgHeightCon.constant = 0
                btnplay.setImage(ImageName.playbutton, for: .normal)
                Timinglbl.isHidden = true
                addfile.isHidden = true
                AudioPlayUrl = url
                voiceTileTextFldCount.isHidden = true
                let formatted = formatDuration(durations)
                voiceTiming.text = "00:00 / \(formatted)"
                AudioPlayUrl = voiceUrl
                forWardVoiceDuraction = durations
                ViewAnimator.animateConstraintChange { [self] in
                    playerheight.constant = 60
                    self.view.layoutIfNeeded()
                }
                ViewAnimator.showFade(voiceStackview)
                ViewAnimator.showFade(dltbtn)
                recoderbtn.isEnabled = false
                if let audioUrl = URL(string: voiceUrl) {
                    playerItem = AVPlayerItem(url: audioUrl)
                    player = AVPlayer(playerItem: playerItem)
                }
            } else {
                recordImgHeightCon.constant = 80
                Timinglbl.isHidden = false
                recrdimg.image = ImageName.mic1
                audioRecorder?.stop()
                isRecording = false
                recordingTimer?.invalidate()
                recordingTimer = nil
                deletRecoding()
                voiceTiming.text = "00:00 / 03:00"
            }
            
            isScheduleSelected = true
            updateEmergencyCallVisibility(staff_role)
            scheduleBtn.backgroundColor = backgroundcolor
            textClickView.backgroundColor = .white
            voiceClickView.backgroundColor = .white
            seduleClickView.backgroundColor = tapColor
            showVoiceMessageView()
            ViewAnimator.showFade(schedulCallView)
            ViewAnimator.hideFade(textmessageview)
            ViewAnimator.animateConstraintChange { [self] in
                timePickerHeight.constant = 141
                self.view.layoutIfNeeded()
            }
            textBtn.backgroundColor = .white
            voiceBtn.backgroundColor = .white
            tittlemessage.text = CommonStringFile.ScheduleCall.translated()
            clickVoiceLbl.textColor = .black
            clickTextView.textColor = .black
            clickSchedule.textColor = .white
            voiceBtn.tintColor = .white
            textBtn.tintColor = .black
            scheduleBtn.tintColor = .white
            voiceBtn.tintColor = .black
            ViewAnimator.hideFade(emengencyCall)
            ViewAnimator.hideFade(EnableCallLbl)
        }
    
    // Record Button Action
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        
        if isRecording {
            stopRecording()
        } else {
            if isAudioRecordingGranted == true{
                startRecording()
            }else{
                let alert = UIAlertController(title: "Error", message: "Please allow microphone usage from settings", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Open settings", style: .default, handler: { action in
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
            
            
        }
    }
    
    @IBAction func enableHistoryEmergency(_ sender: UISwitch) {
        
    }
    
    @IBAction func addFileAction(_ sender: Any) {
        if #available(iOS 14.0, *) {
            let supportedTypes: [UTType] = [.audio]
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            present(documentPicker, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func deleteVoicemsg(_ sender: UIButton) {
        if let url = URL(string:AudioPlayUrl ?? ""){
            deletRecoding()
        }
    }
    

    // Play Button Action
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if waveView.isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    
    func stopPlayback() {
        audioManager.stop()
        waveView.isPlaying = false
        waveView.stopPlaybackAnimation()
        updatePlayButtonState(isPlaying: false)
//        audioDelegate?.audioCell(self, didStopPlayingAtIndex: cellIndex)
    }
    
    private func prepareLocalAudio(url: URL) {
        do {
            try audioManager.setupPlayer(with: url)
            waveView.audioURL = url
        } catch {
            print("❌ Failed to set up audio player:", error)
            showErrorAlert(message: "Failed to load audio file")
        }
    }
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(otherAudioStartedPlaying(_:)),
            name: NSNotification.Name("AudioCellStartedPlaying"),
            object: nil
        )
    }
    
    @objc private func otherAudioStartedPlaying(_ notification: Notification) {
        guard let playingCellIndex = notification.object as? Int,
              playingCellIndex != 0 else { return }
        stopPlayback()
    }
    
    private func downloadAndPrepareAudio(from remoteURL: URL) {
        // Show loading state
        btnplay.isEnabled = false
        
        let session = URLSession.shared
        let task = session.downloadTask(with: remoteURL) { [weak self] (tempURL, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.btnplay.isEnabled = true
                    self.showErrorAlert(message: "Audio download failed.")
                }
                return
            }
            
            guard let tempURL = tempURL else {
                DispatchQueue.main.async {
                    self.btnplay.isEnabled = true
                    self.showErrorAlert(message: "Audio download failed.")
                }
                return
            }
            
            // Save to permanent location
            let permanentURL = self.saveToPermanentLocation(tempURL: tempURL, originalURL: remoteURL)
            
            DispatchQueue.main.async {
                self.btnplay.isEnabled = true
                if let url = permanentURL {
                    self.waveView.audioURL = url
                    self.waveView.updateWaveformColor(progress: 0.0)
                    self.waveView.onDurationUpdate = { [weak self] time in
                        self?.voiceTiming.text = time
                    }
                } else {
                    self.showErrorAlert(message: "Failed to save audio file")
                }
            }
        }
        task.resume()
    }
    
    private func saveToPermanentLocation(tempURL: URL, originalURL: URL) -> URL? {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFolderPath = documentsPath.appendingPathComponent("AudioFiles", isDirectory: true)
        
        // Create directory if needed
        if !fileManager.fileExists(atPath: audioFolderPath.path) {
            try? fileManager.createDirectory(at: audioFolderPath, withIntermediateDirectories: true)
        }
        
        // Generate unique filename
        let filename = originalURL.lastPathComponent.isEmpty ? UUID().uuidString + ".m4a" : originalURL.lastPathComponent
        let permanentURL = audioFolderPath.appendingPathComponent(filename)
        
        // Remove if already exists
        if fileManager.fileExists(atPath: permanentURL.path) {
            try? fileManager.removeItem(at: permanentURL)
        }
        do {
            try fileManager.copyItem(at: tempURL, to: permanentURL)
            print("✅ Audio saved to: \(permanentURL.path)")
            return permanentURL
        } catch {
            print("❌ Failed to save audio: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func startPlayback() {
        // Check if audio is loaded
        guard waveView.audioURL != nil else {
            showErrorAlert(message: "Audio not loaded yet")
            return
        }
        NotificationCenter.default.post(
            name: NSNotification.Name("AudioCellStartedPlaying"),
            object: nil
        )
        waveView.isPlaying = true
        self.waveView.onDurationUpdate = { [weak self] time in
            self?.voiceTiming.text = time
        }
        waveView.startPlaybackAnimation()
        updatePlayButtonState(isPlaying: true)
    }

    
    private func updatePlayButtonState(isPlaying: Bool) {
        btnplay.isSelected = isPlaying
        let imageName = isPlaying ? "pause-button" : "play-button"
        btnplay.setImage(UIImage(named: imageName), for: .normal)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Audio Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        getCurrentViewController()?.present(alert, animated: true)
    }
    
    private func getCurrentViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController?
            .topMostViewController()
    }
    
}

//MARK: Table view Delegate Functions
extension ComunicationVC: UITableViewDelegate, UITableViewDataSource ,UIDocumentPickerDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tittlemessage.text == CommonStringFile.TextMessage.translated(){
            return TextHistory?.count ?? 0
        }
        else{
            return VoiceHistory?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tittlemessage.text == CommonStringFile.TextMessage.translated(){
            let cell = historytable.dequeueReusableCell(withIdentifier: CellConfingName.TextHistoryTVCell, for: indexPath) as! TextHistoryTVCell
            cell.descriptContent
                .setupExpandable(
                    text: TextHistory?[indexPath.row].content ?? ""
                )
            cell.descriptContent.onExpandableTap = {
                cell.descriptContent.isExpanded.toggle()
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            cell.descriptiontext = TextHistory?[indexPath.row].content ?? ""
            cell.MessageTitle.text = TextHistory?[indexPath.row].title
            cell.delegate = self
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                cell.configureShimmer()
            }
            if let sentOn = TextHistory?[indexPath.row].date,
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
                cell.DateLabel.attributedText = attributedText
            }
            return cell
            
        }else{
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.CommunicationTVC, for: indexPath) as? CommunicationTVC else {
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
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
    
    func playTapped(at index: Int) {
        if playIndex != index {
            player?.pause()
            updateTimer?.invalidate()
        }
        playIndex = index
        historytable.reloadData()
    }
    
    // MARK: - Finish Playing Delegate
    func didFinishPlaying(at index: Int) {
        print("✅ Finished playing voice at row: \(index)")
        playIndex = -1
        historytable.reloadData()
    }
    
    // Format seconds into mm:ss
    func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let sec = seconds % 60
        return String(format: CommonStringFile.Time_formate, minutes, sec)
    }
    
    func reload(index: Int) {
        if let currentIndex = playIndex, currentIndex != index {
            let previousIndexPath = IndexPath(row: currentIndex, section: 0)
            if let previousCell = historytable.cellForRow(at: previousIndexPath) as? HistoryTC {
                previousCell.updatePlayState(isPlaying: false, url: nil)
            }
        }
        
        playIndex = (playIndex == index) ? nil : index
        historytable.reloadData()
    }
    
    func setupTimePicker() {
        // Initialize the picker
        timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
        }
        timePicker.backgroundColor = .white
        timePicker.isHidden = true // Initially hidden
        self.view.addSubview(timePicker)
        // Add Done Button
        doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.isHidden = true
        doneButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 8
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        self.view.addSubview(doneButton)
    }
    @objc func doneButtonTapped() {
        // Format the time
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        if let activeButton = activeButton {
            let selectedTime = formatter.string(from: timePicker.date)
            activeButton.setTitle(selectedTime, for: .normal)
        }
        timePicker.isHidden = true
        doneButton.isHidden = true
        activeButton = nil
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Calendar.current.startOfDay(for: Date())
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Calendar.current.date(byAdding: .day, value: 6, to: Date())!
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let firstDayOfCurrentMonth = calendar.currentPage
        let lastDayOfCurrentMonth = Calendar.current.date(byAdding: .month, value: 1, to: firstDayOfCurrentMonth)?.addingTimeInterval(-1) ?? firstDayOfCurrentMonth
        if !(date >= firstDayOfCurrentMonth && date <= lastDayOfCurrentMonth) {
            
            calendar.deselect(date)
            let alert = UIAlertController(
                title: AlertstringFile.invalidSelection,
                message: AlertstringFile.selectDatesWithinMonth,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: AlertstringFile.OK, style: .default))
            self.present(alert, animated: true, completion: nil)
            return
        }
        if selectedDates.count < 7 {
            if !selectedDates.contains(date) {
                selectedDates.append(date)
            }
        } else {
            calendar.deselect(date)
            
            let alert = UIAlertController(
                title: "",
                message: AlertstringFile.Already_Reach_Your_Limit,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: AlertstringFile.OK, style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        
        dateCV.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // Remove the deselected date
        if let index = selectedDates.firstIndex(of: date) {
            selectedDates.remove(at: index)
        }
        dateCV.reloadData()
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        printCurrentMonth()
        print("Current page changed to: \(calendar.currentPage)")
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        return selectedDates.contains(date) ? UIColor.green : nil
    }
    func deleteDelegate(index: Int) {
        let dateToRemove = selectedDates[index]
        selectedDates.remove(at: index)
        DateSelection.deselect(dateToRemove)
        DateSelection.reloadData()
        reloadCollectionAndUpdateHeight()
    }
    
    
    func reloadCollectionAndUpdateHeight() {
        dateCV.reloadData()
        dateCV.layoutIfNeeded()
        
        DispatchQueue.main.async {
            let contentHeight = self.dateCV.collectionViewLayout.collectionViewContentSize.height
            self.dateSelectedViewHeight.constant = contentHeight
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    func printCurrentMonth() {
        let currentPage = DateSelection.currentPage
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy" // Format as Month Year (e.g., "November 2024")
        let formattedMonth = dateFormatter.string(from: currentPage)
        monthLbl.text = formattedMonth.translated()
    }
    func hideCalendarHeader() {
        DateSelection.headerHeight = 0
    }
    
    //MARK: Collection View Delegate Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("selectedDates",selectedDates.count)
        return selectedDates.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConfingName.DateCVC, for: indexPath as IndexPath) as! DateCVC
        
        let selectedDate = selectedDates[indexPath.item]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // You can change this style to your preference
        let formattedDate = dateFormatter.string(from: selectedDate)
        cell.dateLbl.text = formattedDate
        cell.dateDelet.tag = indexPath.item
        cell.delegate = self
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let playIndex = playIndex else { return }
        let indexPath = IndexPath(row: playIndex, section: 0)
        if let visiblePaths = historytable.indexPathsForVisibleRows {
            let isVisible = visiblePaths.contains(indexPath)
            if !isVisible {
                if let cell = historytable.cellForRow(at: indexPath) as? HistoryTC {
                    self.playIndex = nil
                    cell.player = nil
                }
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let with = dateCV.frame.size.width - 20
        let cwidth = with/3
        return CGSize(width: cwidth, height: 60)
    }
    func select(Tittle: String, descriptContent: String) {
        TextMsgTittle.text = Tittle
        informationcontent.text = descriptContent
        placeholderLabel.isHidden = !informationcontent.text.isEmpty
        textCountLbl.text = "\(descriptContent.count) / 500"
        textMsgVoiceCountLbl.text = "\(Tittle.count) / 50"
        showTextMessageView(isforwardtext:true)
    }
    
    func convertDateStrings(dates: [String]) -> [String] {
        let savedCode = UserDefaults.standard.string(forKey: DefaultsKeys.Language) ?? "en"
        let localeID = normalizedLocaleIdentifier(for: savedCode)
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd MMM yyyy"
        inputFormatter.locale = Locale(identifier: localeID)
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MM-yyyy"
        
        return dates.compactMap { dateString in
            if let date = inputFormatter.date(from: dateString) {
                return outputFormatter.string(from: date)
            } else {
                return nil
            }
        }
    }
    
    func convertTimeStringToSeconds(_ timeString: String) -> Int {
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let minutes = Int(components[0]),
              let seconds = Int(components[1]) else {
            return 0
        }
        return (minutes * 60) + seconds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ComunicationVC: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeField = textView
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeField = nil
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return self.rate != 0 && self.error == nil
    }
}
