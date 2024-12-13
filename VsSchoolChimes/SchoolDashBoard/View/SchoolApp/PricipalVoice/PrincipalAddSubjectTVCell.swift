//
//  PrincipalAddSubjectTVCell.swift
//  VoicesnapSchoolApp
//
//  Created by STS_MAC_04 on 18/07/18.
//  Copyright © 2018 Shenll-Mac-04. All rights reserved.
//

import UIKit

class PrincipalAddSubjectTVCell: UITableViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var SubjectNameLbl: UILabel!
    @IBOutlet weak var SelectImg: UIImageView!
    @IBOutlet weak var CellSelectionButton : UIButton!
    @IBOutlet weak var AddView : UIView!
    @IBOutlet weak var RemoveView : UIView!
    @IBOutlet weak var AddButton : UIButton!
    @IBOutlet weak var RemoveButton : UIButton!
    // @IBOutlet weak var StaffNameLbl: UILabel!
    //@IBOutlet weak var SelectImg: UIImageView!
    @IBOutlet weak var RemoveMarkLbl: UILabel!
    @IBOutlet weak var RemoveDateLbl: UILabel!
    @IBOutlet weak var RemoveTimeLbl: UILabel!
    
    @IBOutlet weak var FloatRemoveMarkLbl: UILabel!
    @IBOutlet weak var FloatRemoveDateLbl: UILabel!
    @IBOutlet weak var FlaotRemoveTimeLbl: UILabel!
    @IBOutlet weak var FloatAddMarkTxt: UILabel!
    @IBOutlet weak var FloatAddDateLbl: UILabel!
    @IBOutlet weak var FloatAddTimeLbl: UILabel!
    
    @IBOutlet weak var AddMarkTxt: UITextField!
    @IBOutlet weak var AddDateLbl: UILabel!
    @IBOutlet weak var AddTimeLbl: UILabel!
    @IBOutlet weak var AddDateButton : UIButton!
    @IBOutlet weak var AddTimeButton : UIButton!
    @IBOutlet weak var RemoveTimeButton : UIButton!
    
    @IBOutlet weak var AddSyllabusTxt: UITextField!
    @IBOutlet weak var AddSyllabusLbl: UILabel!
    
    @IBOutlet weak var RemoveSyllabusTitleLbl: UILabel!
    @IBOutlet weak var RemoveSyllabusLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        AddButton.layer.cornerRadius = 5
        AddButton.clipsToBounds = true
        RemoveButton.layer.cornerRadius = 5
        RemoveButton.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        
        if(textField == AddMarkTxt){
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            
            
            let currentCharacterCount = textField.text?.count ?? 0
            
            if (range.length + range.location > currentCharacterCount)
            {
                return false
            }
            
            let newLength = currentCharacterCount + string.count - range.length
            
            
            if(newLength == 5)
            {
                textField.resignFirstResponder()
            }
            
            
            return string == numberFiltered
        }
        
        return true;
        
        
    }
    
}
