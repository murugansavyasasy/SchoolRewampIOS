//
//  LeveHistoryVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit
import DropDown

class LeveHistoryVC: UIViewController,UITableViewDelegate,UITableViewDataSource, UpdateDelegate {

    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var monthWish: UIView!
    @IBOutlet weak var monthBtn: UIButton!
    @IBOutlet weak var fromLbl: UILabel!
    @IBOutlet weak var toLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    var leaveResuest = [LeaveRequest(fromDate: "12 Sep 24", toDate: "13 Sep 24", status: "Pending", reson: "I hope this message finds you well. I am feeling unwell and will not be able to attend work on [mention date(s)]. I will keep you updated on my condition and inform you of my return to work.", isExpanded: false),LeaveRequest(fromDate: "11 Oct 24", toDate: "12 Oct 24", status: "Aproved", reson: "I hope this message finds you well. I am feeling unwell and will not be able to attend work on [mention date(s)]. I will keep you updated on my condition and inform you of my return to work.", isExpanded: false),LeaveRequest(fromDate: "08 Nov 24", toDate: "10 Nov 24", status: "Pending", reson: "I hope this message finds you well. I am feeling unwell and will not be able to attend work on [mention date(s)]. I will keep you updated on my condition and inform you of my return to work.", isExpanded: false),LeaveRequest(fromDate: "12 Dec 24", toDate: "13 Dec 24", status: "Rejected", reson: "I hope this message finds you well. I am feeling unwell and will not be able to attend work on [mention date(s)]. I will keep you updated on my condition and inform you of my return to work.", isExpanded: false)]
    var filterData:[LeaveRequest]?
    @IBOutlet weak var historyTable: UITableView!
    var EditDropdown = DropDown()
    var navigatedelegate:navigateDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        filterData = leaveResuest
        // Do any additional setup after loading the view.
        historyTable.register(UINib(nibName: CellConfingName.LeveHistoryTV, bundle: nil), forCellReuseIdentifier: CellConfingName.LeveHistoryTV)
        fromLbl.setFont(style:.body, size: FontSize.BodySize)
        toLbl.setFont(style:.body, size: FontSize.BodySize)
        statusLbl.setFont(style:.body, size: FontSize.BodySize)
        headerTitle.setFont(style:.body, size: FontSize.BodySize)
        let calendar = Calendar.current
        let currentDate = Date()

