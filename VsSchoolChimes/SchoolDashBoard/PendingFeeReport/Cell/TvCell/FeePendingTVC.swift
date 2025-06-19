//
//  FeePendingTVC.swift
//  VoicesnapSchoolApp
//
//  Created by chandhru on 22/04/24.

import UIKit

@available(iOS 15.0, *)
class FeePendingTVC: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var feeTableTable: UITableView!
    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var keyNameLbl: UILabel!

    // MARK: - Properties
    var feeItems: [FeeData] = []
    var pendingFee = false
    private var isConfigured = false

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupInnerTable()
        applyShadowAndCornerRadius(to: outerView, backgroundColor: .systemGray6)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        tableHeight.constant = 0
        isConfigured = false
    }

    // MARK: - Configuration
    func configure(with section: [FeeData]) {
        if isConfigured { return }

        feeItems = section
        isConfigured = true

        feeTableTable.reloadData()
//        feeTableTable.layoutIfNeeded()
        tableHeight.constant = feeTableTable.contentSize.height
//
//        if let parentTableView = self.superview as? UITableView {
//            parentTableView.beginUpdates()
//            parentTableView.endUpdates()
//        }
    }

    // MARK: - TableView Setup
    private func setupInnerTable() {
        feeTableTable.dataSource = self
        feeTableTable.delegate = self
        feeTableTable.isScrollEnabled = false
        feeTableTable.backgroundColor = .clear
        feeTableTable.separatorStyle = .none
        feeTableTable.showsVerticalScrollIndicator = false
        feeTableTable.showsHorizontalScrollIndicator = false

        gradientView.layer.cornerRadius = 10
        gradientView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

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
            return UITableViewCell()
        }

        let item = feeItems[indexPath.row]
        cell.nameLbl.text = item.type_name
        cell.amountLbl.text = item.amount
        cell.amountLbl.textColor = pendingFee ? UIColor.red1 : .aproved
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.outerView.backgroundColor = pendingFee ? UIColor.red1 : .aproved
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
