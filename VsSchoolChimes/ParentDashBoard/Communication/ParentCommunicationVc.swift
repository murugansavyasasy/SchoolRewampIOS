//
//  ParentCommunicationVc.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit
import DropDown
import AVFoundation

class ParentCommunicationVc: UIViewController, reloadDelegate, HistoryFinishPalyingDelegate{
    
    func deleteDelegate(index: Int) {
        
    }
        var playIndex: Int?
        var lastPlaybackTime: CMTime?
        var lastMessageId: String?

    /// To save and resume audio playback progress per message, you can modify the code in `reload(index:)`
    /// and `didFinishPlaying(at:)` while tracking playback time in your `displayedMessages` array.

    func reload(index: Int) {
        let message = displayedMessages[index]
        let messageId = message.id

        // Pause previous cell if switching
        if let currentIndex = playIndex, currentIndex != index {
            let previousIndexPath = IndexPath(row: currentIndex, section: 0)
            if let previousCell = tv.cellForRow(at: previousIndexPath) as? HistoryTC {
                // ✅ Save playback time before pausing
                displayedMessages[currentIndex].playbackSeconds = previousCell.player?.currentTime().seconds
                previousCell.player?.pause()
                previousCell.playBtn.setImage(ImageName.playbutton, for: .normal)
                previousCell.playerView.updateWithLevel(0.0)
            }
        }

        // Toggle playback
        let isSameIndex = (playIndex == index)
        playIndex = isSameIndex ? nil : index

        let currentIndexPath = IndexPath(row: index, section: 0)
        guard let currentCell = tv.cellForRow(at: currentIndexPath) as? HistoryTC else { return }

        if isSameIndex {
            // ✅ Pause and save playback time
            if let time = currentCell.player?.currentTime() {
                displayedMessages[index].playbackSeconds = time.seconds
            }
            currentCell.player?.pause()
            currentCell.updatePlayState(isPlaying: false, url: nil)
        } else {
            // ✅ Resume playback from saved time
            let resumeTime = displayedMessages[index].playbackSeconds ?? 0
            currentCell.updatePlayState(isPlaying: true, url: message.content)

            if resumeTime > 0 {
                let seekTime = CMTime(seconds: resumeTime, preferredTimescale: 600)
                currentCell.player?.seek(to: seekTime) { _ in
                    currentCell.player?.play()
                }
            }

            currentCell.NewImageView.isHidden = true
            ReadStatusUpdateArchive(type: "Voice", detail_id: messageId)
        }
    }

    func didFinishPlaying(at index: Int) {
        print("didFinishPlaying")
        if playIndex == index {
            playIndex = nil
        }
        // ✅ Reset saved playback time when finished
        displayedMessages[index].playbackSeconds = 0

        let indexPath = IndexPath(row: index, section: 0)
        if let cell = tv.cellForRow(at: indexPath) as? HistoryTC {
            cell.updatePlayState(isPlaying: false, url: nil)
        }
    }



        // Before reload (search/filter/archive)
        func savePlaybackStateBeforeReload() {
            if let index = playIndex {
                let indexPath = IndexPath(row: index, section: 0)
                if let cell = tv.cellForRow(at: indexPath) as? HistoryTC {
                    lastPlaybackTime = cell.player?.currentTime()
                    lastMessageId = displayedMessages[index].id
                }
            }
        }

        // After reload
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
            // ✅ Clear playIndex so reload doesn’t auto-play
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
    
    
    //var playIndex :Int?
    var AudioPlayUrl: String?
    var passValue = 0
    var count = 5
    var shouldShowFooter = true
    var shouldShowFooterLabel = false
    var ArchiveMessage = ""
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var allMessages: [CommunicationReciverData] = []     // Master list
    var displayedMessages: [CommunicationReciverData] = [] // Filtered + searched data
    var dropDown = DropDown()
    let dateFormatter = DateFormatter()
    let Filters = ["All","VOICE","TEXT"/*,"Read","Unread"*/]
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    
    var readStatus = 0  //All = 0, read = 1, unread = 2
    var selectedFilterType: String?
    
    var showfilter = false
    var clickedMessageId : String?
   // var lastPlaybackTime: CMTime?
    
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
        
