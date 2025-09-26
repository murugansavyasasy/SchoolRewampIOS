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
    func editDta(edit: Any?) {
        testTable.beginUpdates()
        if let audio = edit as? AttachmentItem {
            attachments.append(audio)
            if let index = captions.firstIndex(of: .record) {
                captions.remove(at: index)
                let indexPath = IndexPath(row: index, section: 1)
                testTable.deleteRows(at: [indexPath], with: .fade)
            }
            testTable.reloadSections(IndexSet(integer: 1), with: .fade)
            
        } else if let updatedAttachments = edit as? [AttachmentItem] {
            attachments = updatedAttachments
            if let index = captions.firstIndex(of: .record) {
                captions.remove(at: index)
                let indexPath = IndexPath(row: index, section: 1)
                testTable.deleteRows(at: [indexPath], with: .fade)
            }
            testTable.reloadSections(IndexSet(integer: 1), with: .fade)
        }
        testTable.endUpdates()
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
        testTable.beginUpdates()
        
        if type == "Recording" {
            if !captions.contains(.record) {
                captions.append(.record)
                let indexPath = IndexPath(row: captions.count - 1, section: 1)
                testTable.insertRows(at: [indexPath], with: .fade)
            }
        }else{
            if let index = captions.firstIndex(of: .record) {
                captions.remove(at: index)
                let indexPath = IndexPath(row: index, section: 1)
                testTable.deleteRows(at: [indexPath], with: .fade)
            }
        }
        testTable.endUpdates()
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
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptions()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupCaptions() {
        guard let lsrw = lsrw else { return }
        //        self.lsrw?.test = [
        //            TestQuestion(question: "What is the capital of India?", options: ["Delhi", "Mumbai", "Kolkata", "Chennai"]),
        //            TestQuestion(question: "Which is the largest planet?", options: ["Earth", "Mars", "Jupiter", "Saturn"]),
        //            TestQuestion(question: "Who wrote the national anthem of India?", options: ["Tagore", "Gandhi", "Nehru", "Vivekananda"]),
        //            TestQuestion(question: "Which is the fastest land animal?", options: ["Tiger", "Cheetah", "Lion", "Horse"])
        //        ]
        if let type = lsrw.activity_type{
            // Configure captions based on LSRW type
            switch type {
            case .reading, .listening:
                captions += Array(repeating: .test, count: self.lsrw?.test?.count ?? 0)
            case .writing:
                captions.append(.addAttachment)
            case .speaking:
                captions += [.addAttachment]
            case .unknown(_):
                print("unkown")
            }
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
    func numberOfSections(in tableView: UITableView) -> Int {
        if let type = lsrw?.activity_type {
            switch type {
            case .listening, .reading:
                return 2
            case .speaking, .writing:
                return 3
            case .unknown(_):
                return 1   // அல்லது உங்களுக்கு தேவையான default section count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1 // LSWTaskTVC
        case 1:
            return captions.count // dynamic rows
        case 2:
            return 1 // footer cell
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
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
            cell.exportRecordBtn.setTitle("My Submission", for: .normal)
            cell.exportRecordBtn.addTarget(self, action: #selector(exportBtnTapped), for: .touchUpInside)
            cell.delegate = self
            return cell
            
        case 1:
            let type = captions[indexPath.row]
            switch type {
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
                cell.descriptionTXT.addDoneButton()
                cell.config(attachments, task: lsrw?.activity_type)
                return cell
                
            case .record:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecorderTVC", for: indexPath) as! RecorderTVC
                cell.recoderTime.text = "00:00"
                cell.delegate = self
                return cell
                
            default:
                return UITableViewCell()
            }
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: SubmitFooterCell.identifier, for: indexPath) as! SubmitFooterCell
            cell.submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
            cell.contentView.backgroundColor = .clear
            cell.backgroundColor = .clear
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        descriptionString = currentText
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return true
    }
    
    @objc private func submitTapped() {
        guard !attachments.isEmpty else {
            alert.showAlert(title: "", message: AlertstringFile.Please_Add_Attachment, on: self)
            return
        }
        
        uploadMedia(file: attachments, viewController: self, title: lsrw?.title ?? "", description: descriptionString ?? "") { [weak self] urls, iframe, fileSize, embedUrl in
            guard let self = self else { return }
            let uploadedFiles: [[String: String]] = urls.compactMap { urlString in
                guard let url = URL(string: urlString) else { return nil }
                
                let fileType = url.pathExtension.lowercased()
                let type = fileType == CommonStringFile.jpg ? CommonStringFile.IMAGE : url.pathExtension.uppercased()
                
                return [
                    CommonStringFile.url: urlString,
                    CommonStringFile.type: type
                ]
            }
            let iframeValue = iframe ?? ""
            let fileSizeStr = fileSize != nil ? "\(fileSize!)" : ""
            let params: [String: Any] = [
                SendAttachmentStringFile.id:lsrw?.id ?? "",
                assignmentResquestStringKey.description: descriptionString ?? "",
                assignmentResquestStringKey.iframe: iframeValue,
                assignmentResquestStringKey.file_size: fileSizeStr,
                assignmentResquestStringKey.filePath: uploadedFiles
            ]
            // 🔹 Call API
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
                    // Optionally show error alert here
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
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true)
                            }else{
                                self.alert.showAlert(title: "NO Record",
                                                     message: response.message ?? "",
                                                     on: self)
                            }
                        } else {
                            let vc = LSRWSubmissionVC()
                            vc.submitedAssignment = data
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
    
    // MARK: - Upload Media (Images + Video)
    private func uploadMedia(
        file: Any,
        viewController: UIViewController,
        title: String = "",
        description: String = "",
        completion: @escaping (_ urls: [String], _ iframeHTML: String?, _ fileSize: Int?, _ embedUrl: String?) -> Void
    ) {
        var uploadedURLs: [String] = []
        var completed = 0
        
        func updateAndCheckCompletion(total: Int, iframe: String? = nil, size: Int? = nil, embed: String? = nil) {
            let progress = (Double(completed) / Double(total)) * 100
            CircularProgressLoader.shared.updateProgress(to: progress)
            if completed == total {
                CircularProgressLoader.shared.hide()
                completion(uploadedURLs, iframe, size, embed)
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
            
            for item in uploadableItems {
                if let image = item.image {
                    // Upload local image to AWS
                    AWSUploadManager.shared.uploadFileToAWS(
                        file: image,
                        bucketPath: "uploads/images/",
                        bucketName: "schoolchimes-communication",
                        progressHandler: nil
                    ) { url in
                        if let uploadedURL = url {
                            uploadedURLs.append(uploadedURL)
                        }
                        completed += 1
                        updateAndCheckCompletion(total: total)
                    }
                } else if let fileURLStr = item.imageURL {
                    if fileURLStr.lowercased().starts(with: "http") {
                        // Already an uploaded file (skip upload)
                        uploadedURLs.append(fileURLStr)
                        completed += 1
                        updateAndCheckCompletion(total: total)
                    } else if let fileURL = URL(string: fileURLStr) {
                        if item.fileType.lowercased() == CommonStringFile.VIDEO {
                            // 🎥 Video Handling
                            if fileURLStr.lowercased().starts(with: "http") {
                                // ✅ Already remote video URL → skip Vimeo upload
                                uploadedURLs.append(fileURLStr)
                                completed += 1
                                updateAndCheckCompletion(total: total)
                            } else {
                                // 🚀 Upload to Vimeo (local file only)
                                CircularProgressLoader.shared.show()
                                vimeoUploader = VimeoUploader(
                                    accessToken: YOUR_VIMEO_TOKEN,
                                    presentingViewController: viewController
                                )
                                vimeoUploader?.upload(
                                    videoFileURL: fileURL,
                                    title: title,
                                    description: description,
                                    progress: { progress in
                                        CircularProgressLoader.shared.updateProgress(to: progress)
                                    },
                                    completion: { videoURL, iframeHTML, fileSize, finalEmbedUrl in
                                        completed += 1
                                        if let videoURL = videoURL {
                                            uploadedURLs.append(videoURL)
                                        }
                                        updateAndCheckCompletion(total: total, iframe: iframeHTML, size: fileSize, embed: finalEmbedUrl)
                                    }
                                )
                            }
                        } else {
                            // 📄 Docs / Images → upload to AWS
                            let path = item.fileType.lowercased() != CommonStringFile.IMAGE ? "uploads/Documents/" : "uploads/images/"
                            AWSUploadManager.shared.uploadFileToAWS(
                                file: fileURL,
                                bucketPath: path,
                                bucketName: "schoolchimes-communication",
                                progressHandler: nil
                            ) { url in
                                if let uploadedURL = url {
                                    uploadedURLs.append(uploadedURL)
                                }
                                completed += 1
                                updateAndCheckCompletion(total: total)
                            }
                        }
                    } else {
                        print("❌ Invalid fileURL: \(fileURLStr)")
                        completed += 1
                        updateAndCheckCompletion(total: total)
                    }
                }
            }
            
        default:
            print("❌ Unsupported file type")
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
