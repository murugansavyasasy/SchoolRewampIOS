import UIKit
import UniformTypeIdentifiers
import AVFAudio

class ComunicationVC: UIViewController {
    
    
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var isRecording = false
    var updateTimer: Timer?
    var recordingTimer: Timer?
    var recordingStartTime: Date?
    var bars: [UIView] = [] // Array to hold individual wave bars
 
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
        
        uiUUpdate()
        historytable.delegate = self
        historytable.dataSource = self
        
    }
    
//    func uiUUpdate(){
//        
//        
//        let waveview = WaveView(frame: CGRect(x: 0, y: 200, width: view.bounds.width, height: 100))
//        waveview.backgroundColor = .clear
//        waveView.addSubview(waveView)
//        
//        playerheight.constant = 0
//        playadiuoslider.value = 0
//        setupAudioSession()
//        CellRegistre()
//        playerview.layer.shadowColor = UIColor.black.cgColor
//        playerview.layer.shadowOffset = CGSize(width: 0, height: 2)
//        playerview.layer.shadowRadius = 5
//        playerview.layer.shadowOpacity = 0.3
//        playerview.layer.cornerRadius = 8
//        voiceStackview.isHidden = true
//        dltbtn.isHidden = true
//        informationcontent.layer.cornerRadius = 10
//        informationcontent.layer.borderWidth = 1
//        informationcontent.layer.borderColor = UIColor.black.cgColor
//        setupWaveBars()
//        emengencyCall.isOn = false
//        addfile.layer.cornerRadius = 4
//        let title = "Do you want send Text Message?"
//        let title2 = "Do you want  send Voice Message?"
//            let attributedTitle = NSAttributedString(string: title, attributes: [
//                .underlineStyle: NSUnderlineStyle.single.rawValue
//            ])
//        let attributedTitle2 = NSAttributedString(string: title2, attributes: [
//            .underlineStyle: NSUnderlineStyle.single.rawValue
//        ])
//            
//        moveTextmessage.setAttributedTitle(attributedTitle, for: .normal)
//        moveVoiceMessage .setAttributedTitle(attributedTitle2, for: .normal)
//        sendbtn.isHidden = true
//    }
    func uiUUpdate(){
//        let waveview = WaveView(frame: CGRect(x: 0, y: 200, width: view.bounds.width, height: 100))
//        waveview.backgroundColor = .clear
//        waveView.addSubview(waveview) // Use `waveview` instead of `waveView` to avoid adding `self`
        
        playerheight.constant = 0
        playadiuoslider.value = 0
        setupAudioSession()
        CellRegistre()
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
        setupWaveBars()
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
        sendbtn.isHidden = true
    }

    func CellRegistre(){
        historytable.register(UINib(nibName: "HistoryTC", bundle: nil), forCellReuseIdentifier: "HistoryTC")
    }
    @IBAction func voiceview(_ sender: Any) {
        voiceview.isHidden = false
        textmessageview.isHidden = true
        historyview.isHidden = true
        addfile.isHidden = true
        tittlemessage.text = "Voice Message"
    }
    
    @IBAction func sendEmergencycall(_ sender: UISwitch) {
        if sender.isOn{
            sender.isOn = true
        }else{
            sender.isOn = false
        }
    }
    
    @IBAction func history(_ sender: UIButton) {
        historyview.isHidden = false
        voiceview.isHidden = true
        radio1.setImage(UIImage(systemName: "circle"), for: .normal)
        radio2.setImage(UIImage(systemName: "button.programmable"), for: .normal)
        textmessageview.isHidden = true
    }
    
    @IBAction func voiceviewmsg(_ sender: Any) {
        voiceview.isHidden = false
        textmessageview.isHidden = true
        historyview.isHidden = true
        radio1.setImage(UIImage(systemName: "button.programmable"), for: .normal)
        radio2.setImage(UIImage(systemName: "circle"), for: .normal)
        addfile.isHidden = false
        tittlemessage.text = "Voice Message"
    }
    
    @IBAction func textviewshow(_ sender: Any) {
        textmessageview.isHidden = false
        voiceview.isHidden = true
        tittlemessage.text = "Text Message"
    }
    
    
    // Record Button Action
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
            
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
    
    func startRecording() {
        recrdimg.image = UIImage.gifImageWithName("Mic")
        setupRecorder()
        audioRecorder?.record()
        isRecording = true
        recordingStartTime = Date()
        
        // Start recording timer
        recordingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRecordingTime), userInfo: nil, repeats: true)
    }
    
    func stopRecording() {
        recrdimg.image = UIImage(named: "mic")
        audioRecorder?.stop()
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        
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
        sendbtn.isHidden = false
        addfile.isHidden = true
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
    
    
    
    
    @IBAction func deleteVoicemsg(_ sender: UIButton) {
        dltbtn.isHidden = true
        voiceStackview.isHidden = true
        addfile.isHidden = false
        playerheight.constant = 0
        Timinglbl.text = "0.00/3.00"
    }
    
    // Play Button Action
    @IBAction func playButtonTapped(_ sender: UIButton) {

        
        // Check if the audio player is currently playing
          if let audioPlayer = audioPlayer, audioPlayer.isPlaying {
              // Pause the audio
              audioPlayer.pause()
              btnplay.setImage(UIImage(named: "play-button"), for: .normal)
              
              // Invalidate the timer to stop updating the slider while paused
              updateTimer?.invalidate()
              updateTimer = nil
          } else {
              // Attempt to play the audio
              do {
                  if audioPlayer == nil { // Initialize only if it's not already set up
                      let fileURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
                      audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                      audioPlayer?.delegate = self // Set delegate to detect when audio finishes playing
                  }
                  
                  // Start playback or resume
                  audioPlayer?.play()
                  btnplay.setImage(UIImage(named: "pause-button"), for: .normal)
                  
                  // Set slider max to the duration of the audio
                  playadiuoslider.maximumValue = Float(audioPlayer?.duration ?? 0)
                  
                  // Schedule a timer to update the slider as the audio plays
                  updateTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
              } catch {
                  print("Error playing audio: \(error)")
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
    
    
    func resetWaveBars() {
        for bar in bars {
            UIView.animate(withDuration: 0.1) {
                bar.frame.size.height = 0
            }
        }
    }
    // Update Slider Position as Audio Plays
    @objc func updateSlider() {
//        if let audioPlayer = audioPlayer {
//            playadiuoslider.value = Float(audioPlayer.currentTime)
//            let progress = Float(audioPlayer.currentTime / audioPlayer.duration)
//            for i in 0..<bars.count {
//                  let bar = bars[i]
//                  
//                  // Randomly vary the height of each bar within a range based on progress
//                let randomHeight = CGFloat(arc4random_uniform(100) + 20) * CGFloat(progress)
//
//                  UIView.animate(withDuration: 0.1) {
//                      bar.frame.size.height = randomHeight
//                  }
//              }
//            // Check if the audio has finished playing
//            if !audioPlayer.isPlaying {
//                btnplay.setImage(UIImage(named: "play-button"), for: .normal)
//                updateTimer?.invalidate()
//                updateTimer = nil
//                playadiuoslider.value = 0  // Reset slider to the start
//            }
//        }
        guard let audioPlayer = audioPlayer else { return }

        // Update the slider based on current playback time
        playadiuoslider.value = Float(audioPlayer.currentTime)

        // Update wave view based on audio levels
        audioPlayer.updateMeters() // Refresh audio metering data
        let averagePower = audioPlayer.averagePower(forChannel: 0) // Get power level for channel 0
        let normalizedPower = max(0, (averagePower + 160) / 160) // Normalize the power value between 0 and 1

        // Update wave view with the normalized power value
        waveView.updateWithLevel(CGFloat(normalizedPower))
    }
    
    // Seek Audio Position When Slider Value Changes
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        if let audioPlayer = audioPlayer {
            audioPlayer.currentTime = TimeInterval(sender.value)
            
            // Resume playback if paused
            if !audioPlayer.isPlaying {
                audioPlayer.play()
                btnplay.setImage(UIImage(named: "pause-button"), for: .normal)
            }
        }
    }
    
}
extension ComunicationVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        btnplay.setImage(UIImage(named: "play-button"), for: .normal)
//        updateTimer?.invalidate()
//        updateTimer = nil
//        playadiuoslider.value = 0 // Reset the slider
    }
}
extension ComunicationVC: UITableViewDelegate, UITableViewDataSource ,UIDocumentPickerDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historytable.dequeueReusableCell(withIdentifier: "HistoryTC", for: indexPath) as! HistoryTC
        
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
    
    // Setup Recorder
    func setupRecorder() {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        let fileURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
            audioRecorder?.prepareToRecord()
        } catch {
            print("Error setting up recorder: \(error)")
        }
    }
    
    // Helper function to get the documents directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
