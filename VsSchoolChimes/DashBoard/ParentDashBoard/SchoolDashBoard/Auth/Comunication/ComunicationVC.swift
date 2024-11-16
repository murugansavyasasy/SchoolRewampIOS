import UIKit
import AVFoundation
import UniformTypeIdentifiers
import AVFAudio


protocol reloadDelegate{
    func reload(index:Int)
}
class ComunicationVC: UIViewController, AVAudioRecorderDelegate, reloadDelegate {
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var player : AVPlayer?
    var AudioPlayUrl = "file:///var/mobile/Containers/Data/Application/9D69D934-AC7F-4D0B-B91B-055C9719182D/Documents/myRecording.mp4"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        check_record_permission()
        uiUUpdate()
        setupAudioSession()
        CellRegistre()
        setupWaveBars()
        historytable.delegate = self
        historytable.dataSource = self
        var bounds = UIScreen.main.bounds
        var width = bounds.size.width
        var height = view.frame.size.height
        print(height)
    }
    
    func uiUUpdate(){
//        playerheight.constant = 0
        playadiuoslider.value = 0
        playerview.layer.shadowColor = UIColor.black.cgColor
        playerview.layer.shadowOffset = CGSize(width: 0, height: 2)
        playerview.layer.shadowRadius = 5
        playerview.layer.shadowOpacity = 0.3
        playerview.layer.cornerRadius = 8
        voiceStackview.isHidden = true
        dltbtn.isHidden = true
        informationcontent.layer.cornerRadius = 10
        informationcontent.layer.borderWidth = 1
        informationcontent.layer.borderColor = UIColor.black.cgColor
        emengencyCall.isOn = false
        addfile.layer.cornerRadius = 4
        let title = "Do you want send Text Message?"
        let title2 = "Do you want  send Voice Message?"
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        let attributedTitle2 = NSAttributedString(string: title2, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        
        moveTextmessage.setAttributedTitle(attributedTitle, for: .normal)
        moveVoiceMessage.setAttributedTitle(attributedTitle2, for: .normal)
        sendbtn.isEnabled = false
    }
    
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
    
    
    func CellRegistre(){
        historytable.register(UINib(nibName: "HistoryTC", bundle: nil), forCellReuseIdentifier: "HistoryTC")
    }
    
    func setupRecorder()
    {
        if isAudioRecordingGranted ?? true
        {
            let session = AVAudioSession.sharedInstance()
            do
            {
                try session.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
                try session.setActive(true)
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 2,
                    AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue
                ]
                audioRecorder = try AVAudioRecorder(url: getFileUrl(), settings: settings)
                audioRecorder?.delegate = self
                audioRecorder?.isMeteringEnabled = true
                audioRecorder?.record(forDuration: 180.00)// record for 3 minutes
                
                audioRecorder?.prepareToRecord()
            }
            catch let error {
                
            }
        }
    }
    
    func showVoiceMessageView() {
        voiceview.isHidden = false
        textmessageview.isHidden = true
        historyview.isHidden = true
        addfile.isHidden = false
        tittlemessage.text = "Voice Message"
        radio1.setImage(UIImage(systemName: "button.programmable"), for: .normal)
        radio2.setImage(UIImage(systemName: "circle"), for: .normal)
    }
    
    func showTextMessageView() {
        textmessageview.isHidden = false
        voiceview.isHidden = true
        tittlemessage.text = "Text Message"
    }
    
    func showHistoryView() {
        historyview.isHidden = false
        voiceview.isHidden = true
        textmessageview.isHidden = true
        radio1.setImage(UIImage(systemName: "circle"), for: .normal)
        radio2.setImage(UIImage(systemName: "button.programmable"), for: .normal)
    }
    func deletRecoding(){
        sendbtn.isEnabled = false
        dltbtn.isHidden = true
        voiceStackview.isHidden = true
        addfile.isHidden = false
        player?.pause()
        AudioPlayUrl = ""
        Timinglbl.text = "0.00/3.00"
    }
    func startRecording() {
        recrdimg.image = UIImage.gifImageWithName("Mic")
        isRecording = true
        recordingStartTime = Date()
        setupRecorder()
        audioRecorder?.record()
        // Start recording timer
        recordingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRecordingTime), userInfo: nil, repeats: true)
    }
    
    func stopRecording() {
        recrdimg.image = UIImage(named: "mic")
        audioRecorder?.stop()
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        if let urls = URL(string: AudioPlayUrl){
            // Calculate total recording duration and set Timinglbl
            if let startTime = recordingStartTime {
                let duration = Date().timeIntervalSince(startTime)
                let minutes = Int(duration) / 60
                let seconds = Int(duration) % 60
                voiceTiming.text = String(format: "%d:%02d", minutes, seconds)
            }
            
            // Set message send time
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            messageSendTime.text = "\(formatter.string(from: Date()))"
            
            playerheight.constant = 60
            voiceStackview.isHidden = false
            dltbtn.isHidden = false
            sendbtn.isEnabled = true
            addfile.isHidden = true
            
            
            playerItem = AVPlayerItem(url: urls)
            player = AVPlayer(playerItem: playerItem!)
        }
        
    }
    
    @IBAction func voiceview(_ sender: Any) {
        voiceview.isHidden = false
        textmessageview.isHidden = true
        historyview.isHidden = true
        addfile.isHidden = false
        tittlemessage.text = "Voice Message"
    }
    
    @IBAction func sendEmergencycall(_ sender: UISwitch) {
//        sender.isOn.toggle()
    }
    
    @IBAction func history(_ sender: UIButton) {
        showHistoryView()
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func voiceviewmsg(_ sender: Any) {
        showVoiceMessageView()
        deletRecoding()
    }
    
    @IBAction func textviewshow(_ sender: Any) {
        showTextMessageView()
        deletRecoding()
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
    
    
    @IBAction func Addfiles(_ sender: UIButton) {
        // Configure the document picker to allow audio or document files
        if #available(iOS 14.0, *) {
            let supportedTypes: [UTType] = [.audio, .pdf, .text, .plainText]
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false  // Set to true if you want to allow multiple selections
            present(documentPicker, animated: true, completion: nil)
        }
    }
    
    

    @IBAction func deleteVoicemsg(_ sender: UIButton) {
        deletRecoding()
    }
    

    
    // Play Button Action
    @IBAction func playButtonTapped(_ sender: UIButton) {
   
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player!.currentItem)

        
        if playVoicce == true{
            player?.pause()
            playVoicce = false
            btnplay.setImage(UIImage(named: "play-button"), for: .normal)
        }else{
            
            player?.volume = 1
            player?.play()
            playVoicce = true
            btnplay.setImage(UIImage(named: "pause-button"), for: .normal)
            //                         playadiuoslider.maximumValue = Float(audioPlayer?.duration ?? 0)
            updateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        }
        
    }
    
    func getFileUrl() -> URL
    {
        let filename = "myRecording.mp4"
        
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        
        var myurl = filePath
        
        var urlString: String = myurl.absoluteString
        AudioPlayUrl = filePath.absoluteString
        
        return filePath
    }
    
    @objc func updateRecordingTime() {
        if let startTime = recordingStartTime {
            let elapsed = Date().timeIntervalSince(startTime)
            
            // Limit recording time to a maximum of 1 minute (60 seconds)
            if elapsed >= 180 {
                stopRecording()
                Timinglbl.text = "3:00"  // Display 1:00 when maximum time is reached
            } else {
                // Display elapsed time in "m:ss" format, with two digits for seconds
                let minutes = Int(elapsed) / 60
                let seconds = Int(elapsed) % 60
                Timinglbl.text = String(format: "%d:%02d", minutes, seconds)
            }
        }
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        btnplay.setImage(UIImage(named: "play-button"), for: .normal)
        resetWaveBars()
        player?.pause()
        playerItem?.seek(to: CMTime.zero)
    }
    
    
    // Helper function to get the documents directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
    
    
    func resetWaveBars() {
        for bar in bars {
            UIView.animate(withDuration: 0.1) {
                bar.frame.size.height = 0
            }
        }
    }
    
    
    // Update Slider Position as Audio Plays
    @objc func updateSlider() {
        guard let audioPlayer = player else { return }
        //        audioPlayer.updateMeters() // Refresh audio metering data
        if audioPlayer.isPlaying {
            audioRecorder?.updateMeters()
            let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160 // Default to -160 if no data
            let normalizedPower = max(1, (averagePower + 160) / 160)
            waveView.updateWithLevel(CGFloat(normalizedPower))
            
        }else{
            let averagePower = audioRecorder?.averagePower(forChannel: 10) ?? -160 // Get power level for channel 0
            let normalizedPower = max(0, (averagePower + 160) / 160) // Normalize the power value between 0 and 1
            
            // Update wave view with the normalized power level
            waveView.updateWithLevel(CGFloat(normalizedPower))
        }
    }
    
    
    
    
}
extension ComunicationVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        btnplay.setImage(UIImage(named: "play-button"), for: .normal)
        resetWaveBars()
    }
}


