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

        HelppageHeader.text = "Contact Support".translated()
        HelppageHeader.setFont(style: .header, size: FontSize.HeaderSize)
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
