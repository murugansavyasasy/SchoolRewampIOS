//
//  MarkReviewTVC.swift
//  School Chimes
//
//  Created by Chandhru on 25/12/25.
//

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

        let keyboard = MarkKeyboardView(frame: CGRect(x: 0, y: 0,
                                                      width: UIScreen.main.bounds.width,
                                                      height: 120))
        keyboard.delegate = self
        markTxt.inputView = keyboard
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
        
        // Subject marks - use markTxt (editable)
        tittleLbl.isHidden = true
        markTxt.isHidden = false
        markTxt.text = mark
        markTxt.textAlignment = alignment
        
        // Subject mark styling
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
        
        // Subject mark styling
        markTxt.borderStyle = .roundedRect
        if hasFlaggedIssue {
            markTxt.textColor = .orange
            markTxt.layer.borderWidth = 2
            markTxt.layer.borderColor = UIColor.orange.withAlphaComponent(0.4).cgColor
            markTxt.layer.cornerRadius = 6
            markTxt.backgroundColor = UIColor.orange.withAlphaComponent(0.1)
            infoBtn.isHidden = false
            infoBtn.tintColor = .orange
            return
        }
        
        // Invalid marks (AB or text-based)
        if mark == "AB" {
            markTxt.textColor = .systemRed
            markTxt.isUserInteractionEnabled = false
            markTxt.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            infoBtn.isHidden = false
            infoBtn.tintColor = .systemRed
            markTxt.layer.borderWidth = 1
            markTxt.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.4).cgColor
        }else {
            // Valid marks - normal styling
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
        }
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

        // Allow only digits
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
            showErrorUI()
            return
        }

        let entered = Int(trimmed) ?? -1
        if entered < 0 || entered > maxMark {
            showErrorUI()
        } else {
            showNormalUI()
        }
    }
    func showErrorUI() {
        markTxt.textColor = .orange
        markTxt.layer.borderWidth = 2
        markTxt.layer.borderColor = UIColor.orange.withAlphaComponent(0.4).cgColor
        markTxt.layer.cornerRadius = 6
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


}
extension MarkReviewTVC {

    func setupKeyboard() {

        markTxt.keyboardType = .numberPad

        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let left   = UIBarButtonItem(title: "⬅️", style: .plain, target: self, action: #selector(prevCol))
        let right  = UIBarButtonItem(title: "➡️", style: .plain, target: self, action: #selector(nextCol))
        let up     = UIBarButtonItem(title: "⬆️", style: .plain, target: self, action: #selector(prevRow))
        let down   = UIBarButtonItem(title: "⬇️", style: .plain, target: self, action: #selector(nextRow))
        let ab     = UIBarButtonItem(title: "AB", style: .done, target: self, action: #selector(setAB))
        let space  = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done   = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTap))

        toolbar.items = [left, right, up, down, space, ab, done]
        markTxt.inputAccessoryView = toolbar
    }

    @objc func prevCol()  { parentVC?.moveToPreviousColumn(row: rowIndex, column: columnIndex) }
    @objc func nextCol()  { parentVC?.moveToNextColumn(row: rowIndex, column: columnIndex) }
    @objc func prevRow()  { parentVC?.moveToPreviousRow(row: rowIndex, column: columnIndex) }
    @objc func nextRow()  { parentVC?.moveToNextRow(row: rowIndex, column: columnIndex) }

    @objc func setAB() {
        markTxt.text = "AB"
        parentVC?.updateMark(row: rowIndex, column: columnIndex, value: "AB", reson: "Absent")
    }

    @objc func doneTap() {
        markTxt.resignFirstResponder()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        parentVC?.activeTextField = textField
    }
}

extension MarkReviewTVC: MarkKeyboardDelegate {

    func didTapAB() {
        markTxt.text = "AB"
        delegate?.markDidChange(row: rowIndex,
                                column: columnIndex,
                                value: "AB",
                                reason: "Absent")
        parentVC?.moveToNextColumn(row: rowIndex, column: columnIndex)
    }

    func didTapLeft()  { parentVC?.moveToPreviousColumn(row: rowIndex, column: columnIndex) }
    func didTapRight() { parentVC?.moveToNextColumn(row: rowIndex, column: columnIndex) }
    func didTapUp()    { parentVC?.moveToPreviousRow(row: rowIndex, column: columnIndex) }
    func didTapDown()  { parentVC?.moveToNextRow(row: rowIndex, column: columnIndex) }
}


protocol MarkKeyboardDelegate: AnyObject {
    func didTapAB()
    func didTapLeft()
    func didTapRight()
    func didTapUp()
    func didTapDown()
}

class MarkKeyboardView: UIView {

    weak var delegate: MarkKeyboardDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGestures()
    }

    private func setupUI() {

        backgroundColor = .systemGray6

        let abBtn = UIButton(type: .system)
        abBtn.setTitle("AB", for: .normal)
        abBtn.titleLabel?.font = .boldSystemFont(ofSize: 20)
        abBtn.backgroundColor = .systemRed.withAlphaComponent(0.1)
        abBtn.layer.cornerRadius = 10
        abBtn.addTarget(self, action: #selector(abTapped), for: .touchUpInside)

        addSubview(abBtn)
        abBtn.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            abBtn.centerXAnchor.constraint(equalTo: centerXAnchor),
            abBtn.centerYAnchor.constraint(equalTo: centerYAnchor),
            abBtn.widthAnchor.constraint(equalToConstant: 120),
            abBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupGestures() {

        let directions: [UISwipeGestureRecognizer.Direction] = [.left,.right,.up,.down]

        for dir in directions {
            let swipe = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(handleSwipe(_:)))
            swipe.direction = dir
            addGestureRecognizer(swipe)
        }
    }

    @objc private func abTapped() {
        delegate?.didTapAB()
    }

    @objc private func handleSwipe(_ g: UISwipeGestureRecognizer) {
        switch g.direction {
        case .left:  delegate?.didTapLeft()
        case .right: delegate?.didTapRight()
        case .up:    delegate?.didTapUp()
        case .down:  delegate?.didTapDown()
        default: break
        }
    }
}
