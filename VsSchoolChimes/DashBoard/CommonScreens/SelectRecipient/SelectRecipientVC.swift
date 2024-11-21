//
//  SelectRecipientVC.swift
//  VsSchoolChimes
//
//  Created by Admin on 20/11/24.
//

import UIKit
import DropDown

class SelectRecipientVC: UIViewController {

    @IBOutlet weak var Headerview: UIView!
    
    @IBOutlet weak var SelectSchool: UIView!
    
    @IBOutlet weak var stdorgrp: UIView!
    
    @IBOutlet weak var sendAllview: UIView!
    
    @IBOutlet weak var StdorSec: UIView!
    
    @IBOutlet weak var tableview: UITableView!
    
    @IBOutlet weak var SendButton: UIButton!
    
    @IBOutlet weak var SelectSchoolLabel: UILabel!
    
    var flag = 0
    
    var Group: [Section] = [
           Section(title: "Standard", items: ["LKG", "UKG", "1st Standard", "2nd Standard", "3rd Standard", "4th Standard", "5th Standard"]),
           Section(title: "Group", items: ["Teachers group", "Students group"])
       ]
    
    var sections: [Section] = [
           Section(title: "Standard", items: ["A section", "B section", "C section", "D section", "E section"])
       ]
    
    let dropDown = DropDown()
    let StdDropdown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SendButton.layer.cornerRadius = 10
        SendButton.isHidden = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(Selectschool))
        SelectSchool.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(selectStdGrp))
        stdorgrp.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(selectStdSec))
        StdorSec.addGestureRecognizer(tap3)
        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(SendEntireSchool))
        sendAllview.addGestureRecognizer(tap4)
        
        let nib = UINib(nibName: "RecipientTvCell", bundle: nil)
        tableview.register(nib, forCellReuseIdentifier:"RecipientTvCell")
        

        tableview.register(UINib(nibName:"Std_Grp_header", bundle: nil), forHeaderFooterViewReuseIdentifier: "Std_Grp_header")

      
        setupDropDown()
        setupStdDropdown()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func Selectschool(){
        
        dropDown.show()
    }
    
    @IBAction func selectStdGrp(){
        
        flag = 1
        SelectSchool.isHidden = true
        sendAllview.isHidden = true
        StdorSec.isHidden = true
        SendButton.isHidden = false
       tableview.isHidden = false
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    
    @IBAction func selectStdSec(){
        
        StdDropdown.show()
        flag = 2
        SelectSchool.isHidden = true
        sendAllview.isHidden = true
        StdorSec.isHidden = true
        SendButton.isHidden = false
        tableview.isHidden = false
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    
    @IBAction func SendEntireSchool() {
        
        let alertController = UIAlertController(
                   title: "Are you sure?",
                   message: "Do you want to continue or cancel?",
                   preferredStyle: .alert
               )

               // Add Cancel action
               let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                   print("User chose to cancel")
               }

               // Add Continue action
               let continueAction = UIAlertAction(title: "Submit", style: .default) { _ in
                   print("User chose to continue")
               }

               // Add actions to the alert controller
               alertController.addAction(cancelAction)
               alertController.addAction(continueAction)

               // Present the alert
               present(alertController, animated: true, completion: nil)
    }
    
    func setupDropDown() {
        dropDown.anchorView = SelectSchool
           dropDown.dataSource = ["Siga Hr Sec School", "Govt Hr Sec School", "Vidhyalaya metric school"]
           dropDown.bottomOffset = CGPoint(x: 0, y: SelectSchool.bounds.height)
           
           dropDown.selectionAction = { [weak self] (index: Int, item: String) in
               print("Selected item: \(item) at index: \(index)")
               
               // Update the label inside the UIView
               if let label = self?.SelectSchool.subviews.first(where: { $0 is UILabel }) as? UILabel {
                   label.text = item
               }
               
              // self!.SelectSchool.isHidden = true
               self!.stdorgrp.isHidden = false
               self!.StdorSec.isHidden = false
               self!.sendAllview.isHidden = false
                   
           }
       }
    
    func setupStdDropdown (){
        dropDown.anchorView = SelectSchool
           dropDown.dataSource = ["LKG", "UKG", "1st Standard", "2nd Standard", "3rd Standard", "4th Standard", "5th Standard"]
           dropDown.bottomOffset = CGPoint(x: 0, y: SelectSchool.bounds.height)
           
           dropDown.selectionAction = { [weak self] (index: Int, item: String) in
               print("Selected item: \(item) at index: \(index)")
               
               // Update the label inside the UIView
               if let label = self?.SelectSchool.subviews.first(where: { $0 is UILabel }) as? UILabel {
                   label.text = item
               }
               
              // self!.SelectSchool.isHidden = true
//               self!.stdorgrp.isHidden = false
//               self!.StdorSec.isHidden = false
//               self!.sendAllview.isHidden = false
                   
           }
    }
    
    

    @IBAction func BackClk(_ sender: Any) {
       
      
        
        if SelectSchoolLabel.text == "Select your school" {
            
            dismiss(animated: true)
        }
        else {
            stdorgrp.isHidden = true
            StdorSec.isHidden  = true
            sendAllview.isHidden = true
            tableview.isHidden = true
            SelectSchoolLabel.text = "Select your school"
            SelectSchool.isHidden = false
        }
    }
    

}


extension SelectRecipientVC : UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Std_Grp_header") as! Std_Grp_header
        
        if flag == 1 {
            head.HeaderLabel.text = Group[section].title
        }
        else{
            head.HeaderLabel.text = sections[section].title
        }
        return head
    }
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipientTvCell") as! RecipientTvCell
        if flag == 1{
            cell.cellLabel.text = Group[indexPath.section].items[indexPath.row]
        }
        else{
            cell.cellLabel.text = sections[indexPath.section].items[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! RecipientTvCell
        
        cell.checkboxImg.image = UIImage(named: "checkedSquare")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RecipientTvCell
        
        cell.checkboxImg.image = UIImage(named: "uncheckedSquare")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
