//
//  ParentCommunicationVc.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

enum CommunicationMessageType {
    case all
    case voice
    case text
}

enum ReadStatus{
    case all
    case read
    case unread
}


import UIKit
import AVFoundation

class ParentCommunicationVc: UIViewController, AudioPlaybackDelegate1, Datepicker{
    
    
    func audioCell(_ cell: CommunicationTVC, willStartPlayingAtIndex index: Int) {
        
        playIndex = index
        // Safety check
        guard displayedMessages.indices.contains(index) else { return }
        
        let message = displayedMessages[index]
        
        // Mark message as read
        if message.is_unread == true {
            cell.newImageView.isHidden = true
            
            let type = message.type ?? ""
            let id = message.id ?? ""
            
            if message.is_archive == true {
                ReadStatusUpdateArchive(type: type, detail_id: id)
            } else {
                ReadStatusUpdate(type: type, detail_id: id)
            }
        }
        
        // Stop playback for reused cells
        if cell.cellIndex != index {
            cell.stopPlayback()
        }
    }
    
    
    func audioCell(_ cell: CommunicationTVC, didStopPlayingAtIndex index: Int) {
        if playIndex == index {
            playIndex = nil
        }
    }
    
    @IBOutlet weak var ReadUnreadStack: UIStackView!
    @IBOutlet weak var UnreadBtn: UIButton!
    @IBOutlet weak var ReadBtn: UIButton!
    @IBOutlet weak var AllBtn: UIButton!
    @IBOutlet weak var FilterCV: UICollectionView!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var NodataLbl: UILabel!
    @IBOutlet weak var FilterImage: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var NodataImgHeight: NSLayoutConstraint!
    @IBOutlet weak var SearchbarStack: UIStackView!
    @IBOutlet weak var menuNameLbl: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var fromDateView: UIView!
    @IBOutlet weak var toDateView: UIView!
    @IBOutlet weak var fromDateLbl: UILabel!
    @IBOutlet weak var toDateLbl: UILabel!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var DateFilterStack: UIStackView!
    
   
    var shouldShowFooter = true
    var shouldShowFooterLabel = false
    var ArchiveMessage = ""
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var allMessages: [CommunicationReciverData] = []
    var displayedMessages: [CommunicationReciverData] = []
    var dropDown = DropDown()
    let dateFormatter = DateFormatter()
    let Filters = ["All","VOICE","TEXT"/*,"Read","Unread"*/]
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    var clickedMessageId : String?
    var playIndex: Int?
//    var lastPlaybackTime: CMTime?
//    var lastMessageId: String?
    private let threshold = 120
    private let viewText = "View"
    private let seeMoreText = "See more"
    private let seeLessText = "See less"
    var isFromDate = false
    var selectedReadStatus: ReadStatus = .all
    var selectedMessageType: CommunicationMessageType = .all
    var fromDate: Date?
    var toDate: Date?
    var currentSearchText: String = ""
    
