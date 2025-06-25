//
//  LessonEditTV.swift
//  School Chimes
//
//  Created by Lakshmanan on 18/06/25.
//

import UIKit
import DropDown
@available(iOS 14.0, *)
class LessonEditTV: UITableViewCell, Datepicker {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var NameLbl: UILabel!
    @IBOutlet weak var TextField: UITextView!
    @IBOutlet weak var DropdownField: TextfieldWithImage!
    @IBOutlet weak var TextFieldHeight: NSLayoutConstraint!
    
    let dropDown = DropDown()
    var datePicker: UIDatePicker?
    var currentFieldType: String = ""
    weak var tableView: UITableView?
    var fieldID: String = ""
    var originalValue: String = ""
    
    var onEdit: ((String, String) -> Void)?


        override func awakeFromNib() {
            super.awakeFromNib()

            NameLbl.setFont(style: .title, size: FontSize.TitleSize)
            DropdownField.font = UIFont(name: "Poppins-Medium", size: 13)
            TextField.font = UIFont(name: "Poppins-Medium", size: 13)
            TextField.layer.cornerRadius = 10
            TextField.layer.borderWidth = 1.5
            TextField.layer.borderColor = UIColor.systemGray.cgColor
            TextField.addDoneButton()
            TextField.delegate = self
            TextField.isScrollEnabled = false

            setupDropdownGesture()
        }

        private func setupDropdownGesture() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDropdownTap))
            DropdownField.addGestureRecognizer(tapGesture)
            DropdownField.isUserInteractionEnabled = true
        }

        @objc private func handleDropdownTap() {
            if currentFieldType == "datepicker" {
                showDatePicker()
            } else if currentFieldType == "dropdown" {
                dropDown.show()
            }
        }

    func configure(with edit: LessonEditData) {
        
        NameLbl.text = "\(edit.name ?? "") :"
        currentFieldType = edit.field_type ?? ""
        fieldID = edit.field_id ?? ""
        originalValue = edit.value ?? ""

            switch edit.field_type {
            case "dropdown":
                TextField.isHidden = true
                DropdownField.isHidden = false
                DropdownField.text = edit.value
                DropdownField.isUserInteractionEnabled = !(edit.is_disable ?? false)
                if edit.is_disable ?? false {
                    DropdownField.backgroundColor = .systemGray5
                }else {
                    DropdownField.backgroundColor = .white
                   // DropdownField.layer.borderColor = UIColor.systemGreen.cgColor
                }

                dropDown.dataSource = edit.field_data ?? []
                dropDown.anchorView = DropdownField
                dropDown.bottomOffset = CGPoint(x: 0, y: DropdownField.frame.height)
                dropDown.selectionAction = { [weak self] index, item in
                    self?.DropdownField.text = item
                    
                    if item != self?.originalValue {
                        self?.onEdit?(self?.fieldID ?? "", item)
                       }
                }

            case "text":
                TextField.isHidden = false
                DropdownField.isHidden = true
                TextField.text = edit.value
                TextField.isEditable = !(edit.is_disable ?? false)
                if edit.is_disable ?? false {
                    TextField.backgroundColor = .systemGray5
                    TextField.isUserInteractionEnabled = false
                }else {
                    TextField.backgroundColor = .white
                   // TextField.layer.borderColor = UIColor.systemGreen.cgColor
                }
                // ✅ Adjust height based on content right now (from API)
                    let size = CGSize(width: TextField.frame.width, height: .infinity)
                    let estimatedSize = TextField.sizeThatFits(size)
                    let minHeight: CGFloat = 45
                    TextFieldHeight.constant = max(estimatedSize.height, minHeight)


            case "datepicker":
                TextField.isHidden = true
                DropdownField.isHidden = false
                DropdownField.text = convertDate(edit.value ?? "",toFormat: "dd MMM yyyy")//edit.value
                DropdownField.isUserInteractionEnabled = !(edit.is_disable ?? false)
                DropdownField.addTarget(self, action: #selector(showDatePicker), for: .editingDidBegin)
                if edit.is_disable ?? false {
                    DropdownField.backgroundColor = .systemGray5
                }else {
                    DropdownField.backgroundColor = .white
                   // DropdownField.layer.borderColor = UIColor.systemGreen.cgColor
                }

            default:
                break
            }
        }

    @objc func showDatePicker() {
           guard let vc = parentViewController else { return }

           let picker = DatePickerVC()
           picker.modalPresentationStyle = .overCurrentContext
           picker.delegate = self
           picker.dateSelection = 2
           picker.date = DropdownField.text
           picker.view.backgroundColor = .black.withAlphaComponent(0.6)
           vc.present(picker, animated: false)
       }

       // MARK: - Datepicker delegate method
       func date(date: String) {
           DropdownField.text = date
           if date != originalValue {
               let convertedDate = convertDate(date) ?? ""
               onEdit?(fieldID, convertedDate)
           }
       }
}

@available(iOS 14.0, *)
extension LessonEditTV: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)

        // Set a minimum height of 45
        let minHeight: CGFloat = 45
        TextFieldHeight.constant = max(estimatedSize.height, minHeight)

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
