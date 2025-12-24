//
//  CreateQuizQutionVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 19/08/25.
//

import UIKit
extension CreateQuizQutionVc: QuestionCellDelegate {
    
    func checkboxAction(id: String, isSelected: Bool) {
        if isSelected {
            selectedQuestionIds.insert(id)
        } else {
            selectedQuestionIds.remove(id)
        }
        updateSelectAllButtonState()
    }
    
    func addAnotherCell(at indexPath: IndexPath) {
        if let errorMessage = validateQuestions() {
            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Missing_Information, message: errorMessage, on: self)
            return
        }
        questions.insert(QuizQuestiondata(), at: indexPath.row + 1)
        localImages.insert(QuizLocalImages(), at: indexPath.row + 1)
           localAttachments.insert([], at: indexPath.row + 1)

        tv.reloadData()
        self.QuestionNoLbl.text = QuizListStringFile.Question_Limit.translated() + String(self.questions.count) + "/" + String(self.noOfQuestion)
    }
    
    func updateQuestion(at indexPath: IndexPath, model: QuizQuestiondata) {
        var existing = questions[indexPath.row]
        if let existingId = existing.id {
            existing.id = existingId
        }
        if let existingQuizId = existing.quiz_id {
            existing.quiz_id = existingQuizId
        }
        if let newAnswer = model.answer, !newAnswer.isEmpty {
            existing.answer = newAnswer
        }
        if let newText = model.correct_answer_text, !newText.isEmpty {
            existing.correct_answer_text = newText
        }
        existing.chapter = model.chapter
        existing.question = model.question
        existing.a_option = model.a_option
        existing.b_option = model.b_option
        existing.c_option = model.c_option
        existing.d_option = model.d_option
        existing.a_image = model.a_image
        existing.b_image = model.b_image
        existing.c_image = model.c_image
        existing.d_image = model.d_image
        existing.mark = model.mark
        existing.ques_no = model.ques_no
        existing.q_file_path = model.q_file_path
        questions[indexPath.row] = existing
        
    }
    func updateQuestionOptionImage(at indexPath: IndexPath, image: UIImage?, type: OptionType) {

        switch type {
        case .optionA:
            localImages[indexPath.row].a = image
            questions[indexPath.row].a_image = image == nil ? "" : questions[indexPath.row].a_image

        case .optionB:
            localImages[indexPath.row].b = image
            questions[indexPath.row].b_image = image == nil ? "" : questions[indexPath.row].b_image

        case .optionC:
            localImages[indexPath.row].c = image
            questions[indexPath.row].c_image = image == nil ? "" : questions[indexPath.row].c_image

        case .optionD:
            localImages[indexPath.row].d = image
            questions[indexPath.row].d_image = image == nil ? "" : questions[indexPath.row].d_image
        }
    }

    func removeCell(at indexPath: IndexPath) {
        guard questions.count > 1 else { return }
        questions.remove(at: indexPath.row)
        localImages.remove(at: indexPath.row)
           localAttachments.remove(at: indexPath.row)
        tv.reloadData()
        self.QuestionNoLbl.text = QuizListStringFile.Question_Limit.translated() + String(self.questions.count) + "/" + String(self.noOfQuestion)
    }
    
   
    
    func updateQuestionAttachments(at indexPath: IndexPath, attachments: [QuizAttachmentItem]) {
        localAttachments[indexPath.row] = attachments
    }
}