    var tourKey = "ParentCommunication"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StyleAndTranslate()
        SearchBar.delegate = self
        SearchBar.searchTextField.addDoneButton()
        SearchBar.placeholder = CommonStringFile.Search
        SearchBar.backgroundImage = UIImage()
        TitleLbl.configureAsBackTitle(firstLine: "\(studentDetails?.name ?? "")", secondLine:"\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")")
        menuNameLbl.text = MenuStringFile.selectedMenuName
        backBtn.applyBackButton()
        RegisterCell()
        getCommunicationList()
        fromDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectFromDate)))
        toDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SelectToDate)))
        let Filtertap = UITapGestureRecognizer(target: self, action: #selector(filter))
        FilterImage.addGestureRecognizer(Filtertap)
        FilterImage.isUserInteractionEnabled = true
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
        FilterCV.delegate = self
        FilterCV.dataSource = self
        if !UserDefaults.standard.bool(forKey: tourKey){
            DispatchQueue.main.asyncAfter(deadline:.now() + 0.5){
                let vc = AppTourVC()
                vc.modalPresentationStyle = .overFullScreen
                vc.tourKey = self.tourKey
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        tv.beginUpdates()
        tv.endUpdates()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for cell in tv.visibleCells {
            if let historyCell = cell as? HistoryTC {
                historyCell.stopAudioPlayback()
            }
        }
    }
    //MARK: StyleAndTranslate
    func StyleAndTranslate(){
        
        FilterCV.isHidden = true
        ReadUnreadStack.isHidden = true
        SearchbarStack.isHidden = true
        DateFilterStack.isHidden = true
        clearBtn.isHidden = true
        
        ReadBtn.layer.cornerRadius = 12
        UnreadBtn.layer.cornerRadius = 12
        AllBtn.layer.cornerRadius = 12
        
        AllBtn.backgroundColor = .systemGreen.withAlphaComponent(0.4)
        
        ReadBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        UnreadBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        AllBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        NodataLbl.isHidden = true
        NodataImage.isHidden = true
        NodataLbl.setFont(style: .title, size: 17)
        
        applyShadowAndCornerRadius(to: fromDateView, cornerRadius: 6)
        applyShadowAndCornerRadius(to: toDateView, cornerRadius: 6)
        toDateLbl.setFont(style: .title, size: FontSize.BodySize)
        fromDateLbl.setFont(style: .title, size: FontSize.BodySize)
        fromDateLbl.textColor = .darkGray
        toDateLbl.textColor = .darkGray
    }
    
    //MARK: Cell registration
    func RegisterCell(){
        let nib = UINib(nibName: CellConfingName.TextHistoryTVCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier: CellConfingName.TextHistoryTVCell)
        
        let nib2 = UINib(nibName: "CommunicationTVC", bundle: nil)
        tv.register(nib2, forCellReuseIdentifier: "CommunicationTVC")
        
        let footerNib = UINib(nibName:CellConfingName.SeeMoreFooterView , bundle: nil)
        tv.register(footerNib, forHeaderFooterViewReuseIdentifier: CellConfingName.SeeMoreFooterView)
        
        let cvnib = UINib(nibName:CellConfingName.FiltersCvCell , bundle: nil)
        FilterCV.register(cvnib, forCellWithReuseIdentifier: CellConfingName.FiltersCvCell)
    }
    func deleteDelegate(index: Int) {
        ""
    }
    /*func reload(index: Int) {
        let message = displayedMessages[index]
        if let currentIndex = playIndex, currentIndex != index {
            let previousIndexPath = IndexPath(row: currentIndex, section: 0)
            if let previousCell = tv.cellForRow(at: previousIndexPath) as? HistoryTC {
                displayedMessages[currentIndex].playbackSeconds = previousCell.player?.currentTime().seconds
                previousCell.player?.pause()
                previousCell.playBtn.setImage(ImageName.playbutton, for: .normal)
                previousCell.updatePlayState(isPlaying: false, url: nil)
            }
        }
        
        let isSameIndex = (playIndex == index)
        playIndex = isSameIndex ? nil : index
        
        let currentIndexPath = IndexPath(row: index, section: 0)
        guard let currentCell = tv.cellForRow(at: currentIndexPath) as? HistoryTC else { return }
        
        if isSameIndex {
            if let time = currentCell.player?.currentTime() {
                displayedMessages[index].playbackSeconds = time.seconds
            }
            currentCell.player?.pause()
            currentCell.updatePlayState(isPlaying: false, url: nil)
        } else {
            let resumeTime = displayedMessages[index].playbackSeconds ?? 0
            currentCell.updatePlayState(isPlaying: true, url: message.content)
            
            if resumeTime > 0 {
                let seekTime = CMTime(seconds: resumeTime, preferredTimescale: 600)
                currentCell.player?.seek(to: seekTime) { _ in
                    currentCell.player?.play()
                }
            }
            
            if message.is_unread ?? false{
                currentCell.NewImageView.isHidden = true
                if message.is_archive ?? false{
                    ReadStatusUpdate(type: message.type ?? "", detail_id: message.id ?? "")
                }else{
                    ReadStatusUpdateArchive(type: message.type ?? "", detail_id: message.id ?? "")
                }
            }
        }
    }
    
    func didFinishPlaying(at index: Int) {
        if playIndex == index {
            playIndex = nil
        }
        displayedMessages[index].playbackSeconds = 0
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = tv.cellForRow(at: indexPath) as? HistoryTC {
            cell.updatePlayState(isPlaying: false, url: nil)
        }
    }
    func savePlaybackStateBeforeReload() {
        if let index = playIndex {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tv.cellForRow(at: indexPath) as? HistoryTC {
                lastPlaybackTime = cell.player?.currentTime()
                lastMessageId = displayedMessages[index].id
            }
        }
    }
    func restorePlaybackStateAfterReload() {
        if let id = lastMessageId,
           let index = displayedMessages.firstIndex(where: { $0.id == id }),
           let time = lastPlaybackTime {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tv.cellForRow(at: indexPath) as? HistoryTC {
                cell.updatePlayState(isPlaying: true,
                                     url: displayedMessages[index].content)
                cell.player?.seek(to: time)
            }
        }
    }
    
    
    func pauseCurrentAudioBeforeReload() {
        if let index = playIndex {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tv.cellForRow(at: indexPath) as? HistoryTC {
                lastPlaybackTime = cell.player?.currentTime()
                lastMessageId = displayedMessages[index].id
                if let time = cell.player?.currentTime() {
                    displayedMessages[index].playbackSeconds = time.seconds
                }
                cell.player?.pause()
                cell.playBtn.setImage(ImageName.playbutton, for: .normal)
                cell.updatePlayState(isPlaying: false, url: nil)
            }
            playIndex = nil
        }
    } */
    
    private func stopPlayingAudioIfNeeded() {
        
        guard let index = playIndex else { return }
        
        let indexPath = IndexPath(row: index, section: 0)
        
        if let cell = tv.cellForRow(at: indexPath) as? CommunicationTVC {
            cell.stopPlayback()
        }
        
        playIndex = nil
    }
    
    
    
    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    //MARK: Filter Buttons Actions
    
    @IBAction func allAction(_ sender: Any) {
        updateFilterButtons(selected: AllBtn)
        selectedReadStatus = .all
        applyFilters()
    }
    
    @IBAction func readAction(_ sender: Any) {
        updateFilterButtons(selected: ReadBtn)
        selectedReadStatus = .read
        applyFilters()
    }
    
    @IBAction func unreadAction(_ sender: Any) {
        updateFilterButtons(selected: UnreadBtn)
        selectedReadStatus = .unread
        applyFilters()
    }
    
    private lazy var apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"   // API: 05-01-2026 09:55 AM
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    private lazy var pickerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"          // Picker: 05 Jan 2026
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    @IBAction func SelectFromDate(){
        isFromDate = true
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.date = fromDateLbl.text
        if let maxDate = toDate{
            vc.maximumDate = maxDate
        }else{
            vc.maximumDate = Date()
        }
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    @IBAction func SelectToDate(){
        isFromDate = false
        let vc = DatePickerVC(nibName: nil, bundle: nil)
        vc.dateSelection = 2
        vc.date = toDateLbl.text
        vc.maximumDate = Date()
        if let minDate = fromDate{
            vc.minimumDate = minDate
        }
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.present(vc, animated: false)
    }
    
    func date(date: String) {
        if isFromDate {
            fromDateLbl.text = date
            fromDateLbl.textColor = .black
            fromDate = pickerDateFormatter.date(from: date)
        } else {
            toDateLbl.text = date
            toDateLbl.textColor = .black
            toDate = pickerDateFormatter.date(from: date)
        }
        clearBtn.isHidden = false
        applyFilters()
    }
  
    @IBAction func clearBtnAct(_ sender: Any) {
        
        fromDate = nil
        toDate = nil
        fromDateLbl.text = "--From date--"
        toDateLbl.text = "--To date--"
        fromDateLbl.textColor = .darkGray
        toDateLbl.textColor = .darkGray
        applyFilters()
        clearBtn.isHidden = true
    }
    
    @IBAction func filter(_ sender: UIButton) {
        
        FilterCV.isHidden.toggle()
        ReadUnreadStack.isHidden.toggle()
        DateFilterStack.isHidden.toggle()
        if DateFilterStack.isHidden{
            clearBtn.isHidden = true
        }else{
            clearBtn.isHidden = !(fromDate != nil || toDate != nil)
        }
    }
    
    func updateFilterButtons(selected button: UIButton) {
        [AllBtn, ReadBtn, UnreadBtn].forEach { btn in
            btn?.backgroundColor = (btn == button) ? .systemGreen.withAlphaComponent(0.4) : .white
        }
    }
    
    //    func applyFilters() {
    //        let selectedType = (selectedIndex.row == 0) ? nil : Filters[selectedIndex.row]
    //        displayedMessages = allMessages.filtered(readStatus: selectedReadStatus, type: selectedType)
    //        playIndex = nil
    //        updateUIAfterFiltering()
    //    }
    
    
    func getCommunicationList() {
        if #available(iOS 15.0, *) {
            self.showActivityLoader()
        }
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_list, parameters: [:], type: ApitTypeSringFile.GET, token: studentDetails?.access_token ?? "", isBaseUrl: false) { [weak self] (result : Result<CommunicationReciverResponse,Error>) in
            
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let SuccessMessage):
                    if SuccessMessage.status == true {
                        self.allMessages = SuccessMessage.data ?? []
                        self.displayedMessages = self.allMessages
                        self.NodataLbl.isHidden = true
                        self.NodataImage.isHidden = true
                        self.searchBtn.isHidden = false
                        self.tv.reloadData()
                        if self.clickedMessageId != ""{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.scrollToClickedMessage()
                            }
                        }
                        
                    }else {
                        
                        self.allMessages = []
                        self.displayedMessages = self.allMessages
                        self.NodataLbl.text = SuccessMessage.message
                        self.NodataLbl.isHidden = false
                        self.NodataImage.isHidden = false
                        self.searchBtn.isHidden = true
                        self.tv.isScrollEnabled = false
                        self.tv.reloadData()
                    }
                    
                case .failure(let error):
                    
                    self.allMessages = []
                    self.displayedMessages = self.allMessages
                    self.NodataLbl.text = error.localizedDescription
                    self.NodataLbl.isHidden = false
                    self.NodataImage.isHidden = false
                    self.searchBtn.isHidden = true
                    self.tv.isScrollEnabled = false
                    self.tv.reloadData()
                }
                
                self.hideActivityLoader()
            }
        }
    }
    
    private func scrollToClickedMessage() {
        guard let id = clickedMessageId,
              let index = displayedMessages.firstIndex(where: { $0.header_id == id }) else {
            return
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        tv.scrollToRow(at: indexPath, at: .middle, animated: true)
        if let cell = tv.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.3, animations: {
                cell.contentView.backgroundColor = UIColor.lightGray
                    .withAlphaComponent(0.3)
            }) { _ in
                UIView.animate(withDuration: 0.5, delay: 1.0, options: []) {
                    cell.contentView.backgroundColor = .white
                }
            }
        }
    }
    
    func GetArchiveCommunicationList() {
        
        showActivityLoader()
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_communication_list_archive,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: studentDetails?.access_token ?? "", isBaseUrl: false
        ) { [weak self] (result: Result<CommunicationReciverResponse, Error>) in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let response):
                DispatchQueue.main.async {
                    if response.status == true {
                        self.allMessages.append(contentsOf: response.data ?? [])
                        self.applyFilters()
//                        self.NodataLbl.isHidden = true
//                        self.NodataImage.isHidden = true
                        self.shouldShowFooterLabel = false
                        self.tv.isHidden = false
                        self.searchBtn.isHidden = false
                        self.tv.isScrollEnabled = true
                    
                    } else {
                        self.tv.reloadData()
                        
                        if self.allMessages.isEmpty {
                            self.NodataLbl.text = response.message
                            self.shouldShowFooterLabel = false
                            self.tv.isHidden = true
                            self.searchBtn.isHidden = true
                            self.NodataImage.isHidden = false
                            self.NodataLbl.isHidden = false
                        } else {
                            self.ArchiveMessage = response.message ?? ""
                            self.shouldShowFooterLabel = true
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    self.tv.reloadData()
                    //self.restorePlaybackStateAfterReload()
                    
                    if self.allMessages.isEmpty {
                        self.NodataLbl.text = error.localizedDescription
                        self.tv.isHidden = true
                        self.searchBtn.isHidden = true
                        self.NodataImage.isHidden = false
                        self.NodataLbl.isHidden = false
                        self.shouldShowFooterLabel = false
                    } else {
                        self.ArchiveMessage = error.localizedDescription
                        self.shouldShowFooterLabel = true
                    }
                }
            }
            
            self.hideActivityLoader()
        }
    }
    
    
    func ReadStatusUpdate(type: String,detail_id: String) {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "", isBaseUrl: true) { [self] (result : Result<ReadStatusResponse,Error>) in
            
            switch result {
            case .success(let SuccessMessage):
                if SuccessMessage.status == true {
                    DispatchQueue.main.async { [weak self] in
                        if let index = self?.displayedMessages.firstIndex(where: {$0.id == detail_id}) {
                            self?.displayedMessages[index].is_unread = false
                        }
                    }
                }
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func ReadStatusUpdateArchive(type: String,detail_id: String){
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update_archive, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "", isBaseUrl: true) { [weak self] (result : Result<ReadStatusResponse,Error>) in
            
            guard let self = self else {return}
            
            switch result {
            case .success(let SuccessMessage):
                if SuccessMessage.status == true {
                    DispatchQueue.main.async { [weak self] in
                        if let index = self?.displayedMessages.firstIndex(where: {$0.id == detail_id}) {
                            self?.displayedMessages[index].is_unread = false
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func SearchBtnAct(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        if sender.isSelected{
            SearchbarStack.isHidden = false
            sender.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        }else {
            displayedMessages = allMessages
            tv.reloadData()
            SearchbarStack.isHidden = true
            SearchBar.searchTextField.text = ""
            currentSearchText = ""
            selectedReadStatus = .all
            selectedMessageType = .all
            fromDate = nil
            toDate = nil
            fromDateLbl.text = "--From date--"
            toDateLbl.text = "--To date--"
            fromDateLbl.textColor = .darkGray
            toDateLbl.textColor = .darkGray
            SearchBar.resignFirstResponder()
            sender.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            FilterCV.isHidden = true
            ReadUnreadStack.isHidden = true
            DateFilterStack.isHidden = true
            clearBtn.isHidden = true
            NodataImage.isHidden = true
            NodataLbl.isHidden = true
            AllBtn.backgroundColor = .systemGreen.withAlphaComponent(0.4)
            ReadBtn.backgroundColor = .white
            UnreadBtn.backgroundColor = .white
            selectedIndex = IndexPath(item: 0, section: 0)
            FilterCV.reloadData()
        }
    }
}

//MARK: Tableview Functions
extension ParentCommunicationVc : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return displayedMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = displayedMessages[indexPath.row]
        
        switch message.type?.uppercased() {
            
        case "TEXT":
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.TextHistoryTVCell, for: indexPath) as! TextHistoryTVCell
            cell.sendBtnheight.constant = 0
            cell.sendBtnWidth.constant = 0
            cell.DateLabel.textAlignment = .right
            cell.sendBtn.isHidden = true
            cell.NewImageView.isHidden = true
            cell.descriptContent.tag = indexPath.row
            cell.descriptContent.isUserInteractionEnabled = true
            cell.PostedByLbl.isHidden = false
            cell.PostedByLbl.text = "Posted By - \(message.sent_by ?? "")"
            cell.MessageTitle.text = message.title
            let formattedDateString = dateFormatter.convertDate(message.date ?? "") ?? ""
            cell.DateLabel.setStyledDateTime(dateString: formattedDateString, timeString: message.time)
            cell.descriptContent.attributedText = self.descript(
                for: message.content ?? "",
                expanded: message.isExpand ?? false,
                isUnread: message.is_unread ?? false
            )
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleLabelTap(_:)))
            cell.descriptContent.addGestureRecognizer(tapGesture)
            cell.layoutIfNeeded()
            cell.configureShimmer()
            if message.is_unread == true{
                cell.newImageOuterView.isHidden = false
                cell.NewImageView.isHidden = false
            }else {
                cell.newImageOuterView.isHidden = true
                cell.NewImageView.isHidden = true
            }
            return cell
            
        case "VOICE":
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommunicationTVC", for: indexPath) as! CommunicationTVC
            let voiceData = message
            cell.emergencyBtnName.isHidden = !(voiceData.is_emergency ?? false)
            let formattedDateString = dateFormatter.convertDate(message.date ?? "") ?? ""
            cell.dateLbl.setStyledDateTime(dateString: formattedDateString, timeString: message.time)
            cell.waveView.durationLabel.isHidden = true
            cell.PostedByLbl.isHidden = false
            cell.PostedByLbl.text = "Posted By - \(voiceData.sent_by ?? "")"
            cell.titleLbl.text = voiceData.title
            let duration = voiceData.duration ?? 0
            let formattedDuration = formatDuration(duration)
            cell.tottalDurationLbl.text = formattedDuration
            cell.newImageView.isHidden = !(message.is_unread ?? false)
            configureAudioCell(cell, at: indexPath)
            message.loadFile = true
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    private func configureAudioCell(_ cell: CommunicationTVC, at indexPath: IndexPath) {
        //        if displayedMessages[indexPath.item].loadFile != true{
        let file = displayedMessages[indexPath.item]
        let url = URL(string: file.content ?? "")
        cell.audioURL = url
        cell.audioDelegate = self
        cell.cellIndex = indexPath.item
        cell.waveView.setParentCell(cell)
        //            displayedMessages[indexPath.item].loadFile = true
        //        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView()
        footerView.backgroundColor = .clear
        
        if shouldShowFooter {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.titleLabel?.textAlignment = .right
            let title = "See Archived Messages"
            let attributedTitle = NSAttributedString(
                string: title,
                attributes: [
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.systemFont(ofSize: 16, weight: .medium)
                ]
            )
            button.setAttributedTitle(attributedTitle, for: .normal)
            button.addTarget(self, action: #selector(seeArchivedMessagesTapped(_:)), for: .touchUpInside)
            footerView.addSubview(button)
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(greaterThanOrEqualTo: footerView.leadingAnchor, constant: 16),
                button.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
                button.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 8),
                button.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -8)
            ])
            
        }else if shouldShowFooterLabel{
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = ArchiveMessage
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textColor = .black
            label.textAlignment = .center
            label.numberOfLines = 0
            footerView.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
                label.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 20),
                label.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -20),
                label.centerXAnchor.constraint(equalTo: footerView.centerXAnchor)
            ])
        }
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (shouldShowFooter || shouldShowFooterLabel) ? UITableView.automaticDimension : 0.01
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    @objc private func seeArchivedMessagesTapped(_ sender: UIButton) {
        GetArchiveCommunicationList()
        SearchBar.searchTextField.text = ""
        shouldShowFooter = false
    }
    
    
    @objc func handleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard
            let label = gesture.view as? UILabel,
            let text = label.attributedText?.string
        else { return }
        
        let ranges = [viewText,seeMoreText,seeLessText].map { (text as NSString).range(of: $0) }
        
        if ranges.contains(where: { gesture.didTapAttributedTextInLabel(label: label, inRange: $0) }) {
            handleSeeMoreTap(gesture)
        }
    }
    
    
    @objc func handleSeeMoreTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        
        let indexPath = IndexPath(row: label.tag, section: 0)
        var message = displayedMessages[indexPath.row]
        
        guard let fullDescription = message.content else { return }
        
        let threshold = 120
        let isLong = fullDescription.count > threshold
        
        if message.isExpand == nil {
            message.isExpand = false
        }
        
        if message.is_unread == true {
            // First tap on unread
            message.is_unread = false
            message.isExpand = isLong
            
            if message.is_archive ?? false {
                ReadStatusUpdateArchive(type: message.type ?? "", detail_id: message.id ?? "")
            } else {
                ReadStatusUpdate(type: message.type ?? "", detail_id: message.id ?? "")
            }
        } else if isLong {
            // Toggle only for long text
            message.isExpand!.toggle()
        }
        
        label.attributedText = descript(
            for: fullDescription,
            expanded: message.isExpand ?? false,
            isUnread: message.is_unread ?? false
        )
        
        displayedMessages[indexPath.row] = message
        
        if let cell = tv.cellForRow(at: indexPath) as? TextHistoryTVCell {
            cell.NewImageView.isHidden = true
            cell.newImageOuterView.isHidden = true
        }
        
        tv.beginUpdates()
        tv.endUpdates()
    }
    
    
    
    func descript(
        for fullDescription: String,
        expanded: Bool,
        isUnread: Bool
    ) -> NSAttributedString {
        
        let threshold = 120
        let isLong = fullDescription.count > threshold
        
        var displayText = fullDescription
        var actionText: String?
        
        // UNREAD: always collapsed + "View"
        if isUnread {
            if isLong {
                displayText = String(fullDescription.prefix(threshold))
            }
            actionText = "View"
        }
        // READ
        else {
            if isLong {
                if expanded {
                    displayText = fullDescription
                    actionText = "See less"
                } else {
                    displayText = String(fullDescription.prefix(threshold))
                    actionText = "See more"
                }
            } else {
                // Short text, read → show nothing extra
                displayText = fullDescription
            }
        }
        
        let finalString: String
        if let action = actionText {
            finalString = displayText + " " + action
        } else {
            finalString = displayText
        }
        
        let attributed = NSMutableAttributedString(string: finalString)
        
        if let action = actionText {
            let range = (finalString as NSString).range(of: action)
            attributed.addAttribute(.foregroundColor, value: UIColor.link, range: range)
        }
        
        return attributed
    }
    
    
    
    // Method to load the footer from nib and set it as tableFooterView
    func setupTableFooter() {
        if shouldShowFooter {
            if let footer = Bundle.main.loadNibNamed("SeeMoreFooterView", owner: self, options: nil)?.first as? SeeMoreFooterView {
                footer.frame = CGRect(x: 0, y: 0, width: tv.frame.width, height: 200)
                let buttonTitle = "See More"
                let attributedString = NSMutableAttributedString(string: buttonTitle)
                let customFont = UIFont(name: "Poppins-Medium", size: 17) ?? UIFont.systemFont(ofSize: 18)
                attributedString.addAttribute(.font, value: customFont, range: NSRange(location: 0, length: buttonTitle.count))
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: buttonTitle.count))
                footer.SeeMoreBtn.setAttributedTitle(attributedString, for: .normal)
                let seeMoreTap = UITapGestureRecognizer(target: self, action: #selector(seeMoreAction))
                footer.SeeMoreBtn.addGestureRecognizer(seeMoreTap)
                footer.SeeMoreBtn.isUserInteractionEnabled = true
                tv.tableFooterView = footer
            }
        } else {
            tv.tableFooterView = nil
        }
    }
    
    @objc func seeMoreAction() {
        print("Footer button tapped. Hiding the footer.")
        
        if let footer = tv.tableFooterView {
            UIView.animate(withDuration: 0.3, animations: {
                footer.alpha = 0
            }, completion: {[self] _ in
                GetArchiveCommunicationList()
                tv.tableFooterView = nil
                shouldShowFooter = false
            })
        } else {
            shouldShowFooter = false
        }
    }
}

