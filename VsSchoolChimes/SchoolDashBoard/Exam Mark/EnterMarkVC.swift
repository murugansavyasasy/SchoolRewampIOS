//
//  EnterMarkVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 01/12/25.
//

import UIKit

class EnterMarkVC: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var reviewMarksLbl: UILabel!
    @IBOutlet weak var verifyLbl: UILabel!
    @IBOutlet weak var saveMarksBtn: UIButton!
    @IBOutlet weak var saveMarksBtn2: UIButton!
    @IBOutlet weak var topBaseView: UIView!
    @IBOutlet weak var bottomBaseview: UIView!
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveMarksBtn.layer.cornerRadius = 10
        saveMarksBtn2.layer.cornerRadius = 10
        
    }

    
    @IBAction func saveBtnAct(_ sender: Any) {
    }
    
    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
}
