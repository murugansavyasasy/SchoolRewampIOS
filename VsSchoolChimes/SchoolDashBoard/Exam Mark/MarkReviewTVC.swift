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

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextField()
        setupInfoButton()
        setupTitleLabel()
    }
    
    private func setupTextField() {
        markTxt.delegate = self
        markTxt.keyboardType = .numberPad
        markTxt.textAlignment = .center
        markTxt.borderStyle = .roundedRect
        markTxt.placeholder = "--"
        markTxt.font = UIFont.systemFont(ofSize: 15)
        markTxt.addDoneButton()
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
                   hasFlaggedIssue: Bool = false,
                   columnType: ColumnType = .subject) {
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
        self.isEditable = isEditable
        self.parentVC = parentVC
        self.hasFlaggedIssue = hasFlaggedIssue
        
        // Roll number or Student name - use tittleLbl (non-editable)
        if columnType == .rollNumber || columnType == .studentName {
            tittleLbl.isHidden = false
            tittleLbl.text = mark
            tittleLbl.textAlignment = alignment
            tittleLbl.textColor = .label
            tittleLbl.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            
            markTxt.isHidden = true
            markTxt.text = ""
            infoBtn.isHidden = true
            return
        }
        
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
        
        // Check for flagged issues first (highest priority)
        if hasFlaggedIssue {
            markTxt.textColor = .systemRed
            markTxt.layer.borderWidth = 2
            markTxt.layer.borderColor = UIColor.systemRed.cgColor
            markTxt.layer.cornerRadius = 6
            markTxt.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            infoBtn.isHidden = false
            infoBtn.tintColor = .systemRed
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
            markTxt.layer.borderColor = UIColor.systemRed.cgColor
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
                markTxt.textColor = .systemRed
                markTxt.layer.borderWidth = 2
                markTxt.layer.borderColor = UIColor.systemRed.cgColor
                markTxt.layer.cornerRadius = 6
                markTxt.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
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
        parentVC?.updateMark(row: rowIndex, column: columnIndex, value: value)
        print("📝 Mark updated - Row: \(rowIndex), Column: \(columnIndex), Value: \(value)")
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

