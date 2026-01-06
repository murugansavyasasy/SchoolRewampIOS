import UIKit

class MarkReviewTVC: UITableViewCell {

    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var markTxt: UITextField!

    private var rowIndex = 0
    private var columnIndex = 0
    private var hasFlaggedIssue = false
    weak var parentVC: MarkReviewVC?
    weak var delegate: MarkReviewTVCDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextField()
        setupInfoButton()
        setupTitleLabel()
    }
    
    private func setupTextField() {

        markTxt.delegate = self
        markTxt.textAlignment = .center
        markTxt.borderStyle = .roundedRect
        markTxt.placeholder = "--"
        markTxt.font = .systemFont(ofSize: 15)
        markTxt.keyboardType = .numberPad
        markTxt.layer.cornerRadius = 8

        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
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

        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done,
                                     target: markTxt,
                                     action: #selector(UITextField.resignFirstResponder))

        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                  target: nil,
                                  action: nil)

        toolbar.items = [
            abBtn,
            space(4),
            upBtn,
            space(4),
            downBtn,
            space(4),
            leftBtn,
            space(4),
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

        let button = UIButton(type: .system)

        let height: CGFloat = 36
        let minWidth: CGFloat = 44

        button.frame = CGRect(x: 0, y: 0, width: minWidth, height: height)

        if let title = title {
            button.setTitle(title, for: .normal)
            button.backgroundColor = .systemOrange
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        } else if let imageName = imageName {
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            button.setImage(UIImage(systemName: imageName,
                                    withConfiguration: config),
                            for: .normal)
            button.backgroundColor = .systemBlue
        }

        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
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
                   parentVC: MarkReviewVC?,
                   hasFlaggedIssue: Bool = false) {
        
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
        self.parentVC = parentVC
        self.hasFlaggedIssue = hasFlaggedIssue
        tittleLbl.isHidden = true
        markTxt.isHidden = false
        markTxt.text = mark
        markTxt.textAlignment = alignment
        markTxt.layer.borderWidth = 0
        markTxt.borderStyle = .none
        markTxt.backgroundColor = .clear
        infoBtn.isHidden = true
        
        if let changemark = channgeMark, !changemark.isEmpty {
            tittleLbl.text = "was : \(changemark)"
            tittleLbl.isHidden = false
            markTxt.textColor = .systemGreen
            markTxt.layer.borderWidth = 2
            markTxt.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.4).cgColor
            markTxt.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            markTxt.borderStyle = .roundedRect
            infoBtn.isHidden = false
            infoBtn.tintColor = .systemGreen
            markTxt.font = UIFont.systemFont(ofSize: 15)
            markTxt.isUserInteractionEnabled = true
            return 
        }
        
        if hasFlaggedIssue {
            markTxt.textColor = .orange
            markTxt.layer.borderWidth = 2
            markTxt.layer.borderColor = UIColor.orange.withAlphaComponent(0.4).cgColor
            markTxt.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
            markTxt.borderStyle = .roundedRect
            infoBtn.isHidden = false
            infoBtn.tintColor = .orange
            markTxt.font = UIFont.systemFont(ofSize: 15)
            markTxt.isUserInteractionEnabled = true
            return
        }
        if let markValue = Int(mark), !mark.isEmpty, markValue > 100 {
            markTxt.textColor = .orange
            markTxt.layer.borderWidth = 2
            markTxt.layer.borderColor = UIColor.orange.cgColor
            markTxt.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
            markTxt.borderStyle = .roundedRect
            infoBtn.isHidden = false
            infoBtn.tintColor = .systemRed
            markTxt.font = UIFont.systemFont(ofSize: 15)
            markTxt.isUserInteractionEnabled = true
            return
        }

        markTxt.backgroundColor = UIColor.systemGray6
        markTxt.textColor = .label
        markTxt.font = UIFont.systemFont(ofSize: 15)
        markTxt.isUserInteractionEnabled = true
        markTxt.borderStyle = .roundedRect
        infoBtn.isHidden = true
        markTxt.layer.borderWidth = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        markTxt.text = ""
        markTxt.textColor = .label
        markTxt.font = UIFont.systemFont(ofSize: 15)
        markTxt.isUserInteractionEnabled = true
        markTxt.borderStyle = .roundedRect
        markTxt.textAlignment = .center
        markTxt.resignFirstResponder()
        markTxt.layer.borderWidth = 0
        infoBtn.isHidden = true
        hasFlaggedIssue = false
    }
}

// MARK: - UITextFieldDelegate

extension MarkReviewTVC: UITextFieldDelegate {
    
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
        delegate?.markDidChange(row: rowIndex,
                                column: columnIndex,
                                value: value,
                                reason: reason)
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        if !string.isEmpty {
            let allowed = CharacterSet.decimalDigits
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
        if "AB" == updatedText{
            reason = "Absent"
        }
        applyValidationUI(mark: updatedText,
                          maxMark: parentVC?.subjectColumns[columnIndex].maxMarks ?? 0)
        delegate?.markDidChange(row: rowIndex,
                                column: columnIndex,
                                value: updatedText,
                                reason: reason)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func applyValidationUI(mark: String, maxMark: Int) {
        let trimmed = mark.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
//            showErrorUI()
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
        markTxt.borderStyle = .roundedRect
        infoBtn.isHidden = true
        markTxt.layer.borderWidth = 0
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        parentVC?.activeTextField = textField
    }
}

// MARK: - Toolbar Actions

extension MarkReviewTVC {
    
    @objc func upTapped() {
        parentVC?.moveToPreviousRow(row: rowIndex, column: columnIndex)
    }
    
    @objc func downTapped() {
        parentVC?.moveToNextRow(row: rowIndex, column: columnIndex)
    }
    
    @objc func leftTapped() {
        parentVC?.moveToPreviousColumn(row: rowIndex, column: columnIndex)
    }
    
    @objc func rightTapped() {
        parentVC?.moveToNextColumn(row: rowIndex, column: columnIndex)
    }
    
    @objc func abTapped() {
        markTxt.text = "AB"
        delegate?.markDidChange(row: rowIndex,
                                column: columnIndex,
                                value: "AB",
                                reason: "Absent")
        parentVC?.moveToNextColumn(row: rowIndex, column: columnIndex)
    }
}


