//
//  FeePendingTVC.swift
//  VoicesnapSchoolApp
//
//  Created by chandhru on 22/04/24.

import UIKit

@available(iOS 15.0, *)
class FeePendingTVC: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableHeight: NSLayoutConstraint!  // ✅ Renamed from tableHeght
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var feeTableTable: UITableView!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var keyNameLbl: UILabel!
    
    // MARK: - Properties
    var feeItems: [FeeData] = []
    var pendingFee = false
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupInnerTable()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        tableHeight.constant = 0
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    // MARK: - Configuration
    func configure(with section: [FeeData]) {
        feeItems = section
        feeTableTable.reloadData()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.feeTableTable.layoutIfNeeded()
            self.tableHeight.constant = self.feeTableTable.contentSize.height

            // Force update cell height in the table view
            if let parentTableView = self.superview as? UITableView {
                parentTableView.beginUpdates()
                parentTableView.endUpdates()
            }
        }
    }


    // MARK: - TableView Setup
    private func setupInnerTable() {
        feeTableTable.dataSource = self
        feeTableTable.delegate = self
        feeTableTable.isScrollEnabled = false
        feeTableTable.backgroundColor = .clear
        feeTableTable.showsVerticalScrollIndicator = false
        feeTableTable.showsHorizontalScrollIndicator = false
        feeTableTable.separatorStyle = .none
        
        gradientView.layer.cornerRadius = 10
        gradientView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top corners only
        feeTableTable.register(
            UINib(nibName: CellConfingName.PendingFeeReportTableViewCell, bundle: nil),
            forCellReuseIdentifier: CellConfingName.PendingFeeReportTableViewCell
        )

        feeTableTable.register(
            UINib(nibName: "PaymentTypeTVC", bundle: nil),
            forCellReuseIdentifier: "PaymentTypeTVC"
        )
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTypeTVC", for: indexPath) as? PaymentTypeTVC else {
            print("FeePendingTVC: Failed to dequeue PaymentTypeTVC")
            return UITableViewCell()
        }

        let item = feeItems[indexPath.row]
        cell.nameLbl.text = item.type_name
        cell.amountLbl.text = item.amount
        cell.amountLbl.textColor = pendingFee ? UIColor.red1:.aproved
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.outerView.backgroundColor = pendingFee ? UIColor.red1:.aproved
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
