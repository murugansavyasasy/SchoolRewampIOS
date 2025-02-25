//
//  AbsentenceVC.swift
//  VoicesnapSchoolApp
//
//  Created by Shenll-Mac-04 on 12/01/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit
import ObjectMapper
class AbsentenceVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var Selectedindexnumber = Int()
    var SegueString = String()
    var fromVC = String()
    var SelectedSchoolIDString = String()
    var SelectedStaffIDString = String()
    var selectedSchoolDict = NSDictionary()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var tv: UITableView!
    
    var OverAllCountValue  = 0;
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.isOpaque = false
        self.view.backgroundColor =  UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.title = ""
        print("Abs VC \(fromVC)")
        if(fromVC == "p6")
        {
            SegueString = "ViewAbsenteesDateViceSegue"
            
        } else if(fromVC == "p24")
        {
            SegueString = "ShowChatScreenSegue"
            
        } else if(fromVC == "p13")
        {
            SegueString = "MessageFromManagementSegue"
            
        }else{
            SegueString = "ViewSchoolStrengthSegue"
        }
        
        coutApi()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationItem.title = " "
        self.title = ""
    }
    
    
    
    func coutApi(){

            print("appDelSchoolDetailnt",appDelegate.LoginSchoolDetailArray.count)

            DefaultsKeys.coutData.removeAll()
            var scholId = ""
            var staffId = ""

            var CountModal1 : [CountReqModal] = []
            for i in 0..<appDelegate.LoginSchoolDetailArray.count{


                let Dict : NSDictionary =  appDelegate.LoginSchoolDetailArray[i] as! NSDictionary
                staffId = (String(describing: Dict["StaffID"]!))
                scholId    = (String(describing: Dict["SchoolID"]!))

                let couts = CountReqModal()
                couts.SchoolID = scholId
                couts.staffId = staffId

                CountModal1.append(couts)

            }


            let countStr = CountModal1.toJSONString()
            print("requessttttt",countStr)

            print("requessttttt",countStr)

            CountRequest.call_request(param: countStr!){
                [self] (res) in

                print("responsAPiii",res)

                if DefaultsKeys.failedErrorCode == 404 {
                    print("DefaultsKeys.failedErrorCode",DefaultsKeys.failedErrorCode)
                }else{

                    let coutnsResp : [countResponce] = Mapper<countResponce>().mapArray(JSONString: res)!

                    OverAllCountValue = 0;
                    for i in 0..<coutnsResp.count
                    {

                        OverAllCountValue = OverAllCountValue + Int(coutnsResp[i].OVERALLCOUNT)!
                    }




                    //        defaultkcoutData.append(contentsOf: coutnsResp)

                    DefaultsKeys.coutData.append(contentsOf: coutnsResp)
                    tv.reloadData()
                }

            }



    //        print("coutDatacoutData",coutData.count)



        }
    
    //MARK: TABLEVIEW DELEGATE
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return 65
        }else{
            return 50
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return appDelegate.LoginSchoolDetailArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AbsenteesTVCell", for: indexPath) as! AbsenteesTVCell
        cell.backgroundColor = UIColor.clear
        let Dict = appDelegate.LoginSchoolDetailArray[indexPath.row] as! NSDictionary
        cell.SchoolNameLbl.text = Dict["SchoolName"] as? String
        
        cell.schoolCountView.isHidden = true
        if(fromVC == "p13"){
            for i in DefaultsKeys.coutData {
                if(Dict["SchoolID"]! as? String == i.SCHOOLID){
                    if(Int(i.OVERALLCOUNT)! > 0){
                        cell.schoolCountView.isHidden = false
                        cell.schoolCountLbl.text = i.OVERALLCOUNT
                    }
                    else{
                        cell.schoolCountView.isHidden = true

                    }
                    
                }
            }
        }
        else{
            cell.schoolCountView.isHidden = true
        }
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
        return cell;
    }
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if(fromVC == "p6") {
            print("Click")
            let vc = NewAbsenteesViewController(nibName: nil, bundle: nil)
            
            
            let Dict = appDelegate.LoginSchoolDetailArray[indexPath.row] as! NSDictionary
            
            vc.SchoolId = (Dict["SchoolID"] as? String)!
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }else{
            
            
            let Dict = appDelegate.LoginSchoolDetailArray[indexPath.row] as! NSDictionary
            selectedSchoolDict = Dict
            SelectedSchoolIDString = (Dict["SchoolID"] as? String)!
            SelectedStaffIDString = (Dict["StaffID"] as? String)!

            performSegue(withIdentifier: SegueString, sender: self)
        }
    }
    //MARK: BUTTON ACTION
    
    @IBAction func actionCloseView(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: false)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        

        if (segue.identifier == "ViewSchoolStrengthSegue")
        {
            let segueid = segue.destination as! AbsenteesRecordVC
            segueid.SchoolIDString = SelectedSchoolIDString
            
        }
        else if (segue.identifier == "ShowChatScreenSegue")
        {
//            let segueid = segue.destination as! StaffInteractVC
//            segueid.SchoolDetailDict = selectedSchoolDict
//            
//        }



            print("SelectedStaffIDString",SelectedStaffIDString)
            print("SelectedSchoolIDString",SelectedSchoolIDString)


                let segueid = segue.destination as! StaffChatInteractDetailVC
                           segueid.StaffId = SelectedStaffIDString
                           segueid.SchoolId = SelectedSchoolIDString





                   }

        else if (segue.identifier == "MessageFromManagementSegue")
        {
            let segueid = segue.destination as! MsgFromMgmtVC
            segueid.SchoolDetailDict = selectedSchoolDict
            segueid.checkSchoolId = "1"
           
            print("selectedSchoolDictselectedSchoolDict11",selectedSchoolDict)
        }
        
    }
    
}
