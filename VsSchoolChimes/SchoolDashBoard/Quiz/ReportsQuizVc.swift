//
//  ReportsQuizVc.swift
//  School Chimes
//
//  Created by SARANRAJ SHANMUGAM on 24/08/25.
//

import UIKit

class ReportsQuizVc: UIViewController,SelectNotice,addQuestionAndSubmitedListDelegate {
    func addQuestionAndSubmitedList(index: Int) {
        
        let vc = CreateQuizQutionVc(nibName: nil, bundle: nil)
        vc.id = get_QuizDetails[index].id
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }

    func didTapButton(
        title: String,
        content: String,
        items: [FilePath],
        editId: String
    ) {
        print("")
    }
    var selectNotice: SelectNotice?
    var get_QuizDetails : [senderQuizListData] = []
    var staffDetails = UserDefaultFileManager.get_staff_Details()
    let images = ["Quiz1", "Quiz2", "Quiz3"]
    @IBOutlet weak var tv: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        CellRegister()
    }
    
    
    func CellRegister(){
    
        let nib3 = UINib(nibName: CellConfingName.QuizListTvCell, bundle: nil)
        tv.register(nib3, forCellReuseIdentifier: CellConfingName.QuizListTvCell)
        tv.dataSource = self
        tv.delegate = self
        Get_Quiz()
    }
    
    
    func Get_Quiz() {
       
        APIService.shared
            .makeApi(url: ServiceUrl.quiz_report, parameters: ["type" : "2"], type: ApitTypeSringFile.GET, token: staffDetails?.access_token ?? "") { [weak self] (
                result: Result<senderQuizListSuc,
                Error>
            ) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let successResponse):
                   
                    self.get_QuizDetails = successResponse.data ?? []
                    
                    self.tv.reloadData()
                    
                case .failure(let error):
                    print("Error fetching notices: \(error.localizedDescription)")
                }
            }
        }
    }


   
}

extension ReportsQuizVc : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
            return get_QuizDetails.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if id == 1 {
//            let cell = tv.dequeueReusableCell(withIdentifier: CellConfingName.CompletedTVcell, for: indexPath) as! CompletedTVcell
//
//            // Set the question text
//            cell.QuestionLbl.text = String(indexPath.row+1) + ". " + questions[indexPath.row].text
//
//            // Reset button colors to a default state (e.g., .clear or another default color)
//            for button in cell.buttons {
//                button.backgroundColor = .clear
//                button.setTitleColor(.systemBlue, for: .normal)
//                button.layer.borderWidth = 1
//                button.layer.borderColor = UIColor.systemBlue.cgColor
//            }
//
//            // Configure the button titles
//            for (i, button) in cell.buttons.enumerated() {
//                button.setTitle(questions[indexPath.row].options[i], for: .normal)
//            }
//
//            // Highlight the selected and correct options
//            if selectedOption[indexPath.row] != questions[indexPath.row].correctOptionIndex {
//                cell.buttons[selectedOption[indexPath.row]].backgroundColor = .systemRed // Incorrect selection
//                cell.buttons[selectedOption[indexPath.row]].setTitleColor(.white, for: .normal)
//                cell.buttons[selectedOption[indexPath.row]].layer.borderColor = UIColor.systemRed.cgColor
//            }
//            cell.buttons[questions[indexPath.row].correctOptionIndex].backgroundColor = .systemGreen // Correct answer
//            cell.buttons[questions[indexPath.row].correctOptionIndex].setTitleColor(.white, for: .normal)
//            cell.buttons[questions[indexPath.row].correctOptionIndex].layer.borderColor = UIColor.systemGreen.cgColor
//            return cell
//
//        }else{
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.QuizListTvCell, for: indexPath) as? QuizListTvCell else {
                return UITableViewCell()
            }
            let quiz = get_QuizDetails[indexPath.row]
               let imageName = images[indexPath.row % images.count]
            cell.DeafultimageView.image = UIImage(named: imageName)
        cell.delegate = self
        cell.addQuestionBtnName.tag = indexPath.row
            cell.PlayBtn.isHidden = true
            cell.titleLbl.text = get_QuizDetails[indexPath.row].title
            cell.discretiponsLbl.text = get_QuizDetails[indexPath.row].description
            cell.exameDateLbl.text = "Create on 16,Oct 2025 04:24 PM"
            cell.subjectLbl.text = get_QuizDetails[indexPath.row].subject
            cell.postedByLbl.text = ("Posted By:") + (
                get_QuizDetails[indexPath.row].sent_by ?? ""
            )
            return cell
//        }
    }
    
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        
       
            
//            let vc = PlayQuizVc(nibName: nil, bundle: nil)
////            vc.selectedQuizId = self.get_QuizDetails[indexPath.row].quiz_id
//            vc.modalPresentationStyle = .fullScreen
//            present(vc, animated: true)
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
