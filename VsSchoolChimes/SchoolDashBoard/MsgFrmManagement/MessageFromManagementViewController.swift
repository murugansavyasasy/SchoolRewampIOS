//
//  MessageFromManagementViewController.swift
//  VsSchoolChimes
//
//  Created by Apple on 12/17/24.
//

protocol ReadUpadesManagemant{
    func readStatus(attachment:ManagemantMessageData)
}

import UIKit

@available(iOS 14.0, *)
class MessageFromManagementViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var BackBtn: UIButton!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var FilterCV: UICollectionView!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    var messageData: [ManagemantMessageData]?
    var SearchData: [ManagemantMessageData]?
    var dateFormatter = DateFormatter()
    var shouldShowFooter = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackBtn.configureAsBackButton(firstLine: MenuStringFile.MessagesFromManagement, secondLine: staffDetails?.school_name ?? "")
        BackBtn.applyBackButton()
        NoDataLbl.setFont(style: .title, size: FontSize.HeaderSize)
        
        SearchBar.searchTextField.addDoneButton()
        SearchBar.delegate = self
        
        FilterCV.isHidden = true
        SearchBar.isHidden = true
        NoDataLbl.isHidden = true
        NoDataImage.isHidden = true
        
        Cell_Registration()
        setupTableFooter()
        
        tv.register(UINib(nibName: CellConfingName.MessageFromManagementTableViewCell, bundle: nil), forCellReuseIdentifier: CellConfingName.MessageFromManagementTableViewCell)
        tv.dataSource = self
        tv.delegate = self
        
        Get_messages()
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(
            colors: [Colornames.stafGradient, Colornames.stafGradient1],
            startPoint: CGPoint(x: 1, y: 0.5),
            endPoint: CGPoint(x: 0, y: 0.5)
        )
    }
    
    func Cell_Registration() {
        tv.register(UINib(nibName: CellConfingName.TextHistoryTVCell, bundle: nil), forCellReuseIdentifier: CellConfingName.TextHistoryTVCell)
        
        tv.register(UINib(nibName: CellConfingName.HistoryTC, bundle: nil), forCellReuseIdentifier: CellConfingName.HistoryTC)
        
        tv.register(UINib(nibName: CellConfingName.TAttacmentTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.TAttacmentTVC)
        
        tv.register(UINib(nibName: CellConfingName.VideoTVCell, bundle: nil), forCellReuseIdentifier: CellConfingName.VideoTVCell)
    }
    
    //MARK: Get Message Data Api call
    
    func Get_messages() {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_msg_from_management_get_messages_staff, parameters: [:], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") {[self] (result: Result<MessageFromManagementResp,Error>) in
            
            switch result{
                
            case .success(let success):
                DispatchQueue.main.async { [self] in
                    
                    messageData = success.data
                    SearchData = messageData
                    
                    NoDataLbl.text = success.message
                    NoDataImage.isHidden = !(messageData?.isEmpty ?? false)
                    NoDataLbl.isHidden = !(messageData?.isEmpty ?? false)
                    SearchBar.isHidden = (messageData?.isEmpty ?? false)
                    tv.reloadData()
                }
                
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    
                    NoDataImage.isHidden = false
                    NoDataLbl.isHidden = false
                    SearchBar.isHidden = true
                    NoDataLbl.text = error.localizedDescription
                    tv.reloadData()
                }
            }
        }
    }
    
    func get_messages_archive() {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_msg_from_management_get_messages_staff_archive, parameters: [:], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") {[self] (result: Result<MessageFromManagementResp,Error>) in
            
            switch result{
                
            case .success(let success):
                DispatchQueue.main.async { [self] in
                    
                    messageData?.append(contentsOf: success.data ?? [])
                    SearchData = messageData
                    
                    NoDataLbl.text = success.message
                    NoDataImage.isHidden = !(messageData?.isEmpty ?? false)
                    NoDataLbl.isHidden = !(messageData?.isEmpty ?? false)
                    SearchBar.isHidden = (messageData?.isEmpty ?? false)
                    tv.reloadData()
                }
                
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    
                    NoDataImage.isHidden = !(messageData?.isEmpty ?? false)
                    NoDataLbl.isHidden = !(messageData?.isEmpty ?? false)
                    SearchBar.isHidden = (messageData?.isEmpty ?? false)
                    NoDataLbl.text = error.localizedDescription
                }
            }
        }
    }
    
    func ReadStatusUpdate(type: String,detail_id: String) {
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: staffDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
            
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
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update_archive, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: staffDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
            
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
    
    @IBAction func backAct() {
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let Message = SearchData?[indexPath.row]
        
        switch Message?.type {
            
        case "ATTACHMENT":
            
            if Message?.file_path?.first?.type == "VIDEO"{
                
                let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.VideoTVCell, for: indexPath) as! VideoTVCell
                
                cell.titleLbl.text = Message?.title
                cell.descriptContent.onExpandableTap = {
                    cell.descriptContent.isExpanded.toggle()
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
                cell.delegate = self
                let formattedDateString = dateFormatter.convertDate(Message?.date ?? "") ?? ""
                cell.datelbl.setStyledDateTime(dateString: formattedDateString, timeString: Message?.time)
                cell.confic(Message?.file_path?.first?.url ?? "")
                cell.newImg.isHidden = !(Message?.is_unread ?? false)
                
                return cell
            }else{
                let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.TAttacmentTVC, for: indexPath) as! TAttacmentTVC
                
                
                cell.titleLbl.text = Message?.title
                cell.delegate = self
                cell.descriptionLbl.setupExpandable(text: Message?.description ?? "")
                cell.descriptionLbl.onExpandableTap = {
                    cell.descriptionLbl.isExpanded.toggle()
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
                let formattedDateString = dateFormatter.convertDate(Message?.date ?? "") ?? ""
                cell.dateLbl.setStyledDateTime(dateString: formattedDateString, timeString: Message?.time)
                cell.confic(Message?.file_path ?? [])
                cell.readImg.isHidden = !(Message?.is_unread ?? false)
                return cell
            }
            
        case "TEXT":
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.TextHistoryTVCell, for: indexPath) as! TextHistoryTVCell
            
           
            
            cell.sendBtnheight.constant = 0
            cell.sendBtnWidth.constant = 0
            cell.DateLabel.textAlignment = .right
            cell.sendBtn.isHidden = true
            
            cell.MessageTitle.text = Message?.title
           // cell.descriptContent.text = Message?.content
            
            
            cell.ExpandDelegate = self
           
            cell.configure(with: Message?.content ?? "",
                               expanded: Message?.isExpand ?? false,
                               isUnread: Message?.is_unread ?? false)
            
            let formattedDateString = dateFormatter.convertDate(Message?.date ?? "") ?? ""
            
            cell.DateLabel.setStyledDateTime(dateString: formattedDateString, timeString: Message?.time)
            
                cell.configureShimmer()
            
            return cell
            
            
        case "VOICE":
            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.HistoryTC, for: indexPath) as! HistoryTC
            cell.sendbtn.isHidden = true
            cell.sentBtnHeight.constant = 0
            cell.sentBtnWidth.constant = 0
            cell.contentlbl.text = Message?.description
            cell.audioPlayUrl = Message?.content ?? ""
            
            let formattedDateString = dateFormatter.convertDate(Message?.date ?? "") ?? ""
            
            cell.datelbl.setStyledDateTime(dateString: formattedDateString, timeString: Message?.time)
            
            cell.configureShimmer()
           
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
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
                
                get_messages_archive()
                
                tv.tableFooterView = nil
                shouldShowFooter = false
            })
        } else {
            
            shouldShowFooter = false
        }
    }
}

