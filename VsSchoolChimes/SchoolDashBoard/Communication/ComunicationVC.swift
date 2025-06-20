import UIKit
import DropDown
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
class ComunicationVC: UIViewController, AVAudioRecorderDelegate, reloadDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, FSCalendarDelegate, FSCalendarDataSource, SelectedTextDelegate, UITextViewDelegate, ForwordDelegate, HistoryFinishPalyingDelegate,UITextFieldDelegate{
    
    func voiceforword(selectedIndex: Int?) {
        voiceTitleeTxt.text = VoiceHistory?[selectedIndex ?? 0].title ?? ""
        
        if isScheduleSelected{
            enabelScheduleView(
                isforward: true,
                voiceUrl:VoiceHistory?[selectedIndex ?? 0].url ?? "",
                title: VoiceHistory?[selectedIndex ?? 0].title ?? "",
                durations: VoiceHistory?[selectedIndex ?? 0].duration ?? 0,
                url: VoiceHistory?[selectedIndex ?? 0].url ?? ""
            )
        }else{
            enabelVoice_view(
                isforward: true,
                voiceUrl:VoiceHistory?[selectedIndex ?? 0].url ?? "",
                title: VoiceHistory?[selectedIndex ?? 0].title ?? "",
                durations: VoiceHistory?[selectedIndex ?? 0].duration ?? 0,
                url: VoiceHistory?[selectedIndex ?? 0].url ?? ""
            )
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
    let backgroundcolor = Colornames.topBackgroundCLr
    let tapColor = Colornames.topBackgroundCLr1
    var placeholderLabel: UILabel!
    let alert = CustomAlert()
    
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
    @IBOutlet weak var waveView: WaveView!
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
        
        
        if emengencyCall.isOn{
            isEmergencyVoice = true
            //            enableDisable()
        }
        else{
            isEmergencyVoice = true
            //            enableDisable()
        }
        
        if staff_role == "p3"{
            seduleClickView.isHidden = true
        }else{
            seduleClickView.isHidden = false
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleWaveViewProgressChange(_:)), name: NSNotification.Name("WaveViewSliderChanged"), object: nil)
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
            isEmergencyVoice = true
            Timinglbl.text = "00:00/00:30"
            Enabel_buble()
            //            enableDisable()
        }
        else{
            isEmergencyVoice = false
            Timinglbl.text = "00:00/03:00"
            //            enableDisable()
        }
        
    }
    
    
    
    @IBAction func voice_sendBtn_action(_ sender: UIButton) {
        ScheduleSelectedDate.removeAll()
        for i in 0..<selectedDates.count{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let formattedDate = dateFormatter.string(from: selectedDates[i])
            ScheduleSelectedDate.append(formattedDate)
        }
        let today_date = getCurrentDateString()
        if(AudioPlayUrl != "" && voiceTitleeTxt.text != ""){
            
            user_inputs.voice_link = AudioPlayUrl!
            user_inputs.description = voiceTitleeTxt.text!
            user_inputs.duration = voiceRecordedDuration ?? 0
            user_inputs.is_schedule = isScheduleSelected
            user_inputs.is_emergency = isEmergencyVoice ?? false
            user_inputs.file_name = "sss-" + today_date + ".mp3"
            if emengencyCall.isOn || !isScheduleSelected {
                user_inputs.schedule_date = [today_date]
                user_inputs.start_time = ""
                user_inputs.end_time = ""
                recienpient_validation(isVoice : true)
            } else {
                if ScheduleSelectedDate.count != 0{
                    let originalDates = ScheduleSelectedDate
                    let convertedDates = convertDateStrings(dates: originalDates)
                    ScheduleSelectedDate = convertedDates
                    user_inputs.schedule_date = ScheduleSelectedDate
                    user_inputs.start_time = fromTime.titleLabel?.text ?? ""
                    user_inputs.end_time = toTime.titleLabel?.text ?? ""
                    recienpient_validation(isVoice : true)
                }else{
                    alert.showAlert(title: "",message: AlertstringFile.select_date,on: self)
                }
            }
            
            
        }
        else{
            alert
                .showAlert(
                    title: "",
                    message: AlertstringFile.voice_or_title_is_required,
                    on: self)
        }
        
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
                    on: self
                )
        }
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
                    } else {
                        // Fallback on earlier versions
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
                    } else {
                        // Fallback on earlier versions
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
    
    
    
    
    
    
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [ Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
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
        BackBtn.setTitle(MenuStringFile.Communication.translated(), for: .normal)
        
        //MARK: Label font style
        tittlemessage.setFont(style: .title, size: FontSize.TitleSize)
        voiceSetTitleLbl.setRequiredText(CommonStringFile.Title)
        messageSendTime.setFont(style: .body, size: FontSize.BodySize)
        voiceTiming.setFont(style: .body, size: FontSize.BodySize)
        Timinglbl.setFont(style: .body, size: FontSize.BodySize)
        clickVoiceLbl.setFont(style: .title, size: FontSize.TitleSize)
        clickSchedule.setFont(style: .title, size: FontSize.TitleSize)
        clickTextView.setFont(style: .title, size: FontSize.TitleSize)
        ScheduleLbl.setFont(style: .title, size: FontSize.TitleSize)
        fromDateLbl.setFont(style: .title, size: FontSize.TitleSize)
        ToDateLbl.setFont(style: .title, size: FontSize.TitleSize)
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
        placeholderLabel.text = "Description" //CommonStringFile.EnterTextHere.translated()
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
        guard !isKeyboardVisible else { return } // Prevent unnecessary animations
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            isKeyboardVisible = true
            UIView.animate(withDuration: 0.3) {
                self.outerView.transform = CGAffineTransform(translationX: 0, y: -keyboardFrame.height + 200)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard isKeyboardVisible else { return }
        isKeyboardVisible = false
        UIView.animate(withDuration: 0.3) {
            self.outerView.transform = .identity // Reset position
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Calculate the new length of the text
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        if updatedText.count <= 500 {
            textCountLbl.text = "\(updatedText.count) of 500"
            return true // Allow the change
        } else {
            let alert = CustomAlert()
            alert.showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: self)
            return false // Reject the change
        }
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
        //        sendbtn.isEnabled = false
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the current text
        let currentText = textField.text ?? ""
        
        // Apply the change
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // ✅ Update character count label
        voiceTileTextFldCount.text = "\(updatedText.count)/50"
        textMsgVoiceCountLbl.text = "\(updatedText.count)/50"
        
        // ✅ Limit to 50 characters
        return updatedText.count <= 49
    }
    
    
    //MARK: CELL REGISTRATION
    func CellRegistre(){
        historytable.register(UINib(nibName: CellConfingName.HistoryTC, bundle: nil), forCellReuseIdentifier: CellConfingName.HistoryTC)
        historytable.register(UINib(nibName: CellConfingName.TextHistoryTVCell, bundle: nil), forCellReuseIdentifier: CellConfingName.TextHistoryTVCell)
        dateCV.register(UINib(nibName: CellConfingName.DateCVC, bundle: nil), forCellWithReuseIdentifier: CellConfingName.DateCVC)
        
    }
    
    //MARK: BUTTON TITLE CURRANT TIME
    private func setInitialButtonTitles() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        // Set initial times
        let initialFromTime = Date() // Current time for example
        let initialToTime = Calendar.current.date(byAdding: .minute, value: 20, to: initialFromTime) ?? Date()
        
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
                print("✅ File deleted successfully")
            } catch {
                print("❌ Error deleting file: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ File does not exist at path: \(url.path)")
        }
    }

