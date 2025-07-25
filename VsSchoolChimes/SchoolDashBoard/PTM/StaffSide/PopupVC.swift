//
//  PopupVC.swift
//  VsSchoolChimes
//
//  Created by admin on 26/02/25.
//

import UIKit

class PopupVC: UIViewController {
    var selectedIndex:Int?
    @IBOutlet weak var editStack: UIStackView!
    @IBOutlet weak var deleteStack: UIStackView!
    @IBOutlet weak var cancelStack: UIStackView!
    @IBOutlet weak var reopenStack: UIStackView!
    var ptm:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        editStack.isHidden = ptm
        deleteStack.isHidden = ptm
        cancelStack.isHidden = !ptm
        reopenStack.isHidden = !ptm
    }
    
}
