//
//  ReciverAttachmentrVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 18/04/25.
//

import UIKit
import DropDown
import AVKit

protocol ReadUpades{
    func readStatus(attachment:Attachment)
}
class ReciverAttachmentrVC: UIViewController, UISearchBarDelegate, shareDelegate, ReadUpades {
    
    
    func share(url: String) {
        // Convert the string to a URL
        if let videoURL = URL(string: url) {
            // Initialize the activity view controller with the video URL
            let activityVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            UIPasteboard.general.string = url
            self.present(activityVC, animated: true, completion: nil)
        } else {
            print("Invalid video URL.")
        }
    }
    
    func playvideo(index: Int) {
        guard let videoURL = filteredAttachments?[index].file_path?.first?.url, !videoURL.isEmpty,
              let url = URL(string: videoURL) else {
            print("Invalid URL")
            return
        }
        
        let player = AVPlayer(url: url)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        
        // Observe UI visibility changes
        playerViewController?.addObserver(self, forKeyPath: "showsPlaybackControls", options: [.new, .initial], context: nil)
        
        // Present AVPlayerViewController
        if let playerVC = playerViewController {
            present(playerVC, animated: true) {
                player.play()
            }
        }
        
        // Add the download button
    }
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var searchAndFilterStack: UIStackView!
    @IBOutlet weak var filterImgIcon: UIImageView!
    @IBOutlet weak var standerd: UILabel!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var attachmentTable: UITableView!
    @IBOutlet weak var FilterCV: UICollectionView!
    @IBOutlet weak var EmptyView: UIView!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var NodataLbl: UILabel!
    
    
    var attachmentData = [Attachment]()
    var filteredAttachments:[Attachment]?
    var SearchAttachments:[Attachment]?
    var filterDropDown = DropDown()
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var shouldShowFooter = true
    var playerViewController: AVPlayerViewController?
    var Filters = ["All", "Image", "Video", "Document"]
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    var FilterType = "All"
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentName.text = studentDetails?.name
        standerd.text = "\(studentDetails?.standard_name ?? "") - \(studentDetails?.section_name ?? "")"
        studentName.setFont(style: .body, size: FontSize.BodySize)
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        
        standerd.setFont(style: .body, size:10)
        setupView()
        fetchAttachments()
        setupTableFooter()
    }
    
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    
    private func setupView() {
        
        NodataLbl.isHidden = true
        NodataImage.isHidden = true
        EmptyView.isHidden = true
        FilterCV.isHidden = true
        RegisterCell()
        searchBar.delegate = self
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.searchTextField.addDoneButton()
        
        let filterTap = UITapGestureRecognizer(target: self, action: #selector(showFilterOptions))
        filterImgIcon.addGestureRecognizer(filterTap)
        filterImgIcon.isUserInteractionEnabled = true
        FilterCV.delegate = self
        FilterCV.dataSource = self
    }
    
    @objc private func showFilterOptions() {
        FilterCV.isHidden.toggle()
    }
    
    private func applyFilter(type: String) {
        if type == "All"{
            filteredAttachments = attachmentData
        } else {
            
            filteredAttachments = attachmentData.filter { attachmentData in
                attachmentData.file_path?.first?.type == type.uppercased()
            }
        }
        
        SearchAttachments = filteredAttachments
        NodataLbl.text = "No Data Found"
        NodataImage.isHidden = !(SearchAttachments?.isEmpty ?? false)
        NodataLbl.isHidden = !(SearchAttachments?.isEmpty ?? false)
        EmptyView.isHidden = !(SearchAttachments?.isEmpty ?? false)
        attachmentTable.reloadData()
    }
    
    private func fetchArchiveAttachments() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_communication_attachment_list_archive,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token: studentDetails?.access_token ?? ""
        ) { [self] (result: Result<AttachmentsResponse, Error>) in
            
            
            DispatchQueue.main.async { [self] in
                if #available(iOS 15.0, *) {
                    self.hideLottieProgressLoader()
                }
                
                switch result {
                case .success(let response):
                    if response.status == true{
                        self.hideView(ishide: true)
                        attachmentData.append(contentsOf: response.data ?? [])
                        filteredAttachments = attachmentData
                        applyFilter(type: Filters[selectedIndex.item])
                        attachmentTable.reloadData()
                        
                    }else{
                        if attachmentData.count == 0{
                            self.hideView(ishide: false)
                            self.NodataLbl.text = response.message
                        }
                    }
                case .failure(let error):
                    print("Error fetching attachments:", error.localizedDescription)
                    self.hideView(ishide: false)
                    self.NodataLbl.text = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchAttachments() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        
        APIService.shared.makeApi(
            url: ServiceUrl.comm_communication_attachment_list,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token:studentDetails?.access_token ?? ""
        ) { [weak self] (result: Result<AttachmentsResponse, Error>) in
            
            guard let self = self else { return }
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    self.hideLottieProgressLoader()
                }
                
                switch result {
                case .success(let response):
                    if response.status == true{
                        print("attachment==>>", response.data ?? [])
                        self.hideView(ishide: true)
                        self.attachmentData = response.data ?? []
                        self.filteredAttachments = response.data
                        self.SearchAttachments = response.data
                        self.attachmentTable.reloadData()
                    }else{
                        
                        self.hideView(ishide: false)
                        self.NodataLbl.text = response.message
                    }
                    
                case .failure(let error):
                    print("Error fetching attachments:", error.localizedDescription)
                    self.hideView(ishide: false)
                    self.NodataLbl.text = error.localizedDescription
                }
            }
        }
    }
    
    func hideView(ishide: Bool) {
        NodataImage.isHidden =  ishide
        NodataLbl.isHidden = ishide
        EmptyView.isHidden = ishide
        searchAndFilterStack.isHidden = !ishide
    }
    @IBAction func backBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    private func RegisterCell() {
        attachmentTable.register(UINib(nibName: CellConfingName.TAttacmentTVC, bundle: nil),
                                 forCellReuseIdentifier: CellConfingName.TAttacmentTVC)
        
        attachmentTable.register(UINib(nibName: CellConfingName.VideoTVCell, bundle: nil),
                                 forCellReuseIdentifier: CellConfingName.VideoTVCell)
        
        FilterCV.register(UINib(nibName: CellConfingName.FiltersCvCell, bundle: nil),
                          forCellWithReuseIdentifier: CellConfingName.FiltersCvCell)
    }
    
    // MARK: - Search Bar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            SearchAttachments = filteredAttachments
            return
        }else {
            // Filter the data
            SearchAttachments = filteredAttachments?.filter {
                let date = dateFormatter.convertDate($0.date ?? "")?.lowercased()
                return date?.contains(searchText.lowercased()) ?? false ||
                ($0.title?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ($0.description?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        
        NodataLbl.text = "No Data Found"
        NodataImage.isHidden = !(SearchAttachments?.isEmpty ?? false)
        NodataLbl.isHidden = !(SearchAttachments?.isEmpty ?? false)
        EmptyView.isHidden = !(SearchAttachments?.isEmpty ?? false)

        attachmentTable.reloadData()
    }

    func ReadStatusUpdateArchive(type: String,detail_id: String,filterType:String){
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update_archive, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
            
            switch result {
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    
                    DispatchQueue.main.async { [self] in
                        attachmentData = attachmentData.map { attachment in
                            var updated = attachment
                            if attachment.id == detail_id {
                                updated.is_unread = false
                            }
                            return updated
                        }

                        applyFilter(type: filterType)
                    }
                }else{
                    
                }
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    func ReadStatusUpdate(type: String,detail_id: String,filterType:String){
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
            
            switch result {
            case .success(let SuccessMessage):
                
                if SuccessMessage.status == true {
                    DispatchQueue.main.async { [self] in
                        attachmentData = attachmentData.map { attachment in
                            var updated = attachment
                            if attachment.id == detail_id {
                                updated.is_unread = false
                            }
                            return updated
                        }
                        applyFilter(type: filterType)
                    }
                }
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    func readStatus(attachment: Attachment) {
        if attachment.is_archive ?? false{
            ReadStatusUpdateArchive(type:"ATTACHMENT", detail_id: attachment.id ?? "", filterType: FilterType)
        }else{
            ReadStatusUpdate(type:"ATTACHMENT", detail_id: attachment.id ?? "", filterType: FilterType)
        }
        
    }
}

extension ReciverAttachmentrVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("SearchAttachments?.count ?? 0",SearchAttachments?.count ?? 0)
        return SearchAttachments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = SearchAttachments?[indexPath.row] else {
            return UITableViewCell() // Safely return a default cell if data is nil
        }
        
        switch data.file_path?.first?.type?.uppercased() {
        case "VIDEO":
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.VideoTVCell, for: indexPath) as! VideoTVCell
            cell.confic(data.file_path?.first?.url ?? "")
            cell.attachment = data
            cell.file_path = data.file_path
            cell.delegate = self
            cell.descriptContent
                .setupExpandable(
                    text: data.description ?? ""
                )
            cell.descriptContent.onExpandableTap = {
                cell.descriptContent.isExpanded.toggle()
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            cell.datelbl.text = data.date?.convertToTargetDateFormat() ?? "-"
            cell.titleLbl.text = data.title
            cell.configure(indexPath: indexPath)
            cell.onVideoTapped = { tappedIndexPath in
                if let item = self.SearchAttachments?[tappedIndexPath.row]{
                    self.playVideo(for: item)
                }
            }
            
            cell.layoutIfNeeded()
            return cell
            
        case "DOCUMENT":
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.TAttacmentTVC, for: indexPath) as! TAttacmentTVC
            cell.descriptionLbl
                .setupExpandable(
                    text: data.description ?? ""
                )
            cell.descriptionLbl.onExpandableTap = {
                cell.descriptionLbl.isExpanded.toggle()
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            
            cell.delegate = self
            cell.attachment = data
            cell.confic(data.file_path ?? [])
            cell.titleLbl.text = data.title
            cell.dateLbl.text = data.date?.convertToTargetDateFormat() ?? "-"
            cell.readImg.isHidden = !(data.is_unread ?? false)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.TAttacmentTVC, for: indexPath) as! TAttacmentTVC
            cell.titleLbl.text = data.title
            cell.descriptionLbl
                .setupExpandable(
                    text: data.description ?? ""
                )
            cell.descriptionLbl.onExpandableTap = {
                cell.descriptionLbl.isExpanded.toggle()
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            cell.confic(data.file_path ?? [])
            cell.readImg.isHidden = !(data.is_unread ?? false)
            cell.delegate = self
            cell.attachment = data
            cell.dateLbl.text = data.date?.convertToTargetDateFormat() ?? "-"
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func setupTableFooter() {
        if shouldShowFooter {
            if let footer = Bundle.main.loadNibNamed("SeeMoreFooterView", owner: self, options: nil)?.first as? SeeMoreFooterView {
                footer.frame = CGRect(x: 0, y: 0, width: attachmentTable.frame.width, height: 60)
                let buttonTitle = "See More"
                let attributedString = NSMutableAttributedString(string: buttonTitle)
                
                let customFont = UIFont(name: "Poppins-Medium", size: 17) ?? UIFont.systemFont(ofSize: 18)
                attributedString.addAttribute(.font, value: customFont, range: NSRange(location: 0, length: buttonTitle.count))
                
                // Apply underline style
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: buttonTitle.count))
                footer.SeeMoreBtn.setAttributedTitle(attributedString, for: .normal)
                let seeMoreTap = UITapGestureRecognizer(target: self, action: #selector(seeMoreAction))
                footer.SeeMoreBtn.addGestureRecognizer(seeMoreTap)
                footer.SeeMoreBtn.isUserInteractionEnabled = true
                attachmentTable.tableFooterView = footer
            }
        } else {
            attachmentTable.tableFooterView = nil
        }
    }
    
    @objc func seeMoreAction() {
        if let footer = attachmentTable.tableFooterView {
            UIView.animate(withDuration: 0.3, animations: {
                footer.alpha = 0
            }, completion: {[self] _ in
                // Hide the footer after animation completes.
                attachmentTable.tableFooterView = nil
                shouldShowFooter = false
                fetchArchiveAttachments()
            })
        } else {
            // In case footer is already nil.
            shouldShowFooter = false
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    func playVideo(for item: Attachment) {
            
            let vc = VideoPreviewVc(nibName: nil, bundle: nil)
            vc.url = item.file_path?.first?.url
            vc.titles = item.title
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        }
}

extension ReciverAttachmentrVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
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
        selectedIndex = indexPath
        let type = Filters[selectedIndex.item]
        FilterType = type
        applyFilter(type: type)
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
