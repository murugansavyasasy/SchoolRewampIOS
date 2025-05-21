//
//  ReciverAttachmentrVC.swift
//  VsSchoolChimes
//
//  Created by Chandhru on 18/04/25.
//

import UIKit
import DropDown
import AVKit

class ReciverAttachmentrVC: UIViewController, UISearchBarDelegate, shareDelegate {
    
    func share(url: String) {
        // Convert the string to a URL
        if let videoURL = URL(string: url) {
            // Initialize the activity view controller with the video URL
            let activityVC = UIActivityViewController(activityItems: [videoURL], applicationActivities: nil)
            print(videoURL)
            // For iPad: Popover presentation configuration
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = self.view // Set a source view for iPad compatibility
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // Center the popover
                popoverController.permittedArrowDirections = []
            }
            UIPasteboard.general.string = url
            // Present the activity view controller
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

    @IBOutlet weak var filterImgIcon: UIImageView!
    @IBOutlet weak var standerd: UILabel!
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var attachmentTable: UITableView!
    @IBOutlet weak var FilterCV: UICollectionView!
    @IBOutlet weak var EmptyView: UIView!
    @IBOutlet weak var NodataImage: UIImageView!
    @IBOutlet weak var NodataLbl: UILabel!
    
    
    var attachmentData:[Attachment]?
    var filteredAttachments:[Attachment]?
    var SearchAttachments:[Attachment]?
    var filterDropDown = DropDown()
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var shouldShowFooter = true
    var playerViewController: AVPlayerViewController?
    var Filters = ["All", "Image", "Video", "Pdf"]
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    var FilterType = "All"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        studentName.text = studentDetails?.name
        standerd.text = "\(studentDetails?.standard_name ?? ""),\(studentDetails?.section_name ?? "")"
        studentName.setFont(style: .body, size: FontSize.BodySize)
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
           // filteredAttachments = attachmentData?.filter { $0.file_path?.first?.type?.uppercased() == type }
            
            filteredAttachments = attachmentData?.filter { attachmentData in
                attachmentData.file_path?.first?.type == type.uppercased()
            }
        }
        
        SearchAttachments = filteredAttachments
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
                    attachmentData?.append(contentsOf: response.data ?? [])
                   // filteredAttachments?.append(contentsOf: response.data ?? [])
                    applyFilter(type: Filters[selectedIndex.item])
                    attachmentTable.reloadData()
                case .failure(let error):
                    print("Error fetching attachments:", error.localizedDescription)
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
                    
                    self.attachmentData = response.data
                    self.filteredAttachments = response.data
                    self.SearchAttachments = response.data
                    self.attachmentTable.reloadData()
                    
                    
                case .failure(let error):
                    print("Error fetching attachments:", error.localizedDescription)
                }
            }
        }
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
        guard !searchText.isEmpty else {
            SearchAttachments = filteredAttachments
            attachmentTable.reloadData()
            return
        }
        
        SearchAttachments = filteredAttachments?.filter {
            ($0.title?.lowercased().contains(searchText.lowercased()) ?? false) ||
            ($0.description?.lowercased().contains(searchText.lowercased()) ?? false) ||  ($0.date?.lowercased().contains(searchText.lowercased()) ?? false)
        }
        NodataImage.isHidden = !(SearchAttachments?.isEmpty ?? false)
        NodataLbl.isHidden = !(SearchAttachments?.isEmpty ?? false)
        EmptyView.isHidden = !(SearchAttachments?.isEmpty ?? false)
        attachmentTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        SearchAttachments = filteredAttachments
        attachmentTable.reloadData()
    }
}

extension ReciverAttachmentrVC: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return SearchAttachments?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = SearchAttachments?[indexPath.row] else {
            return UITableViewCell() // Safely return a default cell if data is nil
        }

        switch data.file_path?.first?.type?.uppercased() {
        case "VIDEO":
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.VideoTVCell, for: indexPath) as! VideoTVCell
            cell.descriptContent.text = data.description
            cell.datelbl.text = data.date
            cell.videoName.text = data.title
            cell.playvideo(url: "https://player.vimeo.com/video/1084600934?title=0&amp;byline=0&amp;portrait=0&amp;badge=0&amp;autopause=0&amp;player_id=0&amp;app_id=177030\" width=\"400\" height=\"300\" frameborder=\"0\" allow=\"autoplay; fullscreen; picture-in-picture; clipboard-write; encrypted-media\" title=\"The only way I could do that")
            
            return cell

        case "DOCUMENT":
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.TAttacmentTVC, for: indexPath) as! TAttacmentTVC
            cell.titleLbl.text = data.title
            cell.descriptionLbl.text = data.description
            cell.dateLbl.text = data.date
            return cell

        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.TAttacmentTVC, for: indexPath) as! TAttacmentTVC
            cell.titleLbl.text = data.title
            cell.descriptionLbl.text = data.description
            cell.dateLbl.text = data.date
            cell.homeworkDocs = data.file_path
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
        print("Footer button tapped. Hiding the footer.")
        
        // Animate the footer fade-out if desired.
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
            
            applyFilter(type: type)
            
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
