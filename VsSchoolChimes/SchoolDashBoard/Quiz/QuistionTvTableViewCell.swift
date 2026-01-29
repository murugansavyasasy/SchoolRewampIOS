//
//  QuistionTvTableViewCell.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 19/08/25.
//

import UIKit
protocol QuestionCellDelegate: AnyObject {
    func addAnotherCell(at indexPath: IndexPath)
    func updateQuestion(at indexPath: IndexPath, model: QuizQuestiondata)
    func removeCell(at indexPath: IndexPath)
    func checkboxAction(id : String, isSelected: Bool)
    func updateQuestionOptionImage(at indexPath: IndexPath, image: UIImage?, type: OptionType)
}

@available(iOS 14.0, *)
class QuistionTvTableViewCell: UITableViewCell,UITextViewDelegate, UITextFieldDelegate, DeleteImge {
    func deleteImage(index: Int) {
        file_path.remove(at: index)
        QuestionImageCv.imageCollectionview.reloadData()
        if file_path.count == 0{
            collectionViewHeight.constant = 0
        }
    }
    
    @IBOutlet weak var addFileBtnName: UIButton!
    @IBOutlet weak var OptionAImgBtn: UIButton!
    @IBOutlet weak var OptionBImgBtn: UIButton!
    @IBOutlet weak var OptionCImgBtn: UIButton!
    @IBOutlet weak var OptionDImgBtn: UIButton!
    @IBOutlet weak var QuestionImageCv: ImageSelection!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var optionDView: UIView!
    @IBOutlet weak var optionCView: UIView!
    @IBOutlet weak var optionBview: UIView!
    @IBOutlet weak var optionAView: UIView!
    @IBOutlet weak var optionAImageView: UIImageView!
    @IBOutlet weak var optionBImageView: UIImageView!
    @IBOutlet weak var optionCImageView: UIImageView!
    @IBOutlet weak var optionDImageView: UIImageView!
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
    var options = [MenuStringFile.optionA.translated(), MenuStringFile.optionB.translated(), MenuStringFile.optionC.translated(), MenuStringFile.optionD.translated()]
    var answerIndex: Int?
    private var placeholderLabels: [UITextView: UILabel] = [:]
    weak var parentVC: UIViewController?
    let  video = "video"
    var selectedOption: OptionType?
    var A_option: String?
    var B_option: String?
    var C_option: String?
    var D_option: String?
    var file_path: [FilePath] = []
    weak var parentTableView: UITableView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionViewHeight.constant = 0
        setupUI()
        imageSelection()
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
    
    
    func imageSelection() {
        // 1️⃣ CAMERA IMAGE
        PhotoPickerManager.shared.onCameraImagePicked = { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async { [self] in
                // Backend
                let fp = FilePath(url: image.toBase64(), type: CommonStringFile.IMAGE)
                self.file_path.append(fp)
                // UI reload
                self.reloadAttachmentUI()
                // Update parent VC
                if let indexPath = self.indexPath {
                    self.delegate?.updateQuestion(at: indexPath, model: self.captureModel())
                }
            }
        }
        // 2️⃣ MULTIPLE IMAGES
        PhotoPickerManager.shared.onImagesPicked = { [weak self] images in
            guard let self = self else { return }
            DispatchQueue.main.async { [self] in
                for img in images {
                    self.file_path.append(
                        FilePath(url: img.toBase64(), type: CommonStringFile.IMAGE))
                }
                self.reloadAttachmentUI()
                if let indexPath = self.indexPath {
                    self.delegate?.updateQuestion(at: indexPath, model: self.captureModel())
                }
            }
        }
        // 3️⃣ DOCUMENT PDF/DOC
        PhotoPickerManager.shared.onFilePicked = { [weak self] url in
            guard let self = self else { return }
            DispatchQueue.main.async { [self] in
                let base64 = self.fileURLToBase64(url)
                let ext = url.pathExtension.lowercased()
                self.file_path.append(
                    FilePath(url: base64, type: CommonStringFile.pdf)
                )
                self.reloadAttachmentUI()
                if let indexPath = self.indexPath {
                    self.delegate?.updateQuestion(at: indexPath, model: self.captureModel())}
            }
        }
        // 4️⃣ VIDEO
        PhotoPickerManager.shared.onVideoPicked = { [weak self] url in
            guard let self = self else { return }
            DispatchQueue.main.async { [self] in
                let base64 = self.videoToBase64(url)
                self.file_path.append(
                    FilePath(url: base64, type: CommonStringFile.VIDEO)
                )
                self.reloadAttachmentUI()
                if let indexPath = self.indexPath {
                    self.delegate?.updateQuestion(at: indexPath, model: self.captureModel())
                }
            }
        }
    }
    
