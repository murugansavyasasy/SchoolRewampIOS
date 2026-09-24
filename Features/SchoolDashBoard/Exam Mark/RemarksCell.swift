//
//  RemarksCell.swift
//  School Chimes
//
//  Created by Lakshmanan on 04/09/26.
//

import UIKit

class RemarksCell: UICollectionViewCell {
    @IBOutlet weak var textBaseView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var sepratorLbl: UILabel!
    @IBOutlet weak var infoBtn: UIButton!
    
    
    private var rowIndex = 0
    private var columnIndex = 0
    weak var parentVC: EnterMarkVC?
    weak var delegate: MarksCellDelegate?
    private var commonRemarks: [CommonRemarks] = []
    private let remarksDropDown = DropDown()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textBaseView.layer.cornerRadius = 8
        textBaseView.layer.borderColor = UIColor.lightGray.cgColor
        textBaseView.layer.borderWidth = 0.5
        
        textField.delegate = self
        textField.inputAccessoryView = buildAccessoryView()
    }
    
    func configure(
        Remark: String,
        rowIndex: Int,
        columnIndex: Int,
        parentVC: EnterMarkVC?,
        is_edit: Bool,
        commonRemarks: [CommonRemarks]
    ) {
        
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
        self.parentVC = parentVC
        self.commonRemarks = commonRemarks
        
        textField.isHidden = false
        textField.text = Remark
        textField.isEnabled = is_edit
        textField.isUserInteractionEnabled = is_edit
        textBaseView.backgroundColor = is_edit ? .systemGray6 : .systemGray5
        textField.textColor = is_edit ? .label : .darkGray
        dropDownBtn.isHidden = !is_edit
        
        updateRemarksUI(isEdit: is_edit)
    }

    private func updateRemarksUI(isEdit: Bool) {

        // MARK: - Info Button

        let shouldShowInfo = shouldShowInfoButton(
            for: textField.text ?? ""
        )

        infoBtn.alpha = shouldShowInfo ? 1.0 : 0.0
        infoBtn.isUserInteractionEnabled = shouldShowInfo

        // MARK: - Dropdown Button

        let referenceType =
            parentVC?.subjectColumns[columnIndex].activityId ?? ""

        let hasDropdownData: Bool

        if referenceType == "REMARK" {

            hasDropdownData = commonRemarks.contains {
                guard let value = $0.academic_remarks else {
                    return false
                }

                return !value
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
            }

        } else if referenceType == "BEHAVIOURAL_REMARK" {

            hasDropdownData = commonRemarks.contains {
                guard let value = $0.behavioural_remarks else {
                    return false
                }

                return !value
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
            }

        } else {

            hasDropdownData = false
        }

        let showDropdown = isEdit && hasDropdownData

        dropDownBtn.alpha = showDropdown ? 1.0 : 0.0
        dropDownBtn.isUserInteractionEnabled = showDropdown

        sepratorLbl.alpha = showDropdown ? 1.0 : 0.0
    }

    private func shouldShowInfoButton(for text: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedText.isEmpty else {
            return false
        }

//        // Available width inside the text field
//        let availableWidth = textField.bounds.width
//            - textField.leftViewRect(forBounds: textField.bounds).width
//            - textField.rightViewRect(forBounds: textField.bounds).width
//            - 16 // horizontal padding
//
//        guard availableWidth > 0 else {
//            return false
//        }
//
//        let textWidth = (trimmedText as NSString).size(
//            withAttributes: [
//                .font: textField.font ?? UIFont.systemFont(ofSize: 16)
//            ]
//        ).width
//
//        return textWidth > availableWidth
        
        return true
    }
    
    @IBAction func infoBtn(_ sender: Any) {

        let remark = textField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !remark.isEmpty else {
            return
        }

        let popoverVC = PopoverViewVC(
            nibName: nil,
            bundle: nil
        )

        popoverVC.configureButtons(
            with: [
                ("", remark, .systemBlue)
            ],
            type: .symbol
        )

        let (width, height) = calculatePopoverSize(for: remark)

        popoverVC.preferredContentSize = CGSize(
            width: width,
            height: height
        )

        showPopover(
            from: sender as! UIView,
            contentVC: popoverVC
        )
    }
    
    private func calculatePopoverSize(for text: String) -> (width: CGFloat, height: CGFloat) {

        let maxWidth: CGFloat = 400
        let minWidth: CGFloat = 120

        let boundingRect = (text as NSString).boundingRect(
            with: CGSize(
                width: maxWidth - 40,
                height: .greatestFiniteMagnitude
            ),
            options: .usesLineFragmentOrigin,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16)
            ],
            context: nil
        )

        let textWidth = boundingRect.width + 70

        let finalWidth = max(
            minWidth,
            min(textWidth, maxWidth)
        )

        let finalHeight = boundingRect.height + 40

        return (
            width: finalWidth,
            height: finalHeight
        )
    }

    private func showPopover(
        from sender: UIView,
        contentVC: PopoverViewVC
    ) {

        contentVC.modalPresentationStyle = .popover

        if let popover = contentVC.popoverPresentationController {

            popover.sourceView = sender
            popover.sourceRect = sender.bounds
            popover.permittedArrowDirections = .any
            popover.delegate = self
            popover.backgroundColor = .white
        }

        if UIDevice.current.userInterfaceIdiom == .phone {
            contentVC.modalPresentationStyle = .overFullScreen
            contentVC.view.backgroundColor = .white
        }

        parentVC?.present(
            contentVC,
            animated: true
        )
    }
    
    @IBAction func dropDownBtn(_ sender: Any) {
        
        guard dropDownBtn.alpha > 0 else {
            return
        }
        
        guard !commonRemarks.isEmpty else {
            return
        }
        
        guard !commonRemarks.isEmpty else {
            return
        }
        
        let referenceType =
        parentVC?.subjectColumns[columnIndex].activityId ?? ""
        
        let options: [String]
        
        if referenceType == "REMARK" {
            
            options = commonRemarks.compactMap {
                guard let value = $0.academic_remarks,
                      !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                else {
                    return nil
                }
                
                return value
            }
            
        } else if referenceType == "BEHAVIOURAL_REMARK" {
            
            options = commonRemarks.compactMap {
                guard let value = $0.behavioural_remarks,
                      !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                else {
                    return nil
                }
                
                return value
            }
            
        } else {
            
            options = []
        }
        
        guard !options.isEmpty else {
            return
        }
        
        showRemarksDropdown(options: options)
        
    }
    
    private func showRemarksDropdown(options: [String]) {
        remarksDropDown.dataSource = options
        remarksDropDown.anchorView = dropDownBtn
        remarksDropDown.direction = .bottom

        remarksDropDown.bottomOffset = CGPoint(
            x: 0,
            y: dropDownBtn.bounds.height
        )

        remarksDropDown.width = max(
            250,
            contentView.bounds.width
        )

        // Allow long text to wrap into multiple lines
        remarksDropDown.cellHeight = 60

        remarksDropDown.customCellConfiguration = { index, item, cell in
            cell.optionLabel.font = UIFont.systemFont(ofSize: 14)
            cell.optionLabel.numberOfLines = 0
            cell.optionLabel.lineBreakMode = .byWordWrapping
        }

        remarksDropDown.selectionAction = { [weak self] index, item in
            guard let self = self else {
                return
            }

            self.textField.text = item

            let shouldShowInfo = self.shouldShowInfoButton(for: item)

            self.infoBtn.alpha = shouldShowInfo ? 1.0 : 0.0
            self.infoBtn.isUserInteractionEnabled = shouldShowInfo

            self.sendSelectedRemark(item)
        }

        remarksDropDown.show()
    }
    
    private func sendSelectedRemark(_ value: String) {

        let subjectName =
            parentVC?.subjectColumns[columnIndex].subjectName ?? ""

        delegate?.updateMark(
            row: rowIndex,
            column: columnIndex,
            value: value,
            reson: "",
            subjectName: subjectName
        )
    }
    
}

