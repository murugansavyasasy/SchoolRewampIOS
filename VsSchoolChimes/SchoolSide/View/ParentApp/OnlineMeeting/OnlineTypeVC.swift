//
//  HomeWorkTextDetailVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 05/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class OnlineTypeVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var DetailTextView: UITextView!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var TitleVLbl: UITextView!
    @IBOutlet weak var TitleView: UIView!
    @IBOutlet weak var TextViewHeightConst: NSLayoutConstraint!
    var selectedDictionary = NSDictionary()
    var Screenheight = CGFloat()
    var arrSteps = NSArray()
    @IBOutlet weak var tblsteps: UITableView!
    
    var SenderType = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  self.callSelectedLanguage()
        
        arrSteps = selectedDictionary.object(forKey: "steps") as? NSArray ?? []
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionBack(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        let  strLanguage : String = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        if(strLanguage == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.DetailTextView.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.DetailTextView.textAlignment = .left
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrSteps.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //       
        return 40
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingTVCell", for: indexPath) as! MeetingTVCell
        let dicCountryName = arrSteps.object(at: indexPath.row) as! NSDictionary
        let num = dicCountryName["id"] as? String ?? ""
        var htmlString = ""
        if(num == ""){
            htmlString = "\n \(dicCountryName["st"] as? String ?? "") \n"
            
        }else{
            htmlString = "\n \(num). \(dicCountryName["st"] as? String ?? "") \n"
            
        }
        let data = htmlString.data(using: .utf8)!
        let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        
        
        cell.meetingDateLabel.attributedText = attributedString
        
        cell.meetingDateLabel.numberOfLines = 0
        
        
        
        return cell
    }
    
   
    
    
    
    
}
