//
//  AssignmentSummitionVC.swift
//  School Chimes
//
//  Created by Chandhru on 09/06/25.
//

import UIKit

class AssignmentSummitionVC: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var standerdSectionLbl: UILabel!
    @IBOutlet weak var sudentName: UILabel!
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var noDtaImg: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var sumitionList: UITableView!
    var assignments: [Submission]?
    var titleName:String?
    var subject:String?
    var id:String?
      override func viewDidLoad() {
          super.viewDidLoad()
          sumitionList.delegate = self
          sumitionList.dataSource = self
          sumitionList.register(UINib(nibName: "SubmissionTVC", bundle: nil), forCellReuseIdentifier: "SubmissionTVC")
          ReadStatusUpdate()
      }
    override func viewDidLayoutSubviews() {
        view.applyGradient(colors: [Colornames.gradientBlue,Colornames.gradientgreen], startPoint: CGPoint(x: 1, y: 0.5),endPoint: CGPoint(x: 0, y: 0.5))
    }
    func ReadStatusUpdate(){
        
        APIService.shared.makeApi(url: ServiceUrl.comm_api_my_submissions, parameters: ["id":id ?? ""], type: ApitTypeSringFile.GET, token: UserDefaultFileManager.get_child_Details()?.access_token ?? "") { [self] (result : Result<SubmissionResponse,Error>) in
            
            switch result {
            case .success(let SuccessMessage):
                    DispatchQueue.main.async { [self] in
                        assignments = SuccessMessage.data
                        noDtaImg.isHidden = !SuccessMessage.data.isEmpty
                        nodataLbl.isHidden = !SuccessMessage.data.isEmpty
                        nodataLbl.text = SuccessMessage.message
                        sumitionList.reloadData()
                }
            case .failure(let error):
                
                DispatchQueue.main.async {
                    let data: [Submission] = [
                        Submission(
                            id: "1001",
                            content: [
                                FilePath(url: "https://example.com/image1.jpg", type: "IMAGE")
                            ],
                            description: "This is the first dummy assignment submission",
                            submitted_on: "2025-06-09 10:45:00" // today
                        ),
                        Submission(
                            id: "1002",
                            content: [
                                FilePath(url: "https://example.com/image2.jpg", type: "IMAGE")
                            ],
                            description: "Second submission done yesterday evening",
                            submitted_on: "2025-06-08 18:30:00" // 1 day ago
                        ),
                        Submission(
                            id: "1003",
                            content: [
                                FilePath(url: "https://example.com/image3.pdf", type: "PDF")
                            ],
                            description: "Late submission for science project",
                            submitted_on: "2025-06-06 14:15:00" // 3 days ago
                        )
                    ]

                    self.assignments = data
                    self.sumitionList.reloadData()
                    print(error.localizedDescription)
                }
            }
        }
    }
      @IBAction func BackBtn(_ sender: UIButton) {
          dismiss(animated: true)
      }

      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return assignments?.count ?? 0
      }

      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = sumitionList.dequeueReusableCell(withIdentifier: "SubmissionTVC", for: indexPath) as! SubmissionTVC
          if let data = assignments?[indexPath.row]{
              let (timeAgo, dateString) = data.submitted_on.submissionTimeDisplay()
              cell.assignmentTitle.text = titleName
              cell.subjectName.text = subject
              cell.date.text = dateString
              cell.FilesUrl = data.content
              cell.timeLeft.text = "Submited: \(timeAgo)"
              cell.descriptionLbl.text = data.description
              cell.descriptionLbl.setupExpandable(text: data.description)
              cell.descriptionLbl.onExpandableTap = {
                  cell.descriptionLbl.isExpanded.toggle()
                  tableView.beginUpdates()
                  tableView.endUpdates()
              }
          }
          
          return cell
      }

      func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return UITableView.automaticDimension
      }
}

extension String {
    func submissionTimeDisplay(format: String = "yyyy-MM-dd HH:mm:ss") -> (String, String) {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = formatter.date(from: self) else {
            return ("Invalid time", "")
        }
        
        let now = Date()
        let calendar = Calendar.current
        let submittedDay = calendar.startOfDay(for: date)
        let currentDay = calendar.startOfDay(for: now)
        
        let components = calendar.dateComponents([.day], from: submittedDay, to: currentDay)
        let interval = now.timeIntervalSince(date)
        
        // Time part
        var timeAgo = ""
        if calendar.isDateInToday(date) {
            if interval < 60 {
                timeAgo = "Just now"
            } else if interval < 3600 {
                timeAgo = "\(Int(interval / 60)) min ago"
            } else {
                timeAgo = "\(Int(interval / 3600)) hr ago"
            }
        } else if let days = components.day {
            timeAgo = "\(days) Day\(days > 1 ? "s" : "") Ago"
        }
        
        // Date part
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        let dateString = dateFormatter.string(from: date)
        
        return (timeAgo, dateString)
    }
}
