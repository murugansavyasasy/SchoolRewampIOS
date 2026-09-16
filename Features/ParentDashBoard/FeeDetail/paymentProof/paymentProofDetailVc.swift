//
//  paymentProofDetailVc.swift
//  School Chimes
//
//  Created by apple on 08/09/26.
//

import UIKit

class paymentProofDetailVc: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var paymentItem: PaymentDetailItem!

    private enum DetailSectionType {
        case feeBreakdown
        case amountBreakdown
        case validationStatus
        case uploadedProofs
        case transactionDetail(detail: ProofDetailInfo, isFirst: Bool)
    }

    private var sections: [DetailSectionType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupNavigationBar()
        setupTableView()
        buildSections()
    }
    @IBAction func backBtnAct(_ sender: UIButton) {
        dismiss(animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let rowStr = UserDefaults.standard.string(forKey: "ScrollRow"),
           let row = Int(rowStr),
           row < sections.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .top, animated: false)
            }
        }
    }

//    private func setupNavigationBar() {
//        title = "Payment Details"
//        navigationController?.navigationBar.prefersLargeTitles = false
//        navigationItem.largeTitleDisplayMode = .never
//    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0) // #F8FAFC
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 240.0
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 32, right: 0)

        // Register All Card XIBs
        tableView.register(
            UINib(nibName: FeeBreakdownCardCell.reuseIdentifier, bundle: nil),
            forCellReuseIdentifier: FeeBreakdownCardCell.reuseIdentifier
        )
        tableView.register(
            UINib(nibName: AmountBreakdownCardCell.reuseIdentifier, bundle: nil),
            forCellReuseIdentifier: AmountBreakdownCardCell.reuseIdentifier
        )
        tableView.register(
            UINib(nibName: ValidationStatusCardCell.reuseIdentifier, bundle: nil),
            forCellReuseIdentifier: ValidationStatusCardCell.reuseIdentifier
        )
        tableView.register(
            UINib(nibName: UploadedProofsCardCell.reuseIdentifier, bundle: nil),
            forCellReuseIdentifier: UploadedProofsCardCell.reuseIdentifier
        )
        tableView.register(
            UINib(nibName: TransactionDetailCardCell.reuseIdentifier, bundle: nil),
            forCellReuseIdentifier: TransactionDetailCardCell.reuseIdentifier
        )
    }

    private func buildSections() {
        guard paymentItem != nil else { return }
        sections.removeAll()

        // 1. Fee Breakdown Section (only if fees exist)
        if let fees = paymentItem.feeDetails,
           (fees.term?.isEmpty == false ||
            fees.others?.isEmpty == false ||
            fees.carryover?.isEmpty == false ||
            fees.transport?.isEmpty == false ||
            fees.hostel?.isEmpty == false ||
            fees.quantity?.isEmpty == false) {
            sections.append(.feeBreakdown)
        }

        // 2. Amount Breakdown Section
        sections.append(.amountBreakdown)

        // 3. Validation Status Section
        sections.append(.validationStatus)

        // 4. Uploaded Proofs Section
        if !paymentItem.proofUploaded.isEmpty {
            sections.append(.uploadedProofs)
        }

        // 5. Transaction Receipts Section
        for (index, detail) in paymentItem.proofDetails.enumerated() {
            sections.append(.transactionDetail(detail: detail, isFirst: index == 0))
        }

        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension paymentProofDetailVc: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionType = sections[indexPath.row]

        switch sectionType {
        case .feeBreakdown:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FeeBreakdownCardCell.reuseIdentifier,
                for: indexPath
            ) as? FeeBreakdownCardCell else {
                return UITableViewCell()
            }
            cell.configure(with: paymentItem)
            let args = ProcessInfo.processInfo.arguments
            if args.contains("-ExpandOthers") {
                cell.expandSection("others")
            } else if args.contains("-ExpandCarryover") {
                cell.expandSection("carryover")
            } else if args.contains("-ExpandTransport") {
                cell.expandSection("transport")
            } else if args.contains("-ExpandHostel") {
                cell.expandSection("hostel")
            } else if args.contains("-ExpandQuantity") {
                cell.expandSection("quantity")
            } else if args.contains("-ExpandTerm") {
                cell.expandSection("term")
            }
            cell.onToggleExpand = { [weak self] in
                self?.tableView.performBatchUpdates(nil, completion: nil)
            }
            return cell

        case .amountBreakdown:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: AmountBreakdownCardCell.reuseIdentifier,
                for: indexPath
            ) as? AmountBreakdownCardCell else {
                return UITableViewCell()
            }
            cell.configure(with: paymentItem)
            return cell

        case .validationStatus:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ValidationStatusCardCell.reuseIdentifier,
                for: indexPath
            ) as? ValidationStatusCardCell else {
                return UITableViewCell()
            }
            cell.configure(with: paymentItem)
            return cell

        case .uploadedProofs:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: UploadedProofsCardCell.reuseIdentifier,
                for: indexPath
            ) as? UploadedProofsCardCell else {
                return UITableViewCell()
            }
            cell.viewController = self
            cell.configure(with: paymentItem.proofUploaded)
            cell.onOpenProofURL = { [weak self] url in
                let fileURL: [FilePath] = self?.paymentItem.proofUploaded.map {
                    FilePath(url: $0.awsURL, type: $0.type)
                } ?? []
                
                let imageVC = ImageShowVc(nibName: nil, bundle: nil)
                imageVC.fileURL = fileURL
                imageVC.modalPresentationStyle = .fullScreen
                self?.present(imageVC, animated: true)
            }
            return cell

        case .transactionDetail(let detail, let isFirst):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: TransactionDetailCardCell.reuseIdentifier,
                for: indexPath
            ) as? TransactionDetailCardCell else {
                return UITableViewCell()
            }
            cell.configure(
                with: detail,
                showSectionHeader: isFirst,
                totalReceiptsCount: paymentItem.proofDetails.count
            )
            return cell
        }
    }
}
