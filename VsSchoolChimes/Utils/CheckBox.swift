//
//  CheckBox.swift
//  VsSchoolChimes
//
//  Created by admin on 12/06/24.
//

import Foundation



import UIKit



class CheckBox: UIButton {

    // Images

    let checkedImage = UIImage(named: "checked_Tick")!

    let uncheckedImage = UIImage(named: "CheckCircle")!

    

    // Bool property

    var isChecked: Bool = false {

        didSet {

            if isChecked == true {

                self.setImage(checkedImage, for: UIControl.State.normal)


            } else {

                self.setImage(uncheckedImage, for: UIControl.State.normal)


            }

        }

    }

        

    override func awakeFromNib() {

        self.addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)

        self.isChecked = false

    }

        

    @objc func buttonClicked(sender: UIButton) {

        if sender == self {

            isChecked = !isChecked

        }

    }

}

