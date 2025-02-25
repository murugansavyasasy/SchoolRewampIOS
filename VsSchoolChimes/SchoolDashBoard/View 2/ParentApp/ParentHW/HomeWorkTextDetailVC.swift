//
//  HomeWorkTextDetailVC.swift
//  VoicesnapParentApp
//
//  Created by Shenll-Mac-04 on 05/02/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class HomeWorkTextDetailVC: UIViewController {
    @IBOutlet weak var DetailTextView: UITextView!
    @IBOutlet weak var SubjectLbl: UILabel!
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
        if(SenderType == "ExamTest"){
            SubjectLbl.text = String(describing: selectedDictionary["ExaminationName"]!)
            DetailTextView.text = String(describing: selectedDictionary["ExaminationSyllabus"]!)
            
            let DescriptionText:String = String(describing: selectedDictionary["SubjectsForExam"]!)
            let CheckNilText : String = Util .checkNil(DescriptionText)
            if(CheckNilText != ""){
                TitleVLbl.text = CheckNilText
                TitleView.isHidden = false
                let Stringlength : Int = CheckNilText.count
                
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    print(Stringlength)
                    let MuValue : Int = Stringlength/61
                    TextViewHeightConst.constant  = 40 + (30 * CGFloat(MuValue))
                    print( TextViewHeightConst.constant)
                    
                    
                }else{
                    if(Screenheight > 580){
                        let MuValue : Int = Stringlength/50
                        TextViewHeightConst.constant  = 30 + ( 18 * CGFloat(MuValue))
                        
                    }else{
                        let MuValue : Int = Stringlength/44
                        TextViewHeightConst.constant  = 30 + ( 18 * CGFloat(MuValue))
                    }
                }
            }else{
                TitleVLbl.text = ""
                TitleView.isHidden = true
                TextViewHeightConst.constant = 0
            }
        }else{
            SubjectLbl.text = String(describing: selectedDictionary["HomeworkSubject"]!)
            DetailTextView.text = String(describing: selectedDictionary["HomeworkContent"]!)
            let DescriptionText:String = String(describing: selectedDictionary["HomeworkTitle"]!)
            let CheckNilText : String = Util .checkNil(DescriptionText)
            if(CheckNilText != ""){
                TitleVLbl.text = CheckNilText
                TitleView.isHidden = false
                let Stringlength : Int = CheckNilText.count
                
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    print(Stringlength)
                    let MuValue : Int = Stringlength/55
                    TextViewHeightConst.constant  = 40 + (30 * CGFloat(MuValue))
                    print(TextViewHeightConst.constant)
                    
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
                TitleVLbl.text = ""
                TitleView.isHidden = true
                TextViewHeightConst.constant = 0
            }
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
    
    
}
