//
//  LessonEditTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 18/06/25.
//

import UIKit

@available(iOS 14.0, *)
class LessonEditTV: UITableViewCell, Datepicker {
    
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var TextField: UITextView!
    @IBOutlet weak var DropdownField: TextfieldWithImage!
    @IBOutlet weak var TextFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var DropDownView: UIView!
    @IBOutlet weak var DropdownLbl: UILabel!
    
    let dropDown = DropDown()
    var datePicker: UIDatePicker?
    var currentFieldType: String = ""
    weak var tableView: UITableView?
    var fieldID: String = ""
    var originalValue: String = ""
    
    var onEdit: ((String, String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupDropdownGesture()
    }
    
    private func setupUI() {
        DropdownField.font = UIFont(name: "Poppins-Medium", size: 13)
        TextField.font = UIFont(name: "Poppins-Medium", size: 13)
        DropdownLbl.font = UIFont(name: "Poppins-Medium", size: 13)
        
        TextField.layer.cornerRadius = 8
        TextField.layer.borderWidth = 1
        TextField.layer.borderColor = UIColor.systemGray5.cgColor
        TextField.addDoneButton()
        TextField.delegate = self
        TextField.isScrollEnabled = false
        
        dateBtn.layer.cornerRadius = 6
    }
    
    private func setupDropdownGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDropdownTap))
        DropDownView.addGestureRecognizer(tapGesture)
        DropDownView.isUserInteractionEnabled = true
    }
    
    @objc private func handleDropdownTap() {
        switch currentFieldType {
        case "datepicker":
            showDatePicker()
        case "dropdown":
            dropDown.show()
        default:
            break
        }
    }
    
    // MARK: - Configure Cell
    func configure(with edit: LessonEditData) {
        NameLbl.text = "\(edit.name ?? "") :"
        currentFieldType = edit.field_type ?? ""
        fieldID = edit.field_id ?? edit.id ?? ""
        originalValue = edit.value ?? ""
        
        resetVisibility()
        
        switch edit.field_type {
        case "dropdown":
            configureDropdown(edit)
        case "text":
            configureTextField(edit)
        case "datepicker":
            configureDatePicker(edit)
        default:
            break
        }
    }
    
    private func resetVisibility() {
        TextField.isHidden = true
        DropdownField.isHidden = true
        DropDownView.isHidden = true
        dateBtn.isHidden = true
        dropDownBtn.isHidden = true
    }
    
    // MARK: - Configure Dropdown
    private func configureDropdown(_ edit: LessonEditData) {
        DropDownView.layer.borderWidth = 1
        DropDownView.layer.cornerRadius = 8
        DropDownView.layer.borderColor = UIColor.systemGray5.cgColor
        
        DropDownView.isHidden = false
        dropDownBtn.isHidden = false
        
        DropdownLbl.text = edit.value?.isEmpty == false ? edit.value : "Select Value"
        DropdownField.textColor = edit.value?.isEmpty == false ? UIColor.black : UIColor.systemGray6
        DropdownField.text = edit.value ?? "Select Value"
        
        dropDown.dataSource = edit.field_data ?? []
        dropDown.anchorView = DropDownView
        dropDown.bottomOffset = CGPoint(x: 0, y: DropDownView.frame.height)
        dropDown.selectionAction = { [weak self] index, item in
            guard let self = self else { return }
            self.DropdownLbl.text = item
            if item != self.originalValue {
                self.onEdit?(self.fieldID, item)
            }
        }
        
        applyDisableState(isDisabled: edit.is_disable ?? false, views: [DropDownView])
    }
    
    // MARK: - Configure TextField
    private func configureTextField(_ edit: LessonEditData) {
        TextField.isHidden = false
        TextField.text = edit.value
        TextField.isEditable = !(edit.is_disable ?? false)
        applyDisableState(isDisabled: edit.is_disable ?? false, views: [TextField])
        
        // Dynamic height
        let size = CGSize(width: TextField.frame.width, height: .infinity)
        let estimatedSize = TextField.sizeThatFits(size)
        TextFieldHeight.constant = max(estimatedSize.height, 45)
    }
    
    // MARK: - Configure Date Picker
    private func configureDatePicker(_ edit: LessonEditData) {
        DropDownView.layer.borderWidth = 1
        DropDownView.layer.borderColor = UIColor.systemGray5.cgColor
        DropDownView.layer.cornerRadius = 8
        
        DropDownView.isHidden = false
        dateBtn.isHidden = false
        
        let formatted = convertDate(edit.value ?? "", toFormat: "dd MMM yyyy")
        DropdownLbl.text = formatted
        
        applyDisableState(isDisabled: edit.is_disable ?? false, views: [DropDownView])
    }
    
    // MARK: - Disable/Enable State Styling
    private func applyDisableState(isDisabled: Bool, views: [UIView]) {
        for view in views {
            if isDisabled {
                view.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.8)
                if let textField = view as? UITextView {
                    textField.textColor = .systemGray
                }
                if let textField = view as? UITextField {
                    textField.textColor = .systemGray
                }
                if let label = view as? UILabel {
                    label.textColor = .systemGray
                }
                view.layer.borderColor = UIColor.systemGray4.cgColor
                view.isUserInteractionEnabled = false
            } else {
                view.backgroundColor = .white
                view.layer.borderColor = UIColor.systemGray5.cgColor
                if let textField = view as? UITextView {
                    textField.textColor = .black
                }
                if let textField = view as? UITextField {
                    textField.textColor = .black
                }
                if let label = view as? UILabel {
                    label.textColor = .black
                }
                view.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: - Date Picker
    @objc func showDatePicker() {
        guard let vc = parentViewController else { return }
        let picker = DatePickerVC()
        picker.modalPresentationStyle = .overCurrentContext
        picker.delegate = self
        picker.dateSelection = 2
        picker.date = DropdownLbl.text
        picker.view.backgroundColor = .black.withAlphaComponent(0.6)
        vc.present(picker, animated: false)
    }
    
    func date(date: String) {
        DropdownLbl.text = date
        if date != originalValue {
            let convertedDate = convertDate(date) ?? ""
            onEdit?(fieldID, convertedDate)
        }
    }
}

// MARK: - UITextView Delegate
@available(iOS 14.0, *)
extension LessonEditTV: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        TextFieldHeight.constant = max(estimatedSize.height, 45)
        
        UIView.setAnimationsEnabled(false)
        tableView?.beginUpdates()
        tableView?.endUpdates()
        UIView.setAnimationsEnabled(true)
        
        let newValue = textView.text ?? ""
        if newValue != originalValue {
            onEdit?(fieldID, newValue)
        }
    }
}


