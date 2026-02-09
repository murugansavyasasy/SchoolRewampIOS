//
//  LsrwListShowTableViewCell.swift
//  VoicesnapSchoolApp
//
//  Created by Chandhru on 30/06/25.
//
import UIKit

class TestTVC: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var optionsStack: UIStackView!
    @IBOutlet weak var outerView: UIView!
    // MARK: - Properties
    var selectedOptionIndex: Int?
    var test: TestQuestion? {
        didSet {
            configureOptions()
        }
    }

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        optionsStack.axis = .vertical
        optionsStack.spacing = 8
        optionsStack.distribution = .fill
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        selectedOptionIndex = nil
        optionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }

    // MARK: - Configure Options
    private func configureOptions() {
        questionLbl.text = test?.question
        optionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard let options = test?.options else { return }

        for (index, option) in options.enumerated() {
            let optionView = createOptionView(text: option, index: index)
            optionsStack.addArrangedSubview(optionView)
        }
    }

    private func createOptionView(text: String, index: Int) -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 8
        container.alignment = .center

        let icon = UIButton(type: .system)
        icon.setImage(UIImage(systemName: selectedOptionIndex == index ? "circle.inset.filled" : "circle"), for: .normal)
        icon.tintColor = .systemBlue
        icon.tag = index
        icon.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
        icon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 24).isActive = true

        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)

        container.addArrangedSubview(icon)
        container.addArrangedSubview(label)

        return container
    }

    // MARK: - Actions
    @objc private func optionSelected(_ sender: UIButton) {
        selectedOptionIndex = sender.tag
        configureOptions() // Refresh UI
    }
}