class CreateQuizQutionVc: UIViewController {
    
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var popupBGview: UIView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var ImportQuestionBtn: UIButton!
    @IBOutlet weak var QuestionBankTv: UITableView!
    @IBOutlet weak var CancelBtn: UIButton!
    @IBOutlet weak var sendQuizBtn: UIButton!
    @IBOutlet weak var QuestionNoLbl: UILabel!
    @IBOutlet weak var TitleLbl: UILabel!
    
    
    let staffDetails = UserDefaultFileManager.get_staff_Details()
    var id  : String?
    var questions: [QuizQuestiondata] = [QuizQuestiondata()]
    var noOfQuestion: Int = 0
    var subject_Id : String?
    var QuestionBankData: [QuestionItem] = []
    var selectedQuestionIds: Set<String> = []
    var titleString = ""
    var localImages: [QuizLocalImages] = [QuizLocalImages()]
    var localAttachments: [[QuizAttachmentItem]] = [[]]
    var file_path: [FilePaths] = []
    var Common_request_params: [String:Any] = [:]
    var uploadedCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        popupBGview.isHidden = true
        popupView.layer.cornerRadius = 10
        popupView.layer.shadowColor = UIColor.black.cgColor
        popupView.layer.shadowOpacity = 0.3
        popupView.layer.shadowOffset = CGSize(width: 2, height: 2)
        popupView.layer.shadowRadius = 3
        ImportQuestionBtn.layer.cornerRadius = 10
        CancelBtn.layer.cornerRadius = 10
        sendQuizBtn.layer.cornerRadius = 10
        ImportQuestionBtn.setTitle(QuizListStringFile.Import_Question.translated(), for: .normal)
        CancelBtn.setTitle(CommonStringFile.Cancel.translated(), for: .normal)
        selectAllBtn.setTitle(QuizListStringFile.Select_All.translated(), for: .normal)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        TitleLbl.text = titleString
        tv.register(UINib(nibName: CellConfingName.QuistionTvTableViewCell, bundle: nil),
                    forCellReuseIdentifier: CellConfingName.QuistionTvTableViewCell)
        tv.dataSource = self
        tv.delegate = self
        QuestionBankTv.register(UINib(nibName: CellConfingName.QuistionTvTableViewCell, bundle: nil),
                                forCellReuseIdentifier: CellConfingName.QuistionTvTableViewCell)
        QuestionBankTv.dataSource = self
        QuestionBankTv.delegate = self
        addQuestion(id:id ?? "" )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        tv.contentInset.bottom = keyboardHeight
        tv.scrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        tv.contentInset.bottom = 0
        tv.scrollIndicatorInsets.bottom = 0
    }
    
    
    
    @IBAction func btnAct(_ sender: UIButton) {
        
        if let errorMessage = validateQuestions() {
            CustomAlert.showAlertWithOkAction(title: AlertstringFile.Missing_Information.translated(), message: errorMessage, on: self)
            return
        }
//        let vc = RecipientVc(nibName: nil, bundle: nil)
//        vc.ScreenType = Menu_id.quiz
//        vc.questions = questions
//        vc.QuestionBankData = QuestionBankData
//        vc.Common_request_params = Common_request_params
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
        
        uploadAllQuestionsAndCreateQuiz()
    }
    
    func addQuestion(id :String) {
        APIService.shared.makeApi(
            url: ServiceUrl.quiz_questions_report,
            parameters: ["id": id ],
            type: ApitTypeSringFile.GET,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<QuizaddQuestionSuc, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.status == true, let data = res.data, !data.isEmpty {
                        self.questions = data   // use API data
                    } else {
                        self.questions = [QuizQuestiondata()] // fallback to one empty
                    }
                    self.QuestionNoLbl.text = QuizListStringFile.Question_Limit.translated() + String(self.questions.count) + "/" + String(self.noOfQuestion)
                    self.tv.reloadData()
                case .failure:
                    DispatchQueue.main.async {
                        self.questions = [QuizQuestiondata()] // fallback
                        self.tv.reloadData()
                    }
                }
            }
        }
    }
    
    func submitQuestions(params : [String:Any]) {
        APIService.shared.makeApi(
            url: ServiceUrl.quiz_add_question,
            parameters:params,
            type: ApitTypeSringFile.POST,
            token: staffDetails?.access_token ?? ""
        ) { [weak self] (result: Result<QuizaddQuestionSuc, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let res):
                    if res.status == true{
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Success, message: res.message ?? "", on: self) {
                            self.dismiss(animated: true)
                        }
                    }else {
                        
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: res.message ?? "", on: self)
                    }
                case .failure(let error):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: error.localizedDescription, on: self)
                }
            }
        }
    }
    
    func detectType(url: String) -> String {
        let ext = URL(string: url)?.pathExtension.lowercased()

        if url.contains("vimeo.com") { return "video" }
        if ["jpg","jpeg","png","gif","heic"].contains(ext) { return "image" }
        if ext == "pdf" { return "pdf" }
        return "document"
    }
    
    func uploadAllQuestionsAndCreateQuiz() {
        let total = questions.count
        uploadedCount = 0
        uploadForQuestion(index: 0)
    }


    func uploadForQuestion(index: Int) {
        if index >= questions.count {
            // 🔥 ALL DONE → Now call API
            uploadAllQuestionsOptionImages {
                let params = self.buildQuizParams()
                self.submitQuestions(params: params)
            }
            return
        }
        
        let q = questions[index]
        uploadMedia(
            file: q.q_file_path ?? [],
            viewController: self,
            title: "",
            description: ""
        ) { [weak self] urls, iframe, fileSize, embedUrl in
            guard let self = self else { return }
            // 🔥 Save uploaded URLs in this specific question
            var updated = q
            updated.q_file_path = urls.map {
                FilePath(url: $0, type: self.detectType(url: $0))
            }
            self.questions[index] = updated
            // Go to NEXT question
            self.uploadForQuestion(index: index + 1)
        }
    }

    private func uploadMedia(
        file: Any,
        viewController: UIViewController,
        title: String = "",
        description: String = "",
        completion: @escaping (_ urls: [String], _ iframeHTML: String?, _ fileSize: Int?, _ embedUrl: String?) -> Void
    ) {

        guard let items = file as? [FilePath], items.count > 0 else {
            completion([], nil, nil, nil)
            return
        }

        var uploadedURLs: [String] = []
        var completed = 0
        var iframeValue: String?
        var fileSizeValue: Int?
        var embedUrlValue: String?

        CircularProgressLoader.shared.show(style: .circle)
        CircularProgressLoader.shared.updateProgress(to: 0)

        func finishOne(total: Int) {
            completed += 1
            let progress = (Double(completed) / Double(total)) * 100
            CircularProgressLoader.shared.updateProgress(to: progress)

            if completed == total {
                CircularProgressLoader.shared.hide()
                completion(uploadedURLs, iframeValue, fileSizeValue, embedUrlValue)
            }
        }

        let total = items.count

        for item in items {
            // 1️⃣ Already uploaded (remote URL) → NO Upload needed
            if !item.isBase64 {
                uploadedURLs.append(item.url ?? "")
                finishOne(total: total)
                continue
            }
            // 2️⃣ BASE64 → IMAGE
            if item.type == "image" || item.type == CommonStringFile.IMAGE,
               let base = item.url,
               let data = Data(base64Encoded: base),
               let image = UIImage(data: data) {

                AWSUploadManager.shared.uploadFileToAWS(file: image) { url in
                    if let url = url { uploadedURLs.append(url) }
                    finishOne(total: total)
                }
                continue
            }
            // 3️⃣ BASE64 → PDF / DOC
            if item.type == "pdf" || item.type == CommonStringFile.pdf || item.type == "document" ,
               let base = item.url,
               let data = Data(base64Encoded: base) {

                AWSUploadManager.shared.uploadFileToAWS(file: data) { url in
                    if let url = url { uploadedURLs.append(url) }
                    finishOne(total: total)
                }
                continue
            }
            // 4️⃣ BASE64 → VIDEO → Vimeo Upload
            if item.type == CommonStringFile.Video,
               let base = item.url,
               let data = Data(base64Encoded: base) {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("temp_video.mp4")
                try? data.write(to: tempURL)
                let uploader = VimeoUploader(
                    accessToken: YOUR_VIMEO_TOKEN,
                    presentingViewController: viewController
                )
                uploader.upload(
                    videoFileURL: tempURL,
                    title: title,
                    description: description,
                    progress: { progress in
                        CircularProgressLoader.shared.updateProgress(to: progress * 100)
                    },
                    completion: { videoURL, iframeHTML, fileSize, embedUrl in

                        if let embed = embedUrl {
                            uploadedURLs.append(embed)
                        }
                        iframeValue = iframeHTML
                        fileSizeValue = fileSize
                        embedUrlValue = embedUrl
                        finishOne(total: total)
                    }
                )
                continue
            }
            // 5️⃣ Unknown → skip
            finishOne(total: total)
        }
    }

    
    func buildQuizParams() -> [String: Any] {

        let dictArray: [[String: Any]] = questions.enumerated().map { (index, q) in
            let fp = (q.q_file_path ?? []).map {
                      ["url": $0.url ?? "", "type": $0.type ?? ""]
                  }
            return [
                QuizKeys.ques_no: "\(index + 1)",   // 🔥 AUTO NUMBERING HERE
                QuizKeys.chapter: q.chapter,
                QuizKeys.question: q.question,
                QuizKeys.a_option: q.a_option,
                QuizKeys.b_option: q.b_option,
                QuizKeys.c_option: q.c_option,
                QuizKeys.d_option: q.d_option,
                QuizKeys.answer: q.answer ?? "",
                QuizKeys.mark: q.mark ?? 0,
                QuizKeys.iframe: "",
                QuizKeys.file_size: "",
                QuizKeys.thumbnail: "",
                QuizKeys.a_image : q.a_image ?? "",
                QuizKeys.b_image : q.b_image ?? "",
                QuizKeys.c_image : q.c_image ?? "",
                QuizKeys.d_image : q.d_image ?? "",
                QuizKeys.file_path : fp
            ]
        }
        // -------- IMPORTED QUESTION BANK HANDLING ----------
        let qBankDict = Dictionary(uniqueKeysWithValues:
            QuestionBankData.compactMap { qb in qb.id.map { ($0, qb) } }
        )
        let updateArray: [[String: Any]] = questions.compactMap { q in
            guard let id = q.id, let bank = qBankDict[id] else { return nil }
            return [
                QuizKeys.ques_no: id,
                QuizKeys.subject_id: bank.subject_id ?? "",
                QuizKeys.chapter: q.chapter,
                QuizKeys.question: q.question,
                QuizKeys.a_option: q.a_option,
                QuizKeys.b_option: q.b_option,
                QuizKeys.c_option: q.c_option,
                QuizKeys.d_option: q.d_option,
                QuizKeys.answer: q.answer ?? "",
                QuizKeys.mark: q.mark ?? 0
            ]
        }

        let totalMarks = questions.compactMap { $0.mark }.reduce(0, +)

        return [
            QuizKeys.questions: dictArray,
            QuizKeys.max_mark: totalMarks,
            QuizKeys.ok_flag: false,
            QuizKeys.update_question_bank: updateArray
        ]
    }
    func uploadAllQuestionsOptionImages(completion: @escaping ()->Void) {

        var index = 0

        func next() {
            if index >= questions.count {
                completion()
                return
            }

            uploadOptionImages(for: questions[index]) { updated in
                self.questions[index] = updated
                index += 1
                next()
            }
        }

        next()
    }

    func uploadOptionImages(for q: QuizQuestiondata,
                            completion: @escaping (QuizQuestiondata)->Void) {
        var updated = q
        let items = [
            ("a_image", q.a_image),
            ("b_image", q.b_image),
            ("c_image", q.c_image),
            ("d_image", q.d_image)
        ]
        var results: [String: String] = [:]
        var done = 0
        func finish() {
            done += 1
            if done == 4 {
                updated.a_image = results["a_image"]
                updated.b_image = results["b_image"]
                updated.c_image = results["c_image"]
                updated.d_image = results["d_image"]

                completion(updated)
            }
        }

        for (key, value) in items {
            // EMPTY → ""
            if value == nil || value!.isEmpty {
                results[key] = ""
                finish()
                continue
            }

            let str = value!

            // ALREADY URL → no upload
            if str.lowercased().hasPrefix("http") {
                results[key] = str
                finish()
                continue
            }

            // BASE64 → convert → upload AWS
            if let data = Data(base64Encoded: str),
               let img = UIImage(data: data) {

                AWSUploadManager.shared.uploadFileToAWS(file: img) { url in
                    results[key] = url ?? ""
                    finish()
                }
            }
            else {
                results[key] = ""
                finish()
            }
        }
    }

    
