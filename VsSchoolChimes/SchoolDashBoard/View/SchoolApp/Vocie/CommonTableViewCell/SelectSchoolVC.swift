//
//  SelectSchoolVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 18/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class SelectSchoolVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
 
    var schoolNameArray:Array = [String]()
    
    var selectedSchoolArray:Array = [String]()
    var didselectedSchoolArray:Array = [String]()
    var SegueSelectedDataArray:Array = [String]()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        schoolNameArray = ["Chennai School","Public School","DonBosCo","LittleFlower","New American School","GovtSchool","Grace School","St.Joseph School"]
        print(SegueSelectedDataArray)
        
        
     
       
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
          return schoolNameArray.count
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
    let cell = tableView.dequeueReusableCell(withIdentifier: "SelectSchoolTVC", for: indexPath) as! SelectSchoolTVC
   // cell.SchoolNameLabel.text = schoolName.object(at: indexPath.row) as? String
        cell.SchoolNameLabel.text = schoolNameArray[indexPath.row]
        if(SegueSelectedDataArray.count > 0)
        {
            if(SegueSelectedDataArray.contains(schoolNameArray[indexPath.row]))
            {
                print(SegueSelectedDataArray)
                selectedSchoolArray = SegueSelectedDataArray
                tableView.selectRow(at: indexPath, animated: false, scrollPosition:UITableViewScrollPosition.none)
            }
            else
            {
                
            }
        }

        
            
    return cell
        
    }
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
        selectedSchoolArray.append(schoolNameArray[indexPath.row])
        print("selected school \(selectedSchoolArray)")
        
        
    }
     func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselecteddata = schoolNameArray[indexPath.row]
        if(selectedSchoolArray.contains(deselecteddata))
        {
            if let index = selectedSchoolArray.index(of: deselecteddata) {
                selectedSchoolArray.remove(at: index)
            }
            
        }
        
        print("didselected school \(deselecteddata)")
        
    }
    
    @IBAction func Okaction(_ sender: Any) {
       
        let nc = NotificationCenter.default
        nc.post(name:Notification.Name(rawValue:"comeBack"),
                object: nil,userInfo: ["schooldata":selectedSchoolArray,"actionkey":"ok"])
        self.dismiss(animated: false, completion: nil)
    }
   
    
    @IBAction func Cancelaction(_ sender: Any) {
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "comeBack"), object: nil,userInfo: ["schooldata":SegueSelectedDataArray,"actionkey":"cancel"])
        self.dismiss(animated: false, completion: nil)
        
    }
    func cellSelected(indexs:NSIndexPath) -> Void {
        
        
    }
   
    

}
