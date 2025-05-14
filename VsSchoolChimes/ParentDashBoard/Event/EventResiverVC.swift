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
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var TitleHederLbl: UILabel!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var noDataLbl: UILabel!
    @IBOutlet weak var searchHeight: NSLayoutConstraint!
    
    @IBOutlet weak var noDataImg: UIImageView!
    
    @IBOutlet weak var StandardLbl: UILabel!
 
    var titleLbl = "Event"
    var button1 = "Event".translated()
    var button2 = "Holiday".translated()
    var previousOffset: CGFloat = 0.0
    var delegate : HistorySelectDelegate?
    let day = ["Monday","Tuesday","Wednesday","Thursday","Friday"]
    var section = 0
    var shouldShowFooter = true
    var event:[EventList]?
    var playIndex : Int = 0
    var studentDetails = UserDefaultFileManager.get_child_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backBtn.setTitle(button1.translated(), for: .normal)
        backBtn.applyBackButton()
        searchbar.placeholder = CommonStringFile.Search.translated()
        searchbar.applyRightTxt()
        searchbar.delegate = self
        backBtn.setTitleFont(style: .primary, size: FontSize.HeaderSize)
        NameLbl.setFont(style: .body, size: FontSize.BodySize)
        StandardLbl.setFont(style: .body, size: FontSize.BodySize)
        searchbar.addDoneButton()
        uiConficration()
        GetEvent()
        tabelViewRegister()
        setupTableFooter()
    }
    
    @IBAction func backbtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        bgView.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
        
    }
    
    //MARK: Cell Registration
    func tabelViewRegister() {
        tableview.delegate = self
        tableview.dataSource = self
        
        let nib = UINib(nibName:CellConfingName.NoticeBoardTvcellTableViewCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell)
        let nib2 = UINib(nibName: CellConfingName.ReciverAttendReportTV, bundle: nil)
        tableview.register(nib2, forCellReuseIdentifier: CellConfingName.ReciverAttendReportTV)
    }
    
    func uiConficration(){
        TitleHederLbl.setFont(style: .header, size: FontSize.HeaderSize)
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
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
    @IBAction func selectionController(_ sender: UISegmentedControl) {
        
        section = sender.selectedSegmentIndex
        tableview.reloadData()
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
                            self.searchHeight.constant = 56
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.NoticeBoardTvcellTableViewCell, for: indexPath) as! NoticeBoardTvcellTableViewCell
            cell.cellview.changeHeightAndAnimate(40, 110, 31, 80, top: 5)
            cell.ishomework = true
            cell.dicriptContent.attributedText = descript(for: "Annual Day is a special occasion celebrated by schools, colleges, and organizations to mark the completion of another successful year. It is a time for showcasing the talents and achievements of students or members through cultural performances.", expanded: false)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
            cell.delegate = self
            cell.dicriptContent.tag = indexPath.row // Tag the label with the row index
            cell.dicriptContent.isUserInteractionEnabled = true
            cell.dicriptContent.addGestureRecognizer(tapGesture)
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.ReciverAttendReportTV, for: indexPath) as! ReciverAttendReportTV
            cell.TakenLbl.text = "Tamilar Thirunaal"
            cell.MonthView.backgroundColor =  UIColor(named: "Red")
            cell.DateView.backgroundColor =  .white
            cell.DateView.layer.borderWidth = 0.5
            cell.monthLbl.text = "JAN"
            cell.DateLbl.text = "14"
            cell.StatusView.isHidden = true
            return cell
        }
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
    
    @objc func handleSeeMoreTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let indexPath = IndexPath(row: label.tag, section: 0)
        let fullDescription = "Annual Day is a special occasion celebrated by schools, colleges, and organizations to mark the completion of another successful year. It is a time for showcasing the talents and achievements of students or members through cultural performances."
        
        // Toggle the label between expanded and collapsed states
        let isExpanded = label.numberOfLines == 0
        label.numberOfLines = isExpanded ? 3 : 0
        
        // Update the label text with the appropriate "See more" or "See less" state
        label.attributedText = descript(for: fullDescription, expanded: !isExpanded)
        
        // Animate the cell height change
        tableview.beginUpdates()
        tableview.endUpdates()
    }
    
    //MARK: TEXT ADD SEE MORE
    func descript(for fullDescription: String, expanded: Bool) -> NSAttributedString {
        // If expanded, show full text with "See less"
        if expanded {
            let fullString = fullDescription + CommonStringFile.seeLess.translated()
            let attributedText = NSMutableAttributedString(string: fullString)
            
            // Set "See less" text to blue and underline it
            let seeLessRange = (fullString as NSString).range(of: "See less")
            attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: seeLessRange)
            
            return attributedText
        } else {
            var fullString = ""
            // Otherwise, truncate and show "See more"
            if fullDescription.count > 120{
                let truncatedDescription = String(fullDescription.prefix(100))
                fullString = truncatedDescription + CommonStringFile.seemore.translated()
            }else{
                fullString = fullDescription
            }
            let attributedText = NSMutableAttributedString(string: fullString)
            
            // Set "See more" text to blue and underline it
            let seeMoreRange = (fullString as NSString).range(of: "See more")
            attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: seeMoreRange)
            return attributedText
        }
    }
    
    func didTapButton(title: String, content: String, items: [FilePath]) {
        delegate?.select(Title: title, Description: content, Images: [], pdf: "")
        
    }
    
    // Method to load the footer from nib and set it as tableFooterView
    func setupTableFooter() {
        if shouldShowFooter {
            if let footer = Bundle.main.loadNibNamed("SeeMoreFooterView", owner: self, options: nil)?.first as? SeeMoreFooterView {
                // Adjust the frame based on your needs.
                footer.frame = CGRect(x: 0, y: 0, width: tableview.frame.width, height: 60)
                
                // Add a tap gesture recognizer to the button to trigger the hide action.
                let seeMoreTap = UITapGestureRecognizer(target: self, action: #selector(seeMoreAction))
                footer.SeeMoreBtn.addGestureRecognizer(seeMoreTap)
                footer.SeeMoreBtn.isUserInteractionEnabled = true
                
                // Set the footer view.
                tableview.tableFooterView = footer
            }
        } else {
            tableview.tableFooterView = nil
        }
    }
    
    @objc func seeMoreAction() {
        print("Footer button tapped. Hiding the footer.")
        
        // Animate the footer fade-out if desired.
        if let footer = tableview.tableFooterView {
            UIView.animate(withDuration: 0.3, animations: {
                footer.alpha = 0
            }, completion: {[self] _ in
                // Hide the footer after animation completes.
                tableview.tableFooterView = nil
                shouldShowFooter = false
                
                tableview.reloadData()
            })
        } else {
            // In case footer is already nil.
            shouldShowFooter = false
        }
    }
    
}


//MARK: Searchbar Delegate
@available(iOS 14.0, *)
extension EventResiverVC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchbar.resignFirstResponder()
    }

    
}
