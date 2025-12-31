//
//  ActivitiesTVCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 26/11/25.
//

import UIKit
protocol ActivityCellDelegate: AnyObject {
    func didToggleSplit(subjectIndex: Int, splitIndex: Int, isChecked: Bool)
    func didSelectAIOption(subjectIndex: Int, splitIndex: Int, option: String)
}

class ActivitiesTVCell: UITableViewCell {

    @IBOutlet weak var CheckBoxBtnName: UIButton!
    @IBOutlet weak var activityNameLbl: UILabel!
    @IBOutlet weak var dropdownView: UIView!
    @IBOutlet weak var dropdownLbl: UILabel!
    @IBOutlet weak var ActivityStatusView: UIView!
    @IBOutlet weak var ActivitystatusLbl: UILabel!
    
    let dropdown = DropDown()
    weak var delegate: ActivityCellDelegate?
    private var subjectIndex = 0
    private var splitIndex = 0
    let isAi = false
    
    let items: [String] = [
        "HEADER_ACTIONS",
        "🚫 Ignore (Skip this activity)",
        "✏️ Enter marks manually",
        "SEPARATOR",
        "HEADER_COLUMNS",
        "Student_Name",
        "Roll_No",
        "Algebra",
        "Geometry"
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        dropdownView.layer.cornerRadius = 10
        dropdownView.layer.borderWidth = 0.5
        dropdownView.layer.borderColor = UIColor.lightGray.cgColor
        
        ActivityStatusView.layer.cornerRadius = 10
        ActivityStatusView.layer.borderWidth = 0.5
        ActivityStatusView.layer.borderColor = UIColor.lightGray.cgColor
        
        ActivityStatusView.isHidden = true
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
            isAi: Bool
        ) {
            self.subjectIndex = subjectIndex
            self.splitIndex = splitIndex

            activityNameLbl.text = split.name
            CheckBoxBtnName.isSelected = split.isChecked ?? false

            dropdownView.isHidden = !(isAi && split.isChecked ?? false)
            dropdownLbl.text = split.selectedAIOption
        }
    
    @IBAction func CheckBoxBtnAct(_ sender: UIButton) {
        sender.isSelected.toggle()
        updateCheckboxUI(isChecked: sender.isSelected)
        dropdownView.isHidden = !(isAi && sender.isSelected)
        delegate?.didToggleSplit(subjectIndex: subjectIndex, splitIndex: splitIndex, isChecked: sender.isSelected)
        if let parentTable = self.superview as? UITableView {
                               parentTable.beginUpdates()
                               parentTable.endUpdates()
                           }
       }

       func updateCheckboxUI(isChecked: Bool) {
           if isChecked {
               CheckBoxBtnName.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
               CheckBoxBtnName.tintColor = .systemBlue
           } else {
               CheckBoxBtnName.setImage(UIImage(systemName: "square"), for: .normal)
               CheckBoxBtnName.tintColor = .lightGray
           }
       }
    
    func setupDropdown() {
            dropdown.anchorView = dropdownView
            
            dropdown.dataSource = items
            
            dropdown.backgroundColor = .white
            dropdown.cornerRadius = 10

            // Automatically chooses up or down depending on available space
            dropdown.direction = .any
        
        dropdown.customCellConfiguration = { [weak self] index, item, cell in
            
            // Clear default styling
            cell.separatorInset = UIEdgeInsets(top: 0, left: 5000, bottom: 0, right: 0)

            // ===== HEADER: ACTIONS =====
            if item == "HEADER_ACTIONS" {
                cell.optionLabel.text = "ACTIONS"
                cell.optionLabel.font = UIFont.boldSystemFont(ofSize: 14)
                cell.optionLabel.textColor = .systemGray
                cell.isUserInteractionEnabled = false

                // Extra top padding for header
                cell.layoutMargins.top = 8
                cell.layoutMargins.bottom = 4
                return
            }
            
            // ===== HEADER: Columns =====
            if item == "HEADER_COLUMNS" {
                cell.optionLabel.text = "📄 Columns from uploaded image"
                cell.optionLabel.font = UIFont.boldSystemFont(ofSize: 14)
                cell.optionLabel.textColor = .staffExamColour
                cell.isUserInteractionEnabled = false
                
                cell.layoutMargins.top = 4
                cell.layoutMargins.bottom = 4
                return
            }
            
            // ===== SECTION SEPARATOR =====
            if item == "SEPARATOR" {
                cell.optionLabel.text = ""   // hide text
                cell.isUserInteractionEnabled = false
                
                // Draw a custom separator
                let line = UIView(frame: CGRect(x: 16, y: 4, width: cell.frame.width - 32, height: 1))
                line.backgroundColor = UIColor.systemGray4
                cell.addSubview(line)
                
                return
            }

            // ===== NORMAL SELECTABLE ITEMS =====
            cell.optionLabel.text = item
            cell.optionLabel.font = UIFont.systemFont(ofSize: 14)
            cell.optionLabel.textColor = .label
            cell.isUserInteractionEnabled = true
        }

        
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

                // Handle selection
                dropdown.selectionAction = { [weak self] (index, item) in
                    guard let self = self else { return }

                    self.dropdownLbl.text = item
                    self.ActivityStatusView.isHidden = false
                    if let parentTable = self.superview as? UITableView {
                        parentTable.beginUpdates()
                        parentTable.endUpdates()
                    }
                }

                dropdown.show()
    }
}
