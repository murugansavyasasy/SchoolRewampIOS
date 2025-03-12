//
//  LeaveHistoryPopupVC.swift
//  VoicesnapSchoolApp
//
//  Created by Apple on 14/05/19.
//  Copyright © 2019 Shenll-Mac-04. All rights reserved.
//

import UIKit

class LeaveHistoryPopupVC: UIViewController {
    
    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var ClassLabel: UILabel!
    @IBOutlet weak var LeaveAppiledOnLabel: UILabel!
    @IBOutlet weak var LeaveFromLabel: UILabel!
    @IBOutlet weak var LeaveToLabel: UILabel!
    @IBOutlet weak var FloatNameLabel: UILabel!
    @IBOutlet weak var FloatClassLabel: UILabel!
    @IBOutlet weak var FlaotLeaveAppiledOnLabel: UILabel!
    @IBOutlet weak var FloatLeaveFromLabel: UILabel!
    @IBOutlet weak var FloatLeaveToLabel: UILabel!
    @IBOutlet weak var FlaotReason: UILabel!
    @IBOutlet weak var TitlLable: UILabel!
    @IBOutlet weak var reasonTextView: UITextView!
    
    var selectedHistoryDict : NSDictionary = NSDictionary()
    var languageDictionary = NSDictionary()
    var strLanguage = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.callSelectedLanguage()
    }
    
    @IBAction func actionOkButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        strLanguage = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        
        let bundle = Bundle(for: type(of: self))
        if let theURL = bundle.url(forResource: strLanguage, withExtension: "json") {
            do {
                let data = try Data(contentsOf: theURL)
                if let parsedData = try? JSONSerialization.jsonObject(with: data) as AnyObject {
                    self.loadLanguageData(LangDict: parsedData as! NSDictionary, Language: strLanguage)
                }else{
                    self.loadViewData()
                }
            } catch {
                self.loadViewData()
            }
        }
    }
    
    func loadLanguageData(LangDict : NSDictionary, Language : String){
        languageDictionary = LangDict
        if(Language == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.TitlLable.text = languageDictionary["leave_history"] as? String
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.TitlLable.text = languageDictionary["leave_history"] as? String
        }
        
        self.loadViewData()
        
    }
    
    func loadViewData(){
        if(strLanguage == "ar"){
            
            self.NameLabel.textAlignment = .right
            self.ClassLabel.textAlignment = .right
            self.LeaveAppiledOnLabel.textAlignment = .right
            self.LeaveFromLabel.textAlignment = .right
            self.LeaveToLabel.textAlignment = .right
            self.reasonTextView.textAlignment = .right
            self.FlaotReason.textAlignment = .right
            self.FloatNameLabel.textAlignment = .right
            self.FloatClassLabel.textAlignment = .right
            self.FloatLeaveToLabel.textAlignment = .right
            self.FlaotReason.textAlignment = .right
            self.FloatLeaveFromLabel.textAlignment = .right
            self.FlaotLeaveAppiledOnLabel.textAlignment = .right
            
            NameLabel.text =  String(describing: selectedHistoryDict["StudentName"]!) + " : "
            ClassLabel.text =  String(describing: selectedHistoryDict["Class"]!) + " - " + String(describing: selectedHistoryDict["Section"]!) + " : "
            LeaveAppiledOnLabel.text =  String(describing: selectedHistoryDict["LeaveAppliedOn"]!) + " : "
            LeaveFromLabel.text =   String(describing: selectedHistoryDict["LeaveFromDate"]!) + " : "
            LeaveToLabel.text = String(describing: selectedHistoryDict["LeaveTODate"]!) + " : "
            reasonTextView.text =  String(describing: selectedHistoryDict["Reason"]!)
        }else{
            self.NameLabel.textAlignment = .left
            self.ClassLabel.textAlignment = .left
            self.LeaveAppiledOnLabel.textAlignment = .left
            self.LeaveFromLabel.textAlignment = .left
            self.LeaveToLabel.textAlignment = .left
            self.reasonTextView.textAlignment = .left
            self.FlaotReason.textAlignment = .left
            self.FloatNameLabel.textAlignment = .left
            self.FloatClassLabel.textAlignment = .left
            self.FloatLeaveToLabel.textAlignment = .left
            self.FlaotReason.textAlignment = .left
            self.FloatLeaveFromLabel.textAlignment = .left
            self.FlaotLeaveAppiledOnLabel.textAlignment = .left
            
            NameLabel.text = " : " + String(describing: selectedHistoryDict["StudentName"]!)
            ClassLabel.text = " : " + String(describing: selectedHistoryDict["Class"]!) + " - " + String(describing: selectedHistoryDict["Section"]!)
            LeaveAppiledOnLabel.text = " : " + String(describing: selectedHistoryDict["LeaveAppliedOn"]!)
            LeaveFromLabel.text = " : " + String(describing: selectedHistoryDict["LeaveFromDate"]!)
            LeaveToLabel.text = " : " + String(describing: selectedHistoryDict["LeaveTODate"]!)
            reasonTextView.text =  String(describing: selectedHistoryDict["Reason"]!)
        }
        self.FloatNameLabel.text = languageDictionary["name"] as? String
        self.FloatClassLabel.text = languageDictionary["class"] as? String
        self.FloatLeaveToLabel.text = languageDictionary["leave_to_date"] as? String
        self.FlaotReason.text = languageDictionary["leave_reason"] as? String
        self.FloatLeaveFromLabel.text = languageDictionary["leave_from_date"] as? String
        self.FlaotLeaveAppiledOnLabel.text = languageDictionary["appliedon"] as? String
        
        
    }
    
    
    
}
