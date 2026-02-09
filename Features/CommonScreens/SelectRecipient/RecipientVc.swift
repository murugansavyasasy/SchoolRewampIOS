//
//  RecipientVc.swift
//  VsSchoolChimes
//
//  Created by admin on 31/03/25.
//

import UIKit

class RecipientVc: UIViewController{
    
    @IBOutlet weak var subjectDefaultLbl: UILabel!
    @IBOutlet weak var addLevel: UIView!
    @IBOutlet weak var chooseDefaultLbl: UILabel!
    @IBOutlet weak var acidmicYrLbl: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backbtnMName: UIButton!
    @IBOutlet weak var drpodonLbl: UILabel!
    @IBOutlet weak var segmentName: UISegmentedControl!
    @IBOutlet weak var fullview: UIView!
    @IBOutlet weak var contentLbl: UILabel!
    @IBOutlet weak var speficBtnName: UIButton!
    @IBOutlet weak var sendbtnName: UIButton!
    @IBOutlet weak var selectStandardDropDown: UIView!
    @IBOutlet weak var selectSubject: UIView!
    @IBOutlet weak var selectLevel: UIView!
    
    @IBOutlet weak var heightSegment: NSLayoutConstraint!
    @IBOutlet weak var nodataFound: UIImageView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var spaceView: UIView!
    @IBOutlet weak var getSubject: UIButton!
    @IBOutlet weak var noRecordLbl: UILabel!
    @IBOutlet weak var acidamicYrDropView: UIView!
    
