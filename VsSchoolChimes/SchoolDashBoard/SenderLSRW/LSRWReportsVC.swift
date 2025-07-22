//
//  LSRWReportsVC.swift
//  School Chimes
//
//  Created by Chandhru on 03/07/25.
//

import UIKit

class LSRWReportsVC: UIViewController ,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tv: UITableView!
    var rowIdentifier = "NewLSRWTVcell"
    
    let tasks: [LSRW] = [
        LSRW(
            title: "Listening Comprehension - The Environment",
            description: "Listen to an audio about saving the environment and answer questions.",
            subject: "English",
            submitedOn: "2025-01-15",
            duration: "3 min",
            recording: "5 min",
            iframe: "",
            type: "listen",
            filePath: [FileData(url: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/communication/7043/2025-06-174/RecordedAudio.m4a", type: "audio")],
            test: [
                TestQuestion(question: "What are the three main types of pollution?", options: ["Air, Water, Noise", "Air, Light, Soil"]),
                TestQuestion(question: "What is one cause of water pollution mentioned?", options: ["Industrial waste", "Airplanes"]),
                TestQuestion(question: "What solution was suggested to reduce noise pollution?", options: ["Use earplugs", "Reduce traffic"]),
                TestQuestion(question: "Why is saving the environment important?", options: ["For future generations", "To save money"])
            ]
        ),
        
        LSRW(
            title: "Reading - Short Story Analysis",
            description: "Read a short story and write about its characters and themes.",
            subject: "Literature",
            submitedOn: "2025-01-18",
            duration: "",
            recording: "",
            iframe: "",
            type: "read",
            filePath: [FileData(url: "https://example.com/story.pdf", type: "document")],
            test: [
                TestQuestion(question: "Who is the main character in the story?", options: ["John", "Tom"]),
                TestQuestion(question: "What is the setting of the story?", options: ["A village", "A city"]),
                TestQuestion(question: "What conflict does the character face?", options: ["Losing a job", "Failing school"]),
                TestQuestion(question: "What is the theme of the story?", options: ["Perseverance", "Greed"])
            ]
        ),

        LSRW(
            title: "Reading - Poetry Analysis",
            description: "Read a poem and explain its meaning and main ideas.",
            subject: "Literature",
            submitedOn: "2025-01-28",
            duration: "",
            recording: "",
            iframe: "",
            type: "read",
            filePath: [FileData(url: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/communication/7043/2025-06-27/compressed_1751027285425.webp", type: "image"),FileData(url: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//D73D9C9B-FCF0-4ABF-9509-B674C1A6AB53.jpg", type: "image"),FileData(url: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//BADD0725-8EBD-45B1-870D-158E316A77F6.jpg", type: "image"),FileData(url: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//B41BB71B-0AB5-45F0-8346-B258E176C923.jpg", type: "image")],
            test: [
                TestQuestion(question: "Who wrote the poem?", options: ["Robert Frost", "Emily Dickinson"]),
                TestQuestion(question: "What is the poem about?", options: ["Life choices", "Winter"]),
                TestQuestion(question: "What literary device is used in the last line?", options: ["Metaphor", "Simile"]),
                TestQuestion(question: "What is the tone of the poem?", options: ["Reflective", "Angry"])
            ]
        ),

        LSRW(
            title: "Listening - Understanding News Broadcast",
            description: "Listen to a news report and summarize the main points.",
            subject: "Social Studies",
            submitedOn: "2025-01-22",
            duration: "2 min",
            recording: "3 min",
            iframe: "",
            type: "listen",
            filePath: [FileData(url: "https://example.com/newsclip.mp3", type: "audio")],
            test: [
                TestQuestion(question: "Who is speaking in the news clip?", options: ["A journalist", "A student"]),
                TestQuestion(question: "What is the main event discussed?", options: ["A climate protest", "A sports final"]),
                TestQuestion(question: "Where did the event happen?", options: ["New York", "London"]),
                TestQuestion(question: "What was the government’s response?", options: ["Supportive", "Unclear"])
            ]
        ),

        // Writing and Speaking tasks (no test questions needed)
        LSRW(
            title: "Writing - Persuasive Essay",
            description: "Write an essay arguing if homework should be banned or not.",
            subject: "English",
            submitedOn: "2025-01-25",
            duration: "",
            recording: "",
            iframe: "",
            type: "write",
            filePath: [],
            test: []
        ),

        LSRW(
            title: "Speaking - Debate on Climate Change",
            description: "Give a 5-minute speech about whether climate change is real or not.",
            subject: "English",
            submitedOn: "2025-01-20",
            duration: "",
            recording: "5 min",
            iframe: "https://player.vimeo.com/video/1097487862?h=57b122eb27",
            type: "speak",
            filePath: [FileData(url: "https://player.vimeo.com/video/1097487862?h=57b122eb27", type: "video")],
            test: []
        ),

        LSRW(
            title: "Speaking - Show and Tell",
            description: "Present an item that is important to you and explain why.",
            subject: "English",
            submitedOn: "2025-01-30",
            duration: "",
            recording: "2 min",
            iframe: "https://example.com/showtell.mov",
            type: "speak",
            filePath: [FileData(url: "https://example.com/showtell.mov", type: "video")],
            test: []
        ),

        LSRW(
            title: "Writing - Creative Writing",
            description: "Write a short, creative story with a good plot and characters.",
            subject: "English",
            submitedOn: "2025-02-01",
            duration: "",
            recording: "",
            iframe: "",
            type: "write",
            filePath: [FileData(url: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/communication/7043/2025-06-27/compressed_1751027285425.webp", type: "image"),FileData(url: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//D73D9C9B-FCF0-4ABF-9509-B674C1A6AB53.jpg", type: "image"),FileData(url: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//BADD0725-8EBD-45B1-870D-158E316A77F6.jpg", type: "image"),FileData(url: "https://schoolchimes-communication.s3.ap-south-1.amazonaws.com/uploads/images//B41BB71B-0AB5-45F0-8346-B258E176C923.jpg", type: "image")],
            test: []
        )
    ]


  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = CommonStringFile.Search.translated()
        searchBar.delegate = self
        searchBar.addDoneButton()
        tv.register(UINib(nibName: rowIdentifier, bundle: nil), forCellReuseIdentifier: rowIdentifier)
        tv.delegate = self
        tv.dataSource = self
        tv.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        print("dismiss")
        
    }
    @IBAction func takeReadingSkill() {
        let vc = LSRWTakingSkillViewController(nibName: nil, bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated:   true)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: rowIdentifier, for: indexPath) as! NewLSRWTVcell
        cell.TitleLbl.text = tasks[indexPath.row].title
        cell.DescriptionLbl.text = tasks[indexPath.row].description
        cell.Subject.setTitle(tasks[indexPath.row].subject, for: .normal)
        cell.Date.setTitle(tasks[indexPath.row].submitedOn, for: .normal)
        cell.TakeSkillBtn.setTitle("Submissions", for: .normal)
        cell.TakeSkillBtn.tag = indexPath.row
        cell.TakeSkillBtn.addTarget(self, action: #selector(AttachmentRedirect(_:)), for: .touchUpInside)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    @objc func AttachmentRedirect(_ sender: UIButton) {
        let index = sender.tag
        if #available(iOS 15.0, *) {
            let vc = LSRWActivitesVC(nibName: nil, bundle: nil)
            
//            vc.lsrw = tasks[index]
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
            
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
