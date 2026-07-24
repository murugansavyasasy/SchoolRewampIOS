//
//  ActivitiesTVCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 26/11/25.
//

import UIKit
protocol ActivityCellDelegate: AnyObject {
    
    func didToggleSplit(
        subjectIndex: Int,
        splitIndex: Int,
        isChecked: Bool
    )
    func didUpdateAISplit(
        subjectIndex: Int,
        splitIndex: Int,
        isChecked: Bool,
        aiOption: String?
    )
    func didToggleRubric(
        subjectIndex: Int,
        splitIndex: Int,
        rubricIndex: Int,
        isChecked: Bool
    )
    func didToggleActivityWithRubrics(
        subjectIndex: Int,
        splitIndex: Int,
        rubrics: [RubricData],
        isChecked: Bool
    )
    func didToggleRubricsExpansion(
        splitIndex: Int,
        expanded: Bool
    )
    func didUpdateAIRubric(
        subjectIndex: Int,
        splitIndex: Int,
        rubricIndex: Int,
        isChecked: Bool,
        aiOption: String?
    )
}

class ActivitiesTVCell: UITableViewCell {

    @IBOutlet weak var CheckBoxBtnName: UIButton!
    @IBOutlet weak var activityNameLbl: UILabel!
    @IBOutlet weak var ActivitystatusLbl: UILabel!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var rubicsStack: UIStackView!
    @IBOutlet weak var ArrowBtn: UIButton!
    let dropdown = DropDown()
    weak var delegate: ActivityCellDelegate?
    private var subjectIndex = 0
    private var splitIndex = 0
    private var isAIFlow = false
    var items:[String]?
    var rubrics: [RubricData]?
    private var isRubricsExpanded = false
    var onHeightChanged: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        setupDropdown()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(
        subjectIndex: Int,
        splitIndex: Int,
        split: ActivityData,
        isAi: Bool,items: [String],
        isRubricsExpanded: Bool
    ) {
        self.subjectIndex = subjectIndex
        self.splitIndex = splitIndex
        self.isAIFlow = isAi
        dropdown.dataSource = items
        self.items = items
        let nameText = split.activity_name ?? ""
        let maxText = " (Max: \(split.max_mark ?? "") marks)"
        print(items)
        let fullText = nameText + maxText
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttributes([.foregroundColor: UIColor.black,.font: UIFont(name: "Poppins-Medium", size: 15) ?? UIFont.systemFont(ofSize: 20, weight: .semibold)], range: NSRange(location: 0, length: nameText.count))
        
        attributedString.addAttributes([.foregroundColor: UIColor.darkGray, .font : UIFont(name: "Poppins-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)], range: NSRange(location: nameText.count, length: maxText.count))
        
        activityNameLbl.attributedText = attributedString

        let isSelected = split.isChecked == true
        CheckBoxBtnName.isSelected = isSelected
        updateCheckboxUI(isChecked: isSelected)

        // ✅ STATUS
        let mapped = "Mapped to: "
        let selectedOption = split.selectedAIOption.map {$0} ?? ""
        let ActivityfullText = mapped + selectedOption
        let ActivityattributedString = NSMutableAttributedString(string: ActivityfullText)
        ActivityattributedString.addAttributes([.foregroundColor:UIColor.darkGray], range: NSRange(location: 0, length: mapped.count))
        ActivityattributedString.addAttributes([.foregroundColor : UIColor.staffExamColour], range: NSRange(location: mapped.count, length: selectedOption.count))
        ActivitystatusLbl.attributedText = ActivityattributedString
       // ActivitystatusLbl.text = split.selectedAIOption.map { "Mapped to: \($0)" }
        ActivitystatusLbl.isHidden = split.selectedAIOption == nil
        clearBtn.isHidden = split.selectedAIOption == nil

        // ✅ BACKGROUND — SINGLE SOURCE OF TRUTH
        if split.isChecked == true {
            contentView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.07)
        } else {
            contentView.backgroundColor = .systemBackground
        }
        
           self.isRubricsExpanded = isRubricsExpanded
           self.rubrics = split.rubrics
           setupRubrics(self.rubrics)
           rubicsStack.isHidden = !isRubricsExpanded
          ArrowBtn.isHidden = self.rubrics?.isEmpty ?? true
          ArrowBtn.setImage(UIImage(systemName: isRubricsExpanded ? "chevron.up" : "chevron.forward"), for: .normal)
        
        if isAi && !(self.rubrics?.isEmpty ?? true){
            CheckBoxBtnName.alpha = 0
        }else {
            CheckBoxBtnName.alpha = 1
        }
        
        updateStatusLabel(for: split)
    }

    private func updateStatusLabel(for split: ActivityData) {

        let rubricCount = split.rubrics?.count ?? 0

        // AI mapping takes highest priority
        if isAIFlow, let selectedOption = split.selectedAIOption {

            let prefix = "Mapped to: "
            let fullText = prefix + selectedOption

            let attr = NSMutableAttributedString(string: fullText)
            attr.addAttributes(
                [.foregroundColor: UIColor.darkGray],
                range: NSRange(location: 0, length: prefix.count)
            )
            attr.addAttributes(
                [.foregroundColor: UIColor.staffExamColour],
                range: NSRange(location: prefix.count, length: selectedOption.count)
            )

            ActivitystatusLbl.attributedText = attr
            ActivitystatusLbl.isHidden = false
            clearBtn.isHidden = false
            return
        }

        // Show rubric count if rubrics exist
        if rubricCount > 0 {
            ActivitystatusLbl.text = "• \(rubricCount) Rubric\(rubricCount > 1 ? "s" : "")"
            ActivitystatusLbl.textColor = .darkGray
            ActivitystatusLbl.isHidden = false
        } else {
            ActivitystatusLbl.isHidden = true
        }

        clearBtn.isHidden = true
    }
    
    @IBAction func CheckBoxBtnAct(_ sender: UIButton) {

        if isAIFlow {
               // Activities with rubrics can ONLY be mapped through their rubrics
               if let rubrics = self.rubrics, !rubrics.isEmpty {
                   if !isRubricsExpanded {
                       isRubricsExpanded = true
                       rubicsStack.isHidden = false
                       ArrowBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                       delegate?.didToggleRubricsExpansion(splitIndex: splitIndex, expanded: true)
                       onHeightChanged?()
                   }
                   return
               }
               showDropdown()
               return
           }

        // Activity has rubrics
        if var rubrics = self.rubrics, !rubrics.isEmpty {

            let shouldSelect = !(rubrics.allSatisfy { $0.isChecked == true })

            for index in rubrics.indices {
                rubrics[index].isChecked = shouldSelect
            }

            self.rubrics = rubrics

            CheckBoxBtnName.isSelected = shouldSelect
            updateCheckboxUI(isChecked: shouldSelect)

            delegate?.didToggleActivityWithRubrics(
                subjectIndex: subjectIndex,
                splitIndex: splitIndex,
                rubrics: rubrics,
                isChecked: shouldSelect
            )

            setupRubrics(rubrics)
            return
        }

        // No rubrics
        sender.isSelected.toggle()
        updateCheckboxUI(isChecked: sender.isSelected)

        delegate?.didToggleSplit(
            subjectIndex: subjectIndex,
            splitIndex: splitIndex,
            isChecked: sender.isSelected
        )
    }


    @IBAction func clearSelection() {

        // UI reset
            CheckBoxBtnName.isSelected = false
            updateCheckboxUI(isChecked: false)
            ActivitystatusLbl.isHidden = true
            clearBtn.isHidden = true

            // MODEL reset
            delegate?.didUpdateAISplit(
                subjectIndex: subjectIndex,
                splitIndex: splitIndex,
                isChecked: false,
                aiOption: nil
            )
    }


       func updateCheckboxUI(isChecked: Bool) {
           if isChecked {
               CheckBoxBtnName.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
               CheckBoxBtnName.tintColor = .staffExamColour
           } else {
               CheckBoxBtnName.setImage(UIImage(systemName: "circle"), for: .normal)
               CheckBoxBtnName.tintColor = .lightGray
           }
       }
    
    func setupDropdown() {
            dropdown.backgroundColor = .white
            dropdown.cornerRadius = 10

            // Automatically chooses up or down depending on available space
            dropdown.direction = .any
        
        }
    
    @IBAction func showDropdown(){
        
           dropdown.anchorView = activityNameLbl
           dropdown.dataSource = items ?? []
           dropdown.backgroundColor = .white
           dropdown.cornerRadius = 10
           dropdown.direction = .any
        
        dropdown.selectionAction = { [weak self] (_, item) in
            guard let self = self else { return }
            
            // UI
            self.CheckBoxBtnName.isSelected = true
            self.updateCheckboxUI(isChecked: true)
            self.ActivitystatusLbl.text = "Mapped to: \(item)"
            self.ActivitystatusLbl.isHidden = false
            self.clearBtn.isHidden = false
            
            // MODEL (single delegate call)
            self.delegate?.didUpdateAISplit(
                subjectIndex: self.subjectIndex,
                splitIndex: self.splitIndex,
                isChecked: true,
                aiOption: item
            )
            
           
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
            self.superview?.layoutIfNeeded()

        }
        
        dropdown.show()
    }
    
    
    @IBAction func ArrowBtnAct(_ sender: UIButton) {
        isRubricsExpanded.toggle()
        rubicsStack.isHidden = !isRubricsExpanded
        sender.setImage(UIImage(systemName: isRubricsExpanded ? "chevron.up" : "chevron.forward"), for: .normal)
        delegate?.didToggleRubricsExpansion(splitIndex: splitIndex, expanded: isRubricsExpanded) // new delegate method
        onHeightChanged?()
    }
    
    private func setupRubrics(_ rubrics: [RubricData]?) {

        // Remove old views (important because UITableViewCell is reused)
        rubicsStack.arrangedSubviews.forEach {
            rubicsStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        guard let rubrics = rubrics, !rubrics.isEmpty else {
            rubicsStack.isHidden = true
            return
        }

        rubicsStack.isHidden = false

        for (index, rubric) in rubrics.enumerated() {

            let row = UIView()

            // Checkbox
            let checkBox = UIButton(type: .custom)
            checkBox.tag = index
            checkBox.setImage(
                UIImage(
                    systemName: (isAIFlow
                                 ? rubric.selectedAIOption != nil
                                 : (rubric.isChecked ?? false))
                    ? "checkmark.circle.fill"
                    : "circle"
                ),
                for: .normal
            )
            checkBox.tintColor = (isAIFlow
                                  ? rubric.selectedAIOption != nil
                                  : (rubric.isChecked ?? false))
            ? .staffExamColour : .lightGray

            checkBox.widthAnchor.constraint(equalToConstant: 24).isActive = true
            checkBox.heightAnchor.constraint(equalToConstant: 24).isActive = true
            checkBox.addTarget(self, action: #selector(rubricCheckboxTapped(_:)), for: .touchUpInside)

            // Rubric Name
            let nameLabel = UILabel()
            nameLabel.numberOfLines = 0
            nameLabel.font = UIFont.systemFont(ofSize: 13)
            nameLabel.text = "\(rubric.rubric_name ?? "") (Max: \(rubric.max_mark ?? ""))"

            // Vertical stack for labels
            let textStack = UIStackView(arrangedSubviews: [nameLabel])
            textStack.axis = .vertical
            textStack.spacing = 2

            var clearButton: UIButton?

            if isAIFlow, let option = rubric.selectedAIOption {

                let statusLabel = UILabel()
                statusLabel.numberOfLines = 1
                statusLabel.font = UIFont.systemFont(ofSize: 11)

                let prefix = "Mapped to: "
                let fullText = prefix + option

                let attr = NSMutableAttributedString(string: fullText)
                attr.addAttributes(
                    [.foregroundColor: UIColor.darkGray],
                    range: NSRange(location: 0, length: prefix.count)
                )
                attr.addAttributes(
                    [.foregroundColor: UIColor.staffExamColour],
                    range: NSRange(location: prefix.count, length: option.count)
                )

                statusLabel.attributedText = attr
                textStack.addArrangedSubview(statusLabel)

                let clear = UIButton(type: .custom)
                clear.tag = index
                clear.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
                clear.tintColor = .lightGray
                clear.widthAnchor.constraint(equalToConstant: 20).isActive = true
                clear.heightAnchor.constraint(equalToConstant: 20).isActive = true
                clear.addTarget(self, action: #selector(rubricClearTapped(_:)), for: .touchUpInside)

                clearButton = clear
            }

            // Horizontal stack
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.alignment = .center
            hStack.spacing = 10
            hStack.translatesAutoresizingMaskIntoConstraints = false

            hStack.addArrangedSubview(checkBox)
            hStack.addArrangedSubview(textStack)

            // Let text take available width
            textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
            textStack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            checkBox.setContentHuggingPriority(.required, for: .horizontal)
            checkBox.setContentCompressionResistancePriority(.required, for: .horizontal)

            if let clearButton = clearButton {
                clearButton.setContentHuggingPriority(.required, for: .horizontal)
                clearButton.setContentCompressionResistancePriority(.required, for: .horizontal)
                hStack.addArrangedSubview(clearButton)
            }

            row.addSubview(hStack)

            NSLayoutConstraint.activate([
                hStack.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                hStack.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                hStack.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
                hStack.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8)
            ])

            rubicsStack.addArrangedSubview(row)
        }
    }
    
    @objc private func rubricCheckboxTapped(_ sender: UIButton) {
        guard let rubrics = rubrics, sender.tag < rubrics.count else { return }

        if isAIFlow {
            showRubricDropdown(rubricIndex: sender.tag, anchorView: sender)
            return
        }

        // existing non-AI plain-toggle behavior
        var updatedRubrics = rubrics
        let current = updatedRubrics[sender.tag].isChecked ?? false
        let checked = !current
        updatedRubrics[sender.tag].isChecked = checked
        self.rubrics = updatedRubrics

        let allRubricsSelected = updatedRubrics.allSatisfy { $0.isChecked == true }
        CheckBoxBtnName.isSelected = allRubricsSelected
        updateCheckboxUI(isChecked: allRubricsSelected)
        contentView.backgroundColor = allRubricsSelected
            ? UIColor.systemOrange.withAlphaComponent(0.07)
            : .systemBackground

        delegate?.didToggleRubric(
            subjectIndex: subjectIndex,
            splitIndex: splitIndex,
            rubricIndex: sender.tag,
            isChecked: checked
        )

        setupRubrics(updatedRubrics)
    }

    @objc private func rubricClearTapped(_ sender: UIButton) {
        guard var rubrics = rubrics, sender.tag < rubrics.count else { return }
        rubrics[sender.tag].selectedAIOption = nil
        rubrics[sender.tag].isChecked = false
        self.rubrics = rubrics

        delegate?.didUpdateAIRubric(
            subjectIndex: subjectIndex,
            splitIndex: splitIndex,
            rubricIndex: sender.tag,
            isChecked: false,
            aiOption: nil
        )

        setupRubrics(rubrics)
        onHeightChanged?()
    }

    private func showRubricDropdown(rubricIndex: Int, anchorView: UIView) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }

        let frame = anchorView.convert(anchorView.bounds, to: window)
        let screenHeight = UIScreen.main.bounds.height

        let rubricDropdown = DropDown()
        rubricDropdown.anchorView = anchorView
        rubricDropdown.dataSource = items ?? []
        rubricDropdown.backgroundColor = .white
        rubricDropdown.cornerRadius = 10
        rubricDropdown.direction = (frame.maxY > screenHeight * 0.7) ? .top : .bottom

        rubricDropdown.selectionAction = { [weak self] (_, item) in
            guard let self = self else { return }

            self.delegate?.didUpdateAIRubric(
                subjectIndex: self.subjectIndex,
                splitIndex: self.splitIndex,
                rubricIndex: rubricIndex,
                isChecked: true,
                aiOption: item
            )

            if var rubrics = self.rubrics, rubricIndex < rubrics.count {
                rubrics[rubricIndex].selectedAIOption = item
                rubrics[rubricIndex].isChecked = true
                self.rubrics = rubrics
                self.setupRubrics(rubrics)
            }

            self.onHeightChanged?()
        }

        rubricDropdown.show()
    }
}
