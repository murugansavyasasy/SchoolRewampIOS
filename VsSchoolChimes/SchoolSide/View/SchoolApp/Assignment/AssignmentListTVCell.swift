//
//  AssignmentListTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by Preethi on 30/04/20.
//  Copyright © 2020 Shenll-Mac-04. All rights reserved.
//

import UIKit

class AssignmentListTVCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var submissionButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var dueLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var sendByLabel: UILabel!
    @IBOutlet weak var newImageLabel: UILabel!
    @IBOutlet weak var subjectLabelLang: UILabel!
    @IBOutlet weak var dueLabelLang: UILabel!
    @IBOutlet weak var countLabelLang: UILabel!
    @IBOutlet weak var sendByLabelLang: UILabel!
    @IBOutlet weak var newImageWidth: NSLayoutConstraint!
    @IBOutlet weak var submissionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var categorylabel: UILabel!
    @IBOutlet weak var categoryLabelLang: UILabel!
    
    let util = Util()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonBorder(view: viewButton)
        buttonBorder(view: submitButton)
        buttonBorder(view: submissionButton)
        buttonBorder(view: newImageLabel)
    }
    
    func buttonBorder(view : UIView){
        view.layer.borderWidth = 0.3
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.clear.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: Language Selection
    
    func callSelectedLanguage(){
        let  strLanguage : String = UserDefaults.standard.object(forKey: SELECTED_LANGUAGE) as! String
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
        
        if(Language == "ar"){
            self.mainView.semanticContentAttribute = .forceRightToLeft
        }else{
            self.mainView.semanticContentAttribute = .forceLeftToRight
        }
        
        
    }
    
    
}