extension ComunicationVC: UITableViewDelegate, UITableViewDataSource ,UIDocumentPickerDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historytable.dequeueReusableCell(withIdentifier: CellConfingName.HistoryTC, for: indexPath) as! HistoryTC
        
        cell.playBtn.tag = indexPath.row
        
        let image = playIndex == indexPath.row ? UIImage(named: "pause-button"): UIImage(named: "play-button")
        // Update play state
        let isPlaying = (playIndex == indexPath.row)
//        var urls = URL(string: AudioPlayUrl)
        cell.updatePlayState(isPlaying: isPlaying, url: AudioPlayUrl)
        cell.delegate = self
        cell.playBtn.setImage(image, for: .normal)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // Setup Audio Session
    func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .allowBluetooth)
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    func reload(index: Int) {
        // Stop playback in the currently playing cell (if any)
        if let currentIndex = playIndex, currentIndex != index {
            let previousIndexPath = IndexPath(row: currentIndex, section: 0)
            if let previousCell = historytable.cellForRow(at: previousIndexPath) as? HistoryTC {
                previousCell.updatePlayState(isPlaying: false, url: previousCell.AudioPlayUrl)
            }
        }
        
        // Update the currently playing index and reload the table view
        playIndex = (playIndex == index) ? nil : index
        historytable.reloadData()
    }
    
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else { return }
        
        // Do something with the selected file URL
        print("Selected file URL: \(selectedFileURL)")
        
        // Example: You can load or play an audio file from the selected URL
        if selectedFileURL.startAccessingSecurityScopedResource() {
            defer { selectedFileURL.stopAccessingSecurityScopedResource() }
            
            // Handle the file as needed, e.g., copy it or use it in your app
        }
    }
    
    // Handle cancellation
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
}


