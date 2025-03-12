//
//  TextDetailVC.swift
//  VoicesnapParentApp
//
//  Created by PREMKUMAR on 16/07/17.
//  Copyright © 2017 Shenll-Mac-04. All rights reserved.
//

import UIKit

class TextDetailVC: UIViewController {
    
    @IBOutlet weak var PopupDetailTextView: UITextView!
    @IBOutlet var TextDateLabel: UILabel!
    @IBOutlet var TextTitleLabel: UILabel!
    @IBOutlet var TitleText: UITextView!
    @IBOutlet var TitleView: UIView!
    @IBOutlet weak var TextViewHeightConst: NSLayoutConstraint!
    
    var SenderType = String()
    var Screenheight = CGFloat()
    var selectedDictionary = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callSelectedLanguage()
        Screenheight = self.view.frame.size.height
        TextDateLabel.text = String(describing: selectedDictionary["Time"]!)
        TextTitleLabel.text = String(describing: selectedDictionary["Subject"]!)
        
        PopupDetailTextView.text = String(describing: selectedDictionary["URL"]!)
        
        var DescriptionText = String()
        var CheckNilText = String()
        if(SenderType == "FromStaff"){
            CheckNilText = ""
        }else{
            DescriptionText = String(describing: selectedDictionary["Description"]!)
            CheckNilText  = Util .checkNil(DescriptionText)
        }
        if(CheckNilText != ""){
            TitleText.text = CheckNilText
            TitleView.isHidden = false
            let Stringlength : Int = CheckNilText.count
            if(UIDevice.current.userInterfaceIdiom == .pad){
                let MuValue : Int = Stringlength/55
                TextViewHeightConst.constant  = 40 + (30 * CGFloat(MuValue))
            }else{
                if(Screenheight > 580){
                    let MuValue : Int = Stringlength/50
                    TextViewHeightConst.constant  = 30 + ( 18 * CGFloat(MuValue))
                    
                }else{
                    let MuValue : Int = Stringlength/44
                    TextViewHeightConst.constant  = 30 + ( 18 * CGFloat(MuValue))
                }
            }
        }
        else{
            TitleText.text = ""
            TitleView.isHidden = true
            TextViewHeightConst.constant = 0
        }
        
        PopupDetailTextView.tintColor = .systemGreen
        PopupDetailTextView.isEditable = false
        PopupDetailTextView.dataDetectorTypes = .all
        
        TitleText.tintColor = .systemGreen
        TitleText.isEditable = false
        TitleText.dataDetectorTypes = .all
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionBack(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        let  strLanguage : String = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
        if(strLanguage == "ar"){
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.TitleText.textAlignment = .right
            self.PopupDetailTextView.textAlignment = .right
        }else{
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            self.TitleText.textAlignment = .left
            self.PopupDetailTextView.textAlignment = .left
        }
    }
}
