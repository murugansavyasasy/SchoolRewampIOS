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
           Section(title: "Section", items: ["A section", "B section", "C section", "D section", "E section"])
       ]
    
    let dropDown = DropDown()
    let StdDropdown = DropDown()
    let Img = ImageName()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stdorgrp.isHidden = true
        StdorSec.isHidden = true
        sendAllview.isHidden = true
        tableview.isHidden = true
        
        SendButton.layer.cornerRadius = Colornames.CORadius10
        SendButton.isHidden = true

        dropDowViewSetup()
//        SelectSchool.layer.transform = UIColor.blue.cgColor as! CATransform3D
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Selectschool))
        SelectSchool.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(selectStdGrp))
        stdorgrp.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(selectStdSec))
        StdorSec.addGestureRecognizer(tap3)
        
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(SendEntireSchool))
        sendAllview.addGestureRecognizer(tap4)
        
        let nib = UINib(nibName: CellConfingName.RecipientTvCell, bundle: nil)
        tableview.register(nib, forCellReuseIdentifier:CellConfingName.RecipientTvCell)
        

        tableview.register(UINib(nibName:"Std_Grp_header", bundle: nil), forHeaderFooterViewReuseIdentifier: "Std_Grp_header")

      
        
//        setupStdDropdown()
        // Do any additional setup after loading the view.
    }
    
    
    
    func dropDowViewSetup(){
        
        
        SelectSchool.layer.cornerRadius = Colornames.CORadius10
        StdorSec.layer.cornerRadius = Colornames.CORadius10
        stdorgrp.layer.cornerRadius = Colornames.CORadius10
        sendAllview.layer.cornerRadius = Colornames.CORadius10
       
        
        SelectSchool.layer.shadowColor = UIColor.black.cgColor
        SelectSchool.layer.shadowOpacity = 0.5
        SelectSchool.layer.shadowOffset = CGSize(width: 4, height: 4)
        SelectSchool.layer.shadowRadius = 3
        
        StdorSec.layer.shadowColor = UIColor.black.cgColor
        StdorSec.layer.shadowOpacity = 0.5
        StdorSec.layer.shadowOffset = CGSize(width: 4, height: 4)
        StdorSec.layer.shadowRadius = 3
        
        stdorgrp.layer.shadowColor = UIColor.black.cgColor
        stdorgrp.layer.shadowOpacity = 0.5
        stdorgrp.layer.shadowOffset = CGSize(width: 4, height: 4)
        stdorgrp.layer.shadowRadius = 3
        
        sendAllview.layer.shadowColor = UIColor.black.cgColor
        sendAllview.layer.shadowOpacity = 0.5
        sendAllview.layer.shadowOffset = CGSize(width: 4, height: 4)
        sendAllview.layer.shadowRadius = 3
    }
    
    @IBAction func Selectschool(){
        
       
        setupDropDown()
    }
    
    @IBAction func selectStdGrp(){
        
        flag = 1
        SelectSchool.isHidden = true
        sendAllview.isHidden = true
        StdorSec.isHidden = true
        SendButton.isHidden = false
        
        
        if tableview.isHidden == true{
            tableview.isHidden = false
            tableview.delegate = self
            tableview.dataSource = self
            tableview.reloadData()
            
        }
        
       
    }
    
    @IBAction func selectStdSec(){
        
      
        flag = 2
        SelectSchool.isHidden = true
        sendAllview.isHidden = true
        stdorgrp.isHidden = true
        SendButton.isHidden = false
        tableview.isHidden = true
        
        setupStdDropdown ()
        
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
        dropDown.show()
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
        
        StdDropdown.anchorView = SelectSchool
       
        StdDropdown.dataSource = ["LKG", "UKG", "1st Standard", "2nd Standard", "3rd Standard", "4th Standard", "5th Standard"]
        StdDropdown.bottomOffset = CGPoint(x: 0, y: StdorSec.bounds.height)
        StdDropdown.show()
//        DropDown.Direction = .bottom
        StdDropdown.selectionAction = { [weak self] (index: Int, item: String) in
               print("Selected item: \(item) at index: \(index)")
               
               // Update the label inside the UIView
            if let label = self?.StdorSec.subviews.first(where: { $0 is UILabel }) as? UILabel {
                   label.text = item
               }
               
           
            self!.tableview.isHidden = false
           }
        tableview.delegate = self
        tableview.dataSource = self
        tableview.reloadData()
    }
    
    

    @IBAction func BackClk(_ sender: Any) {
       
       // dismiss(animated: true)

        print("ok",SelectSchoolLabel.text)
        if SelectSchoolLabel.text == "Select your school" {
            
            dismiss(animated: true)
        }
        else {
            
            print("ghegwheghjwj")
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
        if flag == 1 {
            return    Group.count
        }
        else if flag == 2{
            return  sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Std_Grp_header") as! Std_Grp_header
        
        if flag == 1 {
            head.HeaderLabel.text = Group[section].title
        }
        else if flag == 2{
            head.HeaderLabel.text = sections[section].title
        }
        return head
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if flag == 1 {
            return Group[section].items.count
        }
        else if flag == 2{
            return sections[section].items.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.RecipientTvCell , for: indexPath) as! RecipientTvCell
        
        
        
        if flag == 1{
            cell.checkboxImg.isUserInteractionEnabled = true
            cell.cellLabel.text = Group[indexPath.section].items[indexPath.row]
            let checkClick = checkClick(target: self, action: #selector(CheckBoxclick))
            checkClick.index = indexPath.row
            checkClick.indexs = indexPath
            cell.checkboxImg.addGestureRecognizer(checkClick)
            
        }
        else{
            cell.cellLabel.text = sections[indexPath.section].items[indexPath.row]
        }
        return cell
    }
    
    
    @IBAction func CheckBoxclick(ges : checkClick){
        
        let cell = tableview.dequeueReusableCell(withIdentifier: CellConfingName.RecipientTvCell , for: ges.indexs) as! RecipientTvCell
        
        cell.checkboxImg.image = Img.checkedsquare
    }
    
 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}


class  checkClick : UITapGestureRecognizer{
    
    
    var index : Int!
    var click : Bool!
    var indexs : IndexPath!
}
