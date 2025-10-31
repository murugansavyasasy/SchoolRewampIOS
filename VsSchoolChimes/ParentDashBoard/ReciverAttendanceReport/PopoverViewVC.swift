//
//  PopoverViewVC.swift
//  School Chimes
//
//  Created by Chandhru on 30/10/25.
//

import UIKit

class PopoverViewVC: UIViewController {
    
    @IBOutlet weak var overallStack: UIStackView!
    
    enum PopoverType {
        case badge   // P, A, OD, LA, -
        case symbol  // SF Symbols like checkmark.circle
    }
    
    // Store the configuration data
    private var configData: [(symbol: String, title: String, color: UIColor)]?
    private var configType: PopoverType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        
        // Configure if data was set
        if let data = configData, let type = configType {
            setupButtons(with: data, type: type)
        }
    }
    
    // Public method to set configuration before view loads
    func configureButtons(with data: [(symbol: String, title: String, color: UIColor)], type: PopoverType) {
        self.configData = data
        self.configType = type
        
        // If view is already loaded, configure immediately
        if isViewLoaded {
            setupButtons(with: data, type: type)
        }
    }
    
    // Private method that does the actual setup
    private func setupButtons(with data: [(symbol: String, title: String, color: UIColor)], type: PopoverType) {
        // Clear existing
        overallStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for item in data {
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.alignment = .center
            hStack.spacing = 10
            let iconView = UIView()
            iconView.translatesAutoresizingMaskIntoConstraints = false
            
            switch type {
            case .badge:
                // Rounded text badge style
                let label = UILabel()
                label.text = item.symbol
                label.textAlignment = .center
                label.textColor = .white
                label.font = .boldSystemFont(ofSize: 13)
                label.backgroundColor = item.color
                label.layer.cornerRadius = 8
                label.clipsToBounds = true
                label.translatesAutoresizingMaskIntoConstraints = false
                
                iconView.addSubview(label)
                
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: iconView.leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: iconView.trailingAnchor),
                    label.topAnchor.constraint(equalTo: iconView.topAnchor),
                    label.bottomAnchor.constraint(equalTo: iconView.bottomAnchor),
                    iconView.widthAnchor.constraint(equalToConstant: 32),
                    iconView.heightAnchor.constraint(equalToConstant: 24)
                ])
                
            case .symbol:
                // SF Symbol style
                let imageView = UIImageView()
                let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
                imageView.image = UIImage(systemName: item.symbol, withConfiguration: config)
                imageView.tintColor = item.color
                imageView.contentMode = .scaleAspectFit
                imageView.translatesAutoresizingMaskIntoConstraints = false
                
                iconView.addSubview(imageView)
                
                NSLayoutConstraint.activate([
                    imageView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor),
                    imageView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
                    imageView.widthAnchor.constraint(equalToConstant: 24),
                    imageView.heightAnchor.constraint(equalToConstant: 24),
                    iconView.widthAnchor.constraint(equalToConstant: 28),
                    iconView.heightAnchor.constraint(equalToConstant: 28)
                ])
            }
            
            let titleLabel = UILabel()
            titleLabel.text = item.title
            titleLabel.textColor = .label
            titleLabel.font = .systemFont(ofSize: 15)
            
            hStack.addArrangedSubview(iconView)
            hStack.addArrangedSubview(titleLabel)
            overallStack.addArrangedSubview(hStack)
        }
    }
}
