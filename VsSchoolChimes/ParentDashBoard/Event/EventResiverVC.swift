//
//  EventResiverVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit

@available(iOS 14.0, *)
class EventResiverVC: UIViewController, SelectNotice{
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var searchHeight: NSLayoutConstraint!
    
    @IBOutlet weak var noDataImg: UIImageView!
    
    var titleLbl = "Event"
    var button1 = "Event/Holidays".translated()
    var button2 = "Holiday".translated()
    var previousOffset: CGFloat = 0.0
    var delegate : HistorySelectDelegate?
    let day = ["Monday","Tuesday","Wednesday","Thursday","Friday"]
    var shouldShowFooter = true
    var event:[EventList]?
    let dateFormatter = DateFormatter()
    var playIndex : Int = 0
    var studentDetails = UserDefaultFileManager.get_child_Details()
    var SearchData: [EventList]?
    var FilteredData: [EventList]?
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.placeholder = CommonStringFile.Search.translated()
        searchbar.applyRightTxt()
        searchbar.delegate = self
        searchbar.addDoneButton()
        GetEvent()
        tabelViewRegister()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        view
//            .applyGradient(
//                colors: [Colornames.gradientgreen,Colornames.gradientBlue],
//                startPoint: CGPoint(x: 1, y: 0.2),
//                endPoint: CGPoint(x: 0, y: 0.5)
//            )
//    }
    
    //MARK: Cell Registration
    func tabelViewRegister() {
        tableview.delegate = self
        tableview.dataSource = self
        
        let nib = UINib(nibName:CellConfingName.EventTVC, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.EventTVC)
        let nib2 = UINib(nibName: CellConfingName.ReciverAttendReportTV, bundle: nil)
        let nib3 = UINib(nibName: CellConfingName.VideoTVCell, bundle: nil)
        tableview.register(nib2, forCellReuseIdentifier: CellConfingName.ReciverAttendReportTV)
        tableview.register(nib3, forCellReuseIdentifier: CellConfingName.VideoTVCell)
    }
    
    func gradientcolours(button : UIButton,colours : [CGColor]){
        
        
        button.layer.sublayers?.removeAll { $0 is CAGradientLayer }
        
        // Create and configure the gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colours
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.5)
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = button.layer.cornerRadius
        
        // Insert the gradient layer into the button's layer
        button.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    func GetEvent() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        APIService.shared.makeApi(
            url: ServiceUrl.api_school_event_get_event,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token:studentDetails?.access_token ?? "") { [self] (result: Result<EventResponse, Error>) in
                DispatchQueue.main.async {
                    if #available(iOS 15.0, *) {
                        self.hideLottieProgressLoader()
                    }
                    
                    switch result {
                    case .success(let successMessage):
                        self.event = successMessage.data
                        self.FilteredData = self.event
                        self.SearchData = self.event
                        self.tableview.reloadData()
                        if self.event?.count == 0{
                            self.noDataLbl.text = successMessage.message
                            self.noDataLbl.isHidden = false
                            self.noDataImg.isHidden = false
                            
                            self.tableview.isHidden = true
                            self.searchbar.isHidden = true
                            self.searchHeight.constant = 0
                        }else{
                            self.noDataLbl.isHidden = true
                            self.noDataImg.isHidden = true
                            //                            self.searchHeight.constant = 56
                            self.searchHeight.constant = 0
                            self.tableview.isHidden = false
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        if self.event?.count == 0{
                            self.noDataLbl.text = error.localizedDescription
                            self.noDataLbl.isHidden = false
                            self.noDataImg.isHidden = false
                            self.tableview.isHidden = true
                            self.searchbar.isHidden = true
                        }
                        
                    }
                }
            }
    }
    
}

