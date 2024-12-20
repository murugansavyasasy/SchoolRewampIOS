//
//  LeveHistoryVC.swift
//  VsSchoolChimes
//
//  Created by admin on 19/12/24.
//

import UIKit
import DropDown

class LeveHistoryVC: UIViewController,UITableViewDelegate,UITableViewDataSource, UpdateDelegate {

    @IBOutlet weak var monthWish: UIView!
    @IBOutlet weak var monthBtn: UIButton!
    var leaveResuest = [LeaveRequest(fromDate: "12 Sep 24", toDate: "13 Sep 24", status: "Pending"),LeaveRequest(fromDate: "11 Oct 24", toDate: "12 Oct 24", status: "Aproved"),LeaveRequest(fromDate: "08 Nov 24", toDate: "10 Sep 24", status: "Pending"),LeaveRequest(fromDate: "12 Dec 24", toDate: "13 Dec 24", status: "Aproved")]
    @IBOutlet weak var historyTable: UITableView!
    var EditDropdown = DropDown()
    var navigatedelegate:navigateDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        historyTable.register(UINib(nibName: "LeveHistoryTV", bundle: nil), forCellReuseIdentifier: "LeveHistoryTV")
    }
    
    @IBAction func monthWishFilter(_ sender: UIButton) {

        let dateFormatter = DateFormatter()
           dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Change locale if needed
           let monthNames = dateFormatter.monthSymbols // This returns ["January", "February", ..., "December"]
           
        EditDropdown.dataSource = monthNames ?? [] // Use month names as data source
           
           EditDropdown.anchorView = monthWish
           EditDropdown.bottomOffset = CGPoint(x: 0, y: monthWish.bounds.height)
           EditDropdown.direction = .bottom
           EditDropdown.width = monthWish.bounds.width
           EditDropdown.show()
           
           EditDropdown.selectionAction = { [self] (index: Int, item: String) in
               self.monthBtn.setTitle(item, for: .normal)
           }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaveResuest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTable.dequeueReusableCell(withIdentifier: "LeveHistoryTV", for: indexPath) as! LeveHistoryTV
        cell.fromDateLbl.text = leaveResuest[indexPath.row].fromDate
        cell.toDateLbl.text = leaveResuest[indexPath.row].toDate
        cell.aproveLbl.text = leaveResuest[indexPath.row].status
        if leaveResuest[indexPath.row].status == "Aproved"{
            cell.statusBtn.backgroundColor = Colornames.AprovedClr
            cell.satusImg.image = ImageName.check
            cell.aproveLbl.textColor = .white
            cell.edit.isHidden =  true
            cell.editHeight.constant = 0
        }else{
            cell.statusBtn.backgroundColor = Colornames.pendingClr
            cell.satusImg.image = ImageName.Pending
        }
        cell.leaverequest = leaveResuest[indexPath.row]
        cell.deltBtn.tag = indexPath.row
        cell.editBtn.tag = indexPath.row

        cell.delegate = self
        
        cell.approvedBy.attributedText = descript(for: "I hope this message finds you well. I am feeling unwell and will not be able to attend work on [mention date(s)]. I will keep you updated on my condition and inform you of my return to work.", expanded: false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSeeMoreTap(_:)))
        cell.approvedBy.tag = indexPath.row // Tag the label with the row index
        cell.approvedBy.isUserInteractionEnabled = true
        cell.approvedBy.addGestureRecognizer(tapGesture)
        
        
        
        return cell
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
        historyTable.beginUpdates()
        historyTable.endUpdates()
    }
    
    //MARK: TEXT ADD SEE MORE
    func descript(for fullDescription: String, expanded: Bool) -> NSAttributedString {
        // If expanded, show full text with "See less"
        if expanded {
            let fullString = fullDescription + CommonStringFile.seeLess
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
                fullString = truncatedDescription + CommonStringFile.seemore
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
    
    
    
}
struct LeaveRequest{
    let fromDate:String
    let toDate:String
    let status:String
}
