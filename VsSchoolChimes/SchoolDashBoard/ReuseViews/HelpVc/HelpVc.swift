//
//  HelpVc.swift
//  VsSchoolChimes
//
//  Created by admin on 26/10/24.
//

import UIKit

class HelpVc: UIViewController {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var HelppageHeader: UILabel!
    var passVale = 1
    override func viewDidLoad() {
        super.viewDidLoad()
       
        HelppageHeader.text = MenuTapbar.Help.translated()
        HelppageHeader.setFont(style: .header, size: FontSize.HeaderSize)
    }
    override func viewDidLayoutSubviews() {
        if passVale == 2{
            outerView.applyGradient(
                colors: [Colornames.gradientBlue, Colornames.gradientgreen],
                startPoint: CGPoint(x: 1, y: 0.5),
                endPoint: CGPoint(x: 0, y: 0.5)
            )
        }else{
            outerView.applyGradient(
                colors: [                    Colornames.stafGradient, Colornames.stafGradient1],
                startPoint: CGPoint(x: 1, y: 0.5),
                endPoint: CGPoint(x: 0, y: 0.5)
            )
        }
    }

}
