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
    func updateQuestion(at indexPath: IndexPath, model: QuestionModel)
    func removeCell(at indexPath: IndexPath)
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
    
    weak var delegate: QuestionCellDelegate?
    var indexPath: IndexPath?
    var dropdown = DropDown()
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
    
    
    @IBAction func correctAnsDropDown(){
        
        dropdown.anchorView = correctOptionView
        dropdown.dataSource = [ "A", "B", "C", "D"]
        
        
        dropdown.bottomOffset = CGPoint(x: 0, y:(dropdown.anchorView?.plainView.bounds.height)!)
        
        dropdown.direction = .bottom
        DropDown.appearance().backgroundColor = UIColor.white
        dropdown.show() //7
        
        
        dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            correctAnsLbl.text = item
            
        }
   
    }
    func setupUI() {
        correctOptionView.layer.cornerRadius = 3
        correctOptionView.layer.masksToBounds = true
        correctOptionView.layer.borderWidth = 0.5
        correctOptionView
            .layer.borderColor = UIColor.lightGray.cgColor
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
        fullView.layer.cornerRadius = 5
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
                setupTextView(questionTxtView, placeholder: "Enter Question")
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
                textView.textColor = .label // normal text color (black/white depending on theme)
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.textColor = .lightGray
                switch textView {
                case opATxtView: textView.text = "Enter Option A"
                case opBTxtView: textView.text = "Enter Option B"
                case opCTxtView: textView.text = "Enter Option C"
                case opDTxtView: textView.text = "Enter Option D"
                case questionTxtView: textView.text = "Enter Question"
                default: break
                }
            }
        }
    func captureModel() -> QuestionModel {
        return QuestionModel(
            chapter: ChapterTxtFld.text ?? "",
            marks: markTxtFild.text ?? "",
            optionA: opATxtView.text ?? "",
            optionB: opBTxtView.text ?? "",
            optionC: opCTxtView.text ?? "",
            optionD: opDTxtView.text ?? "",
            question: questionTxtView.text ?? ""
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
    
    func configureCell(isLast: Bool) {
        addAnotherName.isHidden = !isLast
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func AddAnotherAct(_ sender: UIButton) {
        if let index = indexPath {
            delegate?.addAnotherCell(at: index)
        }
    }
    
    @IBAction func addAttachAct(_ sender: Any) {
    }
    
    @IBAction func DeleteBtnAct(_ sender: UIButton) {
        if let index = indexPath {
                delegate?.removeCell(at: index)
            }
    }
    
}