    func reloadAttachmentUI() {
        QuestionImageCv.imageCollectionview.reloadData()
        let totalItems = self.file_path.count
        self.collectionViewHeight.constant =
        totalItems <= 2
        ? 120
        : self.calculatedCollectionHeight()
        self.contentView.layoutIfNeeded()
        parentTableView?.beginUpdates()
        parentTableView?.endUpdates()
    }
    
    
    func calculatedCollectionHeight() -> CGFloat {
        let items = file_path.count
        guard items > 0 else { return 0 }
        
        let columns = 3
        let itemHeight: CGFloat = 100
        let lineSpacing: CGFloat = 10
        let sectionInsets: CGFloat = 20 // top + bottom
        
        let rows = ceil(CGFloat(items) / CGFloat(columns))
        
        return (rows * itemHeight)
        + ((rows - 1) * lineSpacing)
        + sectionInsets
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
        addAnotherName.setTitle(MenuStringFile.addQuestion.translated(), for: .normal)
        OptionAImgBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        OptionBImgBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        OptionCImgBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        OptionDImgBtn.setTitleFont(style: .body, size: FontSize.BodySize)
        addFileBtnName.setTitleFont(style: .body, size: FontSize.BodySize)
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
        markTxtFild.placeholder = MenuStringFile.dropYourMarkHere.translated()
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
        QuestionImageCv.imageCollectionview.delegate = self
        QuestionImageCv.imageCollectionview.dataSource = self
        QuestionImageCv.imageCollectionview.backgroundColor = .clear
    }
    
