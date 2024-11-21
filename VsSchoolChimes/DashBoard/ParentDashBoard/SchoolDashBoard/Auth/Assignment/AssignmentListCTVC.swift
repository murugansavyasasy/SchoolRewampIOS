//
//  AssignmentListCTVC.swift
//  VsSchoolChimes
//
//  Created by admin on 21/11/24.
//

import UIKit

class AssignmentListCTVC: UITableViewCell {
    
    @IBOutlet weak var spirelview: SpiralView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Ensure the SpiralView fills the full cell view
        spirelview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spirelview.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            spirelview.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            spirelview.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            spirelview.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
}

class SpiralView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNotebook()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupNotebook()
    }
    
    private func setupNotebook() {
        // Clear previous subviews (if any, for safety)
        self.subviews.forEach { $0.removeFromSuperview() }
        
        // Create notebook background view
        let notebookView = UIView()
        notebookView.backgroundColor = .clear
        notebookView.layer.cornerRadius = 8
        notebookView.layer.borderWidth = 1
        notebookView.layer.borderColor = UIColor.black.cgColor
        notebookView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(notebookView)
        
        // Add constraints to `notebookView` to provide 20 points of padding from all sides
        NSLayoutConstraint.activate([
            notebookView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            notebookView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            notebookView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            notebookView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        ])
        
        // Add galaxy background image
        let backgroundImage = UIImageView()
        backgroundImage.image = UIImage(named: "galaxy_background") // Replace with your image
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        notebookView.addSubview(backgroundImage)
        
        // Add constraints to `backgroundImage` to fill `notebookView`
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: notebookView.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: notebookView.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: notebookView.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: notebookView.bottomAnchor)
        ])
        
        // Add spiral binding
        let spiralWidth: CGFloat = 15
        let spiralHeight: CGFloat = 15
        let numberOfSpirals = 8
        let spiralSpacing: CGFloat = 40
        
        for i in 0..<numberOfSpirals {
            let spiral = UIView()
            spiral.backgroundColor = .black
            spiral.layer.cornerRadius = spiralWidth / 2
            spiral.translatesAutoresizingMaskIntoConstraints = false
            notebookView.addSubview(spiral)
            
            NSLayoutConstraint.activate([
                spiral.leadingAnchor.constraint(equalTo: notebookView.leadingAnchor, constant: 10), // Left margin for spirals
                spiral.widthAnchor.constraint(equalToConstant: spiralWidth),
                spiral.heightAnchor.constraint(equalToConstant: spiralHeight),
                spiral.topAnchor.constraint(equalTo: notebookView.topAnchor, constant: CGFloat(i) * spiralSpacing)
            ])
        }
        
        // Add deer illustration
        let deerImage = UIImageView()
        deerImage.image = UIImage(named: "deer") // Replace with your deer image
        deerImage.contentMode = .scaleAspectFit
        deerImage.translatesAutoresizingMaskIntoConstraints = false
        notebookView.addSubview(deerImage)
        
        // Add constraints to `deerImage` to fill `notebookView`
        NSLayoutConstraint.activate([
            deerImage.leadingAnchor.constraint(equalTo: notebookView.leadingAnchor),
            deerImage.trailingAnchor.constraint(equalTo: notebookView.trailingAnchor),
            deerImage.topAnchor.constraint(equalTo: notebookView.topAnchor),
            deerImage.bottomAnchor.constraint(equalTo: notebookView.bottomAnchor)
        ])
    }
}