//MARK: Tableview Functions
@available(iOS 14.0, *)
extension EventResiverVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilteredData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = FilteredData?[indexPath.row]
        if event?.file_path.first?.type?.uppercased() == "VIDEO"{
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.VideoTVCell, for: indexPath) as! VideoTVCell
            cell.selectionStyle = .none
            cell.confic(event?.file_path.first?.url ?? "")
            cell.descriptContent.setupExpandable(text: event?.description ?? "")
            cell.descriptContent.onExpandableTap = {
                cell.descriptContent.isExpanded.toggle()
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            cell.newImg.isHidden = true
            cell.datelbl.isHidden = true
            cell.dateAndtimeLbl.isHidden = false
            let formattedDateString = dateFormatter.convertDate(event?.date ?? "") ?? ""
            cell.dateAndtimeLbl.text =  "🕒 Event starts at: " + (
                event?.time ?? ""
            ) + " , " + "   🗓️   " + formattedDateString
            cell.titleLbl.text = event?.title
            cell.subjectName.text = "📍" + (event?.venue ?? "")
            cell.subjectName.isHidden = false
            cell.forwardBtn.isHidden = true
            
            cell.configure(indexPath: indexPath)
            
            // Handle the tap event with closure
            cell.onVideoTapped = { tappedIndexPath in
                if let item = self.FilteredData?[tappedIndexPath.row]{
                    self.playVideo(for: item)
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.EventTVC, for: indexPath) as! EventTVC
            cell.selectionStyle = .none
            cell.ImageCollectionView.isHidden = true
            cell.withofImageView.constant = 0
            cell.dateLblHeight.constant = 0
            // Configure cell data
            cell.subjectName.text = "📍" + (event?.venue ?? "")
            cell.topics.text = event?.title ?? ""
            cell.eventTimeLbl.isHidden = false
            let formattedDateString = dateFormatter.convertDate(event?.date ?? "") ?? ""
            cell.eventTimeLbl.text = "🕒 Event starts at: " + (
                event?.time ?? ""
            ) + " , " + "   🗓️   " + formattedDateString
            cell.dateLble.isHidden = true
            //                cell.dateLble.text = ""
            cell.forwordBtn.isHidden = true
            cell.SelectBtnHeight.constant = 0
            cell.newView.isHidden = true
            // Load image if available
            if let urls = event?.file_path, urls.count != 0{
                cell.ImageCollectionView.isHidden = false
                cell.pageViewController.isHidden = urls.count <= 1
                cell.CvHeight.constant = 100
                cell.loadImage(urls: urls)
            }
            let contentText = event?.description ?? ""
            cell.descriptionLbl.setupExpandable(text: contentText)
            
            
            //                cell.dateLble.setStyledDateTime(dateString: formattedDateString, timeString: event?.time)
            //                cell.newView.isHidden = contentText.count <= 100
            cell.descriptionLbl.onExpandableTap = { [weak tableView] in
                cell.descriptionLbl.isExpanded.toggle()
                cell.newView.isHidden = true
                tableView?.beginUpdates()
                tableView?.endUpdates()
            }
            
            cell.cellview.layoutIfNeeded()
            return cell
        }
        //            cell.CvHeight.constant = 0
        
    }
    
    
    func playVideo(for item: EventList) {
        
        let vc = VideoPreviewVc(nibName: nil, bundle: nil)
        vc.url = item.file_path.first?.url
        vc.titles = item.title
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        
        // Check for scroll direction
        if contentOffsetY > previousOffset && contentOffsetY > 0 {
        }
        previousOffset = contentOffsetY
    }
    
    
    
    //MARK: TEXT ADD SEE MORE
    
    
    
    
    func didTapButton(title: String, content: String, items: [FilePath]) {
        delegate?.select(Title: title, Description: content, Images: [], pdf: "")
        
    }
    
    
    //    // Method to load the footer from nib and set it as tableFooterView
    //    func setupTableFooter() {
    //        if shouldShowFooter {
    //            if let footer = Bundle.main.loadNibNamed("SeeMoreFooterView", owner: self, options: nil)?.first as? SeeMoreFooterView {
    //                // Adjust the frame based on your needs.
    //                footer.frame = CGRect(x: 0, y: 0, width: tableview.frame.width, height: 60)
    //
    //                // Add a tap gesture recognizer to the button to trigger the hide action.
    //                let seeMoreTap = UITapGestureRecognizer(target: self, action: #selector(seeMoreAction))
    //                footer.SeeMoreBtn.addGestureRecognizer(seeMoreTap)
    //                footer.SeeMoreBtn.isUserInteractionEnabled = true
    //
    //                // Set the footer view.
    //                tableview.tableFooterView = footer
    //            }
    //        } else {
    //            tableview.tableFooterView = nil
    //        }
    //    }
    //
    //    @objc func seeMoreAction() {
    //        print("Footer button tapped. Hiding the footer.")
    //
    //        // Animate the footer fade-out if desired.
    //        if let footer = tableview.tableFooterView {
    //            UIView.animate(withDuration: 0.3, animations: {
    //                footer.alpha = 0
    //            }, completion: {[self] _ in
    //                // Hide the footer after animation completes.
    //                tableview.tableFooterView = nil
    //                shouldShowFooter = false
    //
    //                tableview.reloadData()
    //            })
    //        } else {
    //            // In case footer is already nil.
    //            shouldShowFooter = false
    //        }
    //    }
    
}


//MARK: Searchbar Delegate
@available(iOS 14.0, *)
extension EventResiverVC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchbar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            SearchData = FilteredData
        } else {
            SearchData = FilteredData?.filter { notice in
                (notice.title.lowercased().contains(searchText.lowercased()) ?? false) ||
                (notice.description.lowercased().contains(searchText.lowercased()) ?? false) ||
                (
                    notice.date
                        .lowercased()
                        .contains(searchText.lowercased()) ?? false
                )
            }
        }
        
        noDataImg.isHidden = !(SearchData?.isEmpty ?? false)
        noDataLbl.isHidden = !(SearchData?.isEmpty ?? false)
        tableview.reloadData()
    }
}