    func setPlaceholder(_ placeholder: String, for textView: UITextView) {
        if let existing = placeholderLabels[textView] {
            existing.text = placeholder
            return
        }
        let label = UILabel()
        label.text = placeholder
        label.font = textView.font
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(label)
        placeholderLabels[textView] = label
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 6),
            label.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -6)
        ])
    }
    func updatePlaceholderVisibility(for textView: UITextView) {
        let label = placeholderLabels[textView]
        label?.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        updatePlaceholderVisibility(for: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updatePlaceholderVisibility(for: textView)
    }
    
    func configureCell(
        with model: QuizQuestiondata,
        isLast: Bool,
        numberofQuestion:Int,
        totalQuestion:Int
    ) {
        ChapterTxtFld.text = model.chapter
        markTxtFild.text   = model.mark == nil ? "" : "\(model.mark ?? 0)"
        opATxtView.text = model.a_option
        opBTxtView.text = model.b_option
        opCTxtView.text = model.c_option
        opDTxtView.text = model.d_option
        questionTxtView.text = model.question
        setPlaceholder(MenuStringFile.enterOptionA.translated(), for: opATxtView)
        setPlaceholder(MenuStringFile.enterOptionB.translated(), for: opBTxtView)
        setPlaceholder(MenuStringFile.enterOptionC.translated(), for: opCTxtView)
        setPlaceholder(MenuStringFile.enterOptionD.translated(), for: opDTxtView)
        setPlaceholder(MenuStringFile.enterQuestionHere.translated(), for: questionTxtView)
        [opATxtView, opBTxtView, opCTxtView, opDTxtView, questionTxtView].forEach {
            updatePlaceholderVisibility(for: $0)
        }
        if let answerStr = model.answer,
           let answerIndex = Int(answerStr),
           answerIndex > 0,
           answerIndex <= options.count {
            correctAnsLbl.text = options[answerIndex - 1]
        } else {
            correctAnsLbl.text = MenuStringFile.selectCorrectAnswer.translated()
        }
        if let attachments = model.q_file_path, !attachments.isEmpty {
            self.file_path  = attachments
            self.QuestionImageCv.imageCollectionview.reloadData()
            DispatchQueue.main.async {
                let totalItems = self.file_path.count
                self.collectionViewHeight.constant =
                totalItems <= 2 ? 120 :
                self.QuestionImageCv.imageCollectionview.collectionViewLayout.collectionViewContentSize.height
            }
        } else {
            collectionViewHeight.constant = 0
        }
        if model.a_image != ""{
            selectedOption = .optionA
            assignOptionImage(nil, url: model.a_image)
        }else{
            optionAImageView.isHidden = true
            
        }
        if model.b_image != ""{
            selectedOption = .optionB
            assignOptionImage(nil, url: model.b_image)
        }else{
            optionBImageView.isHidden = true
        }
        if model.c_image != ""{
            selectedOption = .optionC
            assignOptionImage(nil, url: model.c_image)
        }else{
            optionCImageView.isHidden = true
        }
        if model.d_image != ""{
            selectedOption = .optionD
            assignOptionImage(nil, url: model.d_image)
        }else{
            optionDImageView.isHidden = true
        }
        
        if totalQuestion == numberofQuestion {
            addAnotherName.isHidden = true
        }else {
            addAnotherName.isHidden = true//!(isLast)
        }
        checkBoxBtn.isHidden = true
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
            correctAnsLbl.text = MenuStringFile.selectCorrectAnswer.translated()
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
            correct_answer_text: correctAnswerText,
            q_file_path : self.file_path,
            a_image: A_option ?? "",
            b_image: B_option ?? "",
            c_image: C_option ?? "",
            d_image: D_option ?? "",
            ques_no: String((indexPath?.row ?? 0) + 1 )
            
        )
    }
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility(for: textView)
        if let index = indexPath {
            delegate?.updateQuestion(at: index, model: captureModel())
        }
        if let tableView =  self.parentTableView {
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
        addAnotherName.isHidden = true//!isLast
    }
    
    @IBAction func AddAnotherAct(_ sender: UIButton) {
        if let index = indexPath {
            delegate?.updateQuestion(at: index, model: captureModel())
        }
        if let index = indexPath {
            A_option = ""
            B_option = ""
            C_option = ""
            D_option = ""
            delegate?.addAnotherCell(at: index)
        }
    }
    
    @IBAction func OptionAImgBtnAct(_ sender: UIButton) {
        DispatchQueue.main.async { [self] in
            if optionAImageView.image != nil {
                optionAImageView.image = nil
                A_option = ""
                optionAView.isHidden = true
                sender.setTitle("Add Image", for: .normal)
                if let table =  self.parentTableView {
                    table.beginUpdates()
                    table.endUpdates()
                }
                return
            }
            // Else pick new image
            selectedOption = .optionA
            openOptionImagePicker()
        }
    }
    
    @IBAction func OptionBImgBtnAct(_ sender: UIButton) {
        DispatchQueue.main.async { [self] in
            if optionBImageView.image != nil {
                optionBImageView.image = nil
                B_option = ""
                optionBview.isHidden = true
                sender.setTitle("Add Image", for: .normal)
                if let table = self.parentTableView {
                    table.beginUpdates()
                    table.endUpdates()
                }
                return
            }
            // Else pick new image
            selectedOption = .optionB
            openOptionImagePicker()
        }
    }
    
    @IBAction func OptionCImgBtnAct(_ sender: UIButton) {
        DispatchQueue.main.async { [self] in
            if optionCImageView.image != nil {
                optionCImageView.image = nil
                C_option = ""
                optionCView.isHidden = true
                sender.setTitle("Add Image", for: .normal)
                if let table =  self.parentTableView {
                    table.beginUpdates()
                    table.endUpdates()
                }
                return
            }
            // Else pick new image
            selectedOption = .optionC
            openOptionImagePicker()
        }
    }
    
    @IBAction func OptionDImgBtnAct(_ sender: UIButton) {
        DispatchQueue.main.async { [self] in
            if optionDImageView.image != nil {
                optionDImageView.image = nil
                D_option = ""
                optionDView.isHidden = true
                sender.setTitle("Add Image", for: .normal)
                if let table =  self.parentTableView {
                    table.beginUpdates()
                    table.endUpdates()
                }
                return
            }
            // Else pick new image
            selectedOption = .optionD
            openOptionImagePicker()
        }
    }
    
    func openOptionImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = ["public.image"]
        parentViewControllers?.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            assignOptionImage(image, url: "")
            picker.dismiss(animated: true)
            return
        }
        
        picker.dismiss(animated: true)
    }
    
    @IBAction func QuestionImageBtnAct(_ sender: UIButton) {
        guard let parentVC = parentVC else {
            print("❌ parentVC is nil")
            return
        }
        let remaining = Filecount.SelectImageAndDocumetCount - file_path.count
        if remaining > 0 {
            let alertController = UIAlertController(title: AlertstringFile.Select.translated(), message: AlertstringFile.Chooseanoption.translated(), preferredStyle: .actionSheet)
            // Camera option
            let cameraAction = UIAlertAction(title: CommonStringFile.Camera, style: .default) { [self] _ in
                openCamera()
            }
            alertController.addAction(cameraAction)
            // Gallery option
            let galleryAction = UIAlertAction(title: CommonStringFile.Photos, style: .default) { [self] _ in
                selectImages()//
            }
            alertController.addAction(galleryAction)
            
            let pdfAction = UIAlertAction(title: CommonStringFile.Document, style: .default) { [self] _ in
                selectDocuments()
            }
            alertController.addAction(pdfAction)
            //   VIDEO option
            let VideoAction = UIAlertAction(title:
                                                CommonStringFile.Video, style: .default) { [self] _ in
                
                let totalRemaining = Filecount.SelectImageAndDocumetCount - file_path.count
                let videoCount = file_path.filter { $0.type?.lowercased() == video }.count
                let videoRemaining = Filecount.SelectVideoCount - videoCount
                if totalRemaining <= 0 {
                    CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: parentVC)
                } else if videoRemaining <= 0 {
                    CustomAlert()
                        .showAlert(
                            title: "",
                            message: CommonStringFile.You_can_only_select_up_to2_video_files,
                            on: parentVC)
                }else{
                    VideoPick()
                }
            }
            alertController.addAction(VideoAction)
            // Cancel action
            let cancelAction = UIAlertAction(
                title: CommonStringFile.Cancel,
                style: .cancel,
                handler: nil
            )
            alertController.addAction(cancelAction)
            parentViewController?.present(alertController, animated: true, completion: nil)
        }else{
            CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on:parentVC)
        }
    }
    
    
    func selectImages() {
        guard let parentVC = parentVC else {
            print("❌ parentVC is nil")
            return
        }
        let remaining = 10 - file_path.count
        if remaining > 0 {
            let limit = max(remaining , 0)
            if limit > 0 {
                PhotoPickerManager.shared.presentPicker(ofType: .gallery(selectionLimit: limit), from: parentVC)
            } else {
                CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: parentVC)
            }
        } else {
            CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: parentVC)
        }
    }
    func openCamera() {
        guard let parentVC = parentVC else {
            print("❌ parentVC is nil")
            return
        }
        PhotoPickerManager.shared.presentPicker(ofType: .camera, from: parentVC)
    }
    func selectDocuments() {
        guard let parentVC = parentVC else {
            print("❌ parentVC is nil")
            return
        }
        let remaining = 10 - file_path.count
        if remaining > 0 {
            PhotoPickerManager.shared.limiSelection = remaining
            PhotoPickerManager.shared.presentPicker(ofType: .file, from: parentVC)
        } else {
            CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: parentVC)
        }
    }
    func VideoPick() {
        guard let parentVC = parentVC else {
            print("❌ parentVC is nil")
            return
        }
        let totalRemaining = 10 - file_path.count
        let videoCount = file_path.filter { $0.type?.lowercased() == video }.count
        let videoRemaining = 2 - videoCount
        if totalRemaining <= 0 {
            CustomAlert().showAlert(title: "", message: AlertstringFile.Already_Reach_Your_Limit, on: parentVC)
        } else if videoRemaining <= 0 {
            CustomAlert().showAlert(title: "", message: "", on: parentVC)
        } else {
            let pickLimit = min(totalRemaining, videoRemaining)
            PhotoPickerManager.shared.limiSelection = pickLimit
            PhotoPickerManager.shared.presentPicker(ofType: .video, from: parentVC)
        }
    }
    
    @IBAction func addAttachAct(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: AlertstringFile.addAttachment,
                                            message: AlertstringFile.Choose_file_type,
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: AlertstringFile.Gallery, style: .default, handler: { _ in
            self.openPicker(type: .image)
        }))
        actionSheet.addAction(UIAlertAction(title: AlertstringFile.Video, style: .default, handler: { _ in
            self.openPicker(type: .video)
        }))
        actionSheet.addAction(UIAlertAction(title: AlertstringFile.Document, style: .default, handler: { _ in
            self.openDocumentPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: AlertstringFile.Cancel, style: .cancel))
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

@available(iOS 14.0, *)
extension QuistionTvTableViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    enum PickerType { case image, video }
    func openPicker(type: PickerType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = type == .image ? ["public.image"] : ["public.movie"]
        parentViewControllers?.present(picker, animated: true)
    }
    func openDocumentPicker() {
        let docTypes = [
            FileTypeConstants.publicData,
            FileTypeConstants.publicContent,
            FileTypeConstants.adobePDF,
            FileTypeConstants.publicText
        ]
        let picker = UIDocumentPickerViewController(documentTypes: docTypes, in: .import)
        picker.delegate = self
        parentViewControllers?.present(picker, animated: true)
    }
    
    // MARK: - Document Picker Delegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        let file = FilePaths(
            fileName: url.lastPathComponent,
            fileURL: url,
            fileType: .document
        )
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

