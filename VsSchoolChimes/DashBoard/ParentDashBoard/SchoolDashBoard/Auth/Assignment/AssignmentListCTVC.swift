//
//  AssignmentListCTVC.swift
//  VsSchoolChimes
//
//  Created by admin on 21/11/24.
//

import UIKit

class AssignmentListCTVC: UITableViewCell {
    
    @IBOutlet weak var imgHeght: NSLayoutConstraint!
    @IBOutlet weak var spirelview: UIView!
    @IBOutlet weak var outImg: UIImageView!
    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var sendByLbl: UILabel!
    @IBOutlet weak var sumissionLbl: UILabel!
    @IBOutlet weak var dueDateLbl: UILabel!
    var stackView: UIStackView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var viewBtn: UIButton!
    var didSelectDelegate : DidSelectDelegate?
    
       override func awakeFromNib() {
           super.awakeFromNib()
           
           spirelview.layer.cornerRadius = 10
           spirelview.layer.shadowColor = UIColor.black.cgColor
           spirelview.layer.shadowOffset = CGSize(width: 0, height: 2)
           spirelview.layer.shadowRadius = 5
           spirelview.layer.shadowOpacity = 0.3
           outImg.translatesAutoresizingMaskIntoConstraints = false
           
//           // Create a vertical stack view
//           stackView = UIStackView()
//           stackView.axis = .vertical
//           stackView.spacing = 20
//           stackView.alignment = .center
//           stackView.distribution = .fillProportionally
//           
//           // Add the stack view to spirelview
//           spirelview.addSubview(stackView)
//           
//           // Set stack view constraints
//           stackView.translatesAutoresizingMaskIntoConstraints = false
//           NSLayoutConstraint.activate([
//               stackView.centerYAnchor.constraint(equalTo: spirelview.centerYAnchor), // Center vertically in spirelview
//               stackView.leadingAnchor.constraint(equalTo: spirelview.leadingAnchor, constant: -5), // Optional leading constraint if needed
//               stackView.widthAnchor.constraint(equalToConstant: 20) // Fixed width for the stack view
//           ])
//           
//           layoutViewHoles()
       }
       
    func layoutViewHoles() {
        // Remove existing arranged subviews (if any)
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        // Calculate the number of viewHole views that fit
        let viewHoleHeight: CGFloat = 15 // Fixed height for each viewHole
        let spacing: CGFloat = 20
        let totalHeight = spirelview.bounds.height
        let maxViews = Int((totalHeight + spacing) / (viewHoleHeight + spacing))
        
        // Create and add viewHole views
        for _ in 0..<maxViews {
            let viewHole = UIView()
            viewHole.translatesAutoresizingMaskIntoConstraints = false
            viewHole.backgroundColor = .clear // Make background clear to show the custom shape
            
            // Create the outer circle with 75% radius
            let outerCirclePath = UIBezierPath(arcCenter: CGPoint(x: viewHoleHeight / 2, y: viewHoleHeight / 2), radius: viewHoleHeight * 0.75 / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            
            // Create the inner circle with 25% radius (for cut-out effect)
            let innerCirclePath = UIBezierPath(arcCenter: CGPoint(x: viewHoleHeight / 2, y: viewHoleHeight / 2), radius: viewHoleHeight * 0.25 / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            
            // Create a path with the outer circle minus the inner circle (cut-out effect)
            outerCirclePath.append(innerCirclePath.reversing())
            
            // Create a shape layer and apply the path
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = outerCirclePath.cgPath
            shapeLayer.fillColor = UIColor.black.cgColor // Set the color of the shape
            
            // Add the shape layer to the viewHole
            viewHole.layer.addSublayer(shapeLayer)
            
            // Set size constraints
            NSLayoutConstraint.activate([
                viewHole.widthAnchor.constraint(equalToConstant: viewHoleHeight),
                viewHole.heightAnchor.constraint(equalToConstant: viewHoleHeight)
            ])
            
            stackView.addArrangedSubview(viewHole)
        }
    }

       
       override func layoutSubviews() {
           super.layoutSubviews()
           // Re-layout the stack view if spirelview's size changes
//           layoutViewHoles()
           let contentViewHeight = contentView.frame.height - 30
           imgHeght.constant = contentViewHeight
       }
    
    @IBAction func viewAssignment(_ sender: UIButton) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            self.didSelectDelegate?.select(index: 1, value: "")
        didSelectDelegate?.select(index: 1, value:"\(sender.tag)",Img:[""],Pdf:"https://icseindia.org/document/sample.pdf",text:"sjedgwvfefjd xuvu dvs dhv sshgdvsg",type:"")
//            }
    }
    @IBAction func submitBtn(_ sender: UIButton) {
    }
    
}
