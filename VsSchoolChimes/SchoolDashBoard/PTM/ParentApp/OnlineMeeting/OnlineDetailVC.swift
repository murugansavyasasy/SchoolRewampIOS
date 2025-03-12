//
//  HomeWorkTextDetailVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 05/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class OnlineDetailVC: UIViewController {
    @IBOutlet weak var DetailTextView: UITextView!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!

    @IBOutlet weak var TitleVLbl: UITextView!
    @IBOutlet weak var TitleView: UIView!
    @IBOutlet weak var TextViewHeightConst: NSLayoutConstraint!
    var selectedDictionary = NSDictionary()
    var Screenheight = CGFloat()
    
    var SenderType = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callSelectedLanguage()
        Screenheight = self.view.frame.size.height
        
        
        titleLbl.text = "\(selectedDictionary["topic"] as? String ?? "")"
        TitleVLbl.text = "\(selectedDictionary["description"] as? String ?? "")"
        DetailTextView.text = "\(selectedDictionary["url"] as? String ?? "")"

        TextViewHeightConst.constant = self.TitleVLbl.contentSize.height

                if(self.TitleVLbl.contentSize.height > 150){
                    TextViewHeightConst.constant = 160
                }
        
        TitleVLbl.tintColor = .systemGreen
                   TitleVLbl.isEditable = false
                   TitleVLbl.dataDetectorTypes = .all
        
        DetailTextView.tintColor = .systemGreen
             DetailTextView.isEditable = false
             DetailTextView.dataDetectorTypes = .all
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    
    
    
}
