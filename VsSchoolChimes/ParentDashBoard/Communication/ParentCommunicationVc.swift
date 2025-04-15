//
//  ParentCommunicationVc.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit

class ParentCommunicationVc: UIViewController, reloadDelegate {
    func reload(index: Int) {
        if let currentIndex = playIndex, currentIndex != index {
            let previousIndexPath = IndexPath(row: currentIndex, section: 0)
            (tv.cellForRow(at: previousIndexPath) as? HistoryTC)?.updatePlayState(isPlaying: false, url: "https://www.learningcontainer.com/wp-content/uploads/2020/02/Sample-OGG-File.ogg")
        }
        playIndex = (playIndex == index) ? nil : index
        tv.reloadData()
    }
    func deleteDelegate(index: Int) {
        ""
    }
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var clickTextView: UILabel!
    @IBOutlet weak var clickVoiceLbl: UILabel!
    @IBOutlet weak var textBtn: UIButton!
    @IBOutlet weak var voiceClickView: UIView!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var StandardLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var textClickView: UIView!
    @IBOutlet weak var voiceBtn: UIButton!
    @IBOutlet weak var tv: UITableView!
    var BtnId = 1
    let backgroundcolor = Colornames.topBackgroundCLr
    let tapColor = Colornames.topBackgroundCLr1
    var playIndex :Int?
    var AudioPlayUrl: String?
    var passValue = 0
    var count = 5
    var shouldShowFooter = true
    var studentDetails = UserDefaultFileManager.get_child_Details()
//    var TotalMessageList : [CommunicationReciverData]?
//    var FilteredMessages : [CommunicationReciverData]?
//    var ArchiveMessages : [CommunicationReciverData] = []
//    var TodayMessage : [CommunicationReciverData] = []
//    var dropDown = DropDown()
    var isFiltered = false

