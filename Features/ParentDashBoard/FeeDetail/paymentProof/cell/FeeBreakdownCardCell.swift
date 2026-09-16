//
//  FeeBreakdownCardCell.swift
//  paymentProofDesign
//
//  Created by Senior iOS UI/UX Designer on 04/09/26.
//

import UIKit

final class FeeBreakdownCardCell: UITableViewCell {

    static let reuseIdentifier = "FeeBreakdownCardCell"

    // MARK: - Outlets
    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!

    // 1. Term Fees Outlets
    @IBOutlet weak var termCategoryStackView: UIStackView!
    @IBOutlet weak var termAmountLabel: UILabel!
    @IBOutlet weak var termChevronImageView: UIImageView!
    @IBOutlet weak var termDetailStackView: UIStackView!
    @IBOutlet weak var termBottomSeparatorView: UIView!

    // 2. Other Fees Outlets
    @IBOutlet weak var othersCategoryStackView: UIStackView!
    @IBOutlet weak var othersAmountLabel: UILabel!
    @IBOutlet weak var othersChevronImageView: UIImageView!
    @IBOutlet weak var othersDetailStackView: UIStackView!
    @IBOutlet weak var othersBottomSeparatorView: UIView!

    // 3. Carryover Outlets
    @IBOutlet weak var carryoverCategoryStackView: UIStackView!

    // 4. Transport Outlets
    @IBOutlet weak var transportCategoryStackView: UIStackView!
    @IBOutlet weak var transportAmountLabel: UILabel!
    @IBOutlet weak var transportChevronImageView: UIImageView!
    @IBOutlet weak var transportDetailStackView: UIStackView!
    @IBOutlet weak var transportBottomSeparatorView: UIView!

    // 5. Hostel Outlets
    @IBOutlet weak var hostelCategoryStackView: UIStackView!
    @IBOutlet weak var hostelAmountLabel: UILabel!
    @IBOutlet weak var hostelChevronImageView: UIImageView!
    @IBOutlet weak var hostelDetailStackView: UIStackView!
    @IBOutlet weak var hostelBottomSeparatorView: UIView!

    // 6. Quantity Fees Outlets
    @IBOutlet weak var quantityCategoryStackView: UIStackView!
    @IBOutlet weak var quantityAmountLabel: UILabel!
    @IBOutlet weak var quantityChevronImageView: UIImageView!
    @IBOutlet weak var quantityDetailStackView: UIStackView!

    // MARK: - Carryover Section Model
    struct CarryoverSectionViews {
        let containerStackView: UIStackView
        let headerView: UIView
        let titleLabel: UILabel
        let amountLabel: UILabel
        let chevronImageView: UIImageView
        let detailStackView: UIStackView
        let bottomSeparatorView: UIView
    }

    // MARK: - State & Callbacks
    var isTermExpanded: Bool = true
    var isOthersExpanded: Bool = false
    var expandedCarryoverIndex: Int? = nil
    var isCarryoverExpanded: Bool {
        get { expandedCarryoverIndex != nil }
        set { expandedCarryoverIndex = newValue ? 0 : nil }
    }
    var isTransportExpanded: Bool = false
    var isHostelExpanded: Bool = false
    var isQuantityExpanded: Bool = false

    private var carryoverSections: [CarryoverSectionViews] = []

    var onToggleExpand: (() -> Void)?

