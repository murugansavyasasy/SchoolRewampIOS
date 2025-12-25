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
    weak var parentVC: MarkReviewVC?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupTextField()
        setupInfoButton()
    }
    
    private func setupTextField() {
        markTxt.delegate = self
        markTxt.keyboardType = .numberPad
        markTxt.textAlignment = .center
        markTxt.borderStyle = .roundedRect
        markTxt.placeholder = "--"
        markTxt.addDoneButton()
    }
    
    private func setupInfoButton() {
        infoBtn.isHidden = true // Show only if needed
    }

    
    func configure(mark: String, rowIndex: Int, columnIndex: Int, parentVC: MarkReviewVC?) {
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
        self.parentVC = parentVC
        
        tittleLbl.isHidden = true // We don't need label in mark cells
        markTxt.text = mark
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        markTxt.text = ""
        markTxt.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate

extension MarkReviewTVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let value = textField.text ?? ""
        parentVC?.updateMark(row: rowIndex, column: columnIndex, value: value)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                  replacementString string: String) -> Bool {
        // Allow only numbers
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
