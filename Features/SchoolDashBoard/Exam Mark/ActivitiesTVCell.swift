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
       
        ActivitystatusLbl.isHidden = true
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
        let nameText = split.activity_name ?? ""
        let maxText = " (Max: \(split.max_mark ?? "") marks)"
        print(items)
        let fullText = nameText + maxText
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttributes([.foregroundColor: UIColor.black,.font: UIFont(name: "Poppins-Medium", size: 15) ?? UIFont.systemFont(ofSize: 20, weight: .semibold)], range: NSRange(location: 0, length: nameText.count))
        
        attributedString.addAttributes([.foregroundColor: UIColor.darkGray, .font : UIFont(name: "Poppins-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12)], range: NSRange(location: nameText.count, length: maxText.count))
        
        activityNameLbl.attributedText = attributedString
        
        //activityNameLbl.text = (split.name ?? "") + " (Max: " + (split.max_mark ?? "") + ")"

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
        
          ArrowBtn.setImage(UIImage(systemName: isRubricsExpanded ? "chevron.up" : "chevron.forward"), for: .normal)
    }

    
    @IBAction func CheckBoxBtnAct(_ sender: UIButton) {

        if isAIFlow {
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
        
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }
        
        // Convert dropdownView frame to window coords
        let frame = activityNameLbl.convert(activityNameLbl.bounds, to: window)
        let screenHeight = UIScreen.main.bounds.height
        
        // Set direction manually
        dropdown.direction = (frame.maxY > screenHeight * 0.7) ? .top : .bottom
        
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

            let checkBox = UIButton(type: .custom)
            checkBox.backgroundColor = .clear
            checkBox.tag = index
            checkBox.translatesAutoresizingMaskIntoConstraints = false

            let image = rubric.isChecked ?? false
                ? UIImage(systemName: "checkmark.circle.fill")
                : UIImage(systemName: "circle")

            checkBox.setImage(image, for: .normal)
            checkBox.tintColor = rubric.isChecked ?? false ? .staffExamColour : .lightGray

            checkBox.addTarget(self,
                               action: #selector(rubricCheckboxTapped(_:)),
                               for: .touchUpInside)

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 13)

            label.text = "\(rubric.rubric_name ?? "") (Max: \(rubric.max_mark ?? ""))"

            row.addSubview(checkBox)
            row.addSubview(label)

            NSLayoutConstraint.activate([
                checkBox.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                checkBox.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                checkBox.widthAnchor.constraint(equalToConstant: 24),
                checkBox.heightAnchor.constraint(equalToConstant: 24),

                label.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: row.trailingAnchor),
                label.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8)
            ])

            rubicsStack.addArrangedSubview(row)
        }
    }
    
    @objc private func rubricCheckboxTapped(_ sender: UIButton) {

        guard var rubrics = rubrics else { return }

        // Treat nil as false, then explicitly flip — avoids the no-op optional .toggle() trap
        let current = rubrics[sender.tag].isChecked ?? false
        let checked = !current
        rubrics[sender.tag].isChecked = checked

        sender.setImage(
            UIImage(systemName: checked ? "checkmark.circle.fill" : "circle"),
            for: .normal
        )
        sender.tintColor = checked ? .staffExamColour : .lightGray

        self.rubrics = rubrics

        let allRubricsSelected = rubrics.allSatisfy { $0.isChecked == true }

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
    }
}