//    func buildQuizParams() -> [String: Any] {
//        // 1. Convert all QuizQuestiondata → questions
//        let dictArray: [[String: Any]] = questions.map { q in
//            [
//                QuizKeys.ques_no: q.id ?? "",
//                QuizKeys.chapter: q.chapter,
//                QuizKeys.question: q.question,
//                QuizKeys.a_option: q.a_option,
//                QuizKeys.b_option: q.b_option,
//                QuizKeys.c_option: q.c_option,
//                QuizKeys.d_option: q.d_option,
//                QuizKeys.answer: q.answer ?? "",
//                QuizKeys.mark: q.mark ?? 0,
//                QuizKeys.iframe: "",
//                QuizKeys.file_size: "",
//                QuizKeys.thumbnail: "",
//                QuizKeys.a_image : q.a_image ?? "",
//                QuizKeys.b_image : q.b_image ?? "",
//                QuizKeys.c_image : q.c_image ?? "",
//                QuizKeys.d_image : q.d_image ?? "",
//                QuizKeys.file_path:
//                    (q.q_file_path?.isEmpty ?? true)
//                ? []
//                : q.q_file_path!.map { [QuizKeys.url: $0.url, QuizKeys.type: $0.type] }
//            ]
//        }
//        // 2. Lookup QuestionBankData by id
//        let questionBankLookup: [String: QuestionItem] = Dictionary(
//            uniqueKeysWithValues: QuestionBankData.compactMap { item in
//                guard let id = item.id else { return nil }
//                return (id, item)
//            }
//        )
//        
//        // 3. Only imported questions (id present in QuestionBankData)
//        let importedQuestions = questions.filter { q in
//            if let qid = q.id {
//                return questionBankLookup[qid] != nil
//            }
//            return false
//        }
//        
//        // 4. Map imported questions → update_question_bank
//        let updateArray: [[String: Any]] = importedQuestions.compactMap { q in
//            guard let qid = q.id, let bankItem = questionBankLookup[qid] else { return nil }
//            return [
//                QuizKeys.ques_no: qid,
//                QuizKeys.subject_id: bankItem.subject_id ?? "",
//                QuizKeys.chapter: q.chapter,
//                QuizKeys.question: q.question,
//                QuizKeys.a_option: q.a_option,
//                QuizKeys.b_option: q.b_option,
//                QuizKeys.c_option: q.c_option,
//                QuizKeys.d_option: q.d_option,
//                QuizKeys.answer: q.answer ?? "",
//                QuizKeys.mark: q.mark ?? 0
//            ]
//        }
//        
//        
//        // 5. Calculate total marks
//        let totalMarks = questions.compactMap { $0.mark }.reduce(0, +)
//        
//        // 6. Build final params
//        return [
//            QuizKeys.quiz_id: id ?? "",
//            QuizKeys.questions: dictArray,
//            QuizKeys.max_mark: totalMarks,
//            QuizKeys.ok_flag: false,
//            QuizKeys.update_question_bank: updateArray
//        ]
//        
//    }
//    
    func get_QuestionBank_Api(){
        APIService.shared.makeApi(url: ServiceUrl.lms_api_quiz_pick_from_qbank, parameters: [QuizKeys.subject_id: subject_Id ?? ""], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [weak self] (result:Result<QuestionsResponse,Error>) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    if success.status == true {
                        self.QuestionBankData = success.data ?? []
                        self.popupBGview.isHidden = false
                        self.updateSelectAllButtonState()
                        self.selectedQuestionIds = Set(self.questions.compactMap { $0.id })
                        self.QuestionBankTv.reloadData()
                        
                    }else {
                        CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: success.message ?? "", on: self)
                    }
                case .failure(let failure):
                    CustomAlert.showAlertWithOkAction(title: AlertstringFile.Failed, message: failure.localizedDescription, on: self)
                }
            }
            
        }
    }
    
    func validateQuestions() -> String? {
        for (i, q) in questions.enumerated() {
            if q.chapter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "Please fill the Chapter for Question \(i + 1)."
            }
            if q.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || q.question == "Enter Question here"{
                return "Please fill the Question text for Question \(i + 1)."
            }
            if q.a_option.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || q.a_option == "Enter Option A"{
                return "Please provide Option A for Question \(i + 1)."
            }
            if q.b_option.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || q.b_option == "Enter Option B"{
                return "Please provide Option B for Question \(i + 1)."
            }
            if q.c_option.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || q.c_option == "Enter Option C"{
                return "Please provide Option C for Question \(i + 1)."
            }
            if q.d_option.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || q.d_option == "Enter Option D"{
                return "Please provide Option D for Question \(i + 1)."
            }
            if q.answer == nil || q.answer == "Select correct answer" {
                return "Please select the correct answer for Question \(i + 1)."
            }
            if q.correct_answer_text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                return "Please select the correct answer text for Question \(i + 1)."
            }
            if q.mark == nil || q.mark == 0 {
                return "Please assign marks for Question \(i + 1)."
            }
        }
        return nil // ✅ all good
    }
    
    
    @IBAction func ImportquestionAct(_ sender: Any) {
        get_QuestionBank_Api()
    }
    
    @IBAction func BackBtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    @IBAction func AddImportQuestionAct(_ sender: Any) {
        // ✅ First check if nothing is selected
        if selectedQuestionIds.isEmpty {
            CustomAlert.showAlertWithOkAction(
                title: AlertstringFile.No_Selection,
                message: AlertstringFile.You_didn_select_any_questions_from_the_Question_Bank,
                on: self
            )
            return
        }
        
        // ✅ Then check the limit
        if selectedQuestionIds.count > noOfQuestion {
            CustomAlert.showAlertWithOkAction(
                title: AlertstringFile.Limit_Reached,
                message: "You exceed the maximum number of questions (\(noOfQuestion)).",
                on: self
            )
            return
        }
        
        // 1. Remove questions that are no longer selected
        questions.removeAll { quizQ in
            guard let id = quizQ.id else { return false }
            return !selectedQuestionIds.contains(id)
        }
        
        // 2. Add new ones that were selected but not yet in `questions`
        for id in selectedQuestionIds {
            if !questions.contains(where: { $0.id == id }),
               let bankItem = QuestionBankData.first(where: { $0.id == id }) {
                
                let answerIndex = Int(bankItem.answer ?? "")
                var correctText: String? = nil
                if let idx = answerIndex {
                    switch idx {
                    case 1: correctText = bankItem.a_option
                    case 2: correctText = bankItem.b_option
                    case 3: correctText = bankItem.c_option
                    case 4: correctText = bankItem.d_option
                    default: break
                    }
                }
                
                let newQuizQ = QuizQuestiondata(
                    id: bankItem.id,
                    quiz_id: nil,
                    chapter: bankItem.chapter ?? "",
                    question: bankItem.question ?? "",
                    answer: bankItem.answer,
                    a_option: bankItem.a_option ?? "",
                    b_option: bankItem.b_option ?? "",
                    c_option: bankItem.c_option ?? "",
                    d_option: bankItem.d_option ?? "",
                    mark: bankItem.mark,
                    correct_answer_text: correctText
                )
                questions.append(newQuizQ)
            }
        }
        
        // 3. Refresh main table
        tv.reloadData()
        
        // 4. Dismiss popup
        popupBGview.isHidden = true
        
        QuestionNoLbl.text = "\(QuizListStringFile.Question_Limit.translated()) \(questions.count)/\(noOfQuestion)"
    }
    
    
    @IBAction func cancelAct(_ sender: Any) {
        
        selectedQuestionIds = Set(questions.compactMap { $0.id }) // reset to actual imported
        popupBGview.isHidden = true
        QuestionBankTv.reloadData()
        QuestionNoLbl.text = "\(QuizListStringFile.Question_Limit.translated()) \(questions.count)/\(noOfQuestion)"
    }
    
    @IBAction func selectAllAct(_ sender: Any) {
        let shouldSelectAll = selectedQuestionIds.count != QuestionBankData.count
        
        if shouldSelectAll {
            // Check limit
            if questions.count + QuestionBankData.count > noOfQuestion {
                CustomAlert.showAlertWithOkAction(
                    title: AlertstringFile.Limit_Reached,
                    message: "You cannot select all because it exceeds the maximum number of questions (\(noOfQuestion)).",
                    on: self
                )
                return
            }
            selectedQuestionIds = Set(QuestionBankData.compactMap { $0.id })
            selectAllBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            selectedQuestionIds.removeAll()
            selectAllBtn.setImage(UIImage(systemName: "square"), for: .normal)
        }
        
        QuestionBankTv.reloadData()
        QuestionNoLbl.text = "\(QuizListStringFile.Question_Limit.translated()) \(questions.count + selectedQuestionIds.count)/\(noOfQuestion)"
        updateSelectAllButtonState()
    }
    
    private func updateSelectAllButtonState() {
        let total = QuestionBankData.count
        let selected = selectedQuestionIds.count
        
        if selected == total && total > 0 {
            selectAllBtn.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        } else {
            selectAllBtn.setImage(UIImage(systemName: "square"), for: .normal)
        }
        
        QuestionNoLbl.text = "\(QuizListStringFile.Question_Limit.translated()) \(questions.count + selected)/\(noOfQuestion)"
    }
    
    
}

