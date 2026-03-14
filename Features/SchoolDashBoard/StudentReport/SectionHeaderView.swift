//
//  SectionHeaderView.swift
//  School Chimes
//
//  Created by Chandhru on 13/03/26.
//

import UIKit
protocol FeeSectionReloadDelegate: AnyObject {
    func reloadSection()
}
class SectionHeaderView: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var arrowIcon: UIButton!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var statusLbl: UIButton!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var arrowImg: UIButton!
    var breakDown: [CarryoverBreakdown]?
    weak var delegate: FeeSectionReloadDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        tableview.register(UINib(nibName: "PaymentHistoryTVC", bundle: nil), forCellReuseIdentifier: "PaymentHistoryTVC")
        tableview.delegate = self
        tableview.dataSource = self
        outerView.setShadow()
        statusLbl.layer.cornerRadius = statusLbl.frame.height/2
        arrowImg.layer.cornerRadius = statusLbl.frame.height/2
        tableview.isScrollEnabled = false
        totalLbl.numberOfLines = 0
        totalLbl.lineBreakMode = .byWordWrapping
    }
    func resizedSymbol(name: String) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        return UIImage(systemName: name, withConfiguration: config)?
            .withRenderingMode(.alwaysTemplate)
    }
    func confic(breakDown: [CarryoverBreakdown]?) {

        self.breakDown = breakDown
        tableview.reloadData()
        
        DispatchQueue.main.async {
            self.tableview.layoutIfNeeded()
            self.tableHeight.constant = self.tableview.contentSize.height
            self.delegate?.reloadSection()
        }
        
    }
    func setAmountLabel(paid: Double, discount: Double, pending: Double) {

        let paidText = "Paid: ₹\(paid)  "
        let discountText = "(\u{00A0}Disc:\u{00A0}₹\(discount)\u{00A0})  "
        let pendingText = "Pending:\u{00A0}₹\(pending)"

        let finalText = paidText + discountText + pendingText
        let attributed = NSMutableAttributedString(string: finalText)

        // Paid Style
        attributed.addAttributes([
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 14)
        ], range: (finalText as NSString).range(of: paidText))

        // Discount Style
        attributed.addAttributes([
            .foregroundColor: UIColor.systemPurple,
            .font: UIFont.systemFont(ofSize: 13, weight: .medium)
        ], range: (finalText as NSString).range(of: discountText))

        // Pending Style
        attributed.addAttributes([
            .foregroundColor: UIColor.systemRed,
            .font: UIFont.boldSystemFont(ofSize: 13)
        ], range: (finalText as NSString).range(of: pendingText))
        totalLbl.numberOfLines = 0
        totalLbl.lineBreakMode = .byWordWrapping
        totalLbl.attributedText = attributed
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breakDown?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentHistoryTVC", for: indexPath) as! PaymentHistoryTVC
        cell.configureInstallment(data:breakDown?[indexPath.row])
        cell.outerView.layer.cornerRadius = 8
        cell.outerView.layer.borderWidth = 0.5
        cell.outerView.layer.borderColor = UIColor.systemGray6.cgColor
        cell.outerView.backgroundColor = UIColor.systemGray6
        return cell
    }
    
}
