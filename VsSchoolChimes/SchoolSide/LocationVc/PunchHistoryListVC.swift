//
//  PunchHistoryListVC.swift
//  VoicesnapSchoolApp
//
//  Created by admin on 24/09/24.
//  Copyright © 2024 Gayathri. All rights reserved.
//

import UIKit
import ObjectMapper
class PunchHistoryListVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
 
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var tv: UITableView!
    var staffId : Int!
    var instituteId : Int!
    var date : String!
    var timeData : [Timing] = []
    var identifier = "PunchHistTableViewCell"
    override func viewDidLoad() {
        super.viewDidLoad()

       let rowNiib = UINib(nibName: identifier, bundle: nil)
        tv.register(rowNiib, forCellReuseIdentifier: identifier)
        
        noRecordLbl.isHidden = true
        punchHistory(date : date)
        
        let back = UITapGestureRecognizer(target: self, action: #selector(backClick))
        backView.addGestureRecognizer(back)
    }



    @IBAction func backClick(){
        
        dismiss(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PunchHistTableViewCell
        
        let data : Timing  = timeData[indexPath.row]
        cell.timing.text = data.time
        
        
        if data.deviceModel == nil || data.deviceModel == ""{
            
//            cell.phoneModel.isHidden =
            cell.phoneModel.text = "Device Modal - " + "null"
        }else{
            cell.phoneModel.isHidden = false
            cell.phoneModel.text = "Device Modal - " + data.deviceModel
        }
        
        
       
        if data.punchType.value == nil || data.punchType.value == "" {
            
//            cell.punchType.isHidden = true
            cell.punchType.text = "Punch Type - " + "null"
        }else{
            cell.punchType.isHidden = false
            cell.punchType.text = "Punch Type - " + data.punchType.value
        }
        
        

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    
    func punchHistory(date : String){
        
        
        timeData.removeAll()
        
        let param : [String : Any] =
        [
            
            "userId": staffId!,
            "instituteId" : instituteId!,
            "from_date" : date,
            "to_date"  : date
            
        ]
        
        print("paramparamm,nc",param)
        
        PunchHistryRequest.call_request(param: param){ [self]
            (res) in
            
            print("resres",res)
            let PunchHistory : punchHistryResponce = Mapper<punchHistryResponce>().map(JSONString: res)!
            
            if PunchHistory.status == 1  {
                
                for i in PunchHistory.data{
                    
                    timeData.append(contentsOf: i.timings)
                    
                }
                noRecordLbl.isHidden = true
                tv.dataSource = self
                tv.delegate = self
                tv.reloadData()
                
            }else{
                
                noRecordLbl.isHidden = false
                
                noRecordLbl.text = PunchHistory.message
                
            }
            
            
            
            
        }
        
    }
}
