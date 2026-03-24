//
//  GatePassTvcell.swift
//  School Chimes
//
//  Created by apple on 23/03/26.
//

import UIKit

class GatePassTvcell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var purposeContainer: UIView!
    @IBOutlet weak var statusContainer: UIView!
    @IBOutlet weak var separatorView: UIView!
    
    private let dashedLineLayer = CAShapeLayer()
    
    // Background half-circles (The "ticket" cutouts on left and right)
    private let leftCutout: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 246/255, green: 248/255, blue: 250/255, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let rightCutout: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 246/255, green: 248/255, blue: 250/255, alpha: 1.0)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupStyling()
        dashedLineLayer.frame = separatorView.bounds
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: separatorView.bounds.midY))
        path.addLine(to: CGPoint(x: separatorView.bounds.width, y: separatorView.bounds.midY))
        dashedLineLayer.path = path.cgPath
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupStyling() {
        self.backgroundColor = .clear
        
        // Add cutouts
        insertSubview(leftCutout, aboveSubview: contentView)
        insertSubview(rightCutout, aboveSubview: contentView)
        
        NSLayoutConstraint.activate([
            leftCutout.widthAnchor.constraint(equalToConstant: 32),
            leftCutout.heightAnchor.constraint(equalToConstant: 32),
            leftCutout.centerYAnchor.constraint(equalTo: separatorView.centerYAnchor),
            leftCutout.centerXAnchor.constraint(equalTo: cardView.leadingAnchor),
            
            rightCutout.widthAnchor.constraint(equalToConstant: 32),
            rightCutout.heightAnchor.constraint(equalToConstant: 32),
            rightCutout.centerYAnchor.constraint(equalTo: separatorView.centerYAnchor),
            rightCutout.centerXAnchor.constraint(equalTo: cardView.trailingAnchor)
        ])
        
        // Card styling
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowOffset = CGSize(width: 0, height: 5)
        cardView.layer.shadowRadius = 10
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white
        // Avatar circular
        avatarView.layer.cornerRadius = 30
        avatarView.clipsToBounds = true
        
        // Purpose Container styling
        purposeContainer.layer.borderColor = UIColor(red: 250/255, green: 190/255, blue: 40/255, alpha: 1.0).cgColor
        purposeContainer.layer.borderWidth = 1
        purposeContainer.layer.cornerRadius = 8
        
        // Status styling
        statusContainer.layer.borderColor = UIColor(red: 100/255, green: 220/255, blue: 140/255, alpha: 1.0).cgColor
        statusContainer.layer.borderWidth = 1
        statusContainer.layer.cornerRadius = 8
        
        // Separator dotted
        dashedLineLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        dashedLineLayer.lineWidth = 1
        dashedLineLayer.lineDashPattern = [4, 4]
        dashedLineLayer.fillColor = nil
        separatorView.layer.addSublayer(dashedLineLayer)
    }
    
}