extension RemarksCell: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {

        let value = textField.text ?? ""

        let subjectName =
            parentVC?.subjectColumns[columnIndex].subjectName ?? ""

        delegate?.updateMark(
            row: rowIndex,
            column: columnIndex,
            value: value,
            reson: "",
            subjectName: subjectName
        )
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        let currentText = textField.text ?? ""

        guard let textRange = Range(
            range,
            in: currentText
        ) else {
            return true
        }

        let updatedText = currentText.replacingCharacters(
            in: textRange,
            with: string
        )
        
        DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                let shouldShowInfo = self.shouldShowInfoButton(
                    for: updatedText
                )

                self.infoBtn.alpha = shouldShowInfo ? 1.0 : 0.0
                self.infoBtn.isUserInteractionEnabled = shouldShowInfo
            }


        let subjectName =
            parentVC?.subjectColumns[columnIndex].subjectName ?? ""

        delegate?.updateMark(
            row: rowIndex,
            column: columnIndex,
            value: updatedText,
            reson: "",
            subjectName: subjectName
        )

        return true
    }

    func textFieldShouldReturn(
        _ textField: UITextField
    ) -> Bool {

        textField.resignFirstResponder()

        return true
    }
}

extension RemarksCell {
    
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
        
        let buttons: [UIButton] = [
           
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
        doneButton.addTarget(textField,
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
            config.contentInsets = NSDirectionalEdgeInsets(top: 8,leading: 14,bottom: 8,trailing: 14)
            
        } else {
            config.image = UIImage(systemName: imageName ?? "")
            config.baseBackgroundColor = .systemBlue
            config.baseForegroundColor = .white
            config.cornerStyle = .capsule
            config.preferredSymbolConfigurationForImage =
            UIImage.SymbolConfiguration(pointSize: 15,weight: .bold)
            config.contentInsets = NSDirectionalEdgeInsets(top: 8,leading: 8,bottom: 8,trailing: 8)
        }
        
        let button = UIButton(configuration: config)
        if title == nil {
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 36),
                button.heightAnchor.constraint(equalToConstant: 36)
            ])
        }
        button.addTarget(self,action: action,for: .touchUpInside)
        
        return button
    }
    
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
}
extension RemarksCell: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle( for controller: UIPresentationController ) -> UIModalPresentationStyle {
        
        return .none
    }
}
