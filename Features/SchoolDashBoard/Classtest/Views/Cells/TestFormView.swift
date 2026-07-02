//
//  TestFormView.swift
//  School Chimes
//
//  Created by apple on 25/06/26.
//

import UIKit

class TestFormView: UIView,UITextFieldDelegate,UITextViewDelegate {

    @IBOutlet public weak var badgeContainer: UIView!
    @IBOutlet public weak var badgeLabel: UILabel!
    @IBOutlet public weak var testTitleLabel: UILabel!
    @IBOutlet public weak var removeButton: UIButton!
    
    @IBOutlet public weak var examNameTextView: UITextView!
    @IBOutlet public weak var testDateTextField: UITextField!
    
    @IBOutlet public weak var fnButton: UIButton!
    @IBOutlet public weak var anButton: UIButton!
    
    @IBOutlet public weak var maxMarksTextField: UITextField!
    @IBOutlet public weak var minMarksTextField: UITextField!
    @IBOutlet public weak var syllabusTextView: UITextView!

    public var onRemoveTapped : (() -> Void)?
    public var onDataChanged : ((TestDetails) -> Void)?
    
    private var testDetails = TestDetails()
    private let activeColor = UIColor.primery /*UIColor(red: 0.298, green: 0.302, blue: 0.863, alpha: 1.0)*/ // #4C4DDC
    private let inactiveBg = UIColor(red: 0.973, green: 0.976, blue: 0.988, alpha: 1.0)  // #F8F9FC
    private let inactiveText = UIColor(red: 0.392, green: 0.455, blue: 0.545, alpha: 1.0) // #64748B
    private let datePicker = UIDatePicker()
    public override func awakeFromNib(){
        super.awakeFromNib()
        steupUi()
    }
    
    
    private func steupUi(){
      
        styleTextView(examNameTextView)
        styleTextField(testDateTextField)
        styleTextField(maxMarksTextField)
        styleTextField(minMarksTextField)
        styleTextView(syllabusTextView)
        maxMarksTextField.addDoneButton()
        minMarksTextField.addDoneButton()
        examNameTextView.addDoneButton()
        syllabusTextView.addDoneButton()
        badgeContainer.layer.cornerRadius = 12
        badgeContainer.layer.masksToBounds = true
        badgeContainer.backgroundColor = activeColor
        badgeLabel.textColor = .white
        
        fnButton.layer.cornerRadius = 8
        anButton.layer.cornerRadius = 8
        fnButton.layer.masksToBounds = true
        anButton.layer.masksToBounds = true
        
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0).cgColor // #E2E8F0
        self.backgroundColor = .white
        
        examNameTextView.delegate = self
        testDateTextField.delegate  = self
        maxMarksTextField.delegate = self
        minMarksTextField.delegate = self
        syllabusTextView.delegate = self
        
        testDateTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        maxMarksTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
     minMarksTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        setupDatePicker()
    }
    
    public func configure(with details :TestDetails,index:Int,showRemoveButton : Bool ){
        
        self.testDetails = details
        
        badgeLabel.text = "\(index+1)"
        testTitleLabel.text = "Activity \(index+1)"
        
        removeButton.isHidden = !showRemoveButton
        examNameTextView.text = details.examName
        testDateTextField.text = details.testDate
        maxMarksTextField.text = details.maxMarks
        minMarksTextField.text = details.minMarks
        syllabusTextView.text = details.syllabus
        
        updateSessionUI(session: details.session)
        
    }
    
    func configureReport(with activity: StaffActivity, index: Int) {
        
        badgeLabel.text = "\(index + 1)"
        testTitleLabel.text = "Activity \(index + 1)"
        
        examNameTextView.text = activity.activity_name
        testDateTextField.text = activity.exam_date
        maxMarksTextField.text = activity.max_mark
        minMarksTextField.text = activity.min_mark
        syllabusTextView.text = activity.syllabus
        updateSessionUI(session: activity.session ?? "FN")
        
        examNameTextView.isEditable = false
        syllabusTextView.isEditable = false
        
        testDateTextField.isEnabled = false
        maxMarksTextField.isEnabled = false
        minMarksTextField.isEnabled = false
        
        removeButton.isHidden = false
        fnButton.isEnabled = false
        anButton.isEnabled = false
    }
    
    private func styleTextView(_ textView: UITextView) {
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0).cgColor
        textView.backgroundColor = UIColor(red: 0.98, green: 0.985, blue: 1.0, alpha: 1.0)
        
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 8, right: 8)
        textView.adjustsFontForContentSizeCategory = true
    }
    
    private func styleTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(red: 0.886, green: 0.909, blue: 0.941, alpha: 1.0).cgColor
        textField.backgroundColor = UIColor(red: 0.98, green: 0.985, blue: 1.0, alpha: 1.0)
        
        // Add left padding view
        let padView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        textField.leftView = padView
        textField.leftViewMode = .always
        
        textField.adjustsFontForContentSizeCategory = true
    }
    
    private func setupDatePicker() {

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.date = Date()
        datePicker.minimumDate = Date()

        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)

        testDateTextField.inputView = datePicker

        let toolBar = UIToolbar()
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done",
                                         style: .plain,
                                         target: self,
                                         action: #selector(doneButtonTapped))

        toolBar.setItems([UIBarButtonItem.flexibleSpace(), doneButton], animated: false)
        testDateTextField.inputAccessoryView = toolBar
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        testDateTextField.text = formatter.string(from: sender.date)
        textFieldDidChange()
    }
    
    
    @objc private func doneButtonTapped() {

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"

        // Always set the selected date
        testDateTextField.text = formatter.string(from: datePicker.date)

        textFieldDidChange()

        self.endEditing(true)
    }
    
    @IBAction func removeActBtn(_ sender: UIButton) {
        onRemoveTapped?()
    }
    
    @IBAction func FnActBtn(_ sender: Any) {
        updateSessionUI(session: "FN")
        notifyDataChanged()
        
    }
    
    
    @IBAction func anActBtn(_ sender: UIButton) {
        updateSessionUI(session: "AN")
        notifyDataChanged()
    }
    
    private func updateSessionUI(session: String) {
        testDetails.session = session
        if session == "FN" {
            fnButton.backgroundColor = activeColor
            fnButton.setTitleColor(.white, for: .normal)
            anButton.backgroundColor = inactiveBg
            anButton.setTitleColor(inactiveText, for: .normal)
        } else {
            anButton.backgroundColor = activeColor
            anButton.setTitleColor(.white, for: .normal)
            fnButton.backgroundColor = inactiveBg
            fnButton.setTitleColor(inactiveText, for: .normal)
        }
    }
    @objc private func textFieldDidChange() {
        testDetails.testDate = testDateTextField.text ?? ""
        testDetails.activity_name = examNameTextView.text ?? ""
        testDetails.maxMarks =  maxMarksTextField.text ?? ""
        testDetails.minMarks = minMarksTextField.text ?? ""
        testDetails.syllabus = syllabusTextView.text ?? ""
        notifyDataChanged()
    }
    
    private func notifyDataChanged(){
        onDataChanged?(testDetails)
    }
    //MARK: UITextFieldDelegate
    
//    public func textFieldShouldReturn(_ textField:UITextField) -> Bool{
//        textField.resignFirstResponder()
//        return true
//    }
    
    // MARK: - UITextViewDelegate
    public func textViewDidChange(_ textView: UITextView) {
        testDetails.examName = examNameTextView.text ?? ""
        testDetails.syllabus = syllabusTextView.text ?? ""
        notifyDataChanged()
    }
    
//    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
}
