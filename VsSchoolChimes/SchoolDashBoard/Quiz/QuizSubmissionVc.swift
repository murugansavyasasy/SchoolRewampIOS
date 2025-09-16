//
//  QuizSubmissionVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 10/09/25.
//

import UIKit

class QuizSubmissionVc: UIViewController {
    
    @IBOutlet weak var discreptionsLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var pendingBtn: UIButton!
    @IBOutlet weak var allSubmissionBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var PostedOnLbl: UILabel!
    @IBOutlet weak var subjectLbl: UILabel!
    @IBOutlet weak var QuizDetailsView: UIView!
    @IBOutlet weak var DescriptionBaseview: UIView!
    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var tvHeight: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var NoDataImage: UIImageView!
    @IBOutlet weak var NoDataLbl: UILabel!
    
    var senderQuizlist = senderQuizListData()
    var QuizStudentRepo : [QuizStudentReportData] = []
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        discreptionsLbl.text = senderQuizlist.description
        titleLbl.text = senderQuizlist.title
        subjectLbl.text = senderQuizlist.subject
        PostedOnLbl.text = formattedDateStatus(
            from: senderQuizlist.submission_date ??  "")
        QuizDetailsView.layer.cornerRadius = 10
        DescriptionBaseview.layer.cornerRadius = 10
        NoDataImage.isHidden = true
        NoDataLbl.isHidden = true
        tv.isScrollEnabled = false
        tv.register(UINib(nibName: "QuizSubmisionTvCell", bundle: nil), forCellReuseIdentifier: "QuizSubmisionTvCell")
        
        
        tv.delegate = self
        tv.dataSource = self
        
        getSubmissionList(QuizId : senderQuizlist.id ?? "")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeight()
    }
    
    func updateTableHeight() {
        tv.layoutIfNeeded()
        tvHeight.constant = tv.contentSize.height
    }
    
    @IBAction func backAct(_ sender: Any) {
        
        dismiss(animated: true)
    }
}


extension QuizSubmissionVc: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QuizStudentRepo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tv.dequeueReusableCell(
            withIdentifier: "QuizSubmisionTvCell",
            for: indexPath
        ) as? QuizSubmisionTvCell else{
            
            return UITableViewCell()
        }
       
        
        cell.nameLbl.text = QuizStudentRepo[indexPath.row].student_name
        cell.classLbl.text = (QuizStudentRepo[indexPath.row].standard ?? "") + " " + (
            QuizStudentRepo[indexPath.row].section ?? ""
        )
        cell.SubmittedOnBtn.setTitle(QuizStudentRepo[indexPath.row].submitted_on ?? "", for: .normal)
        let submittedOn = QuizStudentRepo[indexPath.row].submitted_on ?? ""

        // set button title with new line
        cell.SubmittedOnBtn.titleLabel?.lineBreakMode = .byWordWrapping
        cell.SubmittedOnBtn.titleLabel?.numberOfLines = 0
        cell.SubmittedOnBtn.setTitle("Submitted On:\n\(submittedOn)", for: .normal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // ✅ Update height when a cell finishes laying out
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateTableHeight()
        }
    }
    
    func getSubmissionList(QuizId : String){
    
            APIService.shared
            .makeApi(url: ServiceUrl.quiz_submission_list, parameters: ["id" : QuizId], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [weak self] (
                    result: Result<QuizStudentReportSuc,
                    Error>
                ) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let successResponse):
                       
                        self.QuizStudentRepo = successResponse.data ?? []
                        
                        self.tv.reloadData()
                      
                            self.updateTableHeight()
                        
                    case .failure(let error):
                        print("Error fetching notices: \(error.localizedDescription)")
                    }
                }
            }
        }
    
}
