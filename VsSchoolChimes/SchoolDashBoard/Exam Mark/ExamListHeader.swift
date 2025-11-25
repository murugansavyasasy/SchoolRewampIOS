//
//  ExamListHeader.swift
//  School Chimes
//
//  Created by Lakshmanan on 24/11/25.
//

import UIKit

class ExamListHeader: UITableViewHeaderFooterView {

    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var SideColourView : UIView!

       var onTap: (() -> Void)?

       @IBAction func expandButtonTapped(_ sender: UIButton) {
           onTap?()
       }

}
