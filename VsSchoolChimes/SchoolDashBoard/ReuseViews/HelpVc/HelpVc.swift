//
//  HelpVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class HelpVc: UIViewController {

    @IBOutlet weak var HelppageHeader: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        HelppageHeader.text = CommonStringFile.ContactSupport
        HelppageHeader.setFont(style: .header, size: FontSize.HeaderSize)
        // Do any additional setup after loading the view.
    }

}