        //setupTableFooter()
        
        getCommunicationList()
      
        let Filtertap = UITapGestureRecognizer(target: self, action: #selector(filter))
        FilterImage.addGestureRecognizer(Filtertap)
        FilterImage.isUserInteractionEnabled = true
       
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
        
        FilterCV.delegate = self
        FilterCV.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        
        tv.beginUpdates()
        tv.endUpdates()
    }
    
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop audio for all visible cells
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
        
    }
    
    //MARK: Cell registration
    func RegisterCell(){
        let nib = UINib(nibName: CellConfingName.TextHistoryTVCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier: CellConfingName.TextHistoryTVCell)
        
        let nib2 = UINib(nibName: CellConfingName.HistoryTC, bundle: nil)
        tv.register(nib2, forCellReuseIdentifier: CellConfingName.HistoryTC)
        
        let footerNib = UINib(nibName:CellConfingName.SeeMoreFooterView , bundle: nil)
        tv.register(footerNib, forHeaderFooterViewReuseIdentifier: CellConfingName.SeeMoreFooterView)
        
        let cvnib = UINib(nibName:CellConfingName.FiltersCvCell , bundle: nil)
        FilterCV.register(cvnib, forCellWithReuseIdentifier: CellConfingName.FiltersCvCell)
    }

    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    //MARK: Filter Buttons Actions
    
    @IBAction func allAction(_ sender: Any) {
        pauseCurrentAudioBeforeReload()
        updateFilterButtons(selected: AllBtn)
        readStatus = 0
        applyFilters()
    }

    @IBAction func readAction(_ sender: Any) {
        pauseCurrentAudioBeforeReload()
        updateFilterButtons(selected: ReadBtn)
        readStatus = 1
        applyFilters()
    }

    @IBAction func unreadAction(_ sender: Any) {
        pauseCurrentAudioBeforeReload()
        updateFilterButtons(selected: UnreadBtn)
        readStatus = 2
        applyFilters()
    }


    
    @IBAction func filter(_ sender: UIButton) {
        
        FilterCV.isHidden.toggle()
        ReadUnreadStack.isHidden.toggle()
    }
    
    func updateFilterButtons(selected button: UIButton) {
        [AllBtn, ReadBtn, UnreadBtn].forEach { btn in
            btn?.backgroundColor = (btn == button) ? .systemGreen.withAlphaComponent(0.4) : .white
        }
    }

    /// Applies read/unread/type filters together
    func applyFilters() {
        // Determine message type from selected index
        let selectedType = (selectedIndex.row == 0) ? nil : Filters[selectedIndex.row]
        
        // Filter allMessages according to readStatus + message type
        displayedMessages = allMessages.filtered(readStatus: readStatus, type: selectedType)
        
        // Reset playback
        playIndex = nil
        
        // Update UI
        updateUIAfterFiltering()
    }
    
    
    func getCommunicationList() {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_list, parameters: [:], type: ApitTypeSringFile.GET, token: studentDetails?.access_token ?? "") { [weak self] (result : Result<CommunicationReciverResponse,Error>) in
            
            guard let self = self else {return}
            switch result {
//                "FN : fornoon  /    AN : afternoon "
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    
                    DispatchQueue.main.async {
                        
                        self.allMessages = SuccessMessage.data
                        self.displayedMessages = self.allMessages
                        self.NodataLbl.isHidden = true
                        self.NodataImage.isHidden = true
                        self.searchBtn.isHidden = false
                        //SearchbarStack.isHidden = !(TotalMessageList?.count ?? 0 > 1)//false
                        self.tv.reloadData()
                        
                            if self.clickedMessageId != ""{
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    self.scrollToClickedMessage()
                                }
                            }
                        
                    }
                    
                }else {
                    
                    DispatchQueue.main.async {
                        self.allMessages = []
                        self.displayedMessages = self.allMessages
                       // SearchbarStack.isHidden = true
                        self.NodataLbl.text = SuccessMessage.message  //"Something went wrong! Try again Later"
                        self.NodataLbl.isHidden = false
                        self.NodataImage.isHidden = false
                        self.searchBtn.isHidden = true
                        self.tv.isScrollEnabled = false
                        self.tv.reloadData()
                    }
                }
                
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func scrollToClickedMessage() {
        guard let id = clickedMessageId,
              let index = displayedMessages.firstIndex(where: { $0.header_id == id }) else {
            return
        }

        let indexPath = IndexPath(row: index, section: 0)
        
        // Scroll to that cell smoothly
        tv.scrollToRow(at: indexPath, at: .middle, animated: true)
        
        // Optionally highlight the cell for 1 second
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
        savePlaybackStateBeforeReload()
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_communication_list_archive,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<CommunicationReciverResponse, Error>) in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let response):
                DispatchQueue.main.async {
                    if response.status {
                        // ✅ Append new archived messages
                        self.allMessages.append(contentsOf: response.data)
                        
                        // ✅ Apply current filters (type + readStatus)
                        self.applyFilters()
                        
                        // ✅ Restore UI
                        self.NodataLbl.isHidden = true
                        self.NodataImage.isHidden = true
                        self.shouldShowFooterLabel = false
                        self.tv.isHidden = false
                        self.searchBtn.isHidden = false
                        self.tv.isScrollEnabled = true
                        self.restorePlaybackStateAfterReload()
                    } else {
                        // ⚠️ Handle empty archive or API message
                        self.tv.reloadData()
                        self.restorePlaybackStateAfterReload()
                        
                        if self.allMessages.isEmpty {
                            self.NodataLbl.text = response.message
                            self.shouldShowFooterLabel = false
                            self.tv.isHidden = true
                            self.searchBtn.isHidden = true
                            self.NodataImage.isHidden = false
                            self.NodataLbl.isHidden = false
                        } else {
                            self.ArchiveMessage = response.message
                            self.shouldShowFooterLabel = true
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    self.tv.reloadData()
                    self.restorePlaybackStateAfterReload()
                    
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
        }
    }

    
    func ReadStatusUpdate(type: String,detail_id: String) {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
            
            switch result {
                
                
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        
                        print(SuccessMessage.message)
                    }
                    
                }else {
                    
                    DispatchQueue.main.async {
                        
                        print(SuccessMessage.message)
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
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update_archive, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
            
            switch result {
                
                
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        
                        print(SuccessMessage.message)
                    }
                    
                }else {
                    
                    DispatchQueue.main.async {
                        
                        print(SuccessMessage.message)
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
            SearchBar.resignFirstResponder()
            sender.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            FilterCV.isHidden = true
            ReadUnreadStack.isHidden = true
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
        
        return displayedMessages.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = displayedMessages[indexPath.row]
        
        switch message.type.uppercased() {
       
        case "TEXT":
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.TextHistoryTVCell, for: indexPath) as! TextHistoryTVCell
           
            cell.sendBtnheight.constant = 0
            cell.sendBtnWidth.constant = 0
            cell.DateLabel.textAlignment = .right
            cell.sendBtn.isHidden = true
            cell.NewImageView.isHidden = true
           
            cell.descriptContent.tag = indexPath.row // Tag the label with the row index
            cell.descriptContent.isUserInteractionEnabled = true
            
            cell.MessageTitle.text = message.title
           
            let formattedDateString = dateFormatter.convertDate(message.date) ?? ""
            
            cell.DateLabel.setStyledDateTime(dateString: formattedDateString, timeString: message.time)

            cell.descriptContent.attributedText = self.descript(for:message.content ?? "", expanded: message.isExpand ?? false)

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
            
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.HistoryTC, for: indexPath) as! HistoryTC
            
            let isPlaying = (playIndex == indexPath.row)
            let voiceData = message
            
            cell.emergencyMessageBtn.isHidden = !(voiceData.is_emergency)
            cell.sendbtn.isHidden = true
            cell.sentBtnHeight.constant = 0
            cell.sentBtnWidth.constant = 0
            cell.updatePlayState(isPlaying: isPlaying, url: voiceData.content)
            cell.playBtn.tag = indexPath.row
            cell.sendbtn.tag = indexPath.row
            cell.delegate = self
            cell.FinishPlayingdelegate = self
            cell.NewImageView.isHidden = true
            
            cell.playBtn.setImage(isPlaying ? ImageName.pausebutton : ImageName.playbutton, for: .normal)
           
          
            let formattedDateString = dateFormatter.convertDate(message.date) ?? ""
            cell.datelbl.setStyledDateTime(dateString: formattedDateString, timeString: message.time)
            
            
            cell.contentlbl.text = voiceData.title
            
            let duration = voiceData.duration ?? 0
            let formattedDuration = formatDuration(duration)

            // ✅ Use saved playback time or 0 if none
            let elapsedSeconds = voiceData.playbackSeconds ?? 0
            let formattedElapsed = formatDuration(Int(elapsedSeconds))

            cell.totaltime.text = "\(formattedElapsed) / \(formattedDuration)"
            
            if !isPlaying {
                cell.playerView.progress = 0.0
                cell.playerView.updateWithLevel(0.0)
                cell.playerView.setNeedsDisplay()
            }else{
                
                cell.NewImageView.isHidden = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                cell.configureShimmer()
            }
            
            cell.NewImageView.isHidden = !(message.is_unread)
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
//        func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//            if let historyCell = cell as? HistoryTC {
//                historyCell.stopAudioPlayback()
//            }
//        }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView()
        footerView.backgroundColor = .clear
        
        if shouldShowFooter {
            
            // Create a button instead of a label
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.titleLabel?.textAlignment = .right
            // Create underlined attributed text
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
            
            // Add target action
            button.addTarget(self, action: #selector(seeArchivedMessagesTapped(_:)), for: .touchUpInside)
            
            // Add and constrain
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
        print("Archived messages tapped!")

        GetArchiveCommunicationList()
        SearchBar.searchTextField.text = ""
        shouldShowFooter = false
    }


   @objc func handleLabelTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel, let attributedText = label.attributedText else { return }
        let text = attributedText.string

        // Define interactive ranges for "View" and "hide".
        let viewRange = (text as NSString).range(of: "View")
        let hideRange = (text as NSString).range(of: "")
        
        if gesture.didTapAttributedTextInLabel(label: label, inRange: viewRange) ||
           gesture.didTapAttributedTextInLabel(label: label, inRange: hideRange) {
            handleSeeMoreTap(gesture)
        }
    }

    @objc func handleSeeMoreTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let indexPath = IndexPath(row: label.tag, section: 0)
        
        var message: CommunicationReciverData?

        message = displayedMessages[indexPath.row]
 
        guard let fullDescription = message?.content else { return }

        let threshold = 120
        if message?.isExpand == nil { message?.isExpand = false }
        
        // Toggle the expanded state.
        message?.isExpand!.toggle()
        let expanded = message?.isExpand ?? false
        
        // Configure the label's number of lines and attributed text.
        label.numberOfLines = expanded ? 0 : (fullDescription.count > threshold ? 3 : 0)
        label.attributedText = descript(for: fullDescription, expanded: expanded)

        // Update read status if required.
        if message?.is_unread == true {
            
            if message?.is_archive ?? false {
                ReadStatusUpdateArchive(type: message?.type ?? "", detail_id: message?.id ?? "")
            }else {
                ReadStatusUpdate(type: message?.type ?? "", detail_id: message?.id ?? "")
            }
            message?.is_unread = false
            let cell = tv.cellForRow(at: indexPath) as! TextHistoryTVCell
            cell.NewImageView.isHidden = true
        }
        
         //Save updated message back to the data source.
            
            if let updatedMessage = message{
                displayedMessages[indexPath.row] = updatedMessage
            }
        
        // Refresh table view layout.
        tv.beginUpdates()
        tv.endUpdates()
       
    }

    /// Returns an attributed string based on whether the text is in an expanded or collapsed state.
    /// If the text is longer than the threshold, it appends "View" (when collapsed) or "hide" (when expanded)
    /// as interactive links. For small text, no extra link is added.
    func descript(for fullDescription: String, expanded: Bool) -> NSAttributedString {
        let threshold = 120
        let attributedText: NSMutableAttributedString
        
        if fullDescription.count > threshold {
            // For large text with truncation and toggling.
            if expanded {
                // Expanded state: full text with "hide" link.
                let fullString = fullDescription + " " + ""
                attributedText = NSMutableAttributedString(string: fullString)
                let hideRange = (fullString as NSString).range(of: "")
                attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: hideRange)
            } else {
                // Collapsed state: truncated text with "View" link.
                let truncatedText = String(fullDescription.prefix(100))
                let fullString = truncatedText + " " + "View"
                attributedText = NSMutableAttributedString(string: fullString)
                let viewRange = (fullString as NSString).range(of: "View")
                attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: viewRange)
            }
        } else {
            // For small text, no "hide" label, only toggleable "View" link.
            if expanded {
                // Expanded state: full text with no additional label.
                attributedText = NSMutableAttributedString(string: fullDescription)
            } else {
                // Collapsed state: full text + "View" link.
                let fullString = fullDescription + " " + "View"
                attributedText = NSMutableAttributedString(string: fullString)
                let viewRange = (fullString as NSString).range(of: "View")
                attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: viewRange)
            }
        }
        return attributedText
    }

    
    // Method to load the footer from nib and set it as tableFooterView
    func setupTableFooter() {
        if shouldShowFooter {
            if let footer = Bundle.main.loadNibNamed("SeeMoreFooterView", owner: self, options: nil)?.first as? SeeMoreFooterView {
                // Adjust the frame based on your needs.
                footer.frame = CGRect(x: 0, y: 0, width: tv.frame.width, height: 200)
               
                let buttonTitle = "See More"
                let attributedString = NSMutableAttributedString(string: buttonTitle)

                let customFont = UIFont(name: "Poppins-Medium", size: 17) ?? UIFont.systemFont(ofSize: 18)
                attributedString.addAttribute(.font, value: customFont, range: NSRange(location: 0, length: buttonTitle.count))
                
                // Apply underline style
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: buttonTitle.count))

                // Set attributed title to UIButton
                footer.SeeMoreBtn.setAttributedTitle(attributedString, for: .normal)

                let seeMoreTap = UITapGestureRecognizer(target: self, action: #selector(seeMoreAction))
                footer.SeeMoreBtn.addGestureRecognizer(seeMoreTap)
                footer.SeeMoreBtn.isUserInteractionEnabled = true
                
                // Set the footer view.
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
        pauseCurrentAudioBeforeReload()
        selectedIndex = indexPath
        
        selectedFilterType = (indexPath.row == 0) ? nil : Filters[indexPath.row]
        
        displayedMessages = allMessages.filtered(readStatus: readStatus, type: selectedFilterType)
        playIndex = nil
        updateUIAfterFiltering()
        FilterCV.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let text = Filters[indexPath.item] // Assuming your label text is from a data source
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16) // Use the same font as in Storyboard
        label.text = text
        label.sizeToFit()

        let width = label.frame.width + 60  // Add padding
        return CGSize(width: width, height: 40) // Adjust height accordingly
    }
}

extension ParentCommunicationVc : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            pauseCurrentAudioBeforeReload()
            
            let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
            // Step 1: Start from filtered base
            let baseList = allMessages.filtered(readStatus: readStatus, type: selectedFilterType)
            
            // Step 2: Apply search if needed
            if trimmedText.isEmpty {
                displayedMessages = baseList
            } else {
                displayedMessages = baseList.filter { msg in
                    let date = dateFormatter.convertDate(msg.date)?.lowercased() ?? ""
                    return [msg.title, msg.content, msg.type, date]
                        .map { $0.lowercased() }
                        .contains { $0.contains(trimmedText) }
                }
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
       // restorePlaybackStateAfterReload()
    }

}

extension Array where Element == CommunicationReciverData {
    func filtered(readStatus: Int, type: String?) -> [CommunicationReciverData] {
        self.filter { msg in
            let matchesType = type == nil || msg.type.caseInsensitiveCompare(type!) == .orderedSame
            let matchesReadStatus: Bool = {
                switch readStatus {
                case 1: return !msg.is_unread
                case 2: return msg.is_unread
                default: return true
                }
            }()
            return matchesType && matchesReadStatus
        }
    }
}
