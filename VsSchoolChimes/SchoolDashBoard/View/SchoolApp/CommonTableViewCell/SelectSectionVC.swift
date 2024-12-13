//
//  SelectSectionVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 25/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class SelectSectionVC: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var ConfirmButton: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    
    var expandedSections : NSMutableSet = []
    var selectedSectionArray:Array = [String]()
    var selectedGroupArray:Array = [String]()
    var selectedSectionCodeArray:Array = [String]()
    var selectedGroupCodeArray:Array = [String]()
    var SchoolDetailArrayData:Array = [Any]()
    var SectionTitle:Array = [String]()
    var sectionGroupData : [String] = ["Select Classes", "Select Group"]
    var SectionTitleData = ["Select Classes"]
    var GroupTitleData = ["Select Group"]
    var SectionArrayData:Array = [String]()
    var GroupArrayData:Array = [String]()
    var SectionCodeArrayData:Array = [String]()
    var GroupCodeArrayData:Array = [String]()
    var SectionGroupDetailDic:NSDictionary = [String:Any]() as NSDictionary
    var tappedString = String()
    var SegueSelectedSectionArray = [String]()
    var SegueSelectedGroupArray = [String]()
    var SegueSelectedSectionCodeArray = [String]()
    var SegueSelectedGroupCodeArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfirmButton.isUserInteractionEnabled = false
        self.myTableView.allowsMultipleSelection = true
        for i in 0..<SchoolDetailArrayData.count{
            SectionGroupDetailDic = SchoolDetailArrayData[i] as! NSDictionary
        }
        
        let Groupcode = SectionGroupDetailDic["GrpCode"] as! NSArray
        let SecCode = SectionGroupDetailDic["StdCode"] as! NSArray
        
        for i in 0..<Groupcode.count{
            let mygroupdic:NSDictionary = Groupcode.object(at: i) as! NSDictionary
            let mystring = mygroupdic["GroupName"] as! String
            let groupid = mygroupdic["GroupCode"] as! String
            GroupArrayData.append(mystring)
            GroupCodeArrayData.append(groupid)
        }
        for i in 0..<SecCode.count{
            let mygroupdic:NSDictionary = SecCode.object(at: i) as! NSDictionary
            let mystring = mygroupdic["Stdname"] as! String
            let mystdid = mygroupdic["StdId"] as! String
            SectionArrayData.append(mystring)
            SectionCodeArrayData.append(mystdid)
            
        }
        
        if(Groupcode.count > 0 && SecCode.count > 0){
            SectionTitle = sectionGroupData
        }else if(SecCode.count > 0){
            SectionTitle = SectionTitleData
        }else if(Groupcode.count > 0){
            SectionTitle = GroupTitleData
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        ConfirmButton.layer.cornerRadius = 5
        ConfirmButton.layer.masksToBounds = true
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    //MARK: TABLE VIEW
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return SectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        if(section == 0){
            let mystring = "Select Classes"
            return mystring
        }else{
            let mystring = "Select Groupes"
            return mystring
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return 40
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if(section == 0){
            return SectionArrayData.count
        }else{
            return GroupArrayData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSectionTVCell", for: indexPath) as! SelectSectionTVCell
            cell.SectionNameLabel.text = SectionArrayData[indexPath.row]
            
            if(SegueSelectedSectionArray.count > 0){
                
                let strSelect = SectionArrayData[indexPath.row]
                
                if(SegueSelectedSectionArray.contains(strSelect)){
                    selectedSectionArray = SegueSelectedSectionArray
                    selectedSectionCodeArray = SegueSelectedSectionCodeArray
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition:UITableView.ScrollPosition.none)
                    
                }
                
                ConFirmButtonActive()
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSectionTVCell", for: indexPath) as! SelectSectionTVCell
            cell.SectionNameLabel.text = GroupArrayData[indexPath.row]
            if(SegueSelectedGroupArray.count > 0){
                
                let strSelect = GroupArrayData[indexPath.row]
                
                if(SegueSelectedGroupArray.contains(strSelect)){
                    selectedGroupArray = SegueSelectedGroupArray
                    selectedGroupCodeArray = SegueSelectedGroupCodeArray
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition:UITableView.ScrollPosition.none)
                }else{
                    myTableView.deselectRow(at: indexPath, animated: false)
                }
                self.ConFirmButtonActive()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        self.ConFirmButtonActive()
        if(indexPath.section == 0){
            let deselecteddata = SectionArrayData[indexPath.row]
            selectedSectionArray.append(deselecteddata)
            selectedSectionCodeArray.append(SectionCodeArrayData[indexPath.row])
        }else if(indexPath.section == 1){
            let deselecteddata = GroupArrayData[indexPath.row]
            selectedGroupArray.append(deselecteddata)
            selectedGroupCodeArray.append(GroupCodeArrayData[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath){
        
        if(indexPath.section == 0){
            
            let selecteddata = SectionArrayData[indexPath.row]
            
            if(selectedSectionArray.contains(selecteddata)){
                if let index = selectedSectionArray.index(of: selecteddata){
                    selectedSectionArray.remove(at: index)
                    selectedSectionCodeArray.remove(at: index)
                }
                
            }
            if(selectedSectionArray.count == 0){
                self.ConfirmButtonDeactive()
            }else{
                self.ConFirmButtonActive()
            }
            
        }else if(indexPath.section == 1){
            
            let selecteddata = GroupArrayData[indexPath.row]
            
            if(selectedGroupArray.contains(selecteddata)){
                if let index = selectedGroupArray.index(of: selecteddata) {
                    selectedGroupArray.remove(at: index)
                    selectedGroupCodeArray.remove(at: index)
                }
            }
            
            if(selectedGroupArray.count == 0){
                self.ConfirmButtonDeactive()
            }else{
                self.ConFirmButtonActive()
            }
        }
    }
    
    
    //MARK: BUTTON ACTION
    
    @IBAction func actionCancel(_ sender: Any){
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBackSection"), object: nil,userInfo: ["SectionDetailArray":SegueSelectedSectionArray,"SectionCodeArray":SegueSelectedSectionCodeArray,"GroupDetailArray":SegueSelectedGroupArray,"GroupCodeArray":SegueSelectedGroupCodeArray,"actionkey":"cancel"])
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func actionConformSelection(_ sender: Any){
        
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBackSection"), object: nil,userInfo: ["SectionDetailArray":selectedSectionArray,"SectionCodeArray":selectedSectionCodeArray,"GroupDetailArray":selectedGroupArray,"GroupCodeArray":selectedGroupCodeArray,"actionkey":"ok"])
        self.dismiss(animated: false, completion: nil)
    }
    
    func ConFirmButtonActive(){
        ConfirmButton.isUserInteractionEnabled = true
        ConfirmButton.backgroundColor = UIColor(red: 36.0/255.0, green: 187.0/255.0, blue: 89.0/255.0, alpha: 1)
    }
    
    func ConfirmButtonDeactive(){
        ConfirmButton.backgroundColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        ConfirmButton.isUserInteractionEnabled = false
    }
    
}
