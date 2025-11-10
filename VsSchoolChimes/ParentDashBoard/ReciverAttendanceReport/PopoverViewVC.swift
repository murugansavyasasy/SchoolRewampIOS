//
//  PopoverViewVC.swift
//  School Chimes
//
//  Created by Chandhru on 30/10/25.
//

import UIKit

class PopoverViewVC: UIViewController {
    @IBOutlet weak var overallStack: UIStackView!

    enum PopoverType { case badge, symbol }

    private var configData: [(symbol: String, title: String, color: UIColor)]?
    private var configType: PopoverType?

    var itemCount: Int { configData?.count ?? 0 }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        
        if let data = configData, let type = configType {
            setupButtons(with: data, type: type)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Force layout pass
        view.layoutIfNeeded()
        
        // Measure actual height the stack wants
        let targetWidth = view.bounds.width
        let fittingSize = overallStack.systemLayoutSizeFitting(
            CGSize(width: 250, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        // Add small padding, and cap at max height
        let maxHeight: CGFloat = 400
        let finalHeight = min(fittingSize.height + 16, maxHeight)
        
        // Update popover size *after* layout
        if preferredContentSize.height != finalHeight {
            preferredContentSize = CGSize(width: targetWidth, height: finalHeight)
            
            // 🔥 Force the popover controller to refresh layout
            if let popover = presentationController?.presentedView {
                popover.setNeedsLayout()
                popover.layoutIfNeeded()
            }
        }
        
        print("✅ Stack calculated height:", fittingSize.height)
    }



    func configureButtons(with data: [(symbol: String, title: String, color: UIColor)], type: PopoverType) {
        self.configData = data
        self.configType = type
        
        if isViewLoaded {
            setupButtons(with: data, type: type)
        }
    }

    private func setupButtons(with data: [(symbol: String, title: String, color: UIColor)], type: PopoverType) {
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
                let imageView = UIImageView()
                let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
                
                if let systemImage = UIImage(systemName: item.symbol, withConfiguration: config) {
                    imageView.image = systemImage
                    imageView.tintColor = item.color
                } else if let assetImage = UIImage(named: item.symbol) {
                    imageView.image = assetImage
                    imageView.tintColor = nil
                }
                
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
