//
//  QuizCompletedVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 09/09/25.
//

import UIKit

class QuizCompletedVc: UIViewController {

    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var menuNameLbl: UILabel!
    
    var get_QuizDetails : [myQuizDetails] = []
    var quiz_details : [MyQuizDetails]?
    var selected_QuizId : String?
    var childDetails = UserDefaultFileManager.get_child_Details()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = childDetails?.name ?? ""
        let standard = (childDetails?.standard_name ?? "") + " - " + (childDetails?.section_name ?? "")
        backBtn.configureAsBackButton(firstLine: name, secondLine: standard)
        menuNameLbl.text = MenuStringFile.selectedMenuName

        tv.register(UINib(nibName: "QuizCompletedFirstTv", bundle: nil), forCellReuseIdentifier: "QuizCompletedFirstTv")
//        
        tv.register(UINib(nibName: CellConfingName.CompletedTVcell, bundle: nil), forCellReuseIdentifier: CellConfingName.CompletedTVcell)
        mySubmission()
        tv.dataSource = self
        tv.delegate = self
//        tv.reloadData()
        
    }

    @IBAction func backBtn(_ sender: Any) {
        
        dismiss(animated: true)
    }

}
extension QuizCompletedVc : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + (quiz_details?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            
            
                // ✅ First cell: Summary
                let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCompletedFirstTv", for: indexPath) as! QuizCompletedFirstTv
            cell.setProgress(to: 50.0)
//            cell.subjectQuiz.text =
//                let studentData = apiResponse // your parsed model
//                cell.studentIdLabel.text = studentData.student_id
//                cell.rightAnswerLabel.text = studentData.right_answer
//                cell.wrongAnswerLabel.text = studentData.wrong_answer
//                cell.unAnswerLabel.text = studentData.un_answer
                
                return cell
            } else {
                // ✅ Remaining cells: Quiz details
                let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedTVcell", for: indexPath) as! CompletedTVcell
                          
                let questionNumber = indexPath.row   // since 0 = summary, 1 = first question
                cell.QuestionLbl.text = "\(questionNumber)) " + "  " + (quiz_details?[indexPath.row - 1].question ?? "")
        
                let detail = quiz_details?[indexPath.row - 1]

                // Reset default state (very important because of cell reuse)
                [cell.Button1, cell.Button2, cell.Button3, cell.Button4].forEach { button in
                    button?.backgroundColor = .clr
                    button?.setTitleColor(.black, for: .normal)
                }

                // Assign titles
                cell.Button1.setTitle(detail?.a_option, for: .normal)
                cell.Button2.setTitle(detail?.b_option, for: .normal)
                cell.Button3.setTitle(detail?.c_cption, for: .normal)
                cell.Button4.setTitle(detail?.d_option, for: .normal)

                guard let studentAnswer = detail?.student_answer,
                      let correctAnswer = detail?.correct_answer else {
                    return cell
                }

                // Check if student answer is correct
                if studentAnswer == correctAnswer {
                    // ✅ Correct → Green
                    if cell.Button1.title(for: .normal) == studentAnswer {
                        cell.Button1.backgroundColor = .systemGreen.withAlphaComponent(0.3)
                    } else if cell.Button2.title(for: .normal) == studentAnswer {
                        cell.Button2.backgroundColor = .systemGreen.withAlphaComponent(0.3)
                    } else if cell.Button3.title(for: .normal) == studentAnswer {
                        cell.Button3.backgroundColor = .systemGreen.withAlphaComponent(0.3)
                    } else if cell.Button4.title(for: .normal) == studentAnswer {
                        cell.Button4.backgroundColor = .systemGreen.withAlphaComponent(0.3)
                    }
                    
                    cell.crtAnsLbl.isHidden  = true
                } else {
                    // ❌ Wrong → Red for student's choice, Green for correct answer
                    if cell.Button1.title(for: .normal) == studentAnswer {
                        cell.Button1.backgroundColor = .systemRed
                            .withAlphaComponent(0.3)
                    } else if cell.Button2.title(for: .normal) == studentAnswer {
                        cell.Button2.backgroundColor = .systemRed.withAlphaComponent(0.3)
                    } else if cell.Button3.title(for: .normal) == studentAnswer {
                        cell.Button3.backgroundColor = .systemRed.withAlphaComponent(0.3)
                    } else if cell.Button4.title(for: .normal) == studentAnswer {
                        cell.Button4.backgroundColor = .systemRed.withAlphaComponent(0.3)
                    }

                    // ✅ Highlight correct answer separately
                    if cell.Button1.title(for: .normal) == correctAnswer {
                        cell.Button1.backgroundColor = .systemGreen
                    } else if cell.Button2.title(for: .normal) == correctAnswer {
                        cell.Button2.backgroundColor = .systemGreen
                    } else if cell.Button3.title(for: .normal) == correctAnswer {
                        cell.Button3.backgroundColor = .systemGreen
                    } else if cell.Button4.title(for: .normal) == correctAnswer {
                        cell.Button4.backgroundColor = .systemGreen
                    }

                    // 🔎 Show label with correct answer (if needed)
                    cell.crtAnsLbl.isHidden  = false
                    cell.crtAnsLbl.text = "Correct: \(correctAnswer)"
                }
                
                cell.file_path = detail?.file_path
                cell.cv.isHidden = detail?.file_path?.count == 0
                //cell.pageControls.isHidden = detail?.file_path?.count ?? 0 <= 1
                cell.pageControls.numberOfPages = detail?.file_path?.count ?? 0
                return cell
            }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 320
        }else{
            return UITableView.automaticDimension
        }
        
    }
    
    
    func mySubmission() {
       
        APIService.shared
            .makeApi(url: ServiceUrl.my_submissions, parameters: ["id" : selected_QuizId ?? "" ], type: ApitTypeSringFile.GET, token: childDetails?.access_token ?? "") { [weak self] (
                result: Result<MyQuizSuc,
                Error>
            ) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let successResponse):
                   
                    if successResponse.status == true{
                        
                        self.get_QuizDetails = successResponse.data ?? []
                        self.quiz_details = successResponse.data?.first?.quiz_details ?? []
                        self.tv.reloadData()
                    }else{
                        
                        
                    }
                    
                    
                case .failure(let error):
                    print("Error fetching notices: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
}