        // Get the current month number
        let currentMonth = calendar.component(.month, from: currentDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM" // "MMMM" gives the full month name (e.g., December)
        filterData = filterByMonth(selectedMonth: currentMonth)
        let monthName = dateFormatter.string(from: currentDate)
        monthBtn.setTitle(monthName, for: .normal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentViewTapped))
        view.isUserInteractionEnabled = true // Ensure interaction is enabled
        view.addGestureRecognizer(tapGesture)
    }
    @objc func contentViewTapped() {
        
//        ShowPopup.isHidden = true
    }
    @IBAction func monthWishFilter(_ sender: UIButton) {

        let dateFormatter = DateFormatter()
           dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Change locale if needed
        let monthNames = dateFormatter.monthSymbols ?? [] // This returns ["January", "February", ..., "December"]

           // Add "All" as the first option
//           monthNames.insert("All", at: 0)
           
           EditDropdown.dataSource = monthNames // Use updated list with "All"
           
           EditDropdown.anchorView = monthWish
           EditDropdown.bottomOffset = CGPoint(x: 0, y: monthWish.bounds.height)
           EditDropdown.direction = .bottom
           EditDropdown.width = monthWish.bounds.width
           EditDropdown.show()
           
           EditDropdown.selectionAction = { [self] (index: Int, item: String) in
               self.monthBtn.setTitle(item, for: .normal)
               
//               if item == "All" {
//                   // Show all data if "All" is selected
//                   filterData = leaveResuest
//               } else {
                   // Filter leaveResuest by the selected month
                   let selectedMonth = index // Adjust index because "All" is now the first item
                   filterData = filterByMonth(selectedMonth: selectedMonth + 1)
//               }
               
               historyTable.reloadData()
           }
    }
    func filterByMonth(selectedMonth: Int) -> [LeaveRequest] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yy" // Match date format to your data
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // Adjust timezone if needed

        return leaveResuest.filter { request in
            guard let fromDateText = request.fromDate,
                  let toDateText = request.toDate else {
                return false
            }

            guard let fromDate = dateFormatter.date(from: fromDateText),
                  let toDate = dateFormatter.date(from: toDateText) else {
                print("Date parsing failed for: \(fromDateText), \(toDateText)")
                return false
            }
            
            let calendar = Calendar.current
            var currentDate = fromDate
            
            while currentDate <= toDate {
                let currentMonth = calendar.component(.month, from: currentDate)
                if currentMonth == selectedMonth {
                    return true // Match found
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            
            return false // No match found
        }
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterData?.count ?? 0
    }
    
    // MARK: Description with See More
    func descript(for fullDescription: String, expanded: Bool) -> NSAttributedString {
        let fullString: String
        let actionText: String
        
        if expanded {
            fullString = fullDescription + " See less"
            actionText = "See less"
        } else {
            let truncatedDescription = fullDescription.count > 100 ? String(fullDescription.prefix(100)) + "..." : fullDescription
            fullString = truncatedDescription + " See more"
            actionText = "See more"
        }
        
        let attributedText = NSMutableAttributedString(string: fullString)
        let actionRange = (fullString as NSString).range(of: actionText)
        attributedText.addAttribute(.foregroundColor, value: UIColor.link, range: actionRange)
        attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: actionRange)
        return attributedText
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTable.dequeueReusableCell(withIdentifier: CellConfingName.LeveHistoryTV, for: indexPath) as! LeveHistoryTV

        guard let leaveData = filterData?[indexPath.row] else { return cell }

        // Configure cell labels and views
        cell.fromDateLbl.text = leaveData.fromDate
        cell.toDateLbl.text = leaveData.toDate
        cell.aproveLbl.text = leaveData.status
        
        // Status-based customization
        if leaveData.status == "Aproved" {
            cell.statusBtn.backgroundColor = Colornames.AprovedClr
            cell.satusImg.image = ImageName.check
            cell.aproveLbl.textColor = .white
            cell.edit.isHidden = true
            cell.editHeight.constant = 0
        } else if leaveData.status == "Rejected" {
            cell.statusBtn.backgroundColor = .red
            cell.satusImg.image = UIImage(systemName: "multiply.circle.fill")
            cell.aproveLbl.textColor = .white
            cell.satusImg.tintColor = .white
        } else {
            cell.aproveLbl.textColor = .white
            cell.satusImg.tintColor = .white
            cell.statusBtn.backgroundColor = Colornames.pendingClr
            cell.satusImg.image = ImageName.Pending
        }

        // Configure description with "See More" or "See Less"
        cell.approvedBy.attributedText = descript(for: leaveData.reson, expanded: leaveData.isExpanded)
        
        // Add gesture recognizer for tapping on "See More" or "See Less"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
        cell.approvedBy.isUserInteractionEnabled = true
        cell.approvedBy.addGestureRecognizer(tapGesture)
        cell.approvedBy.tag = indexPath.row // Use tag to identify the row

        // Set up delegates and button tags
        cell.leaverequest = leaveData
        cell.deltBtn.tag = indexPath.row
        cell.editBtn.tag = indexPath.row
        cell.delegate = self
        return cell
    }

    // Handle the tap gesture on "See More" or "See Less"
    @objc func handleSeeMoreTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? UILabel else { return }
        let indexPath = IndexPath(row: tappedLabel.tag, section: 0)
        guard var leaveData = filterData?[indexPath.row] else { return }
        
        // Check if the label contains "See More" or "See Less"
        if let labelText = tappedLabel.text {
            if labelText.contains("See more") {
                leaveData.isExpanded = true
                tappedLabel.text = tappedLabel.text?.replacingOccurrences(of: "See more", with: "See less")
            } else if labelText.contains("See less") {
                leaveData.isExpanded = false
                tappedLabel.text = tappedLabel.text?.replacingOccurrences(of: "See less", with: "See more")
            }
            filterData?[indexPath.row] = leaveData
            historyTable.reloadRows(at: [indexPath], with: .automatic)
        }
    }



    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func delete(index: Int, UpdateDetails: LeaveRequest,Updated:Bool) {
        if !Updated{
            leaveResuest.remove(at: index)
            historyTable.reloadData()
        }else{
            navigatedelegate?.navigate(index: 0, leaveRequest: UpdateDetails)
        }
    }

}
struct LeaveRequest{
    let fromDate:String?
    let toDate:String?
    let status:String
    let reson:String
    var isExpanded:Bool
}
