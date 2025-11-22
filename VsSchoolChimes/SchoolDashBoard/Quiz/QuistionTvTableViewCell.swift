//
//  QuistionTvTableViewCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 19/08/25.
//

import UIKit
import DropDown
protocol QuestionCellDelegate: AnyObject {
    func addAnotherCell(at indexPath: IndexPath)
    func updateQuestion(at indexPath: IndexPath, model: QuizQuestiondata)
    func removeCell(at indexPath: IndexPath)
    func addAttachment(at indexPath: IndexPath, file: FilePaths)   // ✅ New
    func checkboxAction(id : String, isSelected: Bool)
}



class QuistionTvTableViewCell: UITableViewCell,UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var attachmentBtnName: UIButton!
    @IBOutlet weak var markDefaultLbl: UILabel!
    @IBOutlet weak var CorretDefaultLbl: UILabel!
    @IBOutlet weak var optDDefaultLbl: UILabel!
    @IBOutlet weak var optCDefaultLbl: UILabel!
    @IBOutlet weak var optBDefaultLbl: UILabel!
    @IBOutlet weak var optADefaultLbl: UILabel!
    @IBOutlet weak var QuestionDaultLbl: UILabel!
    @IBOutlet weak var chapterDltLbl: UILabel!
    @IBOutlet weak var fullView: UIView!
    @IBOutlet weak var ChapterTxtFld: UITextField!
    @IBOutlet weak var markTxtFild: UITextField!
    @IBOutlet weak var opDTxtView: UITextView!
    @IBOutlet weak var opCTxtView: UITextView!
    @IBOutlet weak var opBTxtView: UITextView!
    @IBOutlet weak var opATxtView: UITextView!
    @IBOutlet weak var questionTxtView: UITextView!
    @IBOutlet weak var correctAnsLbl: UILabel!
    @IBOutlet weak var correctOptionView: UIView!
    @IBOutlet weak var addAnotherName: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var checkBoxBtn: UIButton!
    @IBOutlet weak var addAnotherStack: UIStackView!
    @IBOutlet weak var dropdownImage: UIImageView!
    
    
    weak var delegate: QuestionCellDelegate?
    var indexPath: IndexPath?
    var dropdown = DropDown()
    var questionId: String?
    var isChecked = false
    var options = [ "Option A".translated(), "Option B".translated(), "Option C".translated(), "Option D".translated()]
    var answerIndex: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        
        let corectAns = UITapGestureRecognizer(
            target: self,
            action:#selector(correctAnsDropDown)
        )
        correctOptionView.addGestureRecognizer(corectAns)
        
    }
    
    
    @IBAction func correctAnsDropDown() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        dropdown.anchorView = correctOptionView
        dropdown.dataSource = options
        dropdown.bottomOffset = CGPoint(x: 0, y: (dropdown.anchorView?.plainView.bounds.height) ?? 0)
        dropdown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropdown.show()

        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            correctAnsLbl.text = item
            answerIndex = index
            if let indexPath = indexPath {
                delegate?.updateQuestion(at: indexPath, model: captureModel())
            }
        }
    }
    
    func setupUI() {
        
        fullView.layer.cornerRadius = 10
        fullView.layer.shadowColor = UIColor.black.cgColor
        fullView.layer.shadowOpacity = 0.3
        fullView.layer.shadowOffset = CGSize(width: 2, height: 2)
        fullView.layer.shadowRadius = 3
        
        correctOptionView.layer.cornerRadius = 3
        correctOptionView.layer.masksToBounds = true
        correctOptionView.layer.borderWidth = 0.5
        correctOptionView.layer.borderColor = UIColor.lightGray.cgColor
        addAnotherName.setTitleFont(style: .body, size: FontSize.BodySize)
        attachmentBtnName.layer.cornerRadius = 10
        attachmentBtnName.setTitleFont(style: .body, size: FontSize.BodySize)
        chapterDltLbl.setRequiredText(QuizListStringFile.Chapter)
        QuestionDaultLbl.setRequiredText(QuizListStringFile.Question)
        optADefaultLbl.setRequiredText(QuizListStringFile.Option_A)
        optBDefaultLbl.setRequiredText(QuizListStringFile.Option_B)
        optCDefaultLbl.setRequiredText(QuizListStringFile.Option_C)
        optDDefaultLbl.setRequiredText(QuizListStringFile.Option_D)
        CorretDefaultLbl.setRequiredText(QuizListStringFile.Correct_Ans)
        markDefaultLbl.setRequiredText(QuizListStringFile.Mark)
        
        markTxtFild.delegate = self
        ChapterTxtFld.delegate = self
        opDTxtView.delegate = self
        opCTxtView.delegate = self
        opBTxtView.delegate = self
        opATxtView.delegate = self
        questionTxtView.delegate = self
        markTxtFild.keyboardType = .numberPad
        opATxtView.addDoneButton()
        markTxtFild.addDoneButton()
        ChapterTxtFld.addDoneButton()
        opBTxtView.addDoneButton()
        opCTxtView.addDoneButton()
        opDTxtView.addDoneButton()
        questionTxtView.addDoneButton()
        opDTxtView.layer.borderWidth = 0.5
        opCTxtView.layer.borderWidth = 0.5
        opBTxtView.layer.borderWidth = 0.5
        opATxtView.layer.borderWidth = 0.5
        questionTxtView.layer.borderWidth = 0.5
        opDTxtView.layer.borderColor = UIColor.lightGray.cgColor
        opCTxtView.layer.borderColor = UIColor.lightGray.cgColor
        opBTxtView.layer.borderColor = UIColor.lightGray.cgColor
        opATxtView.layer.borderColor = UIColor.lightGray.cgColor
        questionTxtView.layer.borderColor = UIColor.lightGray.cgColor
        opDTxtView.layer.cornerRadius = 5
        opCTxtView.layer.cornerRadius = 5
        opBTxtView.layer.cornerRadius = 5
        opATxtView.layer.cornerRadius = 5
        questionTxtView.layer.cornerRadius = 5
        
        setupTextView(opATxtView, placeholder: "Enter Option A")
                setupTextView(opBTxtView, placeholder: "Enter Option B")
                setupTextView(opCTxtView, placeholder: "Enter Option C")
                setupTextView(opDTxtView, placeholder: "Enter Option D")
                setupTextView(questionTxtView, placeholder: "Enter Question here")
    }

   

    private func setupTextView(_ textView: UITextView, placeholder: String) {
            textView.delegate = self
            textView.text = placeholder
            textView.textColor = .lightGray
        
        }
        
        // MARK: - UITextViewDelegate
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == .lightGray {
                textView.text = nil
                textView.textColor = .label
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.textColor = .lightGray
                switch textView {
                case opATxtView: textView.text = "Enter Option A".translated()
                case opBTxtView: textView.text = "Enter Option B".translated()
                case opCTxtView: textView.text = "Enter Option C".translated()
                case opDTxtView: textView.text = "Enter Option D".translated()
                case questionTxtView: textView.text = "Enter Question here".translated()
                default: break
                }
            }
        }
    func configureCell(
        with model: QuizQuestiondata,
        isLast: Bool,
        numberofQuestion:Int,
        totalQuestion:Int
    ) {
        ChapterTxtFld.text = model.chapter
        markTxtFild.text   = model.mark == nil ? "" : "\(model.mark ?? 0)"
        opATxtView.text    = model.a_option.isEmpty ? "Enter Option A".translated() : model.a_option
        opBTxtView.text    = model.b_option.isEmpty ? "Enter Option B".translated() : model.b_option
        opCTxtView.text    = model.c_option.isEmpty ? "Enter Option C".translated() : model.c_option
        opDTxtView.text    = model.d_option.isEmpty ? "Enter Option D".translated() : model.d_option
        questionTxtView.text = model.question.isEmpty ? "Enter Question here".translated() : model.question
        if let answerStr = model.answer,
           let answerIndex = Int(answerStr),
           answerIndex > 0,
           answerIndex <= options.count {
            correctAnsLbl.text = options[answerIndex - 1]
        } else {
            correctAnsLbl.text = "Select correct answer".translated()
        }
        if let attachments = model.file_path, !attachments.isEmpty {
            attachmentBtnName.setTitle("Attachment (\(attachments.count))", for: .normal)
            attachmentBtnName.backgroundColor = .black
            attachmentBtnName.isEnabled = false   // disable click
            attachmentBtnName.alpha = 0.6
        } else {
            attachmentBtnName.setTitle("Add Attachment".translated(), for: .normal)
            attachmentBtnName.backgroundColor = .black
            attachmentBtnName.isEnabled = true
            attachmentBtnName.alpha = 1.0
        }
        
        // "Add Another" logic
        if totalQuestion == numberofQuestion {
            addAnotherName.isHidden = true
        }else {
            
            addAnotherName.isHidden = !(isLast)
        }
       
        checkBoxBtn.isHidden = true
        // Placeholder color setup
        [opATxtView, opBTxtView, opCTxtView, opDTxtView, questionTxtView].forEach { tv in
            if tv?.text?.hasPrefix("Enter".translated()) == true {
                tv?.textColor = .lightGray
            } else {
                tv?.textColor = .label
            }
        }
    }
    
    func configureQuestionBankCell(with model: QuestionItem, isChecked:Bool) {
        ChapterTxtFld.text = model.chapter
        markTxtFild.text   = model.mark == nil ? "" : "\(model.mark ?? 0)"
        opATxtView.text    = model.a_option
        opBTxtView.text    = model.b_option
        opCTxtView.text    = model.c_option
        opDTxtView.text    = model.d_option
        questionTxtView.text = model.question
        if let answerStr = model.answer,
           let answerIndex = Int(answerStr),
           answerIndex > 0,
           answerIndex <= options.count {
            correctAnsLbl.text = options[answerIndex - 1]
        } else {
            correctAnsLbl.text = "Select correct answer".translated()
        }

        
        ChapterTxtFld.backgroundColor = .systemGray6
        markTxtFild.backgroundColor = .systemGray6
        opATxtView.backgroundColor = .systemGray6
        opBTxtView.backgroundColor = .systemGray6
        opCTxtView.backgroundColor = .systemGray6
        opDTxtView.backgroundColor = .systemGray6
        questionTxtView.backgroundColor = .systemGray6
        correctOptionView.backgroundColor = .systemGray6
        
        ChapterTxtFld.isUserInteractionEnabled = false
        markTxtFild.isUserInteractionEnabled = false
        opATxtView.isUserInteractionEnabled = false
        opBTxtView.isUserInteractionEnabled = false
        opCTxtView.isUserInteractionEnabled = false
        opDTxtView.isUserInteractionEnabled = false
        questionTxtView.isUserInteractionEnabled = false
        correctOptionView.isUserInteractionEnabled = false
          
        addAnotherName.isHidden = true
        addAnotherStack.isHidden = true
        attachmentBtnName.isHidden = true
        closeBtn.isHidden = true
        dropdownImage.isHidden = true
        self.isChecked = isChecked
        let image = isChecked ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square")
        checkBoxBtn.setImage(image, for: .normal)
    }
    func captureModel() -> QuizQuestiondata {
        var answerString: String? = nil
        var correctAnswerText: String? = nil
        
        if let idx = answerIndex {
            answerString = String(idx + 1)
            switch idx {
            case 0: correctAnswerText = opATxtView.text
            case 1: correctAnswerText = opBTxtView.text
            case 2: correctAnswerText = opCTxtView.text
            case 3: correctAnswerText = opDTxtView.text
            default: break
            }
        }
        
        return QuizQuestiondata(
            chapter: ChapterTxtFld.text ?? "",
            question: questionTxtView.text ?? "",
            answer: answerString,
            a_option: opATxtView.text ?? "",
            b_option: opBTxtView.text ?? "",
            c_option: opCTxtView.text ?? "",
            d_option: opDTxtView.text ?? "",
            mark: Int(markTxtFild.text ?? ""),
            correct_answer_text: correctAnswerText
        )
    }

    
    func textViewDidChange(_ textView: UITextView) {
        
        if let index = indexPath {
            delegate?.updateQuestion(at: index, model: captureModel())
        }
            // Notify tableView to update layout
            if let tableView = self.superview as? UITableView {
                UIView.setAnimationsEnabled(false)
                tableView.beginUpdates()
                tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
            }
        }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let index = indexPath {
            delegate?.updateQuestion(at: index, model: captureModel())
        }
    }
    
    func configureCell(isLast: Bool) {
        addAnotherName.isHidden = !isLast
    }
    
    @IBAction func AddAnotherAct(_ sender: UIButton) {
        
        if let index = indexPath {
            delegate?.updateQuestion(at: index, model: captureModel())
        }
        
        if let index = indexPath {
            delegate?.addAnotherCell(at: index)
        }
    }
    
    @IBAction func addAttachAct(_ sender: UIButton) {
        
        guard let index = indexPath else { return }
            
            let actionSheet = UIAlertController(title: "Add Attachment",
                                                message: "Choose file type",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Image", style: .default, handler: { _ in
                self.openPicker(type: .image)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { _ in
                self.openPicker(type: .video)
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Document", style: .default, handler: { _ in
                self.openDocumentPicker()
            }))
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            parentViewController?.present(actionSheet, animated: true)
        
    }
    
    @IBAction func DeleteBtnAct(_ sender: UIButton) {
        if let index = indexPath {
                delegate?.removeCell(at: index)
            }
    }
    
    @IBAction func CheckboxtBtnAct(_ sender: Any) {
        
        guard let id = questionId else { return }
        isChecked.toggle()
        let image = isChecked ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square")
        checkBoxBtn.setImage(image, for: .normal)
        delegate?.checkboxAction(id: id, isSelected: isChecked)
    }
    
}

