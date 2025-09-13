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
        vc.noOfQuestion = get_QuizDetails[index].no_of_questions ?? 0 
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
    
        let nib3 = UINib(nibName: CellConfingName.SenderQuizListTvCell, bundle: nil)
        tv.register(nib3, forCellReuseIdentifier: CellConfingName.SenderQuizListTvCell)
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
        print("get_QuizDetailsget_QuizDetails",get_QuizDetails.count)
            return get_QuizDetails.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellConfingName.SenderQuizListTvCell, for: indexPath) as? QuizListTvCell else {
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
        cell.exameDateLbl.text = formattedDateStatus(
            from: get_QuizDetails[indexPath.row].sent_time ?? "")
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