@available(iOS 14.0, *)
extension QuistionTvTableViewCell: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CellConfingName.ImageCvCell,
            for: indexPath
        ) as! ImageCvCell
        
        cell.delegate = self
        cell.deleteBtn.tag = indexPath.row
        cell.imageViews.tintColor = .clear
        cell.imageViews.image = nil  // reset
        // ---------------------------------------------------------------------
        // 1️⃣ Base64 (Local converted data always first priority)
        // ---------------------------------------------------------------------
        let item = file_path[indexPath.item]
        if item.isBase64 {
            if item.type == "image",
               let data = Data(base64Encoded: item.url ?? ""),
               let img = UIImage(data: data) {
                cell.imageViews.image = img
                return cell
            }
            if item.type == "pdf" {
                cell.imageViews.image = UIImage(named: "pdf (1)")
                return cell
            }
            if item.type == "txt"{
                cell.imageViews.image = UIImage(named: "txt-file")
                return cell
            }
            if item.type == "rtf"{
                cell.imageViews.image = UIImage(named: "rtf-file")
                return cell
            }
            if item.type == "doc"{
                cell.imageViews.image = UIImage(named: "microsoft-word")
                return cell
            }
            if item.type == "xls"{
                cell.imageViews.image = UIImage(named: "exel")
                return cell
            }
            if item.type == "ppt" || item.type == "pptx"{
                cell.imageViews.image = UIImage(named: "ppt")
                return cell
            }
            if item.type == "document" {
                cell.imageViews.image = UIImage(named: "doc_icon")
                return cell
            }
            if item.type == "video" {
                cell.imageViews.image = UIImage(named: "video (1)")
                return cell
            }
        }
        
        else {
            if let url = URL(string: item.url ?? "") {
                if item.type  == CommonStringFile.IMAGE || item.type == "image" {
                    cell.imageViews.kf.setImage(with: url)
                }else{
                    let iconName = getFileIconName(for: url)
                    cell.imageViews.image = UIImage(named: iconName)
                }
            }
        }
        return cell
    }
    func base64ToImage(_ base64: String) -> UIImage? {
        guard let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return file_path.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (QuestionImageCv.imageCollectionview.frame.width - 30) / 3
        return CGSize(width: width, height: 100)
    }
    
    
    func assignOptionImage(_ image: UIImage?, url: String?) {
        guard let index = indexPath, let option = selectedOption else { return }
        
        DispatchQueue.main.async {
            let isRemote =
            url?.lowercased().hasPrefix("http://") == true ||
            url?.lowercased().hasPrefix("https://") == true
            
            switch option {
            case .optionA:
                self.optionAView.isHidden = false
                self.OptionAImgBtn.setTitle("Remove Image", for: .normal)
                
                if isRemote {
                    self.optionAImageView.kf.setImage(with: URL(string: url ?? ""))
                    self.A_option = url ?? ""   // URL saving
                } else if let img = image {
                    self.optionAImageView.isHidden = false
                    self.optionAImageView.image = img
                    self.A_option = img.toBase64()  // base64 saving
                }
                
            case .optionB:
                self.optionBview.isHidden = false
                self.OptionBImgBtn.setTitle("Remove Image", for: .normal)
                
                if isRemote {
                    self.optionBImageView.kf.setImage(with: URL(string: url ?? ""))
                    self.B_option = url ?? ""
                } else if let img = image {
                    self.optionBImageView.isHidden = false
                    self.optionBImageView.image = img
                    self.B_option = img.toBase64()
                }
                
            case .optionC:
                self.optionCView.isHidden = false
                self.OptionCImgBtn.setTitle("Remove Image", for: .normal)
                
                if isRemote {
                    self.optionCImageView.kf.setImage(with: URL(string: url ?? ""))
                    self.C_option = url ?? ""
                } else if let img = image {
                    self.optionCImageView.isHidden = false
                    self.optionCImageView.image = img
                    self.C_option = img.toBase64()
                }
                
            case .optionD:
                self.optionDView.isHidden = false
                self.OptionDImgBtn.setTitle("Remove Image", for: .normal)
                
                if isRemote {
                    self.optionDImageView.kf.setImage(with: URL(string: url ?? ""))
                    self.D_option = url ?? ""
                } else if let img = image {
                    self.optionDImageView.isHidden = false
                    self.optionDImageView.image = img
                    self.D_option = img.toBase64()
                }
            }
            // Update table layout
            if let table =  self.parentTableView {
                table.beginUpdates()
                table.endUpdates()
            }
            // Notify parent VC
            self.delegate?.updateQuestion(at: index, model: self.captureModel())
        }
    }
    
    func fileURLToBase64(_ url: URL) -> String? {
        if let data = try? Data(contentsOf: url) {
            return data.base64EncodedString()
        }
        return nil
    }
    func videoToBase64(_ url: URL) -> String? {
        if let data = try? Data(contentsOf: url) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    
}
enum OptionType {
    case optionA, optionB, optionC, optionD
}

struct QuizAttachmentItem {
    var image: UIImage?         // for local images
    var imageURL: String?       // for remote
    var fileType: String
    var VideoURl : URL?// "image", "pdf", etc.
    var VimeoVideoURL : String?
    var displayName : String?
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
extension UIImage {
    func toBase64() -> String? {
        return self.jpegData(compressionQuality: 0.7)?
            .base64EncodedString()
    }
}