extension ParentCommunicationVc : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = FilterCV.dequeueReusableCell(withReuseIdentifier: CellConfingName.FiltersCvCell, for: indexPath) as! FiltersCvCell
        cell.cellView.backgroundColor = .white
        cell.FilterLbl.text = Filters[indexPath.item]
        
        cell.CheckboxImg.image = indexPath == selectedIndex ? UIImage(named: "RadioCheck") : UIImage(named: "CheckCircle")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath
        switch selectedIndex.item {
        case 0:
            selectedMessageType = .all
        case 1:
            selectedMessageType = .voice
        case 2:
            selectedMessageType = .text
        default:
            selectedMessageType = .all
        }
        applyFilters()
        FilterCV.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let text = Filters[indexPath.item]
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = text
        label.sizeToFit()
        
        let width = label.frame.width + 60
        return CGSize(width: width, height: 40)
    }
}

extension ParentCommunicationVc : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //stopPlayingAudioIfNeeded()
        
        //        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        //        let baseList = allMessages.filtered(readStatus: selectedReadStatus, type: selectedFilterType)
        //        if trimmedText.isEmpty {
        //            displayedMessages = baseList
        //        } else {
        ////            displayedMessages = baseList.filter { msg in
        ////                let date = dateFormatter.convertDate(msg.date ?? "")?.lowercased() ?? ""
        ////                return [msg.title, msg.content, msg.type, date]
        ////                    .map { $0?.lowercased() }
        ////                    .contains { $0.contains(trimmedText) }
        ////            }
        //            displayedMessages = baseList.filter { msg in
        //                let date = dateFormatter
        //                    .convertDate(msg.date ?? "")?
        //                    .lowercased() ?? ""
        //
        //                let searchableFields = [
        //                    msg.title,
        //                    msg.content,
        //                    msg.type,
        //                    date
        //                ]
        //                .compactMap { $0?.lowercased() }
        //
        //                return searchableFields.contains { $0.contains(trimmedText) }
        //            }
        //        }
        //
        //       updateUIAfterFiltering()
        
        currentSearchText = searchText
        applyFilters()
    }
    
    private func applyFilters() {
        
        stopPlayingAudioIfNeeded()
        displayedMessages = allMessages.filter { item in
            
            // MARK: - Text Filter
            let textMatch: Bool = {
                guard !currentSearchText.isEmpty else { return true }
                let text = currentSearchText.lowercased()
                return (item.title?.lowercased().contains(text) ?? false) ||
                (item.content?.lowercased().contains(text) ?? false) ||
                (item.type?.lowercased().contains(text) ?? false) ||
                (item.date?.convertToTargetDateFormat()?.lowercased().contains(text) ?? false)
            }()
            
            // MARK: - Read / Unread Filter
            let readMatch: Bool = {
                switch selectedReadStatus {
                case .all:
                    return true
                case .read:
                    return item.is_unread == false
                case .unread:
                    return item.is_unread == true
                }
            }()
            
            // MARK: - message type
            let typeMatch : Bool = {
                switch selectedMessageType{
                case .all:
                    return true
                case .text:
                    return item.type == "TEXT"
                case .voice:
                    return item.type == "VOICE"
                }
            }()
            
            
            // MARK: - Date Filter
            let dateMatch: Bool = {
                guard let apiDateString = item.date,
                      let apiDateTime = apiDateFormatter.date(from: apiDateString)
                else { return true }
                
                let calendar = Calendar.current
                let itemDay = calendar.startOfDay(for: apiDateTime)
                
                if let from = fromDate,
                   itemDay < calendar.startOfDay(for: from) {
                    return false
                }
                
                if let to = toDate,
                   itemDay > calendar.startOfDay(for: to) {
                    return false
                }
                
                return true
            }()
            
            return textMatch && readMatch && dateMatch && typeMatch
        }
        
        updateUIAfterFiltering()
    }
    
    private func updateUIAfterFiltering() {
        let isEmpty = displayedMessages.isEmpty
        NodataLbl.isHidden = !isEmpty
        NodataImage.isHidden = !isEmpty
        NodataLbl.text = "No Data Found"
        tv.isScrollEnabled = !isEmpty
        tv.reloadData()
    }
}

extension Array where Element == CommunicationReciverData {
    func filtered(readStatus: Int, type: String?) -> [CommunicationReciverData] {
        self.filter { msg in
            let matchesType = type == nil || msg.type?.caseInsensitiveCompare(type!) == .orderedSame
            let matchesReadStatus: Bool = {
                switch readStatus {
                case 1: return !(msg.is_unread ?? false)
                case 2: return msg.is_unread ?? false
                default: return true
                }
            }()
            return matchesType && matchesReadStatus
        }
    }
}
