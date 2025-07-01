//
//  ParentCommunicationVc.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit
import DropDown

class ParentCommunicationVc: UIViewController, reloadDelegate{
    
    func deleteDelegate(index: Int) {
        
    }
    func reload(index: Int) {
        
            if let currentIndex = playIndex, currentIndex != index {
                let previousIndexPath = IndexPath(row: currentIndex, section: 0)
                if let previousCell = tv.cellForRow(at: previousIndexPath) as? HistoryTC {
                    previousCell.updatePlayState(isPlaying: false, url: nil)
                }
            }
            
        playIndex = (playIndex == index) ? nil : index
        var currentmessage: CommunicationReciverData?
        

        currentmessage = SearchMessages?[index]
        
        if currentmessage?.is_unread == true {
            
            if currentmessage?.is_archive ?? false {
                ReadStatusUpdateArchive(type: currentmessage?.type ?? "", detail_id: currentmessage?.id ?? "")
            }else {
                
                ReadStatusUpdate(type: currentmessage?.type ?? "", detail_id: currentmessage?.id ?? "")
            }
            
            currentmessage?.is_unread = false
            
            if let PlayingMessage = currentmessage{
                SearchMessages?[index] = PlayingMessage
            }
        }
        
            tv.reloadData()
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
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var NodataImgHeight: NSLayoutConstraint!
    @IBOutlet weak var SearchbarStack: UIStackView!
    
    
    var BtnId = 1
    let backgroundcolor = Colornames.topBackgroundCLr
    let tapColor = Colornames.topBackgroundCLr1
    var playIndex :Int?
    var AudioPlayUrl: String?
    var passValue = 0
    var count = 5
    var shouldShowFooter = true
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var TotalMessageList : [CommunicationReciverData]?
    var FilteredMessages : [CommunicationReciverData]?
    var SearchMessages : [CommunicationReciverData]?
    var dropDown = DropDown()
    let dateFormatter = DateFormatter()
    let Filters = ["All","VOICE","TEXT"/*,"Read","Unread"*/]
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    
    var readStatus = 0  //All = 0, read = 1, unread = 2
    
    var showfilter = false

    override func viewDidLoad() {
        super.viewDidLoad()
    
        StyleAndTranslate()
       
        SearchBar.delegate = self
        SearchBar.searchTextField.addDoneButton()
        
        if passValue == 1{
            NameLbl.text = ""
            StandardLbl.text = ""
        }
        
        backBtn.applyBackButton()
        
      
        RegisterCell()
        
        setupTableFooter()
        
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
        
        if passValue == 1{
            view.backgroundColor = .topBackgroundCLr
            view.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
           
        }else{
            view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        }
        
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
        
        ReadBtn.layer.cornerRadius = 12
        UnreadBtn.layer.cornerRadius = 12
        AllBtn.layer.cornerRadius = 12
        
        AllBtn.backgroundColor = .systemGreen.withAlphaComponent(0.3)
        
        ReadBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        UnreadBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        AllBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        
        NodataLbl.isHidden = true
        NodataImage.isHidden = true
        NodataLbl.setFont(style: .title, size: 17)
        
        NameLbl.text = studentDetails?.name
        StandardLbl.text = (studentDetails?.standard_name ?? "") + " - " + (studentDetails?.section_name ?? "")
        
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        
        backBtn.setTitle(MenuStringFile.Communication.translated(), for: .normal)
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
    
    @IBAction func AllAct(_ sender: Any) {
        
        AllBtn.backgroundColor = .systemGreen.withAlphaComponent(0.3)
        ReadBtn.backgroundColor = .systemGray5
        UnreadBtn.backgroundColor = .systemGray5
        readStatus = 0
        
        if selectedIndex.row == 0{
            
            FilteredMessages = TotalMessageList
        }else {
            
            FilteredMessages = TotalMessageList?.messages(ofType: Filters[selectedIndex.row])
        }
        
        SearchMessages = FilteredMessages
        playIndex = nil
        NodataLbl.isHidden = !(SearchMessages?.count == 0)
        NodataImage.isHidden = !(SearchMessages?.count == 0)
        NodataLbl.text = "No Data Found"
        
        tv.reloadData()
    }
    
    @IBAction func ReadAct(_ sender: Any) {
        
        ReadBtn.backgroundColor = .systemGreen.withAlphaComponent(0.3)
        UnreadBtn.backgroundColor = .systemGray5
        AllBtn.backgroundColor = .systemGray5
        readStatus = 1
        
        if selectedIndex.row == 0{
            
            FilteredMessages = TotalMessageList?.readMessages()
            
        }else{
            
            FilteredMessages = TotalMessageList?.readMessages(ofType: Filters[selectedIndex.row])
        }
        playIndex = nil
        SearchMessages = FilteredMessages
        NodataLbl.isHidden = !(SearchMessages?.count == 0)
        NodataImage.isHidden = !(SearchMessages?.count == 0)
        NodataLbl.text = "No Data Found"
        tv.reloadData()
    }
    
    @IBAction func UnreadAct(_ sender: Any) {
        
        UnreadBtn.backgroundColor = .systemGreen.withAlphaComponent(0.3)
        ReadBtn.backgroundColor = .systemGray5
        AllBtn.backgroundColor = .systemGray5
        readStatus = 2
         
        if selectedIndex.row == 0{
            
            FilteredMessages = TotalMessageList?.unreadMessages()
            
        }else{
            
            FilteredMessages = TotalMessageList?.unreadMessages(ofType: Filters[selectedIndex.row])
        }
        playIndex = nil
        SearchMessages = FilteredMessages
        NodataLbl.isHidden = !(SearchMessages?.count == 0)
        NodataImage.isHidden = !(SearchMessages?.count == 0)
        NodataLbl.text = "No Data Found"
        tv.reloadData()
    }
    
    
    @IBAction func filter(_ sender: UIButton) {
        
        
//        dropDown.dataSource = ["VOICE","TEXT","Read","Unread","All"]
//        dropDown.anchorView = FilterImage
//        dropDown.bottomOffset = CGPoint(x: 0, y: (FilterImage.bounds.height))
//        
//        dropDown.direction = .bottom
//        
//        dropDown.show()
//        dropDown.selectionAction = { [self] (index: Int, item: String) in
//           // self.filterBtn.setTitle(item.translated(), for: .normal)
//            
//            filterSelection(FilterType: item)
//            
//            isFiltered = true
//            tv.reloadData()
//            
//        }
        
        FilterCV.isHidden = false
        ReadUnreadStack.isHidden = false
        
        showfilter.toggle()
        
       if showfilter == true {
            ViewAnimator.showFade(FilterCV)
            ViewAnimator.showFade(ReadUnreadStack)
        }else {
            ViewAnimator.hideFade(FilterCV)
            ViewAnimator.hideFade(ReadUnreadStack)
        }
    }
    
    func filterSelection(FilterType: String) {
        
        switch FilterType{
        case "VOICE":
            FilteredMessages = TotalMessageList?.messages(ofType: "VOICE")
           
        case "TEXT":
            FilteredMessages = TotalMessageList?.messages(ofType: "TEXT")
        
//        case "Read" :
//            FilteredMessages = TotalMessageList?.readMessages()
//            
//        case "Unread" :
//            FilteredMessages = TotalMessageList?.unreadMessages()
            
        case "All" :
            FilteredMessages = TotalMessageList
        
        default:
           
            FilteredMessages = TotalMessageList
        }
    }
    
    
    func getCommunicationList() {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_list, parameters: [:], type: ApitTypeSringFile.GET, token: studentDetails?.access_token ?? "") { [self] (result : Result<CommunicationReciverResponse,Error>) in
            
            switch result {
                
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        
                        TotalMessageList = SuccessMessage.data
                        SearchMessages = TotalMessageList
                        FilteredMessages = TotalMessageList
                        NodataLbl.isHidden = true
                        NodataImage.isHidden = true
                        SearchbarStack.isHidden = !(TotalMessageList?.count ?? 0 > 1)//false
                        tv.reloadData()
                    }
                    
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        TotalMessageList = []
                        SearchMessages = TotalMessageList
                        FilteredMessages = TotalMessageList
                        SearchbarStack.isHidden = true
                        NodataLbl.text = SuccessMessage.message  //"Something went wrong! Try again Later"
                        NodataLbl.isHidden = false
                        NodataImage.isHidden = false
                        tv.isScrollEnabled = false
                        tv.reloadData()
                    }
                }
                
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func GetArchiveCommunicationList() {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_list_archive, parameters: [:], type: ApitTypeSringFile.GET, token: studentDetails?.access_token ?? "") { [self] (result : Result<CommunicationReciverResponse,Error>) in
            
            switch result {
                
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        
                        TotalMessageList?.append(contentsOf: SuccessMessage.data)
                        
                        if selectedIndex.row == 0{
                            
                            switch readStatus {
                                
                            case 0 :
                                FilteredMessages = TotalMessageList
                                
                            case 1 :
                                FilteredMessages = TotalMessageList?.readMessages()
                                
                            case 2:
                                FilteredMessages = TotalMessageList?.unreadMessages()
                                
                            default:
                                FilteredMessages = TotalMessageList
                            }
                            
                        }else {
                            
                            switch readStatus {
                                
                            case 0:
                                FilteredMessages = TotalMessageList?.messages(ofType: Filters[ selectedIndex.row])
                                
                            case 1:
                                FilteredMessages = TotalMessageList?.readMessages(ofType: Filters[ selectedIndex.row])
                            case 2:
                                FilteredMessages = TotalMessageList?.unreadMessages(ofType: Filters[ selectedIndex.row])
                                
                            default:
                                FilteredMessages = TotalMessageList?.messages(ofType: Filters[ selectedIndex.row])
                            }
                            
                        }
                        
                        SearchMessages = FilteredMessages
                        
                        SearchbarStack.isHidden = !(TotalMessageList?.count ?? 0 > 1)//false
                        NodataLbl.isHidden = true
                        NodataImage.isHidden = true
                        tv.isHidden = false
                        tv.isScrollEnabled = true
                        tv.reloadData()
                    }
                    
                }else {
                    
                    DispatchQueue.main.async { [self] in
                        
                        tv.reloadData()
                        
                        if TotalMessageList?.count == 0 {
                            SearchbarStack.isHidden = true
                            NodataLbl.text = SuccessMessage.message
                            //NodataLbl.text = "Something went wrong! Try again Later"
                            tv.isHidden = true
                            NodataImage.isHidden = false
                            NodataLbl.isHidden = false
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
}

//MARK: Tableview Functions
extension ParentCommunicationVc : UITableViewDelegate , UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return SearchMessages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = SearchMessages?[indexPath.row]
        
        switch message?.type.uppercased() {
       
        case "TEXT":
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.TextHistoryTVCell, for: indexPath) as! TextHistoryTVCell
           
            cell.sendBtnheight.constant = 0
            cell.sendBtnWidth.constant = 0
            cell.DateLabel.textAlignment = .right
            cell.sendBtn.isHidden = true
            cell.NewImageView.isHidden = true
           
            cell.descriptContent.tag = indexPath.row // Tag the label with the row index
            cell.descriptContent.isUserInteractionEnabled = true
            
            cell.MessageTitle.text = message?.title
           
            let formattedDateString = dateFormatter.convertDate(message?.date ?? "") ?? ""
            
            cell.DateLabel.setStyledDateTime(dateString: formattedDateString, timeString: message?.time)

            cell.descriptContent.attributedText = self.descript(for:message?.content ?? "", expanded: message?.isExpand ?? false)

                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleLabelTap(_:)))
            
            cell.descriptContent.addGestureRecognizer(tapGesture)
            
                cell.layoutIfNeeded()
            
                cell.configureShimmer()
                
                if message?.is_unread == true{
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
            
            cell.sendbtn.isHidden = true
            cell.sentBtnHeight.constant = 0
            cell.sentBtnWidth.constant = 0
            cell.updatePlayState(isPlaying: isPlaying, url: voiceData?.content)
            cell.playBtn.tag = indexPath.row
            cell.sendbtn.tag = indexPath.row
            cell.delegate = self
            cell.NewImageView.isHidden = true
            
            cell.playBtn.setImage(isPlaying ? ImageName.pausebutton : ImageName.playbutton, for: .normal)
           
          
                let formattedDateString = dateFormatter.convertDate(message?.date ?? "") ?? ""
                cell.datelbl.setStyledDateTime(dateString: formattedDateString, timeString: message?.time)
            
            
            cell.contentlbl.text = voiceData?.title ?? ""
            
            let duration = voiceData?.duration ?? 0
            print("duration1",duration)
            let formatted = formatDuration(duration)
            print("duration",formatted)
            cell.totaltime.text = "00:00 / \(formatted)"
            
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
            
            cell.NewImageView.isHidden = !(message?.is_unread ?? false)
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
        func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            if let historyCell = cell as? HistoryTC {
                historyCell.stopAudioPlayback()
            }
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

        message = SearchMessages?[indexPath.row]
 
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
                SearchMessages?[indexPath.row] = updatedMessage
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
        
        cell.FilterLbl.text = Filters[indexPath.item]
        
        cell.CheckboxImg.image = indexPath == selectedIndex ? UIImage(named: "RadioCheck") : UIImage(named: "CheckCircle")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath // Update selected index
        
        if selectedIndex.row == 0{
            
            switch readStatus {
                
            case 0:
                FilteredMessages = TotalMessageList
                
            case 1:
                FilteredMessages = TotalMessageList?.readMessages()
                
            case 2:
                FilteredMessages = TotalMessageList?.unreadMessages()
                
            default:
                FilteredMessages = TotalMessageList
            }
            
        }else {
            
            switch readStatus {
                
            case 0:
                FilteredMessages = TotalMessageList?.messages(ofType: Filters[selectedIndex.row])
                
            case 1:
                FilteredMessages = TotalMessageList?.readMessages(ofType: Filters[selectedIndex.row])
                
            case 2:
                FilteredMessages = TotalMessageList?.unreadMessages(ofType: Filters[selectedIndex.row])
                
            default:
                FilteredMessages = TotalMessageList?.messages(ofType: Filters[selectedIndex.row])
            }
            
        }
        
        SearchMessages = FilteredMessages
        
        NodataLbl.isHidden = !(SearchMessages?.count == 0)
        NodataImage.isHidden = !(SearchMessages?.count == 0)
        NodataLbl.text = "No Data Found"
        playIndex = nil
        tv.reloadData()
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
        
        guard let totalMessages = FilteredMessages else {
            FilteredMessages = []
            tv.reloadData()
            return
        }

        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            SearchMessages = totalMessages
        } else {
            
            let lowercasedSearch = searchText.lowercased()

            SearchMessages = totalMessages.filter { message in
                let content = message.content.lowercased()
                let title = message.content.lowercased()
                let dateString = dateFormatter.convertDate(message.date)?.lowercased() ?? ""
                let type = message.type.lowercased()

                return title.contains(lowercasedSearch) ||
                       dateString.contains(lowercasedSearch) ||
                       type.contains(lowercasedSearch)
            }
        }

        NodataLbl.isHidden = !(SearchMessages?.count == 0)
        NodataImage.isHidden = !(SearchMessages?.count == 0)
        NodataLbl.text = "No Data Found"
        tv.reloadData()
    }

}

extension Array where Element == CommunicationReciverData {
    
    // Filter unread messages
    func unreadMessages() -> [CommunicationReciverData] {
        return self.filter { $0.is_unread }
    }
    
    // Filter read messages
    func readMessages() -> [CommunicationReciverData] {
        return self.filter { !$0.is_unread }
    }
    
    // Filter by type (e.g. "TEXT", "VOICE")
    func messages(ofType type: String) -> [CommunicationReciverData] {
        return self.filter { $0.type.uppercased() == type.uppercased() }
    }
    
    // Filter unread messages of a specific type
    func unreadMessages(ofType type: String) -> [CommunicationReciverData] {
        return self.filter { $0.is_unread && $0.type.uppercased() == type.uppercased() }
    }
    
    // Filter read messages of a specific type
    func readMessages(ofType type: String) -> [CommunicationReciverData] {
        return self.filter { !$0.is_unread && $0.type.uppercased() == type.uppercased() }
    }
}
