//
//  AttendanceSelectSchoolVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 17/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class AttendanceSelectSchoolVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet var MyTableView: UITableView!
    var SelectedSchoolDeatilDict:NSDictionary = [String:Any]() as NSDictionary
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let UtilObj = UtilClass()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nc = NotificationCenter.default
        nc.addObserver(self,selector: #selector(AttendanceSelectSchoolVC.catchNotification1), name: NSNotification.Name(rawValue: "comeBackMenu"), object:nil)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: Button Action
    @IBAction func actionCloseView(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    
    //MARK: TABLEVIEW DELEGATE
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return 65
        }else{
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.LoginSchoolDetailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageTVCell", for: indexPath) as! TextMessageTVCell
        let Dict = appDelegate.LoginSchoolDetailArray[indexPath.row] as! NSDictionary
        cell.SchoolNameLbl.text = Dict["SchoolName"] as? String
        var schoolNameReg  =  Dict["SchoolNameRegional"] as? String

                if schoolNameReg != "" && schoolNameReg != nil {

                    cell.SchoolNameRegionalLbl.text = schoolNameReg
                    cell.SchoolNameRegionalLbl.isHidden = false

//                        cell.locationTop.constant = 4
                }else{
                    cell.SchoolNameRegionalLbl.isHidden = true
        //            cell.SchoolNameRegional.backgroundColor = .red
                    cell.schoolNameTop.constant = 20

                }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SelectedSchoolDeatilDict = appDelegate.LoginSchoolDetailArray[indexPath.row] as! NSDictionary
        print("SelectedSchoolDeatilDict",SelectedSchoolDeatilDict)
        UtilObj.printLogKey(printKey: "SelectedSchoolDeatilDict", printingValue: SelectedSchoolDeatilDict)
        print("Direct12")
         self.performSegue(withIdentifier: "AttendanceMessageSegue", sender: self)
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "AttendanceMessageSegue"){
            let segueid = segue.destination as! AttendanceMessageVC
            segueid.SchoolDeatilDict = SelectedSchoolDeatilDict
            segueid.checkSchoolId = "1"
            print("Direct")
        }
    }
    
    @objc func catchNotification1(notification:Notification) -> Void{
        print("School attendance Student notif")
        dismiss(animated: false, completion: nil)
    }
}