    override func viewDidLoad() {
        super.viewDidLoad()
//        buttons()

//        StyleAndTranslate()
//        NodataLbl.isHidden = true
       // NodataImage.isHidden = true
        
//        if passValue == 1{
//            NameLbl.text = ""
//            StandardLbl.text = ""
//        }
        
//        backBtn.applyBackButton()
//        ButtonStyle()
        // Do any additional setup after loading the view.
      
//        RegisterCell()
//        
//        setupTableFooter()
//        
//        getCommunicationList(detail_id: "")
      
//        let Filtertap = UITapGestureRecognizer(target: self, action: #selector(filter))
//        FilterImage.addGestureRecognizer(Filtertap)
//        FilterImage.isUserInteractionEnabled = true
//       
//        tv.delegate = self
//        tv.dataSource = self
//        tv.reloadData()
    }

//    override func viewDidLayoutSubviews() {
//        
//        if passValue == 1{
//            view.backgroundColor = .topBackgroundCLr
//            view.applyGradient(colors: [Colornames.stafGradient, Colornames.stafGradient1], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
//           
//        }else{
//            view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
//        }
//    }
//    
//    //MARK: StyleAndTranslate
//    func StyleAndTranslate(){
//        
//        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
//        NameLbl.setFont(style: .body, size: FontSize.BodySize)
//        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
//        
//        clickTextView.text = CommonStringFile.TextMessage.translated()
//        backBtn.setTitle(MenuStringFile.Communication.translated(), for: .normal)
//        clickVoiceLbl.text = CommonStringFile.VoiceMessage.translated()
//    }
//    
//    //MARK: Cell registration
//    func RegisterCell(){
//        let nib = UINib(nibName: CellConfingName.TextHistoryTVCell, bundle: nil)
//        tv.register(nib, forCellReuseIdentifier: CellConfingName.TextHistoryTVCell)
//        
//        let nib2 = UINib(nibName: CellConfingName.HistoryTC, bundle: nil)
//        tv.register(nib2, forCellReuseIdentifier: CellConfingName.HistoryTC)
//        
//        let footerNib = UINib(nibName:CellConfingName.SeeMoreFooterView , bundle: nil)
//        tv.register(footerNib, forHeaderFooterViewReuseIdentifier: CellConfingName.SeeMoreFooterView)
//    }
//    
//    func ButtonStyle(){
//        textClickView.backgroundColor = .white
//        textBtn.backgroundColor = UIColor.white
//        clickVoiceLbl.textColor = .black
//        clickTextView.textColor = .black
//        textBtn.tintColor = .black
//        //voiceBtn.backgroundColor = .white
//        voiceClickView.layer.cornerRadius = 8
//        voiceClickView.layer.cornerRadius = 8
//        //voiceClickView.backgroundColor = tapColor
//        voiceBtn.layer.cornerRadius = 20
//        voiceBtn.layer.shadowColor = UIColor.black.cgColor
//        voiceBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
//        voiceBtn.layer.shadowRadius = 5
//        voiceBtn.layer.shadowOpacity = 0.3
//        gradientcolours(view: voiceClickView,colours:[
//            UIColor(hex: "7ED957").withAlphaComponent(0.5).cgColor,
//            UIColor(hex: "0097B2").withAlphaComponent(0.5).cgColor
//        ])
//        
//        gradientcolours(view: textClickView,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
//    }
//    
//    func buttons(){
//        //MARK: TEXT BUTTON BACKGROUND
//        textBtn.layer.cornerRadius = 20
//        textBtn.layer.shadowColor = UIColor.black.cgColor
//        textBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
//        textBtn.layer.shadowRadius = 5
//        textBtn.layer.shadowOpacity = 0.3
//        textClickView.layer.cornerRadius = 8
//        textClickView.backgroundColor = backgroundcolor
//        voiceClickView.backgroundColor = .white
//        textBtn.backgroundColor = UIColor.white
//        clickVoiceLbl.textColor = .black
//       
//        clickTextView.textColor = .black
//        voiceBtn.tintColor = tapColor
//        textBtn.tintColor = .black
//        
//    }
//    
//    func textButtonStyle(){
//        textClickView.backgroundColor = backgroundcolor
//        voiceClickView.backgroundColor = .white
//        textBtn.backgroundColor = UIColor.white
//        clickVoiceLbl.textColor = .black
//       
//        clickTextView.textColor = .black
////        voiceBtn.tintColor = tapColor
//        textBtn.tintColor = .black
//        
//        //MARK: TEXT BUTTON BACKGROUND
//        textBtn.layer.cornerRadius = 20
//        textBtn.layer.shadowColor = UIColor.black.cgColor
//        textBtn.layer.shadowOffset = CGSize(width: 0, height: 2)
//        textBtn.layer.shadowRadius = 5
//        textBtn.layer.shadowOpacity = 0.3
//        textClickView.layer.cornerRadius = 8
//        gradientcolours(view: textClickView,colours: [
//            UIColor(hex: "7ED957").withAlphaComponent(0.5).cgColor,
//            UIColor(hex: "0097B2").withAlphaComponent(0.5).cgColor
//        ])
//        gradientcolours(view: voiceClickView,colours: [UIColor.clear.cgColor,UIColor.clear.cgColor])
//    }
//    
//    func gradientcolours(view: UIView, colours: [CGColor]) {
//        // Remove any existing gradient layers to avoid duplication
//        view.layer.sublayers?.removeAll { $0 is CAGradientLayer }
//        
//        // Create and configure the gradient layer
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = colours
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
//        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
//        gradientLayer.frame = view.bounds
//        gradientLayer.cornerRadius = view.layer.cornerRadius
//        
//        // Insert the gradient layer into the view's layer
//        view.layer.insertSublayer(gradientLayer, at: 0)
//    }
//
//    @IBAction func backBtn(_ sender: Any) {
//        
//        dismiss(animated: true)
//    }
//    @IBAction func voiceMessgBtn(_ sender: Any) {
//        BtnId = 1
//        ButtonStyle()
//        shouldShowFooter = true
//        setupTableFooter()
//        tv.reloadData()
//        
//    }
//    
//    @IBAction func TextMessageBtn(_ sender: Any) {
//        
//        BtnId = 0
//        textButtonStyle()
//        shouldShowFooter = true
//        setupTableFooter()
//        tv.reloadData()
//    }
//    
//    @IBAction func filter(_ sender: UIButton) {
//        
//        
//        dropDown.dataSource = ["VOICE","TEXT","Read","Unread"]
//        dropDown.anchorView = FilterImage
//        dropDown.bottomOffset = CGPoint(x: 0, y: (FilterImage.bounds.height))
//        
//        dropDown.direction = .bottom
//        
//        dropDown.show()
//        dropDown.selectionAction = { [self] (index: Int, item: String) in
//           // self.filterBtn.setTitle(item.translated(), for: .normal)
//            
//            switch item{
//            case "VOICE":
//                FilteredMessages = TotalMessageList?.messages(ofType: "VOICE")
//               
//            case "TEXT":
//                FilteredMessages = TotalMessageList?.messages(ofType: "TEXT")
//            
//            case "Read" :
//                FilteredMessages = TotalMessageList?.readMessages()
//                
//            case "Unread" :
//                FilteredMessages = TotalMessageList?.unreadMessages()
//            
//            default:
//               
//                FilteredMessages = TotalMessageList
//            }
//            
//            isFiltered = true
//            tv.reloadData()
//            // Update the label inside the UIView
////            if let label = self.categoryDropDownView.subviews.first(where: { $0 is UILabel }) as? UILabel {
////                self.filterBtn.setTitle(item.translated(), for: .normal)
////            }
//        }
//        
//    }
//    
//    
//    func getCommunicationList(detail_id : String) {
//        
//        APIService.shared.makeApi(url: ServiceUrl.comm_communication_list, parameters: [:], type: ApitTypeSringFile.GET, token: studentDetails?.access_token ?? "") { [self] (result : Result<CommunicationReciverResponse,Error>) in
//            
//            switch result {
//                
//                
//            case .success(let SuccessMessage):
//                
//                if SuccessMessage.status == true {
//                    
//                    DispatchQueue.main.async { [self] in
//                        
////                        TotalMessageList = SuccessMessage.data
////                        for i in 0..<(TotalMessageList?.count ?? 0){
////                            if TotalMessageList?[i].id == detail_id{
////                                TotalMessageList?[i].isExpand = true
////                            }else{
////                                TotalMessageList?[i].isExpand = false
////                            }
////                        }
////
//                        
//                        TodayMessage = SuccessMessage.data
//                        tv.reloadData()
//                        
//                       // TotalMessageList?.append(contentsOf: TodayMessage)
//                        
//                    }
//                    
//                }else {
//                    
//                    DispatchQueue.main.async { [self] in
//                        
//                        TodayMessage = []
//                        NodataLbl.text = SuccessMessage.message
//                        NodataLbl.isHidden = false
//                        tv.reloadData()
//                    }
//                }
//                
//            case .failure(let error):
//                
//                DispatchQueue.main.async {
//                    print(error.localizedDescription)
//                }
//            }
//        }
//    }
//    
//    func GetArchiveCommunicationList() {
//        
//        APIService.shared.makeApi(url: ServiceUrl.comm_communication_list_archive, parameters: [:], type: ApitTypeSringFile.GET, token: studentDetails?.access_token ?? "") { [self] (result : Result<CommunicationReciverResponse,Error>) in
//            
//            switch result {
//                
//                
//            case .success(let SuccessMessage):
//                
//                if SuccessMessage.status == true {
//                    
//                    DispatchQueue.main.async { [self] in
//                        
//                        ArchiveMessages = SuccessMessage.data
//                        //TotalMessageList?.append(contentsOf: ArchiveMessages)
//                        tv.reloadData()
//                    }
//                    
//                }else {
//                    
//                    DispatchQueue.main.async { [self] in
//                        
//                        ArchiveMessages = []
//                        
//                        tv.reloadData()
//                        
//                        NodataLbl.text = SuccessMessage.message
//                        NodataImage.isHidden = false
//
//                    }
//                }
//                
//            case .failure(let error):
//                
//                DispatchQueue.main.async {
//                    print(error.localizedDescription)
//                }
//            }
//        }
//    }
//    
//    func ReadStatusUpdate(type: String,detail_id: String) {
//        
//        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
//            
//            switch result {
//                
//                
//            case .success(let SuccessMessage):
//                
//                if SuccessMessage.status == true {
//                    
//                    DispatchQueue.main.async { [self] in
//                        
//                        //getCommunicationList(detail_id: detail_id)
////                        for i in 0..<(MessageList?.count ?? 0){
////                            if MessageList?[i].id == detail_id{
////                                MessageList?[i].is_unread = false
////                            }
////                        }
//                        //tv.reloadData()
//                    }
//                    
//                }else {
//                    
//                    DispatchQueue.main.async {
//                        
//                        print(SuccessMessage.message)
//                    }
//                }
//                
//            case .failure(let error):
//                
//                DispatchQueue.main.async {
//                    print(error.localizedDescription)
//                }
//            }
//        }
//    }
//    
//    func ReadStatusUpdateArchive(type: String,detail_id: String){
//        
//        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update_archive, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
//            
//            switch result {
//                
//                
//            case .success(let SuccessMessage):
//                
//                if SuccessMessage.status == true {
//                    
//                    DispatchQueue.main.async { [self] in
//                        
//                       // getCommunicationList(detail_id: detail_id)
//                    }
//                    
//                }else {
//                    
//                    DispatchQueue.main.async {
//                        
//                        print(SuccessMessage.message)
//                    }
//                }
//                
//            case .failure(let error):
//                
//                DispatchQueue.main.async {
//                    print(error.localizedDescription)
//                }
//            }
//        }
//    }
//}
//
////MARK: Tableview Functions
//extension ParentCommunicationVc : UITableViewDelegate , UITableViewDataSource{
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        
//        if isFiltered{
//            return FilteredMessages?.count ?? 0
//        }else{
//            
//            TotalMessageList = TodayMessage + ArchiveMessages
//            return TotalMessageList?.count ?? 0
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        let message : CommunicationReciverData?
//        
//        if isFiltered{
//             message = FilteredMessages?[indexPath.row]
//        }else {
//            message = TotalMessageList?[indexPath.row]
//        }
//        
//        switch message?.type.uppercased() {
//       
//        case "TEXT":
//            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.TextHistoryTVCell, for: indexPath) as! TextHistoryTVCell
//           
//            cell.sendBtnheight.constant = 0
//            cell.sendBtnWidth.constant = 0
//            cell.DateLabel.textAlignment = .right
//            cell.sendBtn.isHidden = true
//           
//            cell.descriptContent.tag = indexPath.row // Tag the label with the row index
//            cell.descriptContent.isUserInteractionEnabled = true
//           
////            DispatchQueue.main.asyncAfter(deadline: .now()+0.0){
//            DispatchQueue.main.async {
//                
//            
//            cell.MessageTitle.text = message?.description
//            cell.DateLabel.text = (message?.time ?? "") + " " + (message?.date ?? "")
//            cell.descriptContent.attributedText = self.descript(for:message?.content ?? "", expanded: message?.isExpand ?? false)
//            cell.delegate = self
//                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleLabelTap(_:)))
//            cell.descriptContent.addGestureRecognizer(tapGesture)
//            
//                cell.configureShimmer()
//                
//                if message?.is_unread == true{
//                    cell.newImageOuterView.isHidden = false
//                    cell.NewImageView.isHidden = false
//                }else {
//                    cell.newImageOuterView.isHidden = true
//                    cell.NewImageView.isHidden = true
//                }
//            }
//            return cell
//            
//            
//        case "VOICE":
//            
//            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.HistoryTC, for: indexPath) as! HistoryTC
//            
//            cell.sentBtnHeight.constant = 0
//            cell.sendbtn.isHidden = true
//            cell.sentBtnWidth.constant = 0
//            cell.playBtn.tag = indexPath.row
//            cell.datelbl.textAlignment = .right
//            let image = playIndex == indexPath.row ? ImageName.pausebutton: ImageName.playbutton
//            cell.updatePlayState(isPlaying: playIndex == indexPath.row, url: message?.content)
//            cell.delegate = self
//            cell.playBtn.setImage(image, for: .normal)
//            
//            cell.contentlbl.text = message?.description
//            cell.datelbl.text  = (message?.time ?? "") + " " + (message?.date ?? "")
//            
//            if message?.is_unread == true{
//                
//                cell.NewImageView.isHidden = false
//            }else {
//                cell.NewImageView.isHidden = true
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now()+1.0){
//                
//                cell.configureShimmer()
//            }
//    
//            return cell
//            
//        default:
//            return UITableViewCell()
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//    
//
//    
//    @objc func handleLabelTap(_ gesture: UITapGestureRecognizer) {
//        guard let label = gesture.view as? UILabel, let attributedText = label.attributedText else { return }
//        let text = attributedText.string
//
//        // Define interactive ranges for "View" and "hide".
//        let viewRange = (text as NSString).range(of: "View")
//        let hideRange = (text as NSString).range(of: "hide")
//        
//        if gesture.didTapAttributedTextInLabel(label: label, inRange: viewRange) ||
//           gesture.didTapAttributedTextInLabel(label: label, inRange: hideRange) {
//            handleSeeMoreTap(gesture)
//        }
//    }
//
//    @objc func handleSeeMoreTap(_ sender: UITapGestureRecognizer) {
//        guard let label = sender.view as? UILabel else { return }
//        let indexPath = IndexPath(row: label.tag, section: 0)
//        
//        var message: CommunicationReciverData?
//        if isFiltered {
//            message = FilteredMessages?[indexPath.row]
//        } else {
//            message = TotalMessageList?[indexPath.row]
//        }
//        guard let fullDescription = message?.content else { return }
//
//        let threshold = 120
//        if message?.isExpand == nil { message?.isExpand = false }
//        
//        // Toggle the expanded state.
//        message?.isExpand!.toggle()
//        let expanded = message?.isExpand ?? false
//        
//        // Configure the label's number of lines and attributed text.
//        label.numberOfLines = expanded ? 0 : (fullDescription.count > threshold ? 3 : 0)
//        label.attributedText = descript(for: fullDescription, expanded: expanded)
//
//        // Update read status if required.
//        if message?.is_unread == true {
//            
//            if TodayMessage.contains(where: {$0.id == message?.id}){
//                
//                ReadStatusUpdate(type: message?.type ?? "", detail_id: message?.id ?? "")
//                
//            }else if ArchiveMessages.contains(where: {$0.id == message?.id}){
//                
//                ReadStatusUpdateArchive(type: message?.type ?? "", detail_id: message?.id ?? "")
//            }
//            
//            let cell = tv.cellForRow(at: indexPath) as! TextHistoryTVCell
//            cell.NewImageView.isHidden = true
//        }
//        
//         //Save updated message back to the data source.
//        if isFiltered {
//            FilteredMessages?[indexPath.row] = message!
//        } else {
//            TotalMessageList?[indexPath.row] = message!
//        }
//        
//        // Refresh table view layout.
//        tv.beginUpdates()
//        tv.endUpdates()
//       
//    }
//
//
//
//    /// Returns an attributed string based on whether the text is in an expanded or collapsed state.
//    /// If the text is longer than the threshold, it appends "View" (when collapsed) or "hide" (when expanded)
//    /// as interactive links. For small text, no extra link is added.
//    func descript(for fullDescription: String, expanded: Bool) -> NSAttributedString {
//        let threshold = 120
//        let attributedText: NSMutableAttributedString
//        
//        if fullDescription.count > threshold {
//            // For large text with truncation and toggling.
//            if expanded {
//                // Expanded state: full text with "hide" link.
//                let fullString = fullDescription + " " + "hide"
//                attributedText = NSMutableAttributedString(string: fullString)
//                let hideRange = (fullString as NSString).range(of: "hide")
//                attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: hideRange)
//            } else {
//                // Collapsed state: truncated text with "View" link.
//                let truncatedText = String(fullDescription.prefix(100))
//                let fullString = truncatedText + " " + "View"
//                attributedText = NSMutableAttributedString(string: fullString)
//                let viewRange = (fullString as NSString).range(of: "View")
//                attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: viewRange)
//            }
//        } else {
//            // For small text, no "hide" label, only toggleable "View" link.
//            if expanded {
//                // Expanded state: full text with no additional label.
//                attributedText = NSMutableAttributedString(string: fullDescription)
//            } else {
//                // Collapsed state: full text + "View" link.
//                let fullString = fullDescription + " " + "View"
//                attributedText = NSMutableAttributedString(string: fullString)
//                let viewRange = (fullString as NSString).range(of: "View")
//                attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: viewRange)
//            }
//        }
//        return attributedText
//    }
//    
//    // Method to load the footer from nib and set it as tableFooterView
//    func setupTableFooter() {
//        if shouldShowFooter {
//            if let footer = Bundle.main.loadNibNamed("SeeMoreFooterView", owner: self, options: nil)?.first as? SeeMoreFooterView {
//                // Adjust the frame based on your needs.
//                footer.frame = CGRect(x: 0, y: 0, width: tv.frame.width, height: 60)
//                
//                // Add a tap gesture recognizer to the button to trigger the hide action.
//                let seeMoreTap = UITapGestureRecognizer(target: self, action: #selector(seeMoreAction))
//                footer.SeeMoreBtn.addGestureRecognizer(seeMoreTap)
//                footer.SeeMoreBtn.isUserInteractionEnabled = true
//                
//                // Set the footer view.
//                tv.tableFooterView = footer
//            }
//        } else {
//            tv.tableFooterView = nil
//        }
//    }
//    
//    @objc func seeMoreAction() {
//        print("Footer button tapped. Hiding the footer.")
//        
//        // Animate the footer fade-out if desired.
//        if let footer = tv.tableFooterView {
//            UIView.animate(withDuration: 0.3, animations: {
//                footer.alpha = 0
//            }, completion: {[self] _ in
//                // Hide the footer after animation completes.
//                
//                GetArchiveCommunicationList()
//                
//                tv.tableFooterView = nil
//                shouldShowFooter = false
//            })
//        } else {
//            // In case footer is already nil.
//            shouldShowFooter = false
//        }
//    }
//}
//
//
//extension Array where Element == CommunicationReciverData {
//    
//    // Filter unread messages
//    func unreadMessages() -> [CommunicationReciverData] {
//        return self.filter { $0.is_unread }
//    }
//    
//    // Filter read messages
//    func readMessages() -> [CommunicationReciverData] {
//        return self.filter { !$0.is_unread }
//    }
//    
//    // Filter by type (e.g. "TEXT", "VOICE")
//    func messages(ofType type: String) -> [CommunicationReciverData] {
//        return self.filter { $0.type.uppercased() == type.uppercased() }
//    }
    
    // Filter by subject
//    func messages(withSubject subject: String) -> [CommunicationReciverData] {
//        return self.filter { $0.subject == subject }
//    }
}
