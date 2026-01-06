//
//  VoiceCellTV.swift
//  School Chimes
//
//  Created by apple on 27/12/25.
//

import UIKit
import AVFAudio
import AVFoundation

class VoiceCellTV: UITableViewCell, AVAudioRecorderDelegate {
    
    @IBOutlet weak var lineView: UILabel!
    @IBOutlet weak var choosePreRecordBtnName: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var waveView: AudioMessageView!
    @IBOutlet weak var nextBtnName: UIButton!
    @IBOutlet weak var titleDefaultLbl: UILabel!
    @IBOutlet weak var titleTxtFild: UITextField!
    @IBOutlet weak var EmergemcySwich: UISwitch!
    @IBOutlet weak var voiceRecordImgView: UIImageView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var duration: UILabel!
    private let audioManager = AudioManager()
    var isRecording = false
    var isAudioRecordingGranted : Bool?
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var player : AVPlayer?
    var AudioPlayUrl: String?
    var updateTimer: Timer?
    var recordingTimer: Timer?
    var recordingStartTime: Date?
    var bars: [UIView] = [] // Array to hold individual wave bars
    var playerItem : AVPlayerItem?
    var audioURL: URL? {
        didSet {
            guard let url = audioURL else { return }
            if url.isFileURL {
                // Local file
                prepareLocalAudio(url: url)
            } else {
                // Remote file
                downloadAndPrepareAudio(from: url)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        playerView.setShadow(cornerRadius: 10)
        let voiceRecordTap = UITapGestureRecognizer(target: self, action: #selector(voice_record))
        voiceRecordImgView.addGestureRecognizer(voiceRecordTap)
        
    }
    @IBAction func ChooseFromFileBtnAct(_ sender: UIButton) {
    }
    @IBAction func emergencySwitchBtnAct(_ sender: UISwitch) {
    }
    
    @IBAction func NextBtnAct(_ sender: UIButton) {
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func uiUpdate(isHiden : Bool){
        playerView.isHidden = isHiden
        titleDefaultLbl.isHidden = isHiden
        titleTxtFild.isHidden = isHiden
        lineView.isHidden = isHiden
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
    
    private func prepareLocalAudio(url: URL) {
        do {
            try audioManager.setupPlayer(with: url)
            waveView.audioURL = url
        } catch {
            print("❌ Failed to set up audio player:", error)
            showErrorAlert(message: "Failed to load audio file")
        }
    }

//    private func downloadAndPrepareAudio(from remoteURL: URL) {
//        let session = URLSession.shared
//        let task = session.downloadTask(with: remoteURL) { [weak self] (tempURL, response, error) in
//            guard let self = self else { return }
//            if let tempURL = tempURL {
//                do {
//                    try self.audioManager.setupPlayer(with: tempURL)
//                    DispatchQueue.main.async {
//                        self.waveView.audioURL = tempURL
//                    }
//                } catch {
//                    print("Failed to setup player: \(error.localizedDescription)")
//                    DispatchQueue.main.async {
//                        self.showErrorAlert(message: "Failed to load audio file")
//                    }
//                }
//            } else {
//                print("Download error: \(error?.localizedDescription ?? "Unknown error")")
//                DispatchQueue.main.async {
//                    self.showErrorAlert(message: "Audio download failed.")
//                }
//            }
//        }
//        task.resume()
//    }
    
    private func downloadAndPrepareAudio(from remoteURL: URL) {
        // Show loading state
        playBtn.isEnabled = false
        
        let session = URLSession.shared
        let task = session.downloadTask(with: remoteURL) { [weak self] (tempURL, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Download error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.playBtn.isEnabled = true
                    self.showErrorAlert(message: "Audio download failed.")
                }
                return
            }
            
            guard let tempURL = tempURL else {
                DispatchQueue.main.async {
                    self.playBtn.isEnabled = true
                    self.showErrorAlert(message: "Audio download failed.")
                }
                return
            }
            
            // Save to permanent location
            let permanentURL = self.saveToPermanentLocation(tempURL: tempURL, originalURL: remoteURL)
            
            DispatchQueue.main.async {
                self.playBtn.isEnabled = true
                if let url = permanentURL {
                    self.waveView.audioURL = url
                    self.waveView.onDurationUpdate = { [weak self] time in
//                        self?.runningDurationLbl.text = time
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

    @IBAction func playAudio(_ sender: UIButton) {
        waveView.isPlaying.toggle()
        playBtn.isSelected = waveView.isPlaying
        playBtn.setImage(UIImage(named: waveView.isPlaying ? "pause-button" : "play-button"), for: .normal)
        if waveView.isPlaying {
            waveView.startPlaybackAnimation()
        } else {
            waveView.stopPlaybackAnimation()
        }
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
extension VoiceCellTV{
    
    //MARK: SETUP RECORDER
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
    
    @IBAction func voice_record() {
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
                parentViewController?.present(alert, animated: true, completion: nil)
            }
            
            
        }
    }
    
    func startRecording() {
        player?.pause()
        choosePreRecordBtnName.isHidden = true
        nextBtnName.isUserInteractionEnabled = false
        voiceRecordImgView.image = UIImage.gifImageWithName("Mic")
        isRecording = true
        recordingStartTime = Date()
        setupRecorder()
        UIApplication.shared.isIdleTimerDisabled = true
        audioRecorder?.record()
        recordingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRecordingTime), userInfo: nil, repeats: true)
    }
    @objc func updateRecordingTime() {
        if let startTime = recordingStartTime {
            let elapsed = Date().timeIntervalSince(startTime)
            if EmergemcySwich.isOn {
                if elapsed >= 30 {
                    stopRecording()
                    duration.text = "00:30"
                } else {
                    let minutes = Int(elapsed) / 60
                    let seconds = Int(elapsed) % 60
                    duration.text = String(format: CommonStringFile.Time_formate, minutes, seconds)
                }
            }else{
                if elapsed >= 180 {
                    stopRecording()
                    duration.text = "03:00"
                } else {
                    let minutes = Int(elapsed) / 60
                    let seconds = Int(elapsed) % 60
                    duration.text = String(format: CommonStringFile.Time_formate, minutes, seconds)
                }
            }
            
        }
    }
    func stopRecording() {
        UIApplication.shared.isIdleTimerDisabled = false
        voiceRecordImgView.image = ImageName.mic1
        nextBtnName.isUserInteractionEnabled = true
        audioRecorder?.stop()
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        playBtn.setImage(ImageName.playbutton, for: .normal)
        if let urls = URL(string: AudioPlayUrl ?? ""){
            // Calculate total recording duration and set Timinglbl
            if let startTime = recordingStartTime {
                let durations = Date().timeIntervalSince(startTime)
                let minutes = Int(durations) / 60
                let seconds = Int(durations) % 60
                duration.text = String(format: CommonStringFile.Time_formate, minutes, seconds)
                let durationString =  duration.text ?? ""
//                let totalSeconds = convertTimeStringToSeconds(durationString)
//                voiceRecordedDuration = totalSeconds
                
            }
            // Set message send time
            let formatter = DateFormatter()
            formatter.timeStyle = .short
//            messageSendTime.text = "\(formatter.string(from: Date()))"
            nextBtnName.isEnabled = duration.text == "00:00" ? false:true
            choosePreRecordBtnName.isHidden = duration.text == "00:00" ? false:true
            PlayVoiceRecoredFile(url: urls)
           
        }
        
    }
    
    func PlayVoiceRecoredFile(url: URL){
        if url.isFileURL {
            do {
                try audioManager.setupPlayer(with: url)
                waveView.audioURL = url
                uiUpdate(isHiden: false)
            } catch {
                print("❌ Failed to set up audio player:", error)
            }
        } else {
            // Remote URL - download it first
            downloadAndPrepareAudio(from: url)
        }
    }
}