import Foundation
import UIKit


@IBDesignable
class PaddedTextField: UITextField {

    // MARK: - Padding
    @IBInspectable var paddingLeft: CGFloat = 10
    @IBInspectable var paddingRight: CGFloat = 10

    // MARK: - Styling
    @IBInspectable var cornerRadius: CGFloat = 10
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var borderColor: UIColor = UIColor.lightGray

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyling()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        applyStyling()
    }

    private func applyStyling() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
    }

    // MARK: - Padding Implementation
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: paddingLeft, bottom: 0, right: paddingRight))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}


@IBDesignable
class TextfieldWithImage: UITextField {

    // MARK: - Padding
    @IBInspectable var paddingLeft: CGFloat = 10
    @IBInspectable var paddingRight: CGFloat = 10

    // MARK: - Styling
    @IBInspectable var cornerRadius: CGFloat = 10
    @IBInspectable var borderWidth: CGFloat = 1.5
    @IBInspectable var borderColor: UIColor = UIColor.systemGray

    // MARK: - Right Image
    @IBInspectable var rightImage: UIImage? {
        didSet {
            updateRightView()
        }
    }

    @IBInspectable var rightImagePadding: CGFloat = 8

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyling()
        updateRightView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        applyStyling()
        updateRightView()
    }

    private func applyStyling() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
    }

    private func updateRightView() {
        guard let image = rightImage else {
            rightView = nil
            rightViewMode = .never
            return
        }

        // Use template rendering to apply tint color
        let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .gray // Make it gray

        let imageSize: CGFloat = 16 // Smaller size
        let containerSize: CGFloat = imageSize + rightImagePadding * 2

        imageView.frame = CGRect(x: rightImagePadding, y: 0, width: imageSize, height: imageSize)

        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerSize, height: containerSize))
        container.addSubview(imageView)

        // Center image inside container
        imageView.center = CGPoint(x: container.bounds.midX, y: container.bounds.midY)

        rightView = container
        rightViewMode = .always
    }


    // MARK: - Padding Implementation
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rightInset = rightView != nil ? (rightView!.frame.width + paddingRight) : paddingRight
        return bounds.inset(by: UIEdgeInsets(top: 0, left: paddingLeft, bottom: 0, right: rightInset))
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}

import UIKit

extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController {
                return vc
            }
            responder = r.next
        }
        return nil
    }
}
