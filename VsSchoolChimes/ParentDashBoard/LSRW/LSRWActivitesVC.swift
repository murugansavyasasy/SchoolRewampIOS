//
//  LSRWActivitesVC.swift
//  School Chimes
//
//  Created by Chandhru on 30/06/25.
//

import UIKit
import AVFoundation

@available(iOS 15.0, *)
class LSRWActivitesVC: UIViewController, BaktoHome, AssignmentDetailTVCDelegate, EditObjectDelegate, UITextFieldDelegate {
    // In editDta method, replace the reload logic with:
    func editDta(edit: Any?) {
        if let audio = edit as? AttachmentItem {
            attachments.append(audio)
        } else if let updated = edit as? [AttachmentItem] {
            attachments = updated
        }
        
        if let index = captions.firstIndex(of: .record) {
            captions.remove(at: index)
        }
        testTable.reloadData()
    }
    
    
    func didSelectAttachment(at index: Int, allAttachments: [FilePath], subjectName: String) {
        let filterArray = allAttachments.filter { $0.type?.uppercased() != CommonStringFile.M4A }
        if allAttachments[index].type?.uppercased() != CommonStringFile.M4A {
            // Find new index inside filtered array
            let selectedFile = allAttachments[index]
            if let newIndex = filterArray.firstIndex(where: { $0.url == selectedFile.url }) {
                let imageVC = ImageShowVc(nibName: nil, bundle: nil)
                imageVC.fileURL = filterArray
                imageVC.subjectName = subjectName
                imageVC.scrollIndex = IndexPath(item: newIndex, section: 0) // ✅ Correct adjusted index
                imageVC.index = newIndex
                imageVC.modalPresentationStyle = .fullScreen
                present(imageVC, animated: true)
            }
        }
    }
    
    
    func backtohome(type: String) {
        if type == "Recording" {
            if !captions.contains(.record) {
                let insertIndex = max(captions.count - 1, 0)
                captions.insert(.record, at: insertIndex)
            }
        } else {
            if let index = captions.firstIndex(of: .record) {
                captions.remove(at: index)
            }
        }
        testTable.reloadData()
    }

    
    
    // MARK: - IBOutlets
    @IBOutlet weak var testTable: UITableView!
    
    // MARK: - Properties
    var lsrw: LSRWTask?
    private var captions: [CaptionType] = []
    var attachments: [AttachmentItem] = []
    var descriptionString:String?
    var alert = CustomAlert()
    var vimeoUploader: VimeoUploader?
    var onDismiss: (() -> Void)?
    var studentDetails = UserDefaultFileManager.get_child_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptions()
        setupTableView()
        if lsrw?.is_unread ?? false{
            ReadStatusUpdate(type: "LSRW", detail_id: lsrw?.detail_id ?? "")
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let animationCurveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        let animationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw << 16)
        let keyboardHeight = keyboardFrame.height

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) {
            self.testTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight + 30, right: 0)
            self.testTable.scrollIndicatorInsets = self.testTable.contentInset
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let animationCurveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        let animationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw << 16)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions) {
            self.testTable.contentInset = .zero
            self.testTable.scrollIndicatorInsets = .zero
        }
    }

    func ReadStatusUpdate(type: String,detail_id: String){
        
        APIService.shared.makeApi(url: ServiceUrl.comm_communication_read_status_update, parameters: [ReadStatusUpdateStringFile.type : type,ReadStatusUpdateStringFile.detail_id: detail_id], type: ApitTypeSringFile.POST, token: studentDetails?.access_token ?? "") { [self] (result : Result<ReadStatusResponse,Error>) in
            
            switch result {
            case .success(let SuccessMessage):
                if SuccessMessage.status == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        self?.onDismiss?()
                    }
                }
            case .failure(let error):
                
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                }
            }
        }
    }
    // MARK: - Setup
    private func setupCaptions() {
        
        guard let lsrw = lsrw else { return }
        
        if let type = lsrw.activity_type{
            guard lsrw.is_submitted == false else {
                return captions.append(.task)
            }
            captions.append(.task)
            // Configure captions based on LSRW type
            switch type {
            case .reading, .listening:
//                captions += Array(repeating: .test, count: self.lsrw?.test?.count ?? 0)
                captions.append(.addAttachment)
            case .writing:
                captions.append(.addAttachment)
            case .speaking:
                captions += [.addAttachment]
            case .unknown(_):
                print("unkown")
            }
            captions.append(.submit)
        }
    }
    
    private func setupTableView() {
        let nibs = [
            "TestTVC", "RecorderTVC", "AddAttachmentTVC",
            "LSWTaskTVC", "AudioPlayerTVC"
        ]
        testTable.register(SubmitFooterCell.self, forCellReuseIdentifier: SubmitFooterCell.identifier)
        nibs.forEach { testTable.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0) }
        
        testTable.delegate = self
        testTable.dataSource = self
        testTable.rowHeight = UITableView.automaticDimension
        testTable.estimatedRowHeight = 100.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.testTable.reloadData()
        }
    }
    
    @IBAction private func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

