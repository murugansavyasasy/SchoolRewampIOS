//
//  MarksCell.swift
//  School Chimes
//
//  Created by Chandhru on 07/01/26.
//

import UIKit

// MARK: - Protocol for communicating mark changes
protocol MarksCellDelegate: AnyObject {
    func updateMark(row: Int,
                    column: Int,
                    value: String,
                    reson: String,
                    subjectName: String)
}

class MarksCell: UICollectionViewCell {

    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var markTxt: UITextField!
    
    private var rowIndex = 0
    private var columnIndex = 0
    private var hasFlaggedIssue = false
    weak var delegate: MarksCellDelegate?
    weak var parentVC: EnterMarkVC?
    private var naButton: UIButton?
    override func awakeFromNib() {
        super.awakeFromNib()
        markTxt.delegate = self
        markTxt.textAlignment = .center
        markTxt.cornerRadius(6)
        markTxt.placeholder = "--"
        markTxt.font = .systemFont(ofSize: 15)
        markTxt.keyboardType = .decimalPad

        markTxt.inputAccessoryView = buildAccessoryView()
    }

    private func buildAccessoryView() -> UIView {

        let container = UIView()
        container.frame = CGRect(x: 0,
                                 y: 0,
                                 width: UIScreen.main.bounds.width,
                                 height: 50)
        container.backgroundColor = .systemGray6

        let hairline = UIView()
        hairline.backgroundColor = .separator
        hairline.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(hairline)

        let abButton = createKeyButton(title: "AB", action: #selector(abTapped))

        let naButton = createKeyButton(title: "NA", action: #selector(naTapped))
//        naButton.isHidden = !(parentVC?.uploadTest ?? false)
        self.naButton = naButton

        let buttons: [UIButton] = [
            abButton,
            naButton,
            createKeyButton(imageName: "arrow.up", action: #selector(upTapped)),
            createKeyButton(imageName: "arrow.down", action: #selector(downTapped)),
            createKeyButton(imageName: "arrow.left", action: #selector(leftTapped)),
            createKeyButton(imageName: "arrow.right", action: #selector(rightTapped))
        ]

        let leftStack = UIStackView(arrangedSubviews: buttons)
        leftStack.axis = .horizontal
        leftStack.spacing = 12
        leftStack.alignment = .center
        leftStack.distribution = .fill

        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        doneButton.addTarget(markTxt,
                             action: #selector(UITextField.resignFirstResponder),
                             for: .touchUpInside)

        let spacer = UIView()

        let stack = UIStackView(arrangedSubviews: [
            leftStack,
            spacer,
            doneButton
        ])

        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center

        container.addSubview(stack)

        NSLayoutConstraint.activate([

            hairline.topAnchor.constraint(equalTo: container.topAnchor),
            hairline.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hairline.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hairline.heightAnchor.constraint(equalToConstant: 0.5),

            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)

        ])

        return container
    }



    private func space(_ width: CGFloat) -> UIBarButtonItem {
        let sp = UIBarButtonItem(barButtonSystemItem: .fixedSpace,
                                 target: nil,
                                 action: nil)
        sp.width = width
        return sp
    }

    private func createKeyButton(
        title: String? = nil,
        imageName: String? = nil,
        action: Selector
    ) -> UIButton {

        var config = UIButton.Configuration.filled()

        if let title = title {

            config.title = title
            config.baseBackgroundColor = .systemOrange
            config.baseForegroundColor = .white

            config.cornerStyle = .medium

            config.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 14,
                bottom: 8,
                trailing: 14
            )

        } else {

            config.image = UIImage(
                systemName: imageName ?? ""
            )

            config.baseBackgroundColor = .systemBlue
            config.baseForegroundColor = .white

            config.cornerStyle = .capsule

            config.preferredSymbolConfigurationForImage =
                UIImage.SymbolConfiguration(
                    pointSize: 15,
                    weight: .bold
                )

            config.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            )
        }

        let button = UIButton(configuration: config)

        if title == nil {

            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 36),
                button.heightAnchor.constraint(equalToConstant: 36)
            ])
        }

        button.addTarget(self,
                         action: action,
                         for: .touchUpInside)

        return button
    }

    @objc private func keyDown(_ sender: UIButton) {
        UIView.animate(
            withDuration: 0.14,
            delay: 0,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 0.9,
            options: [.allowUserInteraction],
            animations: {
                sender.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
                sender.layer.shadowOpacity = 0.08
                sender.layer.shadowOffset = CGSize(width: 0, height: 2)
            }
        )
    }

