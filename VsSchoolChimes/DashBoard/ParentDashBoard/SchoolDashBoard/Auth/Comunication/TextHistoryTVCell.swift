//
//  TextHistoryTVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 16/11/24.
//

import UIKit
protocol SelectedTextDelegate{
    func select(Tittle:String,descriptContent:String)
}
class TextHistoryTVCell: UITableViewCell {
    @IBOutlet weak var descriptContent: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var outerview: UIView!
    var delegate : SelectedTextDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        outerview.layer.shadowColor = UIColor.black.cgColor
        outerview.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerview.layer.shadowRadius = 5
        outerview.layer.shadowOpacity = 0.3
        outerview.layer.cornerRadius = 20
        sendBtn.layer.cornerRadius = 4
    }

    @IBAction func Select(_ sender: UIButton) {
        delegate?.select(Tittle: "selectedText", descriptContent: descriptContent.text ?? "hgdsxgvbdusf")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
