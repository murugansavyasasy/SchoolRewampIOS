//
//  SendMsgTvCell.swift
//  School Chimes
//
//  Created by apple on 29/12/25.
//

import UIKit

protocol selectedTextMsg : AnyObject {
    func sendTextMsg(title:String,content:String)
}
class SendMsgTvCell: UITableViewCell,UITextFieldDelegate,UITextViewDelegate {

    @IBOutlet weak var nextBtnName: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var descriptionTxtView: UITextView!
    @IBOutlet weak var titleTextFiled: UITextField!
    @IBOutlet weak var titleDefaultLbl: UILabel!
    weak var delegate:selectedTextMsg?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleTextFiled.delegate = self
        descriptionTxtView.delegate = self
        titleTextFiled.addDoneButton()
        descriptionTxtView.addDoneButton()
    }

    @IBAction func nextBtnAct(_ sender: UIButton) {
        delegate?.sendTextMsg(title: titleTextFiled.text ?? "", content: descriptionTxtView.text)
    }
}