class WaveView: UIView {
    
    private var waveLayers: [CAShapeLayer] = []
    private var displayLink: CADisplayLink?
    
    // Wave configuration
    private var baseAmplitude: CGFloat = 20.0 // Base height of the wave bars
    private var waveFrequency: CGFloat = 0.5 // Frequency of the wave variation
    private var waveSpeed: CGFloat = 0.1 // Speed of the wave phase shift
    private var wavePhase: CGFloat = 0.0 // Initial phase shift
    private var numberOfBars: Int = 40 // Number of bars in the waveform
    
    // Current amplitude factor from audio level
    private var currentAmplitude: CGFloat = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWaveBars()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWaveBars()
    }
    
    private func setupWaveBars() {
        // Remove existing bars if any
        waveLayers.forEach { $0.removeFromSuperlayer() }
        waveLayers.removeAll()
        
        // Calculate the width and spacing of each bar
        let barWidth: CGFloat = self.bounds.width / CGFloat(numberOfBars) - 2
        let barSpacing: CGFloat = 1
        
        // Create each bar layer
        for i in 0..<numberOfBars {
            let barLayer = CAShapeLayer()
            barLayer.fillColor = UIColor.systemBlue.cgColor
            barLayer.strokeColor = UIColor.systemBlue.cgColor
            
            // Set initial frame and add to the view's layer
            let xPosition = CGFloat(i) * (barWidth + barSpacing)
            barLayer.frame = CGRect(x: xPosition, y: 0, width: barWidth, height: self.bounds.height)
            self.layer.addSublayer(barLayer)
            waveLayers.append(barLayer)
        }
        
        // Start the display link for animation
        displayLink = CADisplayLink(target: self, selector: #selector(updateWaveBars))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    // New method to update the amplitude based on the audio level
    func updateWithLevel(_ level: CGFloat) {
        // Scale the base amplitude with the normalized audio level
        currentAmplitude = baseAmplitude * level
    }
    
    @objc private func updateWaveBars() {
        wavePhase += waveSpeed
        
        // Update each bar's height to simulate a waveform
        for (index, barLayer) in waveLayers.enumerated() {
            let path = UIBezierPath()
            
            // Calculate the height of the bar using a sine function, adjusted by audio level
            let normalizedIndex = CGFloat(index) / CGFloat(numberOfBars)
            let barHeight = currentAmplitude * sin(normalizedIndex * waveFrequency * 2 * .pi + wavePhase)
            let adjustedHeight = max(5, abs(barHeight)) // Ensure a minimum height
            
            // Set the path for each bar, centered vertically
            let centerY = self.bounds.height / 2
            path.move(to: CGPoint(x: 0, y: centerY - adjustedHeight / 2))
            path.addLine(to: CGPoint(x: 0, y: centerY + adjustedHeight / 2))
            
            barLayer.path = path.cgPath
        }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}
