//
//  DropDownVC.swift
//  GiftWallet
//
//  Created by Shenll-Mac-04 on 13/12/17.
//  Copyright © 2017 Shenll Software Solutions. All rights reserved.
//

import UIKit

class DropDownVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var DropDownTableView: UITableView!
    
    var arrSchoolName = NSArray()
    var arrFAQName = NSArray()
    var TitleString = String()
    var selectedString = String()
    var CellTypeString = String()
    var NotificationName = String()
    var fromVC = String()
    var dictSelectedSchool:NSDictionary = [String:Any]() as NSDictionary
    let UtilObj = UtilClass()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var arrCommon = NSArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.callSelectedLanguage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        arrSchoolName = appDelegate.LoginSchoolDetailArray
    }
    
    func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(fromVC == "FAQ"){
            return 50
        }else if(fromVC == "setting" || fromVC == "settings"){
                   return 50
               }
        if(fromVC == "meeting"){
            return 40

        }
        else{
            if(UIDevice.current.userInterfaceIdiom == .pad){
                return 58
            }else{
                return 48
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(fromVC == "FAQ" || fromVC == "setting" || fromVC == "settings"){
            return arrFAQName.count
        }else if(fromVC == "meeting"){
            return arrCommon.count

        }
        else{
            return arrSchoolName.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownTVCell", for: indexPath) as! DropDownTVCell
        if(fromVC == "FAQ" || fromVC == "setting" || fromVC == "settings"){
            cell.SchoolNameLbl.text = arrFAQName[indexPath.row] as? String
            if(UIDevice.current.userInterfaceIdiom == .pad){
                cell.SchoolNameLbl.font = UIFont.boldSystemFont(ofSize: 20)
            }
            cell.backgroundColor = UIColor.clear
            cell.MainView.backgroundColor = UIColor.white
            cell.SchoolNameLbl.textAlignment = .center
        }else if(fromVC == "meeting"){
            let dict = arrCommon[indexPath.row] as! NSDictionary
            cell.SchoolNameLbl.textAlignment = .left
            cell.SchoolNameLbl.text = String(describing: dict["type"]!)
           
        }
        else{
            let dict = arrSchoolName[indexPath.row] as! NSDictionary
            cell.SchoolNameLbl.textAlignment = .left
            cell.SchoolNameLbl.text = String(describing: dict["SchoolName"]!)
            cell.MainView.layer.cornerRadius = 5
            cell.MainView.clipsToBounds = true
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: false, completion: nil)

        if(fromVC == "FAQ" || fromVC == "setting" || fromVC == "settings"){
            selectedString = arrFAQName[indexPath.row] as! String
            perform(#selector(MoveToNextpage), with: nil, afterDelay: 0.2)
        } else if(fromVC == "meeting"){
            dictSelectedSchool = arrCommon[indexPath.row] as! NSDictionary
            perform(#selector(MoveToNextpage), with: nil, afterDelay: 0.2)
        }
        else{
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCell.AccessoryType.checkmark
            dictSelectedSchool = arrSchoolName[indexPath.row] as! NSDictionary
            perform(#selector(MoveToNextpage), with: nil, afterDelay: 0.2)
        }
    }
    
    @objc  func MoveToNextpage(){

        let nc = NotificationCenter.default
        if(fromVC == "FAQ"){
            nc.post(name: Notification.Name(rawValue:"FAQNotification"), object: selectedString)
        }else if(fromVC == "setting" || fromVC == "settings"){
            nc.post(name: Notification.Name(rawValue:"SettingNotification"), object: selectedString)
        } else if(fromVC == "meeting"){
            nc.post(name: Notification.Name(rawValue:"meetingNotification"), object: dictSelectedSchool)

        }
        else{
            nc.post(name: Notification.Name(rawValue:"DropDownNotification"), object: dictSelectedSchool)
        }
    }
    
    func callSelectedLanguage(){
        let strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }
            } catch {
                
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        
      
        if(fromVC == "FAQ"){
              arrFAQName = [LangDict["fag_for_parent"] as? String ?? "",LangDict["faq_for_school"] as? String ?? ""]
            self.navigationController?.navigationBar.isHidden = true
            if(UIDevice.current.userInterfaceIdiom == .pad){
                self.preferredContentSize = CGSize(width: 250, height: 100)
            }else{
                self.preferredContentSize = CGSize(width: 200, height: 90)
            }
        } else if(fromVC == "setting"){
        
            arrFAQName =  [LangDict["txt_menu_help"] as? String ?? "",LangDict["txt_menu_logout"] as? String ?? ""]
                   self.navigationController?.navigationBar.isHidden = true
            print(arrFAQName)
                   if(UIDevice.current.userInterfaceIdiom == .pad){
                       self.preferredContentSize = CGSize(width: 180, height: 100)
                   }else{
                       self.preferredContentSize = CGSize(width: 160, height: 90)
                   }
               }
        else if(fromVC == "settings"){
           
            arrFAQName =  ["Upload Document and Photos",LangDict["txt_menu_help"] as? String ?? "" ,LangDict["txt_menu_logout"] as? String ?? ""]
                   self.navigationController?.navigationBar.isHidden = true
                   if(UIDevice.current.userInterfaceIdiom == .pad){
                       self.preferredContentSize = CGSize(width: 300, height: 120)
                   }else{
                       self.preferredContentSize = CGSize(width: 260, height: 110)
                   }
               }
     else if(fromVC == "meeting"){
        self.title = "SELECT MEETING PLATFORM"
        self.navigationController?.navigationBar.isHidden = false
        if(UIDevice.current.userInterfaceIdiom == .pad){
            self.preferredContentSize = CGSize(width: 600, height: 600)
        }else{
            self.preferredContentSize = CGSize(width: 300, height: 300)
        }
    }
        else{
            self.title = LangDict["teacher_select_school"] as? String
            self.navigationController?.navigationBar.isHidden = false
            if(UIDevice.current.userInterfaceIdiom == .pad){
                self.preferredContentSize = CGSize(width: 600, height: 600)
            }else{
                self.preferredContentSize = CGSize(width: 300, height: 300)
            }
        }
    }
}
