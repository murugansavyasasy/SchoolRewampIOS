//
//  TimetableTv.swift
//  TimetableDesignPractice
//
//  Created by Admin on 10/01/25.
//

import UIKit

class TimetableTv: UITableViewCell {
    
    @IBOutlet weak var cellview: UIView!
    @IBOutlet weak var TimeLbl: UILabel!
    @IBOutlet weak var DetailsView: UIView!
    @IBOutlet weak var CheckImgview: UIImageView!
    @IBOutlet weak var SubjectLbl: UILabel!
    @IBOutlet weak var StaffNameLbl: UILabel!
    @IBOutlet weak var DurationLbl: UILabel!
    @IBOutlet weak var hrsType: UILabel!
    var animated = false
    @IBOutlet weak var progrssView: VerticalProgressView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Other view styling
        DetailsView.layer.cornerRadius = 10
        hrsType.layer.cornerRadius = 8
        hrsType.clipsToBounds = true
        DetailsView.layer.borderWidth = 0.5
        DetailsView.layer.borderColor = UIColor.gray.cgColor
    }
    
}

import UIKit

class VerticalProgressView: UIView {
    
    private let trackLayer = CALayer()
    private let progressLayer = CALayer()
    private var currentProgress: Float = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        layer.masksToBounds = true
        
        // Track background
        trackLayer.backgroundColor = UIColor.lightGray.cgColor
        trackLayer.cornerRadius = 2
        layer.addSublayer(trackLayer)
        
        // Progress fill
        progressLayer.backgroundColor = UIColor.systemBlue.cgColor
        progressLayer.cornerRadius = 2
        layer.addSublayer(progressLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackLayer.frame = bounds
        updateProgressLayer()
    }
    
    func setProgress(_ progress: Float, animated: Bool = true) {
        currentProgress = max(0.0, min(1.0, progress))
        progressLayer.backgroundColor = currentProgress >= 1.0 ? UIColor.systemGreen.cgColor : UIColor.systemBlue.cgColor
        updateProgressLayer(animated: animated)
    }
    
    private func updateProgressLayer(animated: Bool = true) {
        let totalHeight = bounds.height
        let progressHeight = CGFloat(currentProgress) * totalHeight
        let newFrame = CGRect(x: 0, y: totalHeight - progressHeight, width: bounds.width, height: progressHeight)
        
        if animated {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.3)
            progressLayer.frame = newFrame
            CATransaction.commit()
        } else {
            progressLayer.frame = newFrame
        }
    }
}

