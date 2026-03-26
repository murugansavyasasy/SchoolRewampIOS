//
//  GatePassTvcell.swift
//  School Chimes
//
//  Created by apple on 23/03/26.
//

import UIKit

class GatePassTvcell: UITableViewCell {
    @IBOutlet weak var studentRollNumberLbl: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var AutjorizedByLbl: UILabel!
    @IBOutlet weak var validUntilLbl: UILabel!
    @IBOutlet weak var validFromLbl: UILabel!
    @IBOutlet weak var floorLbl: UILabel!
    @IBOutlet weak var roomNumberLbl: UILabel!
    @IBOutlet weak var reasonLbl: UILabel!
    @IBOutlet weak var exitingTimeLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var purposeContainer: UIView!
    @IBOutlet weak var statusContainer: UIView!
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var studentNameLbl: UILabel!
    private let dashedLineLayer = CAShapeLayer()
    // Background half-circles (The "ticket" cutouts on left and right)
    private let leftCutout: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.96, alpha: 1) // Matches ViewController background
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let rightCutout: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.96, alpha: 1) // Matches ViewController background
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
       
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.25
        contentView.layer.shadowOffset = CGSize(width: 0, height: 10)
        contentView.layer.shadowRadius = 20
        contentView.layer.masksToBounds = false

        cardView.layer.cornerRadius = 16
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
    
    
    func configure(with data: GatePass?) {
        studentRollNumberLbl.text = data?.admission_no
        reasonLbl.text = data?.reason
        validUntilLbl.text = data?.fromdate_todate
        floorLbl.text = data?.floor_no
        roomNumberLbl.text = data?.room_no
        validFromLbl.text = data?.request_time?.convertToTargetDateFormat()
        validUntilLbl.text = data?.request_time?.convertToTargetDateFormat()
        AutjorizedByLbl.text = data?.action_by
    }
  
}
