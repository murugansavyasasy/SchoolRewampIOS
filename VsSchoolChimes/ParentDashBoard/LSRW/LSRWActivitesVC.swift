//
//  LSRWActivitesVC.swift
//  School Chimes
//
//  Created by Chandhru on 30/06/25.
//

import UIKit
import AVFoundation

@available(iOS 15.0, *)
class LSRWActivitesVC: UIViewController, BaktoHome, AssignmentDetailTVCDelegate, EditObjectDelegate {
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
        let imageVC = ImageShowVc(nibName: nil, bundle: nil)
        imageVC.fileURL = allAttachments
        imageVC.subjectName = "Event"
        imageVC.scrollIndex = IndexPath(index:index)
        imageVC.index = index
        imageVC.modalPresentationStyle = .fullScreen
        present(imageVC, animated: true)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptions()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupCaptions() {
        guard let lsrw = lsrw else { return }
        self.lsrw?.test = [
            TestQuestion(question: "What is the capital of India?", options: ["Delhi", "Mumbai", "Kolkata", "Chennai"]),
            TestQuestion(question: "Which is the largest planet?", options: ["Earth", "Mars", "Jupiter", "Saturn"]),
            TestQuestion(question: "Who wrote the national anthem of India?", options: ["Tagore", "Gandhi", "Nehru", "Vivekananda"]),
            TestQuestion(question: "Which is the fastest land animal?", options: ["Tiger", "Cheetah", "Lion", "Horse"])
        ]
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
        return 3 // 0: Task, 1: Captions, 2: Footer
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
            if let task = lsrw {
                cell.configureCell(with: task, attachments: task.file_path ?? [])
            }
            cell.reminderBtn.isHidden = true
            cell.exportRecordBtn.isHidden = false
            cell.exportRecordBtn.setTitle("View Submission", for: .normal)
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
                cell.config(attachments)
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
   
  
    @objc private func submitTapped() {
        print("✅ Submit button pressed")
        // add your submit logic here
    }
    
    @objc func exportBtnTapped() {
        let vc = LSRWSubmisionListVC()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
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
