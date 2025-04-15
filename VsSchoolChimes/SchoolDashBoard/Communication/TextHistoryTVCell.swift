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
    
    @IBOutlet weak var sendBtnheight: NSLayoutConstraint!
    @IBOutlet weak var NewImageView: UIImageView!
    @IBOutlet weak var newImageOuterView: UIView!
    @IBOutlet weak var sendBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var DateLabel: ShimmerLabel!
    @IBOutlet weak var MessageTitle: ShimmerLabel!
    @IBOutlet weak var descriptContent: ShimmerLabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var outerview: ShimmerView2!
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
        MessageTitle.removeShimmer()
        DateLabel.removeShimmer()
        DateLabel.setFont(style: .body, size: FontSize.BodySize)
        MessageTitle.setFont(style: .title, size: FontSize.TitleSize)
        descriptContent.setFont(style: .body, size: FontSize.BodySize)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Assuming 'myLabel' is your UILabel
        descriptContent.preferredMaxLayoutWidth = descriptContent.frame.width
        
        configureShimmer()
    }
    
    @IBAction func Select(_ sender: UIButton) {
        delegate?.select(Tittle: MessageTitle.text ?? "selectedText", descriptContent: descriptContent.text ?? "hgdsxgvbdusf")
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureShimmer() {
        
        MessageTitle.removeShimmer()
        descriptContent.removeShimmer()
        DateLabel.removeShimmer()
        outerview.removeShimmer()
    }
}
