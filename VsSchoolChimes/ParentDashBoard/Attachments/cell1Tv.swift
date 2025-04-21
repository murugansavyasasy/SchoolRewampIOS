//
//  cell1Tv.swift
//  VsSchoolChimes
//
//  Created by admin on 26/03/25.
//

import UIKit

class cell1Tv: UITableViewCell {

    @IBOutlet weak var bubleAnimateView: CustomAttachmentView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

@IBDesignable
class CustomAttachmentView: UIView {
    
    @IBInspectable var isSender: Bool = true {
        didSet {
            updateBubbleStyle()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        layer.cornerRadius = 16
        clipsToBounds = true
        updateBubbleStyle()
    }

    private func updateBubbleStyle() {
        backgroundColor = isSender ? UIColor.systemBlue.withAlphaComponent(0.2) : UIColor.systemGray5
    }
}