@available(iOS 15.0, *)
extension LSRWActivitesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return captions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let type = captions[indexPath.row]
            switch type {
            case .task :
                let cell = tableView.dequeueReusableCell(withIdentifier: "LSWTaskTVC", for: indexPath) as! LSWTaskTVC
                cell.titleLbl.text = lsrw?.title ?? "No Title"
                cell.descriptionLbl.text = lsrw?.description ?? "No Description"
                cell.reminderBtn.isHidden = true
                if let task = lsrw {
                    cell.configureCell(with: task, attachments: task.file_path ?? [])
                    switch task.activity_type{
                    case .listening,.reading:
                        cell.exportRecordBtn.isHidden = true
                    default :
                        cell.exportRecordBtn.isHidden = false
                    }
                }
                cell.exportRecordBtn.isHidden = !(lsrw?.is_submitted ?? false)
                cell.exportRecordBtn.setTitle("My Submission", for: .normal)
                cell.exportRecordBtn.addTarget(self, action: #selector(exportBtnTapped), for: .touchUpInside)
                cell.delegate = self
                return cell
            case .audio:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AudioPlayerTVC", for: indexPath) as! AudioPlayerTVC
                if let urlString = lsrw?.file_path?.first?.url,
                   let url = URL(string: urlString) {
                    cell.audioURL = url
                }
                return cell
                
            case .test:
                let index = captions[..<indexPath.row].filter { $0 == .test }.count
                if let test = lsrw?.test?[safe: index] {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TestTVC", for: indexPath) as! TestTVC
                    cell.test = test
                    cell.questionLbl.text = test.question
                    return cell
                } else {
                    let cell = UITableViewCell()
                    cell.textLabel?.text = "No Test Available"
                    return cell
                }
                
            case .addAttachment:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddAttachmentTVC", for: indexPath) as! AddAttachmentTVC
                cell.delegate = self
                cell.Adddelegate = self
                cell.descriptionTXT.delegate = self
                cell.descriptionTXT.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)

//                cell.descriptionTXT.text = descriptionString
                cell.descriptionTXT.addDoneButton()
                cell.config(attachments, task: lsrw?.activity_type)
                return cell
                
            case .record:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecorderTVC", for: indexPath) as! RecorderTVC
                cell.recoderTime.text = "00:00"
                cell.delegate = self
                return cell
            case .submit:
                let cell = tableView.dequeueReusableCell(withIdentifier: SubmitFooterCell.identifier, for: indexPath) as! SubmitFooterCell
                cell.submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
                cell.contentView.backgroundColor = .clear
                cell.backgroundColor = .clear
                return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        descriptionString = textField.text
    }

    @objc private func submitTapped() {

        let isAttachmentEmpty = attachments.isEmpty
        let isDescriptionEmpty = (descriptionString ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if isAttachmentEmpty && isDescriptionEmpty {
            alert.showAlert(title: "", message: "Please add attachment and description", on: self)
            return
        }

        if isAttachmentEmpty {
            alert.showAlert(title: "", message: "Please add attachment", on: self)
            return
        }

        if isDescriptionEmpty {
            alert.showAlert(title: "", message: "Please enter description", on: self)
            return
        }
        uploadMedia(
            file: attachments,
            viewController: self,
            title: lsrw?.title ?? "",
            description: descriptionString ?? ""
        ) { [weak self] urls, iframe, fileSize, embedUrl in
            guard let self = self else { return }

            var uploadedFiles: [[String: String]] = []

            for urlString in urls {
                guard let url = URL(string: urlString) else { continue }

                let ext = url.pathExtension.lowercased()
                var type = ""

                if ["jpg", "jpeg", "png", "gif", "heic"].contains(ext) {
                    type = CommonStringFile.IMAGE
                } else if urlString.contains("vimeo.com") {
                    type = CommonStringFile.VIDEO
                } else {
                    type = ext.uppercased()
                }

                uploadedFiles.append([
                    CommonStringFile.url: urlString,
                    CommonStringFile.type: type
                ])
            }

            let params: [String: Any] = [
                SendAttachmentStringFile.id: self.lsrw?.id ?? "",
                assignmentResquestStringKey.description: self.descriptionString ?? "",
                assignmentResquestStringKey.iframe: iframe ?? "",
                assignmentResquestStringKey.file_size: fileSize != nil ? "\(fileSize!)" : "",
                assignmentResquestStringKey.filePath: uploadedFiles
            ]
            self.sendAttachment(with: params)
        }
    }


    
    func sendAttachment(with parameters: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            APIService.shared.makeApi(
                url: ServiceUrl.lms_api_lsrw_submit_skill,
                parameters: parameters,
                type: ApitTypeSringFile.POST,
                token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
            ) { [weak self] (result: Result<Send_AttachmentResponse, Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        CustomAlert.showAlertWithOkAction(
                            title: response.status ? AlertstringFile.Success : AlertstringFile.Alert_title,
                            message: response.message,
                            on: self
                        ) {
                            self.dismiss(animated: true)
                        }
                    }
                case .failure(let error):
                    print("❌ API error: \(error.localizedDescription)")
                }
            }
        }
    }
    @objc func exportBtnTapped() {
        APIService.shared.makeApi(
            url: ServiceUrl.lms_api_lsrw_my_submissions,
            parameters: ["id":lsrw?.id ?? ""],
            type: ApitTypeSringFile.GET,
            token: UserDefaultFileManager.get_child_Details()?.access_token ?? ""
        ) { [weak self] (result: Result<LSWSubmissionResponse, Error>) in
            switch result {
            case .success(let response):
                if response.status ?? false {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        let data = response.data ?? []
                        if data.count == 1 {
                            if data.first?.file_path?.count != 0{
                                let vc = LSRWSubmisionListVC()
                                vc.attachment = data.first?.file_path
                                vc.titleSting = data.first?.description ?? ""
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true)
                            }else{
                                self.alert.showAlert(title: "NO Record",
                                                     message: response.message ?? "",
                                                     on: self)
                            }
                        } else {
                            let vc = LSRWSubmissionVC()
                            vc.modalPresentationStyle = .pageSheet
                            
                            if let sheet = vc.sheetPresentationController {
                                if data.count > 2 {
                                    sheet.detents = [.large()]
                                } else {
                                    sheet.detents = [.medium()]
                                }
                                sheet.prefersGrabberVisible = true
                            }
                            self.present(vc, animated: true)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.alert.showAlert(title: "NO Record",
                                             message: response.message ?? "",
                                             on: self)}
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("API Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func uploadMedia(
        file: Any,
        viewController: UIViewController,
        title: String = "",
        description: String = "",
        completion: @escaping (_ urls: [String], _ iframeHTML: String?, _ fileSize: Int?, _ embedUrl: String?) -> Void
    ) {
        var uploadedURLs: [String] = []
        var completed = 0
        var iframeValue: String?
        var fileSizeValue: Int?
        var embedUrlValue: String?
        var currentProgressValues: [Int: Double] = [:] // Track per file progress

        func updateAndCheckCompletion(total: Int) {
            let totalProgress = currentProgressValues.values.reduce(0, +) / Double(total)
            CircularProgressLoader.shared.updateProgress(to: totalProgress * 100)

            if completed == total {
                CircularProgressLoader.shared.hide()
                completion(uploadedURLs, iframeValue, fileSizeValue, embedUrlValue)
            }
        }

        switch file {
        case let attachments as [AttachmentItem]:
            let uploadableItems = attachments.filter { $0.image != nil || $0.imageURL != nil }
            let total = uploadableItems.count
            guard total > 0 else {
                completion([], nil, nil, nil)
                return
            }

            CircularProgressLoader.shared.show(style: .circle)
            CircularProgressLoader.shared.updateProgress(to: 0)

            for (index, item) in uploadableItems.enumerated() {
                currentProgressValues[index] = 0.0

                if let image = item.image {
                    AWSUploadManager.shared.uploadFileToAWS(
                        file: image,
                        bucketPath: "uploads/images/",
                        bucketName: "schoolchimes-communication",
                        progressHandler: { progress in
                            currentProgressValues[index] = progress / 100
                            updateAndCheckCompletion(total: total)
                        }
                    ) { url in
                        if let uploadedURL = url {
                            uploadedURLs.append(uploadedURL)
                        }
                        currentProgressValues[index] = 1.0
                        completed += 1
                        updateAndCheckCompletion(total: total)
                    }

                } else if let fileURLStr = item.imageURL,
                          let fileURL = URL(string: fileURLStr) {

                    if item.fileType.uppercased() == CommonStringFile.VIDEO {
                        if fileURLStr.contains("vimeo.com") {
                            uploadedURLs.append(fileURLStr)
                            currentProgressValues[index] = 1.0
                            completed += 1
                            updateAndCheckCompletion(total: total)
                        } else {
                            vimeoUploader = VimeoUploader(
                                accessToken: YOUR_VIMEO_TOKEN,
                                presentingViewController: viewController
                            )
                            vimeoUploader?.upload(
                                videoFileURL: fileURL,
                                title: title,
                                description: description,
                                progress: { progress in
                                    currentProgressValues[index] = progress
                                    updateAndCheckCompletion(total: total)
                                },
                                completion: { videoURL, iframeHTML, fileSize, finalEmbedUrl in
                                    if let finalEmbedUrl = finalEmbedUrl {
                                        uploadedURLs.append(finalEmbedUrl)
                                    }
                                    iframeValue = iframeHTML
                                    fileSizeValue = fileSize
                                    embedUrlValue = finalEmbedUrl

                                    currentProgressValues[index] = 1.0
                                    completed += 1
                                    updateAndCheckCompletion(total: total)
                                }
                            )
                        }

                    } else {
                        if fileURLStr.lowercased().starts(with: "http") {
                            uploadedURLs.append(fileURLStr)
                            currentProgressValues[index] = 1.0
                            completed += 1
                            updateAndCheckCompletion(total: total)
                        } else {
                            let path = item.fileType.uppercased() != CommonStringFile.IMAGE
                                ? "uploads/Documents/"
                                : "uploads/images/"

                            AWSUploadManager.shared.uploadFileToAWS(
                                file: fileURL,
                                bucketPath: path,
                                bucketName: "schoolchimes-communication",
                                progressHandler: { progress in
                                    currentProgressValues[index] = progress / 100
                                    updateAndCheckCompletion(total: total)
                                }
                            ) { url in
                                if let uploadedURL = url {
                                    uploadedURLs.append(uploadedURL)
                                }
                                currentProgressValues[index] = 1.0
                                completed += 1
                                updateAndCheckCompletion(total: total)
                            }
                        }
                    }

                } else {
                    currentProgressValues[index] = 1.0
                    completed += 1
                    updateAndCheckCompletion(total: total)
                }
            }

        default:
            completion([], nil, nil, nil)
        }
    }
 
}

// MARK: - CaptionType Enum
enum CaptionType: String {
    case task
    case audio
    case test
    case addAttachment
    case record
    case submit
}

// MARK: - Safe Subscript
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

import UIKit

class SubmitFooterCell: UITableViewCell {
    
    static let identifier = "SubmitFooterCell"
    
    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            submitButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            submitButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