@available(iOS 14.0, *)
extension MessageFromManagementViewController: UISearchBarDelegate {
    
}

@available(iOS 14.0, *)
extension MessageFromManagementViewController: TextExpandCellDelegate, ReadUpades {
    
    func didTapExpand(in cell: TextHistoryTVCell) {
        guard let indexPath = tv.indexPath(for: cell) else { return }
        guard var message = SearchData?[indexPath.row] else { return }

        // Toggle state
        message.isExpand = !(message.isExpand ?? false)
        SearchData?[indexPath.row] = message

        // API Call (on first view)
        if message.is_unread == true {
            if message.is_archive == true {
                ReadStatusUpdateArchive(type: message.type ?? "", detail_id: message.id ?? "")
            } else {
                ReadStatusUpdate(type: message.type ?? "", detail_id: message.id ?? "")
            }
            SearchData?[indexPath.row].is_unread = false
            cell.NewImageView.isHidden = true
        }

        // Reload cell for layout changes
        tv.beginUpdates()
        tv.reloadRows(at: [indexPath], with: .automatic)
        tv.endUpdates()
    }
    
    func readStatus(attachment: Attachment) {
        
        if attachment.is_archive == true {
            ReadStatusUpdateArchive(type: attachment.type ?? "", detail_id: attachment.id ?? "")
        } else {
            ReadStatusUpdate(type: attachment.type ?? "", detail_id: attachment.id ?? "")
        }
    }
}
