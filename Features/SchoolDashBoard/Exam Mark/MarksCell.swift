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
    override func awakeFromNib() {
        super.awakeFromNib()
        markTxt.delegate = self
        markTxt.textAlignment = .center
        markTxt.cornerRadius(6)
        markTxt.placeholder = "--"
        markTxt.font = .systemFont(ofSize: 15)
        markTxt.keyboardType = .decimalPad
        let toolbar = UIToolbar()
        toolbar.isTranslucent = false
        toolbar.barTintColor = .systemGray6

        // 🔒 Disable toolbar animations (iOS 16+)
        toolbar.layer.actions = [
            "position": NSNull(),
            "bounds": NSNull(),
            "frame": NSNull()
        ]

        toolbar.sizeToFit()

        let abBtn    = UIBarButtonItem(customView: createKeyButton(title: "AB",
                                                                  action: #selector(abTapped)))
        let upBtn    = UIBarButtonItem(customView: createKeyButton(imageName: "arrow.up",
                                                                  action: #selector(upTapped)))
        let downBtn  = UIBarButtonItem(customView: createKeyButton(imageName: "arrow.down",
                                                                  action: #selector(downTapped)))
        let leftBtn  = UIBarButtonItem(customView: createKeyButton(imageName: "arrow.left",
                                                                  action: #selector(leftTapped)))
        let rightBtn = UIBarButtonItem(customView: createKeyButton(imageName: "arrow.right",
                                                                  action: #selector(rightTapped)))

        let doneBtn = UIBarButtonItem(title: "Done",
                                     style: .plain,
                                     target: markTxt,
                                     action: #selector(UITextField.resignFirstResponder))

        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                  target: nil,
                                  action: nil)

        toolbar.items = [
            abBtn,
            space(6),
            upBtn,
            space(6),
            downBtn,
            space(6),
            leftBtn,
            space(6),
            rightBtn,
            flex,
            doneBtn
        ]

        markTxt.inputAccessoryView = toolbar
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

        let button = UIButton(type: .custom)
        let width: CGFloat = 44
        let height: CGFloat = 36
        button.frame = CGRect(x: 0, y: 0, width: width, height: height)

        if let title = title {
            button.setTitle(title, for: .normal)
            button.backgroundColor = .systemOrange
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        } else if let imageName = imageName {
            let config = UIImage.SymbolConfiguration(pointSize: 15,
                                                     weight: .semibold,
                                                     scale: .medium)
            let image = UIImage(systemName: imageName,
                                withConfiguration: config)
            button.setImage(image, for: .normal)
            button.backgroundColor = .systemBlue
        }

        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
        button.adjustsImageWhenHighlighted = false
        button.adjustsImageWhenDisabled = false
        button.showsTouchWhenHighlighted = false
        button.layer.actions = [
            "backgroundColor": NSNull(),
            "transform": NSNull(),
            "bounds": NSNull(),
            "position": NSNull()
        ]

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

            applyHighlight(
                color: .systemGreen,
                infoColor: .systemGreen
            )
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
}
