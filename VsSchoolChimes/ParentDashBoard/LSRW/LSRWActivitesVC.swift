//
//  LSRWActivitesVC.swift
//  School Chimes
//
//  Created by Chandhru on 30/06/25.
//

import UIKit
import AVFoundation

@available(iOS 15.0, *)
class LSRWActivitesVC: UIViewController, BaktoHome, AssignmentDetailTVCDelegate {
    func didSelectAttachment(at index: Int, allAttachments: [FilePath], subjectName: String) {
        let imageVC = ImageShowVc(nibName: nil, bundle: nil)
        imageVC.fileURL = allAttachments
        imageVC.subjectName = "Event"
        imageVC.scrollIndex = IndexPath(index:index)
        imageVC.index = index
        imageVC.modalPresentationStyle = .fullScreen
        present(imageVC, animated: true)
    }
    
    func backtohome() {
        testTable.reloadData()
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var testTable: UITableView!
    
    // MARK: - Properties
    var lsrw: LSRWTask?
    private var captions: [CaptionType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptions()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupCaptions() {
        guard let lsrw = lsrw else { return }
        
//        // Add initial attachment type if available
//        if let firstAttachmentType = lsrw.file_path?.first?.type?.lowercased() {
//            captions.append(firstAttachmentType == "audio" ? .audio : .attachments)
//        }
        self.lsrw?.test = [
            TestQuestion(question: "What is the capital of India?", options: ["Delhi", "Mumbai", "Kolkata", "Chennai"]),
            TestQuestion(question: "Which is the largest planet?", options: ["Earth", "Mars", "Jupiter", "Saturn"]),
            TestQuestion(question: "Who wrote the national anthem of India?", options: ["Tagore", "Gandhi", "Nehru", "Vivekananda"]),
            TestQuestion(question: "Which is the fastest land animal?", options: ["Tiger", "Cheetah", "Lion", "Horse"])
        ]

        // Configure captions based on LSRW type
        switch lsrw.activity_type {
        case .reading, .listening:
            captions += Array(repeating: .test, count: self.lsrw?.test?.count ?? 0)
        case .writing:
            captions.append(.addAttachment)
        case .speaking:
            captions += [.record, .addAttachment]
        }
        
        // Always insert task first
        captions.insert(.task, at: 0)
    }
    
    private func setupTableView() {
        let nibs = [
            "TestTVC", "RecorderTVC", "AddAttachmentTVC",
            "LSWTaskTVC", "AudioPlayerTVC"
        ]
        nibs.forEach { testTable.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0) }
        
        testTable.delegate = self
        testTable.dataSource = self
        testTable.rowHeight = UITableView.automaticDimension
        testTable.estimatedRowHeight = 100.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.testTable.reloadData()
        }
    }
    
    // MARK: - Actions
    @IBAction func submit(_ sender: UIButton) {
        sender.setTitle("Submit", for: .normal)
        print("Submit button tapped")
    }
    
    @IBAction private func back(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
@available(iOS 15.0, *)
extension LSRWActivitesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return captions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = captions[indexPath.row]
        
        switch type {
        case .task:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSWTaskTVC", for: indexPath) as! LSWTaskTVC
            cell.titleLbl.text = lsrw?.title ?? "No Title"
            cell.descriptionLbl.text = lsrw?.description ?? "No Description"
            if let task = lsrw {
                cell.configureCell(with: task, attachments:task.file_path ?? [])
            }
            cell.reminderBtn.isHidden = true
            cell.exportRecordBtn.isHidden = true
            cell.delegate = self
            return cell
            
        case .audio:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioPlayerTVC", for: indexPath) as! AudioPlayerTVC
            if let urlString = lsrw?.file_path?.first?.url, let url = URL(string: urlString) {
                cell.audioURL = url
            }
            return cell
            
        case .test:
            let index = captions[..<indexPath.row].filter { $0 == .test }.count
            let safeTest = lsrw?.test
            if let test = safeTest?[safe: index] {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TestTVC", for: indexPath) as! TestTVC
                cell.test = test
                print(test)
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
            return cell
            
        case .record:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecorderTVC", for: indexPath) as! RecorderTVC
            cell.recoderTime.text = "00:00"
            return cell
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

