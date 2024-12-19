//
//  ExamsListCVCell.swift
//  VsSchoolChimes
//
//  Created by admin on 17/12/24.
//

import UIKit

class ExamsListCVCell: UICollectionViewCell {

    @IBOutlet weak var deletBtn: UIButton!
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var outerView: UIView!
    var examSchedul:[ExamsSchedule]?
    var finalArray = [ExamsSchedule]()
    var subName: String?
    var scheduDelegate:ScheduleDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        outerView.layer.cornerRadius = 10
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        outerView.layer.shadowRadius = 5
        outerView.layer.shadowOpacity = 0.3
        subjectName.setFont(style: .body, size: FontSize.BodySize)
    }
    @IBAction func deleteBtn(_ sender: UIButton) {
        guard let subjectName = subName else { return }
        
        if let index = finalArray.firstIndex(where: { $0.subjectName == subjectName }) {
            finalArray.remove(at: index)
            scheduDelegate?.schedulSubject(ExamsSchedule: finalArray, delete: true, index: sender.tag)
        } else {
            print("Subject not found in the array.")
        }
    }
}
