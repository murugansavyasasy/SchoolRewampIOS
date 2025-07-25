//
//  EventHistoryVC.swift
//  VsSchoolChimes
//
//  Created by admin on 04/12/24.
//

import UIKit

@available(iOS 14.0, *)
class EventHistoryVC: UIViewController,UITableViewDelegate,UITableViewDataSource,SelectNotice, UISearchBarDelegate {
    
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var nodataImg: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var historyTable: UITableView!
    var previousOffset: CGFloat = 0.0
    var delegate : HistorySelectDelegate?
    var event:[EventList]?
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTable.register(UINib(nibName: CellConfingName.EventTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.EventTVC)
        historyTable.delegate = self
        historyTable.dataSource = self
        searchBar.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GetEvent()
    }
    func GetEvent() {
        if #available(iOS 15.0, *) {
            showLottieProgressLoader(animationName: "loader (2)")
        }
        APIService.shared.makeApi(
            url: ServiceUrl.api_school_event_get_event,
            parameters: [:],
            type: ApitTypeSringFile.GET,
            token:UserDefaultFileManager.get_staff_Details()?.access_token ?? "") { [self] (result: Result<EventResponse, Error>) in
                DispatchQueue.main.async {
                    if #available(iOS 15.0, *) {
                        self.hideLottieProgressLoader()
                    }
                    switch result {
                    case .success(let successMessage):
//                        self.event = successMessage.data
                        self.historyTable.reloadData()
                        if self.event?.count == 0{
                            self.noDataLbl.text = successMessage.message
                            self.noDataLbl.isHidden = false
                            self.nodataImg.isHidden = false
                            
                            self.historyTable.isHidden = true
                        }else{
                            self.noDataLbl.isHidden = true
                            self.nodataImg.isHidden = true
                            self.historyTable.isHidden = false
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        if self.event?.count == 0{
                            self.noDataLbl.text = error.localizedDescription
                            self.noDataLbl.isHidden = false
                            self.nodataImg.isHidden = false
                            self.historyTable.isHidden = true
                            self.searchBar.isHidden = true
                        }
                        
                    }
                }
            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTable.dequeueReusableCell(withIdentifier: CellConfingName.EventTVC, for: indexPath) as! EventTVC
        cell.CvHeight.constant = 0
        cell.ImageCollectionView.isHidden = true
        let data = event?[indexPath.row]
        cell.subjectName.text = data?.venue
        cell.topics.text = data?.title ?? ""
        cell.dateLble.text =  data?.date ?? ""
        cell.ImageCollectionView.isHidden = (data?.file_path.isEmpty ?? true)
        if let urls = data?.file_path, urls.count != 0{
            cell.ImageCollectionView.isHidden = false
            cell.CvHeight.constant = 150
            cell.loadImage(urls: urls)
        }
        cell.newView.isHidden = true
        cell.descriptionLbl.setupExpandable(text: data?.description ?? "")
        cell.descriptionLbl.onExpandableTap = {
            cell.descriptionLbl.isExpanded.toggle()
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        cell.cellview.layoutIfNeeded()
        return cell
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
    
    func didTapButton(title: String, content: String, items: [FilePath]) {
        delegate?.select(Title: title, Description: content, Images: [], pdf: "")
        
    }
}