    private let activeChevronTint = UIColor(red: 0.118, green: 0.471, blue: 0.949, alpha: 1.0) // #1E78F2
    private let inactiveChevronTint = UIColor(red: 0.580, green: 0.639, blue: 0.722, alpha: 1.0) // #94A3B8

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardStyle()
        updateExpansionUI(animated: false)
    }

    private func setupCardStyle() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardBackgroundView.backgroundColor = .white
        cardBackgroundView.layer.cornerRadius = 16.0
        cardBackgroundView.layer.borderWidth = 1.0
        cardBackgroundView.layer.borderColor = UIColor(red: 0.90, green: 0.93, blue: 0.96, alpha: 1.0).cgColor

        cardBackgroundView.layer.shadowColor = UIColor.black.cgColor
        cardBackgroundView.layer.shadowOpacity = 0.04
        cardBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardBackgroundView.layer.shadowRadius = 6.0
        cardBackgroundView.layer.masksToBounds = false

        contentStackView.clipsToBounds = true
        termDetailStackView.clipsToBounds = true
        othersDetailStackView.clipsToBounds = true
        carryoverCategoryStackView.clipsToBounds = true
        transportDetailStackView.clipsToBounds = true
        hostelDetailStackView.clipsToBounds = true
        quantityDetailStackView.clipsToBounds = true
    }

    func configure(with item: PaymentDetailItem) {
        guard let fees = item.feeDetails else { return }

        // 1. Clear all previous dynamic rows
        [termDetailStackView, othersDetailStackView,
         transportDetailStackView, hostelDetailStackView, quantityDetailStackView].forEach { stack in
            stack?.arrangedSubviews.forEach { subview in
                stack?.removeArrangedSubview(subview)
                subview.removeFromSuperview()
            }
        }
        carryoverCategoryStackView.arrangedSubviews.forEach { subview in
            carryoverCategoryStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        carryoverSections.removeAll()

        // 2. Category Header Amounts
        termAmountLabel.text = item.termCategoryTotal
        othersAmountLabel.text = item.othersCategoryTotal
        transportAmountLabel.text = item.transportCategoryTotal
        hostelAmountLabel.text = item.hostelCategoryTotal
        quantityAmountLabel.text = item.quantityCategoryTotal

        // 3. Category Visibility based on real data presence
        let hasTerm = !(fees.term?.isEmpty ?? true)
        let hasOthers = !(fees.others?.isEmpty ?? true)
        let carryoverList = fees.carryover ?? []
        let hasCarryover = !carryoverList.isEmpty
        let hasTransport = !(fees.transport?.isEmpty ?? true)
        let hasHostel = !(fees.hostel?.isEmpty ?? true)
        let hasQuantity = !(fees.quantity?.isEmpty ?? true)

        termCategoryStackView.isHidden = !hasTerm
        othersCategoryStackView.isHidden = !hasOthers
        carryoverCategoryStackView.isHidden = !hasCarryover
        transportCategoryStackView.isHidden = !hasTransport
        hostelCategoryStackView.isHidden = !hasHostel
        quantityCategoryStackView.isHidden = !hasQuantity

        // Auto-collapse any category that is hidden
        if !hasTerm && isTermExpanded { isTermExpanded = false }
        if !hasOthers && isOthersExpanded { isOthersExpanded = false }
        if !hasCarryover && isCarryoverExpanded { expandedCarryoverIndex = nil }
        if !hasTransport && isTransportExpanded { isTransportExpanded = false }
        if !hasHostel && isHostelExpanded { isHostelExpanded = false }
        if !hasQuantity && isQuantityExpanded { isQuantityExpanded = false }

        // Default open the first available category if none is currently active
        if !isTermExpanded && !isOthersExpanded && !isCarryoverExpanded &&
           !isTransportExpanded && !isHostelExpanded && !isQuantityExpanded {
            if hasTerm { isTermExpanded = true }
            else if hasOthers { isOthersExpanded = true }
            else if hasCarryover { expandedCarryoverIndex = 0 }
            else if hasTransport { isTransportExpanded = true }
            else if hasHostel { isHostelExpanded = true }
            else if hasQuantity { isQuantityExpanded = true }
        }

        // 4. Dynamically populate sub-rows from response values
        populateTermFees(from: fees.term)
        populateOtherFees(from: fees.others)
        populateCarryoverFees(from: carryoverList)
        populateTransportFees(from: fees.transport)
        populateHostelFees(from: fees.hostel)
        populateQuantityFees(from: fees.quantity)

        updateExpansionUI(animated: false)
    }

    // MARK: - Populate Breakdown Categories

    private func populateTermFees(from terms: [TermFeeGroup]?) {
        guard let terms = terms, !terms.isEmpty else { return }
        
        var flatRows: [(title: String, amount: String, feeAmount: String, discount: String, paid: String)] = []
        for term in terms {
            let termTitle = term.termName ?? ""
            if let details = term.feesDetails, !details.isEmpty {
                for fee in details {
                    let feeTitle = fee.feeName?.trimmingCharacters(in: .whitespaces) ?? ""
                    let fullTitle = feeTitle.isEmpty ? termTitle : "\(termTitle) - \(feeTitle)"
                    flatRows.append((
                        title: fullTitle,
                        amount: fee.displayAmount,
                        feeAmount: fee.displayFeeAmount,
                        discount: fee.displayAmount,
                        paid: fee.displayPaid
                    ))
                }
            } else {
                flatRows.append((
                    title: termTitle,
                    amount: term.displayAmount,
                    feeAmount: term.displayAmount,
                    discount: CurrencyUtility.zeroAmount(),
                    paid: CurrencyUtility.zeroAmount()
                ))
            }
        }
        
        for (index, row) in flatRows.enumerated() {
            let rowView = createFeeRow(
                title: row.title,
                amount: row.amount,
                feeAmount: row.feeAmount,
                discount: row.discount,
                paid: row.paid,
                isSubItem: false
            )
            termDetailStackView.addArrangedSubview(rowView)
            if index < flatRows.count - 1 {
                termDetailStackView.addArrangedSubview(createSeparatorView())
            }
        }
    }
    
    private func populateOtherFees(from others: [OtherFeeGroup]?) {
        guard let others = others, !others.isEmpty else { return }
        
        var allRows: [UIView] = []
        for group in others {
            let headerTitle = group.feeName ?? "Other Fee"
            let headerRow = createFeeRow(
                title: headerTitle,
                amount: group.displayAmount,
                isSubItem: false,
                showsSplit: false
            )
            allRows.append(headerRow)
            
            if let months = group.monthDetails {
                for month in months {
                    let subRow = createFeeRow(
                        title: month.displayMonth,
                        amount: month.displayAmount,
                        feeAmount: month.displayFeeAmount,
                        discount: month.displaypending,
                        paid: month.displayPaid,
                        isSubItem: true
                    )
                    allRows.append(subRow)
                }
            }
        }
        
        for (idx, rowView) in allRows.enumerated() {
            othersDetailStackView.addArrangedSubview(rowView)
            if idx < allRows.count - 1 {
                othersDetailStackView.addArrangedSubview(createSeparatorView())
            }
        }
    }
    
    private func populateCarryoverFees(from carryoverList: [CarryoverFeeGroup]) {
        guard !carryoverList.isEmpty else { return }
        
        for (index, carryGroup) in carryoverList.enumerated() {
            let section = createCarryoverSection(for: carryGroup, at: index)
            carryoverSections.append(section)
            carryoverCategoryStackView.addArrangedSubview(section.containerStackView)
        }
    }
    
    private func createCarryoverSection(for carryGroup: CarryoverFeeGroup, at index: Int) -> CarryoverSectionViews {
        let containerStack = UIStackView()
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.axis = .vertical
        containerStack.spacing = 12
        containerStack.clipsToBounds = true

        // 1. Header View (Height 38)
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.heightAnchor.constraint(equalToConstant: 38).isActive = true
        headerView.clipsToBounds = true

        // Icon Box (38x38, rounded 10, bg #EDF4FE)
        let iconBox = UIView()
        iconBox.translatesAutoresizingMaskIntoConstraints = false
        iconBox.backgroundColor = UIColor(red: 0.929, green: 0.957, blue: 0.996, alpha: 1.0)
        iconBox.layer.cornerRadius = 10
        iconBox.clipsToBounds = true

        let iconLabel = UILabel()
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = "⏮️"
        iconLabel.font = UIFont.systemFont(ofSize: 17)
        iconLabel.textAlignment = .center
        iconBox.addSubview(iconLabel)

        NSLayoutConstraint.activate([
            iconBox.widthAnchor.constraint(equalToConstant: 38),
            iconBox.heightAnchor.constraint(equalToConstant: 38),
            iconLabel.centerXAnchor.constraint(equalTo: iconBox.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconBox.centerYAnchor)
        ])

        // Title Label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = UIColor(red: 0.059, green: 0.090, blue: 0.165, alpha: 1.0)
        if let typeName = carryGroup.feeGroupTypeName, !typeName.isEmpty {
            titleLabel.text = "Carryover (\(typeName))"
        } else {
            titleLabel.text = "Carryover"
        }
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.82
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Chevron Image View
        let chevronImageView = UIImageView()
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))
        chevronImageView.tintColor = inactiveChevronTint
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.setContentHuggingPriority(.required, for: .horizontal)

        // Amount Label
        let amountLabel = UILabel()
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.font = UIFont.boldSystemFont(ofSize: 16)
        amountLabel.textColor = UIColor(red: 0.059, green: 0.090, blue: 0.165, alpha: 1.0)
        amountLabel.textAlignment = .right
        amountLabel.text = carryGroup.displayAmount
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Button for Tap
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = index
        button.addTarget(self, action: #selector(dynamicCarryoverTapped(_:)), for: .touchUpInside)

        headerView.addSubview(iconBox)
        headerView.addSubview(titleLabel)
        headerView.addSubview(amountLabel)
        headerView.addSubview(chevronImageView)
        headerView.addSubview(button)

        NSLayoutConstraint.activate([
            iconBox.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            iconBox.topAnchor.constraint(equalTo: headerView.topAnchor),
            iconBox.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: iconBox.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),

            chevronImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14),

            amountLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            amountLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            button.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            button.topAnchor.constraint(equalTo: headerView.topAnchor),
            button.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])

        // 2. Detail Stack View (spacing 8, clipsToBounds)
        let detailStackView = UIStackView()
        detailStackView.translatesAutoresizingMaskIntoConstraints = false
        detailStackView.axis = .vertical
        detailStackView.spacing = 8
        detailStackView.clipsToBounds = true
        detailStackView.isHidden = true

        // Populate detail sub-rows from carryGroup with separator after every split
        var allRows: [UIView] = []
        let carryGroups = carryGroup.detailedGroups
        for group in carryGroups {
            let groupHdr = createFeeRow(
                title: group.feeName,
                amount: group.totalAmount,
                isSubItem: false,
                showsSplit: false
            )
            allRows.append(groupHdr)

            for termRow in group.termRows {
                let subRow = createFeeRow(
                    title: termRow.termName,
                    amount: termRow.amount,
                    feeAmount: termRow.feeAmount,
                    discount: termRow.feeAmount,
                    paid: termRow.paid,
                    isSubItem: true
                )
                allRows.append(subRow)
            }
        }

        for (idx, rowView) in allRows.enumerated() {
            detailStackView.addArrangedSubview(rowView)
            if idx < allRows.count - 1 {
                detailStackView.addArrangedSubview(createSeparatorView())
            }
        }

        // 3. Bottom Separator
        let bottomSeparatorView = UIView()
        bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparatorView.backgroundColor = UIColor(red: 0.941, green: 0.957, blue: 0.976, alpha: 1.0)
        bottomSeparatorView.heightAnchor.constraint(equalToConstant: 0.75).isActive = true
        bottomSeparatorView.isHidden = true

        containerStack.addArrangedSubview(headerView)
        containerStack.addArrangedSubview(detailStackView)
        containerStack.addArrangedSubview(bottomSeparatorView)

        return CarryoverSectionViews(
            containerStackView: containerStack,
            headerView: headerView,
            titleLabel: titleLabel,
            amountLabel: amountLabel,
            chevronImageView: chevronImageView,
            detailStackView: detailStackView,
            bottomSeparatorView: bottomSeparatorView
        )
    }
    
    private func populateTransportFees(from transportList: [TransportFeeGroup]?) {
        guard let transportList = transportList, !transportList.isEmpty else { return }
        
        var allRows: [UIView] = []
        for group in transportList {
            let headerRow = createFeeRow(
                title: group.formattedGroupTitle,
                amount: group.displayAmount,
                isSubItem: false,
                showsSplit: false
            )
            allRows.append(headerRow)
            
            if let busMonths = group.busMonthDetails {
                // Filter out zero fee months if non-zero months are present
                let nonZeroMonths = busMonths.filter { month in
                    CurrencyUtility.parseNumericValue(from: month.feeAmount) > 0.0
                }
                let monthsToShow = nonZeroMonths.isEmpty ? busMonths : nonZeroMonths
                for month in monthsToShow {
                    let subRow = createFeeRow(
                        title: month.displayMonth,
                        amount: month.displayAmount,
                        feeAmount: month.displayFeeAmount,
                        discount: month.displayDiscount,
                        paid: month.displayPaid,
                        isSubItem: true
                    )
                    allRows.append(subRow)
                }
            }
        }
        
        for (idx, rowView) in allRows.enumerated() {
            transportDetailStackView.addArrangedSubview(rowView)
            if idx < allRows.count - 1 {
                transportDetailStackView.addArrangedSubview(createSeparatorView())
            }
        }
    }
    
    private func populateHostelFees(from hostelList: [HostelFeeGroup]?) {
        guard let hostelList = hostelList, !hostelList.isEmpty else { return }
        
        var allRows: [UIView] = []
        for group in hostelList {
            let headerRow = createFeeRow(
                title: group.formattedGroupTitle,
                amount: group.displayAmount,
                isSubItem: false,
                showsSplit: false
            )
            allRows.append(headerRow)
            
            if let hostelMonths = group.month_details {
                let nonZeroMonths = hostelMonths.filter { month in
                    CurrencyUtility.parseNumericValue(from: month.actualAmount) > 0.0
                }
                let monthsToShow = nonZeroMonths.isEmpty ? hostelMonths : nonZeroMonths
                for month in monthsToShow {
                    let subRow = createFeeRow(
                        title: month.displayMonth,
                        amount: month.displayAmount,
                        feeAmount: month.displayFeeAmount,
                        discount: month.displayDiscount,
                        paid: month.displayPaid,
                        isSubItem: true
                    )
                    allRows.append(subRow)
                }
            }
        }
        
        for (idx, rowView) in allRows.enumerated() {
            hostelDetailStackView.addArrangedSubview(rowView)
            if idx < allRows.count - 1 {
                hostelDetailStackView.addArrangedSubview(createSeparatorView())
            }
        }
    }
    
    private func populateQuantityFees(from quantityList: [QuantityFeeGroup]?) {
        guard let quantityList = quantityList, !quantityList.isEmpty else { return }
        
        for (index, qty) in quantityList.enumerated() {
            let name = qty.feeName ?? "-"
            let rowView = createFeeRow(
                title: name,
                amount: qty.displayAmount,
                feeAmount: qty.displayuom_price,
                discount: qty.displayAmount,
                paid: "-",
                isSubItem: false
            )
            quantityDetailStackView.addArrangedSubview(rowView)
            if index < quantityList.count - 1 {
                quantityDetailStackView.addArrangedSubview(createSeparatorView())
            }
        }
    }

    // MARK: - Row Factory Methods
    
    private func createFeeRow(
        title: String,
        amount: String,
        feeAmount: String = "",
        discount: String = "",
        paid: String = "",
        isSubItem: Bool,
        showsSplit: Bool = true
    ) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.clipsToBounds = true
        
        let vStack = UIStackView()
        vStack.translatesAutoresizingMaskIntoConstraints = false
        vStack.axis = .vertical
        vStack.spacing = 5
        vStack.clipsToBounds = true
        
        // 1. Top Row: Title & Amount
        let topRow = UIView()
        topRow.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        if isSubItem {
            titleLabel.font = .systemFont(ofSize: 14.5, weight: .medium)
            titleLabel.textColor = UIColor(red: 0.392, green: 0.455, blue: 0.545, alpha: 1.0) // #64748B
            let prefix = title.hasPrefix("–") || title.hasPrefix("-") ? "" : "– "
            titleLabel.text = "\(prefix)\(title)"
        } else {
            titleLabel.font = .boldSystemFont(ofSize: 15.5)
            titleLabel.textColor = UIColor(red: 0.059, green: 0.090, blue: 0.165, alpha: 1.0) // #0F172A
            titleLabel.text = title
        }
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let amountLabel = UILabel()
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        if isSubItem {
            amountLabel.font = .boldSystemFont(ofSize: 15)
            amountLabel.textColor = UIColor(red: 0.278, green: 0.333, blue: 0.412, alpha: 1.0) // #475569
        } else {
            amountLabel.font = .boldSystemFont(ofSize: 16)
            amountLabel.textColor = UIColor(red: 0.059, green: 0.090, blue: 0.165, alpha: 1.0) // #0F172A
        }
        amountLabel.textAlignment = .right
        amountLabel.text = PaymentProofDataLoader.formatCurrency(amount)
        amountLabel.setContentHuggingPriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        topRow.addSubview(titleLabel)
        topRow.addSubview(amountLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: topRow.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topRow.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: topRow.bottomAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),
            
            amountLabel.trailingAnchor.constraint(equalTo: topRow.trailingAnchor),
            amountLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            amountLabel.topAnchor.constraint(greaterThanOrEqualTo: topRow.topAnchor),
            amountLabel.bottomAnchor.constraint(lessThanOrEqualTo: topRow.bottomAnchor)
        ])
        
        vStack.addArrangedSubview(topRow)
        
        // 2. Bottom Row: 3-Column Split (FEE AMOUNT, DISCOUNT, PAID) - only if showsSplit is true
        if showsSplit {
            let splitStack = UIStackView()
            splitStack.translatesAutoresizingMaskIntoConstraints = false
            splitStack.axis = .horizontal
            splitStack.distribution = .fillEqually
            splitStack.spacing = 8
            splitStack.alignment = .fill
            
            let col1 = createColumn(caption: "ACTUAL AMOUNT", value: PaymentProofDataLoader.formatCurrency(feeAmount))
            let col2 = createColumn(caption: "PENDING", value: PaymentProofDataLoader.formatCurrency(discount))
            let col3 = createColumn(caption: "PAID", value: PaymentProofDataLoader.formatCurrency(paid))
            
            splitStack.addArrangedSubview(col1)
            splitStack.addArrangedSubview(col2)
            splitStack.addArrangedSubview(col3)
            
            vStack.addArrangedSubview(splitStack)
        }
        
        container.addSubview(vStack)
        
        let leadingIndent: CGFloat = isSubItem ? 16.0 : 0.0
        let verticalPadding: CGFloat = showsSplit ? 4.0 : 5.0
        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: leadingIndent),
            vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            vStack.topAnchor.constraint(equalTo: container.topAnchor, constant: verticalPadding),
            vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -verticalPadding)
        ])
        
        return container
    }
    
    private func createColumn(caption: String, value: String) -> UIView {
        let col = UIStackView()
        col.translatesAutoresizingMaskIntoConstraints = false
        col.axis = .vertical
        col.alignment = .leading
        col.spacing = 2
        
        let captionLabel = UILabel()
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.font = .systemFont(ofSize: 10.5, weight: .bold)
        captionLabel.textColor = UIColor(red: 0.580, green: 0.639, blue: 0.722, alpha: 1.0) // #94A3B8
        captionLabel.text = caption.uppercased()
        
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 13.5, weight: .semibold)
        valueLabel.textColor = UIColor(red: 0.278, green: 0.333, blue: 0.412, alpha: 1.0) // #475569
        valueLabel.text = value
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.8
        
        col.addArrangedSubview(captionLabel)
        col.addArrangedSubview(valueLabel)
        return col
    }
    
    private func createSeparatorView() -> UIView {
        let sep = UIView()
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.backgroundColor = UIColor(red: 0.941, green: 0.957, blue: 0.976, alpha: 1.0) // #F1F5F9
        sep.heightAnchor.constraint(equalToConstant: 0.75).isActive = true
        return sep
    }

    func expandSection(_ sectionName: String) {
        let key = sectionName.lowercased()
        isTermExpanded = (key == "term")
        isOthersExpanded = (key == "others")
        isTransportExpanded = (key == "transport")
        isHostelExpanded = (key == "hostel")
        isQuantityExpanded = (key == "quantity")
        if key == "carryover" || key == "carryover_0" {
            expandedCarryoverIndex = 0
        } else if key == "carryover_1" {
            expandedCarryoverIndex = 1
        } else if key.starts(with: "carryover_"), let idx = Int(key.replacingOccurrences(of: "carryover_", with: "")) {
            expandedCarryoverIndex = idx
        } else {
            expandedCarryoverIndex = nil
        }
        updateExpansionUI(animated: false)
    }

    // MARK: - Dynamic Carryover Tap
    @objc private func dynamicCarryoverTapped(_ sender: UIButton) {
        let index = sender.tag
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()

        if expandedCarryoverIndex == index {
            expandedCarryoverIndex = nil
        } else {
            expandedCarryoverIndex = index
            isTermExpanded = false
            isOthersExpanded = false
            isTransportExpanded = false
            isHostelExpanded = false
            isQuantityExpanded = false
        }

        updateExpansionUI(animated: false)
        onToggleExpand?()
    }

    // MARK: - IBActions
    @IBAction func termHeaderTapped(_ sender: Any) {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()

        if isTermExpanded {
            isTermExpanded = false
        } else {
            isTermExpanded = true
            isOthersExpanded = false
            expandedCarryoverIndex = nil
            isTransportExpanded = false
            isHostelExpanded = false
            isQuantityExpanded = false
        }

        updateExpansionUI(animated: false)
        onToggleExpand?()
    }

    @IBAction func othersHeaderTapped(_ sender: Any) {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()

        if isOthersExpanded {
            isOthersExpanded = false
        } else {
            isOthersExpanded = true
            isTermExpanded = false
            expandedCarryoverIndex = nil
            isTransportExpanded = false
            isHostelExpanded = false
            isQuantityExpanded = false
        }

        updateExpansionUI(animated: false)
        onToggleExpand?()
    }

    @IBAction func carryoverHeaderTapped(_ sender: Any) {
        // Fallback for legacy outlet if any
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()

        if isCarryoverExpanded {
            expandedCarryoverIndex = nil
        } else {
            expandedCarryoverIndex = 0
            isTermExpanded = false
            isOthersExpanded = false
            isTransportExpanded = false
            isHostelExpanded = false
            isQuantityExpanded = false
        }

        updateExpansionUI(animated: false)
        onToggleExpand?()
    }

    @IBAction func transportHeaderTapped(_ sender: Any) {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()

        if isTransportExpanded {
            isTransportExpanded = false
        } else {
            isTransportExpanded = true
            isTermExpanded = false
            isOthersExpanded = false
            expandedCarryoverIndex = nil
            isHostelExpanded = false
            isQuantityExpanded = false
        }

        updateExpansionUI(animated: false)
        onToggleExpand?()
    }

    @IBAction func hostelHeaderTapped(_ sender: Any) {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()

        if isHostelExpanded {
            isHostelExpanded = false
        } else {
            isHostelExpanded = true
            isTermExpanded = false
            isOthersExpanded = false
            expandedCarryoverIndex = nil
            isTransportExpanded = false
            isQuantityExpanded = false
        }

        updateExpansionUI(animated: false)
        onToggleExpand?()
    }

    @IBAction func quantityHeaderTapped(_ sender: Any) {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()

        if isQuantityExpanded {
            isQuantityExpanded = false
        } else {
            isQuantityExpanded = true
            isTermExpanded = false
            isOthersExpanded = false
            expandedCarryoverIndex = nil
            isTransportExpanded = false
            isHostelExpanded = false
        }

        updateExpansionUI(animated: false)
        onToggleExpand?()
    }

    // MARK: - Update Expansion UI
    func updateExpansionUI(animated: Bool) {
        let updateBlock = {
            // Term
            self.termDetailStackView.isHidden = !self.isTermExpanded
            self.termDetailStackView.alpha = self.isTermExpanded ? 1.0 : 0.0
            self.termBottomSeparatorView.isHidden = !self.isTermExpanded
            self.termChevronImageView.image = UIImage(systemName: self.isTermExpanded ? "chevron.up" : "chevron.down")
            self.termChevronImageView.tintColor = self.isTermExpanded ? self.activeChevronTint : self.inactiveChevronTint

            // Others
            self.othersDetailStackView.isHidden = !self.isOthersExpanded
            self.othersDetailStackView.alpha = self.isOthersExpanded ? 1.0 : 0.0
            self.othersBottomSeparatorView.isHidden = !self.isOthersExpanded
            self.othersChevronImageView.image = UIImage(systemName: self.isOthersExpanded ? "chevron.up" : "chevron.down")
            self.othersChevronImageView.tintColor = self.isOthersExpanded ? self.activeChevronTint : self.inactiveChevronTint

            // Dynamic Carryovers
            for (index, section) in self.carryoverSections.enumerated() {
                let isExpanded = (self.expandedCarryoverIndex == index)
                section.detailStackView.isHidden = !isExpanded
                section.detailStackView.alpha = isExpanded ? 1.0 : 0.0
                section.bottomSeparatorView.isHidden = !isExpanded
                section.chevronImageView.image = UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down")
                section.chevronImageView.tintColor = isExpanded ? self.activeChevronTint : self.inactiveChevronTint
            }

            // Transport
            self.transportDetailStackView.isHidden = !self.isTransportExpanded
            self.transportDetailStackView.alpha = self.isTransportExpanded ? 1.0 : 0.0
            self.transportBottomSeparatorView.isHidden = !self.isTransportExpanded
            self.transportChevronImageView.image = UIImage(systemName: self.isTransportExpanded ? "chevron.up" : "chevron.down")
            self.transportChevronImageView.tintColor = self.isTransportExpanded ? self.activeChevronTint : self.inactiveChevronTint

            // Hostel
            self.hostelDetailStackView.isHidden = !self.isHostelExpanded
            self.hostelDetailStackView.alpha = self.isHostelExpanded ? 1.0 : 0.0
            self.hostelBottomSeparatorView.isHidden = !self.isHostelExpanded
            self.hostelChevronImageView.image = UIImage(systemName: self.isHostelExpanded ? "chevron.up" : "chevron.down")
            self.hostelChevronImageView.tintColor = self.isHostelExpanded ? self.activeChevronTint : self.inactiveChevronTint

            // Quantity
            self.quantityDetailStackView.isHidden = !self.isQuantityExpanded
            self.quantityDetailStackView.alpha = self.isQuantityExpanded ? 1.0 : 0.0
            self.quantityChevronImageView.image = UIImage(systemName: self.isQuantityExpanded ? "chevron.up" : "chevron.down")
            self.quantityChevronImageView.tintColor = self.isQuantityExpanded ? self.activeChevronTint : self.inactiveChevronTint
        }

        if animated {
            UIView.animate(withDuration: 0.25) {
                updateBlock()
                self.contentView.layoutIfNeeded()
            }
        } else {
            updateBlock()
        }
    }
}
