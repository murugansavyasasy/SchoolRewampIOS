import UIKit

class MarkReviewTVC: UITableViewCell {

    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var tittleLbl: UILabel!
    @IBOutlet weak var markTxt: UITextField!

    private var rowIndex = 0
    private var columnIndex = 0
    private var isEditable = true
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
        markTxt.font = UIFont.systemFont(ofSize: 15)
        markTxt.keyboardType = .numberPad
        markTxt.layer.cornerRadius = 8

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let abBtn    = UIBarButtonItem(customView: createKeyButton(title: "AB", action: #selector(abTapped)))
        let upBtn    = UIBarButtonItem(customView: createKeyButton(imageName: "arrow.up", action: #selector(upTapped)))
        let downBtn  = UIBarButtonItem(customView: createKeyButton(imageName: "arrow.down", action: #selector(downTapped)))
        let leftBtn  = UIBarButtonItem(customView: createKeyButton(imageName: "arrow.left", action: #selector(leftTapped)))
        let rightBtn = UIBarButtonItem(customView: createKeyButton(imageName: "arrow.right", action: #selector(rightTapped)))

        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: markTxt, action: #selector(UITextField.resignFirstResponder))
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [
            abBtn,
            space(8),
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
    func space(_ width: CGFloat) -> UIBarButtonItem {
        let sp = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        sp.width = width
        return sp
    }

    private func createKeyButton(title: String? = nil,
                                 imageName: String? = nil,
                                 action: Selector) -> UIButton {

        let button = UIButton(type: .system)

        if let title = title {
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            button.backgroundColor = .systemOrange
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }
        else if let imageName = imageName {
            // 🔷 Arrow Buttons (BLUE)
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
            let image = UIImage(systemName: imageName, withConfiguration: config)
            button.setImage(image, for: .normal)

            button.backgroundColor = UIColor.systemBlue
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 2)
        }

        button.tintColor = .white
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 34)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true

        // Shadow
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 3

        button.addTarget(self, action: action, for: .touchUpInside)
        return button
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
    
    func configure(mark: String,channgeMark: String? = nil,
                   rowIndex: Int,
                   columnIndex: Int,
                   isEditable: Bool,
                   alignment: NSTextAlignment = .center,
                   parentVC: MarkReviewVC?,
                   hasFlaggedIssue: Bool = false) {
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
        self.isEditable = isEditable
        self.parentVC = parentVC
        self.hasFlaggedIssue = hasFlaggedIssue
        tittleLbl.isHidden = true
        markTxt.isHidden = false
        markTxt.text = mark
        markTxt.textAlignment = alignment
        if !isEditable {
            markTxt.textColor = .label
            markTxt.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            markTxt.isUserInteractionEnabled = false
            markTxt.backgroundColor = .clear
            markTxt.borderStyle = .none
            infoBtn.isHidden = true
            markTxt.layer.borderWidth = 0
            return
        }
        if let changemark = channgeMark{
            tittleLbl.text = changemark
            tittleLbl.isHidden = false
            markTxt.textColor = .systemGreen
            markTxt.layer.borderWidth = 2
            markTxt.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.4).cgColor
            markTxt.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            infoBtn.isHidden = false
            infoBtn.tintColor = .systemGreen
        }else{
            tittleLbl.isHidden = true
        }
        markTxt.borderStyle = .roundedRect
        if hasFlaggedIssue {
            markTxt.textColor = .orange
            markTxt.layer.borderWidth = 2
            markTxt.layer.borderColor = UIColor.orange.withAlphaComponent(0.4).cgColor
            markTxt.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
            infoBtn.isHidden = false
            infoBtn.tintColor = .orange
            return
        }
        
//        if mark == "AB" {
//            markTxt.textColor = .systemRed
//            markTxt.isUserInteractionEnabled = false
//            markTxt.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
//            infoBtn.isHidden = false
//            infoBtn.tintColor = .systemRed
//            markTxt.layer.borderWidth = 1
//            markTxt.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.4).cgColor
//        } else {
            markTxt.backgroundColor = UIColor.systemGray6
            markTxt.textColor = .label
            markTxt.font = UIFont.systemFont(ofSize: 15)
            markTxt.isUserInteractionEnabled = true
            markTxt.borderStyle = .roundedRect
            infoBtn.isHidden = true
            markTxt.layer.borderWidth = 0
            
            if let markValue = Int(mark), markValue > 100 {
                markTxt.textColor = .orange
                markTxt.layer.borderWidth = 2
                markTxt.layer.borderColor = UIColor.orange.cgColor
                markTxt.layer.cornerRadius = 6
                markTxt.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
                infoBtn.isHidden = false
                infoBtn.tintColor = .systemRed
            }
//        }
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


