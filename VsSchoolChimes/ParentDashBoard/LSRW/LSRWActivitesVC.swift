//
//  LSRWActivitesVC.swift
//  School Chimes
//
//  Created by Chandhru on 30/06/25.
//

import UIKit
import AVFoundation

@available(iOS 15.0, *)
class LSRWActivitesVC: UIViewController, BaktoHome {
    func backtohome() {
        testTable.reloadData()
    }
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var testTable: UITableView!
    
    // MARK: - Properties
    var lsrw: LSRW?
    private var captions: [CaptionType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptions()
        setupTableView()
    }
    
    // MARK: - Setup
    private func setupCaptions() {
        guard let lsrw = lsrw else { return }
        
        // Add initial attachment type if available
        if let firstAttachmentType = lsrw.filePath.first?.type {
            captions.append(firstAttachmentType == "audio" ? .audio : .attachments)
        }
        
        // Configure captions based on LSRW type
        switch lsrw.type.lowercased() {
        case "read", "listen":
            captions += Array(repeating: .test, count: lsrw.test.count)
        case "write":
            captions.append(.addAttachment)
        case "speak":
            captions += [.record, .addAttachment]
        default:
            break
        }
        captions.insert(.task, at: 0)
    }
    
    private func setupTableView() {
        let nibs = [
            "TestTVC", "RecorderTVC", "AddAttachmentTVC",
            "LSWTaskTVC", "LSWViewAttachmentTVC", "AudioPlayerTVC"
        ]
        nibs.forEach { testTable.register(UINib(nibName: $0, bundle: nil), forCellReuseIdentifier: $0) }
        
        testTable.delegate = self
        testTable.dataSource = self
        testTable.rowHeight = UITableView.automaticDimension
        testTable.estimatedRowHeight = 100.0
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
            return cell
            
        case .attachments:
            let cell = tableView.dequeueReusableCell(withIdentifier: "LSWViewAttachmentTVC", for: indexPath) as! LSWViewAttachmentTVC
            let type = lsrw?.filePath.first?.type ?? ""
            cell.videoView.isHidden = (type != "video")
            cell.imagesView.isHidden = (type != "image")
            cell.loadFilePath(lsrw?.filePath ?? [])
            return cell
            
        case .audio:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioPlayerTVC", for: indexPath) as! AudioPlayerTVC
            if let urlString = lsrw?.filePath.first?.url, let url = URL(string: urlString) {
                cell.audioURL = url
            }
            return cell
            
        case .test:
            let index = captions[..<indexPath.row].filter { $0 == .test }.count
            guard let test = lsrw?.test[safe: index] else {
                let cell = UITableViewCell()
                cell.textLabel?.text = "No Test Available"
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "TestTVC", for: indexPath) as! TestTVC
            cell.test = test
            cell.questionLbl.text = test.question
            return cell
            
        case .addAttachment:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAttachmentTVC", for: indexPath) as! AddAttachmentTVC
            cell.delegate = self
            return cell
            
        case .record:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecorderTVC", for: indexPath) as! RecorderTVC
//            cell.audioURLString = lsrw?.filePath.first?.url
            cell.recoderTime.text = lsrw?.test.first?.question ?? "00:00"
            return cell
        }
    }
}

// MARK: - CaptionType Enum
enum CaptionType: String {
    case task
    case audio
    case attachments
    case test
    case addAttachment
    case record
}

// MARK: - Collection Extension for Safe Indexing
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Array Extension for Safe Access
extension Array {
    subscript(safe index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
}