@available(iOS 14.0, *)
extension CreateQuizQutionVc: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tv{
            return questions.count
        }else{
            return QuestionBankData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tv {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.QuistionTvTableViewCell, for: indexPath) as? QuistionTvTableViewCell else {
                return UITableViewCell()
            }
            cell.layoutIfNeeded()
            
            let model = questions[indexPath.row]
            let isLastCell = (indexPath.row == questions.count - 1)
            cell.indexPath = indexPath
            cell.delegate = self
            cell.parentVC = self
            cell.configureCell(
                with: model,
                isLast: isLastCell,
                numberofQuestion: noOfQuestion,
                totalQuestion : questions.count
            )
            return cell
        }else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.QuistionTvTableViewCell, for: indexPath) as? QuistionTvTableViewCell else {
                return UITableViewCell()
            }
            
            cell.layoutIfNeeded()
            
            let model = QuestionBankData[indexPath.row]
            cell.indexPath = indexPath
            cell.questionId = model.id
            cell.delegate = self
            cell.parentVC = self
            // ✅ Use selectedQuestionIds instead of questions
            let isChecked = selectedQuestionIds.contains(model.id ?? "")
            cell.configureQuestionBankCell(with: model, isChecked: isChecked)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

struct QuestionModel {
    var chapter: String
    var marks: String
    var optionA: String
    var optionB: String
    var optionC: String
    var optionD: String
    var question: String
}

struct QuizLocalImages {
    var a: UIImage?
    var b: UIImage?
    var c: UIImage?
    var d: UIImage?
}
