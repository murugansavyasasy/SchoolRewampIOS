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
    func setAmountLabel(paid: Double?, discount: Double?, pending: Double?) {

        let attributed = NSMutableAttributedString()

        // Paid
        if let paid = paid, paid > 0 {
            let text = "Paid: ₹\(paid)"
            let attr = NSAttributedString(string: text, attributes: [
                .foregroundColor: UIColor.black,
                .font: UIFont.boldSystemFont(ofSize: 14)
            ])
            attributed.append(attr)
        }
        // Pending
        if let pending = pending, pending > 0 {
            let text = " Pending: ₹\(pending)"
            let attr = NSAttributedString(string: text, attributes: [
                .foregroundColor: UIColor.systemRed,
                .font: UIFont.boldSystemFont(ofSize: 13)
            ])
            attributed.append(attr)
        }
        
        // Discount
        if let discount = discount, discount > 0 {
            let text = "( Disc: ₹\(discount)) "
            let attr = NSAttributedString(string: text, attributes: [
                .foregroundColor: UIColor.systemPurple,
                .font: UIFont.systemFont(ofSize: 13, weight: .medium)
            ])
            attributed.append(attr)
        }


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