extension QuistionTvTableViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    enum PickerType { case image, video }
    
    func openPicker(type: PickerType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = type == .image ? ["public.image"] : ["public.movie"]
        parentViewControllers?.present(picker, animated: true)
    }
    
    func openDocumentPicker() {
        let docTypes = ["public.data", "public.content", "com.adobe.pdf", "public.text"]
        let picker = UIDocumentPickerViewController(documentTypes: docTypes, in: .import)
        picker.delegate = self
        parentViewControllers?.present(picker, animated: true)
    }
    
    // MARK: - Image/Video Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var file: FilePaths?
        
        if let url = info[.mediaURL] as? URL {
            // Video
            file = FilePaths(fileName: url.lastPathComponent, fileURL: url, fileType: .video)
        } else if let image = info[.originalImage] as? UIImage {
            // Save image temporarily
            if let data = image.jpegData(compressionQuality: 0.8) {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
                try? data.write(to: tempURL)
                file = FilePaths(fileName: tempURL.lastPathComponent, fileURL: tempURL, fileType: .image)
            }
        }
        
        if let file = file, let index = indexPath {
            delegate?.addAttachment(at: index, file: file)
        }
        
        picker.dismiss(animated: true)
    }
    
    // MARK: - Document Picker Delegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        let file = FilePaths(
            fileName: url.lastPathComponent,
            fileURL: url,
            fileType: .document
        )
        
        if let index = indexPath {
            delegate?.addAttachment(at: index, file: file)
        }
    }
}

struct FilePaths: Codable {
    var fileName: String
    var fileURL: URL
    var fileType: FileType
}

enum FileType: String, Codable {
    case image
    case video
    case document
}

extension UIView {
    var parentViewControllers: UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController { return vc }
            responder = responder?.next
        }
        return nil
    }
}

extension CGRect {
    var maxYPoint: CGPoint {
        return CGPoint(x: midX, y: maxY)
    }
}