    @objc private func keyUp(_ sender: UIButton) {
        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1.2,
            options: [.allowUserInteraction],
            animations: {
                sender.transform = .identity
                sender.layer.shadowOpacity = 0.18
                sender.layer.shadowOffset = CGSize(width: 0, height: 4)
            }
        )
    }
    
    private func setupInfoButton() {
        infoBtn.isHidden = true
        infoBtn.setImage(UIImage(systemName: "exclamationmark.circle.fill"), for: .normal)
        infoBtn.tintColor = .systemRed
    }
    
    private func setupTitleLabel() {
        tittleLbl.isHidden = true
        tittleLbl.font = UIFont.systemFont(ofSize: 13)
        tittleLbl.textColor = .label
    }
    
    func configure(mark: String,
                   channgeMark: String? = nil,
                   rowIndex: Int,
                   columnIndex: Int,
                   alignment: NSTextAlignment = .center,
                   parentVC: EnterMarkVC?,
                   hasFlaggedIssue: Bool = false,
                   is_edit: Bool,
                   maxMark: Int = 0) {

        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
        self.hasFlaggedIssue = hasFlaggedIssue
        self.parentVC = parentVC
        tittleLbl.isHidden = true
        infoBtn.isHidden = true

        markTxt.isHidden = false
        markTxt.text = mark
        markTxt.textAlignment = alignment
        markTxt.font = UIFont.systemFont(ofSize: 15)
        markTxt.cornerRadius(6)
        markTxt.isEnabled = is_edit
        markTxt.isUserInteractionEnabled = is_edit
        markTxt.backgroundColor = is_edit ? .systemGray6 : .systemGray5
        markTxt.textColor = is_edit ? .label : .darkGray
        markTxt.layer.borderWidth = 0
        markTxt.layer.borderColor = nil
        if let changemark = channgeMark, !changemark.isEmpty {
            tittleLbl.text = "was : \(changemark)"
            tittleLbl.isHidden = false
            applyHighlight(color: .systemGreen,infoColor: .systemGreen)
            return
        }
        if hasFlaggedIssue {
            applyHighlight(
                color: .orange,
                infoColor: .orange
            )
            return
        }
        
        if let markValue = Int(mark),
           !mark.isEmpty,
           markValue > maxMark {

            applyHighlight(
                color: .orange,
                infoColor: .systemRed
            )
            return
        }
        markTxt.inputAccessoryView = buildAccessoryView()
    }

    private func applyHighlight(color: UIColor, infoColor: UIColor) {
        markTxt.textColor = color
        markTxt.backgroundColor = color.withAlphaComponent(0.1)
        markTxt.layer.borderWidth = 2
        markTxt.layer.borderColor = color.withAlphaComponent(0.4).cgColor
        markTxt.isEnabled = true
        markTxt.isUserInteractionEnabled = true
        infoBtn.isHidden = false
        infoBtn.tintColor = infoColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        markTxt.text = ""
        markTxt.textColor = .label
        markTxt.font = UIFont.systemFont(ofSize: 15)
        markTxt.isUserInteractionEnabled = true
        markTxt.cornerRadius(6)
        markTxt.textAlignment = .center
        markTxt.resignFirstResponder()
        markTxt.layer.borderWidth = 0
        infoBtn.isHidden = true
        hasFlaggedIssue = false
        delegate = nil
    }
    
    func applyValidationUI(mark: String, maxMark: Int) {
        let trimmed = mark.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        let entered = Int(trimmed) ?? 0
        if entered > maxMark {
            showErrorUI()
        } else {
            showNormalUI()
        }
    }
    
    func showErrorUI() {
        markTxt.textColor = .orange
        markTxt.layer.borderWidth = 2
        markTxt.layer.borderColor = UIColor.orange.withAlphaComponent(0.4).cgColor
        markTxt.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
        infoBtn.isHidden = false
        infoBtn.tintColor = .orange
    }
    
    func showNormalUI() {
        markTxt.backgroundColor = UIColor.systemGray6
        markTxt.textColor = .label
        markTxt.font = UIFont.systemFont(ofSize: 15)
        markTxt.isUserInteractionEnabled = true
        markTxt.cornerRadius(6)
        infoBtn.isHidden = true
        markTxt.layer.borderWidth = 0
    }
}
extension MarksCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let value = textField.text ?? ""
        var reason = ""
        var isValid = true

        if let maxStr = parentVC?.subjectColumns[columnIndex].maxMarks,
           let entered = Int(value),
           entered > maxStr {
            isValid = false
            reason = "Maximum mark exceeded"
        }
        
        let subjectName = parentVC?.subjectColumns[columnIndex].subjectName ?? ""
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        if !string.isEmpty {
            let allowed = CharacterSet(charactersIn: "0123456789.")
            let set = CharacterSet(charactersIn: string)
            if !allowed.isSuperset(of: set) { return false }
        }
        
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        var reason = ""
        var isValid = true

        if let max = parentVC?.subjectColumns[columnIndex].maxMarks,
           let entered = Int(updatedText),
           entered > max {
            isValid = false
            reason = "Maximum mark exceeded"
        }
        
        if updatedText == "AB" {
            reason = "Absent"
        }
        
        applyValidationUI(mark: updatedText,
                          maxMark: parentVC?.subjectColumns[columnIndex].maxMarks ?? 0)
        let subjectName = parentVC?.subjectColumns[columnIndex].subjectName ?? ""
        delegate?.updateMark(row: rowIndex,
                             column: columnIndex,
                             value: updatedText,
                             reson: reason,
                             subjectName: subjectName)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension MarksCell {
    
    @objc private func upTapped() {
        parentVC?.moveToPreviousRow(row: rowIndex, column: columnIndex)
    }

    @objc private func downTapped() {
        parentVC?.moveToNextRow(row: rowIndex, column: columnIndex)
    }

    @objc private func leftTapped() {
        parentVC?.moveToPreviousColumn(row: rowIndex, column: columnIndex)
    }

    @objc private func rightTapped() {
        parentVC?.moveToNextColumn(row: rowIndex, column: columnIndex)
    }

    
    @objc private func abTapped() {
        markTxt.text = "AB"
        let subjectName = parentVC?.subjectColumns[columnIndex].subjectName ?? ""
        delegate?.updateMark(row: rowIndex,
                             column: columnIndex,
                             value: "AB",
                             reson: "Absent",
                             subjectName: subjectName)
        parentVC?.moveToNextColumn(row: rowIndex, column: columnIndex)
    }
    @objc private func naTapped() {
        markTxt.text = "NA"
        let subjectName = parentVC?.subjectColumns[columnIndex].subjectName ?? ""
        delegate?.updateMark(row: rowIndex,
                             column: columnIndex,
                             value: "NA",
                             reson: "Not Applicable",
                             subjectName: subjectName)
        parentVC?.moveToNextColumn(row: rowIndex, column: columnIndex)
    }
}
