//
//  SelectedLSRWSubmissionVC.swift
//  School Chimes
//
//  Created by Chandhru on 07/07/25.
//

import UIKit

class SelectedLSRWSubmissionVC: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    var submitedLsrw: [LsrwRespons] = []
//    [LsrwRespons(title: <#T##String?#>, description: <#T##String?#>, recordingTime: <#T##String?#>, submitedCount: <#T##String?#>, iframe: <#T##String?#>, filePath:[FilePath( url: "https://example.com/audio.mp3", type: "Audio")], QuestionAns: [
//        QuestionAnswer(Qst: "Q1 - What is Swift?", Answer: "A modern iOS language", Status: true),
//        QuestionAnswer(Qst: "Q2 - What is Codable?", Answer: "Used for JSON", Status: true),
//        QuestionAnswer(Qst: "Q - Use of struct?", Answer: "For value types", Status: false),
//        QuestionAnswer(Qst: "Q.4 - What is URLSession?", Answer: "For network calls", Status: true)
//    ])]
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableCells()
//        tableView.dataSource = self
//        tableView.delegate = self
        
    }
    private func registerTableCells() {
        tableView.register(UINib(nibName: "QuestionAnsTVC", bundle: nil), forCellReuseIdentifier: "QuestionAnsTVC")
        tableView.register(UINib(nibName: CellConfingName.HomeWorkTVC, bundle: nil), forCellReuseIdentifier: CellConfingName.HomeWorkTVC)
        tableView.register(UINib(nibName: CellConfingName.VideoTVCell, bundle: nil), forCellReuseIdentifier: CellConfingName.VideoTVCell)
        tableView.register(UINib(nibName: CellConfingName.HistoryTC, bundle: nil), forCellReuseIdentifier: CellConfingName.HistoryTC)
    }
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//    }
}
struct QuestionAnswer: Codable {
    let Qst: String?
    let Answer: String?
    let Status: Bool?
}

struct LsrwRespons: Codable {
    let title: String?
    let description: String?
    let recordingTime: String?
    let submitedCount: String?
    let iframe: String?
    let filePath: [FilePath]?
    let QuestionAns: [QuestionAnswer]?
}
enum FileType: String {
    case Audio = "Audio"
    case Video = "Video"
    case Image = "Image"
    case Document = "Document"
}