    var cv_itemsarry : [String] = []
    var dropDownArray = [String]()
    var subjectList = [String]()
    var uploadedURLs: [String] = []
    var subjectDetails: [GetSubjectDetails]?
    var studentsDetails: [StudentDetails]?
    var sectionsDetails: [sectionsDetail]?
    var standardDetails: [StandardDetail]?
    var staffDetails: [GetStaffDetails]?
    var groupDetails: [GroupDetail]?
    var lastSelectedButton: UIButton?
    let dropDown = DropDown()
    let StdDropdown = DropDown()
    var selectedId : IndexPath?
    var sectionId:Int?
    var ScreenType:Int?
    var sectionIds:String?
    let staffDetailsCount = UserDefaultFileManager.getUserDetails()?.user_details?.staff_details
    let  staff_role = UserDefaultFileManager.getUserDetails()?.user_details?.staff_role ?? ""
    var segment_selected_index:Int?
    var array_selectedId : [String] = []
    var communicatio_textDetails :[String] = []
    var requestCommonDataDetails : [String:Any] = [:]
    var target_type : Int?
    let alert = CustomAlert()
    var circular_types : String?
    var subjectId : String?
    var classID : String?
    var accadimYr :[String] = []
    let acidamicdrops = DropDown()
    var  selectedAcadimicYearId: Int?
    var accadimYrIDs :[Int] = []
    var accadmicDefaultYrName : String?
    var accedmicYrEligible = false
    var vimeoUploader: VimeoUploader?
    var Common_request_params: [String:Any] = [:]
    var sectionName:String?
    var levelDropDown: [String] = []
    var SEND_ATTACHMENT = "SEND_ATTACHMENT"
    var SEND_HOMEWORK = "SEND_HOMEWORK"
    var SEND_ASSIGNMENT = "SEND_ASSIGNMENT"
    var SEND_TEXT = "SEND_TEXT"
    var SEND_VOICE = "SEND_VOICE"
    var questions: [QuizQuestiondata] = [QuizQuestiondata()]
    var QuestionBankData: [QuestionItem] = []
    var localImages: [QuizLocalImages] = [QuizLocalImages()]
    var localAttachments: [[QuizAttachmentItem]] = [[]]
    var uploadedFiles1: [[String: String]] = []
    var file_path: [FilePath] = []
    var uploadedCount = 0
    var isQuiz_open_to_students: Bool = false
    var IsNoSubjectData: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        nodataFound.isHidden = true
        noRecordLbl.isHidden = true
        speficBtnName.isHidden = true
        tv.isHidden = true
        backbtnMName
            .setTitle(
                UserDefaultFileManager.get_staff_Details()?.school_name,
                for: .normal)
        backbtnMName.setTitleFont(style: .secondary, size: 18.0)
        getacadmicYr{
            self.homeWorkShowProps{ succes in
                if !succes{
                    self.configureRecipientTabs()
                }
            }
        }
        let nib = UINib(nibName: CellConfingName.RecipientTvCell, bundle: nil)
        tv.register(nib, forCellReuseIdentifier:CellConfingName.RecipientTvCell)
        tv.register(UINib(nibName:CellConfingName.Std_Grp_header, bundle: nil),forHeaderFooterViewReuseIdentifier: CellConfingName.Std_Grp_header)
        sendbtnName.layer.cornerRadius = 10
        speficBtnName.layer.cornerRadius = 10
        getSubject.layer.cornerRadius = 10
        applyShadowAndCornerRadius(to: selectStandardDropDown)
        applyShadowAndCornerRadius(to: selectSubject)
        applyShadowAndCornerRadius(to: selectLevel)
        applyShadowAndCornerRadius(to: getSubject)
        applyShadowAndCornerRadius(to: acidamicYrDropView)
        selectSubject.isHidden = true
        subjectDefaultLbl.isHidden = true
        selectLevel.isHidden = true
        spaceView.isHidden = true
        getSubject.isHidden = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(selectStd))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(selectedSubject))
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(selectedLevel))
        let acidmaciyrClick = UITapGestureRecognizer(target: self, action:
                                                        #selector(academicYearDrop_action))
        selectStandardDropDown.addGestureRecognizer(tap2)
        selectSubject.addGestureRecognizer(tap3)
        selectLevel.addGestureRecognizer(tap4)
        acidamicYrDropView.addGestureRecognizer(acidmaciyrClick)
    }
    func configureRecipientTabs() {
        segmentName.removeAllSegments()
        cv_itemsarry.removeAll()
        var defaultIndex = 0
        segmentName
            .setTitleTextAttributes(
                [.font: UIFont.boldSystemFont(ofSize: 10),
                    .foregroundColor: UIColor.black],
                for: .normal
            )
        
        switch staff_role {
        case PriorityType.is_staff:
            cv_itemsarry = [
//                recipeint_tabBarName.Standard,
                recipeint_tabBarName.Section_Student,
                recipeint_tabBarName.Group
            ]
            target_type = TargetTypes.standard
            circular_types =  circular_type.standard
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            }
            defaultIndex = 0
        case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
            if Menu_id.event == Menu_id.staffSelectedMenuId {
                cv_itemsarry = [
                    recipeint_tabBarName.Entier_School,
                    recipeint_tabBarName.Standard,
                    recipeint_tabBarName.Group
                ]
            }else{
                cv_itemsarry = [
                    recipeint_tabBarName.Entier_School,
                    recipeint_tabBarName.Standard,
                    recipeint_tabBarName.Section_Student,
                    recipeint_tabBarName.Group,
                    recipeint_tabBarName.Staff
                ]
            }
            circular_types = circular_type.school
            target_type = TargetTypes.school
            noRecordLbl.text = CommonStringFile.Tap_SEND_to_share_this
            defaultIndex = 1
        default:
            print("Unhandled staff role")
        }
        // Add segments from updated array
        for (index, title) in cv_itemsarry.enumerated() {
            segmentName.insertSegment(withTitle: title, at: index, animated: false)
        }
        segmentName.selectedSegmentIndex = defaultIndex
        handleSegmentSelection(index: defaultIndex)
    }
    

    
    func handleSegmentSelection(index: Int) {
        segment_selected_index = index
        if index == 0 {
            segmentName.isHidden = false
            heightSegment.constant = 40
        }else{
            DispatchQueue.main.async { [self] in
                nodataFound.isHidden = true
                noRecordLbl.isHidden = true
                heightSegment.constant = 40
                segmentName.isHidden = false
                target_type = TargetTypes.standard
                circular_types =  circular_type.standard
                selectStandardDropDown.isHidden = true
                self.getStandardsAPI(academic_year_id: self.selectedAcadimicYearId ?? 0)
            }
        }
    }


    func homeWorkShowProps(onSuccess: @escaping (Bool) -> Void) {
        guard accedmicYrEligible else { return }
        nodataFound.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            let isAssignmentOrHomework = Menu_id.staffSelectedMenuId == Menu_id.isAssaignment || Menu_id.staffSelectedMenuId == Menu_id.homeWorkMenuId || Menu_id.staffSelectedMenuId == Menu_id.lsrw || Menu_id.staffSelectedMenuId == Menu_id.quiz
            if isAssignmentOrHomework {
                segmentName.isHidden = true
                nodataFound.isHidden = true
                noRecordLbl.isHidden = true
                target_type = TargetTypes.section
                circular_types = circular_type.section
                getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
                
                speficBtnName.isHidden = true
                speficBtnName.isEnabled = false
                
                tv.isHidden = false
                selectStandardDropDown.isHidden = false
                heightSegment.constant = 0
                segment_selected_index = 0
                cv_itemsarry = [recipeint_tabBarName.Section_Student]
                onSuccess(true)
            } else {
                speficBtnName.isEnabled = true
                selectStandardDropDown.isHidden = true
                onSuccess(false)
            }
        }
    }
    
    
    
    @IBAction func backbtn(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func send(_ sender: UIButton) {
        print("selectedId : \(array_selectedId)")
        let isEntireSchool = (cv_itemsarry[segmentName.selectedSegmentIndex] == recipeint_tabBarName.Entier_School)
        // Validate selection
        guard isEntireSchool || !array_selectedId.isEmpty else {
            alert.showAlert(
                title: AlertstringFile.Alert_title,
                message: AlertstringFile.Choose_any_target,
                on: self
            )
            return
        }
        
        let comm = commonApi_forSending()
        switch Menu_id.staffSelectedMenuId {
        case Menu_id.communicationMenuId:
            SendingCommunicationFlow()
        case Menu_id.homeWorkMenuId, Menu_id.isAssaignment:
            guard let subjectId = subjectId, !subjectId.isEmpty else {
                alert.showAlert(
                    title: AlertstringFile.Alert_title,
                    message: AlertstringFile.Choose_any_section,
                    on: self
                )
                return
            }
            let baseURL = (Menu_id.staffSelectedMenuId == Menu_id.homeWorkMenuId)
            ? ServiceUrl.comm_homework_sendhomework
            : ServiceUrl.comm_assignment_send_assignment
            
            sendAttachmentFlow(
                via: comm,
                url: baseURL,
                subjectId: subjectId, isBaseUrl: true
            )
            
        case Menu_id.quiz:
            guard let subjectId = subjectId, !subjectId.isEmpty else {
                alert.showAlert(
                    title: AlertstringFile.Alert_title,
                    message: AlertstringFile.Choose_any_section,
                    on: self)
                return}
            
            uploadAllQuestionsAndCreateQuiz()
        case Menu_id.AttachmentMenuId:
            sendAttachmentFlow(
                via: comm,
                url: ServiceUrl.comm_attachment_send_attachment,
                subjectId: subjectId ?? "", isBaseUrl: true)
        case Menu_id.lsrw:
            guard let subjectId = subjectId, !subjectId.isEmpty else {
                alert.showAlert(
                    title: AlertstringFile.Alert_title,
                    message: AlertstringFile.Choose_any_section,
                    on: self
                )
                return
            }
            sendAttachmentFlow(
                via: comm,
                url: ServiceUrl.lms_api_lsrw_create_skill,
                subjectId: subjectId, isBaseUrl: true
            )
        case Menu_id.event:
            sendAttachmentFlow(
                via: comm,
                url: ServiceUrl.api_school_event_send_event,
                subjectId: subjectId ?? "", isBaseUrl: true)
            
        default:
            print("⚠️ Unhandled menu ID: \(Menu_id.staffSelectedMenuId)")
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
        uploadedCount = 0
        uploadForQuestion(index: 0)
    }


    func uploadForQuestion(index: Int) {
        if index >= questions.count {
            // 🔥 ALL DONE → Now call API
            uploadAllQuestionsOptionImages {
                let params = self.buildQuizParams()
                self.CreateQuiz(QuestionParams: params)
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
            if item.type == "pdf" || item.type == "document" || item.type ==  "PDF",
               let base = item.url,
               let data = Data(base64Encoded: base) {

                AWSUploadManager.shared.uploadFileToAWS(file: data) { url in
                    if let url = url { uploadedURLs.append(url) }
                    finishOne(total: total)
                }
                continue
            }

            // 4️⃣ BASE64 → VIDEO → Vimeo Upload
            if item.type == CommonStringFile.VIDEO,
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

        let dictArray: [[String: Any]] = questions.enumerated().map{ (index, q) in
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

    
    func CreateQuiz(QuestionParams : [String: Any]) {
            var params: [String: Any] = [
                createQuizStringFile.target_type: target_type ?? 0,
                createQuizStringFile.target_code: array_selectedId,
                createQuizStringFile.subject_id : subjectId ?? "",
                createQuizStringFile.class_id : classID ?? "",
                createQuizStringFile.open_to_student : isQuiz_open_to_students
            ]

            params.merge(Common_request_params) { _, new in new }
            params.merge(QuestionParams) { _, new in new }
            APIService.shared.makeApi(
                url: ServiceUrl.quiz_create_quiz,
                parameters: params,
                type: ApitTypeSringFile.POST,
                token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: true
            ) { [self] (result: Result<CommonApiSuc, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let res):
                        if res.status == true {
                            CustomAlert.showAlertWithOkAction(
                                title: AlertstringFile.Success,
                                message: res.message ?? "",
                                on: self
                            ) { self.gotoDashboard() }
                        } else {
                            self.alert.showAlert(
                                title: AlertstringFile.Alert_title,
                                message: res.message ?? "",
                                on: self
                            )
                        }
                        
                    case .failure(let err):
                        print("❌ ERROR:", err.localizedDescription)
                    }
                }
            }
    }

    
    func paketApiCall(params:[String:Any]) {
        APIService.shared.makeApi(
            url: ServiceUrl.dashboard_api_pauket_add_points,
            parameters: params,
            type: ApitTypeSringFile.POST,
            token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: true
        ) { [weak self] (result: Result<EventResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.gotoDashboard()
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(response.message, duration: 2.0, position: .bottom)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    self.gotoDashboard()
                    if let window = UIApplication.shared.windows.first {
                        window.makeToast(error.localizedDescription, duration: 2.0, position: .bottom)
                    }
                }
            }
        }
    }
    
    private func sendAttachmentFlow(
        via comm: commonApi_forSending,
        url baseURL: String,
        subjectId: String,
        isBaseUrl: Bool
    ) {
        comm.SendingAttachmentFlow(
            selectedAcadimicYearId: selectedAcadimicYearId ?? 0,
            target_type: target_type ?? 0,
            selectedId: array_selectedId,
            baseURL: baseURL,
            subjectId: subjectId,
            message: acidmicYearOrNotAlertMessage(),
            from: self,
            Common_request_params: Common_request_params,
            isBaseUrl : isBaseUrl
        ) { response in
            DispatchQueue.main.async {
                CircularProgressLoader.shared.hide()
                CustomAlert.showAlertWithOkAction(
                    title: AlertstringFile.Success,
                    message: response.message,
                    on: self
                ) { [self] in
                    Common_request_params.removeAll()
                    var activity = ""
                    switch Menu_id.staffSelectedMenuId {
                    case Menu_id.AttachmentMenuId:
                        activity = SEND_ATTACHMENT
                    case Menu_id.homeWorkMenuId:
                        activity = SEND_HOMEWORK
                    case Menu_id.isAssaignment:
                        activity = SEND_ASSIGNMENT
                    default:
                        activity = ""
                    }
                    if user_inputs.clearTempData(),activity != "" {
                        let params: [String: Any] = [
                            addPonintsPackut.mobile_number: UserDefaultFileManager
                                .get_staff_Details()?.mobile_no ?? "",
                            addPonintsPackut.activity : activity,
                            addPonintsPackut.user_type : 2,
                            addPonintsPackut.menu_id : Menu_id.staffSelectedMenuId
                        ]
                        paketApiCall(params: params)
                    }else{
                        
                        gotoDashboard()
                    }
                }
            }
        }
    }
    
    func acidmicYearOrNotAlertMessage() -> String{
        var selectedTabItem = cv_itemsarry[segmentName.selectedSegmentIndex]
        
        if cv_itemsarry[segmentName.selectedSegmentIndex] == recipeint_tabBarName.Section_Student{
            selectedTabItem = "Section"
        }
        var message : String?
        if accadmicDefaultYrName == acidmicYrLbl.text{
            message = AlertstringFile.Selected_target + "\(array_selectedId.count) " + "\(selectedTabItem) (s)" + "\n" + AlertstringFile.AreYouSureYouWantToProceed
        }else{
            
            message = AlertstringFile.Selected_target + "\(array_selectedId.count) " + "\(cv_itemsarry[segmentName.selectedSegmentIndex]) (s)" + "\n" + AlertstringFile.Change_academic_year + " " + (
                acidmicYrLbl.text ?? "") + AlertstringFile.Change_academic_year1 +   "\n" + AlertstringFile.Change_academic_year2
        }
        
        return message ?? ""
    }
    
    @IBAction func getSubject(_ sender: UIButton) {
        let selectedSections = sectionsDetails?.filter { $0.isSelect == true } ?? []
        if Menu_id.homeWorkMenuId == Menu_id.staffSelectedMenuId || Menu_id.isAssaignment == Menu_id.staffSelectedMenuId || Menu_id.lsrw == Menu_id.staffSelectedMenuId || Menu_id.staffSelectedMenuId == Menu_id.quiz{
            if let finalSectionIds = sectionIds, !finalSectionIds.isEmpty {
                getSubjectListAPI(finalSectionIds)
            }
        }
        selectSubject.isHidden = !(selectedSections.count >= 1)
        subjectDefaultLbl.isHidden = !(selectedSections.count >= 1)
        getSubject.isHidden = true
        selectSubject.isHidden = false
        subjectDefaultLbl.isHidden = false
        selectLevel.isHidden = Menu_id.staffSelectedMenuId == Menu_id.quiz ? false : true
        spaceView.isHidden = true
    }
    
    private func SendingCommunicationFlow() {
        let title = AlertstringFile.Confirm_title
        alert.showAlertCancel(
            title: title,
            message: acidmicYearOrNotAlertMessage(),
            actionLbl1: AlertstringFile.Yes_Send,
            actionLbl2: AlertstringFile.Cancel,
            on: self,
            onOk: { [self] in
                switch ScreenType {
                case screenType.communication_text:
                    sendtextmessage_communication()
                case screenType.is_emergencyvoice, screenType.non_emergencyvoice:
                    if user_inputs.voice_link.contains("https:") { // MARK: FORWARD VOICE
                        sendVoiceMessage_communication()
                    } else {
                        let com = commonApi_forSending()
                        com.uploadAWSMedia(file: user_inputs.voice_link) {
                            self.sendVoiceMessage_communication()
                        }
                    }
                    
                default:
                    print("Unhandled communication screen type: \(ScreenType)")
                }
            },
            onNo: {
                print("User canceled.")
            }
        )
    }
    
    
    
    
    @IBAction func spefic_student_actionBtn(_ sender: UIButton) {
    
        guard  array_selectedId.count > 0 else {
            self.alert
                .showAlert(
                    title: AlertstringFile.Alert_title,
                    message: AlertstringFile.Choose_any_standard_section ,
                    on: self
                )
            return
        }
        var message : Bool?
        if accadmicDefaultYrName == acidmicYrLbl.text{
            message = true
        }else{
            message = false
        }
        let selectedSectionName = sectionsDetails?
            .first(where: {$0.isSelect == true })?
            .name
        let vc = StudentHistryVC(nibName: nil, bundle: nil)
        vc.selected_sectionID = array_selectedId.first
        vc.ScreenType = ScreenType
        vc.selected_subjectID = subjectId
        vc.AlertMessageContent = message
        vc.Common_request_params  = Common_request_params
        vc.accidmaticNAme = acidmicYrLbl.text
        vc.selectedAcadimicYearId = self.selectedAcadimicYearId
        vc.StandardString = drpodonLbl.text
        vc.SectionString = selectedSectionName
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    @IBAction func segment_action(_ sender: UISegmentedControl) {
        array_selectedId.removeAll()
        speficBtnName.isHidden = true
        segment_selected_index = sender.selectedSegmentIndex
        guard segment_selected_index ?? 0 >= 0, segment_selected_index ?? 0 < cv_itemsarry.count else {
            print("Invalid segment index.")
            return
        }
        let selectedTitle = cv_itemsarry[segment_selected_index ?? 0]
        switch selectedTitle {
        case recipeint_tabBarName.Entier_School:
            array_selectedId.append( UserDefaultFileManager.get_staff_Details()?.school_id ?? "")
            target_type = TargetTypes.school
            circular_types =  circular_type.school
            nodataFound.isHidden = false
            noRecordLbl.isHidden = false
            noRecordLbl.text = CommonStringFile.Tap_SEND_to_share_this
            sendbtnName.isHidden = false
            nodataFound.image = ImageName.girl_and_boy_are
            selectStandardDropDown.isHidden = true
            tv.isHidden = true
        case recipeint_tabBarName.Group:
            target_type = TargetTypes.group
            circular_types =  circular_type.group
            getGrouplistAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
        case recipeint_tabBarName.Standard:
            target_type = TargetTypes.standard
            circular_types =  circular_type.standard
            getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            selectStandardDropDown.isHidden = true
            tv.isHidden = false
        case recipeint_tabBarName.Section_Student:
            target_type = TargetTypes.section
            circular_types =  circular_type.section
            getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            speficBtnName.isEnabled = !(
                Menu_id.staffSelectedMenuId == Menu_id.isAssaignment ||  Menu_id.staffSelectedMenuId == Menu_id.homeWorkMenuId || Menu_id.staffSelectedMenuId == Menu_id.quiz
            )
            tv.isHidden = false
            selectStandardDropDown.isHidden = false
        case recipeint_tabBarName.Staff:
            target_type = TargetTypes.staff
            circular_types =  circular_type.staff
            getStaffListAPI()
            tv.isHidden = false
            selectStandardDropDown.isHidden = true
        default:
            print("Unhandled tab selection: \(selectedTitle)")
        }
        
    }
    
    @IBAction func selectStd(){
        setupStdDropdown ()
    }
    @IBAction func selectedLevel(){
        selectLevelDropdown()
    }
    
    @IBAction func selectedSubject(){
        setupSubjectDropdown ()
    }
    
    func selectLevelDropdown(){
        StdDropdown.anchorView = selectLevel
        StdDropdown.dataSource = levelDropDown
        StdDropdown.bottomOffset = CGPoint(x: 0, y: selectLevel.bounds.height)
        StdDropdown.direction = .bottom
        StdDropdown.show()
        StdDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            if let label = self.selectLevel.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.text = item
                user_inputs.level = Int(item) ?? 1
            }
        }
    }
    func setupStdDropdown() {
        
        StdDropdown.anchorView = selectStandardDropDown
        StdDropdown.dataSource = dropDownArray
        StdDropdown.bottomOffset = CGPoint(x: 0, y: selectStandardDropDown.bounds.height)
        StdDropdown.direction = .bottom
        StdDropdown.show()
        StdDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            array_selectedId.removeAll()
            selectSubject.isHidden = true
            subjectDefaultLbl.isHidden = true
            subjectId = ""
            self.sectionsDetails = self.standardDetails?.first(where: { $0.name == item })?.sections
            if let label = self.selectStandardDropDown.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.text = item
            }
            classID = self.standardDetails?[index].id
            speficBtnName.isHidden = true
            if sectionsDetails?.count == 0{
                self.tv.isHidden = true
                self.alert
                    .showAlert(
                        title: AlertstringFile.Oops,
                        message: "No Section Found",
                        on: self
                    )
            }else{
                self.tv.isHidden = false
                self.tv.dataSource = self
                self.tv.delegate = self
                self.tv.reloadData()
                DispatchQueue.main.async {
                    self.tableHeight.constant = self.tv.contentSize.height
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func setupSubjectDropdown() {
        StdDropdown.anchorView = selectSubject
        StdDropdown.dataSource = subjectList
        StdDropdown.bottomOffset = CGPoint(x: 0, y: selectSubject.bounds.height)
        StdDropdown.show()
        let tableView = self.StdDropdown.tableView
        let visibleCellCount = tableView.visibleCells.count
        let visibleHeight = CGFloat(visibleCellCount) * 44.0
        if visibleHeight < 200 {
            self.StdDropdown.direction = .top
        } else {
            self.StdDropdown.direction = .bottom
        }
        StdDropdown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            if let label = self.selectSubject.subviews.first(where: { $0 is UILabel }) as? UILabel {
                label.text = item
                subjectId = subjectDetails?[index].id ?? ""
                speficBtnName.isHidden = true
            }
            if Menu_id.staffSelectedMenuId == Menu_id.isAssaignment{
                speficBtnName.isHidden = !(array_selectedId.count == 1)
            }
            if Menu_id.staffSelectedMenuId == Menu_id.quiz{
                
                getQuizLevel(
                    SubjectId: subjectId ?? "" ,
                    ClassId: classID ?? "",
                    SectionId: "0"
                )
            }
        }
    }
    
    @IBAction func academicYearDrop_action() {
        accadimYr.removeAll()
        accadimYrIDs.removeAll()
        let yearname = localData.accidamic_year_data?.data?.compactMap{ $0.year}
        let yeardId = localData.accidamic_year_data?.data?.compactMap{ $0.id}
        accadimYr = yearname ?? []
        accadimYrIDs = yeardId ?? []
        acidamicdrops.anchorView = acidamicYrDropView
        acidamicdrops.dataSource = accadimYr
        acidamicdrops.bottomOffset = CGPoint(x: 0, y: acidamicYrDropView.bounds.height)
        acidamicdrops.show()
        acidamicdrops.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            selectedAcadimicYearId =  localData.accidamic_year_data?.data?[index].id
            array_selectedId.removeAll()
            acidmicYrLbl.text = item
            if cv_itemsarry[segmentName.selectedSegmentIndex] ==   recipeint_tabBarName.Standard {
                getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            }
            else if cv_itemsarry[segmentName.selectedSegmentIndex] ==   recipeint_tabBarName.Section_Student {
                getStandardsAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            }
            else if cv_itemsarry[segmentName.selectedSegmentIndex] ==   recipeint_tabBarName.Group {
                getGrouplistAPI(academic_year_id: selectedAcadimicYearId ?? 0)
            }
        }
        
        
    }
}


extension RecipientVc: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: CellConfingName.Std_Grp_header
        ) as! Std_Grp_header
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            head.HeaderLabel.text = recipeint_tabBarName.Group
            head.createdOnDefaultLbl.isHidden = false
        case recipeint_tabBarName.Standard:
            head.HeaderLabel.text = recipeint_tabBarName.Standard
            head.createdOnDefaultLbl.isHidden = true
        case recipeint_tabBarName.Section_Student:
            head.HeaderLabel.text = recipeint_tabBarName.Section_Student
            head.createdOnDefaultLbl.isHidden = true
        case recipeint_tabBarName.Staff:
            head.HeaderLabel.text = recipeint_tabBarName.Staff
            head.createdOnDefaultLbl.isHidden = true
        default:
            head.HeaderLabel.text = ""
        }
        return head
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let baseCount: Int
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            baseCount = groupDetails?.count ?? 0
        case recipeint_tabBarName.Standard:
            baseCount = standardDetails?.count ?? 0
        case recipeint_tabBarName.Section_Student:
            baseCount = sectionsDetails?.count ?? 0
        case recipeint_tabBarName.Staff:
            baseCount = staffDetails?.count ?? 0
        default:
            baseCount = 0
        }
        return baseCount + 1 // +1 for "Select All"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.RecipientTvCell, for: indexPath) as! RecipientTvCell
        if indexPath.row == 0 {
            cell.cellLabel.text = "Select All"
            cell.createdOnlbl.isHidden = true
            let allSelected = isAllSelected()
            cell.checkboxImg.image = allSelected ? ImageName.checkedSquares : ImageName.uncheckedSquares
            return cell
        }
        let dataIndex = indexPath.row - 1
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            if let item = groupDetails?[dataIndex] {
                cell.cellLabel.text = item.name
                cell.createdOnlbl.isHidden = false
                cell.createdOnlbl.text =  item.created_on?
                    .convertToTargetDateFormat() ?? ""
                cell.createdOnlbl.textAlignment = .right
                cell.checkboxImg.image = (item.isSelect ?? false) ? ImageName.checkedSquares : ImageName.uncheckedSquares
            }
        case recipeint_tabBarName.Standard:
            if let item = standardDetails?[dataIndex] {
                cell.cellLabel.text = item.name
                cell.createdOnlbl.isHidden = true
                cell.checkboxImg.image = (item.isSelect ?? false) ? ImageName.checkedSquares : ImageName.uncheckedSquares
            }
        case recipeint_tabBarName.Section_Student:
            if let item = sectionsDetails?[dataIndex] {
                cell.cellLabel.text = item.name
                cell.createdOnlbl.isHidden = true
                cell.checkboxImg.image = (item.isSelect ?? false) ? ImageName.checkedSquares : ImageName.uncheckedSquares
            }
        case recipeint_tabBarName.Staff:
            if let item = staffDetails?[dataIndex] {
                cell.cellLabel.text = item.name
                cell.createdOnlbl.isHidden = false
                cell.createdOnlbl.textAlignment = .left
                if ((item.designation?.isEmpty) != nil) && (
                    (item.emp_id?.isEmpty) != nil
                ){
                    cell.createdOnlbl.isHidden = true
                }else{
                    cell.isHidden = false
                    cell.createdOnlbl.text = "\(item.designation ?? "") - \(item.emp_id ?? "")"
                }
                cell.checkboxImg.image = (item.isSelect ?? false) ? ImageName.checkedSquares : ImageName.uncheckedSquares
            }
        default:
            break
        }
        
        DispatchQueue.main.async {
            self.tableHeight.constant = self.tv.contentSize.height
            self.view.layoutIfNeeded()
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            handleSelectAllToggle()
            tableView.reloadData()
            return
        }
        
        let dataIndex = indexPath.row - 1
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            if var item = groupDetails?[dataIndex] {
                item.isSelect?.toggle()
                groupDetails?[dataIndex].isSelect = item.isSelect
                updateSelectionArray(id: item.id, isSelected: item.isSelect)
            }
        case recipeint_tabBarName.Standard:
            if var item = standardDetails?[dataIndex] {
                item.isSelect?.toggle()
                standardDetails?[dataIndex].isSelect = item.isSelect
                updateSelectionArray(id: item.id, isSelected: item.isSelect)
            }
        case recipeint_tabBarName.Section_Student:
            if var item = sectionsDetails?[dataIndex] {
                item.isSelect?.toggle()
                sectionsDetails?[dataIndex].isSelect = item.isSelect
                updateSelectionArray(id: item.id, isSelected: item.isSelect)
                let selectedSections = sectionsDetails?.filter { $0.isSelect == true } ?? []
                let selectedIds = selectedSections.compactMap { $0.id }
                array_selectedId = selectedIds
                sectionIds = selectedIds.joined(separator: ",")
                if Menu_id.homeWorkMenuId == Menu_id.staffSelectedMenuId || Menu_id.lsrw == Menu_id.staffSelectedMenuId || Menu_id.staffSelectedMenuId == Menu_id.quiz {
                    if (selectedSections.count >= 1){
                        selectSubject.isHidden = false
                        subjectDefaultLbl.isHidden = false
                        getSubjectListAPI(sectionIds ?? "")
                    }else{
                        selectSubject.isHidden = true
                        subjectDefaultLbl.isHidden = true
                        subjectId = ""
                    }
                }else{
                    if Menu_id.isAssaignment == Menu_id.staffSelectedMenuId {
                        speficBtnName.isHidden = !(selectedSections.count == 1)
                        speficBtnName.isEnabled = true
                        selectSubject.isHidden = false
                        subjectDefaultLbl.isHidden = true
                        getSubjectListAPI(sectionIds ?? "")
                    }else{
                        speficBtnName.isHidden = !(selectedSections.count == 1)
                        speficBtnName.isEnabled = true
                    }
                }
                spaceView.isHidden = true
            }
            
        case recipeint_tabBarName.Staff:
            if var item = staffDetails?[dataIndex] {
                item.isSelect?.toggle()
                staffDetails?[dataIndex].isSelect = item.isSelect
                updateSelectionArray(id: item.id, isSelected: item.isSelect)
            }
        default:
            break
        }
        tableView.reloadData()
    }
    
    // MARK: - Helper Function to update selection array
    func updateSelectionArray(id: String?, isSelected: Bool?) {
        guard let id = id else { return }
        if isSelected == true {
            if !array_selectedId.contains(id) {
                array_selectedId.append(id)
            }
        } else {
            array_selectedId.removeAll(where: { $0 == id })
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func isAllSelected() -> Bool {
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            return groupDetails?.allSatisfy { $0.isSelect == true } ?? false
        case recipeint_tabBarName.Standard:
            return standardDetails?.allSatisfy { $0.isSelect == true } ?? false
        case recipeint_tabBarName.Section_Student:
            return sectionsDetails?.allSatisfy { $0.isSelect == true } ?? false
        case recipeint_tabBarName.Staff:
            return staffDetails?.allSatisfy { $0.isSelect == true } ?? false
        default:
            return false
        }
    }
    func handleSelectAllToggle() {
        let selecting = !isAllSelected()
        switch cv_itemsarry[segment_selected_index ?? 0] {
        case recipeint_tabBarName.Group:
            groupDetails = groupDetails?.map {
                var item = $0
                item.isSelect = selecting
                return item
            }
            array_selectedId = selecting ? groupDetails?.compactMap { $0.id } ?? [] : []
        case recipeint_tabBarName.Standard:
            standardDetails = standardDetails?.map {
                var item = $0
                item.isSelect = selecting
                return item
            }
            array_selectedId = selecting ? standardDetails?.compactMap { $0.id } ?? [] : []
        case recipeint_tabBarName.Section_Student:
            sectionsDetails = sectionsDetails?.map {
                var item = $0
                item.isSelect = selecting
                return item
            }
            array_selectedId = selecting ? sectionsDetails?.compactMap { $0.id } ?? [] : []
            sectionIds = array_selectedId.joined(separator: ",")
            if Menu_id.homeWorkMenuId == Menu_id.staffSelectedMenuId || Menu_id.isAssaignment == Menu_id.staffSelectedMenuId || Menu_id.lsrw == Menu_id.staffSelectedMenuId || Menu_id.staffSelectedMenuId == Menu_id.quiz{
                sectionIds = ""
                let selectedSections = sectionsDetails?.filter { $0.isSelect == true } ?? []
                let selectedIds = selectedSections.compactMap { $0.id }
                array_selectedId = selectedIds
                sectionIds = selectedIds.joined(separator: ",")
                spaceView.isHidden = true
                subjectId = selectedSections.count == 0 ? "" : subjectId
                selectSubject.isHidden = sectionIds == "" || sectionIds == nil
                subjectDefaultLbl.isHidden = sectionIds == "" || sectionIds == nil
                if sectionIds?.count != 0{
                    getSubjectListAPI(sectionIds ?? "")
                }
            }
            
            if Menu_id.isAssaignment == Menu_id.staffSelectedMenuId  || Menu_id.AttachmentMenuId ==  Menu_id.staffSelectedMenuId || Menu_id.communicationMenuId == Menu_id.staffSelectedMenuId{
                speficBtnName.isHidden = !(array_selectedId.count == 1)
                speficBtnName.isEnabled = true
            }else{
                speficBtnName.isHidden = true
                speficBtnName.isEnabled = false
            }
        case recipeint_tabBarName.Staff:
            staffDetails = staffDetails?.map {
                var item = $0
                item.isSelect = selecting
                return item
            }
            array_selectedId = selecting ? staffDetails?.compactMap { $0.id } ?? [] : []
            
        default:
            break
        }
    }
    
    // MARK:  This api for  Listing Stars ============================
    func getGrouplistAPI(academic_year_id:Int){
        APIService.shared
            .makeApi(
                url: ServiceUrl.recipient_get_group_list,
                parameters: [COMMON_PARAMETER.academic_year_id:academic_year_id],
                type: ApitTypeSringFile.GET ,
                token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false
            ) {
                [self] (result: Result<GrouplistSuc,Error>) in
                switch result {
                case .success(let successmessage):
                    if successmessage.status == true{
                        DispatchQueue.main.async {[self] in
                            selectSubject.isHidden = true
                            subjectDefaultLbl.isHidden = true
                            
                            //                            spaceView.isHidden = false
                            spaceView.isHidden = true
                            groupDetails = successmessage.data
                            nodata(true, message: "")
                            if var students = groupDetails {
                                for i in students.indices {
                                    students[i].isSelect = false
                                }
                                groupDetails = students
                            }
                            tv.delegate = self
                            tv.dataSource = self
                            tv.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            nodata(false, message: successmessage.message ?? "" )
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print(error.localizedDescription)
                        self.nodata(false, message: error.localizedDescription)
                    }
                }
            }
    }
    
    func getStandardsAPI(academic_year_id:Int){
        dropDownArray.removeAll()
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_standards, parameters: [COMMON_PARAMETER.academic_year_id : academic_year_id], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false) { [self] (result:Result <GetStandardsSuc,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        selectSubject.isHidden = true
                        subjectDefaultLbl.isHidden = true
                        spaceView.isHidden = true
                        tv.isHidden = false
                        noRecordLbl.isHidden = true
                        nodata(true, message: "")
                        standardDetails = successMessage.data
                        standardDetails?.enumerated().forEach { index, student in
                            standardDetails?[index].isSelect = false
                            dropDownArray.append(student.name ?? "")
                            if let sections = student.sections {
                                for j in 0..<sections.count {
                                    standardDetails?[index].sections?[j].isSelect = false
                                }
                            }
                        }
                        selectStandardDropDown.isHidden = cv_itemsarry[segmentName.selectedSegmentIndex] == recipeint_tabBarName.Standard
                        getSubject.isHidden = true
                        drpodonLbl.text = standardDetails?.first?.name
                        drpodonLbl.text = standardDetails?.first?.name
                        classID = standardDetails?.first?.id ?? ""
                        sectionsDetails = standardDetails?.first?.sections // Assign sections directly
                        tv.delegate = self
                        tv.dataSource = self
                        tv.reloadData()
                        DispatchQueue.main.async {
                            self.tableHeight.constant = self.tv.contentSize.height
                            self.view.layoutIfNeeded()
                        }
                        if sectionsDetails?.count == 0{
                            tv.isHidden = true
                            self.alert
                                .showAlert(
                                    title: AlertstringFile.Oops,
                                    message: "No Section Found",
                                    on: self
                                )
                        }
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        selectStandardDropDown.isHidden = true
                        selectSubject.isHidden = true
                        subjectDefaultLbl.isHidden = true
                        nodata(false, message: successMessage.message ?? "")
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [self] in
                    print(error.localizedDescription)
                    nodata(false, message: error.localizedDescription)
                }
                
            }
        }
        
    }
    func nodata(_ ishide:Bool,message:String){
        nodataFound.image = ImageName.missing_file
        nodataFound.isHidden = ishide
        sendbtnName.isHidden = !ishide
        tv.isHidden = !ishide
        noRecordLbl.isHidden = ishide
        noRecordLbl.text = message
        if Menu_id.homeWorkMenuId == Menu_id.staffSelectedMenuId || Menu_id.isAssaignment == Menu_id.staffSelectedMenuId || Menu_id.lsrw == Menu_id.staffSelectedMenuId || Menu_id.staffSelectedMenuId == Menu_id.quiz{
        }
    }
    func getStaffListAPI(){
        APIService.shared
            .makeApi(url: ServiceUrl.recipient_get_staff_list, parameters: [:], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false){ [self] (
                result:Result <GetStafflistSuc,
                Error>
            ) in
                switch result {
                case .success(let successMessage):
                    if successMessage.status == true{
                        DispatchQueue.main.async { [self] in
                            nodata(true, message: "")
                            staffDetails = successMessage.data
                            if var students = staffDetails {
                                for i in students.indices {
                                    students[i].isSelect = false
                                }
                                staffDetails = students
                            }
                            tv.delegate = self
                            tv.dataSource = self
                            tv.reloadData()
                            DispatchQueue.main.async {
                                self.tableHeight.constant = self.tv.contentSize.height
                                self.view.layoutIfNeeded()
                            }
                        }
                    }else{
                        DispatchQueue.main.async { [self] in
                            selectSubject.isHidden = true
                            subjectDefaultLbl.isHidden = true
                            spaceView.isHidden = true
                            sendbtnName.isHidden = true
                            tv.isHidden = true
                            nodata(false, message: successMessage.message ?? "")
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    nodata(false, message: "Something went wrong")
                }
            }
        
    }
    
    func getQuizLevel(SubjectId:String,ClassId:String,SectionId:String){
        levelDropDown.removeAll()
        APIService.shared.makeApi(url: ServiceUrl.check_level , parameters: [
            get_quizLevel.class_id : ClassId,
            get_quizLevel.subject_id : SubjectId
        ], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false){ [self] (result:Result <checkQuizLevelSuc,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        if let quizData = successMessage.data {
                            levelDropDown = quizData.compactMap { item in
                                item.level.map { "Level \($0)" }
                            }}
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        if let quizData = successMessage.data {
                            for item in quizData {
                                levelDropDown.append(String(item.level ?? 0))
                            }
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        
        
    }
    func getSubjectListAPI(_ id:String){
        subjectList.removeAll()
        APIService.shared.makeApi(url: ServiceUrl.recipient_get_subject_list , parameters: [
            COMMON_PARAMETER.section_ids: id
        ], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: false){ [self] (result:Result <GetSubjectlistSuc,Error>) in
            switch result {
            case .success(let successMessage):
                if successMessage.status == true{
                    DispatchQueue.main.async { [self] in
                        speficBtnName.isEnabled = true
                        sendbtnName.isEnabled = true
                        sendbtnName.backgroundColor = .primery
                        speficBtnName.backgroundColor = .primery
                        tv.isHidden = false
                        spaceView.isHidden = true
                        subjectDetails = successMessage.data
                        subjectDetails?.enumerated().forEach { index, student in
                            subjectList.append(student.name ?? "")
                        }
                        if let label = self.selectSubject.subviews.first(where: { $0 is UILabel }) as? UILabel {
                            label.text = subjectDetails?.first?.name
                            subjectId =  subjectDetails?.first?.id ?? ""
                        }
                        if Menu_id.quiz == Menu_id.staffSelectedMenuId{
                            getQuizLevel(
                                SubjectId: subjectId ?? "",
                                ClassId: classID ?? "",
                                SectionId: String(sectionId ?? 0))
                        }
                    }
                }else{
                    DispatchQueue.main.async { [self] in
                        selectSubject.isHidden = true
                        subjectDefaultLbl.isHidden = true
                        IsNoSubjectData = true
                        spaceView.isHidden = true
                        speficBtnName.isEnabled = false
                        sendbtnName.isEnabled = false
                        sendbtnName.backgroundColor = .gray
                        speficBtnName.backgroundColor = .gray
                        self.alert
                            .showAlert(
                                title: AlertstringFile.Oops,
                                message: successMessage.message ?? "",
                                on: self
                            )
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.alert
                    .showAlert(
                        title: AlertstringFile.Oops,
                        message: error.localizedDescription,
                        on: self
                    )
            }
        }
    }
    
    
    func getacadmicYr(onComplete:  @escaping() -> Void){
        if localData.accidamic_year_data?.status == true{
            DispatchQueue.main.async { [weak self] in
                var hasCurrentYear = false
                for i in 0..<(
                    localData.accidamic_year_data?.data?.count ?? 0
                ){
                    if localData.accidamic_year_data?.data?[i].current_academic_year ?? false == true{
                        self?.acidmicYrLbl.text = localData.accidamic_year_data?.data?[i].year
                        self?.accadmicDefaultYrName = localData.accidamic_year_data?.data?[i].year
                        self?.selectedAcadimicYearId = localData.accidamic_year_data?.data?[i].id ?? 0
                        hasCurrentYear = true
                        self?.accedmicYrEligible = true
                        self?.segmentName.isUserInteractionEnabled = hasCurrentYear
                        onComplete()
                        break
                        
                    }
                }
                
                if !hasCurrentYear {
                    self?.segmentName.isUserInteractionEnabled = false
                    self?.nodata(false, message: "")
                    self?.nodataFound.isHidden = false
                    self?.nodataFound.image = ImageName.customer_support
                    self?.acidamicYrDropView.isUserInteractionEnabled = false
                    self?.heightSegment.constant = 0
                    self?.chooseDefaultLbl.isHidden = true
                    self?.segmentName.isHidden = true
                    self?.acidamicYrDropView.isHidden = true
                    self?.selectStandardDropDown.isHidden = true
                    let fullText = CommonStringFile.Your_academic_year_configuration
                    let attributedString = NSMutableAttributedString(string: fullText)
                    let email = CommonStringFile.support_savyasasy_com
                    if let range = fullText.range(of: email) {
                        let nsRange = NSRange(range, in: fullText)
                        // Color and underline
                        attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: nsRange)
                        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
                    }
                    self?.noRecordLbl.attributedText = attributedString
                    self?.noRecordLbl.isUserInteractionEnabled = true
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self?.handleEmailTap(_:)))
                    self?.noRecordLbl.addGestureRecognizer(tapGesture)
                    
                }
                
            }
            
        }else{
            DispatchQueue.main.async {
                self.alert
                    .showAlert(
                        title: AlertstringFile.Error,
                        message: localData.accidamic_year_data?.message ?? "" ,
                        on: self
                    )
            }
        }
        
    }
    
    @objc func handleEmailTap(_ gesture: UITapGestureRecognizer) {
        guard let text = noRecordLbl.attributedText?.string else { return }
        let email = CommonStringFile.support_savyasasy_com
        if let range = text.range(of: email) {
            let nsRange = NSRange(range, in: text)
            let tapLocation = gesture.location(in: noRecordLbl)
            let layoutManager = NSLayoutManager()
            let textContainer = NSTextContainer(size: noRecordLbl.bounds.size)
            let textStorage = NSTextStorage(attributedString: noRecordLbl.attributedText!)
            textContainer.lineFragmentPadding = 0
            textContainer.maximumNumberOfLines = noRecordLbl.numberOfLines
            textContainer.lineBreakMode = noRecordLbl.lineBreakMode
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)
            let index = layoutManager.characterIndex(for: tapLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            if NSLocationInRange(index, nsRange) {
                let subject = "Request to configure communication academic year"
                let body = "Dear School Chimes Team,\n\n Please configure communication academic year  as 20xx - 20xx for any queries contact .\n\n Your name,\nMobile No"
                // URL encode
                let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                // Try Gmail URL
                if let gmailURL = URL(string: "googlegmail://co?to=\(email)&subject=\(encodedSubject)&body=\(encodedBody)"),
                   UIApplication.shared.canOpenURL(gmailURL) {
                    UIApplication.shared.open(gmailURL)
                } else if let fallbackURL = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
                    UIApplication.shared.open(fallbackURL)
                }
            }
        }
    }// MARK:   Listing  API END ===========================
    
    
    //MARK: ALL Sending API START ===========================
    
    func sendtextmessage_communication(){
        APIService.shared
            .makeApi(url: ServiceUrl.comm_text_message_send_text, parameters:[
                send_textmessageStringFile.description : user_inputs.description,
                send_textmessageStringFile.message : user_inputs.title,
                send_textmessageStringFile.target_code: array_selectedId,
                send_textmessageStringFile.target_type: target_type ?? 0,
                send_textmessageStringFile.academic_year_id: selectedAcadimicYearId ?? 0
            ] , type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: true ){ [self] (
                result : Result<CommonApiSuc,
                Error>
            ) in switch result {
            case.success(let succesmessage) :
                if succesmessage.status == true {
                    DispatchQueue.main.async { [self] in
                        CustomAlert
                            .showAlertWithOkAction(
                                title: AlertstringFile.Success,
                                message: succesmessage.message ?? "",
                                on: self
                            ) {
                                if user_inputs.clearTempData(){
                                    let params: [String: Any] = [
                                        addPonintsPackut.mobile_number: UserDefaultFileManager
                                            .get_staff_Details()?.mobile_no ?? "",
                                        addPonintsPackut.activity : self.SEND_TEXT ,
                                        addPonintsPackut.user_type : 2,
                                        addPonintsPackut.menu_id : Menu_id.staffSelectedMenuId
                                    ]
                                    self.paketApiCall(params:params)
                                }
                            }
                    }
                }else {
                    DispatchQueue.main.async {
                        self.alert
                            .showAlert(
                                title: AlertstringFile.Oops,
                                message: succesmessage.message ?? "" ,
                                on: self)
                    }
                }
                
            case.failure(let error) :
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    self.alert
                        .showAlert(
                            title: AlertstringFile.Oops,
                            message: error.localizedDescription ?? "",
                            on: self)
                }
            }
            }
    }
    
    
    func sendVoiceMessage_communication() {
        APIService.shared
            .makeApi(url: ServiceUrl.comm_voice_send_voice, parameters:[
                
                send_voicemeassageStringFile.voice_link : user_inputs.voice_link,
                send_voicemeassageStringFile.target_type : target_type ?? 0,
                send_voicemeassageStringFile.target_code : array_selectedId,
                send_voicemeassageStringFile.duration : user_inputs.duration,
                send_voicemeassageStringFile.description : user_inputs.description,
                send_voicemeassageStringFile.is_emergency : user_inputs.is_emergency,
                send_voicemeassageStringFile.is_schedule : user_inputs.is_schedule,
                send_voicemeassageStringFile.schedule_date : user_inputs.schedule_date,
                send_voicemeassageStringFile.start_time : user_inputs.start_time,
                send_voicemeassageStringFile.end_time :user_inputs.end_time,
                send_voicemeassageStringFile.file_name : user_inputs.file_name,
                send_voicemeassageStringFile.circular_type : circular_types ?? "",
                send_voicemeassageStringFile.academic_year_id: selectedAcadimicYearId ?? 0
                
            ] , type: ApitTypeSringFile.POST, token: UserDefaultFileManager.get_staff_Details()?.access_token ?? "", isBaseUrl: true ){ [self] (
                result : Result<CommonApiSuc,
                Error>
            ) in
                
                switch result {
                    
                case.success(let succesmessage) :
                    
                    if succesmessage.status == true {
                        DispatchQueue.main.async { [self] in
                            CircularProgressLoader.shared.hide()
                            CustomAlert
                                .showAlertWithOkAction(
                                    title: AlertstringFile.Success,
                                    message: succesmessage.message ?? "",
                                    on: self
                                ) { [self] in
                                    if user_inputs.clearTempData(){
                                        let params: [String: Any] = [
                                            addPonintsPackut.mobile_number: UserDefaultFileManager
                                                .get_staff_Details()?.mobile_no ?? "",
                                            addPonintsPackut.activity : SEND_VOICE,
                                            addPonintsPackut.user_type : 2,
                                            addPonintsPackut.menu_id : Menu_id.staffSelectedMenuId
                                        ]
                                        self.paketApiCall(params:params)
                                    }
                                }
                        }
                    }else {
                        DispatchQueue.main.async {
                            CircularProgressLoader.shared.hide()
                            self.alert
                                .showAlert(
                                    title: AlertstringFile.Oops,
                                    message: succesmessage.message ?? "" ,
                                    on: self
                                )
                            
                        }
                    }
                    
                case.failure(let error) :
                    DispatchQueue.main.async {
                        CircularProgressLoader.shared.hide()
                        print(error.localizedDescription)
                        self.alert
                            .showAlert(
                                title: AlertstringFile.Oops,
                                message: error.localizedDescription ,
                                on: self
                            )
                    }
                }
                
            }
        
    }
    
    
    func gotoDashboard(){
        DispatchQueue.main.async { [self] in
            if Menu_id.staffSelectedMenuId == Menu_id.communicationMenuId{
                switch staff_role {
                case PriorityType.is_staff:
                    self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                    
                case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                    if (staffDetailsCount?.count ?? 0) > 1 {
                        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                    } else {
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                    }
                    
                default:
                    print("Unhandled staff role")
                }
            }
            else if Menu_id.staffSelectedMenuId == Menu_id.lsrw{
                switch staff_role {
                case PriorityType.is_staff:
                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                    
                case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                    if (staffDetailsCount?.count ?? 0) > 1 {
                        self.presentingViewController?.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                    } else {
                        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                    }
                    
                default:
                    print("Unhandled staff role")
                }
            }
            
            else{
                switch staff_role {
                case PriorityType.is_staff:
                    self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                case PriorityType.is_admin, PriorityType.is_principal, PriorityType.is_grouphead:
                    if (staffDetailsCount?.count ?? 0) > 1 {
                        self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                    } else {
                        self.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: nil)
                    }
                    
                default:
                    print("Unhandled staff role")
                }
            }
        }
    }
    
    
}
