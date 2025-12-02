//
//  ActivitiesTVCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 26/11/25.
//

import UIKit

class ActivitiesTVCell: UITableViewCell {

    @IBOutlet weak var activityNameLbl: UILabel!
    @IBOutlet weak var dropdownView: UIView!
    @IBOutlet weak var dropdownLbl: UILabel!
    @IBOutlet weak var ActivityStatusView: UIView!
    @IBOutlet weak var ActivitystatusLbl: UILabel!
    
    let dropdown = DropDown()
    
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
        
        dropdownView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDropdown)))
        
        setupDropdown()
    }
    
    func confugure(value:Int){
        
        switch value{
            
        case 0:
            ActivityStatusView.isHidden = true
            
        case 1:
            ActivityStatusView.isHidden = false
            ActivityStatusView.backgroundColor = .staffExamColour.withAlphaComponent(0.06)
            
        case 2:
            ActivityStatusView.isHidden = false
            ActivityStatusView.backgroundColor = .systemBlue.withAlphaComponent(0.06)
            
        default:
            ActivityStatusView.isHidden = true
            
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

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
