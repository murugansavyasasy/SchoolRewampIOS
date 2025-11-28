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
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

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
    
    func setupDropdown() {
            dropdown.anchorView = dropdownView
            
            dropdown.dataSource = [
                "Pending",
                "In Progress",
                "Completed"
            ]
            
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
