//
//  ActivitiesTVCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 26/11/25.
//

import UIKit
protocol ActivityCellDelegate: AnyObject {
    func didToggleSplit(subjectIndex: Int, splitIndex: Int, isChecked: Bool)
    func didUpdateAISplit(subjectIndex: Int, splitIndex: Int, isChecked: Bool, aiOption: String?)
}

class ActivitiesTVCell: UITableViewCell {

    @IBOutlet weak var CheckBoxBtnName: UIButton!
    @IBOutlet weak var activityNameLbl: UILabel!
    @IBOutlet weak var dropdownView: UIView!
    @IBOutlet weak var dropdownLbl: UILabel!
    @IBOutlet weak var ActivityStatusView: UIView!
    @IBOutlet weak var ActivitystatusLbl: UILabel!
    @IBOutlet weak var clearBtn: UIButton!
    
    let dropdown = DropDown()
    weak var delegate: ActivityCellDelegate?
    private var subjectIndex = 0
    private var splitIndex = 0
    private var isAIFlow = false
    
    var items:[String]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        dropdownView.layer.cornerRadius = 10
        dropdownView.layer.borderWidth = 0.5
        dropdownView.layer.borderColor = UIColor.lightGray.cgColor
        
        ActivityStatusView.layer.cornerRadius = 10
        ActivityStatusView.layer.borderWidth = 0.5
        ActivityStatusView.layer.borderColor = UIColor.lightGray.cgColor
        
        ActivityStatusView.isHidden = true
        ActivitystatusLbl.isHidden = true
        dropdownView.isHidden = true
        dropdownView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDropdown)))
        
        setupDropdown()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(
        subjectIndex: Int,
        splitIndex: Int,
        split: SplitDetail,
        isAi: Bool,items: [String]
    ) {
        self.subjectIndex = subjectIndex
        self.splitIndex = splitIndex
        self.isAIFlow = isAi
        dropdown.dataSource = items
        let nameText = split.name ?? ""
        let maxText = " (Max: \(split.max_mark ?? "") marks)"
        print(items)
        let fullText = nameText + maxText
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttributes([.foregroundColor: UIColor.black,.font: UIFont(name: "Poppins-Medium", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .semibold)], range: NSRange(location: 0, length: nameText.count))
        
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
    }

    
    @IBAction func CheckBoxBtnAct(_ sender: UIButton) {

        if isAIFlow {
            showDropdown()
            return
        }

        // MANUAL FLOW
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
            dropdownView.isHidden = true
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
               CheckBoxBtnName.setImage(UIImage(systemName: "record.circle.fill"), for: .normal)
               CheckBoxBtnName.tintColor = .staffExamColour
           } else {
               CheckBoxBtnName.setImage(UIImage(systemName: "circle"), for: .normal)
               CheckBoxBtnName.tintColor = .lightGray
           }
       }
    
    func setupDropdown() {
            dropdown.anchorView = dropdownView
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
        let frame = dropdownView.convert(dropdownView.bounds, to: window)
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
}
