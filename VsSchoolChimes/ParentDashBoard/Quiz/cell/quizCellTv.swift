//
//  quizCellTv.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 05/09/25.
//

import UIKit

class quizCellTv: UITableViewCell {
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var parentFullview: UIView!
    @IBOutlet weak var child2View: UIView!
    @IBOutlet weak var child1View: UIView!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var discretiponsLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var LevelLbl: UILabel!
    @IBOutlet weak var MaxmarkLbl: UILabel!
    @IBOutlet weak var NoOfQuestionLbl: UILabel!
    @IBOutlet weak var createdDateLbl: UILabel!
    @IBOutlet weak var PostByLbl: UILabel!
    @IBOutlet weak var playBtnWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyCardShadow(to: parentFullview)
        applyCardShadow(to: child1View)
        applyCardShadow(to: child2View)
        playBtn.layer.shadowColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1).cgColor // #007AFF
        playBtn.layer.shadowOpacity = 0.2 // 20%
        playBtn.layer.shadowOffset = CGSize(width: 0, height: 2) // Y-offset 2pt
        playBtn.layer.shadowRadius = 6 // Blur = 6pt
        playBtn.layer.masksToBounds = false
        playBtn.layer.cornerRadius = 8
        
    }
    
    func applyCardShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black
            .withAlphaComponent(0.8).cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = CGSize(width: 0, height: 7)
        view.layer.shadowRadius = 10
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 8
    }
    
}