//    //MARK: GET AUDIO URL
//    func getFileUrl() -> URL {
//        let filename = getTimestampedFileName()
//        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
//        AudioPlayUrl = filePath.absoluteString // Store the file path for later use
//        return filePath
//    }
    func getFileUrl() -> URL {
        let filename = "RecordedAudio.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)

        // Delete if it already exists
        if FileManager.default.fileExists(atPath: filePath.path) {
            try? FileManager.default.removeItem(at: filePath)
        }

        AudioPlayUrl = filePath.absoluteString
        return filePath
    }

    
//    func getTimestampedFileName(extension ext: String = "m4a") -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyyMMdd_HHmmss"
//        let timestamp = formatter.string(from: Date())
//        return "Audio_\(timestamp).\(ext)"
//    }
    
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
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                
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
                                on: self
                            )
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
        return String(format: "%02d:%02d", minutes, seconds) // e.g., "01:27"
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
            .makeApi(url:  ServiceUrl.comm_voice_get_voice_history, parameters: [:] , type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? ""){ [self] (
                result : Result<VoiceResponse,
                Error>
            ) in
                
                switch result {
                    
                case.success(let succesmessage) :
                    
                    print("succesmessagesdsds",succesmessage)
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
            .makeApi(url:  ServiceUrl.comm_text_message_get_text_history, parameters: [:] , type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? ""){ [self] (
                result : Result<TextDetailsResponse,
                Error>
            ) in
                
                switch result {
                    
                case.success(let succesmessage) :
                    
                    print("succesmessagesdsds",succesmessage)
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
        playerheight.constant = 0
        if emengencyCall.isOn{
            Timinglbl.text = "00:00/00:30"
        }else{
            Timinglbl.text = "00:00/03:00"
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
        if let urls = URL(string: AudioPlayUrl!){
            // Calculate total recording duration and set Timinglbl
            if let startTime = recordingStartTime {
                let duration = Date().timeIntervalSince(startTime)
                let minutes = Int(duration) / 60
                let seconds = Int(duration) % 60
                voiceTiming.text = String(format: "%02d:%02d", minutes, seconds)
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
            playerItem = AVPlayerItem(url: urls)
            player = AVPlayer(playerItem: playerItem!)
        }
        
    }
    @objc func handleWaveViewProgressChange(_ notification: Notification) {
        guard let progress = notification.object as? CGFloat,
              let player = player else { return }
        let totalDuration = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime.zero)
        let seekTime = CMTime(seconds: Double(progress) * totalDuration, preferredTimescale: 1)
        player.seek(to: seekTime) { [weak self] _ in
            self?.updateUIForSeekPosition(progress)
        }
    }
    
    // MARK: - UI Update for Seek
    private func updateUIForSeekPosition(_ progress: CGFloat) {
        waveView.progress = progress
        
        // Update the timer display
        let totalDuration = CMTimeGetSeconds(player?.currentItem?.duration ?? CMTime.zero)
        let currentSeconds = Int(progress * totalDuration)
        let minutes = currentSeconds / 60
        let seconds = currentSeconds % 60
        voiceTiming.text = String(format: "%02d:%02d", minutes, seconds)
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
                    Timinglbl.text = String(format: "%02d:%02d", minutes, seconds)
                }
            }else{
                if elapsed >= 180 {
                    stopRecording()
                    Timinglbl.text = "03:00"
                } else {
                    let minutes = Int(elapsed) / 60
                    let seconds = Int(elapsed) % 60
                    Timinglbl.text = String(format: "%02d:%02d", minutes, seconds)
                }
            }
            
        }
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        btnplay.setImage(ImageName.playbutton, for: .normal)
        player?.pause()
        updateTimer?.invalidate()
        audioRecorder?.updateMeters()
        let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160
        let normalizedPower = max(0, (averagePower + 160) / 160)
        waveView.updateWithLevel(CGFloat(normalizedPower))
        playerItem?.seek(to: CMTime.zero)
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
    @objc func updateSlider() {
        guard let audioPlayer = player else { return }
        
        // Get current player item and playback status
        if let currentItem = audioPlayer.currentItem {
            let totalDuration = CMTimeGetSeconds(currentItem.duration)
            let elapsedTime = CMTimeGetSeconds(audioPlayer.currentTime())
            
            // Safely unwrap and validate durations
            guard totalDuration.isFinite, elapsedTime.isFinite else { return }
            let progress = CGFloat(elapsedTime / totalDuration)
            waveView.progress = progress
            waveView.setNeedsDisplay()
            let totalFormatted = formatTime(totalDuration)
            let currentFormatted = formatTime(elapsedTime)
            voiceTiming.text = "\(currentFormatted) / \(totalFormatted)"
            let fakeLevel = sin(progress * .pi)
            waveView.updateWithLevel(CGFloat(fakeLevel))
            if audioPlayer.isPlaying {
                audioRecorder?.updateMeters()
                
                // Get average power for channel 0
                let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160
                let normalizedPower = max(1, (averagePower + 160) / 160)
                waveView.updateWithLevel(CGFloat(normalizedPower))  // Update waveform animation
                
                // Update playback time
                if let currentItem = audioPlayer.currentItem {
                    let totalDuration = CMTimeGetSeconds(currentItem.duration)
                    
                    if totalDuration.isFinite {
                        let elapsedTime = CMTimeGetSeconds(audioPlayer.currentTime())
                        let progress = CGFloat(elapsedTime / totalDuration)
                        waveView.progress = progress
                        waveView.setNeedsDisplay()  // Refresh WaveView to update colors
                        
                        // Time formatting for display
                        let totalMinutes = Int(totalDuration) / 60
                        let totalSeconds = Int(totalDuration) % 60
                        let totalDurationFormatted = String(format: "%02d:%02d", totalMinutes, totalSeconds)
                        
                        let elapsedMinutes = Int(elapsedTime) / 60
                        let elapsedSeconds = Int(elapsedTime) % 60
                        let currentFormatted = String(format: "%02d:%02d", elapsedMinutes, elapsedSeconds)
                        
                        // Update the timing label
                        voiceTiming.text = "\(currentFormatted) / \(totalDurationFormatted)"
                        voiceRecordedDuration = Int(totalDurationFormatted)
                        
                    }
                }
            } else {
                audioRecorder?.updateMeters()
                let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160
                let normalizedPower = max(0, (0) / 160)
                waveView.updateWithLevel(CGFloat(normalizedPower))
            }
        }
    }
    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
        selectedDates.removeAll()
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
        
        if selectedDates.count == 0{
            
            ViewAnimator.animateConstraintChange { [self] in
                dateSelectedViewHeight.constant = 0
                self.view.layoutIfNeeded()
            }
            
        }else if selectedDates.count <= 3{
            ViewAnimator.animateConstraintChange { [self] in
                dateSelectedViewHeight.constant = 64
                self.view.layoutIfNeeded()
            }
            
        }else{
            ViewAnimator.animateConstraintChange { [self] in
                dateSelectedViewHeight.constant = 120
                self.view.layoutIfNeeded()
            }
            
        }
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
        selectedDates.removeAll()
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
        //        for i in 0..<selectedDates.count {
        //                    DateSelection.deselect(selectedDates[i])
        //                }
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
            textCountLbl.text = "0 of 500"
            textMsgVoiceCountLbl.text = "0 of 50"
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
        emengencyCall.isOn = false
        isScheduleSelected = false
        updateEmergencyCallVisibility(staff_role)
        
        if isforward {
            recordImgHeightCon.constant = 0
            Timinglbl.isHidden = true
            addfile.isHidden = true
            AudioPlayUrl = url
            let formatted = formatDuration(durations)
            voiceTiming.text = "00:00 / \(formatted)"
            AudioPlayUrl = voiceUrl
            voiceTileTextFldCount.text = "\(title.count) of 500"
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
        url: String
    ) {
        emengencyCall.isOn = false
        
        if isforward {
            recordImgHeightCon.constant = 0
            Timinglbl.isHidden = true
            addfile.isHidden = true
            AudioPlayUrl = url
            voiceTileTextFldCount.text = "\(title.count) of 500"
            let formatted = formatDuration(durations)
            voiceTiming.text = "00:00 / \(formatted)"
            AudioPlayUrl = voiceUrl
            
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
            dateSelectedViewHeight.constant = 0
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
//            deleteFile(at:url)
            deletRecoding()
        }
    }
    
    
    
    // Play Button Action
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player!.currentItem)
        if playVoicce == true{
            player?.pause()
            playVoicce = false
            btnplay.setImage(ImageName.playbutton, for: .normal)
        }else{
            
            player?.volume = 1
            player?.play()
            playVoicce = true
            btnplay.setImage(ImageName.pausebutton, for: .normal)
            updateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        }
        
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
            let cell = historytable.dequeueReusableCell(withIdentifier: CellConfingName.HistoryTC, for: indexPath) as! HistoryTC
            
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
        return String(format: "%02d:%02d", minutes, sec)
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
        return Date()
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Calendar.current.date(byAdding: .day, value: 7, to: Date())!
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
        if selectedDates.count < 6 {
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
        // Update height based on count
        var newHeight: CGFloat = 0
        if selectedDates.count == 0 {
            newHeight = 0
        } else if selectedDates.count <= 3 {
            newHeight = 64
        } else {
            newHeight = 128
        }
        
        // Animate constraint change
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
            self.dateSelectedViewHeight.constant = newHeight
            self.view.layoutIfNeeded()
        }
        
        dateCV.reloadData()
    }
    
    
    //MARK: Collection View Delegate Functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        textCountLbl.text = "\(descriptContent.count) of 500"
        textMsgVoiceCountLbl.text = "\(Tittle.count) of 50"
        showTextMessageView(isforwardtext:true)
    }
    
    func convertDateStrings(dates: [String]) -> [String] {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd MMM yyyy"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
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
