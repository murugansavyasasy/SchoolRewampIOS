//
//  TextviewTVC.swift
//  School Chimes
//
//  Created by Lakshmanan on 19/03/26.
//

import UIKit

class TextviewTVC: UITableViewCell {

    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var suggestContetTxtView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tittleLbl.setFont(style: .body, size: FontSize.BodySize)
        suggestContetTxtView.layer.cornerRadius = Colornames.CORadius10
        suggestContetTxtView.layer.borderWidth = 1
        suggestContetTxtView.layer.borderColor = UIColor.lightGray.cgColor
        suggestContetTxtView.addDoneButton()
        
        setAttributedText(for: tittleLbl,
                          with: CommonStringFile.any_other_suggestions.translated(),
                          firstString: CommonStringFile.Add_attachment.translated(),
                          secondString: CommonStringFile.Optional.translated(),
                          color1: .black,
                          color2: .lightGray)
        
        tittleLbl.text = CommonStringFile.any_other_suggestions.translated()
    }
}
